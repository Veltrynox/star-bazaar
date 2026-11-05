# More skills sign-off (T173): seven new nodes

Reviewer: qa-analyst. Build: working tree, `data/skills.json` v6 (38 nodes), `data/balance.json` v52. Nothing in game code or data was edited, nothing committed or stashed. The owner's uncommitted asset work was not touched.

Raw records: `qa/reports/2026-11-05-more-skills-signoff-runs.jsonl` (194 runs, labelled by batch and data build). Bugs: `qa/reports/2026-11-05-bug_report-more-skills-signoff.json` (12 entries). Driver: `qa/bots/more_skills_signoff.sh`. Analyser: `qa/bots/more_skills_signoff_analyse.py`. Per-run wrapper: `qa/bots/skill_signoff_one.sh` (unchanged).

## Headline

- No crash, softlock or freeze in 194 runs. Every repeat (3 flagged runs, 2 repeats each) reproduced exactly, so the 4-seed results are deterministic, not noisy.
- Verdicts: 1 KEEP (BIO_5B), 5 CHANGE (FND_BULK, LUX_5B, MIN_5B, BIO_6B, LUX_6B), 1 DROP (MIL_5B). No node is cleanly FELT with a positive, reachable effect except BIO_5B.
- Two medium regressions (decent players losing a focus run). Decent mil focus seed 2 is swept at cycle 27 (END_SWEPT loss, mil share 0.074, cash 524). Decent bio focus seed 4 is outcompeted at the cycle-40 gate (no win, cash 489). Both come from the new nodes, not from other data changes: with the seven new nodes removed, the results match HEAD data exactly. Mil seed 2 is caused by FND_BULK. Bio seed 4 needs FND_BULK and BIO_5B together.
- LUX_5B is documented as information only, but it changes the realised event sequence in 4 of 4 seeds (see section 2). Its measured outcome effects come from that, not from the reveal.
- Default decent wins 27 in 4 of 4 (same as last round). Always-expand wins once (seed 3, cycle 39), which breaks the last-round "0 of 12" dominance result.
- Lock works: BIO_6B with MIL_5 or LUX_7 keeps a 6-cycle gap between hits of different skills in every seed where both fire, and the own cooldowns hold. No combination wins before cycle 27.
- Point supply is not a fixed 21. Earned points by cycle 39 are 16 to 22 in mil, default and bio focus, but 22 to 25 in lux and 27 to 29 in min. A second market (24 points on the whitelist) does not fit at mil or default supply (19 to 21 spent).

## 1. Verdicts per node

Rules, fixed before the runs. REACHED: learned in the on arm in at least 3 of 4 seeds. FELT: removal moves the win cycle (at least 1), cash (at least 5 percent), focus share (at least 0.02), planet stock or event hits in one direction in at least 3 of 4 seeds, with reachable payoff. NOT FELT: reached, and no measure moves past those limits. UNTESTABLE: the bot cannot reach the payoff (reason given).

Two arms per node, same seeds, keep-running 38, fast clock. Natural arm: focus run with and without the node (`--skip-skill`). Branch arm: the market whitelist (`--skills=`) with and without the node, so the points cannot move to other nodes.

| node | effect (data) | reached | measured effect (on vs off, 4 seeds) | verdict |
|---|---|---|---|---|
| FND_BULK | order size +15 pct, all markets, cost 2, tier 1 | 4 of 4 (learned cycle 2 to 4) | default win 27 in both arms; cash -6.9k to +10.8k (mixed); cash at cycle 5 12 to 37 pct lower with it; mil focus seed 2 flips to an END_SWEPT loss at 27 with it (win 27 without; repeated 3 times) | CHANGE, see section 4 |
| MIL_5B | planet storage stock growth 1 pct a cycle, cap 10 pct; stock protect on asteroid cut | 4 of 4 | growth half: mil stock in planet storage at end +7, 0, +2, +2 units (branch arm); share and win unchanged; cash +0 to +176. Stock protect UNTESTABLE (no asteroid storage cut in any run) | DROP (growth half not felt; protect half unmeasured) |
| LUX_5B | reveal prices 2 cycles; event warning 2 cycles (information only per data) | 4 of 4 | Reveal half UNTESTABLE (no bot reads prices). The warning changes the realised event sequence in 4 of 4 seeds, first difference at cycles 9 to 21. Natural win 27 vs none, 27 vs 34, 32 vs 36 (earlier in 3 of 4); branch win 27/27, 37/none, none/none, 36/36; share +0.005, +0.50, +0.06, 0 | CHANGE, see section 2 |
| MIN_5B | debris immunity; min price-down cut 0.3 | 4 of 4 | Branch arm identical in 4 of 4 seeds (win 27, cash, share, events). Min price-down starts are 0 or 1 per run. Debris immunity UNTESTABLE: no debris event (EV17) started in any of the 132 batch runs | CHANGE (unproven as built; needs a debris test or a larger cut) |
| BIO_5B | bio route capacity +12.5 pct (cost 2, tier 3) | 4 of 4 | Natural: share +0.051, +0.029, +0.123, -0.034 (3 of 4 at 0.02 or more); cash +11 pct, +95 pct, +12 pct, 0 (no win in seed 4 either arm); seed 2 win 27 with it, 32 without. Branch: without it the bio branch wins 1 of 4 (cash 0 or 520 in 3 seeds), with it 3 of 4 (27, 37, 27) | KEEP |
| BIO_6B | shared chosen-bot hit 25 pct for 4 cycles, every 8, shared lock 6 | 0 of 4 natural; 4 of 4 when whitelisted | Natural: never learned, so no arm to compare. Forced: fires every 8 cycles, share +0.004, +0.007, +0.007, +0.006 (below 0.02 in 4 of 4), cash and win unchanged. The test base collapses in 3 of 4 seeds, so this is a weak test | CHANGE (not felt as built; raise the hit or drop with it) |
| LUX_6B | lux price-down cut 0.3 (tier 4, cost 2, after LUX_5B) | 4 of 4 | Natural: win 27/27, 27/28, 27/27, 32/30; share 0, +0.005, 0, -0.015. Branch: win same in 4 of 4; cash +3.1k in one seed (same win, event sequence also changed). Lux price-down starts 0 or 1 per run (mean 0.5), so the cut binds rarely | CHANGE (cut binds too rarely to be felt) |

Verdict count: KEEP 1 (BIO_5B), CHANGE 5, DROP 1 (MIL_5B). Node-level detail for the owner is in the bug JSON (`not_felt` and `design_claim_mismatch` entries).

## 2. LUX_5B: the node changes events, not only information

`game/main.gd` lines 2151 to 2155: the warning picks the next event `events.random_id(...)` two cycles early, from the event rng, and the pool filter (`available(id, cycle)`) runs at the earlier cycle. The forecast is then the event that fires when its slot comes due (the due-slot branch of the cycle step). LUX_3 does the same at one cycle, so this is a design mechanism, but LUX_5B's data says "information only".

Evidence: the realised events (cycle and id) differ with and without LUX_5B in every seed (natural and branch). Seed 1 natural: cycle 13 EV43 with the node, cycle 21 EV02 without. The outcome differences therefore come from a different event stream. The reveal half (the "in 2 cycles" price line) was not measured, since no bot reads prices.

Decision for the owner: either the forecast draws from its own stream (so information never changes the events), or LUX_5B and LUX_3 are described as changing the event draw. Until then the economy claim "info only" is wrong.

## 3. Regression against last round and HEAD

Last round (`qa/reports/2026-11-05-skill-signoff-qa.md`): balance v50, skills v3. Now: balance v52, skills v6. HEAD data (skills v4, balance v51) was run on the working-tree code, because HEAD itself cannot run the bot (`Markets` and `Chains` are autoloads from uncommitted files).

| arm (decent, seeds 1 to 4) | last round | now | HEAD data on current code | reading |
|---|---|---|---|---|
| default | 27 x4 | 27 x4 | 27 x4 | same |
| mil focus | 27, 27, 32, 27 | 27, **loss (swept at 27)**, 27, 27 | 27 x4 | regression, seed 2 caused by FND_BULK |
| lux focus | 27, 27, 29, none | 27, 27, 27, 32 | 27, loss, 28, 31 | better; not isolated (balance changes) |
| min focus | 27 x4 | 27 x4 | 27 x4 | same |
| bio focus | 30, 27, 31, 27 | 27, 27, 27, **soft (outcompeted at 40)** | 30, 27, 31, 27 | regression, seeds 3 and 4 caused by FND_BULK plus BIO_5B |
| sloppy | 0 of 4 | 0 of 4 | not run | same |
| never_expand | 0 of 4 | 0 of 4 | not run | same |
| always_expand | 0 of 4 | 1 of 4 (seed 3, cycle 39) | not run | new win, reproduced 3 times |

Attribution. Removing all seven new nodes restores the HEAD-data results exactly in both mil (cash 18384, 20431, 17590, 24654) and bio (23898, 38969, 21377, 36490). Removing FND_BULK alone fixes mil seed 2 (win 27) but bio seeds 3 and 4 still collapse. Removing BIO_5B alone leaves bio seed 4 collapsed. Removing both restores bio. So bio is a knife edge on early point timing: FND_BULK (learned at cycle 2 to 4) and BIO_5B (cycle 12 to 14) each shift the purchase order. MIL_5B, LUX_5B, LUX_6B and MIN_5B are never learned in bio focus, so removing them changes nothing.

Pacing. Default decent wins at 27 in every seed (in band). Lux focus seed 4 wins at 32 (after 30, medium). Bio and mil focus flags are the regressions above.

Dominance. Sloppy and never_expand 0 of 4 each. Always_expand 1 of 4, at cycle 39 in seed 3, reproduced in 3 of 3 runs (medium, within one cycle of the game's 40-cycle end). Last round it was 0 of 12 across the three non-decent strategies; now 1 of 12.

## 4. FND_BULK: early cash (brief item 2)

Answer: FND_BULK does not make the first 10 cycles risky for bankruptcy, but it costs early cash.

- Cash minimum over cycles 1 to 10 with FND_BULK: 300 in all 4 seeds (without it: 300 in 3 seeds, 284 in seed 4).
- First ship buy: cycle 5 with and without, in all 4 seeds (no delay).
- Cash at cycle 5: 473, 473, 338, 473 with FND_BULK vs 539 without (12 to 37 pct lower).
- Cash at cycle 10: 543, 358, 890, 1667 with vs 1593, 1948, 1231, 593 without (lower in 3 of 4 seeds by 0.3k to 1.6k).

The early cost is small in absolute terms, but it is the path change behind the mil seed 2 loss and the bio collapse (section 3). CHANGE: move the node out of the cycle 2 to 4 window (higher tier or cost), then re-run mil seed 2 and bio seeds 3 and 4.

## 5. Shared chosen-bot lock (brief item 3)

Works as designed. Successful chosen-bot hits (`bot_skill_log`) with BIO_6B learned:

| arm | learned | gap between hits of different skills | own cooldown gaps | wins |
|---|---|---|---|---|
| lock_mil5_bio6b | MIL_5, BIO_6B in 4 of 4 | 6 in all 4 seeds (shared_every 6) | MIL_5 7, BIO_6B 8, no breaks | 27 x4 |
| lock_lux7_bio6b | LUX_7 and BIO_6B in 2 of 4 (seeds 2, 3); BIO_6B only in seed 4; none in seed 1 | 6 in every seed where both fire | LUX_7 and BIO_6B, no breaks | 28 (none learned), 36, 27, 38 |
| lock_mil5_lux7 (control, no BIO_6B) | MIL_5 only (LUX_7 not reached without a focus) | none, no shared lock without BIO_6B | MIL_5 7, no breaks | 27 x4 |
| lock_all3 | MIL_5 only (BIO_6B and LUX_7 not reached) | none | MIL_5 7 | 27 x4 |

- No combination wins before cycle 27 (current best). PASS.
- Not tested: MIL_5 with LUX_7 and BIO_6B together, since the points do not fit (lock_all3 never learns BIO_6B). LUX_7 is reached only in lux focus (reg_lux seed 4).
- The shared timer on the skill screen ("Use" row) is UNTESTABLE headless (no UI run).

## 6. Point supply (brief item 4)

Measured as spent (sum of skill costs learned) plus points left at cycle 39, from focus runs:

| arm | spent | left | earned |
|---|---|---|---|
| default (all skills) | 18, 21, 21, 21 | 1, 1, 1, 1 | 19, 22, 22, 22 |
| mil focus | 16 to 19 | 0 to 1 | 16 to 19 |
| bio focus | 17 to 18 | 0 | 17 to 18 |
| lux focus | 22 to 25 | 0 | 22 to 25 |
| min focus | 27 to 29 | 0 to 1 | 27 to 29 |
| second-market arm (24 points on the whitelist) | 19 to 21 | 0 to 1 | 20 to 21 |

- A focused mil run uses 16 to 19 points and a bio run 17 to 18, close to the economy's "about 19 of 21".
- Lux and min runs earn more (22 to 29): share steps (`skill_points_share_20`, `_35`) pay more when a market is strong, so supply is per run, not 21.
- A second market does not fit: the second-market arm whitelists 24 points (FND trio, LUX 6 nodes, MIL 4 nodes). FND_BULK is auto-allowed (section 8), so 26 are wanted; the runs spend 19 to 21. This holds at mil and default supply, but not for lux or min focus, where supply is 22 to 29.
- Single focus arm (lux, 16 points plus FND_BULK = 18 spent): 2 to 7 points left unspent, so one focus fits with room.

## 7. Other checks

- Crash, softlock, freeze: none in 194 runs. Every run printed RESULT.
- Win and loss: decent wins at cycle 27 in default and in min focus; the loss, no-win and always_expand cases are in section 3 and the bug JSON.
- Release export (static, no build): `export_presets.cfg` excludes `game/debug_menu.gd`, `qa/*`, `tools/*`; `debug_tools_allowed()` returns `OS.is_debug_build()`. No export binary built, so the release binary check is UNKNOWN.
- Not run: UI (skill screen, planet panel, shared timer, reveal price line). Those are the owner's visual checks.

## 8. Method and limits

- Bot change, qa/bots only: `bot_run.gd` now records `route_units_by_market` (route capacity: `units_per_cycle` of each running route, summed over settled cycles). Behaviour is unchanged. The engine does not log units moved per route, so this is capacity, not volume. Its aggregate reading is confounded by route sets that differ between arms (bio capacity on-off +0.3 to +20 pct), so BIO_5B's FELT verdict rests on share and cash.
- Branch whitelist rule (pre-existing, `bot_run.gd:1255-1264`): once any non-Foundation skill is whitelisted, every Foundation node is allowed. So each branch arm with a market skill also learned FND_BULK, on both sides of its pair (the pairs still compare the node cleanly). Only `brb_fnd_base` against `brb_fnd_bulk` isolates FND_BULK, and the FND_BULK verdict rests on that pair plus the natural arms.
- Four seeds, deterministic: three flagged runs reproduced exactly on repeat. Four seeds are still a small sample; a 0.02 share or 1 win cycle is at the noise edge.
- Natural arms are path-dependent: removing a node reallocates points, which can move a whole run (lux seed 2 collapses to 0.04 share without LUX_5B). The branch arms fix the whitelist, so they are the cleaner test.
- Event hits are rare in the bot's runs: down-start events per run are 0 to 1 for lux and min, 1 to 3 for mil, 0 for bio. Cut-based nodes cannot be measured reliably at this rate. Debris (EV17) never started.
- HEAD cannot run the bot (uncommitted autoloads). The HEAD comparison used a scratch copy of the working tree with HEAD's two data files; no repository file changed.
- Crash rows from the first HEAD attempt (missing autoloads) are not in the raw records.
