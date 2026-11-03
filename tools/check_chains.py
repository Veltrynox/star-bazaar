#!/usr/bin/env python3
"""Checks data/chains.json against data/balance.json. Run: python3 -I tools/check_chains.py"""
import json, sys, os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
c = json.load(open(os.path.join(R, 'data/chains.json')))
b = json.load(open(os.path.join(R, 'data/balance.json')))['values']
err = []
def key(k, where):
    if k not in b: err.append(f"{where}: missing balance key {k}")
def eff_keys(e, w):
    for f in ('key', 'cycles_key'):
        if f in e: key(e[f], w)
ids = [s['id'] for s in c['steps']]
if len(ids) != 28 or len(set(ids)) != 28: err.append('need 28 unique steps')
for m in ('mil', 'lux', 'min', 'bio'):
    ss = [s for s in c['steps'] if s['market'] == m]
    if sorted(s['id'][4:] for s in ss) != ['A1','A2','A3','B1','B2','B3','B4']: err.append(f'{m}: wrong step set')
    dirs = [s[o]['dir'] for s in ss for o in ('opt_a', 'opt_b')]
    if not (any(d > 0 for d in dirs) and any(d < 0 for d in dirs)): err.append(f'{m}: dir needs both signs')
    sa = sum(d for d in dirs if d > 0); sb = -sum(d for d in dirs if d < 0)
    print(m, 'plus', sa, 'minus', sb)
for s in c['steps']:
    w = s['id']
    ds = []
    for o in ('opt_a', 'opt_b'):
        if o not in s: err.append(f'{w}: missing {o}'); continue
        op = s[o]; ds.append(op['dir'])
        if not op['gets'] or not op['costs']: err.append(f'{w}.{o}: empty gets or costs')
        if not op['bot']: err.append(f'{w}.{o}: no bot effect (R-BOT)')
        for e in op['gets'] + op['costs'] + op['bot']: eff_keys(e, f'{w}.{o}')
        for e in op['bot']:
            if e['direction'] not in ('up', 'down') or e['stat'] not in ('strength', 'growth', 'tier'): err.append(f'{w}.{o}: bad bot effect')
            if e['stat'] == 'tier' and e['direction'] != 'down': err.append(f'{w}.{o}: tier must be cut')
    if len(ds) == 2 and (ds[0] > 0) == (ds[1] > 0): err.append(f'{w}: both options same sign')
    key(s['min_gap_key'], w)
    def walk(t):
        if 'any' in t:
            for x in t['any']: walk(x)
        for f in ('first_sale_after_cycle', 'share_pct', 'cycles_after_prev_step'):
            if f in t: key(t[f], w)
    walk(s['trigger'])
for k in ('dir_nudge_cap','dir_echo_mult','dir_swing_mult','dir_swing_min_abs','win_gate_cycle'):
    key(k, 'rules')
if len(c['pool_new']) != 12: err.append('pool_new must be 12')
for e in c['pool_new']:
    if not e['bot_effect']: err.append(e['id'] + ': no bot effect')
    eff_keys(e['effect'], e['id']);
    for x in e['bot_effect']: eff_keys(x, e['id'])
for k, e in c['pool_kept'].items():
    for x in e['bot_effect']: eff_keys(x, k)
if len(c['pool_kept']) != 24: err.append('pool_kept must be 24')
print('ERRORS' if err else 'OK'); [print(' ', x) for x in err]
sys.exit(1 if err else 0)
