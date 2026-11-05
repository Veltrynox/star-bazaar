# Skill tree round 3 (economy-designer, 2026-11-05)

Balance v51, skills v4. Bot: current qa/bots/bot_run.gd (musk-feed fix). All runs `--skip-tutorial`, fast clock, `--keep-running=38`. Contested = rival strength and growth of the tested market multiplied in a scratch copy (real data untouched).

## What changed
| item | change | reason |
|---|---|---|
| LUX_2 | extra event_bonus_pct removed; key skill_LUX_2_event_bonus removed | dead (2 of 25 events). Volume +8%, price +6% kept |
| LUX_7 | once per run to cooldown: skill_LUX_7_every 9 (NEW key), hit 0.3 to 0.4, 8 cycles | comparable to MIL_5 (5 of 7 cycles, 50%). Uptime 8 of 9 |
| MIN_7 / BIO_7 | cut 0.2 to 0.3 / 0.15 to 0.25 | uncontested win sits at the earliest cycle (27), so only share moves |
| MIL_7 | unchanged (growth x0.5) | not trivial, see below |
| gems | gems_batch_out 3 to 6 | with gems really crafted (programmer fix) lux seeds 1 and 2 lost |
| lux bots | strength and growth x0.81 (6 keys) | lux focus back to wins |
| mil bots | strength and growth x0.7 (6 keys) | mil 3 of 4 after the bot fix; seed 3 no win |
| culture lab | NEW key culture_lab_build_cost 600 (goods.json cost_key); other workshops stay 900 | bio seeds 1 and 4 starved (lab built, no cash for spores ship). Global 600 hurt mil, so lab only |
Tests: LUX_2 event-bonus checks now use LUX_5; LUX_7 test is a cooldown. 1866 pass.

## Evidence (real data, decent, seeds 1-6 unless noted)
- default: 27,27,27,27,27,27. mil focus 27 x6. min focus 27 x6. bio 30,27,31,27,27,27. lux (seeds 1-8) 27,30,27,29,x,28,30,32 (seed 5 cash collapse).
- sloppy, always_expand, never_expand: 0 of 12 wins. No dominant strategy.
- CEO x ship, 16 combos x 2 seeds: 31 of 32 wins at 27. ceo_man_01 + bulk is fragile: seed 2 END_BANKRUPT at c14; extra seeds 3,4 win, 5-10: 4 of 5. Flips with any bot value (also with old data when only one of lux or mil is reverted), so it is a knife edge, not these changes.
- BUG-1 (lux seed 4): now wins 29. BUG-4 (mil seed 3): 27. BUG-5 (bio seed 3): still 31, seed 1 30 (inside 22-30 band edge).

## Contested capstones (8 seeds, branch arm = points only in the market branch; mil open tree)
| node | contest | with | without | read |
|---|---|---|---|---|
| MIL_5 | mil x1.35 | 27,27,37,27,40,27,27,x, share 0.51 | 40,27,27,27,x,27,29,x, share 0.47 | felt: share +0.04, same win count (6 of 8), different seeds |
| MIL_7 | mil x1.35 | 27,27,28,27,30,28,27,27, share 0.57 | 27,27,29,27,40,31,27,27, share 0.52 | felt: share +0.05, about 1.5 cycles faster; wins still at 27 floor, so not trivial |
| LUX_7 | lux x1.0 | 8 of 8 wins, share +0.03 to 0.05 | 6 of 8 | felt. At x1.15: 4 of 8 vs 2 of 8 |
| MIN_7 (0.3) | min x2.5 | 8 of 8 | 6 of 8 | felt only at x2.5; x1.5 and x2 share +0.02, wins equal |
| BIO_7 (0.25) | bio x2.5 | share +0.04, wins equal | | share only: bio wins sit at the earliest cycle; the one loss is a cash collapse |

MIL_7 trim: not needed. Mil stays held at cycle 27 by win_earliest_cycle, the capstone only widens share.

## LUX_4 (BUG-3)
Real data lux focus vs LUX_4 skipped: cash at c27 9.3k vs 30.4k (seed 1), 5.3k vs 16.0k, 8.7k vs 17.1k. Share with LUX_4 0.48 vs 0.32 to 0.34, and seed 4 wins only with it (without: cash 0). So gems pay in share and wins, and cost cash. The cash cost is mostly the bot: the silk and musk feed routes carry about 25 a cycle each while one batch uses 2 silk and 1 musk; the station ends with 450 silk and 475 musk idle. Fix belongs to the bot (cap feed amount), not data. Price x1.5 to x2.5 raised share but not cash and delayed wins to c34-40, so price stays 130.

## UNTESTABLE
- Alloy (MIN_6 half): the bot never builds the fabric.
- Event halves (MIL_6, BIO_6 event cut, LUX_5 events): no forced events in the bot.
- MIN_7 and BIO_7 win effect: the floor (cycle 27) hides it unless rivals are x2.5.
- LUX_7 contested read uses a branch arm (no tech), not the real build.

## SK_* text that changes
SK_LUX_2_PLAIN (drop the 50% event line), SK_LUX_7_PLAIN (not once per run: "every {m} cycles ... falls by 40% for {n} cycles"), SK_MIN_7_PLAIN (30%), SK_BIO_7_PLAIN (25%). story/ and generated text not edited here.
