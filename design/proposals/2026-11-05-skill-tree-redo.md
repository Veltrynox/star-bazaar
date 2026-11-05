# Skill tree redo, DRAFT (2026-11-05, economy-designer)

Status: DRAFT for feature-designer and qa-analyst review. data/skills.json, balance.json, availability.json are NOT edited yet. Shape is unchanged (3 FND + 4 x 7 nodes, tiers, prereqs, point costs 1/2/3/4, tech goals 9/18/12) so the screen and save code stay as is. Only effects, two unlock moves and a few values change.

Filler rule used: a node is filler if it is a flat 6-12% on something the player never has to decide about. Such effects are removed or replaced by something that opens a route, a batch, a good, an event answer or a rival action.

Identity per tree: MIL = defence and denial (cheap fleet, safe routes, rival control). LUX = timing and information (price events, forecasts, crafted luxury). MIN = production chain (mining, batches, plate, alloy). BIO = stockpile (storage growth, safe stock, endurance).

## Table (cost key = balance skill_cost_<id>, unchanged; tech = 0 points, goal tech_goal_*)

| id | old | new | verdict | why (decision / ties to / adds) | effect types |
|---|---|---|---|---|---|
| FND_STORAGE | Space Storage | same | keep | Decision: when to spend point 1; ties to Space Storage and BIO stock; balance | unlock feature space_storage |
| FND_PERMIT | Permit Charter | same | keep | Opens system 2: chips, rivets, silk, musk, spores; interest | unlock feature permit_routes |
| FND_PROSPECT | Prospecting | same | keep | Opens ore clusters (raw for ingot, gems); interest | unlock feature cluster_routes |
| MIL_1 | upkeep -20%, munitions, cells | same | keep | Cheap fleet pays on 4th-6th ship (maintenance 40 each); ties to munitions + cells; balance | upkeep_mult (skill_MIL_1_upkeep), unlock workshop munitions, good cells |
| MIL_2 tech | mil volume +8% | Second Line: munitions +1 batch/cycle | CHANGE | Volume +8% was unfelt. A second batch doubles cells output but needs double energy + chips hauled from system 2: a logistics decision. Ties to munitions, energy, chips; interest | workshop_batches mil (new key skill_MIL_2_batches 1) |
| MIL_3 | mil route cap +12.5% | Armed Convoys: mil routes immune to pirate and debris route events | REPLACE | +12.5% was filler. Immunity makes mil goods the safe lane; decision: run risky high-margin lanes with mil cargo. Ties to energy, chips, rivets; balance | NEW event_immune {target mil, kinds [pirate, debris]} |
| MIL_4 tech | armour unlock + mil price +6% | armour unlock only | CHANGE | Drop the 6%. Armour (540 value, needs cells + chips + rivets) is the payoff; ties to rivets and chips; interest | unlock good armour |
| MIL_5 | Embargo Desk: chosen bot -18% for 3 cycles, every 8 | same, retune hit 0.25, cycles 4 (sim) | KEEP, retune | Active ability: choose which rival, time it before the share check; interest and balance | bot_strength_pct chosen_bot |
| MIL_6 tech | mil event damage -50% | same | keep | Event answer: lets the player hold big mil stock through price events; pairs with MIL_3 | event_cut_pct mil |
| MIL_7 | all rivals' mil growth x0.5, permanent | same | keep | Capstone win lever: choose to commit to mil share; balance | bot_growth_mult all_bots |
| LUX_1 | price +6%, reveal prices 1 cycle, atelier, GEMS | reveal prices 1 cycle, atelier, CASK | CHANGE | Fixes inverted order (audit item 4). Drop +6%. Reveal gives next-cycle prices, so the player routes to the best planet; cask (food only, system 1) is a T3 good a tier-1 node can run. Ties to food, atelier; interest | reveal_prices, unlock workshop atelier, good cask |
| LUX_2 tech | price-up events pay +50% | same | keep | Pairs with LUX_1 reveal and LUX_3 forecast: chase events with stock. Crafted cask counts toward goal (9 units, 3 batches, doable) | event_bonus_pct lux |
| LUX_3 | event forecast 1 cycle, all markets | same | keep | Plan stock moves before an event; helps every tree; interest | event_warning |
| LUX_4 tech | cask unlock + lux stock safe from storage cut | GEMS unlock | CHANGE | Gems (needs ore + silk + musk, system 2 and permit) belong at tier 3. Stock_protect moves to BIO_5 (thematic: held stock). Ties to ore, silk, musk; interest | unlock good gems |
| LUX_5 | volume +15% on sales at price-up planets | same | keep | Rewards LUX_2/LUX_3 event chasing with share, not just cash; balance | volume_pct lux with condition sale_at_price_up_planet |
| LUX_6 tech | lux price +12% | Hallmark: sales of cask and gems lose half as much to saturation | REPLACE | +12% filler. Saturation relief lets the player dump crafted luxury at one planet instead of spreading lanes; ties to atelier output; balance and interest. Needs sim | NEW saturation_relief {goods cask, gems, key skill_LUX_6_saturation 0.5} |
| LUX_7 | once per run, rival lux -18% for 5 cycles | once per run, hit 0.30, cycles 8 (sim) | KEEP, retune | Once per run is felt only if strong enough to swing a share crossing; decision: when to fire | bot_strength_pct chosen_bot, once_per_run |
| MIN_1 | smelter, fabric, ingot | same | keep | Opens the whole chain; ties to ore | unlock workshops smelter, fabric, good ingot |
| MIN_2 tech | min volume +8%, ore orders ignore size cap | ore orders ignore size cap only | CHANGE | Drop the 8%. The cap bypass changes how mining routes run (bulk ore); ties to ore | ore_free_slots |
| MIN_3 | cluster yield +25%, mine dross at Cinderrest | same | keep | New route (dead world, cycle 15) plus real ore boost; ties to dross, plate | cluster_yield_pct, mine_unlock dross |
| MIN_4 tech | +1 batch, ALLOY unlock | +1 batch only (rename Second Crucible) | CHANGE | Alloy needs plate and plate needs nullglass (MIN_5), so alloy at MIN_4 was a dead unlock (audit item 5). Batches +1 is real: smelter and fabric both double | workshop_batches min |
| MIN_5 | mine nullglass at Greywake | same | keep | System 2 route; completes plate; ties to nullglass, fabric, Null Core | mine_unlock nullglass |
| MIN_6 tech | +1 unit per batch | +1 unit per batch AND ALLOY unlock | CHANGE | Alloy now appears when plate can exist (MIN_4 + MIN_5 done). Capstone payoff of the chain; ties to plate, ingot | batch_yield min, unlock good alloy |
| MIN_7 | all rivals' min strength -10%, permanent | -20% (sim) | KEEP, retune | -10% unfelt; capstone win lever for a mining-focused run | bot_strength_pct all_bots permanent |
| BIO_1 | order size +30%, culture lab, gel | culture lab, gel | CHANGE | Drop order size (flat, all markets, unfelt). Lab and gel are the node; ties to food, spores | unlock workshop culture_lab, good gel |
| BIO_2 tech | stock grows 2%/cycle up to 20% in planet storage | same | keep | Signature: stockpile compounds, so holding food and spores is a choice vs selling now; ties to storage | stock_growth_pct |
| BIO_3 | planet storage +50% | same | keep (borderline) | Scales BIO_2 (growth is a share of stock) and Space Storage feed; QA checks it is felt | storage_cap_pct |
| BIO_4 tech | seed unlock | same | keep | End product (spores + gel); interest | unlock good seed |
| BIO_5 | bio share window longer | bio share window longer AND bio stock safe from storage cut | CHANGE | Adds the stock_protect from LUX_4: the stockpile tree protects stock. Window stays as a win-rule lever | share_window, stock_protect bio |
| BIO_6 tech | bio events -25%, closed planet reopens 1 cycle sooner | same | keep | Event answer and rescue; pairs with BIO_5 | event_cut_pct bio, reopen_sooner |
| BIO_7 | all rivals' bio strength -10% permanent | -15% (sim) | KEEP, retune | Capstone; bio rivals are weakest, so smaller than MIN_7 | bot_strength_pct all_bots permanent |

Verdicts (31 nodes): keep unchanged 16, retune value only 4 (MIL_5, LUX_7, MIN_7, BIO_7), change 9 (MIL_2, MIL_4, LUX_1, LUX_4, MIN_2, MIN_4, MIN_6, BIO_1, BIO_5), replace 2 (MIL_3, LUX_6). No node is dropped; the removed filler is the percent part.

## Every good has a place

energy, food: start lanes. ore: FND_PROSPECT. dross: MIN_3. nullglass: MIN_5. chips, rivets, silk, musk, spores: system 2 trade, each feeds a recipe (cells/armour, gems, gel/seed). ingot MIN_1. plate: MIN_3 + MIN_5 (fabric). alloy MIN_6. cells MIL_1. armour MIL_4. cask LUX_1. gems LUX_4. gel BIO_1. seed BIO_4. No orphan.

## Data edits to apply together with skills.json after review (not applied)

- skills.json: effects above. MIN_4 loses unlock alloy, MIN_6 gains it. LUX_1 extra gems -> cask. LUX_4 effect cask -> gems, stock_protect moves to BIO_5. Remove sale_price_pct from LUX_1, LUX_6, MIL_4; volume_pct from MIL_2, MIN_2; order_size_pct from BIO_1; route_capacity_pct from MIL_3.
- availability.json: atelier = skill_learned:LUX_1 alone (drop the LUX_4 / system_open:2 + ore branch and its note). cask = LUX_1 + workshop_built:atelier. gems = LUX_4 + atelier + good_visible ore, silk, musk. alloy = MIN_6 + smelter + plate + ingot. Update the notes (cask LUX_1, gems LUX_4, alloy MIN_6). I did not edit it now: it must change with skills.json or the unlock check disagrees.
- balance.json: new skill_MIL_2_batches 1, skill_LUX_6_saturation 0.5. Retune (sim first): skill_MIL_5_hit 0.18->0.25, skill_MIL_5_cycles 3->4, skill_LUX_7_hit 0.18->0.30, skill_LUX_7_cycles 5->8, skill_MIN_7_strength_cut 0.1->0.2, skill_BIO_7_strength_cut 0.1->0.15. Unused after redo (remove): skill_MIL_3_route_units, skill_MIL_4_price, skill_LUX_1_price, skill_LUX_6_price, skill_BIO_1_order_units; skill_size_s. These need owner approval as new keys.

## Code for the gameplay-programmer (new effect types)

1. event_immune {target market, kinds: [pirate, debris]}: pirate volume penalty and debris route penalty do not apply to routes carrying that market's goods (MIL_3).
2. saturation_relief {goods: [...], key}: saturation price drop on sales of those goods x (1 - balance[key]) (LUX_6).
Existing types only otherwise. stock_protect must accept bio (BIO_5); workshop_batches already reads mil (Skills.workshop_batches(market) in workshops.gd).

## Text for the story-designer

Plain lines change for MIL_2, MIL_3, MIL_4, LUX_1, LUX_4, LUX_6, MIN_2, MIN_4, MIN_6, BIO_1, BIO_5. Renames: LUX_4 (Cask Cellar, now gems), MIN_4 (Alloying, now batches), LUX_6, MIL_3. No text may name a hidden good: LUX_1 line names cask only, LUX_4 gems, MIN_6 alloy, only when the node can be seen (node screen already shows names; check tooltips against availability).

## Risks for QA

- LUX_6 can make crafted luxury dominant; sim with the atelier at 2 batches before approving.
- MIL_2 plus MIL_3 plus MIL_6 stack into a safe mil run; check mil win rate (was 4/5 at maintenance 40).
- Capstone retunes shift win rates and cycle medians; target stays decent wins 25-28, no dominant strategy.
- Tech goals: LUX_2 goal (9 cask) and LUX_4 goal (18 cask) now craftable in system 1; LUX_4 therefore arrives earlier than before (check gems timing vs permit 2).
