# Skill tree final sign-off QA (2026-11-05)

Reviewer: qa-analyst. Build: current working tree, balance v50, skills v3 (economy-designer round 2, `design/proposals/2026-11-05-skill-tree-round2.md`). Nothing in game code or data was edited, nothing committed.

Raw records: `qa/reports/2026-11-05-skill-signoff-runs.jsonl` (172 batch rows, the 20 tech re-runs replace their leaking first rows). Bugs: `qa/reports/2026-11-05-bug_report-skill-signoff.json` (10 entries). Driver: `qa/bots/skill_signoff.sh`, one run: `qa/bots/skill_signoff_one.sh`, tables: `qa/bots/skill_signoff_analyse.py`.

Runs: 195 executed. 172 batch (step 1 ablations and baselines 108, dominance 12, base without tutorial skip 4, CEO x ship 48), 20 re-runs (tech ablation fix), 3 smoke runs.

## Headline

- No crash, softlock or freeze in the 172 batch runs. Every run ends at its expected cycle. The 4 `base_notut` runs are a bot tutorial limit, not a game path (BUG-9).
- Default decent wins 4 of 4 at cycle 27 (the 3 of 4 seen in the final review is gone on current data).
- Nodes: 19 checked, 11 AGREE (5 of them with an untestable half), 8 CONCERN, 0 REJECT. No node is fully untestable; six payoffs or halves are untestable (MIL_3 debris, MIL_6 and BIO_6 event cut, LUX_1 reveal prices, MIN_6 alloy, LUX_4 gems).
- No dominant strategy: sloppy, always_expand and never_expand 0 of 12 wins.
- Pacing: two medium flags on focus variants (mil seed 3 at cycle 32, bio seed 3 at cycle 31). Default is in band.
- CEO x ship check: 16 of 16 combos pass. 45 of 48 runs win.
- Gems and alloy are not reachable by the bot. Capstones are reachable through a branch-restricted arm.
- Release export: static check passes (no build run).

## 1. Bot changes (qa/bots only, no game code)

1. `--keep-running=<cycle>`: after the win the bot clears `main.game_over`, removes the end screen and takes the cycle step the game skipped. The game returns from `_end_cycle` right after a win, before `cycle += 1`, so without this the counter freezes. Limits: events, `Chains.tick` and `_sync_closed` do not run after the win; the game ends every run at cycle 40 (`win_cycle_markets`), so kept runs play to cycle 39. The kept run's outcome is its first win (`win_cycle`); a kept run can later be labelled SOFT at cycle 40 by the game's own timeout, which is not a player path.
2. Run record check uses the first `run_ended` (a kept run can end later with a different side).
3. `--feed-ships=n` (default 2) added. Not used for any result: alloy would also need the fabric build, which the bot does not do.
4. Tech ablation fix (`--skip-tech`). Round 2 lowered `tech_goal_2` and `tech_goal_6` to 6 and 8, so one cycle's crafting could finish an ablated tech after the bot erased its count (`still_in_abl` 4 of 4 for BIO_2, 2 of 4 for MIL_2, MIL_6, MIN_2, MIN_6). The count is now pinned at -1000000. The five nodes were re-run (20 runs, 0 completions).
5. Capstones: no bot change. `--skills=<branch>` restricts points to the market branch, because the open tree spends them on other markets (the lux focus learned MIL_5 and BIO_1 instead of LUX_7).
6. Not done: gems (musk never reaches the station, BUG-2) and alloy (needs the fabric build, MIN_1 plus dross and nullglass feeds, and 3 feed ships). See section 5.

Run count against the ~120 cap: step 1 (baselines and ablations) is 108 unique runs, plus 20 re-runs of the leaking tech ablations = 128. That is 8 over the cap; the 20 re-runs are the cost of the tool fix. Steps 3 and 4 add 64 runs (12 dominance, 4 base without tutorial skip, 48 CEO x ship).

## 2. Node verdicts (4 seeds, keep-running 38, learned arm = focus baseline)

Rules, fixed before the runs. REACHED: the learned arm holds the node in at least 3 of 4 seeds. AGREE: removal moves wins, win cycle (at least 1 cycle), cash (at least 5 pct) or focus share (at least 0.02) in one direction in at least 3 seeds, or the node's own output (craft units). REJECT: reached, and no measure moves. CONCERN: small, mixed, or not isolated. UNTESTABLE: the bot cannot produce the payoff. Removing a tech also removes its dependants (subtree), noted per row.

| node | kind | reached | removal evidence | verdict |
|---|---|---|---|---|
| MIL_2 | tech | 4 | subtree (MIL_4, MIL_6): cash -5.8k to -11.3k; share -0.014 to -0.082; armour -39 to -63, cells -9 to -15; seed 3 loses its win (32 to none) | AGREE (subtree; batch +1 not isolated, MIL_4 needs it) |
| MIL_3 | skill | 4 | subtree (MIL_5, MIL_6): share -0.094, -0.059, -0.019, -0.015; cash -18.4k, -12.7k, +2.2k, -5.4k; seed 3 faster without (32 to 29) | AGREE (capacity half). Debris half UNTESTABLE here (not counted) |
| MIL_4 | tech | 4 | armour 39 to 63 units per run in 4 of 4 seeds; cash -2.8k to -7.0k with MIL_6 (own part about -1.5k mean) | AGREE (output felt; cash effect small) |
| MIL_5 | skill | 4 | share -0.003 to -0.012; cash -4.7k, -3.2k, +8.0k, -3.6k; wins 27 in all (seed 3 32 to 27) | CONCERN: not felt uncontested (mil share about 0.5 to 0.6) |
| MIL_6 | tech | 4 | cash -9 to -11 pct in 4 of 4 (-2.0k to -4.7k); share, craft, wins unchanged | AGREE on the sale-price half. Event cut UNTESTABLE (no forced mil price-down events) |
| LUX_1 | skill | 4 | subtree (LUX_2 to LUX_6): lux wins 27, 27, 29 to none in all 4 seeds; cask -72 to -87 (atelier) | AGREE (atelier and food feed). Reveal-prices half UNTESTABLE (no price read in the bot) |
| LUX_2 | tech | 3 | subtree (LUX_4, LUX_6): cash +13.7k to +20.3k when removed; wins 27 to 27, 27 to 28, 29 to 30 | CONCERN: own volume and price not isolated (LUX_4 needs it); subtree is a cash cost |
| LUX_4 | tech | 3 | subtree (LUX_6): cash +17.1k to +21.6k when removed; wins unchanged | CONCERN: cost only. Gem payoff UNTESTABLE (musk never reaches the station, BUG-2) |
| LUX_5 | skill | 4 | subtree (LUX_6): wins 27 to 29, 27 to 29, 29 to 29; cash -9 to -22 pct | AGREE |
| LUX_6 | tech | 3 | cash -9 to -13 pct (-2.0k to -3.2k); cask -12 to -16; wins unchanged | AGREE |
| LUX_7 | skill | 3 | bot skill fires at cycles 25 and 26 (seeds 1 and 3); share -0.004 and -0.006; win and cash unchanged | CONCERN: not felt uncontested (lux share about 0.77, far above the line) |
| MIN_2 | tech | 4 | subtree (MIN_4, MIN_6): cash -16 to -20 pct; share -0.021 to -0.045; ingots -72 to -121; wins unchanged | CONCERN: ore-cap effect not isolated (MIN_4 needs MIN_2); no ore order sizes logged |
| MIN_6 | tech | 4 | ingots -27 to -49; cash -13 to -14 pct; share -0.01 to -0.029; wins unchanged | AGREE on the ingot half. Alloy UNTESTABLE (its plate needs the fabric the bot never builds; alloy needs 3 feed ships) |
| MIN_7 | skill | 4 | passive (no bot activation); share +0.019 to +0.021 with it; cash identical; win 27 in both arms | CONCERN: share only; min share 0.66 to 0.69, so the win is not affected |
| BIO_2 | tech | 4 | subtree (BIO_4, BIO_6): cash -35 to -50 pct (-3.3k to -7.0k); share -0.014 to -0.029; gel +24 to +30 | AGREE (subtree; volume not isolated) |
| BIO_4 | tech | 4 | subtree (BIO_6): cash -2.3k to -6.1k; share 0 to +0.007; wins unchanged | AGREE (subtree; seed unlock not isolated) |
| BIO_5 | skill | 4 | subtree (BIO_6, and MIL_5 through points): cash -0.5k to -7.9k; share +0.022, -0.008, +0.012, -0.011 (mixed); win +2 in seed 1 only | CONCERN: mixed share; stock-protect half not measured |
| BIO_6 | tech | 3 | cash -12 to -16 pct (-1.4k to -2.5k) in 3 of 3 reached seeds; wins, share, craft unchanged | AGREE on the price half. Event cut UNTESTABLE (no forced events) |
| BIO_7 | skill | 4 | passive; share +0.011 to +0.020; cash identical; win 27 in both arms | CONCERN: share only, win not affected |

Count: AGREE 11 (MIL_2, MIL_3, MIL_4, MIL_6, LUX_1, LUX_5, LUX_6, MIN_6, BIO_2, BIO_4, BIO_6). CONCERN 8 (MIL_5, LUX_2, LUX_4, LUX_7, MIN_2, MIN_7, BIO_5, BIO_7). REJECT 0.

Compared with the 2026-11-05 final review: MIL_2, MIL_3, MIL_4, MIL_6, LUX_1, LUX_5, LUX_6, MIN_6, BIO_2, BIO_4 and BIO_6 move from CONCERN, NOT FELT or REJECT to AGREE. MIL_3 is no longer REJECT (capacity now felt).

## 3. Dominance and pacing (4 seeds each, current data)

| strategy | wins | win cycles | mean final cash | notes |
|---|---|---|---|---|
| default decent | 4 of 4 | 27, 27, 27, 27 | 51.0k | in the 22 to 30 band |
| mil focus | 4 of 4 | 27, 27, 32, 27 | 33.7k | seed 3 after 30 |
| lux focus | 3 of 4 | 27, 27, 29 | 27.2k | seed 4 no win by 40 (BUG-1) |
| min focus | 4 of 4 | 27, 27, 27, 27 | 33.2k | |
| bio focus | 4 of 4 | 30, 27, 31, 27 | 11.8k | seed 3 after 30; low cash |
| sloppy | 0 of 4 | none | 9.3k | 1 ship; soft at 40 |
| always_expand | 0 of 4 | none | 24.9k | 6 ships; soft at 40 |
| never_expand | 0 of 4 | none | 9.3k | about 2 ships; soft at 40 |

Dominance: none. Only decent-based strategies win, and no non-decent strategy wins. The default and the min focus are equal at 27. Pacing: the default is in band; medium flags are mil seed 3 (32) and bio seed 3 (31), focus variants (BUG-4, BUG-5). Earlier flags are resolved: bio was 32 to 34 and lux seed 3 at 35, now 27 to 31 and 29.

## 4. CEO x ship check (decent, seeds 1 to 3, 16 combos)

Pass rule (from the brief): the combo's median win cycle is within 1 of the reference median, and its win rate is at least 60 pct of the best combo. Reference median = median of the 16 combo medians = 27. Best win rate = 100 pct.

Result: 16 of 16 pass. 45 of 48 runs win; the 3 misses (ceo_man_02 dart and fleet, ceo_woman_01 dart) are one seed each with no win by cycle 40 (67 pct, still at least 60 pct of the best). Win cycles 27 and one 28.

| CEO | bulk | dart | fleet | small |
|---|---|---|---|---|
| ceo_man_01 | 3/3 | 3/3 | 3/3 | 3/3 |
| ceo_man_02 | 3/3 | 2/3 | 2/3 | 3/3 |
| ceo_woman_01 | 3/3 | 2/3 | 3/3 | 3/3 |
| ceo_woman_02 | 3/3 | 3/3 | 3/3 | 3/3 |

## 5. Reachability: gems, alloy, capstones

- Gems (LUX_4 payoff): UNTESTABLE. The lux route from Tillam (planet index 1) to the station is built at cycles 22 to 26 in seeds 1 to 3, but musk in station storage stays 0 and no gem is crafted (BUG-2). Silk from another planet does arrive.
- Alloy (MIN_6 half): UNTESTABLE. Alloy = plate + 2 ingot. The plate needs the fabric (MIN_1, plus dross and nullglass routed to system 1). The decent bot builds the fabric only in dead_run. Alloy's feed is 3 ships against the limit of 2.
- Capstones: reachable with the branch arm. LUX_7 learned in 3 of 4 seeds, MIN_7 in 4 of 4, BIO_7 in 4 of 4. Only LUX_7 is an active bot skill. MIN_7 and BIO_7 are passive, so they act on the share only.

## 6. Checks

- Crash, softlock, freeze: none. All batch runs printed RESULT. Cycle counts as designed (win at 27 to 32, or no win at 40).
- Win and loss: first win on the expected cycle in every winning run. LUX_1 removal seed 4 is a LOSS (END_SWEPT at cycle 27, lux share 0.03): a designed loss path, not a fault.
- Release export (static): `export_presets.cfg` excludes `game/debug_menu.gd` and `qa/*`, `tools/*`, `handoffs/*`. `main.gd` creates the debug menu only when `debug_tools_allowed()` (`OS.is_debug_build()`). No export build was run, so the binary is UNKNOWN.
- Tooling: the kept-run window (cycle 39) and the lack of events after a win limit the event-based halves (MIL_6, BIO_6 event cut; LUX_2 event bonus).

## 7. Bugs (full entries in the JSON)

| id | severity | summary | owner |
|---|---|---|---|
| BUG-1 | medium | lux focus seed 4: atelier at cycle 21, no feed route logged, no win by 40 | economy-designer (cause UNKNOWN) |
| BUG-2 | medium | musk route from Tillam built, musk never reaches station; no gems in any run | gameplay-programmer (cause UNKNOWN) |
| BUG-3 | medium | LUX_4 costs 17k to 22k cash in the lux focus with no payoff seen | economy-designer |
| BUG-4 | medium | mil focus seed 3 wins at cycle 32 | economy-designer |
| BUG-5 | medium | bio focus seed 3 wins at cycle 31 | economy-designer |
| BUG-6 | low | LUX_7 not felt uncontested | economy-designer |
| BUG-7 | low | MIN_7 and BIO_7 move the share only | economy-designer |
| BUG-8 | low | MIL_5 not felt uncontested | economy-designer |
| BUG-9 | low | bot cannot pass the tutorial gate without --skip-tutorial (4 of 4 loss at 27 with 0 ships) | qa-analyst |
| BUG-10 | low | tech ablation leaked (fixed in bot, 20 runs re-run) | qa-analyst |

## 8. Limits

- Seeds are near-deterministic (earlier: 20 of 20 re-runs identical), so 4 seeds is a small sample. Treat under 1 win cycle or 0.02 share as noise.
- A tech removal measures its subtree. Own effects are not isolated for MIL_2, MIN_2, LUX_2, BIO_2 and BIO_4.
- Capstone verdicts compare with the branch arm (a different baseline from the focus run).
- Contested runs (bot strength raised) are needed for MIL_5, LUX_7, MIN_7 and BIO_7; the brief did not ask for them.
