# Four Markets: design pack summary and reconciliation (2026-11-03)

For owner approval. No game code. Three docs make up the pack; where they disagree, THIS file decides.

| Doc | Owner | Covers |
|---|---|---|
| `2026-11-03-four-markets.md` (core) | feature-designer | markets, goods, share and win/lose rules, trees, event structure, endings, touch list |
| `2026-11-03-four-markets-economy.md` | economy-designer | prices, recipes, share numbers, spreading penalty, bot numbers, skill costs, credit curve |
| `2026-11-03-four-markets-story.md` | story-designer | names, node texts, 11 endings, Military chains A and B written in full, style guide, 6 pool events |

## Brief checklist
1. Four markets, goods mapped (8 existing, 11 new, 4 workshops): core section 1, prices in economy section 1.
2. Share = player base-value volume / (player + 3 bots), window 8 cycles; win above 50% held 5 cycles from cycle 20 or at cycle 40; lose rules: core section 2, numbers in economy.
3. Spreading penalty: overhead 150 x (n-1)^2 per cycle plus 1.5x trip cost for mixed cross-market loads. Net cash at cycle 40: 23.9k with 1 market, 18.8k with 2, -7.8k with 3, -26.7k with 4. Every spread split tested won 0 of 60 runs.
4. Bots: bot_1..3 (named in the story doc), per-market strength, growth and tier, gap rule, event hits S/M/L: economy section 4.
5. Trees: 7 nodes per market (4 skills, 3 tech by crafting) plus 3 Foundations; old 15 skills mapped: core section 3, costs in economy section 5.
6. Events: two chains per market (3 and 4 steps), two choices each, every choice changes a bot stat (rule R-BOT), shared pool of 24 existing plus 12 new: core section 4.
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
| R9 | Shared pool says 25 kept, ids listed give 24; EV19, BE01 to BE03 not named | Keep EV19 and BE01 to BE03 in the pool as fire-once. Pool = 25 kept (EV18 retired) + 12 new. |
| R10 | Names: Dunmere Syndicate vs Dunmere Reach, Lattice Alloy vs Lattice Plate | Ostrel Syndicate, Seam Alloy (story doc). |
| R11 | End screen must not reveal the hidden record | No counts, labels or direction on the end screen. `END_STAT_RECORD` is removed. |
| R12 | Win rate is knife-edge (+-8% bot strength flips 100% to 0%) | Add one global `bot_scale` key so QA can tune; target focused win rate 56 to 98% as measured on the paper model, to be re-checked on the real game. |
| R12b | Bot strength scale | `bot_scale` = 0.85 in the sim, `bot_2_lux_strength` 1700 to 1900. |
| R13 | Price skills (MIL_4, LUX_1, LUX_6) change credits only because share uses base prices | Stay cash perks (owner may choose a small share effect, see Q4). |
| R14 | Open/Hard stance replaced (owner change, Q3) | Two neutral in-fiction options per step (`opt_a`, `opt_b`, shown in shuffled order); each gives the player something, costs something and changes at least one bot stat. Hidden `dir_<mkt>` (-100 to +100, one value per market, both chains feed it). Nudges grow late (B4 24 to 26). Echo x1.25 when the previous step in the chain pushed the same way; late swing x1.5 against the lean at B3/B4 when abs(dir) is 40 or more. Good ending at dir 10 or more, bad at -10 or less, between decided by the sign of the last nudge. No step fired = good. |
| R15 | Core 4.3 cell values vs economy | Economy section 8 wins (24 small retunes so no step's two options differ by more than ~10 win-rate points). |
| R16 | Effect line limit | 200 characters (was 90), format "Get / Cost / Rivals". |
| R17 | `EPI_NARROW` epilogue when the win market was decided by the tiebreak | Added by story; owner may remove (Q4 below). |
| R18 | Story placeholders | New: {cash_in}, {cash_out}, {n}, {cut}, {cut_std}; `{player_effect}` retired. |
| R19 | Approved loss rules were missing from the core doc, economy section 6 and the story loss endings | Applied everywhere: bankrupt = newest ship repossessed each cycle while cash is negative (360 credited), ends when no ship is left and cash still negative; swept = player under 10% in all four markets for 3 cycles from cycle 25. END_SWEPT renamed "The Floor of Every Graph". |
| R20 | Story Military text used first-pass numbers | Story re-aligned to economy 8.2 (B1 to B4 durations and sizes, no tier cut in B2, no Velvet boost in B3). Only MIL_A2 opt_b can cut a tier. |
| R21 | MIL_B3 opt_b had no player cost | Added cash -150 (spread vs opt_a still 7 points). |

Known gap, handled in the later goals: the preface, goal line, tutorial, mission board lines and the whole Release/Corporation ending set are out of date for the new goal. They are a rewrite task in the endings goal (Goal 6), not in this pack.

## Caveats
- The numbers come from a ramped paper model, not the real route engine. Every win cycle must be re-checked in a bot run on the real game (Goals 2 and 3).
- Skill point supply (about 21 against 13 for one market, 23 for two) assumes 7 of 9 reachable planets and 5 route pairs. UNKNOWN until the real game confirms it.
- Only the Military chains and 6 of the 12 new pool events are written. Luxury, Minerals, Biotech chains follow the story style guide in Goal 5.

## Owner answers (2026-11-03)
1. 40 cycles: approved.
2. Old saves dropped, EV18 retired: approved.
3. Choices must not be framed as good or bad; the chain decides the direction: IMPLEMENTED as R14 in this revision. Owner to confirm the result reads right.
4. Price skills get NO share effect (cash perks only): decided.
5. Swept (player under 10% everywhere) and bankrupt (ship repossession): approved.
6. Global `bot_scale` key and the 56 to 98% focused win rate: approved.
7. Names (bots, goods, endings): undecided, to be judged in play. Names stay as in the story doc until then.

## Open questions for the owner (after the revision)
1. Late cash is worth almost nothing: a focused player has about 12k unspent after cycle 16, so cash and upkeep trade-offs at B3/B4 barely bite. Economy balanced it by retuning bot sizes. Alternative: a late cash sink (upgrade cost 900 to 1500). Which?
2. Tier -1 cuts on bots fire before the bot's first tier-up (cycles 11 to 14), so they act as strength cuts. A persistent tier offset fixes it and makes those options about 5 points stronger. Apply?
3. A 85/15 spread still wins 4.6% of runs. Leave it, or raise `market_active_pct` to 0.15?
4. Keep `EPI_NARROW`? A sharp player may infer the last choice mattered.
5. Effect lines show credits and tech units as numbers but volume, price and upkeep as size words. Make all numbers (line limit about 230)?
6. Boosted bots show as "strength up" in the Standings. A player may read that as a mistake in hindsight. Intended?
7. Button order is shuffled per run so a position never means anything. Acceptable for the UI build?
8. Win medians land at cycle 26 to 28 (core said 28 to 36). Moving them later needs `bot_scale` near 0.88, which drops some path win rates below 56%. Accept 26 to 28?
9. Between -9 and +9 the last nudge decides the ending. OK, or use a coin of the run seed?
10. A strong lean turned late by the last two steps is not detected by the epilogues. Needs the game to expose the sign of `dir` before B3. Skip?
11. Is "contract" colder than "garrison" in MIL_B4? Playtest before the other three chains are written?
12. Names stay as in the story doc until you judge them in play.
13. Rescue stipend vs repossession: the game pays a 1000 rescue every stalled cycle with no cap, which would hide repossession for a negative-cash spreader. Proposed: check repossession first, pay no stipend in a cycle with a repossession, and pay only the first two stipends (`rescue_max` 2). Approve?
14. END_SWEPT can only fire for a four-market spreader whose fleet has already been repossessed (84% at 2 ships left, 100% at 1; a focused player 0%). A three-market spreader goes bankrupt instead. Accept that swept is rare?
15. Win rate by committed policy: always taking the "+" direction option wins 70/96/94/58% (mil/lux/min/bio), always the "-" option 88/80/74/80%. No single step is dominant (max 10 points), but committing the whole chain one way swings win rate by up to 22 points and the sign differs by market. Also Luxury with opt_b every step wins 99%, above the 98% ceiling, and 13 of 512 paths sit outside 56-98%. Accept, or retune?
16. Honest status: all figures are from the economy-designer's paper sim and were not re-run here; they need a real-game check in Goals 2 and 3.
