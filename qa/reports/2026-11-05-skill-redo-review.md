# Skill tree redo: QA review (2026-11-05)

Reviewer: qa-analyst. Input: `design/proposals/2026-11-05-skill-tree-redo.md` (DRAFT, not applied). Build: current working tree, `data/skills.json` unchanged. Nothing was edited or committed.

Batch: 40 headless runs (cap reached). 16 baseline (4 strategies x seeds 1-4), 4 decent with the draft's node order forced (`--skill-order`), 16 decent ablations (one of MIL_5, LUX_5, BIO_3, MIN_3 removed, seeds 1-4), 4 decent with `--market=lux` and a LUX-first order. Raw records: `qa/reports/2026-11-05-skill-review-runs.jsonl`. Bugs: `qa/reports/2026-11-05-bug_report-skill-review.json`.

Headline: no crash, softlock or freeze in 40 runs. No dominant strategy in the default config. Most of the redo is untested because the bots never reach it (section 3). One node is rejected (MIL_3). Three current-build issues are logged (section 4).

## 1. Baseline by strategy (default config, `--skip-tutorial`)

| strategy | runs | wins | non-win end | final cash | ships | permits | points earned (spent+left) |
|---|---|---|---|---|---|---|---|
| decent | 4 | 3 (c27, c27, c28) | 1 bankrupt at c24 (seed 2) | win 14.9k to 22.9k | 6 | 1 | 18 to 21 |
| sloppy | 4 | 0 | 4 at c40 (outcompeted) | 6.3k to 7.5k | 1 | 0 | 4 to 5 unspent, no skills |
| always_expand | 4 | 0 | 4 at c40 | 14.5k to 21.8k | 6 | 0 | 11 |
| never_expand | 4 | 0 | 4 at c40 | 5.9k to 7.1k | 1 | 0 | 5 to 8 |

Outcome labels: the game's "soft" side (END_OUTCOMPETED at the cycle-40 gate) is listed as a loss. No strategy other than decent wins, so no dominance flag. Decent wins at c27 and c28 sit inside the 22 to 30 pacing band (the skilled target in balance.json is 22 to 26; decent is 1 to 2 cycles late against it, which is a balance note, not a flag).

Other batches: decent with the draft order forced wins 1 of 4 (c31). Decent with `--market=lux` wins 3 of 4 (c27, c29, c33) with no workshop built. The LUX market alone can win; this is a win-rule question, not a node flag.

## 2. Ablations (decent, one node removed, seeds 1 to 4)

| node removed | same win cycles (seeds 1, 3, 4) | cash change vs baseline | reading |
|---|---|---|---|
| MIL_5 | yes (27, 27, 28) | -1.4k, -1.2k, +0.1k | no outcome effect at 0.18 / 3 cycles |
| LUX_5 | yes | -1.4k, -1.2k, +0.1k | same numbers as MIL_5: the bot spends the 3 points on the other node |
| BIO_3 | yes | 0, 0, +0.3k (learned in seed 4 only) | not felt |
| MIN_3 | yes | 0, 0, -0.3k (learned in seed 4 only) | not felt |

Seed 2 stays bankrupt when BIO_3 or MIN_3 is removed, and ends as a non-win at cycle 40 when MIL_5 or LUX_5 is removed. Seed 2 is a knife-edge, so single-seed differences are noise. Caveat: removing a node frees its points for another node, so each row measures node plus reallocation.

## 3. Coverage: what the bots can reach

- Tech gates: each tier-4 and tier-5 tree needs 9 + 18 + 12 = 39 units of its workshop output (goal counts from `tech_goal_2/4/6` = 9/18/12). Bot decent builds one workshop only, the smelter (`qa/bots/bot_run.gd` `_workshop_turn`). Smelter tech MIN_2 and MIN_4 landed in 24 of 24 decent-logic runs.
- Never learned in any of the 40 runs: MIL_2, MIL_4, MIL_6, MIL_7, LUX_2, LUX_4, LUX_6, LUX_7, BIO_2, BIO_4, BIO_5, BIO_6, BIO_7, MIN_7. Rare: MIN_5 and MIN_6 (2 of 40 each, both seed 4).
- Atelier and culture lab were never built. Munitions was built only by never_expand, where it stalled for the whole run (no chips without system 2).
- Points: the full tree costs 43 points (3 FND + 10 per tree x 4). Decent earns 18 to 21 by its wins. A capstone path (for example MIL_7 = FND 3 + MIL_1 1 + MIL_3 2 + MIL_5 3 + MIL_7 4) is 13 points plus 39 tech units. Estimate: one capstone is not reachable before about cycle 30 with one workshop; to confirm, run a sim with the workshop built at cycle 9 to 12.
- Estimate of workshop time per tree: 39 units is 13 batches at 3 units per batch (cells, cask, ingot, gel), or about 20 batches at 2 per batch (alloy, gems, seed). At one batch a cycle, that is 13 to 20 uninterrupted cycles after the workshop is running.

## 4. Verdicts per node

Verdict key: AGREE = keep as drafted. CONCERN = do not approve until the check is done (reason given). REJECT = do not apply as written.

| node | draft | verdict | why (evidence from 40 runs or code) | check |
|---|---|---|---|---|
| FND_STORAGE | keep | AGREE | Learned in 36 of 36 non-sloppy runs at c8.4. Gates all four tier-1 nodes; income gate 2000 is reached in every decent run. | none |
| FND_PERMIT | keep | AGREE | Learned at c1.0 in 36 runs. Learning it does not buy the permit (600), so tier-1 nodes can be learned with system 2 closed. | none |
| FND_PROSPECT | keep | AGREE | c2.0 in 36 runs; opens cluster routes and ore. | none |
| MIL_1 | keep | AGREE | c8.6 in 36 runs. Upkeep effect and cells/munitions unlock. Munitions still needs system 2. | Ship maintenance with 4 to 6 ships in a decent run (not measured here). |
| MIL_2 | tech: munitions +1 batch | CONCERN | 0 of 40 reached. Munitions never ran (cells need chips, system 2). Code is live: `workshops.gd:59` adds `Skills.workshop_batches` for munitions. | Run munitions with the permit (`--market=mil` or a feeder bot); check the 9-cell goal and batch count. |
| MIL_3 | event_immune (replaces +12.5% route cap) | REJECT | Pirate target has no source: `pirates_active` (route_engine.gd:36) is never set true, so the pirate half does nothing. Only debris is live (EV17 route efficiency, route_engine.gd:639-640). The `event_immune` type has no code. The current +12.5% route cap is learned in 35 of 40 runs and was never measured. | Retarget to debris only, or hold the node until pirates exist. Re-review after. |
| MIL_4 | tech: armour unlock only | CONCERN | 0 of 40 (needs 18 cells). Armour sells 180 at cash cost 25 per unit (margin 155; cells 58). Likely the strongest mil good. | Once munitions runs: time to armour and armour share of cash; dominance vs cells. |
| MIL_5 | Embargo, retune 0.25 / 4 cycles / every 8 | CONCERN | Learned 22 of 40. Ablation shows no outcome change at the current 0.18 / 3. The retune is directionally right but not yet felt. | Re-run the ablation at the retune. Measure win-share delta, not only win cycle. |
| MIL_6 | keep | CONCERN | 0 of 40 (needs MIL_4 and 12 cell units). Untestable now. | Munitions run. |
| MIL_7 | keep (capstone) | CONCERN | 0 of 40. 13-point path plus 39 cell units. Likely after the win window. Permanent halving of rival mil growth is a strong lever if reached early. | Points and unit timing sim. If reached before c25, dominance check. |
| LUX_1 | reveal prices, atelier, cask (drops +6%, gems) | CONCERN | Node text names cask while hidden (see 5.2). Atelier never built in 40 runs. Reveal prices: no bot reads next-cycle prices, so bots cannot measure it. Cask sells 72 for cash cost 12 (margin 60) and is the only system-1 crafted luxury, so it may be an early engine. | Atelier run (food feed). Cask cash vs decent. Reveal check in a playtest. |
| LUX_2 | keep (tech, +50% price-up pay) | CONCERN | 0 of 40 (9 cask units behind the atelier). | Atelier run; check the bonus fires on lux price-up events (EV21, EV22 silk; chain steps). |
| LUX_3 | keep (1-cycle event warning) | CONCERN (low) | Learned 28 of 40. Information only: bots do not act on warnings, so a bot ablation cannot show it. | Playtest or UI check that the warning line is shown. |
| LUX_4 | tech: cask unlock becomes gems unlock | CONCERN | 0 of 40. The tech can finish on cask before any gem is craftable (gems needs silk, so system 2 and the permit). Payoff waits for the permit. Gems rule lacks musk (see 5.4). | Atelier run; check LUX_4 done before permit and gems timing vs permit. |
| LUX_5 | keep (+15% volume at price-up planets) | CONCERN | Learned 21 of 40. Ablation: same win cycles, cash change within 1.4k. Condition (sale at a price-up planet) rarely true for the bot. | Count sales that meet the condition per run. Bot that sells on price-up. |
| LUX_6 | Hallmark: saturation relief (replaces +12%) | CONCERN (hold) | 0 of 40, no code yet. The draft's own dominance risk: cask margin 60 with relief lets one planet take all the stock. | Sim with atelier at 2 batches. Then atelier bot run: cask share of cash and win cycle. Do not approve before this. |
| LUX_7 | keep (retune 0.30 / 8, once per run) | CONCERN | 0 of 40. 13-point path plus 39 lux units. Strong once-per-run lever. | Timing sim; dominance check if reached by c25. |
| MIN_1 | keep | CONCERN | Learned 34 of 40. Smelter and ingot unlock as described. Fabric, named in the text, is hidden until MIN_5 and nullglass are visible (c15 plus system 2), so the fabric half is a no-op until MIN_5. | Fix text, or name the fabric as "after nullglass" (see 5.2). |
| MIN_2 | tech: ore cap bypass only (+8% dropped) | CONCERN | Reached in 24 of 24 decent-logic runs (9 units). The only effect left is the ore order size cap bypass (route_engine.gd:199). No run measures whether that cap binds. | Mining run with and without MIN_2; compare ore order sizes. |
| MIN_3 | keep (+25% cluster yield, dross at Cinderrest) | AGREE (with check) | Learned 18 of 40 at c12. Ablation: removing it costs 0.3k cash on seed 4, same win cycles. Dross and dead worlds open at c15; the dead_run strategy exercises them (not run here). | Run dead_run and mining_focus with `--skip-skill=MIN_3`. |
| MIN_4 | tech: +1 batch (Second Crucible), alloy unlock removed | AGREE | Reached in 24 of 24 decent-logic runs (27 units in total: 9 for MIN_2, 18 for MIN_4). Batch effect is live (`workshops.gd:59`, `fabric.gd:37`). | Smelter batches go 1 to 2 in a run log. |
| MIN_5 | keep (nullglass at Greywake) | CONCERN | Learned in 2 of 40 runs. It is the hub of fabric, plate, alloy and null core, so reach matters. | Points-by-cycle sim; mining_focus run. |
| MIN_6 | tech: +1 unit per batch and ALLOY unlock | CONCERN | Reached in 2 of 40 (seed 4 only, needs MIN_5). Alloy margin 155 (sell 160, cash 5), second only to seed (169). Alloy also needs plate. | Mining_focus run: min win share and alloy share of cash. |
| MIN_7 | keep (retune -20%, permanent) | CONCERN | 0 of 40. 13-point path plus 39 min units. Capstone. | Timing sim; dominance check if reached. |
| BIO_1 | culture lab and gel (order size dropped) | CONCERN | Culture lab and gel are hidden until system 2 (availability), so the 1-point spend shows nothing until the permit. Learned at c9 to 11 in decent. Text names bio-gel while hidden. | Decide: keep a visible effect, or label "after permit". Check the UI with BIO_1 learned and permit closed. |
| BIO_2 | keep (stock growth 2% a cycle, cap 20%) | CONCERN | 0 of 40 (needs culture lab). Effect needs bio stock held in planet storage, which bots never hold. Small effect. | Culture lab run plus stock-hold check; stock value after 10 cycles. |
| BIO_3 | keep (planet storage +50%, borderline) | CONCERN (low) | Learned 20 of 40. Ablation: +0.3k cash without it, same win cycle. Felt only when planet storage is full, which bots do not reach (not measured). | Storage fill ratio per run. If under about half the cap, it is a no-op. |
| BIO_4 | keep (seed unlock) | CONCERN | 0 of 40 (needs culture lab and 27 gel units). Seed is the top bio margin (sell 190, cash 21). | Culture lab run; bio dominance check. |
| BIO_5 | share window 12 cycles, plus stock_protect (moved from LUX_4) | CONCERN | 0 of 40. Window change is live (`Markets.window_for`). stock_protect only matters on the asteroid decline branch (50% roll, only when the player declines; events.gd `asteroid_roll`, main.gd:2327), so it is rarely felt. Key name `share_window_bio_bonus` holds a window length, not a bonus. | Bio path run; count decline rolls that cut storage with bio stock held. Rename the key or add a note. |
| BIO_6 | keep (tech: bio events -25%, reopen 1 cycle sooner) | CONCERN | 0 of 40 (needs BIO_4 and BIO_5). `reopen_sooner` is wired (main.gd:2250). Untestable now. | Bio path run. |
| BIO_7 | keep (capstone, retune -15%) | CONCERN | 0 of 40. 13-point path plus 39 bio units. | Timing sim. |

Count: AGREE 6, REJECT 1 (MIL_3), CONCERN 24.

## 5. Cross-cutting findings

5.1 Points and timing. The full tree (43 points) is not reachable in a win run; decent holds 18 to 21 points by its wins. Capstones need a 13-point path plus three tech gates (39 units each). The redo keeps the shape, so the capstones are the main pacing risk. Approve only after the timing sim.

5.2 Text vs availability (CLAUDE.md rule). Current skill texts name goods that are hidden at the time: SK_MIL_1_PLAIN (pulse cells), SK_MIN_1_PLAIN (ingot; fabric is a workshop), SK_MIN_4_PLAIN (seam alloy), SK_BIO_1_PLAIN (bio-gel). The draft's LUX_1 (cask), LUX_4 (gems) and MIN_6 (alloy) texts would do the same. UNKNOWN whether the `_test_availability` text scan covers SK_* ids. Bug logged.

5.3 Test suite. `tools/tests/run_tests.gd` reads keys the draft removes: skill_size_s (lines 1743, 1747), skill_LUX_1_price and skill_LUX_6_price (1753), skill_MIL_3_route_units (1757), skill_BIO_1_order_units (1765, 3375), skill_MIL_4_price (3321-3329), and the LUX_4 stock_protect test (3385). The data change must update these in the same change, or the suite fails.

5.4 Data lint in the draft. The gems rule must include musk (the draft note says all of ore, silk and musk must be visible; the current visible_when lists ore and silk only).

5.5 Harness. The bot cannot test the LUX, MIL or BIO tech chains: it builds one workshop, the smelter. A market-focused run did not build the atelier either (cask needs food, and the lux focus carries no bio lanes). A workshop-building bot (atelier, munitions, culture lab, with feeders) is the one change that unlocks checks for about 20 of the 24 CONCERN nodes. qa-analyst can build it; estimate one session. Not done in this review because the run cap is reached.

## 6. Required before the draft is applied

1. Reject or retarget MIL_3 (debris only, or hold).
2. Remove the text problems in 5.2 for current and new skill texts; BIO_1 and MIN_1 need a visible-effect decision.
3. Add musk to gems; update the availability rules as the draft lists, then `sh tools/tests/run.sh`.
4. Timing sim for the four capstones and for LUX_6 (saturation) before approval.
5. Workshop-building bot, then re-run the CONCERN nodes.

## 7. Limits

Headless runs only; no windowed playthrough. The release-export debug-menu check is not part of this brief and was not run. Seeds 1 to 4 only; the game has no RNG except the asteroid roll and the alt choice, so seeds differ little. Goods margins use `cash_cost_per_unit` from goods.json, not full cost. UNKNOWN: whether the player UI shows the workshop build button for munitions while system 2 is closed (bug 2 severity depends on it).
