#!/usr/bin/env python3
"""Economy check report: reads qa/check/out/results.jsonl (+ errors.log, features.json) and writes qa/check/out/report.md."""
import json, os, sys
from collections import defaultdict, Counter

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.environ.get("CHECK_OUT") or os.path.join(HERE, "out")
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))


def load_runs():
    runs = []
    p = os.path.join(OUT, "results.jsonl")
    if not os.path.exists(p):
        return runs
    for line in open(p):
        line = line.strip()
        if not line:
            continue
        try:
            runs.append(json.loads(line))
        except Exception:
            runs.append({"style": "?", "ceo": "?", "seed": 0, "outcome": "badjson"})
    return runs


def at(arr, i, default=None):
    if not arr:
        return default
    i = min(i, len(arr) - 1)
    return arr[i] if i >= 0 else default


def msum(d):
    return {k: sum(v.values()) for k, v in (d or {}).items()}


def ms(run, mid):
    for m in run.get("milestones", []):
        if m["id"] == mid:
            return m["cycle"]
    return None


def fmt(x):
    return "-" if x is None else str(x)


def first_event_ids():
    try:
        d = json.load(open(os.path.join(REPO, "data", "events.json")))
        evs = d.get("events", d if isinstance(d, list) else [])
        return [e["id"] for e in evs if isinstance(e, dict) and "id" in e]
    except Exception:
        return []


def main():
    runs = load_runs()
    feats = json.load(open(os.path.join(HERE, "features.json")))["features"]
    errs = []
    ep = os.path.join(OUT, "errors.log")
    if os.path.exists(ep):
        errs = [l.rstrip() for l in open(ep) if l.strip()]
    L = []
    w = L.append
    ok_runs = [r for r in runs if "cyc" in r]
    w("# Economy check report\n")
    w("Runs: %d (%d finished, %d crash/frozen).\n" % (len(runs), len(ok_runs), len(runs) - len(ok_runs)))

    # (a) outcomes
    w("## (a) Outcomes\n")
    w("| style | ceo | seed | outcome | ending | end cycle | cash at end | peak ships | worlds T1/T2/T3 | Bazaar stages | skills | wall s |")
    w("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for r in runs:
        if "cyc" not in r:
            w("| %s | %s | %s | **%s** | | | | | | | | |" % (r.get("style"), r.get("ceo"), r.get("seed"), r.get("outcome")))
            continue
        t = r.get("worlds_per_tier", {})
        w("| %s | %s | %s | %s | %s | %s | %s | %s | %s/%s/%s | %s | %d | %.0f |" % (
            r["style"], r["ceo"], r["seed"], r["outcome"], r["ending"], r["end_cycle"], r["cash_at_end"], r["peak_ships"],
            t.get("1", 0), t.get("2", 0), t.get("3", 0), r["bazaar_stage"], len(r["skills_learned"]), r["wall_s"]))
    w("")

    # (b) health
    w("## (b) Health\n")
    ic = Counter()
    for r in ok_runs:
        for i in r["issues"]:
            ic[(i["kind"], i["detail"][:120])] += 1
    for r in runs:
        if "cyc" not in r:
            ic[("run_" + r.get("outcome", "?"), "%s %s seed %s" % (r.get("style"), r.get("ceo"), r.get("seed")))] += 1
    w("**Invariant breaks, softlocks, unanswered events** (kind, detail, runs):\n")
    if not ic:
        w("none")
    for (k, d), n in ic.most_common():
        w("- `%s` x%d: %s" % (k, n, d))
    w("")
    script = [e for e in errs if "SCRIPT ERROR" in e or ": ERROR" in e]
    warns = [e for e in errs if e not in script]
    w("**Godot script errors** (%d):\n" % len(script))
    for e in sorted(set(script))[:25]:
        w("- " + e[:230])
    w("\n**Game warnings** (%d):\n" % len(warns))
    for e in sorted(set(warns))[:15]:
        w("- " + e[:230])
    w("\n**Refused actions grouped by reason** (feature: reason, count):\n")
    refused = Counter()
    for r in ok_runs:
        for fid, e in r["features"].items():
            for reason, n in e["reasons"].items():
                refused[(fid, reason)] += n
    for (fid, reason), n in refused.most_common(40):
        w("- `%s` x%d: %s" % (fid, n, reason))
    w("")

    # (c) coverage
    w("## (c) Feature coverage\n")
    styles = sorted(set(r["style"] for r in ok_runs))
    w("| feature | entry | " + " | ".join(styles) + " |")
    w("|---|---|" + "---|" * len(styles))
    done = {}
    tried = {}
    for f in feats:
        fid = f["id"]
        row = []
        for s in styles:
            n = sum(r["features"].get(fid, {}).get("ok", 0) for r in ok_runs if r["style"] == s)
            t = sum(r["features"].get(fid, {}).get("tried", 0) for r in ok_runs if r["style"] == s)
            row.append("%d" % n if n else ("x%d" % t if t else "."))
            done[fid] = done.get(fid, 0) + n
            tried[fid] = tried.get(fid, 0) + t
        w("| %s | %s | %s |" % (fid, f["entry"][:40], " | ".join(row)))
    w("\n(n = successes, xN = tried N times and always refused, . = never tried)\n")
    none_e = [f for f in feats if f["entry"].strip().lower().startswith("none")]
    missed = [f for f in feats if done.get(f["id"], 0) == 0]
    w("**No run managed %d of %d features:**\n" % (len(missed), len(feats)))
    w("- entry none: " + (", ".join(f["id"] for f in none_e) or "(none listed)"))
    always = [f for f in missed if tried.get(f["id"], 0) > 0 and f not in none_e]
    w("- tried and always refused:")
    for f in always:
        rs = Counter()
        for r in ok_runs:
            for k, n in r["features"].get(f["id"], {}).get("reasons", {}).items():
                rs[k] += n
        w("  - `%s`: %s" % (f["id"], "; ".join("%s (x%d)" % (k[:80], n) for k, n in rs.most_common(2))))
    never = [f for f in missed if tried.get(f["id"], 0) == 0 and f not in none_e]
    w("- never tried: " + (", ".join(f["id"] for f in never) or "-"))
    w("")

    # (d) economy
    w("## (d) Economy and pacing per style\n")
    for key in sorted(set((r["style"], r["ceo"]) for r in ok_runs)):
        rs = [r for r in ok_runs if (r["style"], r["ceo"]) == key]
        w("### %s / %s (%d runs)\n" % (key[0], key[1], len(rs)))
        w("| seed | cash c5 | c10 | c20 | c30 | end | first ship | 2nd ship | tier2 | permit | workshop | Bazaar | stage1 | stage2 | stage3 | stage4 | win | idle cycles | longest idle | ship idle avg | stalled avg | blocked avg |")
        w("|" + "---|" * 22)
        for r in rs:
            c = r["cyc"]
            n = max(1, len(c["cash"]))
            w("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %d | %d | %.1f | %.1f | %.1f |" % (
                r["seed"], at(c["cash"], 4), at(c["cash"], 9), at(c["cash"], 19), at(c["cash"], 29), at(c["cash"], 10 ** 6),
                fmt(ms(r, "first_ship")), fmt(ms(r, "second_ship")), fmt(ms(r, "first_tier2")), fmt(ms(r, "first_permit")),
                fmt(ms(r, "first_workshop")), fmt(ms(r, "bazaar_founded")), fmt(ms(r, "bazaar_stage_1")), fmt(ms(r, "bazaar_stage_2")),
                fmt(ms(r, "bazaar_stage_3")), fmt(ms(r, "bazaar_stage_4")), fmt(ms(r, "end_win")),
                r["idle_cycles"], r["idle_streak_max"], sum(c["idle_ships"]) / n, sum(c["routes_stalled"]) / n, sum(c["routes_blocked"]) / n))
        r0 = rs[0]
        inc = msum(r0["cyc"]["income"])
        sp = msum(r0["cyc"]["spend"])
        w("\nSeed %s income by source: %s" % (r0["seed"], ", ".join("%s %d" % kv for kv in sorted(inc.items(), key=lambda x: -x[1]))))
        w("\nSeed %s spend by sink: %s" % (r0["seed"], ", ".join("%s %d" % kv for kv in sorted(sp.items(), key=lambda x: -x[1]))))
        w("\nGoods sold (units): %s" % ", ".join("%s %d" % kv for kv in sorted(r0["goods_sold"].items(), key=lambda x: -x[1])))
        w("\nStyle notes (seed %s, first 12): %s\n" % (r0["seed"], " | ".join(r0.get("style_notes", [])[:12])))

    # (e) worth a look
    w("## (e) Worth a look\n")
    look = []
    for r in ok_runs:
        tag = "%s/%s/seed %s" % (r["style"], r["ceo"], r["seed"])
        if r["outcome"] == "LOSS":
            look.append("%s went bankrupt at cycle %s (check it was intended)." % (tag, r["end_cycle"]))
        c = r["cyc"]
        if c["cash"]:
            end = c["cash"][-1]
            price = 1000
            if end > 40 * price and r["peak_ships"] >= 15 and r["idle_cycles"] > len(c["cash"]) / 3:
                look.append("%s: cash only grows (%d at the end, ship cap hit, %d idle cycles): nothing left to buy." % (tag, end, r["idle_cycles"]))
        if r["outcome"] == "WIN":
            cyc = r["end_cycle"]
            if cyc < 35 or cyc > 75:
                look.append("%s: won at cycle %d, outside the expected 35 to 75 window." % (tag, cyc))
        if r["outcome"] == "SOFT" and r["bazaar_stage"] == 0:
            look.append("%s: term ended with no Bazaar stage done (Bazaar founded: %s)." % (tag, r["bazaar_founded"]))
        if not r["saveload"].get("ok") and r["saveload"].get("done"):
            look.append("%s: save/load round trip changed state: %s" % (tag, "; ".join(r["saveload"].get("diff", []))[:200]))
        if r["idle_streak_max"] >= 10:
            look.append("%s: %d idle-decision cycles in a row." % (tag, r["idle_streak_max"]))
    for f in always:
        look.append("feature `%s` was refused in every run it was tried in." % f["id"])
    for f in none_e:
        look.append("feature `%s` has no player entry point." % f["id"])
    sold = set()
    bought = set()
    for r in ok_runs:
        sold |= set(r["goods_sold"])
        bought |= set(r["goods_bought"])
    try:
        gj = json.load(open(os.path.join(REPO, "data", "goods.json")))["goods"]
        allg = [g["id"] for g in gj]
        nt = [g for g in allg if g not in sold and g not in bought]
        if nt:
            look.append("goods never traded by any run: " + ", ".join(nt))
    except Exception:
        pass
    try:
        sk = json.load(open(os.path.join(REPO, "data", "skills.json")))["nodes"]
        learned = set()
        for r in ok_runs:
            learned |= set(r["skills_learned"])
        nl = [n["id"] for n in sk if n.get("kind") != "tech" and n["id"] not in learned]
        if nl:
            look.append("skills never learned by any run (%d): %s" % (len(nl), ", ".join(nl)))
    except Exception:
        pass
    seen = set()
    for r in ok_runs:
        seen |= set(r["events_seen"])
    evs = first_event_ids()
    ne = [e for e in evs if e not in seen]
    if ne:
        look.append("events never seen (%d): %s" % (len(ne), ", ".join(ne)))
    endings = set(r["ending"] for r in ok_runs if r["ending"])
    try:
        ed = json.load(open(os.path.join(REPO, "data", "endings.json")))["endings"]
        allend = [e["id"] for e in ed] + ["END_UNFINISHED", "END_BANKRUPT"]
        ne2 = [e for e in allend if e not in endings]
        look.append("endings never reached (%d of %d): %s" % (len(ne2), len(allend), ", ".join(ne2)))
    except Exception:
        pass
    for x in look:
        w("- " + x)
    open(os.path.join(OUT, "report.md"), "w").write("\n".join(L) + "\n")


if __name__ == "__main__":
    main()
