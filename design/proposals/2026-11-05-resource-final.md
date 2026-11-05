# Resource final audit (2026-11-05, economy-designer)

Data audited: goods.json v3, markets.json, availability.json, skills.json, after skill round 2 (armour = 4 cells, gems = 2 silk + 1 musk). `sh tools/tests/run.sh`: pass=1866 fail=0.

## Result
One orphan remains: rivets. Everything else is consumed. Rivets is kept as an argued sale-only trade good (below). No recipe change was shippable: see section 2.

## 1. Good by good

| Good | Mkt | Source | Use | Role |
|---|---|---|---|---|
| energy | mil | Voltara, s2_p2 buy | cells; trade | start lane, mil raw |
| food | bio | Tillam, Ashgate, s2_p1/p3 | cask, gel; trade | start lane, lux+bio raw |
| ore | min | mined | ingot; sale | min raw |
| dross | min | mined (MIN_3) | plate; trade | Fabric input |
| nullglass | min | mined (MIN_5, sys 2) | plate | Fabric input |
| chips | mil | s2_p2 buy | cells; trade | mil T2 input |
| rivets | mil | Voltara buy 20 | sale only, sys 2 sells 40-42 | mil export lane, see 2 |
| silk | lux | s2_p1 buy | gems | lux T2 input |
| musk | lux | Tillam buy | gems | lux T2 input |
| spores | bio | Tillam, Ashgate | gel, seed | bio T2 input |
| plate | min | Fabric | alloy; sale | min T3 |
| ingot | min | Smelter | alloy; sale | min T2 |
| alloy | min | Smelter | sale | min end product |
| cells | mil | Munitions | armour; sale | mil T3 |
| armour | mil | Munitions (4 cells) | sale | mil end product |
| cask | lux | Atelier (3 food) | sale | lux T3 |
| gems | lux | Atelier (2 silk + musk) | sale | lux end product |
| gel | bio | Culture Lab | seed; sale | bio T3 |
| seed | bio | Culture Lab | sale | bio end product |

End products are sold only. Skills and tech use credits and crafted units of a market, not named goods.

## 2. Why rivets stays sale-only
- Recipes may use only own-market goods plus common raws (test `every recipe uses common raws and own-market goods only`), so rivets (mil) can only go into cells or armour. Alloy was tried: the test fails, correctly.
- Bot feeding allows two raw inputs (`FEED_SHIPS` 2). Munitions already needs energy and chips. Tried armour = 3 cells + 1 rivets: focus mil seeds 1-2 made 0 armour (baseline 27), 78 cells unused. Reverted.
- Swapping cells to energy + rivets only moves the orphan to chips.
- Market role (stated): rivets is the cheap entry lane into system 2. Bought at Voltara 20, sells at s2_p2 40 and s2_p4 42 (+100%), base value 33 in markets.json, event and market-share demand data present. It is the one mil good a new player can carry before chips and cells exist.

If the owner insists on a recipe: raise `FEED_SHIPS` to 3 in qa/bots/bot_run.gd (QA) and set armour = 3 cells + 1 rivets with an availability rule `good_visible:rivets`. Not done.

## 3. Verification (decent, --skip-tutorial)
- Default, seeds 1-4: 4/4 wins, cycle 27 (cash 30.0k, 30.7k, 31.2k, 22.9k).
- Focus mil seeds 1-2: win 27; armour 27 crafted each.
- Focus lux seeds 1-2: win 27; only cask crafted (33-35), gems 0. Same before and after my data (gems 2 silk + musk is feedable; the bot opens gem feeds late, per round 2). Not caused by this task. QA/Gameplay to look at it.

## 4. Changes
goods.json v2 to v3: notes only (rivets note, source). availability.json: rivets note only. balance.json unchanged. No test change needed.

## 5. Story ids
No recipe text changes. Recipes show through tooltips automatically. Optional: GOOD_RIVETS_DESC, add "Bought at Voltara, sold at the system 2 yards" (max 110 chars, hidden-good rule safe). Round 2 ids (SK_MIL_4 armour 4 cells, SK_LUX_4 gems silk + musk) are already in the round-2 doc.
