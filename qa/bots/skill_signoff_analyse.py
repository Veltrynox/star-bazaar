import json, statistics as st, sys, collections

# QA 2026-11-05 sign-off tables (owned by qa-analyst). Reads <out_dir>/results_all.jsonl from skill_signoff.sh.
# Prints: batch summary, focus vs base, ablation evidence per node, dominance, CEO x ship pass rule.
# Verdict rules (fixed before the runs): a node is REACHED when the learned arm holds it in >= 3 of 4 seeds.
#   AGREE   reached, and the removal moves wins, win cycle (>= 1 cycle, median), cash (>= 5 pct) or focus share (>= 0.02)
#           in the same direction in >= 3 of 4 seeds, or in the node's own output (craft units >= 10 pct).
#   REJECT  reached in >= 3 seeds and no measure moves (all within the noise limits above).
#   CONCERN a change that is small, mixed across seeds, or only part of the node's effect is visible.
#   UNTESTABLE the bot cannot reach the node or its payoff in the kept window (reason given per node).

ROOT = sys.argv[1]
recs = [json.loads(l) for l in open(ROOT + "/results_all.jsonl") if l.strip()]
by = collections.defaultdict(dict)
for r in recs:
    by[r["clock_tag"]][int(r["seed"])] = r
# Re-runs after the pinned-count fix (abl_MIL_2, MIL_6, MIN_2, MIN_6, BIO_2) replace the leaking first runs (optional dir).
if len(sys.argv) > 2:
    for l in open(sys.argv[2] + "/results_all.jsonl"):
        if l.strip():
            r = json.loads(l)
            by[r["clock_tag"]][int(r["seed"])] = r


def craft(r, ws, good):
    return int(((r.get("craft_totals") or {}).get(ws) or {}).get(good, 0))


def craft_all(r):
    return sum(sum(d.values()) for d in (r.get("craft_totals") or {}).values())


def share(r, m):
    return float((r.get("final_shares_by_market") or {}).get(m, 0.0))


def win_cycle(r):
    # The first win of the run. A kept run can end later as SOFT at cycle 40 (the game's own timeout) with the win kept.
    w = r.get("win_cycle")
    return w if (w is not None and w >= 0) else None


def musk_arrivals(r):
    return int(((r.get("storage_end") or {}).get("system:1") or {}).get("musk", 0))


def batch_line(tag):
    rows = by.get(tag, {})
    seeds = sorted(rows)
    wins = [rows[s] for s in seeds if win_cycle(rows[s]) is not None]
    wc = [win_cycle(r) for r in wins]
    cash = [rows[s]["final_cash"] for s in seeds]
    return {
        "n": len(seeds),
        "outcomes": ["win" if win_cycle(rows[s]) else rows[s]["outcome"] for s in seeds],
        "wins": len(wins),
        "win_cycles": wc,
        "median_win": st.median(wc) if wc else None,
        "mean_cash": round(st.mean(cash)) if cash else None,
        "craft_units_mean": round(st.mean(craft_all(rows[s]) for s in seeds), 1) if seeds else None,
        "ships_mean": round(st.mean(rows[s].get("ships_owned", 0) for s in seeds), 1) if seeds else None,
        "issues": sorted({i[0] for s in seeds for i in rows[s].get("issues", []) if i[0] != "warning_streak"}),
    }


def row_str(tag):
    return json.dumps(batch_line(tag), sort_keys=True)


print("== batches (every run, one line per tag)")
for t in sorted(by):
    print(t, row_str(t))

print("\n== crash / frozen / softlock / check records")
bad = [(t, s, r["outcome"]) for t in by for s, r in by[t].items() if r["outcome"] not in ("win", "loss", "soft")]
print("non-game-end records:", bad or "none")
chk = [(t, s, i) for t in by for s, r in by[t].items() for i in r.get("issues", []) if i[0] not in ("warning_streak",)]
print("issues (excl. warning_streak):", chk[:40] if chk else "none")

print("\n== focus and base: wins, win cycles, cash, share (decent, keep-running 38)")
for t, m in [("base", None), ("focus_mil", "mil"), ("focus_lux", "lux"), ("focus_min", "min"), ("focus_bio", "bio"), ("brb_lux", "lux"), ("brb_min", "min"), ("brb_bio", "bio")]:
    rows = by.get(t, {})
    print(t, {s: (rows[s]["outcome"], win_cycle(rows[s]), rows[s]["final_cash"], round(share(rows[s], m), 3) if m else None) for s in sorted(rows)})

print("\n== kept-run output: gems, alloy, armour, plate, musk in station storage (system 1), per focus seed")
for t in ["focus_lux", "abl_LUX_4", "focus_min", "abl_MIN_6", "focus_mil", "abl_MIL_4", "brb_lux", "abl_LUX_7"]:
    rows = by.get(t, {})
    print(t, {s: {"gems": craft(rows[s], "atelier", "gems"), "alloy": craft(rows[s], "smelter", "alloy"),
                  "armour": craft(rows[s], "munitions", "armour"), "musk_station": musk_arrivals(rows[s])}
              for s in sorted(rows)})

NODE_BASE = {}
ABL = [
    ("MIL_2", "tech", "focus_mil"), ("MIL_3", "skill", "focus_mil"), ("MIL_4", "tech", "focus_mil"),
    ("MIL_5", "skill", "focus_mil"), ("MIL_6", "tech", "focus_mil"),
    ("LUX_1", "skill", "focus_lux"), ("LUX_2", "tech", "focus_lux"), ("LUX_4", "tech", "focus_lux"),
    ("LUX_5", "skill", "focus_lux"), ("LUX_6", "tech", "focus_lux"),
    ("MIN_2", "tech", "focus_min"), ("MIN_6", "tech", "focus_min"),
    ("BIO_2", "tech", "focus_bio"), ("BIO_4", "tech", "focus_bio"), ("BIO_5", "skill", "focus_bio"), ("BIO_6", "tech", "focus_bio"),
    ("LUX_7", "skill", "brb_lux"), ("MIN_7", "skill", "brb_min"), ("BIO_7", "skill", "brb_bio"),
]

print("\n== ablations: node removed vs its focus baseline (same seed)")
for node, kind, base_tag in ABL:
    ab_tag = "abl_" + node
    base = by.get(base_tag, {})
    abl = by.get(ab_tag, {})
    seeds = sorted(set(base) & set(abl))
    if not seeds:
        print(node, "NO DATA")
        continue
    mk = base_tag.split("_")[1]
    if kind == "tech":
        reached = [any(c[1] == node for c in base[s].get("tech_log", [])) for s in seeds]
        done_abl = [any(c[1] == node for c in abl[s].get("tech_log", [])) for s in seeds]
    else:
        reached = [node in base[s].get("skills_owned", []) for s in seeds]
        done_abl = [node in abl[s].get("skills_owned", []) for s in seeds]
    dw = [(win_cycle(abl[s]) - win_cycle(base[s])) if (win_cycle(abl[s]) and win_cycle(base[s])) else None for s in seeds]
    dcash = [abl[s]["final_cash"] - base[s]["final_cash"] for s in seeds]
    dshare = [round(share(abl[s], mk) - share(base[s], mk), 3) for s in seeds]
    dcraft = [craft_all(abl[s]) - craft_all(base[s]) for s in seeds]
    dgood = []
    for s in seeds:
        keys = set()
        for d in [base[s].get("craft_totals") or {}, abl[s].get("craft_totals") or {}]:
            for ws, g in d.items():
                keys |= {(ws, x) for x in g}
        delta = {f"{ws}.{x}": craft(abl[s], ws, x) - craft(base[s], ws, x) for ws, x in sorted(keys)}
        dgood.append({k: v for k, v in delta.items() if abs(v) >= 5})
    print(node, {
        "kind": kind, "base_tag": base_tag, "reached_seeds": sum(reached), "still_in_abl": sum(done_abl),
        "base_out": ["win" if win_cycle(base[s]) else "no win" for s in seeds], "abl_out": ["win" if win_cycle(abl[s]) else "no win" for s in seeds],
        "base_win": [win_cycle(base[s]) for s in seeds], "abl_win": [win_cycle(abl[s]) for s in seeds],
        "d_win": dw, "d_cash": dcash, "mean_d_cash": round(st.mean(dcash)) if dcash else None,
        "d_share": dshare, "d_craft": dcraft, "d_goods_seed_by_seed": dgood,
        "base_craft_mean": round(st.mean(craft_all(base[s]) for s in seeds), 1),
        "lost_seed1": sorted(set(base[seeds[0]].get("skills_owned", [])) - set(abl[seeds[0]].get("skills_owned", []))),
        "tech_base_seed1": [c for c in base[seeds[0]].get("tech_log", [])],
        "abl_issues": [i for s in seeds for i in abl[s].get("issues", []) if i[0] != "warning_streak"][:3],
        "tech_completed_in_abl": [[c for c in abl[s].get("tech_log", []) if c[1] == node] for s in seeds] if kind == "tech" else None,
    })

print("\n== dominance and pacing, 4 seeds (no-market default vs focuses vs other strategies)")
for t in ["base", "focus_mil", "focus_lux", "focus_min", "focus_bio", "dom_sloppy", "dom_always_expand", "dom_never_expand", "base_notut"]:
    print(t, row_str(t))

print("\n== CEO x ship check (decent, seeds 1-3): median win cycle and win rate")
combos = []
for t in sorted(by):
    if not t.startswith("ce_"):
        continue
    rows = by[t]
    wins = [win_cycle(rows[s]) for s in sorted(rows) if win_cycle(rows[s]) is not None]
    combos.append({"combo": t[3:], "wins": len(wins), "n": len(rows),
                   "median": st.median(wins) if wins else None, "cycles": wins})
best_rate = max((c["wins"] / c["n"] for c in combos), default=0.0)
med_all = [c["median"] for c in combos if c["median"] is not None]
ref = st.median(med_all) if med_all else None
passed = 0
for c in combos:
    rate = c["wins"] / c["n"] if c["n"] else 0.0
    c["rate"] = round(rate, 3)
    c["median_ok"] = c["median"] is not None and ref is not None and abs(c["median"] - ref) <= 1
    c["rate_ok"] = best_rate > 0 and rate >= 0.6 * best_rate
    c["pass"] = c["median_ok"] and c["rate_ok"]
    passed += 1 if c["pass"] else 0
    print(c)
print("reference median (median of combo medians):", ref, "best win rate:", round(best_rate, 3), "combos passing:", passed, "of", len(combos))
