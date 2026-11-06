#!/usr/bin/env python3
"""Parallel overnight orchestrator: several scheduled tasks at once, one git worktree each.

Sequential runner stays in tools/job_runner.py. This one never loops or sleeps: every command
does one step and exits, state lives in logs/orchestrator/state.json. A Claude session driven by
/loop (dynamic mode) calls `status` and `merge` from ScheduleWakeup check-ins (see DRIVER below).

  python3 tools/orchestrator.py plan [--max 4]      DRY RUN: which tasks would run in parallel, which are skipped and why
  python3 tools/orchestrator.py infer [--write]     fill missing `touches` (file globs) in schedule.json from the task briefs
  python3 tools/orchestrator.py start [--max 4]     baseline tests, worktree ../wt/<id> on branch task/<id>, one detached
                                                    `claude -p "/overnight-worker <id>"` per task
  python3 tools/orchestrator.py baseline            re-run the baseline test count at HEAD (start does it once)
  python3 tools/orchestrator.py resume <id>         relaunch the worker of a stopped task in its worktree
  python3 tools/orchestrator.py status              which workers are running / finished (reads their logs)
  python3 tools/orchestrator.py merge               serial merge queue for finished workers (see below)
  python3 tools/orchestrator.py report              write reports/overnight_<date>.md

Ready task = status queued/partial, all depends_on done, not `needs_owner`, owner_agent not an owner-only
agent (qa-analyst, economy-designer), title not "Decide..."/"OWNER...". Selection: `priority` (1 first, default 2), then partial first, then schedule order; skip
a task whose `touches` overlap one already chosen (globs compare by their literal prefix), up to --max (default 4).

Workers (skill overnight-worker) build in their worktree, commit on task/<id>, iterate the test suite up to 5 times and
never touch schedule.json or blackboard.md. The merge queue handles one finished task at a time:
  rebase task/<id> onto the base branch -> full test suite in the worktree -> `git merge --ff-only` in the main checkout ->
  schedule.json + blackboard.md updated and committed (only those two files) -> worktree and branch removed.
A rebase conflict, a test FAIL, a dirty worktree or a refused fast-forward marks the task `blocked` (log path in
`blocked_log`), keeps worktree and branch, and does NOT merge. Never runs on `main` unless --allow-main.
Windowed Godot is only used by the worker's Quick look screenshot; no QA agents or bots are ever started.

DRIVER (what the /loop session does): `start`, then at each ScheduleWakeup check-in `status`; when workers have
finished run `merge`; when nothing is running or queued for merge run `report`; wake again after 10 to 20 minutes while any worker runs.
"""
import argparse
import datetime as dt
import fnmatch
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

ROOT = Path(__file__).resolve().parent.parent
WT_DIR = (ROOT.parent / "wt").resolve()
OUT = ROOT / "logs" / "orchestrator"
SCRATCH = WT_DIR / "_scratch"  # big temp files live on the same (large) volume as the project, never in /tmp or /var/folders
STATE = OUT / "state.json"
SCHEDULE = ROOT / "schedule.json"
# untracked files Godot generates in every worktree (textures extracted from the pirate ship model); not worker output
GDD_MERGED = []  # worktrees whose gdd.md conflict was resolved by keeping both sides
IGNORE_UNTRACKED = ("assets/ships/pirate_ship_01/",)
OWNER_ONLY = {"qa-analyst", "economy-designer"}
OPEN = {"queued", "partial"}
TOOLS = "Bash,Read,Edit,Write,Glob,Grep,Agent,Skill"
RESULT = "JOB_RESULT:"
TOTAL = re.compile(r"TOTAL pass=(\d+) fail=(\d+)")


def sh(cmd, cwd=ROOT, env=None, timeout=None):
    e = dict(os.environ, **(env or {}))
    return subprocess.run(cmd, cwd=cwd, env=e, capture_output=True, text=True, timeout=timeout)


def branch():
    return sh(["git", "branch", "--show-current"]).stdout.strip()


def load_schedule():
    return json.loads(SCHEDULE.read_text())


def save_schedule(data):
    # same layout as the checked-in file (2-space indent, no trailing newline): no whole-file reformat
    SCHEDULE.write_text(json.dumps(data, indent=2, ensure_ascii=False))


def load_state():
    return json.loads(STATE.read_text()) if STATE.exists() else {"tasks": {}}


def save_state(st):
    OUT.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(st, indent=2))


# ---------- touches ----------

def prefix(glob):
    m = re.search(r"[*?\[]", glob)
    return glob[: m.start()] if m else glob


def overlap(a, b):
    for x in a:
        for y in b:
            px, py = prefix(x), prefix(y)
            if px.startswith(py) or py.startswith(px) or fnmatch.fnmatch(x, y) or fnmatch.fnmatch(y, x):
                return (x, y)
    return None


def infer_touches(task, files):
    found = []
    for tok in re.findall(r"[\w./-]+\.(?:gd|json|md|tscn|gdshader|py)", task.get("brief", "") + " " + task.get("title", "")):
        if re.fullmatch(r"T\d+\.json", tok):
            continue
        cands = [f for f in files if f == tok or f.endswith("/" + tok)]
        for c in cands[:2]:
            if c not in found and not c.startswith("handoffs/"):
                found.append(c)
    agent = task.get("owner_agent", "")
    code_agents = {"gameplay-programmer", "ui-programmer", "juice-programmer", "fx-programmer"}
    only_data = found and all(f.startswith(("data/", "story/")) or f.endswith(".md") for f in found)
    if agent == "gameplay-programmer" and not only_data and "game/main.gd" not in found:
        found.append("game/main.gd")  # the 4000-line hub: assume gameplay work reaches it
    if not found:
        found = {"juice-programmer": ["game/juice.gd"], "ui-programmer": ["game/ui.gd"], "story-designer": ["story/**"],
                 "fx-programmer": ["game/fx/**"], "galaxy-builder": ["game/galaxy/**"]}.get(agent, ["game/main.gd"] if agent in code_agents else ["**"])
    return found


def repo_files():
    return sh(["git", "ls-files"]).stdout.split()


# ---------- selection ----------

def done_ids(data):
    return set(data.get("done_task_ids", [])) | {t["task_id"] for t in data["tasks"] if t["status"] == "done"}


def classify(data, in_flight=()):
    """-> (ready list, skipped list of (id, reason))"""
    done = done_ids(data)
    ready, skipped = [], []
    for t in data["tasks"]:
        tid = t["task_id"]
        if t["status"] not in OPEN:
            continue
        reason = None
        if tid in in_flight:
            reason = "already in flight"
        elif t.get("needs_owner"):
            reason = "needs owner: " + str(t["needs_owner"])
        elif t.get("owner_agent") in OWNER_ONLY:
            reason = "owner-only agent " + t["owner_agent"]
        elif t["title"].startswith(("Decide", "OWNER")):
            reason = "owner decision / owner starts by hand"
        else:
            missing = [d for d in t.get("depends_on", []) if d not in done]
            if missing:
                reason = "waits for " + ", ".join(missing)
        if reason:
            skipped.append((tid, reason))
        else:
            ready.append(t)
    ready.sort(key=lambda t: (t.get("priority", 2), t["status"] != "partial"))  # priority 1 first, then partial; stable: schedule order otherwise
    return ready, skipped


def select(ready, limit):
    chosen, deferred = [], []
    for t in ready:
        touches = t.get("touches") or ["**"]
        hit = None
        for c in chosen:
            o = overlap(touches, c.get("touches") or ["**"])
            if o:
                hit = (c["task_id"], o)
                break
        if hit:
            deferred.append((t["task_id"], f"touches overlap with {hit[0]} ({hit[1][0]} vs {hit[1][1]})"))
        elif len(chosen) >= limit:
            deferred.append((t["task_id"], f"over the limit of {limit}"))
        else:
            chosen.append(t)
    return chosen, deferred


# ---------- commands ----------

def cmd_infer(args):
    data = load_schedule()
    files = repo_files()
    n = 0
    for t in data["tasks"]:
        if t["status"] in OPEN and not t.get("touches"):
            t["touches"] = infer_touches(t, files)
            n += 1
            print(f"{t['task_id']:5} {t['owner_agent']:20} {t['touches']}")
    if args.write:
        save_schedule(data)
        print(f"wrote touches for {n} open tasks")
    else:
        print(f"dry run: {n} open tasks would get touches (use --write)")


def cmd_plan(args):
    data = load_schedule()
    ready, skipped = classify(data)
    chosen, deferred = select(ready, args.max)
    print(f"base branch: {branch()}   limit: {args.max}\n")
    print("RUN IN PARALLEL NOW:")
    for t in chosen:
        print(f"  {t['task_id']:5} {t['owner_agent']:20} {t['title'][:60]}\n        touches {t.get('touches') or ['** (not set)']}")
    if not chosen:
        print("  (nothing)")
    print("\nREADY BUT WAITING FOR A LATER ROUND:")
    for tid, why in deferred:
        print(f"  {tid:5} {why}")
    print("\nNOT READY:")
    for tid, why in skipped:
        print(f"  {tid:5} {why}")
    missing = [t["task_id"] for t in ready if not t.get("touches")]
    if missing:
        print("\nno `touches` yet (treated as '**', overlaps everything):", ", ".join(missing), "-> run: infer --write")


def run_tests(cwd, tag):
    SCRATCH.mkdir(parents=True, exist_ok=True)
    scratch = str(SCRATCH / f"test-home-{tag}")
    p = sh(["sh", "tools/tests/run.sh"], cwd=cwd, env={"STAR_TEST_SCRATCH": scratch, "TMPDIR": str(SCRATCH)}, timeout=1500)
    shutil.rmtree(scratch, ignore_errors=True)
    out = p.stdout + p.stderr
    m = TOTAL.findall(out)
    pas, fail = (int(m[-1][0]), int(m[-1][1])) if m else (0, -1)
    fails = [l for l in out.splitlines() if l.startswith("FAIL")]
    return {"pass": pas, "fail": fail, "code": p.returncode, "fails": fails[:30], "output": out}


def prepare_worktree(path, br, base):
    sh(["git", "worktree", "add", "-b", br, str(path), base])
    # untracked-but-needed: Godot binary (gitignored, 337M) by symlink, import cache by APFS clone
    gd = path / "tools" / "godot"
    if not gd.exists():
        gd.symlink_to(ROOT / "tools" / "godot")
    cache = path / ".godot"
    if not cache.exists() and (ROOT / ".godot").exists():
        if sh(["cp", "-cR", str(ROOT / ".godot"), str(cache)]).returncode != 0:
            shutil.copytree(ROOT / ".godot", cache)


def ensure_baseline(st):
    """Full test run on a throwaway worktree at HEAD; stores pass/fail counts in the state."""
    bw = WT_DIR / "_baseline"
    if bw.exists():
        sh(["git", "worktree", "remove", "--force", str(bw)])
    WT_DIR.mkdir(parents=True, exist_ok=True)
    sh(["git", "worktree", "add", "--detach", str(bw), "HEAD"])
    gd = bw / "tools" / "godot"
    if not gd.exists():
        gd.symlink_to(ROOT / "tools" / "godot")
    if not (bw / ".godot").exists() and (ROOT / ".godot").exists():
        sh(["cp", "-cR", str(ROOT / ".godot"), str(bw / ".godot")])
    r = run_tests(bw, "baseline")
    st["baseline"] = {"pass": r["pass"], "fail": r["fail"], "fails": r["fails"],
                      "commit": sh(["git", "rev-parse", "--short", "HEAD"]).stdout.strip()}
    (OUT / "baseline.log").write_text(r["output"][-6000:])
    sh(["git", "worktree", "remove", "--force", str(bw)])
    print("baseline at HEAD:", st["baseline"]["pass"], "pass,", st["baseline"]["fail"], "fail")


def cmd_baseline(args):
    st = load_state()
    ensure_baseline(st)
    save_state(st)


def cmd_start(args):
    if branch() in ("main", "") and not args.allow_main:
        sys.exit("refusing to run on branch main; pass --allow-main to override")
    if shutil.which("claude") is None:
        sys.exit("claude CLI not found on PATH")
    st = load_state()
    in_flight = {k for k, v in st["tasks"].items() if v["state"] in ("running", "finished", "blocked")}
    data = load_schedule()
    ready, _ = classify(data, in_flight)
    running = [k for k, v in st["tasks"].items() if v["state"] == "running"]
    chosen, _ = select(ready, max(0, args.max - len(running)))
    if not chosen:
        print("nothing to start")
        return
    base = branch()
    OUT.mkdir(parents=True, exist_ok=True)
    WT_DIR.mkdir(parents=True, exist_ok=True)
    if "baseline" not in st:
        ensure_baseline(st)
    st["base_branch"] = base
    st.setdefault("started", dt.datetime.now().isoformat(timespec="minutes"))
    for t in chosen:
        tid = t["task_id"]
        path, br = WT_DIR / tid, f"task/{tid}"
        prepare_worktree(path, br, base)
        log = OUT / f"{tid}.log"
        cmd = ["claude", "-p", f"/overnight-worker {tid}"]
        cmd += ["--dangerously-skip-permissions"] if args.skip_permissions else ["--permission-mode", "acceptEdits", "--allowedTools", TOOLS]
        if shutil.which("caffeinate"):
            cmd = ["caffeinate", "-i"] + cmd
        SCRATCH.mkdir(parents=True, exist_ok=True)
        scratch = str(SCRATCH / f"test-home-{tid}")
        f = open(log, "w")
        p = subprocess.Popen(cmd, cwd=path, stdin=subprocess.DEVNULL, stdout=f, stderr=subprocess.STDOUT,
                             env=dict(os.environ, STAR_TEST_SCRATCH=scratch, TMPDIR=str(SCRATCH)), start_new_session=True)
        st["tasks"][tid] = {"state": "running", "pid": p.pid, "worktree": str(path), "branch": br, "log": str(log),
                            "title": t["title"], "agent": t["owner_agent"], "started": dt.datetime.now().isoformat(timespec="minutes")}
        print(f"started {tid} (pid {p.pid}) in {path}")
    save_state(st)


def cmd_resume(args):
    """Relaunch the worker for a stopped task in its existing worktree."""
    st = load_state()
    for tid in args.ids:
        v = st["tasks"].get(tid)
        if not v or v["state"] not in ("stopped", "blocked"):
            print(f"{tid}: nothing to resume")
            continue
        SCRATCH.mkdir(parents=True, exist_ok=True)
        cmd = ["claude", "-p", f"/overnight-worker {tid}", "--permission-mode", "acceptEdits", "--allowedTools", TOOLS]
        if shutil.which("caffeinate"):
            cmd = ["caffeinate", "-i"] + cmd
        f = open(v["log"], "a")
        p = subprocess.Popen(cmd, cwd=v["worktree"], stdin=subprocess.DEVNULL, stdout=f, stderr=subprocess.STDOUT,
                             env=dict(os.environ, STAR_TEST_SCRATCH=str(SCRATCH / f"test-home-{tid}"), TMPDIR=str(SCRATCH)), start_new_session=True)
        v.update(state="running", pid=p.pid)
        v.pop("why", None)
        print(f"resumed {tid} (pid {p.pid})")
    save_state(st)


def alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def result_line(log):
    try:
        for line in reversed(Path(log).read_text(errors="replace").strip().splitlines()):
            if line.strip().startswith(RESULT):
                return line.strip()[len(RESULT):].strip()
    except OSError:
        pass
    return None


def refresh(st):
    for tid, v in st["tasks"].items():
        if v["state"] == "running" and not alive(v["pid"]):
            v["result"] = result_line(v["log"])
            v["state"] = "finished"
            v["ended"] = dt.datetime.now().isoformat(timespec="minutes")
    save_state(st)


def cmd_status(args):
    st = load_state()
    refresh(st)
    if not st["tasks"]:
        print("no tasks started")
        return
    for tid, v in st["tasks"].items():
        print(f"{tid:5} {v['state']:9} {v.get('result') or ''}")
    running = sum(1 for v in st["tasks"].values() if v["state"] == "running")
    to_merge = sum(1 for v in st["tasks"].values() if v["state"] == "finished")
    print(f"\nrunning {running}, waiting for merge {to_merge}")
    print("NEXT:", "check again in 10-20 min" if running else ("run merge" if to_merge else "run report (or start for the next round)"))


def commit_board(tid, title, status, note, summary, extra_fail=""):
    """schedule.json + blackboard.md entry, committed alone. Returns an error string or None."""
    dirty = sh(["git", "status", "--porcelain", "--", "schedule.json", "blackboard.md"]).stdout.strip()
    if dirty:
        return "schedule.json or blackboard.md has uncommitted changes in the main checkout; left untouched"
    data = load_schedule()
    for t in data["tasks"]:
        if t["task_id"] == tid:
            t["status"] = status
            t["note"] = note
            if status == "blocked":
                t["blocked_log"] = str(OUT / f"{tid}-merge.log")
    save_schedule(data)
    now = dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    entry = (f"\n## {now} run: {tid}\n- Summary: {summary}\n- Why this task: parallel orchestrator round (tools/orchestrator.py); ready, touches did not overlap.\n"
             f"- Approach: built by a worker in worktree ../wt/{tid} on branch task/{tid}, merged by the serial merge queue.\n"
             f"- Agent prompts: /overnight-worker {tid} (skill overnight-worker); worker log {OUT / (tid + '.log')}.\n"
             f"- Worked: {'rebase, full test suite and fast-forward merge passed' if status == 'done' else 'worker finished'}.\n"
             f"- Failed / did not work: {extra_fail or 'nothing'}.\n- Files and commits: see git log on branch {branch()} for commits starting with {tid}.\n"
             f"- Left to do: {'nothing for this task' if status == 'done' else 'owner or a new run: see blocked_log in schedule.json'}.\n")
    with open(ROOT / "blackboard.md", "a") as f:
        f.write(entry)
    sh([sys.executable, "tools/blackboard.py", "--archive"])
    chk = sh([sys.executable, "tools/blackboard.py", "--check"])
    if chk.returncode != 0:
        return "blackboard check failed: " + chk.stdout.strip()[:300]
    sh(["git", "add", "schedule.json", "blackboard.md"])
    c = sh(["git", "commit", "-m", f"{tid}: {status} by orchestrator [no-gdd] [no-tests]", "--", "schedule.json", "blackboard.md"])
    return None if c.returncode == 0 else "commit failed: " + c.stderr.strip()[:300]


def block(st, tid, why, log_text):
    v = st["tasks"][tid]
    v["state"], v["why"] = "blocked", why
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / f"{tid}-merge.log").write_text(why + "\n\n" + log_text)
    err = commit_board(tid, v["title"], "blocked", f"Blocked by orchestrator: {why}", f"Not merged: {why}", why)
    if err:
        v["board_error"] = err
    save_state(st)
    print(f"{tid}: BLOCKED, {why}")


def fail_name(line):
    parts = re.split(r"\s{2,}", line.strip())
    return parts[0].replace("FAIL", "").strip() or parts[1] if len(parts) > 1 else line.strip()


def resolve_balance_source(wt):
    """Auto-resolve conflicts in data/balance.json that are only additions: the one-line change note ("source":
    the base's note stays, the task's first sentence goes on top) and new key lines added at the same spot (both
    sets are kept). The result must be valid JSON without duplicate keys. Returns True if resolved."""
    p = Path(wt) / "data" / "balance.json"
    text = p.read_text()
    pre = '  "source": "'
    keyline = re.compile(r'^\s+"[^"]+": .*$')
    pat = re.compile(r"<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n", re.S)

    def fix(m):
        head, mine = m.group(1), m.group(2)
        if head.startswith(pre) and mine.startswith(pre):
            return pre + mine[len(pre):].split(" Earlier: ")[0] + " Earlier: " + head[len(pre):]
        lines = (head + mine).splitlines()
        if lines and all(keyline.match(l) for l in lines):
            tail = text[m.end():].lstrip()[:1]  # what follows the region: "}" means the last key needs no comma
            out = [l.rstrip().rstrip(",") + "," for l in lines]
            if tail in ("}", "]"):
                out[-1] = out[-1].rstrip(",")
            return "\n".join(out) + "\n"
        raise ValueError("not a pure addition")

    try:
        new = pat.sub(fix, text)
        def no_dups(pairs):
            keys = [k for k, _ in pairs]
            if len(keys) != len(set(keys)):
                raise ValueError("duplicate key")
            return dict(pairs)
        json.loads(new, object_pairs_hook=no_dups)
    except ValueError:
        return False
    p.write_text(new)
    return True


def resolve_keep_both(wt, name):
    """Conflict in a prose file (gdd.md): keep both sides, base first. Nothing is lost; the report flags it for review."""
    p = Path(wt) / name
    text = p.read_text()
    pat = re.compile(r"<<<<<<< [^\n]*\n(.*?)=======\n(.*?)>>>>>>> [^\n]*\n", re.S)
    if not pat.search(text):
        return False
    p.write_text(pat.sub(lambda m: m.group(1) + m.group(2), text))
    return True


def rebase_with_auto_resolve(wt, base):
    r = sh(["git", "rebase", base], cwd=wt)
    for _ in range(12):
        if r.returncode == 0:
            return r
        files = sh(["git", "diff", "--name-only", "--diff-filter=U"], cwd=wt).stdout.split()
        for f in [f for f in files if f.endswith(".uid")]:  # Godot-generated ids: the base's file always wins
            sh(["git", "checkout", "--ours", "--", f], cwd=wt)
            sh(["git", "add", "--", f], cwd=wt)
        files = [f for f in files if not f.endswith(".uid")]
        if "gdd.md" in files and resolve_keep_both(wt, "gdd.md"):
            sh(["git", "add", "gdd.md"], cwd=wt)
            GDD_MERGED.append(wt)
            files.remove("gdd.md")
        if files not in ([], ["data/balance.json"]):
            return r
        if files and not resolve_balance_source(wt):
            return r
        if files:
            sh(["git", "add", "data/balance.json"], cwd=wt)
        r = sh(["git", "rebase", "--continue"], cwd=wt, env={"GIT_EDITOR": "true"})
    return r


def refresh_import(wt):
    """Rebuild Godot's class and import cache in a worktree (a rebase can bring new class_name scripts that the cloned
    .godot cache does not know, which makes the test script fail to parse)."""
    SCRATCH.mkdir(parents=True, exist_ok=True)
    gd = ROOT / "tools" / "godot" / "Godot.app" / "Contents" / "MacOS" / "Godot"
    sh([str(gd), "--headless", "--path", str(wt), "--import"],
       env={"HOME": str(SCRATCH / "import-home"), "TMPDIR": str(SCRATCH)}, timeout=600)
    shutil.rmtree(SCRATCH / "import-home", ignore_errors=True)


def merge_one(st, tid):
    v = st["tasks"][tid]
    wt, br, base = v["worktree"], v["branch"], st["base_branch"]
    r = (v.get("result") or "")
    # a worker that stopped only because of tests also fails on base still goes through the gate below, which compares with the baseline
    if not (r.startswith("done") or (r.startswith("blocked") and "tests" in r.lower() and "committed" in r.lower())):
        return block(st, tid, "worker did not report done: " + str(v.get("result")), "")
    # Godot rewrites tracked .import files when it re-imports in a worktree: generated noise, never worker output
    noisy = [f for f in sh(["git", "diff", "--name-only"], cwd=wt).stdout.splitlines() if f.endswith(".import")]
    if noisy:
        sh(["git", "checkout", "--"] + noisy, cwd=wt)
    dirty = [l for l in sh(["git", "status", "--porcelain"], cwd=wt).stdout.splitlines() if l[3:].rstrip("/") != "tools/godot" and not (l.startswith("??") and (l.endswith(".uid") or l[3:].strip(chr(34)).startswith(IGNORE_UNTRACKED)))]  # our own symlink, Godot-generated uid files
    if dirty:
        return block(st, tid, "worktree has uncommitted files", "\n".join(dirty))
    r = rebase_with_auto_resolve(wt, base)
    if r.returncode != 0:
        sh(["git", "rebase", "--abort"], cwd=wt)
        return block(st, tid, f"rebase onto {base} failed", r.stdout + r.stderr)
    refresh_import(wt)
    t = run_tests(wt, tid + "-merge")
    known = {fail_name(l) for l in st.get("baseline", {}).get("fails", [])}
    new = [l for l in t["fails"] if fail_name(l) not in known]
    if t["fail"] < 0 or new or (t["fail"] > len(known) and t["fail"] > 0):
        return block(st, tid, f"tests after rebase: {t['pass']} pass, {t['fail']} fail, {len(new)} new vs baseline", "NEW:\n" + "\n".join(new) + "\n\n" + t["output"][-4000:])
    r = sh(["git", "merge", "--ff-only", br])
    if r.returncode != 0:
        return block(st, tid, "fast-forward merge refused", r.stdout + r.stderr)
    v["state"], v["tests_after"] = "merged", {"pass": t["pass"], "fail": t["fail"]}
    summary = (v["result"].split("|")[1].strip() if "|" in v["result"] else v["result"])[:300]
    err = commit_board(tid, v["title"], "done", f"Done by orchestrator: {summary}", summary)
    if err:
        v["board_error"] = err
    sh(["git", "worktree", "remove", "--force", wt])
    sh(["git", "branch", "-d", br])
    save_state(st)
    print(f"{tid}: merged ({t['pass']} pass)" + (f"; {err}" if err else ""))


def cmd_merge(args):
    if branch() in ("main", "") and not args.allow_main:
        sys.exit("refusing to merge on branch main; pass --allow-main to override")
    st = load_state()
    refresh(st)
    todo = [k for k, v in st["tasks"].items() if v["state"] == "finished"]
    if not todo:
        print("nothing to merge")
    for tid in todo:  # strictly one after the other: later ones rebase onto the earlier merges
        merge_one(st, tid)


def cmd_report(args):
    st = load_state()
    refresh(st)
    d = dt.date.today().isoformat()
    rep = ROOT / "reports"
    rep.mkdir(exist_ok=True)
    tasks = st["tasks"]
    merged = [(k, v) for k, v in tasks.items() if v["state"] == "merged"]
    blocked = [(k, v) for k, v in tasks.items() if v["state"] == "blocked"]
    other = [(k, v) for k, v in tasks.items() if v["state"] in ("running", "finished")]
    b = st.get("baseline", {})
    after = merged[-1][1]["tests_after"] if merged else None
    L = [f"# Overnight report {d}", "", f"Base branch: {st.get('base_branch', '?')}. Started {st.get('started', '?')}.", "",
         "## Tests", f"- Before (baseline at {b.get('commit', '?')}): {b.get('pass', '?')} pass, {b.get('fail', '?')} fail",
         f"- After (last merge): {after['pass']} pass, {after['fail']} fail" if after else "- After: nothing merged", ""]
    L += ["## Landed"] + ([f"- {k} {v['title']} ({v['agent']}): {v.get('result', '')}" for k, v in merged] or ["- nothing"]) + [""]
    L += ["## Blocked"] + ([f"- {k} {v['title']}: {v.get('why')}. Log: logs/orchestrator/{k}-merge.log. Worktree kept at {v['worktree']}, branch {v['branch']}." for k, v in blocked] or ["- nothing"]) + [""]
    if other:
        L += ["## Still open"] + [f"- {k}: {v['state']}" for k, v in other] + [""]
    L += ["## Notes", "- Visual review of ui/juice tasks is yours: screenshots are in logs/screenshots/<task>.png inside the task worktree while it exists.",
          "- QA and economy runs were not started."]
    path = rep / f"overnight_{d}.md"
    path.write_text("\n".join(L) + "\n")
    print("wrote", path)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name, fn in [("plan", cmd_plan), ("infer", cmd_infer), ("start", cmd_start), ("baseline", cmd_baseline), ("resume", cmd_resume), ("status", cmd_status), ("merge", cmd_merge), ("report", cmd_report)]:
        p = sub.add_parser(name)
        p.set_defaults(fn=fn)
        p.add_argument("ids", nargs="*")
        p.add_argument("--max", type=int, default=4)
        p.add_argument("--write", action="store_true")
        p.add_argument("--allow-main", action="store_true")
        p.add_argument("--skip-permissions", action="store_true")
    args = ap.parse_args()
    args.fn(args)


if __name__ == "__main__":
    main()
