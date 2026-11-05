# Skill tree round 2 (economy-designer, 2026-11-05)

Input: QA skill-final review (REJECT MIL_3, 17 CONCERN/NOT FELT, BUG-2/3/4/5). Data: balance v50, skills.json v3, goods.json (armour, gems), availability.json (gems, armour notes). Tree shape unchanged (31 nodes, same prereqs). Runs: decent bot, `--skip-tutorial`, seeds 1-4, same driver as QA (about 110 runs). Seeds are near-deterministic: treat under 1 win cycle as noise.

## Global changes
- `chain_min_gap` 3 to 2: the chain sequence (A1..B4, 7 steps) was the real pace limiter for bio and lux (win gated on B4, which needs the 6 earlier steps). Bio 34/32/34/27 to 30/27/31/27.
- Mil bots x1.265 (strength, growth), lux bots x0.65, bio bots x0.92 (original = 1). Mil stops being a free 4/4 at 27 (27,27,32,27 now) without breaking default decent (27 x4; at x1.39 default fell to 3/4).
- `tech_goal_2/4/6` 9/18/12 to 6/11/8, capstone cost (MIL/LUX/MIN/BIO_7) 4 to 3: capstones were never reached.
- NEW keys (owner approval needed, see open_questions): skill_MIL_6_price, skill_LUX_2_volume, skill_LUX_2_price, skill_LUX_6_price, skill_MIN_6_price, skill_BIO_2_volume, skill_BIO_4_price, skill_BIO_6_price. Restored: skill_MIL_3_route_units 0.125.

## Per node (focus run baseline vs node removed, 4 seeds)
| node | decision | change | evidence |
|---|---|---|---|
| MIL_2 | (a) | none; was untestable (BUG-1) | removed: craft 78 to 46, cash -2.9k, seed 3 loses the win |
| MIL_3 | (b) | debris immunity kept as extra; main effect now route_capacity_pct mil +12.5% (key restored). Debris never fires: EV17 is a rare random-planet event and routes rarely start there | removed: cash -5.4k (-29%), share -0.04. Contested (mil bots +35%): 2 of 4 wins to 0 of 4 |
| MIL_4 | (a) via BUG-2 | armour recipe 3 cells+chips+rivets to 4 cells (raws energy+chips = 2 feed ships) | armour made 21-30 units per run; removed: cash -1.9k, share -0.01. Rivets is now a plain trade good |
| MIL_5 | (a) | hit 0.35 to 0.5, cycles 4 to 5, every 8 to 7 | uncontested mil (share 0.59) it cannot show; contested (bots +35%): removed 27,27,soft,soft vs 27,27,28,soft, share 0.49 vs 0.52 |
| MIL_6 | (a) | event cut 0.35 to 0.5, extra sale price +6% (cash) | removed: cash -1.5k (-8%); event cut stays unseen (mil price-down events are 3 of 25 events): test needs forced events |
| MIL_7 | (a) | cost 4 to 3 | reached only if the bot stops buying MIL_5 in other focuses (bot wastes 5 points); test: `--only-skills` run |
| LUX_2 | (b) | now volume +8% and sale price +6%; event bonus kept (only silk events exist, 2 of 25) | removed with LUX_4/6 chain: bio share and cash shift, no clean arm; see LUX_4 |
| LUX_4 | (a)+(c) | gems recipe ore+silk+musk to 2 silk+1 musk (2 feed ships); gems_batch_out 2 to 3 (gems 390 a batch, cask 216) | the bot opens gem feeds only at c22-25 and never crafts gems before the win; LUX_4 present costs cash 4-5k (feed routes closing earners). Test: lux run with win delayed (no win) to 45 cycles |
| LUX_5 | keep | none | removed: wins 27,27,29 to 29,31,29 (+2.5 cycles), felt |
| LUX_6 | (b) | extra sale price +8% | removed: cash -0.2k; gems batch +1 only shows once gems run (as LUX_4) |
| LUX_7 | (c) | cost 3 | needs 13-point path; test as MIL_7 |
| MIN_2 | (c) | none | cannot be isolated (MIN_4 needs it); test: log ore order sizes with and without the cap |
| MIN_6 | (b) | extra sale price +8% | removed: craft 93 to 76, cash -1.6k; alloy never made (fabric not built by bot) |
| MIN_7 | (c) | cost 3 | as MIL_7 |
| BIO_2 | (b) | volume +12% extra; growth numbers kept | removed: cash 4.4k to 3.2k (-28%) |
| BIO_4 | (b) | extra sale price +10% | removed: cash -0.8k |
| BIO_5 | keep | none | removed: win +2 cycles in seed 1 |
| BIO_6 | (b) | event cut 0.25 to 0.4, extra sale price +8% | removed: cash -0.3k; event cut needs forced events |
| BIO_7 | (c) | cost 3 | as MIL_7 |

## Dominance and pacing (focus runs, 4 seeds)
default decent 27,27,27,27; mil 27,27,32,27 (cash 18k); lux 27,27,29,soft (20k); min 27,27,27,27 (17k); bio 30,27,31,27 (4k). Sloppy, always-expand, never-expand: 0 of 12 wins. No focus is clearly best: mil lost its extra wins and its win does not now depend on a free share margin. Remaining: bio cash is low (4k) and lux seed 4 never builds the atelier before c21 (bot food feed, QA).

## Story ids to update (story-designer)
SK_MIL_3 (now capacity first, debris second), SK_MIL_5 (50%, 5 of 7 cycles), SK_MIL_6 (price +6%), SK_LUX_2 (volume, price), SK_LUX_4 (gems from silk and musk, no ore), SK_LUX_6 (price), SK_MIN_6, SK_BIO_2, SK_BIO_4, SK_BIO_6, SK_*_7 cost lines; goods text for armour and gems recipes. Texts must not name hidden goods (gems, armour) before their rule.
