#!/usr/bin/env python3
"""Headless metrics report for the Star Bazaar QA batch (owned by qa-analyst).

Reads one or more results_<TAG>.jsonl files (one RESULT json per line, written by run_batch.sh)
and writes a JSON report and a short markdown report. Standard library only.

Usage:
  metrics.py RESULTS.jsonl [MORE.jsonl ...] --json OUT.json --md OUT.md

Definitions:
  base run      no --skip-skill, no --inject, no --force-goal. The default game, used for density,
                dominant strategy, win share and spread. Failed runs (crash, frozen) carry no config
                fields, so they count as base runs.
  clock group   analysis is done per --clock value, so timer and fast runs are never mixed.
  completed     outcome win or loss. failed = any other outcome (softlock, frozen, crash).
  matched       pairs of runs with the same strategy, seed, clock and choice policy.
"""
import argparse
import json
import os
import statistics
import sys
from collections import defaultdict

ORDER = ["decent", "sloppy", "always_expand", "never_expand"]


def ordered(names):
    known = [s for s in ORDER if s in names]
    return known + sorted(n for n in names if n not in ORDER)


def load(paths, warnings):
    recs = []
    for p in paths:
        with open(p) as f:
            for lineno, line in enumerate(f, 1):
                line = line.strip()
                if not line:
                    continue
                try:
                    r = json.loads(line)
                except json.JSONDecodeError:
                    warnings.append("%s:%d is not valid JSON, skipped" % (os.path.basename(p), lineno))
                    continue
                if not isinstance(r, dict):
                    continue
                r["_src"] = os.path.basename(p)
                recs.append(r)
    return recs


def config_key(r):
    return (r.get("clock"), r.get("choice_policy"), r.get("force_goal_cycle"),
            r.get("inject"), tuple(r.get("skip_skills") or []))


def is_base(r):
    return (not (r.get("skip_skills") or []) and not r.get("inject")
            and r.get("force_goal_cycle", -1) in (-1, None))


def completed(r):
    return r.get("outcome") in ("win", "loss")


def has_cash(r):
    return isinstance(r.get("final_cash"), (int, float))


def clock_of(r):
    return r.get("clock") or "unknown"


def mean(xs):
    return sum(xs) / len(xs) if xs else None


def safe_div(a, b):
    return a / b if b else None


def stdev(xs):
    return statistics.stdev(xs) if len(xs) >= 2 else None


def dedupe(recs, warnings):
    seen = set()
    out = []
    for r in recs:
        key = (r.get("strategy"), r.get("seed")) + config_key(r)
        if key in seen:
            warnings.append("duplicate run dropped: strategy=%s seed=%s (%s)" % (
                r.get("strategy"), r.get("seed"), r.get("_src")))
            continue
        seen.add(key)
        out.append(r)
    return out


def win_rate(rs):
    return safe_div(sum(1 for r in rs if r.get("outcome") == "win"), len(rs))


def density(base, strategies):
    out = {}
    for s in strategies:
        rs = [r for r in base if r["strategy"] == s]
        lists = [r["decisions_by_cycle"] for r in rs if isinstance(r.get("decisions_by_cycle"), list)]
        counts = [int(n) for L in lists for _, n in L]
        by_kind = defaultdict(int)
        for r in rs:
            for k, v in (r.get("decisions_by_kind") or {}).items():
                by_kind[k] += int(v)
        out[s] = {
            "runs": len(rs),
            "runs_with_decision_data": len(lists),
            "cycles": len(counts),
            "decisions": sum(counts),
            "mean_decisions_per_cycle": safe_div(sum(counts), len(counts)),
            "zero_decision_cycle_share": safe_div(sum(1 for n in counts if n == 0), len(counts)),
            "mean_decisions_per_run": safe_div(sum(counts), len(lists)),
            "decisions_by_kind": dict(sorted(by_kind.items())),
        }
    return out


def dominant(base, strategies):
    by_seed = defaultdict(dict)
    for r in base:
        if has_cash(r):
            by_seed[r["seed"]].setdefault(r["strategy"], r["final_cash"])
    seeds = [sd for sd, d in by_seed.items() if set(strategies) <= set(d)]
    credit = {s: 0.0 for s in strategies}
    sole = {s: 0 for s in strategies}
    ties = 0
    for sd in seeds:
        best = max(by_seed[sd][s] for s in strategies)
        tied = [s for s in strategies if by_seed[sd][s] == best]
        if len(tied) > 1:
            ties += 1
        else:
            sole[tied[0]] += 1
        for s in tied:
            credit[s] += 1.0 / len(tied)
    share = {s: safe_div(credit[s], len(seeds)) for s in strategies}
    win = {}
    for s in strategies:
        rs = [r for r in base if r["strategy"] == s]
        wins = sum(1 for r in rs if r.get("outcome") == "win")
        win[s] = {"wins": wins, "runs": len(rs), "win_share": safe_div(wins, len(rs))}
    return {
        "seeds_in_all_strategies": sorted(seeds),
        "seed_count": len(seeds),
        "ties": ties,
        "top_cash_share": share,
        "sole_top_seeds": sole,
        "win_share": win,
    }


def spread(base, strategies):
    out = {}
    for s in strategies:
        rs = [r for r in base if r["strategy"] == s]
        cash = [r["final_cash"] for r in rs if has_cash(r)]
        out[s] = {
            "runs": len(rs),
            "cash_runs": len(cash),
            "mean_final_cash": mean(cash),
            "stdev_final_cash": stdev(cash),
            "min_final_cash": min(cash) if cash else None,
            "max_final_cash": max(cash) if cash else None,
            "range_final_cash": (max(cash) - min(cash)) if cash else None,
            "distinct_win_cycles": sorted({r.get("cycle_reached") for r in rs if r.get("outcome") == "win"}),
            "distinct_loss_cycles": sorted({r.get("cycle_reached") for r in rs if r.get("outcome") == "loss"}),
            "end_cycle_not_ok": sum(1 for r in rs if r.get("end_cycle_ok") is False),
            "failed": sum(1 for r in rs if not completed(r)),
        }
    return out


def paired(a_runs, b_runs):
    """Match a-runs to b-runs by (strategy, seed, choice). Returns the list of (a, b) pairs."""
    index = {(r["strategy"], r["seed"], r.get("choice_policy")): r for r in b_runs}
    pairs = []
    for a in a_runs:
        b = index.get((a["strategy"], a["seed"], a.get("choice_policy")))
        if b is not None:
            pairs.append((a, b))
    return pairs


def skill_impact(recs, clock):
    dec = [r for r in recs if r["strategy"] == "decent" and clock_of(r) == clock
           and not r.get("inject") and r.get("force_goal_cycle", -1) in (-1, None) and has_cash(r)]
    learn = [r for r in dec if not (r.get("skip_skills") or [])]
    skip = [r for r in dec if r.get("skip_skills")]
    res = {
        "learn_runs": len(learn),
        "skip_runs": len(skip),
        "skipped_skill_ids": sorted({sid for r in skip for sid in r["skip_skills"]}),
    }
    if not skip:
        res["note"] = "No decent --skip-skill runs in the input; skill impact not measured."
        return res
    res["mean_skills_learned_learn_runs"] = mean([len(r.get("skills_learned") or []) for r in learn])
    res["learn_mean_final_cash"] = mean([r["final_cash"] for r in learn])
    res["skip_mean_final_cash"] = mean([r["final_cash"] for r in skip])
    res["learn_win_rate"] = win_rate(learn)
    res["skip_win_rate"] = win_rate(skip)
    pairs = paired(learn, skip)
    res["matched_pairs"] = len(pairs)
    if pairs:
        res["matched_cash_diff_learn_minus_skip"] = mean([a["final_cash"] - b["final_cash"] for a, b in pairs])
        res["matched_win_rate_diff_learn_minus_skip"] = mean(
            [(a.get("outcome") == "win") - (b.get("outcome") == "win") for a, b in pairs])
    return res


def event_impact(all_recs, base, clock):
    with_field = [r for r in all_recs if clock_of(r) == clock and "events_resolved" in r]
    events_total = sum(int(r["events_resolved"]) for r in with_field)
    res = {
        "runs_with_event_field": len(with_field),
        "events_resolved_total": events_total,
        "runs_with_events": sum(1 for r in with_field if int(r["events_resolved"]) > 0),
    }
    if not with_field:
        res["note"] = "No run in the input reports events_resolved (older results)."
        return res
    if events_total == 0:
        res["note"] = ("Event coverage zero: %d runs, 0 events resolved. _resolve_events() is a stub "
                       "in this build, so no event comparison is possible. Result: no event effect measured."
                       % len(with_field))
        return res
    on = [r for r in base if clock_of(r) == clock and int(r.get("events_resolved", 0)) > 0 and has_cash(r)]
    off = [r for r in base if clock_of(r) == clock and "events_resolved" in r
           and int(r["events_resolved"]) == 0 and has_cash(r)]
    res["events_on_runs"] = len(on)
    res["events_off_runs"] = len(off)
    pairs = paired(on, off)
    res["matched_pairs"] = len(pairs)
    if pairs:
        res["matched_cash_diff_on_minus_off"] = mean([a["final_cash"] - b["final_cash"] for a, b in pairs])
        res["matched_win_rate_diff_on_minus_off"] = mean(
            [(a.get("outcome") == "win") - (b.get("outcome") == "win") for a, b in pairs])
    return res


def _decent_clock(recs, clock):
    return [r for r in recs if r["strategy"] == "decent" and clock_of(r) == clock
            and not r.get("inject") and r.get("force_goal_cycle", -1) in (-1, None) and has_cash(r)]


def skill_log_summary(recs, clock):
    """Per skill id, over decent learn runs (no skip): how often learned, at what mean cycle, for what mean points.
    Reads the skill_log field added to the RESULT line; older runs without it are counted as missing."""
    learn = [r for r in _decent_clock(recs, clock) if not (r.get("skip_skills") or [])]
    with_log = [r for r in learn if "skill_log" in r]
    res = {"learn_runs": len(learn), "runs_with_skill_log": len(with_log), "skills": {}}
    for sid in ("A1", "A2", "A3", "A4", "A5", "B1", "B2", "B3", "B4", "C1", "C2", "C3", "C4"):
        hits = [(e[0], e[2]) for r in with_log for e in r["skill_log"] if e[1] == sid]
        if not with_log:
            break
        res["skills"][sid] = {
            "learned_in_runs": len(hits),
            "learn_share": len(hits) / len(with_log),
            "mean_cycle": mean([c for c, _ in hits]) if hits else None,
            "mean_points_spent": mean([p for _, p in hits]) if hits else None,
        }
    return res


def per_skill_impact(recs, clock):
    """Each single-skill skip (decent) matched by (seed, choice) to the all-skills decent run.
    Effect = all-skills minus skip-X, so a positive number means the skill helps."""
    dec = _decent_clock(recs, clock)
    learn = [r for r in dec if not (r.get("skip_skills") or [])]
    out = {}
    for sid in sorted({x for r in dec for x in (r.get("skip_skills") or [])}):
        skip = [r for r in dec if r.get("skip_skills") == [sid]]
        pairs = paired(learn, skip)
        entry = {"skip_runs": len(skip), "matched_pairs": len(pairs)}
        if pairs:
            entry["effect_cash_learn_minus_skip"] = mean([a["final_cash"] - b["final_cash"] for a, b in pairs])
            entry["effect_win_rate_learn_minus_skip"] = mean(
                [(a.get("outcome") == "win") - (b.get("outcome") == "win") for a, b in pairs])
            entry["learn_mean_cash_matched"] = mean([a["final_cash"] for a, _ in pairs])
            entry["skip_mean_cash_matched"] = mean([b["final_cash"] for _, b in pairs])
        out[sid] = entry
    return out


def analyze_clock(all_recs, base_clock, clock):
    base = [r for r in base_clock if clock_of(r) == clock]
    strategies = ordered({r["strategy"] for r in base})
    return {
        "base_runs": len(base),
        "strategies": strategies,
        "a_decision_density": density(base, strategies),
        "b_dominant_strategy": dominant(base, strategies) if strategies else {},
        "c_outcome_spread": spread(base, strategies),
        "d_skill_impact": skill_impact(all_recs, clock),
        "d2_skill_log": skill_log_summary(all_recs, clock),
        "d3_per_skill_impact": per_skill_impact(all_recs, clock),
        "e_event_impact": event_impact(all_recs, base, clock),
    }


def fmt(x, digits=1):
    if x is None:
        return "n/a"
    if isinstance(x, float):
        return f"{x:,.{digits}f}"
    if isinstance(x, int):
        return f"{x:,}"
    return str(x)


def pct(x):
    return "n/a" if x is None else f"{100 * x:.0f}%"


def write_md(report, path):
    L = []
    L.append("# QA metrics report")
    L.append("")
    L.append("Inputs: " + ", ".join(report["inputs"]))
    L.append("")
    L.append("Runs: %d total, %d default-config (base), %d failed (crash, frozen or softlock)." % (
        report["runs"], report["base_runs_total"], report["failed_total"]))
    if report["warnings"]:
        L.append("")
        L.append("Warnings:")
        for w in report["warnings"]:
            L.append("- " + w)
    for clock, a in report["clocks"].items():
        L.append("")
        L.append("## Clock: %s (base runs %d)" % (clock, a["base_runs"]))
        strategies = a["strategies"]
        if not strategies:
            L.append("")
            L.append("No base runs for this clock.")
            continue
        L.append("")
        L.append("### a. Decision density")
        L.append("")
        L.append("| strategy | runs | cycles | decisions | mean per cycle | zero-decision cycles | mean per run |")
        L.append("|---|---|---|---|---|---|---|")
        for s in strategies:
            d = a["a_decision_density"][s]
            L.append("| %s | %d | %d | %d | %s | %s | %s |" % (
                s, d["runs"], d["cycles"], d["decisions"], fmt(d["mean_decisions_per_cycle"], 2),
                pct(d["zero_decision_cycle_share"]), fmt(d["mean_decisions_per_run"], 1)))
        L.append("")
        L.append("Decisions by kind: " + "; ".join(
            "%s: %s" % (s, ", ".join("%s %d" % kv for kv in a["a_decision_density"][s]["decisions_by_kind"].items())
                        or "none")
            for s in strategies))
        b = a["b_dominant_strategy"]
        L.append("")
        L.append("### b. Dominant strategy and win share")
        L.append("")
        L.append("Seeds present in all strategies: %d (ties: %d)." % (b["seed_count"], b["ties"]))
        L.append("")
        L.append("| strategy | top-cash share of seeds | sole top seeds | wins | runs | win share |")
        L.append("|---|---|---|---|---|---|")
        for s in strategies:
            w = b["win_share"][s]
            L.append("| %s | %s | %d | %d | %d | %s |" % (
                s, pct(b["top_cash_share"][s]), b["sole_top_seeds"][s], w["wins"], w["runs"], pct(w["win_share"])))
        c = a["c_outcome_spread"]
        L.append("")
        L.append("### c. Outcome spread")
        L.append("")
        L.append("| strategy | cash runs | mean cash | stdev | min | max | range | win cycles | loss cycles | end cycle not ok | failed |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|")
        for s in strategies:
            x = c[s]
            L.append("| %s | %d | %s | %s | %s | %s | %s | %s | %s | %d | %d |" % (
                s, x["cash_runs"], fmt(x["mean_final_cash"], 0), fmt(x["stdev_final_cash"], 0),
                fmt(x["min_final_cash"], 0), fmt(x["max_final_cash"], 0), fmt(x["range_final_cash"], 0),
                ", ".join(str(v) for v in x["distinct_win_cycles"]) or "none",
                ", ".join(str(v) for v in x["distinct_loss_cycles"]) or "none",
                x["end_cycle_not_ok"], x["failed"]))
        d = a["d_skill_impact"]
        L.append("")
        L.append("### d. Skill impact (decent)")
        L.append("")
        if "note" in d and d.get("skip_runs", 0) == 0:
            L.append(d["note"])
        else:
            L.append("Learn runs %d, skip runs %d (skipped: %s). Matched pairs: %d." % (
                d["learn_runs"], d["skip_runs"], ", ".join(d["skipped_skill_ids"]) or "none", d.get("matched_pairs", 0)))
            L.append("")
            L.append("| | mean final cash | win rate |")
            L.append("|---|---|---|")
            L.append("| learn | %s | %s |" % (fmt(d.get("learn_mean_final_cash"), 0), pct(d.get("learn_win_rate"))))
            L.append("| skip | %s | %s |" % (fmt(d.get("skip_mean_final_cash"), 0), pct(d.get("skip_win_rate"))))
            if d.get("matched_pairs"):
                L.append("")
                L.append("Matched by seed: cash diff (learn minus skip) %s; win rate diff %s." % (
                    fmt(d.get("matched_cash_diff_learn_minus_skip"), 0),
                    pct(d.get("matched_win_rate_diff_learn_minus_skip"))))
        L.append("")
        L.append("### d2. Skill log (decent learn runs)")
        L.append("")
        sl = a.get("d2_skill_log", {})
        if not sl.get("runs_with_skill_log"):
            L.append("No run in the input carries a skill_log field (older results).")
        else:
            L.append("Runs with skill_log: %d of %d learn runs." % (sl["runs_with_skill_log"], sl["learn_runs"]))
            L.append("")
            L.append("| skill | learned in | mean cycle | mean points |")
            L.append("|---|---|---|---|")
            for sid, v in sl["skills"].items():
                L.append("| %s | %s | %s | %s |" % (sid, pct(v["learn_share"]), fmt(v["mean_cycle"]), fmt(v["mean_points_spent"])))
        L.append("")
        L.append("### d3. Per-skill impact (single skip vs all skills, matched by seed and choice)")
        L.append("")
        pi = a.get("d3_per_skill_impact", {})
        if not pi:
            L.append("No single-skill skip runs in the input.")
        else:
            L.append("| skill | skip runs | matched | cash effect (learn minus skip) | win-rate effect |")
            L.append("|---|---|---|---|---|")
            for sid, v in pi.items():
                L.append("| %s | %d | %d | %s | %s |" % (sid, v["skip_runs"], v["matched_pairs"],
                    fmt(v.get("effect_cash_learn_minus_skip"), 0), pct(v.get("effect_win_rate_learn_minus_skip"))))
        e = a["e_event_impact"]
        L.append("")
        L.append("### e. Event impact")
        L.append("")
        if "note" in e:
            L.append(e["note"])
        else:
            L.append("Events on: %d runs, off: %d runs. Matched pairs: %d. Cash diff (on minus off) %s; win rate diff %s." % (
                e.get("events_on_runs", 0), e.get("events_off_runs", 0), e.get("matched_pairs", 0),
                fmt(e.get("matched_cash_diff_on_minus_off"), 0), pct(e.get("matched_win_rate_diff_on_minus_off"))))
    with open(path, "w") as f:
        f.write("\n".join(L) + "\n")


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("inputs", nargs="+", help="results_<TAG>.jsonl files")
    ap.add_argument("--json", required=True, help="output JSON path")
    ap.add_argument("--md", required=True, help="output markdown path")
    args = ap.parse_args(argv)
    warnings: list = []
    recs = dedupe(load(args.inputs, warnings), warnings)
    base_all = [r for r in recs if is_base(r)]
    clocks = sorted({clock_of(r) for r in recs})
    clock_reports = {}
    for clock in clocks:
        clock_reports[clock] = analyze_clock(recs, base_all, clock)
    failed = sum(1 for r in recs if not completed(r))
    with_issues = sum(1 for r in recs if r.get("issues"))
    if with_issues:
        warnings.append("%d runs carry bot issues (see the RESULT issues field)" % with_issues)
    report = {
        "inputs": [os.path.basename(p) for p in args.inputs],
        "runs": len(recs),
        "base_runs_total": len(base_all),
        "failed_total": failed,
        "runs_with_issues": with_issues,
        "warnings": warnings,
        "clocks": clock_reports,
    }
    os.makedirs(os.path.dirname(os.path.abspath(args.json)), exist_ok=True)
    with open(args.json, "w") as f:
        json.dump(report, f, indent=2, sort_keys=False)
        f.write("\n")
    write_md(report, args.md)
    print("metrics: %d runs, %d base, %d failed -> %s, %s" % (len(recs), len(base_all), failed, args.json, args.md))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
