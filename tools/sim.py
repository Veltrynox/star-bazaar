#!/usr/bin/env python3
"""Star Bazaar route-model paper sim (replaces the old manual-trade sim).
Usage: python3 tools/sim.py [--mc N] [--seed S]     (run from repo root; ~1 s, --mc 50 ~ 5 s)
Reads data/balance.json + data/planets.json only. Prints one table of lines.
Model: a route = planet pair, 2 legs (buy at A sell at B, buy at B sell at A). Per ship per cycle net =
 (m1+m2)*cargo/(2*travel) - trip_cost/travel - maintenance/interval, each leg's sell price lowered by
 saturation*k for the k-th extra ship, floored at buy price. Route total <= 0 idles (pays 0).
Permit 2/3 each open one extra route (copy of Voltara-Tillam / Voltara-Ashgate) with margin x (1+permit_margin_bonus).
Buying happens at cycle start, income at cycle end; ships buy onto the best marginal route, only if marginal > 0
(except 'overload'). --mc N: N seeds of events (every event_interval cycles one random planet's sell prices
x(1 +/- U(pct)) for that interval) on best/decent/always_expand/never_expand."""
import json, random, sys, os, itertools, statistics

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V = json.load(open(os.path.join(ROOT, "data/balance.json")))["values"]
B = json.load(open(os.path.join(ROOT, "data/balance.json")))
PL = json.load(open(os.path.join(ROOT, "data/planets.json")))["planets"]
COMM = ["energy", "food"]

def starter_routes():
    """Pairs of planets that trade both ways: list of (a, b, [(buyprice, sellprice, sell_planet_idx)...])."""
    out = []
    for i, j in itertools.combinations(range(len(PL)), 2):
        legs = []
        for s, d in ((i, j), (j, i)):
            for c in COMM:
                b = PL[s]["base_prices"].get(c + "_buy"); p = PL[d]["base_prices"].get(c + "_sell")
                if b is not None and p is not None:
                    legs.append((b, p, d))
        if len(legs) == 2:
            out.append(legs)
    return out

BASE = starter_routes()

def route_legs(r, ev, bonus):
    """Legs of route r with event factor ev=(planet_idx, f) applied to sell prices, optional permit bonus."""
    legs = []
    for b, p, d in BASE[r % len(BASE)]:
        if ev and ev[0] == d:
            p = round(p * ev[1])
        if bonus:
            p = b + round((p - b) * (1 + V["permit_margin_bonus"]))
        legs.append((b, p))
    return legs

def ship_net(legs, k):
    g = sum(max(p - k * V["saturation"], b) - b for b, p in legs)
    t = V["travel_cycles_per_leg"]
    return g * V["cargo"] // (2 * t) - V["trip_cost"] // t - V["maintenance"] // V["maintenance_interval"]

def run(n2=99, n3=99, exp=False, never=False, single=False, over=False, events=None):
    cash = V["starting_credits"]; ships = 0; p = 0; alloc = []; ev = None
    for c in range(1, V["win_cycle"] + 1):
        if events is not None and (c - 1) % V["event_interval"] == 0:
            ev = (events.randrange(len(PL)), 1 + events.choice([-1, 1]) * events.uniform(*V["event_effect"]["pct"]))
        # route slots: 0,1 starter; 2 permit2; 3 permit3
        slots = [(0, False), (1, False)] if not (single or over) else [(0, False)]
        if p >= 1: slots.append((0, True))
        if p >= 2: slots.append((1, True))
        L = [route_legs(r, ev, b) for r, b in slots]
        alloc += [0] * (len(L) - len(alloc))
        while True:
            if never and ships >= 1: break
            if not (exp or single or over):
                if p == 0 and ships >= n2 and cash >= V["permit_2_cost"]:
                    cash -= V["permit_2_cost"]; p = 1; slots.append((0, True)); L.append(route_legs(0, ev, True)); alloc.append(0); continue
                if p == 1 and ships >= n3 and cash >= V["permit_3_cost"]:
                    cash -= V["permit_3_cost"]; p = 2; slots.append((1, True)); L.append(route_legs(1, ev, True)); alloc.append(0); continue
            if ships < V["ship_cap"] and cash >= V["ship_price"]:
                i = max(range(len(L)), key=lambda i: ship_net(L[i], alloc[i]))
                if not over and ship_net(L[i], alloc[i]) <= 0: break
                cash -= V["ship_price"]; ships += 1; alloc[i] += 1; continue
            break
        cash += sum(max(sum(ship_net(L[i], k) for k in range(alloc[i])), 0) for i in range(len(L)))
        if cash >= V["win_cash"]:
            return c, cash
    return None, cash

def best_policy():
    res = None
    for n2 in range(1, 9):
        for n3 in list(range(1, 9)) + [99]:
            w, cash = run(n2, n3)
            key = (w or 99, -cash)
            if res is None or key < res[0]: res = (key, n2, n3)
    return res[1], res[2]

LINES = lambda bp: [
    ("best", dict(n2=bp[0], n3=bp[1])), ("decent", dict(n2=3, n3=3)), ("decent late p3", dict(n2=3, n3=5)),
    ("never_expand", dict(never=True)), ("always_expand", dict(exp=True)),
    ("sloppy (1 route)", dict(single=True)), ("sloppy overload", dict(over=True))]

def main():
    mc = int(sys.argv[sys.argv.index("--mc") + 1]) if "--mc" in sys.argv else 0
    seed = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else 1
    bp = best_policy()
    print("win_cash %d / %d cycles | best policy: permit2 after %d ships, permit3 after %d" % (V["win_cash"], V["win_cycle"], bp[0], bp[1]))
    print("%-18s %10s %6s %-5s" % ("line", "final_cash", "win_c", "result"))
    for name, kw in LINES(bp):
        w, cash = run(**kw)
        print("%-18s %10d %6s %-5s" % (name, cash, w or "-", "WIN" if w else "loss"))
    if mc:
        print("\nevent Monte Carlo, %d seeds: win%%, median win cycle, wins before check_early_win_cycle" % mc)
        for name, kw in LINES(bp):
            if name.startswith("sloppy"): continue
            ws = [run(events=random.Random(seed * 1000 + s), **kw)[0] for s in range(mc)]
            w = [x for x in ws if x]
            print("%-18s %4.0f%% %6s %4d" % (name, 100 * len(w) / mc, statistics.median(w) if w else "-", sum(1 for x in w if x < B["targets"]["check_early_win_cycle"])))

if __name__ == "__main__":
    main()
