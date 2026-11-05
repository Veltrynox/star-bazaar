import json, statistics as st, sys, collections, os

# QA 2026-11-05 T173 sign-off tables (owned by qa-analyst). Reads <out_dir>/results_all.jsonl from more_skills_signoff.sh.
# Verdict rules (fixed before the runs), per node with a learned arm and an unlearned arm on the same seeds:
#   REACHED   the node is learned in the on arm in >= 3 of 4 seeds
#   FELT      reached, and removal moves in one direction in >= 3 of 4 seeds: win cycle (>= 1), cash (>= 5 pct),
#             focus share (>= 0.02), route capacity of the market (>= 10 pct), event hits (>= 1), planet stock (>= 10 pct)
#   NOT FELT  reached, and no measure moves past those limits
#   UNTESTABLE the bot cannot reach the node or its payoff (reason given)
# Usage: python3 -I qa/bots/more_skills_signoff_analyse.py <out_dir>   (path to results_all.jsonl's folder)
ROOT = sys.argv[1]
recs = [json.loads(l) for l in open(os.path.join(ROOT, "results_all.jsonl")) if l.strip()]
by = collections.defaultdict(dict)
for r in recs:
    by[r["clock_tag"]][int(r["seed"])] = r

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
goods = {g["id"]: g["market"] for g in json.load(open(os.path.join(REPO, "data/goods.json")))["goods"]}
balance = json.load(open(os.path.join(REPO, "data/balance.json")))


def win_cycle(r):
    w = r.get("win_cycle")
    return w if (w is not None and w >= 0) else None


def cost_of(node_id):
    return int(balance.get("skill_cost_" + node_id, 0))


def spent(r):
    return sum(int(x[2]) for x in r.get("skill_log", []))


def earned(r):
    return spent(r) + int(r.get("skill_points_left", 0))


def cash_min_10(r):
    rows = [c for c in r.get("cash_by_cycle", []) if c[0] <= 10]
    return min(c[1] for c in rows) if rows else None


def cash_at(r, cyc):
    for c in r.get("cash_by_cycle", []):
        if c[0] == cyc:
            return c[1]
    return None


def stock_mkt(r, m):
    tot = 0
    for key, goods_map in (r.get("storage_end") or {}).items():
        if not key.startswith("planet:"):
            continue
        for g, n in goods_map.items():
            if goods.get(g) == m:
                tot += int(n)
    return tot


def events(r, m):
    """Price events against market m: down and up rows that start (age 0), plus closure rows (no good)."""
    down = up = closed = 0
    for ev in r.get("event_rows", []):
        for a in ev.get("active", []):
            _, eid, kind, planet, c, left, age = a
            if c and goods.get(c) == m and int(age) == 0:
                if kind == "down":
                    down += 1
                elif kind == "up":
                    up += 1
        closed += len(ev.get("closed", []))
    return {"down": down, "up": up, "closed_cycles": closed}


def route_cap(r, m):
    return int((r.get("route_units_by_market") or {}).get(m, 0))


def share(r, m):
    return float((r.get("final_shares_by_market") or {}).get(m, 0.0))


def med(xs):
    return st.median(xs) if xs else None


def arm_line(tag):
    rows = by.get(tag, {})
    seeds = sorted(rows)
    wc = [win_cycle(rows[s]) for s in seeds]
    wins = [w for w in wc if w is not None]
    return {
        "tag": tag, "n": len(seeds),
        "wins": len(wins), "win_cycles": [w if w is not None else "-" for w in wc],
        "outcomes": [rows[s].get("outcome") for s in seeds],
        "cash_mean": round(st.mean(rows[s]["final_cash"] for s in seeds)) if seeds else None,
        "cash_min10": [cash_min_10(rows[s]) for s in seeds],
        "ships": [rows[s].get("ships_owned") for s in seeds],
        "permits": [rows[s].get("permits_bought") for s in seeds],
        "spent": [spent(rows[s]) for s in seeds],
        "left": [rows[s].get("skill_points_left") for s in seeds],
        "earned": [earned(rows[s]) for s in seeds],
    }


def show(line):
    print("%-18s n=%d wins=%d/%d cycles=%s outcomes=%s cash_mean=%s ships=%s permits=%s" % (
        line["tag"], line["n"], line["wins"], line["n"], line["win_cycles"], line["outcomes"],
        line["cash_mean"], line["ships"], line["permits"]))


print("== 1. Regression and dominance (keep-running 38 for reg_*, none for dom_*)")
for tag in ["reg_default", "reg_mil", "reg_lux", "reg_min", "reg_bio", "dom_sloppy", "dom_always_expand", "dom_never_expand"]:
    show(arm_line(tag))
dom_wins = sum(len([1 for s in by[t] if win_cycle(by[t][s]) is not None]) for t in ["dom_sloppy", "dom_always_expand", "dom_never_expand"] if t in by)
print("dominance wins (sloppy + always_expand + never_expand): %d of 12" % dom_wins)

print("\n== 2. Points: spent and left by run (focus runs, to cycle 39)")
for tag in ["reg_default", "reg_mil", "reg_lux", "reg_min", "reg_bio", "fit_one_lux", "fit_two_mkts"]:
    L = arm_line(tag)
    print("%-14s spent=%s left=%s earned=%s" % (tag, L["spent"], L["left"], L["earned"]))

print("\n== 3. Node ablations (on = learned, off = removed; same seeds; keep-running 38)")
NODES = [
    # node, market, natural pair (with, without), controlled pair (off, on)
    ("FND_BULK", "fnd", ("reg_default", "nat_FND_BULK"), ("brb_fnd_base", "brb_fnd_bulk"), "FND_BULK"),
    ("MIL_5B", "mil", ("reg_mil", "nat_MIL_5B"), ("brb_mil_base", "brb_mil_5B"), "MIL_5B"),
    ("LUX_5B", "lux", ("reg_lux", "nat_LUX_5B"), ("brb_lux_base", "brb_lux_5B"), "LUX_5B"),
    ("LUX_6B", "lux", ("reg_lux", "nat_LUX_6B"), ("brb_lux_5B", "brb_lux_5B_6B"), "LUX_6B"),
    ("MIN_5B", "min", ("reg_min", "nat_MIN_5B"), ("brb_min_base", "brb_min_5B"), "MIN_5B"),
    ("BIO_5B", "bio", ("reg_bio", "nat_BIO_5B"), ("brb_bio_base", "brb_bio_5B"), "BIO_5B"),
    ("BIO_6B", "bio", ("reg_bio", "nat_BIO_6B"), ("brb_bio_base", "brb_bio_6B"), "BIO_6B"),
]


def learned(r, node):
    return node in (r.get("skills_owned") or [])


def pair_report(node, m, on_tag, off_tag, label):
    on = by.get(on_tag, {}); off = by.get(off_tag, {})
    seeds = sorted(set(on) & set(off))
    reach = sum(1 for s in seeds if learned(on[s], node))
    print("-- %s [%s]: on=%s off=%s  learned in on arm %d of %d" % (node, label, on_tag, off_tag, reach, len(seeds)))
    rows = []
    for s in seeds:
        a, b = on[s], off[s]
        rows.append((s, learned(a, node), win_cycle(a), win_cycle(b), a["final_cash"], b["final_cash"],
                     share(a, m), share(b, m), route_cap(a, m), route_cap(b, m),
                     events(a, m), events(b, m), stock_mkt(a, m), stock_mkt(b, m), cash_min_10(a), cash_min_10(b)))
    print("  seed learned win(on/off) cash(on/off) share(on/off) route_cap(on/off) events_down(on/off) stock(on/off) cash_min10(on/off)")
    for (s, l, wa, wb, ca, cb, sa, sb, ra, rb, ea, eb, ka, kb, mina, minb) in rows:
        print("  %d %-5s %s/%s %d/%d %.3f/%.3f %d/%d %d/%d %d/%d %s/%s" % (
            s, l, wa, wb, ca, cb, sa, sb, ra, rb, ea["down"], eb["down"], ka, kb, mina, minb))
    if seeds:
        dc = [on[s]["final_cash"] - off[s]["final_cash"] for s in seeds]
        ds = [share(on[s], m) - share(off[s], m) for s in seeds]
        dr = [route_cap(on[s], m) - route_cap(off[s], m) for s in seeds]
        de = [events(on[s], m)["down"] - events(off[s], m)["down"] for s in seeds]
        print("  deltas (on-off): cash %s, share %s, route_cap %s, down events %s" % (
            dc, ["%+.3f" % x for x in ds], dr, de))
    return rows


for node, m, nat, brb, _ in NODES:
    pair_report(node, m, nat[0], nat[1], "natural focus")
    pair_report(node, m, brb[1], brb[0], "branch whitelist")

print("\n== 4. Chosen-bot lock: successful chosen-bot hits, gaps between hits of different skills")
CB_CD = {"MIL_5": 7, "LUX_7": 9, "BIO_6B": 8}
for tag in ["lock_mil5_bio6b", "lock_lux7_bio6b", "lock_mil5_lux7", "lock_all3", "reg_default", "reg_mil", "reg_lux", "reg_bio", "brb_bio_6B"]:
    if tag not in by:
        continue
    for s in sorted(by[tag]):
        r = by[tag][s]
        owned = [n for n in ["MIL_5", "LUX_7", "BIO_6B"] if n in (r.get("skills_owned") or [])]
        hits = sorted([(int(x[0]), x[1]) for x in r.get("bot_skill_log", []) if x[4]])
        cross = [b[0] - a[0] for a, b in zip(hits, hits[1:]) if a[1] != b[1]]
        same = [b[0] - a[0] for a, b in zip(hits, hits[1:]) if a[1] == b[1]]
        att = len(r.get("bot_skill_log", []))
        bad_same = [g for g in same if g < CB_CD.get(hits[0][1], 0)] if hits else []
        print("  %-17s s%d learned=%s hits=%s min_cross_gap=%s same_gaps=%s own-cooldown breaks=%s win=%s" % (
            tag, s, owned, [(h[0], h[1]) for h in hits], min(cross) if cross else "-", same, bad_same, win_cycle(r)))

print("\n== 5. Second-market fit (points)")
for tag in ["fit_one_lux", "fit_two_mkts"]:
    for s in sorted(by.get(tag, {})):
        r = by[tag][s]
        learned_set = [x[1] for x in r.get("skill_log", [])]
        print("  %s s%d earned=%d spent=%d left=%d learned=%d win=%s" % (tag, s, earned(r), spent(r), r.get("skill_points_left", 0), len(learned_set), win_cycle(r)))
