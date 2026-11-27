#!/usr/bin/env python3
"""API-equivalent cost of the Star Bazaar project, from Claude Code session logs.

Reads every Claude Code session log (JSONL) of this project and its orchestrator
worktrees, takes the `usage` block of each model call, and prices it at Anthropic
API list rates (RATES below). Writes a JSON summary and a CSV of every priced call.

  python3 tools/cost_report.py                       # writes reports/cost_<until>.json and .csv
  python3 tools/cost_report.py --until 2026-11-25    # last day included (UTC), default 2026-11-25
  python3 tools/cost_report.py --logs ~/.claude/projects

What counts as one call: one assistant message id. Claude Code writes a streamed
message as several log lines that repeat the same id and usage; each id is priced
once. Lines with model "<synthetic>" (local placeholders, no API call) are skipped.

Pipeline part, from where the log lives:
  main session   ~/.claude/projects/<project>/<session>.jsonl   (the interactive session)
  role agent     ~/.claude/projects/<project>/<session>/subagents/agent-*.jsonl
                 (agent type read from the matching agent-*.meta.json)
  orchestrator   ~/.claude/projects/<...>-wt-T<id>/**.jsonl     (headless worker per task,
                 started by tools/orchestrator.py, and any agents it started)

Log retention: Claude Code deletes session logs older than 30 days (setting
cleanupPeriodDays). The first run of this count, on 2026-11-25, still saw the
2026-10-24..27 sessions and gave $841.07; on 2026-11-27 the oldest log left is
from 2026-10-28. The committed CSV keeps every priced call, so the figures no longer
depend on the logs still being there.

Translation before/after (2026-11-09 rule: translation moved from Sonnet story-designer
agents to Haiku agents): the same job, the four market event chains into Russian,
is matched by the agent descriptions in TRANSLATION_RUNS and priced the same way.
"""
import argparse
import csv
import glob
import json
import os
import re
from collections import defaultdict
from pathlib import Path

# USD per million tokens. Source: Anthropic model pricing (claude-api reference,
# cached 2026-11-03). Cache writes: 5-minute TTL = 1.25x input, 1-hour TTL = 2x input.
RATES = {
    #                    input  output  cache_read  write_5m  write_1h
    "claude-fable-5-2":  (8.00, 40.00, 0.20, 10.00, 16.00),
    "claude-fable-5-1":  (10.00, 50.00, 0.25, 12.50, 20.00),
    "claude-opus-5-5":   (4.00, 20.00, 0.20, 5.00, 8.00),
    "claude-sonnet-5-5": (2.00, 10.00, 0.10, 2.50, 4.00),
    "claude-haiku-5-5":  (0.10, 0.50, 0.01, 0.125, 0.20),
}
PROJECT_DIRS = ("-Volumes-Work-Gamedev-Projects-AgentCourse-star-bazaar",
                "-Volumes-Work-Gamedev-Projects-StarBazaar",  # second checkout of the same repo, 2026-11-14..15
                "-Volumes-Work-Gamedev-Projects-AgentCourse-wt-T*")
SINCE = "2026-10-24"

# Agent runs of the translation before/after comparison (meta.json "description", case-insensitive regex).
TRANSLATION_RUNS = {
    "before_sonnet": r"translat.*(military|luxury|minerals|biotech)",
    "after_haiku": r"translat.*(military|luxury|minerals|biotech)",
}


def price(model, u):
    r = RATES[model]
    cc = u.get("cache_creation") or {}
    w1h = cc.get("ephemeral_1h_input_tokens", 0) or 0
    w5m = cc.get("ephemeral_5m_input_tokens")
    if w5m is None:  # older log lines: no split, all writes at the 5-minute rate
        w5m = (u.get("cache_creation_input_tokens", 0) or 0) - w1h
    parts = {
        "input": (u.get("input_tokens", 0) or 0) * r[0],
        "output": (u.get("output_tokens", 0) or 0) * r[1],
        "cache_read": (u.get("cache_read_input_tokens", 0) or 0) * r[2],
        "cache_write": w5m * r[3] + w1h * r[4],
    }
    return {k: v / 1e6 for k, v in parts.items()}


def classify(path, root):
    rel = Path(path).relative_to(root)
    proj = rel.parts[0]
    if "-wt-T" in proj:
        return "orchestrator", "worker:" + proj.split("-wt-")[1], ""
    if "subagents" in rel.parts:
        meta = Path(path).with_suffix(".meta.json")
        m = json.loads(meta.read_text()) if meta.exists() else {}
        return "role_agent", m.get("agentType", "unknown"), m.get("description", "")
    return "main_session", "main", ""


def collect(root, until):
    seen, rows = set(), []
    files = sorted(f for d in PROJECT_DIRS for f in glob.glob(str(root / d / "**" / "*.jsonl"), recursive=True))
    for f in files:
        part, agent, desc = classify(f, root)
        for line in open(f, encoding="utf-8", errors="replace"):
            if '"usage"' not in line:
                continue
            try:
                d = json.loads(line)
            except ValueError:
                continue
            msg = d.get("message") or {}
            model, u, mid = msg.get("model"), msg.get("usage"), msg.get("id")
            if not u or model not in RATES or not mid:
                continue
            day = (d.get("timestamp") or "")[:10]
            if not (SINCE <= day <= until) or mid in seen:
                continue
            seen.add(mid)
            p = price(model, u)
            rows.append({
                "timestamp": d.get("timestamp"), "day": day, "part": part, "agent": agent, "description": desc,
                "model": model, "session_file": str(Path(f).relative_to(root)), "message_id": mid,
                "input_tokens": u.get("input_tokens", 0) or 0, "output_tokens": u.get("output_tokens", 0) or 0,
                "cache_read_tokens": u.get("cache_read_input_tokens", 0) or 0,
                "cache_write_tokens": u.get("cache_creation_input_tokens", 0) or 0,
                **{f"usd_{k}": round(v, 6) for k, v in p.items()}, "usd": round(sum(p.values()), 6),
            })
    return rows, len(files)


def group(rows, key):
    out = defaultdict(lambda: {"calls": 0, "usd": 0.0, "runs": set()})
    for r in rows:
        g = out[r[key]]
        g["calls"] += 1
        g["usd"] += r["usd"]
        g["runs"].add(r["session_file"])
    return {k: {"calls": v["calls"], "runs": len(v["runs"]), "usd": round(v["usd"], 2)}
            for k, v in sorted(out.items(), key=lambda kv: -kv[1]["usd"])}


def translation(rows):
    """Per agent run (session file) of the translation job: model, output tokens, cost."""
    out = {}
    for side, pat in TRANSLATION_RUNS.items():
        want = "claude-sonnet-5-5" if side == "before_sonnet" else "claude-haiku-5-5"
        runs = defaultdict(lambda: {"calls": 0, "output_tokens": 0, "usd": 0.0})
        for r in rows:
            if r["part"] == "role_agent" and r["model"] == want and re.search(pat, r["description"], re.I):
                x = runs[r["session_file"]]
                x.update(description=r["description"], agent=r["agent"], model=r["model"], day=r["day"])
                x["calls"] += 1
                x["output_tokens"] += r["output_tokens"]
                x["usd"] += r["usd"]
        runs = {k: {**v, "usd": round(v["usd"], 4)} for k, v in runs.items()}
        out[side] = {"runs": runs, "output_tokens": sum(v["output_tokens"] for v in runs.values()),
                     "usd": round(sum(v["usd"] for v in runs.values()), 3)}
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--logs", default=os.path.expanduser("~/.claude/projects"))
    ap.add_argument("--until", default="2026-11-25")
    ap.add_argument("--out", default="reports")
    a = ap.parse_args()
    rows, nfiles = collect(Path(a.logs), a.until)
    total = sum(r["usd"] for r in rows)
    tok = {k: round(sum(r[f"usd_{k}"] for r in rows), 2) for k in ("input", "output", "cache_read", "cache_write")}
    summary = {
        "generated_by": "python3 tools/cost_report.py --until " + a.until,
        "source": "Claude Code session logs (~/.claude/projects), " + ", ".join(PROJECT_DIRS),
        "period": [SINCE, a.until], "log_files": nfiles, "model_calls": len(rows),
        "first_day_with_logs": min(r["day"] for r in rows),
        "note": "Claude Code deletes session logs after 30 days. The 2026-11-25 run of this count still had the "
                "2026-10-24..27 sessions and gave $841.07; this run can only see logs from first_day_with_logs on.",
        "rates_usd_per_mtok": {m: dict(zip(("input", "output", "cache_read", "cache_write_5m", "cache_write_1h"), r)) for m, r in RATES.items()},
        "total_usd": round(total, 2),
        "by_model": group(rows, "model"),
        "by_token_kind_usd": tok,
        "by_pipeline_part": group(rows, "part"),
        "by_role_agent": group([r for r in rows if r["part"] == "role_agent"], "agent"),
        "orchestrator_tasks": len({r["agent"] for r in rows if r["part"] == "orchestrator"}),
        "translation_before_after": translation(rows),
    }
    out = Path(a.out)
    out.mkdir(exist_ok=True)
    jp, cp = out / f"cost_{a.until}.json", out / f"cost_{a.until}.csv"
    jp.write_text(json.dumps(summary, indent=2) + "\n")
    with open(cp, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(sorted(rows, key=lambda r: r["timestamp"] or ""))
    print(f"{len(rows)} calls from {nfiles} log files, total ${total:,.2f}")
    for k in ("by_model", "by_pipeline_part"):
        print(k, {m: v["usd"] for m, v in summary[k].items()})
    print("by_token_kind", tok)
    t = summary["translation_before_after"]
    print("translation", {s: (t[s]["usd"], t[s]["output_tokens"], len(t[s]["runs"])) for s in t})
    print("wrote", jp, cp)


if __name__ == "__main__":
    main()
