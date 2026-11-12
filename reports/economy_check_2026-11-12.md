# Economy check, first full run, 2026-11-12

How it was made: `sh qa/check/run.sh` played 58 headless games through the real game scene (every play style, each with the CEOs it fits, two seeds; the full 80-cycle term, then 3 cycles of free play). The bots act only through what a player can click. The generated detail is in `qa/check/out/report.md` (not in git); this file is the reading of it.

Done today before the run: the dead mechanics were removed, the event set was raised to 25 shared / 15 per branch / 10 chain steps, and eleven bugs found by the first bot games were fixed (listed at the end). The run below is on that state.

## 1. Does the game work?

Yes, for 80 cycles and three endings out of four. No crash, no freeze, no softlock, every event window answerable, Continue works in every game. The run engine, routes, orders, ships, skills, workshops, mining, platforms, Fabric, Null Core, raids, salvage, hubs, Space Storage, Storage Link, permits, Flagship flight and dock, signal gigs, Bazaar founding and stages 1 and 2 were all exercised and behaved.

| Outcome | Games | Styles |
| --- | --- | --- |
| Soft ending (term ran out) | 50 | every builder style |
| Bankrupt | 8 | reckless, by design |
| Win | 0 | no style finished the Bazaar |

The only health marks left after the fixes:
- One game (founder, Luxury CEO, seed 1) counted 3 ships assigned while owning 2 from cycle 26 to the end. See open items.
- Two of 48 save-and-load round trips lost one local order (16 to 15; 10 to 9). See open items.
- `Lambda capture at index 0 was freed` in 5 game logs, origin not yet traced (game or the bot's reload).

## 2. What the styles showed (median of each style's games)

| Style | Cash at end | Peak ships | 2nd ship | First tier 2 | First tier 3 | Bazaar | Idle streak |
| --- | --- | --- | --- | --- | --- | --- | --- |
| trader | 18k | 15 | c8 | c12 | c21 | founded c13, stage 1 | 7 |
| founder (plays to win) | 30k | 15 | c11 | c10 | c19 | founded c11, stage 2 | 11 |
| captain (Flagship) | 59k | 3 | c7 | c9 | c16 | no | 4 |
| expander (systems) | 60k | 15 | c7 | c13 | c24 | no | 38 |
| industrialist (workshops) | 53k | 9 | c8 | c13 | c16 | no | 12 |
| miner (Minerals only) | 24k | 9 | c5 | c4 | c26 | no | 17 |
| idler (one lane, nothing else) | 19k | 1 | never | never | never | no | 80 |
| reckless (fool on purpose) | 28 | 4 | c2 | never | never | no | 7 |

Idle streak = the longest run of cycles in which the style could not or did not do anything.

## 3. What stands between the game and the final

### 3.1 Nobody can win, and the reason is ore
The Bazaar needs worlds at high tiers and a goods bill at the capital. On a Minerals run every world's need list carries ore, every rush order asks for ore, and the reclaim list asks for ore; but ore has no seller anywhere, clusters run dry by cycle 11, and each dead world holds 240 units that the Fabric eats by cycle 45. The founder stalled at stage 2 (bill 0 of 30 plate, quorum short), the miner's reclaim stalled at 4 of 5 steps, the captain let 29 of 29 rush orders expire. On other branches the founder met stage 3's bill and quorum and failed only the "a world in another system at tier 2" rule, which the bot does not pursue yet; so a Biotech or Luxury win looks reachable with a better bot, a Minerals win does not with any bot.
Suggested: give ore a slow renewable source (cluster regrowth, or a dead world that keeps yielding at a trickle after reclaim), or take ore out of world needs and rush orders and keep it for the workshop chain.

### 3.2 The late game is empty
Every builder style hits the 15-ship cap between cycle 37 and 70 and then sits on growing cash with nothing to buy: 50k to 170k by the end, idle streaks of 26 to 61 cycles for the expander. Income never stops, so the last third of the term is waiting. The idler shows the floor: one ship, one lane, no further spending still earns 230 to 270 a cycle and 19k by the end, and nothing ever happens to a player who does nothing.
Suggested: late sinks that matter (Bazaar stages 3 and 4 priced in the tens of thousands, ship cap raised by wings or permits, world upgrades), and a reason to keep acting (needs that decay a tier when starved for long, events that cost idle players).

### 3.3 Going wide does not pay
The expander opened system 2 at cycle 6 to 32 and system 3 at 21 to 54, posts at 540 each, permits 600 and 1500. Lane income from systems 2 and 3 summed to zero or slightly negative over the term; all growth came from system 1. Systems 4 and 5 are switched off in the data (`systems_placeholder.json`), although the GDD and the availability notes call 3 to 5 live. A Storage Link was never built in any game: the refusal is always "needs goods" and no bot (and probably no player) finds out which. 
Suggested: make a new system carry something system 1 lacks (a good, a buyer, a cheaper source of the branch's tier-2 inputs), and say on the link card which goods it needs.

### 3.4 The Flagship loop is thin
Hand trade earned 5 to 25% of lane income (energy, 17 units a trip, 80 to 180 credits a trip), the Flagship idled 25 to 29% of the time, and in 16 to 24 of 80 cycles the board had no gig at all. Signals and salvage work; rush orders mostly ask for goods the captain cannot get (ore on Minerals; spores, musk, silk elsewhere) and 19 to 29 expired per game against 0 to 6 done. The four new signal gigs wired today were not in this run's styles yet.
Suggested: rush orders only for goods some reachable world sells; a bigger hold or a hold upgrade as a wing; a gig on the board most of the time.

### 3.5 Making things starts too late and sometimes never
The first extra ship costs about 1,035 against a few dozen credits a cycle from the first lane; in maker runs the second ship came as late as cycle 37 to 65 and the first workshop at 22 to 65. Once fed, a smelter pays back clearly (197 ingots against a 900 fee); the munitions line never made a round in 60 cycles because its feed lanes lost the cash race to the trading lanes (Buy orders are capped by cash after the route reserve). Crafted goods can also be bought outright at Voltara and system 2 (rounds 78, ingot 40), so the workshop is a long-term bet, not a step.
Suggested: a cheaper second ship or a stipend-like starter loan for the first workshop; show the cash-after-reserve state on the planet card (today it is only a tooltip; this is also what you saw in system 3 as "1 energy per cycle").

### 3.6 Bankruptcy is odd, and the fool survives on a technicality
Cash never goes below zero by play: a losing lane idles and costs nothing, so repossession and its ending text can never happen. Both rescue stipends fire by cycle 3 (the first one just because buying ships pushed cash under a ship price), and the deliberate fool ends through the dead-end rule at cycle 6 to 10 with 28 to 60 credits in hand.
Suggested: a standing upkeep that is paid whether a lane runs or not, so debt is possible and repossession means something; the stipend only after a real loss.

### 3.7 Worlds that cannot grow
Eleven CEO-and-world pairs had an empty need list (the world already sold the branch's only tier-1 good): Flintmoor on Military, Ashgate on Luxury, Ashgate and Tillam on Biotech, and all seven system 2 and 3 worlds on Biotech. They never gained a tier and warned every cycle. All eleven now have a need by data override, as Voltara already did. Side effect to decide: the feeding lane buys the good where it is sold at 11 to 12 and sells it back at 9 to 10, a loss after trip cost, and the four Biotech worlds that sell food cheaply have no cheaper neighbour at all. The real fix is one more tier-1 good per branch, or letting a world need the next tier's good.

### 3.8 Events
110 distinct events fired across the games; 22 of the 125 wired never did, mostly late ones (chain C2 and C3 steps need Bazaar stages 2 and 3; EV42, 44, 45, 47, 48, 51 need a workshop good visible; EV53 to EV55 need the branch's good traded in the first cycles; EV60, 70, 81, 92, 93, 96 are gated later or on worlds few games reached). Nothing fired that should not have. The balance numbers of all new events are placeholders.

## 4. Coverage
92 of 104 player actions were done successfully by at least one style. Never reached: the win and the CEO endings, the Opening gig, a finished reclaim, hub need-switch and hub release, Storage Link orders and removal (no link was ever built), a Flagship plain fly order (styles use fly-and-establish), surplus pricing. No action was refused in every game, and no player action turned out to have no entry point.

## 5. Open items from this run
- Founder / Luxury CEO / seed 1: 3 ships assigned against 2 owned from cycle 26: a real bug, fixed after the run. Repossession with no free ship and no route left still took a ship off the count but never out of the hub pool; it now takes one from the pool. (Side note: this game did reach repossession three times, so negative cash is possible with hubs; the reckless style never got there because its lanes idle.)
- One local order lost in 2 of 48 save-load round trips: traced and fixed after the run (a Sell order whose buyer comes from a world's need was loaded before the need state and dropped as "not traded here"; orders now load after prosperity). Both round trips are clean with the fix.
- `Lambda capture at index 0 was freed` in 5 game logs: origin unknown.
- The captain style got the stale notice "The Pathfinder arrived at Flintmoor." back as the reason for a refused signal gig; a wrong reason text, not a wrong refusal.
- Systems 4 and 5: switched off in the data, called live in the docs. Decide which.
- Russian: the new and reworded texts have no translation yet (2295 of 2718 ids).

## 7. Second run, after the changes of the afternoon

The same 58 games were played again after the dead-world rule (every company mines its own raw), the four directions (ore as an input with regrowing clusters, obtainable rush goods, cheaper first ships and feed-first orders, upkeep whether lanes run or not with a stipend only after a loss), the route guard and the three-systems cut.

| Style | Cash at end | Peak ships | 2nd ship | First tier 2 | First tier 3 | Bazaar | Repossessions (8 games) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| trader | 7k (was 18k) | 15 | c6 (was c8) | c13 | c24 | founded c14 | 8; one game bankrupt at c74 |
| founder | 0.1k (was 30k) | 13 | c11 | c14 | c19 | founded c15, **stage 3** (was 2) | 26; two games bankrupt at c56 and c63 |
| captain | 58k | 3 | c6 | c10 | c16 | no | 0 |
| expander | 4k (was 60k) | 15 | c6 | c12 | c36 | no | 17 |
| industrialist | 40k | 9 | c6 (was c8) | c9 | c15 | no | 2 |
| miner | 49k (was 24k) | 11 | c6 | c8 | c62 (was c26) | no | 0 |
| idler | 19k | 1 | never | c6 | c12 | no | 0 |
| reckless | 0.01k | 3 | c2 | c7 | never | no | 19; bankrupt at c9 to c17 (was c6 to c10, no repossession) |

What the changes did:
- **Debt is real now.** Repossession happens by play (72 across the matrix, none before), bankruptcy comes through debt and the fool lasts to cycle 9 to 17 instead of 6 to 10. The founder reached Bazaar stage 3 for the first time (ore no longer blocks the Minerals bill chain).
- **Too harsh at the placeholder numbers for anyone who parks ships.** The expander and the founder buy to the 15-ship cap and leave ships idle; at 10 credits a cycle per idle ship plus the upkeep of idle lanes they bled into repossession, and three builder games went bankrupt in the last third of the term. The bots do not watch the forecast; a player would, but the numbers still need tuning: the idle upkeep goes to 5 as a first step, and the economy designer should set the rest when you call for a balance pass.
- **The miner's first tier 3 moved from cycle 26 to 62**: with ore out of the need lists, a Minerals world's needs are energy and the branch's goods only, so tiers climb slower on that branch. Worth a look when the needs are next tuned.
- **Cheaper first ships worked:** second ship at cycle 6 for most styles (was 7 to 8).
- The idler and captain are unchanged; the late-game "cash only grows" rows remain for styles that reach the cap without a Bazaar.
- Health: no script error, no invariant break, 111 distinct events seen, one remaining save-and-load case (an order lost in 2 of 50 round trips) traced and fixed afterwards: a Sell order for a crafted good whose buyer comes from a need was loaded before the workshops, so the good counted as hidden; workshops now load before orders, and both round trips are clean.
- Goods never traded by any style: plate, rounds, arms, gems, alloy, seed (the tier-3 and tier-4 crafted goods); skills never learned: the tier-7, 12 and 15 nodes. These are the bots' limits as much as the game's.

## 6. Fixed today, before this run
Save and load dropped every route; the same cycle settled twice after Continue; a script error on the gig rings and three more places that read a planet index on a point-target gig; a hub carried goods out of Space Storage with no link or route; the capital's own needs ate the Bazaar stage bill; eleven worlds with no needs; "pay a small sum" event options could push cash below zero; the Opening had no window before the win.
