# Resource and crafting audit (2026-11-05, economy-designer)

Sources: data/goods.json, markets.json, availability.json, skills.json, planets.json, systems.json, game/workshops.gd. Test: `sh tools/tests/run.sh` passes (0 FAIL).

## 1. Table: good -> source -> consumers -> role

| Good | Mkt | Source | Consumed by | Role |
|---|---|---|---|---|
| energy | mil | Voltara, s2_p2 (buy 9-10) | cells; trade | start trade lane, mil input |
| food | bio | Tillam, Ashgate, s2_p1/p3 | cask, gel; trade | start trade lane, lux+bio input |
| ore | min | mined (clusters, FND_PROSPECT) | ingot, gems; sells 12-16 | raw for Smelter and Atelier |
| dross | min | mined Cinderrest (MIN_3, cycle 15) | plate; trade to Voltara | Fabric input |
| nullglass | min | mined Greywake (MIN_5, cycle 15, sys 2) | plate, Null Core | Fabric input |
| chips | mil | s2_p2 buy | cells, armour; trade to s2_p3/p4 | mil T2 input |
| rivets | mil | Voltara buy | trade to sys 2 | was ORPHAN (no recipe) |
| silk | lux | s2_p1 buy | gems; trade to s2_p4 | lux T2 input |
| musk | lux | Tillam buy | trade to sys 2 | was ORPHAN |
| spores | bio | Tillam, Ashgate buy | gel, seed; trade to sys 2 | bio T2 input |
| plate | min | Fabric (2 dross + 1 nullglass -> 1) | alloy, Null Core; sells 120 | min T3 |
| ingot | min | Smelter (2 ore -> 3) | alloy; sells 36 | min T2 |
| alloy | min | Smelter (plate + 2 ingot -> 2) | sells 160 | min T4 end product |
| cells | mil | Munitions (2 energy + chips -> 3) | armour; sells 70 | mil T3 |
| armour | mil | Munitions | sells 180 | mil T4 end product |
| cask | lux | Atelier (3 food -> 3) | sells 72 | lux T3 |
| gems | lux | Atelier | sells 130 | lux T4 end product |
| gel | bio | Culture Lab (2 food + spores -> 3) | seed; sells 74 | bio T3 |
| seed | bio | Culture Lab | sells 190 | bio T4 end product |

End products (alloy, armour, gems, seed) are meant to be sold only. Crafted goods are single-price (buy = sell x 1.12), so they are sold in place, not hauled. Skills and tech use credits and crafted units (any recipe of the market counts), not goods. Ships and upgrades cost credits only.

## 2. Findings

1. Orphans: rivets (mil) and musk (lux) made, only traded. FIXED: armour now takes 1 rivets, gems take 1 musk. Each market's two T2 goods now both feed a recipe (mil chips+rivets, lux silk+musk, bio spores, min dross+nullglass).
2. Armour needs Voltara rivets plus system 2 chips, gems need Tillam musk plus system 2 silk, so crafting ties both systems.
3. Recipe maths: all outputs exceed input base value (cells 78 -> 210, armour ~260 -> 540, gems ~61 -> 260, alloy 192 -> 320, seed 172 -> 380, cask 57 -> 216, gel 62 -> 222, ingot 26 -> 108, plate 57 -> 120). No loops. Batch rates fine. Margins after change: armour ~466 a batch (was ~486), gems ~218 (was ~236); both stay inside the economy doc bands.
4. NOT FIXED, needs skills.json: lux tiers are inverted. LUX_1 unlocks gems (T4, needs silk and musk, system 2) and LUX_4 unlocks cask (T3, food only). LUX_2 and LUX_4 techs need 9 and 18 crafted units, so a player must craft gems 14 batches before cask exists. Fix: LUX_1 unlocks cask, LUX_4 unlocks gems; then availability rules swap (cask: LUX_1 + atelier; gems: LUX_4 + atelier + ore + silk + musk; atelier: LUX_1 alone). I have not touched availability for this so it stays in step with skills.json. The skills agent should do the swap, then I (or they) apply the availability edit.
5. Alloy needs plate, plate needs nullglass (MIN_5, system 2, cycle 15), so alloy is effectively behind MIN_5 though its unlock node is MIN_4. Acceptable (the availability rule already checks plate visible); note for skills ordering.
6. No dead inputs found otherwise; no true duplicates (T3 goods at 70-74 are intentional parity across markets).

## 3. Changes
- goods.json (data_version 2): armour recipe + rivets 1; gems recipe + musk 1; cash_cost_per_unit armour 18 -> 25, gems 12 -> 21.
- availability.json (data_version 3): armour adds good_visible:rivets; gems adds good_visible:musk; notes updated.
- balance.json: unchanged. Sim does not model recipes; win rates unaffected for market-share runs. Bots: recheck lux and mil crafting runs only.

## 4. Open needs
- Skills agent: swap cask/gems unlock nodes (item 4).
- Code: none required (workshops.gd and recipe_ok handle 3 inputs). Optional: workshop picks highest tier first, so armour can starve cells; fine today.
- Story: item names unchanged; no text change needed. Tooltips "Used in" update automatically.
