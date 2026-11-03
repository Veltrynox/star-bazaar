# Four Markets: design pack summary and reconciliation (2026-11-03)

For owner approval. No game code. Three docs make up the pack (plus this file); where they disagree, THIS file decides.

| Doc | Owner | Covers |
|---|---|---|
| `2026-11-03-four-markets.md` (core) | feature-designer | markets, goods, share and win/lose rules, trees, event structure, endings, touch list |
| `2026-11-03-four-markets-economy.md` | economy-designer | prices, recipes, share numbers, spreading penalty, bot numbers, skill costs, credit curve |
| `2026-11-03-four-markets-story.md` | story-designer | names, node texts, 11 endings, Military chains A and B written in full, style guide, 6 pool events |

## Brief checklist
1. Four markets, goods mapped (8 existing, 11 new, 4 workshops): core section 1, prices in economy section 1.
2. Share = player base-value volume / (player + 3 bots), window 8 cycles; win above 50% held 5 cycles from cycle 20 or at cycle 40; lose rules: core section 2, numbers in economy.
3. Spreading penalty: overhead 150 x (n-1)^2 per cycle plus 1.5x trip cost for mixed cross-market loads. Net cash at cycle 40: 23.9k with 1 market, 18.8k with 2, -7.8k with 3, -26.7k with 4. In the sim, 3-market and 4-market spreads and every split of 75/25 or worse won 0 of 240 runs; an 85/15 split won 10 of 240 (4.2%).
4. Bots: bot_1..3 (named in the story doc), per-market strength, growth and tier, gap rule, event hits S/M/L: economy section 4.
5. Trees: 7 nodes per market (4 skills, 3 tech by crafting) plus 3 Foundations; old 15 skills mapped: core section 3, costs in economy section 5.
6. Events: two chains per market (3 and 4 steps), two choices each, every choice changes a bot stat (rule R-BOT), shared pool of 24 existing plus 12 new = 36 (EV18 retired): core section 4.
7. Endings: END_<MKT>_GOOD and _BAD for each market, plus END_BANKRUPT, END_SWEPT, END_OUTCOMPETED: core section 6, full text in story section 2.
8. Military sample chain, fully written: story section 3.

## Reconciliation: decisions where the docs differed
These are my defaults so the pack is consistent. Each is listed again as an open question where the owner may overrule.

| # | Conflict | Decision |
|---|---|---|
| R1 | Tech goals: core 15/30/20, economy 9/18/12 | Economy wins: 9/18/12 (15/30/20 puts the capstone after cycle 35). |
| R2 | `market_overhead`: core 100, economy 150 | 150. |
| R3 | `END_SWEPT` as written in core can never fire (no bot reaches 50% in all four) | Economy fix: swept = player share under 10% in all four markets for 3 cycles from cycle 25. |
| R4 | `END_BANKRUPT` can never fire (ships are never lost) | Economy fix: repossess the newest ship while cash is negative and credit `salvage_share` x ship price; bankruptcy when no ship is left and cash stays negative. |
| R5 | Energy (Military) and food (Biotech) sell from cycle 1, so two markets count as active and MIL_A1 / BIO_A1 fire at cycle 5 for everyone | Common raws (energy, food, ore) do not count toward the 5% active-market rule or toward chain triggers. |
| R6 | "Variant chosen by the last choice" is ambiguous | Per chain, keyed to the option id picked in the previous step of the same chain. B1 has one body. |
| R7 | Which bot is "marked" and ties | The bot with the biggest cut from the last option chosen; boosts never count, a tier cut counts as medium; a tie goes to the lower bot number. |
| R8 | Tier cut wording on a bot already at the lowest tier | The game fills {cut} and {cut_std} with tier wording, or "loses strength clearly" at the lowest tier. Tier epilogue fires only if a tier really dropped. |
| R9 | Shared pool counts disagreed (25 vs 24 listed) | Pool = 24 kept (the pool rows that exist in data/events.json; EV19, BE01 to BE03 are draft text only, EV23 and EV27 do not exist; EV18 retired) + 12 new (EV40 to EV51) = 36 (recounted in R27 pass, core section 4 decides). |
| R10 | Names: Dunmere Syndicate vs Dunmere Reach, Lattice Alloy vs Lattice Plate | Ostrel Syndicate, Seam Alloy (story doc). |
| R11 | End screen must not reveal the hidden record | No counts, labels or direction on the end screen. `END_STAT_RECORD` is removed. |
| R12 | Win rate is knife-edge (+-8% bot strength flips 100% to 0%) | Add one global `bot_scale` key so QA can tune; target focused win rate 56 to 98% as measured on the paper model, to be re-checked on the real game. |
| R12b | Bot calibration | `bot_scale` 0.85; `bot_2_lux_strength` 2015 and `bot_2_bio_strength` 1100 so that all 512 option paths win 56 to 98% for a focused player. |
| R13 | Price skills (MIL_4, LUX_1, LUX_6) change credits only because share uses base prices | Decided by the owner: cash perks only, no share effect. |
| R14 | Open/Hard stance replaced (owner change) | Two neutral in-fiction options per step (`opt_a`, `opt_b`, shuffled order); each gives the player something, costs something and changes at least one bot stat. Hidden `dir_<mkt>` (about -63 to +63), one value per market, fed by both chains. Base nudges by step A1 4-6 up to B4 10-12; echo x1.25 (previous step same chain pushed the same way), then late swing x1.5 (B3, B4, only when abs(dir) is 25 or more and the nudge opposes the lean), then cap 14 per nudge, so no single step can decide. Ending: dir >= 0 good, dir < 0 bad (sign of the whole sum, no band, no last-nudge tiebreak); no step fired = good. The dir signs are mixed so cash, tech, bigger bot cut and opt_a position are each about half positive. |
| R15 | Core 4.3 cell values vs economy | Economy section 8.2 wins on every Gets/Costs/Bot cell (25 small retunes, no step's two options differ by more than 10 win-rate points). Core 4.3 now holds only id, trigger, neutral situation and the `dir` values, which core owns. |
| R16 | Effect line limit | 200 characters (was 90), format "Get / Cost / Rivals". |
| R17 | `EPI_NARROW` epilogue | Removed with the last-nudge tiebreak (no band any more). |
| R18 | Story placeholders | New: {cash_in}, {cash_out}, {n}, {cut}, {cut_std}; `{player_effect}` retired. |
| R19 | Approved loss rules were missing from the core doc, economy section 6 and the story loss endings | Applied everywhere: bankrupt = newest ship repossessed each cycle while cash is negative (360 credited), ends when no ship is left and cash still negative; swept = player under 10% in all four markets for 3 cycles from cycle 25. END_SWEPT renamed "The Floor of Every Graph". |
| R20 | Story Military text used first-pass numbers | Story re-aligned to economy 8.2 (B1 to B4 durations and sizes, no tier cut in B2, no Velvet boost in B3). Only MIL_A2 opt_b can cut a tier. |
| R21 | MIL_B3 opt_b had no player cost | Added cash -150 (spread vs opt_a still 7 points). |

| R22 | Reviewer: one late step could decide the ending (B4 nudge 24-26 vs thresholds of 10) | Replaced by R14's scale: max 14 per nudge, sign of the sum decides. About 40% of paths can still be flipped by B4 when dir is within reach of zero (any sign rule has this). |
| R23 | Reviewer: 13 of 18 cash options were negative-dir, tech options positive (a learnable pattern) | Re-signed per R14. |
| R24 | Reviewer: 8 options paid only with a rival boost, and LUX_B3 b boosted and cut the same bot | Each now also has an own cost (cash S, a short volume or upkeep hit); LUX_B3 b boost moved to bot_3. Sim re-run, all paths still in 56 to 98%. |
| R25 | Reviewer: no order for same-cycle outcomes; rescue stipend could hide repossession | Check order win, then swept, then bankrupt. Repossession first, no stipend in a repossession cycle, only the first two stipends paid (`rescue_max` 2), a stipend never ends the run. |
| R26 | Reviewer: effects timing | Bot and player effects apply at once and the result popup is immediate. Minerals chain A keeps its follow-up events (EV30, EV31, EV33, EV34, EV36, EV37) as optional flavour only. |
| R27 | Reviewer: "a few cycles" (2-4) overlapped "a while" (4-8) | A few cycles = 2 to 3, a while = 4 to 8. Neutral-wording rules tightened (no virtue adjectives, no cooperative-vs-delinquent button pairs, no ending themes in situations). Soft ending renamed "No Market Held". |

Known gap, handled in the later goals: the preface, goal line, tutorial, mission board lines and the whole Release/Corporation ending set are out of date for the new goal. They are a rewrite task in the endings goal (Goal 6), not in this pack.

## Caveats
- The numbers come from a ramped paper model, not the real route engine. Every win cycle must be re-checked in a bot run on the real game (Goals 2 and 3).
- Skill point supply (about 21 against 13 for one market, 23 for two) assumes 7 of 9 reachable planets and 5 route pairs. UNKNOWN until the real game confirms it.
- Only the Military chains and 6 of the 12 new pool events are written. Luxury, Minerals, Biotech chains follow the story style guide in Goal 5.

## Owner answers (2026-11-03)
1. 40 cycles: approved.
2. Old saves dropped, EV18 retired: approved.
3. Choices must not be framed as good or bad; the chain decides the direction: implemented as R14. Owner to confirm the result reads right.
4. Price skills get NO share effect (cash perks only): decided.
5. Swept (player under 10% everywhere) and bankrupt (ship repossession): approved.
6. Global `bot_scale` key and the 56 to 98% focused win rate: approved.
7. Names (bots, goods, endings): undecided, to be judged in play. Names stay as in the story doc until then.

## Verification status (honest)
- The economy numbers come from the economy-designer's paper sim (128 option paths per market, 200 seeds). They were not re-run by anyone else and are not tested on the real game.
- An independent reviewer read all four files in full (40 findings). Contradictions, stale text and neutrality problems found were fixed (R9 to R27). The Military chains were re-read against economy 8.2 after the fixes.
- Luxury, Minerals and Biotech chain TEXTS are not written (Goal 5); only their option numbers (economy 8.2), neutral situations and direction values (core 4.3) exist, plus the style guide rules. Their neutrality can only be checked when the texts exist.

## Open questions for the owner
1. Late cash is nearly worthless: a focused player has about 12k unspent after cycle 16, so late cash gets and costs (e.g. MIL_B4 b +600) barely matter. Options: add a late cash sink (upgrade cost 900 to 1500), or give late steps non-cash costs. Which?
2. Path-level gap: no single step is dominant (max 10 points), but a player who always takes the stronger-for-share option wins more: all opt_b vs all opt_a is 88 vs 68 (mil), 90 vs 68 (lux), 95 vs 68 (min), 82 vs 82 (bio). Button order is shuffled so position cannot be exploited, but is a 20 to 27 point gap between consistent strategies acceptable?
3. Tier -1 cuts on bots fire before the bot's first tier-up (cycles 11 to 14), so they act as strength cuts. A persistent tier offset fixes it and makes those options about 5 points stronger. Apply?
4. An 85/15 spread still wins 4.2% of runs. Leave it, or raise `market_active_pct` to 0.15?
5. Effect lines show credits and tech units as numbers but volume, price and upkeep as size words. Make all numbers (line limit about 230)?
6. Boosted bots show as "strength up" in the Standings; a player may read that as a mistake in hindsight. Intended?
7. Button order is shuffled per run. Acceptable for the UI build?
8. Win medians land at cycles 27 to 28 (core first said 28 to 36). Accept?
9. About 40% of runs can still be flipped by the last step (B4), since dir can sit near zero. Accept, or add a rule that a lean must exceed a small band before it counts?
10. A strong lean turned late by the last steps is not detected by the epilogues (needs the game to expose the sign of `dir` before B3). Skip?
11. Is "Your desk sets the roster" colder than "Garrisons set the roster" in MIL_B4? Playtest before the other three chains are written?
12. END_SWEPT can only fire for a four-market spreader whose fleet is already repossessed (84% with 2 ships left, 100% with 1; focused 0%); a three-market spreader goes bankrupt instead. Accept that swept is rare?
13. MIL_B1 opt_a still reads stronger than opt_b on the effect lines. Accept, or ask economy to even the cells?
14. Names (3 bots, goods, 4 renamed endings including "The Floor of Every Graph" and "No Market Held") stay as in the story doc until you judge them in play.
