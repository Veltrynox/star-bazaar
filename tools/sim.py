#!/usr/bin/env python3
"""Star Bazaar paper sim v4 (v3 + shared order pools per planet+commodity, many ships per route, system 2). Run from repo root: python3 tools/sim.py [--mc N] [--seed S]
Reads data/balance.json, data/planets.json, data/events.json (tags only). No game code is read.
Model (per cycle, one ship = one src->dst commodity c leg, steady state; any number of ships per route):
  v4: buy order at (src,c) and sell order at (dst,c) are SHARED POOLS of order_amount*(1+B2) units/cycle across all ships;
  ships fill pools in margin order; a ship whose net <=0 idles. Ship flow f = min(route_units, pool left)
  route_units = cargo/(2*travel) * (1+A4)
  margin m = (sell_dst - buy_src) * (1+B3) * (1+upgrade_bonus*level)   with event price factors on both prices
  net = f*m - upkeep, upkeep = (trip_cost + maintenance/interval) * (1-A5); net<=0 -> idle, pays 0
  New route earns 0 in its first cycle (stock must move first; UNKNOWN real pipeline lag).
Events (every event_interval cycles, one random of events.json): price up/down = factor on that planet+commodity buy and sell
  prices for event_price_cycles; closed = planet blocked for event_close_cycles (A1/A2/B4 each cover one cycle of it).
Points: planet_first_visit, new pair, (system points unused in system 1). Skills cost points; no credits.
--real: mirrors the build as of 2026-10-27 (one ship per lane, no upgrades, no permit); --inject=C:N adds N cash at cycle C (QA input). Lane-limited mode reproduces the QA bot (decent +1000: 8701).
Win: cash>=win_cash at cycle end. Loss: cycle win_cycle ends below. Rescue: no ships and cash<ship_price -> stipend."""
import json, os, re, random, statistics, sys, itertools
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
J = lambda p: json.load(open(os.path.join(R, p)))
V = J("data/balance.json")["values"]; PL = J("data/planets.json")["planets"]; EVS = J("data/events.json")
REAL = "--real" in sys.argv; RESCUE_ANY = "--rescue-any" in sys.argv; INJ = (0, 0)
for _a in sys.argv:
    if _a.startswith("--inject="): INJ = tuple(int(x) for x in _a[9:].split(":"))
    if _a.startswith("--set="):
        for kv in _a[6:].split(","): k, v = kv.split("="); V[k] = float(v) if "." in v else int(v)
S2 = J("tools/system2.json")["planets"]
NAME = [p["name"] for p in PL]
for p in PL: p["system"] = 1
PL = PL + S2          # indices 0-2 system 1, 3-6 system 2
def parse(e):
    m = re.match(r"\[(price (?:up|down)): (\w+), (\w+)\]", e["tag"])
    if m: return (m.group(1), NAME.index(m.group(2)), m.group(3))
    m = re.match(r"\[planet closed: (\w+)\]", e["tag"])
    return ("closed", NAME.index(m.group(1)), None) if m else None
EVT = [x for x in map(parse, EVS) if x]
COMM = ["energy", "food"]
def routes_in(sysn):
    ix = [i for i, p in enumerate(PL) if p["system"] == sysn]
    return [(s, d, c) for s in ix for d in ix if s != d for c in COMM
            if PL[s]["base_prices"].get(c + "_buy") and PL[d]["base_prices"].get(c + "_sell")
            and PL[d]["base_prices"][c + "_sell"] > PL[s]["base_prices"][c + "_buy"]]
R1, R2 = routes_in(1), routes_in(2)
ALL = R1
def pair(r): return frozenset((r[0], r[1]))
TREE = {"A1": None, "A2": "A1", "A4": "A2", "A5": "A4", "B1": None, "B2": "B1", "B3": "B2", "B4": "B3",
        "C1": None, "C2": "C1", "C3": "C2", "C4": "C3"}
def cost(s): return V["skill_cost_" + s]
BUILDS = {
 "none": [], "logistics": ["A1", "A2", "A4", "A5"], "research": ["B1", "B2", "B3", "B4"],
 "expansion": ["C1", "C2", "C3", "C4"], "econ_mix": ["B1", "B2", "A1", "A2", "B3", "A4", "A5", "B4"],
 "log_first": ["A1", "A2", "A4", "B1", "B2", "A5", "B3", "B4"],
 "perm_only": ["C1"], "perm_research": ["C1", "B1", "B2", "B3", "B4"],
 "full": list(TREE)}
def margin(r, sk, ev, lv):
    s, d, c = r; buy = PL[s]["base_prices"][c + "_buy"]; sell = PL[d]["base_prices"][c + "_sell"]
    for (k, p, cc), _ in ev:
        if cc == c and k != "closed":
            f = 1 + V["event_price_pct"] * (1 if k == "price up" else -1)
            if p == s: buy *= f
            if p == d: sell *= f
    return (sell - buy) * (1 + V["skill_B3_margin"] * ("B3" in sk)) * (1 + V["upgrade_margin_bonus"] * lv)
def ship_stats(x, sk):
    h = x["h"]
    ru = V["cargo"] / (2 * V["travel_cycles_per_leg"]) * (1 + V["skill_A4_route_units"] * ("A4" in sk))
    up = (V["trip_cost"] + V["maintenance"] / V["maintenance_interval"]) * (1 - V["skill_A5_upkeep"] * ("A5" in sk))
    return ru, up
def blocked(r, ev, sk):
    for (k, p, c), left in ev:
        if k == "closed" and p in (r[0], r[1]):
            cov = ("A1" in sk) + ("A2" in sk) + ("B4" in sk)
            if left > cov: return True
    return False
def income(ships, sk, evp=(), ev=(), detail=False):
    """steady-state net per cycle of all ships (age>=1, not blocked) with shared order pools"""
    A = V["order_amount"] * (1 + V["skill_B2_order_units"] * ("B2" in sk))
    pool = {}
    items = []
    for x in ships:
        if x["age"] < 1 or blocked(x["r"], ev, sk): continue
        ru, up = ship_stats(x, sk); items.append((margin(x["r"], sk, evp, x["lv"]), ru, up, x))
    items.sort(key=lambda t: -t[0]); tot = 0; per = []
    for m, ru, up, x in items:
        s, d, c = x["r"]; f = min(ru, pool.setdefault(("b", s, c), A), pool.setdefault(("s", d, c), A))
        net = f * m - up
        if net <= 0: per.append(0); continue
        pool[("b", s, c)] -= f; pool[("s", d, c)] -= f; tot += net; per.append(net)
    return (tot, per) if detail else tot
def marginal(route, nmax=10, sk=frozenset()):
    """system-1 table: net income added by the Nth ship, ships added greedily to the best marginal route"""
    ships = []; out = []; prev = 0
    for n in range(nmax):
        best = max(R1, key=lambda r: income(ships + [{"r": r, "lv": 0, "h": False, "age": 1}], sk))
        ships.append({"r": best, "lv": 0, "h": False, "age": 1}); t = income(ships, sk); out.append((best, t - prev)); prev = t
    return out
def run(strat="decent", build="none", rng=None, trace=False):
    cash = V["starting_credits"]; ships = []; sk = set(); pts = 0; seen = {0}; pairs = set(); ev = []; permit2 = False; sysp = set()
    pts += V["skill_points_planet"]
    for c in range(1, V["win_cycle"] + 1):
        ev = [(e, l - 1) for e, l in ev if l > 1]
        if rng and (c - 1) % V["event_interval"] == 0:
            e = rng.choice(EVT); ev.append((e, V["event_close_cycles"] if e[0] == "closed" else V["event_price_cycles"]))
        if build == "full": pts += V["full_ref_points_per_cycle"]
        def learn():
            nonlocal pts
            for b in BUILDS[build]:
                if b not in sk and (TREE[b] is None or TREE[b] in sk) and pts >= cost(b):
                    if b != "C1" or pts - cost(b) >= 0: pts -= cost(b); sk.add(b)
        learn()
        if c == INJ[0]: cash += INJ[1]
        evp = [x for x in ev if x[0][0] != "closed"]
        def price(h): return V["ship_price"]
        def inc_now(sh): return income(sh, sk)
        def new(r, h, lv=0): return {"r": r, "lv": lv, "h": h, "age": 1}
        def buy_ship(r, h):
            nonlocal cash, pts
            cash -= price(h); ships.append({"r": r, "lv": 0, "h": h, "age": 0})
            for p in (r[0], r[1]):
                if p not in seen:
                    seen.add(p); pts += V["skill_points_planet"]
                    sy = PL[p]["system"]
                    if sy != 1 and sy not in sysp: sysp.add(sy); pts += V["skill_points_system"]
            if pair(r) not in pairs: pairs.add(pair(r)); pts += V["skill_points_route"]
            learn()
        pool_routes = R1 + (R2 if permit2 else [])
        if strat == "always":
            while len(ships) < V["ship_cap"] and cash >= V["ship_price"]:
                base = inc_now(ships); cand = [(inc_now(ships + [new(r, False)]) - base, r) for r in pool_routes if not (REAL and any(x["r"] == r for x in ships))]
                if not cand: break
                dv, r = max(cand, key=lambda t: t[0]); buy_ship(r, False)
            if "C1" in sk and not permit2 and pts >= V["permit_points_2"] and cash >= V["permit_2_cost"]:
                permit2 = True; cash -= V["permit_2_cost"]; pts -= V["permit_points_2"]
        else:
            while True:
                opts = []; base = inc_now(ships)
                if strat == "decent" and len(ships) < V["ship_cap"]:
                    for r in pool_routes:
                        if REAL and any(x["r"] == r for x in ships): continue
                        for h in ([False]):
                            dv = inc_now(ships + [new(r, h)]) - base
                            if dv > 0: opts.append((dv / price(h), price(h), "route", r, h))
                if strat == "decent" and not REAL:
                    for x in ships:
                        if x["lv"] < 1:
                            x["lv"] = 1; dv = inc_now(ships) - base; x["lv"] = 0
                            if dv > 0: opts.append((dv / V["upgrade_cost"], V["upgrade_cost"], "up", x, None))
                    if "C1" in sk and not permit2 and pts >= V["permit_points_2"] and len(ships) < V["ship_cap"]:
                        dv = max(inc_now(ships + [new(r, False)]) - base for r in R2)
                        # a permit is useless without a ship there: judge permit + first ship together
                        if dv > 0 and cash >= V["permit_2_cost"] + V["ship_price"]: opts.append((dv / (V["permit_2_cost"] + V["ship_price"]), V["permit_2_cost"] + V["ship_price"], "permit", None, None))
                if strat in ("never", "sloppy") and not ships and cash >= V["ship_price"]:
                    buy_ship(ALL[0], False); continue
                if not opts: break
                opts.sort(key=lambda o: -o[0]); o = opts[0]; rem = V["win_cycle"] - c
                if o[0] * rem < 1.0 or cash < o[1]: break
                if o[2] == "route": buy_ship(o[3], o[4])
                elif o[2] == "permit": permit2 = True; cash -= V["permit_2_cost"]; pts -= V["permit_points_2"]; pool_routes = R1 + R2
                else: cash -= o[1]; o[3]["lv"] = 1
            if strat == "sloppy" and ships:   # overloaded: every spare ship goes on the same route
                while len(ships) < V["ship_cap"] and cash >= V["ship_price"]: buy_ship(ALL[0], False)
        cash += income(ships, sk, evp, ev)
        if trace: print(c, int(cash), len(ships), permit2)
        for x in ships: x["age"] += 1
        if RESCUE_ANY:
            if cash < V["trip_cost"] + V["maintenance"] // V["maintenance_interval"] and income(ships, sk) <= 0 and cash < V["win_cash"]: cash += V["rescue_stipend"]
        elif not ships and cash < V["ship_price"]: cash += V["rescue_stipend"]
        if cash >= V["win_cash"]: return c, cash, len(sk), pts, len(ships)
    return None, cash, len(sk), pts, len(ships)
LINES = [("decent no skills", "decent", "none"), ("decent logistics", "decent", "logistics"), ("decent research", "decent", "research"),
         ("decent expansion", "decent", "expansion"), ("decent permit only", "decent", "perm_only"), ("decent permit+research", "decent", "perm_research"),
         ("decent mixed L+R", "decent", "econ_mix"), ("decent full tree (ref)", "decent", "full"),
         ("sloppy overload", "sloppy", "none"), ("always expand", "always", "none"), ("always expand+C1", "always", "perm_only"),
         ("never expand", "never", "none")]
def main():
    a = sys.argv; mc = int(a[a.index("--mc") + 1]) if "--mc" in a else 0; seed = int(a[a.index("--seed") + 1]) if "--seed" in a else 1
    print("win_cash %d / %d cycles | order_amount %d cargo %d ship_cap %d | tree cost %d" % (V["win_cash"], V["win_cycle"], V["order_amount"], V["cargo"], V["ship_cap"], sum(cost(s) for s in TREE)))
    print("system 1 marginal net per ship N (best route each):", " ".join("%d:%s %.0f" % (i + 1, "".join(NAME[r[0]][0] + NAME[r[1]][0] + r[2][0] for r in [rr]), m) for i, (rr, m) in enumerate(marginal(None))))
    print("%-24s %8s %6s %7s %5s %5s" % ("line (no events)", "cash", "win_c", "skills", "pts", "ships"))
    for n, s, b in LINES:
        w, cash, ns, p, nr = run(s, b); print("%-24s %8d %6s %7d %5d %5d  %s" % (n, cash, w or "-", ns, p, nr, "WIN" if w else "loss"))
    if mc:
        print("\nevents, %d seeds: win%%, min / median / max win cycle" % mc)
        for n, s, b in LINES:
            ws = [run(s, b, random.Random(seed * 1000 + i))[0] for i in range(mc)]; w = [x for x in ws if x]
            print("%-24s %4.0f%%  %s" % (n, 100 * len(w) / mc, "%d / %d / %d" % (min(w), statistics.median(w), max(w)) if w else "-"))
if __name__ == "__main__": main()
