# Branch goods: every resource belongs to one branch, energy is the only shared good

Date: 2026-11-05. Task T238. Author: feature-designer. Status: waits for the owner. No numbers here: tier and role only; gameplay reuses the existing price band of each tier (economy-designer pins values). One proposal, ranked 1 of 1.

## Problem
Food and ore feed any market and energy sits in Military, so a Biotech player can sell weapon goods and the four companies look alike. The owner wants each company to trade only its own goods, with energy the one universal good.

## Idea
- Each good gets exactly one owner branch. A company sees, buys, sells, routes and stores only its own branch's goods plus energy. Other branches' goods are not drawn at all (Availability rule, see section 6).
- Energy belongs to no market. It sells for cash but adds no share. `common_raws` shrinks to energy alone.
- Each branch keeps today's chain depth: starter (T1), trade goods (T2), two crafted goods (T3, T4), one workshop.
- Every branch has a starter that sells at the home world Voltara from cycle 0. One new living world in system 1 makes this work for all four (section 3).
- Recipes keep today's shape (same input count and tier), so existing price bands and the two-ship feeding rule hold.

## The player's new choice
Which company you pick now decides what you can trade at all. Each branch has its own cycle-0 lane, its own mid-game goods and its own system-2 buyers. Energy is the only good where branches meet, so an energy lane is the one shared fallback and workshop fuel.

## Risk
- The "focus on one market, spreading loses" pillar is now enforced by the rules. Spreading penalty, mixed-load penalty and the other three skill trees need an owner ruling (question 1).
- Energy lanes could become a no-brainer income for all. Keep energy's margin below every starter's (economy-designer).
- A catch-all urban buyer (s2_p4) would flatten route choice. Each branch gets a second crafted buyer in system 2.

## 1. Goods per branch
Kind: trade = bought at a planet, mined = cluster or dead world, crafted = workshop. "Keep" = id and recipe stay, only the owner branch changes.

### Shared
| id | name | tier | kind | recipe | produced | bought | world line |
|---|---|---|---|---|---|---|---|
| energy | Energy | 1 | trade | none | Voltara, s2_p2 | Tillam, Ashgate, Brannock, s2_p1, s2_p3, s2_p4 | The only thing every company needs and every sky sells. |

### Military (workshop: Munitions Line)
| id | name | tier | kind | recipe | produced | bought | world line |
|---|---|---|---|---|---|---|---|
| powder | Blast powder | 1 | trade | none | Brannock | Voltara, s2_p3 | Grey grit in sacks; every fleet starts here. STARTER. |
| rivets | Bulkhead rivets | 2 | trade (sale-only, as today) | none | Voltara | s2_p2, s2_p4 | Keep. Hull hardware for a yard that never stops. |
| spyware | Spy software | 2 | trade (sale-only) | none | s2_p3 | s2_p4, s2_p2 | Was chips. Listening code sold to those who like to know. |
| rounds | Munitions | 3 | crafted (M) | energy 2 + powder 1 | Munitions Line | Voltara, s2_p2 | Was cells. Loaded and counted; the Plan wants them. |
| arms | Weapons | 4 | crafted (L) | rounds 4 | Munitions Line | Voltara, s2_p4 | Was armour. Rail carbines and gun racks in crates. |

Why: chips left the recipe because powder is the second Munitions raw (energy plus powder keeps two-line feeding). Chips become identity goods that only sell.

### Luxury (workshop: Atelier)
| id | name | tier | kind | recipe | produced | bought | world line |
|---|---|---|---|---|---|---|---|
| blooms | Hothouse blooms | 1 | trade | none | Ashgate | Voltara, s2_p3 | Petals picked at dawn; scent is the cheapest status. STARTER. |
| silk | Dune silk | 2 | trade | none | s2_p1 | s2_p4, Voltara | Keep. Moves like water, priced like a sin. |
| musk | Musk | 2 | trade | none | Tillam | s2_p1, s2_p4 | Keep. Costs little where it is made. |
| attar | Attar | 3 | crafted (M) | blooms 3 | Atelier | Voltara, s2_p4 | Was cask (food input would cross branches). Bottled scent. |
| gems | Cut gems | 4 | crafted (L) | silk 2 + musk 1 | Atelier | Voltara, s2_p1 | Keep. Stone, thread and a name on the list. |

### Minerals (workshops: Smelter and Fabric)
| id | name | tier | kind | recipe | produced | bought | world line |
|---|---|---|---|---|---|---|---|
| ore | Raw ore | 1 | trade + mined | none | Brannock (market, cycle 0); clusters (Prospecting) | Voltara, s2_p2, s2_p4 | Keep. STARTER. Brannock sells it from cycle 0; clusters stay the cheaper bulk source later. |
| dross | Dross (salt) | 2 | mined | none | Cinderrest | Voltara, Ashgate | Keep. Bad rock that someone will smelt anyway. |
| nullglass | Nullglass | 2 | mined | none | Greywake | s2_p2, s2_p4 | Keep. Humming glass. |
| ingot | Ingot | 2 | crafted | ore 2 | Smelter | Voltara, s2_p2 | Keep. |
| plate | Lattice plate | 3 | crafted | dross 2 + nullglass 1 | Fabric | Voltara, s2_p4 | Keep. Fabric stays the plate station. |
| alloy | Alloy | 4 | crafted (L) | plate 1 + ingot 2 | Smelter | Voltara, s2_p4 | Keep. |

Minerals needs no new good: it is already the most identity-rich branch (dead worlds, Null Core).

### Biotech (workshop: Culture Lab)
| id | name | tier | kind | recipe | produced | bought | world line |
|---|---|---|---|---|---|---|---|
| food | Food | 1 | trade | none | Tillam, Ashgate, s2_p1, s2_p3 | Voltara, s2_p2, s2_p4 | Keep. STARTER. Biotech only now: feeds the vats. |
| spores | Spores | 2 | trade | none | Tillam, Ashgate | s2_p4, s2_p2 | Keep. Fruiting bodies that make medicine and trouble. |
| medicine | Medicine | 3 | crafted (M) | food 2 + spores 1 | Culture Lab | Voltara, s2_p4 | Was gel. Clinic stock in cold boxes. |
| seed | Engineered seed | 4 | crafted (L) | medicine 2 + spores 1 | Culture Lab | Voltara, s2_p1 | Keep id. Crops built to order; harvests that pay twice. |

Bio has one T2 trade good, as today. Say so if you want a second.

## 2. Starter lane at cycle 0 (all four work)
Only Voltara is open at start (discovery on). Each starter is sold at Voltara and made at a system-1 world the Pathfinder reaches first:
| Branch | Starter | Buy at | Sell at home |
|---|---|---|---|
| Military | powder | Brannock | Voltara |
| Luxury | blooms | Ashgate | Voltara |
| Minerals | ore | Brannock | Voltara (ore_sell exists today) |
| Biotech | food | Tillam or Ashgate | Voltara (works today) |
Energy stays the all-branch fallback (Voltara to Tillam, as today's energy lane). Starter margin must beat the energy lane's (economy-designer).

## 3. Planets and systems (counted from data: system 1 has 3 living worlds plus Cinderrest, system 2 has 4 living worlds plus Greywake)
| World | Fate and role |
|---|---|
| Voltara (home) | Keep. Energy source. Buys every branch's starter and T3/T4 (home must always pay a starter). Voltara also makes rivets. |
| Tillam | Keep. Biotech and Luxury source (food, spores, musk); buys energy. |
| Ashgate | Keep. Luxury blooms, Biotech food and spores; buys energy and dross. |
| Brannock (NEW, system 1, barren quarry colony) | Military powder and Minerals ore source; buys energy. Needed because no current system-1 world fits a gunpowder or quarry starter. Fallback: retype Ashgate (question 2). |
| Cinderrest | Keep (Minerals only). |
| s2_p1 ocean hub | Keep. Silk, food source. Buyer: Lux (musk, gems, seed). |
| s2_p2 desert, energy-rich | Keep. Military and Minerals buyer (rivets, spyware, rounds, ore, nullglass, ingot), Bio (food, spores). |
| s2_p3 agrarian outpost | Keep. Military (powder), Luxury (blooms) buyer; spyware source. |
| s2_p4 urban | Keep as a buyer for all four branches, but crafted goods also sell at one other s2 world each (columns above). |
| Greywake | Keep (Minerals only). |
Every branch has at least two buyers in system 1 (Voltara plus one other) and at least two in system 2. Planet descriptions and roles change text only (story-designer).

## 4. Fate of today's goods
| Today | Fate |
|---|---|
| energy | Keep, leaves Military, shared. |
| food | Keep, Biotech only, leaves common raws. |
| ore | Keep, Minerals only, leaves common raws; now also buyable at Brannock. |
| chips | Rename spyware, sale-only (recipe use ends). |
| rivets | Keep, Military. |
| silk, musk | Keep, Luxury. |
| dross, nullglass, plate, ingot, alloy | Keep, Minerals. |
| spores, seed | Keep, Biotech. |
| cells | Rename rounds. |
| armour | Rename arms (recipe stays rounds 4). |
| cask | Rename attar, input blooms (food leaves Luxury). |
| gel | Rename medicine. |
New: powder, blooms. Dropped: none.

## 5. What changes for energy as the shared good
- Market: out of Military in `data/markets.json`; `common_raws` becomes [energy]. Food and ore join their branches' share goods.
- Share: energy sales count toward no market. Chain trigger "first sale of a non-common-raw good" now fires on a starter sale (earlier for Biotech and Minerals than today, since food and ore used to not count). Story and economy must check chain timing.
- Price and buyers: stays priced by planets (cheap at Voltara and s2_p2, dear elsewhere). Margin stays below every starter. No branch may price energy differently.
- Recipes: Military rounds keep energy 2. Recommend one small energy per T3 recipe in all four workshops so every company needs an energy lane (question 3).
- Storage Link: upkeep stays energy only. Now fair for all branches, since only energy is held by everyone. Energy must show at start for every branch and in Space Storage rows (it already does).
- Events: energy price events hit everyone; events that name food, ore, chips, cask or gel need branch filters (the existing filter uses good_visible) and a text check.
- Mixed load: a lane of energy plus a branch good no longer counts as mixed (energy is no market).

## 6. What must change in the game (for the producer)
| Item | Agent | Size |
|---|---|---|
| New Availability atom `branch_is:<id>` and branch-aware start state (4 start states, not 1); each good rule gains its branch | gameplay-programmer | M |
| markets.json, goods.json owner fixes, common_raws, new Brannock world and planet_prices for powder and blooms, renames | gameplay-programmer, economy-designer (prices by tier) | M |
| Re-test of recipes, bots and chain triggers after rename and recipe changes | economy-designer (owner-called only) | M |
| Names, planet and Brannock descriptions, skill texts that name cells, armour, cask, gel, chips, food, ore (MIL_4 "hull", LUX_4 "Cold Cellar") | story-designer | M |
| Icons (below) | juice-programmer or the art-atlas owner | M |
| Goods lists in UI follow Availability | ui-programmer | S |
Total: L. Ship in one go; goods half-moved would break the start state.

## 7. Icon briefs (64 px, one silhouette, one dominant colour; background transparent)
New or re-drawn:
| id | shape | colour | silhouette |
|---|---|---|---|
| powder | open sack with a pile spilling out | charcoal grey, orange spark dot | wide triangle with a notch |
| spyware | eye inside a chip square with a dotted scan line | teal on dark | square with a round pupil |
| rounds | three short shells standing side by side | brass and dull red tips | three vertical bars with rounded tops |
| arms | crossed carbine and rail bar | gunmetal blue-grey | an X with a long barrel |
| blooms | five-petal flower on a short stem | magenta and cream | round bloom on a thin line |
| attar | small teardrop bottle with a tall stopper | amber gold | pear shape under a stopper |
| medicine | capsule over a small cross | mint green and white | pill with a cross |
Kept as they are (cells to rounds, armour to arms, cask to attar, gel to medicine, chips to spyware are the renames above): energy, food, ore, rivets, silk, musk, dross, nullglass, plate, ingot, alloy, gems, spores, seed. Seed art may add a small gene helix so it reads "engineered". No two icons share a colour AND silhouette within a branch.

## open_questions (UNKNOWN)
1. UNKNOWN: Can a company still learn the other three skill trees and win another market? If trades are locked, the spreading penalty, three of four chains and rival-cutting skills (Embargo Desk, Guild Seal, Patent Wall) apply only to your own branch. Keep, hide, or retire them?
2. UNKNOWN: Add one new system-1 world (Brannock, recommended) or retype Ashgate to carry Military and Minerals starters?
3. UNKNOWN: Does energy join every T3 recipe (recommended), or only Military's as today?
