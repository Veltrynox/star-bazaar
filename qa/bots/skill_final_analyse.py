import json, statistics as st, sys

ROOT = sys.argv[1]
recs = [json.loads(l) for l in open(ROOT + "/results_all.jsonl")]
by = {}
for r in recs:
    by.setdefault(r["clock_tag"], {})[r["seed"]] = r

MARKET = {"focus_mil": "mil", "focus_lux": "lux", "focus_min": "min", "focus_bio": "bio"}
NODE_TAG = {}  # tag -> (node, kind, market)
for t in by:
    if t.startswith("abl_"):
        node = t[4:]
        mk = node.split("_")[0].lower()
        NODE_TAG[t] = (node, mk)


def craft_units(r):
    return sum(sum(d.values()) for d in (r.get("craft_totals") or {}).values())


def share(r, m):
    return float((r.get("final_shares_by_market") or {}).get(m, 0.0))


def summ(tag, m=None):
    rows = by.get(tag, {})
    seeds = sorted(rows)
    wins = [s for s in seeds if rows[s]["outcome"] == "win"]
    wc = [rows[s]["cycle_reached"] for s in wins]
    cash = [rows[s]["final_cash"] for s in seeds]
    out = {
        "n": len(seeds),
        "wins": len(wins),
        "win_cycles": wc,
        "outcomes": [rows[s]["outcome"] for s in seeds],
        "cash": round(st.mean(cash)) if cash else None,
        "share": round(st.mean(share(rows[s], m) for s in seeds), 3) if m else None,
        "craft": round(st.mean(craft_units(rows[s]) for s in seeds), 1),
        "ships": round(st.mean(rows[s]["ships_owned"] for s in seeds), 1) if seeds else None,
        "workshops": sorted({w[1] for s in seeds for w in rows[s].get("workshops_built", [])}),
    }
    return out


print("== batches")
for t in sorted(by):
    m = MARKET.get(t) or (t[4:].split("_")[0].lower() if t.startswith("abl_") else None)
    if t == "base":
        m = None
    s = summ(t, m)
    print(t, s)

print("\n== skill learn cycles (skill_log) and techs done, focus baselines")
for t in ["focus_mil", "focus_lux", "focus_min", "focus_bio"]:
    for s in sorted(by.get(t, {})):
        r = by[t][s]
        print(t, s, "learn:", [(e[0], e[1]) for e in r.get("skill_log", [])], "tech_done:", r.get("tech_done"))

print("\n== ablations vs focus baseline, same seed")
for t in sorted(NODE_TAG):
    node, mk = NODE_TAG[t]
    base_tag = "focus_" + mk
    base = by.get(base_tag, {})
    abl = by.get(t, {})
    seeds = sorted(set(base) & set(abl))
    if not seeds:
        print(t, "NO DATA")
        continue
    reached = [node in base[s].get("skills_owned", []) for s in seeds]
    lost_all = []
    for s in seeds:
        lost = sorted(set(base[s].get("skills_owned", [])) - set(abl[s].get("skills_owned", [])))
        lost_all.append(lost)
    still = [node in abl[s].get("skills_owned", []) for s in seeds]
    base_wins = [base[s]["outcome"] == "win" for s in seeds]
    abl_wins = [abl[s]["outcome"] == "win" for s in seeds]
    dcash = [abl[s]["final_cash"] - base[s]["final_cash"] for s in seeds]
    dshare = [share(abl[s], mk) - share(base[s], mk) for s in seeds]
    dcraft = [craft_units(abl[s]) - craft_units(base[s]) for s in seeds]
    bwc = [base[s]["cycle_reached"] for s in seeds]
    awc = [abl[s]["cycle_reached"] for s in seeds]
    print(t, {
        "node_reached_base": sum(reached), "node_in_abl": sum(still),
        "base_outcomes": [base[s]["outcome"] for s in seeds],
        "abl_outcomes": [abl[s]["outcome"] for s in seeds],
        "base_cycles": bwc, "abl_cycles": awc,
        "base_wins": sum(base_wins), "abl_wins": sum(abl_wins),
        "mean_dcash": round(st.mean(dcash)),
        "mean_dshare_%s" % mk: round(st.mean(dshare), 3),
        "mean_base_share": round(st.mean(share(base[s], mk) for s in seeds), 3),
        "mean_dcraft": round(st.mean(dcraft), 1),
        "mean_base_craft": round(st.mean(craft_units(base[s]) for s in seeds), 1),
        "lost_subtree_seed1": lost_all[0],
        "abl_skill_log_errors": [i for s in seeds for i in abl[s].get("issues", []) if i[0] != "warning_streak"][:2],
    })

print("\n== all issues by batch (excluding warning_streak)")
for t in sorted(by):
    for s in sorted(by[t]):
        for i in by[t][s].get("issues", []):
            if i[0] != "warning_streak":
                print(t, s, i)
