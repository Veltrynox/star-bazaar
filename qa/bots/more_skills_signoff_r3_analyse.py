import json, statistics as st, sys, collections, os

# QA 2026-11-05 T173 round 3 tables (owned by qa-analyst). Reads <out_dir>/results_all.jsonl from more_skills_signoff_r3.sh.
# Previous round records (for the regression column): qa/reports/2026-11-05-more-skills-signoff-runs.jsonl (data skills v6, balance v52).
# Verdict rules (same as round 1 and 2), per node, same seeds, on vs off:
#   REACHED   learned in the on arm in >= 3 of 4 seeds
#   FELT      reached, and one measure moves in one direction in >= 3 of 4 seeds past its limit:
#             win cycle (>= 1), cash (>= 5 pct), focus share (>= 0.02), market route capacity (>= 10 pct),
#             down events against the market (>= 1), planet stock of the market (>= 10 pct)
#   NOT FELT  reached, and no measure moves past those limits
#   UNTESTABLE the bot cannot reach the node or its payoff (reason given by hand)
# Usage: python3 -I qa/bots/more_skills_signoff_r3_analyse.py <out_dir>
ROOT = sys.argv[1]
recs = [json.loads(l) for l in open(os.path.join(ROOT, "results_all.jsonl")) if l.strip()]
by = collections.defaultdict(dict)
for r in recs:
    by[r["clock_tag"]][int(r["seed"])] = r

REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
goods = {g["id"]: g["market"] for g in json.load(open(os.path.join(REPO, "data/goods.json")))["goods"]}
PREV = os.path.join(REPO, "qa/reports/2026-11-05-more-skills-signoff-runs.jsonl")
prev = collections.defaultdict(dict)
for l in open(PREV):
    if l.strip():
        r = json.loads(l)
        if str(r.get("clock_tag", "")).startswith("reg_") or str(r.get("clock_tag", "")).startswith("dom_"):
            prev[r["clock_tag"]][int(r["seed"])] = r


def win_cycle(r):
    w = r.get("win_cycle")
    return w if (w is not None and w >= 0) else None


def spent(r):
    return sum(int(x[2]) for x in r.get("skill_log", []))


def earned(r):
    return spent(r) + int(r.get("skill_points_left", 0))


def cash_min_10(r):
    rows = [c for c in r.get("cash_by_cycle", []) if c[0] <= 10]
    return min(c[1] for c in rows) if rows else None


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
    down = up = 0
    for ev in r.get("event_rows", []):
        for a in ev.get("active", []):
            _, eid, kind, planet, c, left, age = a
            if c and goods.get(c) == m and int(age) == 0:
                if kind == "down":
                    down += 1
                elif kind == "up":
                    up += 1
    return {"down": down, "up": up}


def event_starts(r):
    """Realised event sequence: (cycle, event id, planet, kind) for every event that starts (age 0)."""
    out = []
    for ev in r.get("event_rows", []):
        for a in ev.get("active", []):
            cyc, eid, kind, planet, c, left, age = a
            if int(age) == 0:
                out.append((int(cyc), eid, planet, kind))
    return out


def route_cap(r, m):
    return int((r.get("route_units_by_market") or {}).get(m, 0))


def share(r, m):
    return float((r.get("final_shares_by_market") or {}).get(m, 0.0))


def learned(r, node):
    return node in (r.get("skills_owned") or [])


def wins_str(rows):
    return ", ".join(("%s" % (win_cycle(rows[s]) if win_cycle(rows[s]) is not None else "none")) for s in sorted(rows))


print("== 0. Health: outcome, error flags and crash/frozen records")
bad = []
for tag in sorted(by):
    for s in sorted(by[tag]):
        r = by[tag][s]
        if r.get("outcome") in ("crash", "frozen", None) or r.get("issues"):
            bad.append((tag, s, r.get("outcome"), r.get("issues")))
print("runs: %d; records with crash/frozen/none outcome or issues: %s" % (len(recs), bad if bad else "none"))
flags = collections.Counter()
for r in recs:
    for k in ("end_cycle_ok", "end_screen_ok", "stats_ok"):
        if r.get(k) is False:
            flags[k] += 1
print("false end/stats flags: %s" % (dict(flags) if flags else "none"))

print("\n== 1. Regression and dominance: this round vs previous round (skills v6 / balance v52)")
ROWS = ["reg_default", "reg_mil", "reg_lux", "reg_min", "reg_bio", "dom_sloppy", "dom_always_expand", "dom_never_expand"]
for tag in ROWS:
    rows = by.get(tag, {})
    print("%-18s now: win cycles [%s] outcomes %s cash %s | prev: [%s] cash %s" % (
        tag, wins_str(rows), [rows[s].get("outcome") for s in sorted(rows)],
        [rows[s]["final_cash"] for s in sorted(rows)],
        wins_str(prev.get(tag, {})) if tag in prev else "-",
        [prev[tag][s]["final_cash"] for s in sorted(prev[tag])] if tag in prev else "-"))
dom_wins = sum(1 for t in ["dom_sloppy", "dom_always_expand", "dom_never_expand"] for s in by.get(t, {}) if win_cycle(by[t][s]) is not None)
print("dominance wins (sloppy + always_expand + never_expand): %d of 12" % dom_wins)
print("\nalways_expand detail (skills learned, win, ships, permits):")
for s in sorted(by.get("dom_always_expand", {})):
    r = by["dom_always_expand"][s]
    print("  seed %d win=%s ships=%s permits=%s skill_log=%s" % (
        s, win_cycle(r), r.get("ships_owned"), r.get("permits_bought"), r.get("skill_log")))

print("\n== 2. Points: spent / left / earned by focus run (to cycle 39)")
for tag in ["reg_default", "reg_mil", "reg_lux", "reg_min", "reg_bio"]:
    rows = by.get(tag, {})
    print("%-12s spent=%s left=%s earned=%s" % (
        tag, [spent(rows[s]) for s in sorted(rows)], [rows[s].get("skill_points_left") for s in sorted(rows)],
        [earned(rows[s]) for s in sorted(rows)]))

print("\n== 3. Node ablations: pairs on vs off, same seeds")
NODES = [
    # node, market, natural (with, without), branch (without, with)
    ("LUX_5B", "lux", ("reg_lux", "nat_LUX_5B"), ("brb_lux_base", "brb_lux_5B")),
    ("LUX_6B", "lux", ("reg_lux", "nat_LUX_6B"), ("brb_lux_5B", "brb_lux_5B_6B")),
    ("MIN_5B", "min", ("reg_min", "nat_MIN_5B"), ("brb_min_base", "brb_min_5B")),
    ("BIO_5B", "bio", ("reg_bio", "nat_BIO_5B"), ("brb_bio_base", "brb_bio_5B")),
    ("BIO_6B", "bio", ("reg_bio", "nat_BIO_6B"), ("brb_bio_base", "brb_bio_6B")),
]
LIMITS = {"win": 1, "cash": 0.05, "share": 0.02, "route": 0.10, "down": 1, "stock": 0.10}
summary = {}


def pair(node, m, on_tag, off_tag, label):
    on = by.get(on_tag, {}); off = by.get(off_tag, {})
    seeds = sorted(set(on) & set(off))
    reach = sum(1 for s in seeds if learned(on[s], node))
    print("-- %s [%s]: on=%s off=%s learned in on arm %d of %d" % (node, label, on_tag, off_tag, reach, len(seeds)))
    print("  seed learned win(on/off) cash(on/off) share(on/off) route(on/off) down(on/off) stock(on/off) cash_min10(on/off) bot_hits(on/off)")
    d = collections.defaultdict(list)
    for s in seeds:
        a, b = on[s], off[s]
        ea, eb = events(a, m), events(b, m)
        ka, kb = stock_mkt(a, m), stock_mkt(b, m)
        ha = sum(1 for x in a.get("bot_skill_log", []) if x[4])
        hb = sum(1 for x in b.get("bot_skill_log", []) if x[4])
        cols = [str(s), str(learned(a, node)), "%s/%s" % (win_cycle(a), win_cycle(b)),
                "%d/%d" % (a["final_cash"], b["final_cash"]), "%.3f/%.3f" % (share(a, m), share(b, m)),
                "%d/%d" % (route_cap(a, m), route_cap(b, m)), "%d/%d" % (ea["down"], eb["down"]),
                "%d/%d" % (ka, kb), "%s/%s" % (cash_min_10(a), cash_min_10(b)), "%d/%d" % (ha, hb)]
        print("  " + " ".join(cols))
        d["win"].append((win_cycle(a) or 0) - (win_cycle(b) or 0))
        d["cash"].append((a["final_cash"] - b["final_cash"]) / max(1, abs(b["final_cash"])))
        d["share"].append(share(a, m) - share(b, m))
        d["route"].append((route_cap(a, m) - route_cap(b, m)) / max(1, route_cap(b, m)))
        d["down"].append(ea["down"] - eb["down"])
        d["stock"].append((ka - kb) / max(1, kb))
    moved = {}
    for k, xs in d.items():
        lim = LIMITS[k]
        pos = sum(1 for x in xs if x >= lim); neg = sum(1 for x in xs if x <= -lim)
        moved[k] = "+%d/-%d" % (pos, neg)
        if pos >= 3 or neg >= 3:
            moved[k] += " FELT"
    print("  seeds past limit (+ on higher, - on lower; needs 3 of 4): %s" % moved)
    print("  deltas on-off: cash %s, share %s, route %s, down %s" % (
        ["%+d" % x for x in [a["final_cash"] - b["final_cash"] for a, b in ((on[s], off[s]) for s in seeds)]],
        ["%+.3f" % x for x in d["share"]], ["%+.2f" % x for x in d["route"]], d["down"]))
    summary[(node, label)] = (reach, len(seeds), moved)


for node, m, nat, brb in NODES:
    pair(node, m, nat[0], nat[1], "natural focus")
    pair(node, m, brb[1], brb[0], "branch whitelist")

print("\n== 4. LUX_5B event sequence: with vs without (realised starts and full event rows)")
for on_tag, off_tag, label in [("reg_lux", "nat_LUX_5B", "natural"), ("brb_lux_5B", "brb_lux_base", "branch")]:
    on = by.get(on_tag, {}); off = by.get(off_tag, {})
    for s in sorted(set(on) & set(off)):
        a, b = event_starts(on[s]), event_starts(off[s])
        full_a = json.dumps(on[s].get("event_rows"), sort_keys=True)
        full_b = json.dumps(off[s].get("event_rows"), sort_keys=True)
        first = next((i for i, (x, y) in enumerate(zip(a, b)) if x != y), None)
        print("  %s s%d: starts with=%d without=%d identical_starts=%s identical_event_rows=%s first_diff=%s" % (
            label, s, len(a), len(b), a == b, full_a == full_b,
            (a[first] if first is not None and first < len(a) else (b[first] if first is not None else "-"))))

print("\n== 5. BIO_5B knife edge (bio focus, all four seeds, win and cash by arm)")
for tag in ["reg_bio", "nat_BIO_5B", "brb_bio_base", "brb_bio_5B", "nat_BIO_6B", "brb_bio_6B"]:
    rows = by.get(tag, {})
    print("  %-14s wins [%s] cash %s outcomes %s" % (tag, wins_str(rows),
          [rows[s]["final_cash"] for s in sorted(rows)], [rows[s].get("outcome") for s in sorted(rows)]))
r4 = by.get("reg_bio", {}).get(4)
if r4:
    print("  reg_bio seed 4 skill_log: %s" % r4.get("skill_log"))
    print("  reg_bio seed 4 final shares: %s" % r4.get("final_shares_by_market"))

print("\n== 6. BIO_6B chosen-bot hits (successful) per run, with and without the node")
for tag in ["reg_bio", "nat_BIO_6B", "brb_bio_6B", "brb_bio_base"]:
    rows = by.get(tag, {})
    print("  %-14s %s" % (tag, [sum(1 for x in rows[s].get("bot_skill_log", []) if x[4]) for s in sorted(rows)]))

print("\n== 7. Shared chosen-bot lock with BIO_6B at 0.35 (successful hits, gaps)")
CB_CD = {"MIL_5": 7, "LUX_7": 9, "BIO_6B": 8}
for tag in ["lock_mil5_bio6b", "lock_lux7_bio6b"]:
    for s in sorted(by.get(tag, {})):
        r = by[tag][s]
        owned = [n for n in ["MIL_5", "LUX_7", "BIO_6B"] if n in (r.get("skills_owned") or [])]
        hits = sorted([(int(x[0]), x[1]) for x in r.get("bot_skill_log", []) if x[4]])
        cross = [b[0] - a[0] for a, b in zip(hits, hits[1:]) if a[1] != b[1]]
        same = [b[0] - a[0] for a, b in zip(hits, hits[1:]) if a[1] == b[1]]
        bad_same = [g for g in same if g < CB_CD.get(hits[0][1], 0)] if hits else []
        print("  %-17s s%d learned=%s hits=%s min_cross_gap=%s own-cooldown breaks=%s win=%s" % (
            tag, s, owned, hits, min(cross) if cross else "-", bad_same, win_cycle(r)))

print("\n== 8. Verdict inputs (reached and FELT by measure)")
for (node, label), (reach, n, moved) in summary.items():
    print("  %-7s %-16s reached %d of %d  %s" % (node, label, reach, n, moved))
