#!/usr/bin/env python3
"""Headless paper sim for Star Bazaar. Reads data/balance.json. Usage: sim.py [--verbose]
Assumptions: 1 route per system; each leg = 1 cycle, loaded both ways; margin = sell-buy;
saturation = margin x (1 - sat*(n-1)) [interpretation: UNKNOWN in GDD]; new systems margin x (1+permit_margin_bonus);
events averaged out (zero mean); cash may not buy below 0; win checked at end of cycle."""
import json, sys, os
B = json.load(open(os.path.join(os.path.dirname(__file__), "..", "data", "balance.json")))["values"]

def route_income(n, sysidx):
    """Net per-cycle income of n ships on the route in system sysidx (0-based), before maintenance."""
    if n == 0: return 0.0
    sell, buy = B["food_sell"], B["food_buy"]
    bonus = 1 + (B["permit_margin_bonus"] if sysidx > 0 else 0)
    # each ship: one leg per cycle, loaded both ways
    base = (sell - buy) * bonus
    margin = base * max(0.0, 1 - B["saturation"] * (n - 1))
    leg = margin * B["cargo"] - B["trip_cost"]
    return n * leg

def marginal(routes, i):
    r = list(routes); a = route_income(r[i], i); r[i] += 1
    return route_income(r[i], i) - a

def run(strategy):
    cash = B["starting_credits"] - 0
    systems = 1; routes = [0, 0, 0]; ships = 0
    log = {}
    # tutorial: player buys first ship at cycle 0
    def buy_ship():
        nonlocal cash, ships
        best = max(range(systems), key=lambda i: marginal(routes, i))
        routes[best] += 1; ships += 1; cash -= B["ship_price"]
    buy_ship()
    log["ship1"] = 0
    if strategy == "never_expand": pass
    for c in range(1, B["win_cycle"] + 1):
        cash += sum(route_income(routes[i], i) for i in range(3))
        if c % B["maintenance_interval"] == 0: cash -= B["maintenance"] * ships
        # decisions at end of cycle
        reserve = B["maintenance"] * ships  # keep cash to cover upkeep
        if strategy in ("optimal", "single_route", "always_expand"):
            while True:
                acted = False
                if strategy == "always_expand" and systems < 3:
                    cost = B["permit_2_cost"] if systems == 1 else B["permit_3_cost"]
                    if cash >= cost: cash -= cost; systems += 1; log[f"permit{systems}"] = c; acted = True; 
                    if acted: continue
                    break  # save for permit, no ships
                if strategy == "optimal" and systems < 3:
                    cost = B["permit_2_cost"] if systems == 1 else B["permit_3_cost"]
                    # buy permit when best ship slot gain is poor and permit affordable
                    gain_ship = max(marginal(routes, i) for i in range(systems))
                    if gain_ship < 0.6 * (B["food_sell"]-B["food_buy"]) * B["cargo"] - B["trip_cost"] and cash >= cost + reserve:
                        cash -= cost; systems += 1; log[f"permit{systems}"] = c; continue
                if ships < B["ship_cap"] and cash >= B["ship_price"] + (0 if ships < 2 else reserve * 0):
                    if strategy == "single_route":
                        routes[0] += 1; ships += 1; cash -= B["ship_price"]
                    else:
                        best = max(range(systems), key=lambda i: marginal(routes, i))
                        if marginal(routes, best) <= 0: break
                        routes[best] += 1; ships += 1; cash -= B["ship_price"]
                    log[f"ship{ships}"] = c; continue
                break
        if cash >= B["win_cash"]:
            return dict(strategy=strategy, final_cash=round(cash), win_cycle=c, ships=ships, log=log)
    return dict(strategy=strategy, final_cash=round(cash), win_cycle=None, ships=ships, log=log)

if __name__ == "__main__":
    for s in ("optimal", "single_route", "always_expand", "never_expand"):
        r = run(s); print(json.dumps(r))
