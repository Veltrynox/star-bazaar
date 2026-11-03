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
--upg (with --real): lane cap stays, decent may buy one route upgrade (level 1) per ship.
--real: mirrors the build as of 2026-10-27 (one ship per lane, no upgrades, no permit); --inject=C:N adds N cash at cycle C (QA input). Lane-limited mode reproduces the QA bot (decent +1000: 8701).
Win: cash>=win_cash at cycle end. Loss: cycle win_cycle ends below. Rescue: no ships and cash<ship_price -> stipend."""
import json, os, re, random, statistics, sys, itertools, math
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
J = lambda p: json.load(open(os.path.join(R, p)))
V = J("data/balance.json")["values"]; PL = J("data/planets.json")["planets"]; EVS = J("data/events.json")
# 2026-11-03: the cash goal (win_cash, win_cycle) was removed from balance.json. This sim is now a plain "run to
# win_cycle_markets cycles, report cash" mode: win_cash is an unreachable sentinel so no run ever wins, and the
# win_c column shows "-". The real market-share model lives in game/markets.gd; the paper model is in
# design/proposals/2026-11-03-four-markets-economy.md. Old win-cycle targets no longer apply here.
V.setdefault("win_cycle", V["win_cycle_markets"]); V.setdefault("win_cash", 10 ** 12)
GOODS = "--goods" in sys.argv; REAL = "--real" in sys.argv; UPG = "--upg" in sys.argv; RESCUE_ANY = "--rescue-any" in sys.argv; INJ = (0, 0)
for _a in sys.argv:
    if _a.startswith("--inject="): INJ = tuple(int(x) for x in _a[9:].split(":"))
    if _a.startswith("--set="):
        for kv in _a[6:].split(","): k, v = kv.split("="); V[k] = float(v) if "." in v else int(v)
S2 = J("tools/system2.json")["planets"]
NAME = [p["name"] for p in PL]
for p in PL: p["system"] = 1
PL = PL + S2          # indices 0-2 system 1, 3-6 system 2
# T153 --goods: silk/chips/ore from planets.json + tools/system2.json base_prices; ore clusters are virtual sources (ore_buy 0, finite, need skill B1).
# cluster counts/richness/yield from balance.json (mining_*). Cluster x,y are placeholders (galaxy-builder places real ones in T157).
CL = []
if GOODS:
    for sy, n, sink in ((1, int(V["mining_clusters_s1"]), None), (2, int(V["mining_clusters_s2"]), None)):
        for i in range(n): CL.append({"id": "cl%d_%d" % (sy, i), "name": "Cluster%d%d" % (sy, i), "system": sy, "x": 0, "y": 0, "base_prices": {"ore_buy": 0}, "cluster": True})
    PL = PL + CL
REM = {i: V.get("mining_cluster_richness", 0) for i, p in enumerate(PL) if p.get("cluster")}
STOP_PX = 40.0        # N9: mirrors route_engine.gd STOP_PATH_PX (map px from the src-dst line)
if "--stop-fixture" in sys.argv: PL[2]["x"], PL[2]["y"] = 0, 80  # test only: Ashgate moved onto the Voltara-Tillam line
def on_path(s, k, d):
    """N9: stop k lies strictly between s and d, within STOP_PX of their straight line (mirrors stop_on_path)."""
    if len({s, k, d}) < 3: return False
    ax, ay = PL[s]["x"], PL[s]["y"]; bx, by = PL[d]["x"] - ax, PL[d]["y"] - ay
    px, py = PL[k]["x"] - ax, PL[k]["y"] - ay; L2 = bx * bx + by * by
    t = (px * bx + py * by) / L2
    return 0 < t < 1 and math.hypot(px - t * bx, py - t * by) <= STOP_PX
STOPS = [(r, k) for r in [] for k in []]  # filled below once R1 exists
def parse(e):
    m = re.match(r"\[(price (?:up|down)): (\w+), (\w+)\]", e["tag"])
    if m: return (m.group(1), NAME.index(m.group(2)), m.group(3)) if m.group(2) in NAME else None  # dead worlds (Greywake) are not in the sim
    m = re.match(r"\[planet closed: (\w+)\]", e["tag"])
    return ("closed", NAME.index(m.group(1)), None) if m and m.group(1) in NAME else None
EVT = [x for x in map(parse, EVS) if x]
if GOODS:  # EV21-EV25, EV28 price swings (T154 writes text; EV26/EV27 not modelled)
    EVT += [("price up", 1, "silk"), ("price up", 0, "silk"), ("price down", 1, "silk"), ("price up", 0, "chips"), ("price up", 2, "chips"), ("price up", 0, "ore")]
COMM = ["energy", "food"] + (["silk", "chips", "ore"] if GOODS else [])
def routes_in(sysn):
    ix = [i for i, p in enumerate(PL) if p["system"] == sysn]
    return [(s, d, c) for s in ix for d in ix if s != d for c in COMM
            if (c + "_buy") in PL[s]["base_prices"] and PL[d]["base_prices"].get(c + "_sell") and not PL[d].get("cluster")
            and PL[d]["base_prices"][c + "_sell"] > PL[s]["base_prices"][c + "_buy"]]
_R1, _R2 = routes_in(1), routes_in(2)
isc = lambda r: bool(PL[r[0]].get("cluster"))
R1, R2 = [r for r in _R1 if not isc(r)], [r for r in _R2 if not isc(r)]
RC1, RC2 = [r for r in _R1 if isc(r)], [r for r in _R2 if isc(r)]
STOPS = [(r, k) for r in R1 for k in range(3) if on_path(r[0], k, r[1]) and PL[k]["base_prices"].get(r[2] + "_sell")]  # N9 stop options, system 1
ALL = R1
def pair(r): return frozenset((r[0], r[1]))
TREE = {"A1": None, "A2": "A1", "A4": "A2", "A5": "A4", "B1": None, "B2": "B1", "B3": "B2", "B4": "B3",
        "C1": None, "C2": "C1", "C3": "C2", "C4": "C2"}
def cost(s): return V["skill_cost_" + s]
BUILDS = {
 "none": [], "logistics": ["A1", "A2", "A4", "A5"], "research": ["B1", "B2", "B3", "B4"],
 "expansion": ["C1", "C2", "C3", "C4"], "econ_mix": ["B1", "B2", "A1", "A2", "B3", "A4", "A5", "B4"],
 "log_first": ["A1", "A2", "A4", "B1", "B2", "A5", "B3", "B4"],
 "perm_only": ["C1"], "mining": ["B1"], "perm_research": ["C1", "B1", "B2", "B3", "B4"],
 "full": list(TREE)}
def margin(r, sk, ev, lv):
    s, d, c = r; buy = PL[s]["base_prices"][c + "_buy"]; sell = PL[d]["base_prices"][c + "_sell"]
    for (k, p, cc), _ in ev:
        if cc == c and k != "closed":
            f = 1 + V.get("event_pct_" + c, V["event_price_pct"]) * (1 if k == "price up" else -1)
            if p == s: buy *= f
            if p == d: sell *= f
    return (sell - buy) * (1 + V["skill_B3_margin"] * ("B3" in sk)) * (1 + V["upgrade_margin_bonus"] * lv)
def ship_stats(x, sk):
    h = x["h"]
    ru = V["cargo"] / (2 * V["travel_cycles_per_leg"]) * (1 + V["skill_A4_route_units"] * ("A4" in sk))
    up = (V["trip_cost"] + V["maintenance"] / V["maintenance_interval"]) * (1 - V["skill_A5_upkeep"] * ("A5" in sk))
    if x.get("stop") is not None: ru /= 2; up += V["trip_cost"]  # N9: one more leg (half the units) and one more trip cost
    return ru, up
def blocked(r, ev, sk):
    for (k, p, c), left in ev:
        if k == "closed" and p in (r[0], r[1]):
            cov = ("A1" in sk) + ("A2" in sk) + ("B4" in sk)
            if left > cov: return True
    return False
def income(ships, sk, evp=(), ev=(), detail=False, split=0, bun=False, consume=False):
    """steady-state net per cycle of all ships (age>=1, not blocked) with shared order pools.
    split (N2): 0 = off; else a source with two lanes gives the higher-margin lane `split` of its buy pool, the other lane 1 - split."""
    A = V["order_amount"] * (1 + V["skill_B2_order_units"] * ("B2" in sk))
    pool = {}
    items = []
    for x in ships:
        if x["age"] < 1 or blocked(x["r"], ev, sk): continue
        ru, up = ship_stats(x, sk); items.append((margin(x["r"], sk, evp, x["lv"]), ru, up, x))
    items.sort(key=lambda t: -t[0]); tot = 0; per = []; rev = {}
    lanes = {}  # (source, c) -> destinations in margin order
    for m, ru, up, x in items:
        lst = lanes.setdefault((x["r"][0], x["r"][2]), [])
        if x["r"][1] not in lst: lst.append(x["r"][1])
    for m, ru, up, x in items:
        s, d, c = x["r"]; lim = ru
        if x.get("stop") is not None:  # N9 stop: sells up to order amount A at the stop (base prices, own pool-free), carries the rest on
            k = x["stop"]; f = min(lim, pool.setdefault(("b", s, c), A)); sold = min(f, A)
            rest = min(f - sold, pool.setdefault(("s", d, c), A)); bought = sold + rest
            net = sold * PL[k]["base_prices"][c + "_sell"] + rest * PL[d]["base_prices"][c + "_sell"] - bought * PL[s]["base_prices"][c + "_buy"] - up
            if net <= 0: per.append(0); continue
            pool[("b", s, c)] -= bought; pool[("s", d, c)] -= rest; tot += net; per.append(net)
            continue
        if split and len(lanes[(s, c)]) >= 2:  # N2: split Send, fixed share of the source pool per lane
            lim = min(ru, A * (split if lanes[(s, c)][0] == d else 1 - split))
        if PL[s].get("cluster"): pool.setdefault(("b", s, c), min(REM[s], V["mining_yield_per_cycle"]))
        f = min(lim, pool.setdefault(("b", s, c), A), pool.setdefault(("s", d, c), A))
        net = f * m - up
        if net <= 0: per.append(0); continue
        pool[("b", s, c)] -= f; pool[("s", d, c)] -= f; tot += net; per.append(net)
        rev.setdefault(d, {}); rev[d][c] = rev[d].get(c, 0) + f * PL[d]["base_prices"][c + "_sell"]
    if consume:
        for (t, s_, c_), left in pool.items():
            if t == "b" and PL[s_].get("cluster"): REM[s_] = max(0, REM[s_] - (min(REM[s_], V["mining_yield_per_cycle"]) - left))
    if bun:  # N3 Mixed load: bonus on the 2nd and later distinct good sold at one planet in one cycle, capped per planet per cycle
        for d, g in rev.items():
            if len(g) >= 2: tot += min(V["bundle_bonus_cap"], V["bundle_bonus_pct"] * (sum(g.values()) - max(g.values())))
    return (tot, per) if detail else tot
def marginal(route, nmax=10, sk=frozenset()):
    """system-1 table: net income added by the Nth ship, ships added greedily to the best marginal route"""
    ships = []; out = []; prev = 0
    for n in range(nmax):
        best = max(R1, key=lambda r: income(ships + [{"r": r, "lv": 0, "h": False, "age": 1}], sk))
        ships.append({"r": best, "lv": 0, "h": False, "age": 1}); t = income(ships, sk); out.append((best, t - prev)); prev = t
    return out
def run(strat="decent", build="none", rng=None, trace=False):
    # N3: "bundle" = decent whose income adds the Mixed load bonus (bundle_bonus_pct, bundle_bonus_cap), ships picked with the bonus counted
    # N2: "split" buys like decent and splits each two-lane source half and half; "split34" gives 3/4 to the higher-margin lane
    DEC = strat in ("decent", "split", "split34", "bundle", "stop", "mining_focus"); MF = strat == "mining_focus"; BUN = strat == "bundle"; SPL = {"split": 0.5, "split34": 0.75}.get(strat, 0)
    for k_ in REM: REM[k_] = V.get("mining_cluster_richness", 0)
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
        if MF:   # T160: a ship on an emptied cluster is sent to the best core route (a player would do this)
            for x in ships:
                if isc(x["r"]) and REM.get(x["r"][0], 0) * 11 <= V["trip_cost"]:   # left ore cannot pay a trip
                    x["r"] = max(R1 + (R2 if permit2 else []), key=lambda r: income([new(r, False)], sk))
        def price(h): return V["ship_price"]
        def inc_now(sh): return income(sh, sk, split=SPL, bun=BUN)
        def new(r, h, lv=0, k=None): return {"r": r, "lv": lv, "h": h, "age": 1, "stop": k}
        def buy_ship(r, h, k=None):
            nonlocal cash, pts
            cash -= price(h); ships.append({"r": r, "lv": 0, "h": h, "age": 0, "stop": k})
            for p in (r[0], r[1]):
                if p not in seen:
                    seen.add(p); pts += V["skill_points_planet"]
                    sy = PL[p]["system"]
                    if sy != 1 and sy not in sysp: sysp.add(sy); pts += V["skill_points_system"]
            if pair(r) not in pairs: pairs.add(pair(r)); pts += V["skill_points_route"]
            learn()
        pool_routes = R1 + (R2 if permit2 else []) + ((RC1 + (RC2 if permit2 else [])) if "B1" in sk else [])
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
                if DEC and len(ships) < V["ship_cap"]:
                    for r in pool_routes:
                        if REAL and any(x["r"] == r for x in ships): continue
                        for h in ([False]):
                            dv = inc_now(ships + [new(r, h)]) - base
                            if dv > 0: opts.append((dv / price(h), price(h), "route", r, h, None))
                    if strat == "stop":  # N9: a route with one stop on the way is an option next to the direct one
                        for r, k in STOPS:
                            dv = inc_now(ships + [new(r, False, 0, k)]) - base
                            if dv > 0: opts.append((dv / price(False), price(False), "route", r, False, k))
                if DEC and (not REAL or UPG):
                    for x in ships:
                        if x["lv"] < 1:
                            x["lv"] = 1; dv = inc_now(ships) - base; x["lv"] = 0
                            if dv > 0: opts.append((dv / V["upgrade_cost"], V["upgrade_cost"], "up", x, None, None))
                    if "C1" in sk and not permit2 and pts >= V["permit_points_2"] and len(ships) < V["ship_cap"]:
                        dv = max(inc_now(ships + [new(r, False)]) - base for r in R2)
                        # a permit is useless without a ship there: judge permit + first ship together
                        if dv > 0 and cash >= V["permit_2_cost"] + V["ship_price"]: opts.append((dv / (V["permit_2_cost"] + V["ship_price"]), V["permit_2_cost"] + V["ship_price"], "permit", None, None, None))
                if strat in ("never", "sloppy") and not ships and cash >= V["ship_price"]:
                    buy_ship(ALL[0], False); continue
                if not opts: break
                opts.sort(key=lambda o: ((0 if (MF and o[2] == "route" and isc(o[3])) else 1), -o[0])); o = opts[0]; rem = V["win_cycle"] - c  # T160 mining_focus: cluster routes first
                if o[0] * rem < 1.0 or cash < o[1]: break
                if o[2] == "route": buy_ship(o[3], o[4], o[5])
                elif o[2] == "permit": permit2 = True; cash -= V["permit_2_cost"]; pts -= V["permit_points_2"]; pool_routes = R1 + R2 + (RC1 + RC2 if "B1" in sk else [])
                else: cash -= o[1]; o[3]["lv"] = 1
            if strat == "sloppy" and ships:   # overloaded: every spare ship goes on the same route
                while len(ships) < V["ship_cap"] and cash >= V["ship_price"]: buy_ship(ALL[0], False)
        cash += income(ships, sk, evp, ev, split=SPL, bun=BUN, consume=True)
        if trace: print(c, int(cash), len(ships), permit2)
        for x in ships: x["age"] += 1
        if RESCUE_ANY:
            if cash < V["trip_cost"] + V["maintenance"] // V["maintenance_interval"] and income(ships, sk) <= 0 and cash < V["win_cash"]: cash += V["rescue_stipend"]
        elif not ships and cash < V["ship_price"]: cash += V["rescue_stipend"]
        if cash >= V["win_cash"]: return c, cash, len(sk), pts, len(ships)
    return None, cash, len(sk), pts, len(ships)

# ---------------------------------------------------------------------------------------------
# --settle: ENGINE MIRROR (2026-11-02 alpha-economy). Mirrors game/route_engine.gd settle() and qa/bots/bot_run.gd:
#   cycle start: events, bot decide (ship, skills, permit, lanes, orders; cash row is read here), then settle:
#   1 Buys (n = min(order, space, floor((cash - route_reserve) / price))), 2 routes (fixed cost paid from cash, stock moves),
#   3 Sells (min(order, stock) at sold price, Mixed load bonus). One ship per lane (one route per src,dst,c).
#   Planets: system 1 = data/planets.json, system 2 = data/systems.json (after the permit). Goods: energy, food; ore from clusters (needs B1).
#   NOT modelled (UNKNOWN effect, all lower income): event fees (EV17/18/20 paid by the bot), skill cover of closures, A3/A1 storage uses,
#   shield/pirate/debris, route-removal churn on full storage. Event prices use rounded factor like trade.price().
# Run: python3 tools/sim.py --settle [--mc 200] [--seed 1] [--trace=decent]
# ---------------------------------------------------------------------------------------------
SYS2 = J("data/systems.json")["systems"][0]["planets"]
MP = [dict(p, system=1) for p in J("data/planets.json")["planets"]] + [dict(p, system=2) for p in SYS2]
MN = [p["name"] for p in J("data/planets.json")["planets"]] + [p["id"] for p in SYS2]
MCOMM = ["energy", "food"]
MEV = []   # every event of events.json; the ones the game cannot price (silk, chips, fees, choices) are no-ops here (UNKNOWN fees)
for _e in EVS:
    _m = re.match(r"\[(price (?:up|down)): (\w+), (\w+)\]", _e["tag"])
    if _m and _m.group(2) in MN[:3] and _m.group(3) in ("energy", "food", "ore"): MEV.append((_m.group(1), MN.index(_m.group(2)), _m.group(3)))
    else:
        _m = re.match(r"\[planet closed: (\w+)\]", _e["tag"])
        _t = _e["tag"]
        MEV.append(("closed", MN.index(_m.group(1)), None) if _m and _m.group(1) in MN[:3] else
                   ("fee", -1, "debris_clear_fee") if "route efficiency" in _t else ("fee", -1, "shield_build_cost") if "shield" in _t else
                   ("fee", -1, "asteroid_deflect_cost") if "asteroid" in _t else ("noop", -1, None))
MTREE = {"A1": [], "A2": ["A1"], "A4": ["A2"], "A5": ["A4"], "B1": [], "B2": ["B1"], "B3": ["B2"], "B4": ["B3"], "C1": [], "C2": ["C1"], "C3": ["C2", "A1"], "C4": ["C2"]}
MORDER = list(MTREE)
CLUS = [(1, i) for i in range(int(V["mining_clusters_s1"]))] + [(2, i) for i in range(int(V["mining_clusters_s2"]))]
def mirror(strat="decent", rng=None, trace=False, permit=None, noevents=False, sched=None):
    """returns dict(win, cash, ships, buys=[(cycle, n)], rows={cycle: cash at decide})"""
    if permit is None: permit = strat in ("decent", "mining_focus", "always_expand", "never_expand+permit")
    MF = strat == "mining_focus"; AE = strat == "always_expand"; SL = strat == "sloppy"; NV = strat.startswith("never_expand")
    cash = V["starting_credits"]; ships = 0; routes = []; local = {}; stock = {}; skills = set(); pts = 0; pp = set(); pairs = set()
    opened = [1]; sysreached = {1}; ev = []; buys = []; rows = {}; locked = None; skipB1 = not MF
    clusters = {}   # (sys,i) -> left
    for k in CLUS: clusters[k] = V["mining_cluster_richness"]
    budget = {}; permit_c = None
    order_pref = ["C1"] if not AE else ["C1", "C3", "A1", "A2"]
    if MF: order_pref = ["B1"]
    def award_planet(p):
        nonlocal pts
        if p in pp: return
        pp.add(p); pts += V["skill_points_planet"]
    def award_route(a, b):
        nonlocal pts
        award_planet(a); award_planet(b)
        k = (min(a, b), max(a, b))
        if k not in pairs: pairs.add(k); pts += V["skill_points_route"]
        for p in (a, b):
            sy = MP[p]["system"]
            if sy not in sysreached: sysreached.add(sy); pts += V["skill_points_system"]
    award_planet(0)
    def nplanets(): return 3 + (4 if 2 in opened else 0)
    def popen(p): return not any(k == "closed" and q == p for (k, q, _), l in ev)
    def price(p, key):
        v = MP[p]["base_prices"].get(key)
        if v is None: return -1
        f = 1.0; c = key.rsplit("_", 1)[0]
        for (k, q, cc), l in ev:
            if k != "closed" and q == p and cc == c: f *= 1 + V.get("event_pct_" + c, V["event_price_pct"]) * (1 if k == "price up" else -1)
        return max(0, int(round(v * f))) if ev else int(v)
    def sold(p, c):
        v = price(p, c + "_sell")
        return int(round(v * (1 + V["skill_B3_margin"]))) if v > 0 and "B3" in skills else v
    def upc(): return math.floor(V["cargo"] / (2.0 * V["travel_cycles_per_leg"]) * (1 + V["skill_A4_route_units"] * ("A4" in skills)))
    def lamt(): return math.floor(V["order_amount"] * (1 + V["skill_B2_order_units"] * ("B2" in skills)))
    def fixed(): return math.floor(V["trip_cost"] / V["travel_cycles_per_leg"]) + math.floor(V["maintenance"] * (1 - V["skill_A5_upkeep"] * ("A5" in skills)) / V["maintenance_interval"])
    def cap(): return int(round(100 * (1 + V["skill_A2_capacity"] * ("A2" in skills))))
    def amt(p, c): return stock.get((p, c), 0)
    def add(p, c, n):
        n = max(0, min(n, cap() - amt(p, c))); stock[(p, c)] = amt(p, c) + n; return n
    def rem(p, c, n):
        n = max(0, min(n, amt(p, c))); stock[(p, c)] = amt(p, c) - n; return n
    def ranked():
        out = []; u = min(lamt(), upc()); fx = fixed()
        for c in MCOMM:
            for a in range(nplanets()):
                for b in range(nplanets()):
                    if a == b or not popen(a) or not popen(b): continue
                    bp = price(a, c + "_buy"); sp = price(b, c + "_sell")
                    if bp <= 0 or sp < 0: continue
                    if MP[a]["system"] != MP[b]["system"] and "C3" not in skills: continue
                    pr = (sp - bp) * u - fx
                    if pr * 10 >= V["ship_price"]: out.append({"a": a, "b": b, "c": c, "profit": pr})
        out.sort(key=lambda x: -x["profit"]); return out
    def cluster_lanes():
        out = []; u = min(upc(), V["mining_yield_per_cycle"]); fx = fixed()
        for k in CLUS:
            if k[0] not in opened or clusters[k] <= 0: continue
            best = None
            for b in range(nplanets()):
                if not popen(b): continue
                if MP[b]["system"] != k[0] and "C3" not in skills: continue
                sp = price(b, "ore_sell")
                if sp <= 0: continue
                pr = sp * u - fx
                if pr > 0 and (best is None or pr > best["profit"]): best = {"a": ("cl",) + k, "b": b, "c": "ore", "profit": pr}
            if best: out.append(best)
        out.sort(key=lambda x: -x["profit"]); return out
    def plan():
        rk = ranked(); capn = max(1, int(V["ship_cap"]))
        if SL:
            nonlocal locked
            if locked is None and rk: locked = rk[0]
            return [] if locked is None else [locked]
        if NV: return rk[:1]
        if MF:
            out = (cluster_lanes() if "B1" in skills else []) + rk
            return out[:capn]
        return rk[:capn]
    def find(a, b, c):
        for r in routes:
            if r["a"] == a and r["b"] == b and r["c"] == c: return r
        return None
    def buy_wanted(a, c):
        if isinstance(a, tuple): return False
        if SL: return True
        u = min(lamt(), upc()); bp = price(a, c + "_buy")
        return amt(a, c) < u and cash >= fixed() + max(bp, 1)
    def set_order(p, c, role, on):
        k = (p, c); o = local.get(k)
        if on:
            if o is None: o = local[k] = {"buy": False, "sell": False}
            o[role] = True
        elif o is not None:
            o[role] = False
            if not o["buy"] and not o["sell"]: del local[k]
    def src_avail(r):
        if isinstance(r["a"], tuple):
            k = r["a"][1:]; return min(clusters[k], budget.get(k, V["mining_yield_per_cycle"]))
        return amt(r["a"], r["c"])
    def space(p, c): return cap() - amt(p, c)
    def outflow(b, c):
        if local.get((b, c), {}).get("sell"): return True
        return any(r["a"] == b and r["c"] == c for r in routes)
    def rlive(r): return (isinstance(r["a"], tuple) or popen(r["a"])) and popen(r["b"])
    def buy_feeds(p, c, afford):
        o = local.get((p, c))
        if not o or not o["buy"] or not popen(p) or price(p, c + "_buy") < 0: return False
        return afford >= price(p, c + "_buy") and space(p, c) > 0
    def reserve(cs):
        left = cs; total = 0
        for r in routes:
            if not rlive(r): continue
            if space(r["b"], r["c"]) <= 0: continue
            have = src_avail(r)
            fx = fixed()
            if not isinstance(r["a"], tuple) and have <= 0 and buy_feeds(r["a"], r["c"], left - fx): have = 1
            if have <= 0 or left < fx: continue
            left -= fx; total += fx
        return total
    for c in range(1, V["win_cycle"] + 1):
        ev = [(e, l - 1) for e, l in ev if l > 1]
        if sched is not None:
            for e in sched.get(c, []): ev.append((e, V["event_close_cycles"] if e[0] == "closed" else V["event_price_cycles"]))
        elif not noevents and rng and c > 1 and c % V["event_interval"] == 1 and rng.random() < 0.88:
            e = rng.choice(MEV)
            if e[0] == "fee":   # bot answers with the first enabled choice = the paying one, when it can pay (EV18 only from cycle 10)
                if V[e[2]] <= cash and not (e[2] == "shield_build_cost" and c < 10): cash -= V[e[2]]
            else: ev.append((e, V["event_close_cycles"] if e[0] == "closed" else V["event_price_cycles"]))
        # ---- bot decide
        if ships == 0: cash -= V["ship_price"]; ships += 1; buys.append((c, ships))
        if AE:
            while ships < V["ship_cap"] and cash >= V["ship_price"] + V.get("buy_gate", 0): cash -= V["ship_price"]; ships += 1; buys.append((c, ships))
        if not SL:
            ids = order_pref + MORDER; again = True
            while again:
                again = False
                for s in ids:
                    if s in skills or (s == "B1" and skipB1) or (s == "B1" and False): continue
                    if any(q not in skills for q in MTREE[s]): continue
                    if s not in ("A1", "C1") and not ("A1" in skills and "C1" in skills): continue   # owner 2026-11-02: first row gates the rest
                    res = (V["permit_points_2"] - ("C2" in skills) if (permit and "C1" in skills and 2 not in opened) else 0)
                    if pts - cost(s) < 0 or (res and pts - cost(s) < res): continue
                    pts -= cost(s); skills.add(s); again = True; break
        if permit and 2 not in opened and "C1" in skills:
            pc = math.floor(V["permit_2_cost"] * (1 - V["skill_C4_permit_discount"] * ("C4" in skills))); ppnt = max(1, V["permit_points_2"] - ("C2" in skills))
            if pts >= ppnt and cash >= pc and cash >= pc + 400: cash -= pc; pts -= ppnt; opened.append(2); permit_c = c
        pl = plan()
        def missing(): return sum(1 for l in pl if find(l["a"], l["b"], l["c"]) is None)
        if not (AE or NV) or NV:
            pass
        if strat in ("decent", "mining_focus"):
            while missing() > ships - len(routes) and cash - V["ship_price"] >= V.get("buy_gate", 0) and ships < V["ship_cap"]:
                cash -= V["ship_price"]; ships += 1; buys.append((c, ships))
        elif AE:
            while missing() > ships - len(routes) and cash >= V["ship_price"] + V.get("buy_gate", 0) and ships < V["ship_cap"]:
                cash -= V["ship_price"]; ships += 1; buys.append((c, ships))
        elif SL:
            if missing() > ships - len(routes) and cash >= V["ship_price"] and ships < V["ship_cap"]: cash -= V["ship_price"]; ships += 1; buys.append((c, ships))
        # sync lanes
        if not SL:
            for r in list(routes):
                keep = any(l["a"] == r["a"] and l["b"] == r["b"] and l["c"] == r["c"] for l in pl) and amt(r["b"], r["c"]) < cap()
                if not keep: routes.remove(r)
        active = []
        for l in pl:
            if find(l["a"], l["b"], l["c"]) is None:
                if ships - len(routes) <= 0 or amt(l["b"], l["c"]) >= cap(): continue
                routes.append({"a": l["a"], "b": l["b"], "c": l["c"]}); award_route(l["a"] if not isinstance(l["a"], tuple) else l["b"], l["b"])
            active.append(l)
        want = []
        for l in active:
            if buy_wanted(l["a"], l["c"]): want.append((l["a"], l["c"], "buy"))
            want.append((l["b"], l["c"], "sell"))
        for (p, cc), o in list(local.items()):
            for role in ("buy", "sell"):
                if o[role] and (p, cc, role) not in want: set_order(p, cc, role, False)
        for (p, cc, role) in want: set_order(p, cc, role, True)
        rows[c] = int(cash)
        # ---- settle
        delta = 0; la = lamt(); budget = {}
        for (p, cc), o in list(local.items()):
            if o["buy"]:
                pr = price(p, cc + "_buy")
                if pr < 0 or not popen(p): continue
                n = min(la, space(p, cc))
                if pr > 0: n = min(n, math.floor(max(cash + delta - reserve(cash + delta), 0) / pr))
                if n > 0: n = add(p, cc, n); delta -= n * pr
        for r in routes:
            if not rlive(r): continue
            full = amt(r["b"], r["c"]) >= cap()
            if full and not outflow(r["b"], r["c"]): continue
            if src_avail(r) <= 0 or full: continue
            fx = fixed()
            if cash + delta < fx: continue
            mv = min(upc(), src_avail(r), space(r["b"], r["c"]))
            if mv <= 0: continue
            delta -= fx; r["mv"] = (c, mv)
            if isinstance(r["a"], tuple):
                k = r["a"][1:]; clusters[k] -= mv; budget[k] = budget.get(k, V["mining_yield_per_cycle"]) - mv
            else: rem(r["a"], r["c"], mv)
            add(r["b"], r["c"], mv)
        mixed = {}
        for (p, cc), o in list(local.items()):
            if o["sell"]:
                pr = sold(p, cc)
                if pr < 0 or not popen(p): continue
                n = rem(p, cc, la)
                if n <= 0: continue
                rev = n * pr; g, b_ = mixed.get(p, (0, 0))
                if g >= 1: bon = max(0, min(math.floor(rev * V["bundle_bonus_pct"]), V["bundle_bonus_cap"] - b_)); rev += bon; b_ += bon
                mixed[p] = (g + 1, b_); delta += rev
        cash += delta
        # main._check_stranded: cash below one route's fixed cost, no income or no route ran, no Sell order with stock -> rescue_stipend
        ran = any(rlive(r) for r in routes) and delta != 0
        sellable = any(o["sell"] and amt(p, cc) > 0 for (p, cc), o in local.items())
        if ships == 0 and cash < V["ship_price"] or (cash < fixed() and (delta <= 0 or not ran) and not sellable): cash += V["rescue_stipend"]
        if trace: print(c, int(cash), ships, [(r["a"], r["b"], r["c"], r.get("mv", (0, 0))[1] if r.get("mv", (0, 0))[0] == c else 0) for r in routes], pts, "delta", delta, {k: v for k, v in stock.items() if v}, {k: dict(v) for k, v in local.items()})
        if cash >= V["win_cash"]: return {"win": c, "cash": cash, "ships": ships, "buys": buys, "rows": rows, "permit": permit_c}
    return {"win": None, "cash": cash, "ships": ships, "buys": buys, "rows": rows, "permit": permit_c}
def real_sched(row):
    """event schedule of one QA run row (event_rows: [cycle, id, up|down|closed, planet, commodity, left, elapsed])"""
    out = {}
    for r in row["event_rows"]:
        for x in r["active"]:
            if x[6] == 0: out.setdefault(x[0], []).append(("closed" if x[2] == "closed" else "price " + x[2], x[3], x[4] or None))
    return out
def compare(path):
    """mirror vs real QA runs (same events as the real run): ship buys and cash at decide-time rows 3 and 10"""
    print("%-14s %4s | real ship3/4/5 | mirror ship3/4/5 | real cash r3 r10 end | mirror r3 r10 end" % ("strategy", "seed"))
    for l in open(path):
        d = json.loads(l); st = d["clock_tag"]
        m = mirror(st, None, sched=real_sched(d))
        rb = {n: c for c, _, n in d["ship_buys"]}; mb = {n: c for c, n in m["buys"]}
        cb = dict(d["cash_by_cycle"])
        print("%-14s %4d | %s | %s | %s %s %s | %s %s %s" % (st, d["seed"], "/".join(str(rb.get(n, "-")) for n in (3, 4, 5)), "/".join(str(mb.get(n, "-")) for n in (3, 4, 5)),
              d["cash_rows_3_8"][0][1], cb.get(9), d["final_cash"], m["rows"].get(3), m["rows"].get(10), int(m["cash"])))
def main_settle(a):
    if "--compare" in a: return compare(a[a.index("--compare") + 1])
    mc = int(a[a.index("--mc") + 1]) if "--mc" in a else 200; seed = int(a[a.index("--seed") + 1]) if "--seed" in a else 1
    print("settle mirror: win_cash %d / %d cycles, start %d, %d seeds (QA seeds 1-8 differ: the game has no RNG, events come from the bot's seed)" % (V["win_cash"], V["win_cycle"], V["starting_credits"], mc))
    only = [x[7:] for x in a if x.startswith("--only=")]
    for st in ("decent", "mining_focus", "always_expand", "sloppy", "never_expand", "never_expand+permit"):
        if only and st not in only[0].split(","): continue
        rs = [mirror(st, random.Random(seed * 1000 + i)) for i in range(mc)]
        w = [r["win"] for r in rs if r["win"]]; s3 = [next((c for c, n in r["buys"] if n == 3), 31) for r in rs]
        c3 = [r["rows"].get(3, 0) for r in rs]
        print("%-14s win %3.0f%%  win cycle min/med/max %s  ship3 median cycle %s  cash row3 median %s  end cash median %d  ships median %s" % (
            st, 100 * len(w) / mc, "%d/%d/%d" % (min(w), statistics.median(w), max(w)) if w else "-", statistics.median(s3), statistics.median(c3),
            statistics.median([r["cash"] for r in rs]), statistics.median([r["ships"] for r in rs])))

LINES = [("decent no skills", "decent", "none"), ("decent logistics", "decent", "logistics"), ("decent research", "decent", "research"),
         ("decent expansion", "decent", "expansion"), ("decent permit only", "decent", "perm_only"), ("decent permit+research", "decent", "perm_research"),
         ("decent mixed L+R", "decent", "econ_mix"), ("decent full tree (ref)", "decent", "full"), ("decent B1 only (mining)", "decent", "mining"), ("mining_focus (B1, clusters first)", "mining_focus", "mining"),
         ("split half and half", "split", "none"), ("split 3/4 and 1/4", "split34", "none"), ("bundle (N3, capped)", "bundle", "none"),
         ("decent + stop (N9)", "stop", "none"), ("sloppy overload", "sloppy", "none"), ("always expand", "always", "none"), ("always expand+C1", "always", "perm_only"),
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
if __name__ == "__main__":
    if "--settle" in sys.argv:
        t = [x for x in sys.argv if x.startswith("--trace=")]
        if t: mirror(t[0][8:], random.Random(1), trace=True)
        else: main_settle(sys.argv)
    else: main()
