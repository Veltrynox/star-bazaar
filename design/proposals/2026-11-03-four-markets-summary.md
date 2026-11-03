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
| R6 | "Variant chosen by the last choice" is ambiguous | Per chain: the previous step in the same chain. B1 has one body. |
| R7 | Tie on the marked bot is undefined | Lower bot number wins the tie. |
| R8 | Tier cut text "drops a tier" on a bot already at tier 1; MIL_A2 Open has no effect | Texts must say nothing happens to a bot at tier 1; MIL_A2 Open gets a small growth cut so R-BOT holds. |
| R9 | Shared pool says 25 kept, ids listed give 24; EV19, BE01 to BE03 not named | Keep EV19 and BE01 to BE03 in the pool as fire-once. Pool = 25 kept (EV18 retired) + 12 new. |
| R10 | Names: Dunmere Syndicate vs Dunmere Reach, Lattice Alloy vs Lattice Plate | Ostrel Syndicate, Seam Alloy (story doc). |
| R11 | End screen showing Open/Hard counts reveals a hidden record | Do not show the counts. |
| R12 | Win rate is knife-edge (+-8% bot strength flips 100% to 0%) | Add one global `bot_scale` key so QA can tune; target focused win rate 56 to 98% as measured on the paper model, to be re-checked on the real game. |
| R13 | Price skills (MIL_4, LUX_1, LUX_6) change credits only because share uses base prices | Stay cash perks (owner may choose a small share effect, see Q4). |

Known gap, handled in the later goals: the preface, goal line, tutorial, mission board lines and the whole Release/Corporation ending set are out of date for the new goal. They are a rewrite task in the endings goal (Goal 6), not in this pack.

## Caveats
- The numbers come from a ramped paper model, not the real route engine. Every win cycle must be re-checked in a bot run on the real game (Goals 2 and 3).
- Skill point supply (about 21 against 13 for one market, 23 for two) assumes 7 of 9 reachable planets and 5 route pairs. UNKNOWN until the real game confirms it.
- Only the Military chains and 6 of the 12 new pool events are written. Luxury, Minerals, Biotech chains follow the story style guide in Goal 5.

## Owner answers (2026-11-03)
1. 40 cycles: approved.
2. Old saves dropped, EV18 retired: approved.
3. CHANGE REQUESTED: choices must not be labelled or framed as obviously good or bad, and no single choice should clearly push one way; the CHAIN of choices should push the player toward an ending direction. Open/Hard labels and +1/-1 stance per step are to be redesigned (Goal 1 rerun).
4. Price skills get NO share effect (cash perks only): decided.
5. Swept (player under 10% everywhere) and bankrupt (ship repossession): approved.
6. Global `bot_scale` key and the 56 to 98% focused win rate: approved.
7. Names (bots, goods, endings): undecided, to be judged in play. Names stay as in the story doc until then.

## Original open questions
1. Run length: 40 cycles OK (was 30)?
2. Old saves are dropped (new save version) and the shield event EV18 is retired. OK?
3. Ending quality depends only on the Open vs Hard stance of the winning market's chains. Tie counts as good. OK? Is the soft `END_OUTCOMPETED` (no market over 50% at cycle 40) an acceptable non-win?
4. Should price skills also give a small share effect, or stay cash perks?
5. Approve R3 (swept = player under 10% everywhere) and R4 (ship repossession) as the way the two loss endings can happen?
6. Approve the global `bot_scale` key and a 56 to 98% focused win rate?
7. Bot names (3), good names and ending names are settled in the story doc. Any you want changed before they spread into texts?
