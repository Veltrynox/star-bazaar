# Four Markets: economy numbers

> Part of the Four Markets pack. Where the docs disagree, `2026-11-03-four-markets-summary.md` (reconciliation table R1 to R13) decides.

Date: 2026-11-03. Author: economy-designer. Status: PROPOSAL. `data/balance.json` is NOT edited; this file is the spec for the later data goal. Core design: `design/proposals/2026-11-03-four-markets.md` (ids fixed, not renamed). All numbers below come from a paper model written for this task (player volume ramp + 3 bots + the 28 chain steps from the core doc, seeded noise, 60-100 seeds per case). The sim script lives in the session scratchpad only; porting it into `tools/sim.py` is part of the data goal (section 9). Stated limits: the player model is a ramp (ships at cycles 1/5/9/13/17, per-ship volume from the existing 16 units a cycle), not the Godot route engine, so QA bots must re-check every win cycle here.

## 1. Goods: price, cost, size, margin, recipes

Size = cargo slots per unit: S 1, M 2, L 3 (`size_slots_M` 2, `size_slots_L` 3; S is today's 1). Tier rule: T1-T2 trade goods S, T3 M, T4 L. Existing plate stays S (no change to a built good). "Cost" = cash to buy or make one unit (mined goods cost 0 cash). "Out" = units one workshop batch makes (new key `<good>_batch_out`). A batch = the recipe once. Margin = sell minus cost, per unit.

Trade goods (prices are base prices in planets.json style, buy at the maker, sell at the wanter):

| Good | Mkt | T | Size | Cost (buy) | Sell | Margin/unit | Where made / wanted |
|---|---|---|---|---|---|---|---|
| energy | mil | 1 | S | 8-10 | 24-34 | 14-26 | unchanged |
| food | bio | 1 | S | 11-12 | 26-35 | 15-24 | unchanged |
| chips | mil | 2 | S | 16-18 | 36-38 | 18-22 | unchanged (system 2) |
| silk | lux | 2 | S | 24 | 48 | 24 | unchanged (system 2) |
| ore | min | 1 | S | 0 (mined) | 12-16 | 12-16 | unchanged |
| dross | min | 2 | S | 4 | 15-18 | 11-14 | unchanged |
| nullglass | min | 2 | S | 12 | 25-29 | 13-17 | unchanged |
| plate | min | 3 | S | crafted | 120 (buy 135) | see 1.1 | unchanged (T3 band exception, already built) |
| rivets | mil | 2 | S | 20 | 42 | 22 | made Voltara (`rivets_buy` 20, `rivets_sell` 17), wanted system 2 (42) |
| musk | lux | 2 | S | 18 | 40 | 22 | made Tillam, wanted system 2 (40) |
| spores | bio | 2 | S | 16 | 36 | 20 | made Tillam and Ashgate (16), wanted system 2 (36) |

Margin bands per tier for trade goods: T1 14-26, T2 18-24 per unit. One ship moves 16 units a cycle (cargo 32 / 2), so a trade ship earns 16 x 20 - 75 upkeep = about 245 gross-margin, ~150 net of the existing trip and maintenance after skills; this is the unit the whole model uses ("NET 150 per ship per cycle").

Crafted goods (sell = base price; also the volume base price for share):

| Good | Mkt | T | Size | Recipe per batch | Out/batch | Sell | Cash cost/unit | Margin/batch | Workshop |
|---|---|---|---|---|---|---|---|---|---|
| plate | min | 3 | S | 2 dross + 1 nullglass (existing) | 1 | 120 | ~10 | ~110 | Fabric |
| ingot | min | 2 | S | 2 ore | 3 | 36 | 0 (ore mined) | 108 | Smelter |
| alloy | min | 4 | L | 1 plate + 2 ingot | 2 | 160 | ~5 | ~310 | Smelter |
| cells | mil | 3 | M | 2 energy + 1 chips | 3 | 70 | 12 | 174 | Munitions |
| armour | mil | 4 | L | 3 cells + 1 chips | 3 | 180 | 18 | ~490 | Munitions |
| cask | lux | 3 | M | 3 food | 3 | 72 | 12 | 180 | Atelier |
| gems | lux | 4 | L | 2 ore + 1 silk | 2 | 130 | 12 | 236 | Atelier |
| gel | bio | 3 | M | 2 food + 1 spores | 3 | 74 | 13 | 182 | Culture Lab |
| seed | bio | 4 | L | 2 gel + 1 spores | 2 | 190 | 21 | ~340 | Culture Lab |

Throughput: `workshop_batches_per_cycle` 1 (Fabric today). MIN_4 gives the Smelter 2 (ingot + alloy in the same cycle; with plate from the Fabric this makes exactly 2 alloy a cycle: 1 plate + 2 ingot per batch, ingot batch gives 3). Check of the arithmetic: a workshop batch earns 108-182 at T2/T3 (about one ship of 150) and 240-490 at T4 chains; per workshop-cycle the chain average is 180-260. A workshop costs 900 (`workshop_build_cost`, one ship) and the Fabric stays 600. This lets a workshop repay in 4-6 cycles; it must not exceed two ships' income, which it does not.

### 1.1 Known price and margin problems

- Armour per batch needs 3 cells (one whole cells batch). Chain volume: cells batch 210 bv + armour batch 540 bv = 375 bv a batch, above cells alone (210). OK.
- Seed batch consumes 2 of the 3 gel from one gel batch; chain 227 bv a batch vs gel alone 222: T4 gives almost no extra volume, only more cash and price. Accepted; do not raise seed above 190.
- Alloy at 160: inputs would sell for 98 per alloy, so alloy adds about 60 percent value. Above 160 the Smelter beats a ship; kept at 160.

### 1.2 Event swings (lux "huge swings")

`event_pct_musk` 0.35, `event_pct_cask` 0.35, `event_pct_gems` 0.35 (as silk); `event_pct_rivets` 0.2, `event_pct_cells` 0.2, `event_pct_armour` 0.25; `event_pct_spores` 0.25, `event_pct_gel` 0.25, `event_pct_seed` 0.25; minerals ingot 0.3, alloy 0.3 (as ore).

## 2. Market share as numbers

Formula stays as in the core doc. Numbers:

| Key | Value | Reason |
|---|---|---|
| `share_window` | 8 | core |
| `share_window_bio_bonus` (BIO_5) | 12 | core |
| `share_volume_weight_<good>` | 1.0 for all 19 goods | volume = units x base sell price already weighs tiers; extra weights only add a second knob |
| `win_share_pct` | 0.50 (strictly above) | core |
| `win_hold_cycles` | 5 | core |
| `win_earliest_cycle` | 20 | core; first reachable win cycle is 24 |
| `sweep_hold_cycles` | 3 | core (see problem S2) |
| `win_cycle` | 40 | core |
| `skill_points_share_20` / `_35` | 1 / 2 | core, paid once per market |
| `win_cash` | removed | core |

Player volume per cycle in the focus market (bv = units x base price), full skill play (+25% volume by cycle 36 from MIL_2, MIL_3, MIN_2 type nodes, +5% per Open step): 1 ship 540 at cycle 1, 2 ships ~1100 at cycle 6, 3 ships ~1800 at cycle 10, 5 ships plus workshop ~4100 at cycle 20 and ~5400 at cycle 36. Crafted goods add up to 600 bv at the end (one workshop). Bots (section 4) are 2.8k at the start and 5-6k at cycle 36 after event cuts.

Worked example, Military, focused, player vs bots (avg of 60 seeds; volumes bv per cycle; share is the 8-cycle window):

| Cycle | Player (Open) | bot_1 | bot_2 | bot_3 | Share Open | Share Hard |
|---|---|---|---|---|---|---|
| 1 | 542 | 1711 | 448 | 645 | 16% | 16% |
| 4 | 543 | 1787 | 466 | 708 | 16% | 16% |
| 8 | 1163 | 1871 | 501 | 764 | 22% | 22% |
| 12 | 2023 | 1869 | 645 | 835 | 32% | 32% |
| 16 | 2997 | 2313 | 677 | 1078 | 40% | 40% |
| 20 | 4100 | 2421 | 694 | 1165 | 45% | 46% |
| 24 | 4465 | 2521 | 857 | 1143 | 49% | 49% |
| 28 | 4887 | 2740 | 891 | 1424 | 50% | 49% |
| 32 | 5133 | 2765 | 922 | 1448 | 50% | 50% |
| 36 | 5435 | 2811 | 938 | 1496 | 50% | 50% |
| 40 | 5420 | 2869 | 956 | 1519 | 50% | 51% |

(Hard table row: player 3280 / 3435 / 3620 / 4026 and bot_1 1566 / 1651 / 1402 / 1472 at cycles 20/24/28/36; Hard cuts bots harder, Open lifts the player.) The averaged share hovers at 50% because the median seed crosses; single runs cross above or below, see win rates below.

Focused win results (100 seeds, full tree, any skill-complete player; the mix row alternates Open and Hard):

| Market | Open wins, median cycle | Hard wins, median cycle | Mixed wins, median |
|---|---|---|---|
| mil | 86%, 39 | 98%, 36 | 98%, 27.5 |
| lux | 74%, 29.5 | 57%, 31 | 95%, 28 |
| min | 56%, 30 | 16%, 33.5 | 100%, 28 |
| bio | 59%, 28 | 23%, 28 | 100%, 27 |

Reading: a focused, skill-complete player wins in 27-39; the earliest is 26 and the floor is 24 by the hold rule. With no events cut (events skipped) a focused player ends at 49-50% and does not clear: events and choices decide the win, as designed. With low skill (volume bonus +10%) a focused Hard player wins rarely (0-8%): skills are required. Open versus Hard is asymmetric: Hard is faster but riskier (sections 3 and 8).

Can a focused player reach >50% in one market by cycle 40 but not by spreading? Yes, from the table above and from the spread runs (60 runs each, mixed Open/Hard):

| Allocation of fleet | Wins | Best share ever, any market | Median best share at cycle 40 |
|---|---|---|---|
| 100% one market | 56-98% | 50%+ | 50% |
| 85/15 two markets | 0 of 60 | 46% | 44% |
| 75/25 | 0 of 60 | 43% | 42% |
| 60/40 | 0 of 60 | 37% | 36% |
| 50/50 | 0 of 60 | 34% | 33% |
| 33/33/33 | 0 of 60 | 21% | 19% |
| 25 x 4 | 0 of 60 | 17% | 15% |

Balance flag: the pass margin is thin. A change of +/-8% in bot strengths moves the focused win rate from near 100% to near 0% (cliff). QA must run 100 seeds on the real game before any bot number is touched (tool in section 9).

## 3. Spreading penalty

Keys: `market_overhead` 150 (core suggestion untuned; set to 150 because credits pile up, see 6), `market_active_pct` 0.05, `cross_load_trip_mult` 1.5, `workshop_build_cost` 900 (Fabric stays `fabric_build_cost` 600), `bot_gap_growth` 12, `bot_gap_share_pct` 0.10.

Formulas:
- overhead per cycle = `market_overhead` x (n_active - 1)^2, n_active = markets where the player's share of its own volume exceeds `market_active_pct`.
- mixed load trip cost = `trip_cost` x `cross_load_trip_mult` per leg (60 -> 90) and no bundle bonus (5%, cap 150).
- gap rule: a market where the player's share is under 10% and cycle >3 adds `bot_gap_growth` to each bot's strength every cycle (cumulative).
- skill points: not enough for two markets (see 5).
- workshop: 900 each one-time (one per market).

Examples, 5 ships (cap), NET 150 a ship, workshops built at cycles 10/16/22/28, markets opened at cycles 1/6/12/18 (model run on the credit curve in section 6):

| Markets | Overhead per cycle | Total overhead, 40 cycles | Cash at cycle 40 | Best share (hard) |
|---|---|---|---|---|
| 1 | 0 | 0 | 23,900 | 50%+ |
| 2 | 150 | 5,250 | 18,800 | 46% max |
| 3 | 600 | 18,300 | -7,800 (3 ships repossessed) | 21% |
| 4 | 1,350 | 35,550 | -26,700 (3 ships repossessed) | 17% |

Focus beats dabbling in cash (23.9k versus 18.8k for just two) and in share (50% versus 46% max). Mixed-cargo example: two markets in one route load costs 30 extra per leg; with 5 routes that is 150 a cycle, about as much as one overhead step, so it hurts but is not the main brake. A player can sit at 5% of volume in a side market to avoid overhead; that player has no real second market (5% of 5000 is 250 bv). Left as is.

Gap-rule effect when ignoring a market (player absent, bots only): bot totals per market grow from 2.2-3.3k at cycle 1 to 5.0-5.9k at cycle 20 and 7.9-9.5k at cycle 40, so a market entered at cycle 25 needs 5k+ bv to just reach 40% (a full fleet gives ~5k). It does not get cheap.

## 4. Bots

Keys per bot b and market m: `bot_<b>_<m>_strength` (s0), `bot_<b>_<m>_growth` (g, added each cycle), `bot_<b>_tier_cycle_1/2` (tier-up cycles). Tier multipliers `bot_tier_mult_1..4` = 1.0, 1.2, 1.4, 1.7 (tier 1 start; the three bots reach tier 3 at the second cycle; tier 4 is only by events at +1). Noise `bot_noise_pct` 0.10 for all three (core). Volume = (s0 x strength hits + accumulated growth + gap growth) x tier mult x (1 +/- noise).

s0 (strength, bv per cycle) / g (growth per cycle):

| Bot | Personality | mil | lux | min | bio | Tier-ups at |
|---|---|---|---|---|---|---|
| bot_1 Harrow Combine | heavy, slow | 1690 / 22 | 600 / 5 | 1410 / 22 | 410 / 5 | 13, 27 |
| bot_2 Velvet Concord | lux and bio, faster growth | 440 / 8 | 1700 / 38 | 370 / 8 | 1170 / 38 | 11, 24 |
| bot_3 Dunmere Syndicate | even, steady, high growth off-lean | 630 / 18 | 860 / 18 | 530 / 18 | 590 / 18 | 14, 28 |

Market totals at start: mil 2.8k, lux 3.3k, min 2.5k, bio 2.2k. Lux is bigger because its player price per unit is higher (PV lux 42 vs mil 34, min 30, bio 32 bv per unit in the model).

Bot growth curve (bots only, no event hits, gap rule active because the player is absent), total bv per cycle:

| Cycle | mil | lux | min | bio |
|---|---|---|---|---|
| 1 | 2784 | 3283 | 2485 | 2195 |
| 5 | 3153 | 3643 | 2580 | 2463 |
| 10 | 3564 | 4071 | 3131 | 2986 |
| 15 | 4426 | 5482 | 4113 | 4438 |
| 20 | 5397 | 5835 | 4381 | 4975 |
| 25 | 6285 | 7252 | 5650 | 5915 |
| 30 | 7418 | 8350 | 6884 | 7219 |
| 35 | 8123 | 8474 | 6889 | 7490 |
| 40 | 8564 | 9472 | 8087 | 7940 |

Per bot in mil (cycles 1/10/20/30/40): bot_1 1716 / 2161 / 2941 / 3733 / 4333; bot_2 446 / 551 / 969 / 1427 / 1616; bot_3 621 / 851 / 1486 / 2257 / 2613.

Bots with a focused player and the chain cuts (this is what the player faces): mil total 2.8k at cycle 1, ~4.3k at 20, ~5.3k at 36 (Open) or ~3.9k (Hard). With no cuts at all it would be ~6.0k at 30 and the player reaches only 49%.

Gap rule: `bot_gap_growth` 12 per cycle while player share is under 10% (a market the player ignores gets +12 on each bot, so +36 total a cycle, ~+1.1k by cycle 30).

### 4.1 Event hit sizes (apply to the stat named in the core doc chain table)

| Hit | Effect | Keys |
|---|---|---|
| strength S / M / L | strength x (1 - 5% / 10% / 18%), permanent, multiplicative | `event_hit_strength_S` 0.05, `_M` 0.10, `_L` 0.18 |
| growth S / M / L | growth x (1 - 10% / 20% / 30%) from now on | `event_hit_growth_S` 0.10, `_M` 0.20, `_L` 0.30 |
| tier -1 | drops one tier (output x1.2 -> x1.0 or x1.4 -> x1.2, about -14 to -17%); cannot go below tier 1; later schedule steps still apply | `event_hit_tier` 1 |
| tier +1 (boosts) | the reverse, used only for bad Hard results or follow-ups | same key |
| timed (embargo, Guild Seal) | strength x (1 - L) for the stated cycles | `skill_MIL_5_hit`, `skill_LUX_7_hit` (section 5) |
| boost to a bot (rare, follow-up results) | strength +S/M/L, same percentages upward | same keys |

Cumulative cuts from a complete chain (7 steps), strength x / growth x / tiers dropped, as the core table lists:

| Market | Open path | Hard path |
|---|---|---|
| mil | bot_1 0.95 / 0.72 / 0, bot_2 0.95 / 1 / 0, bot_3 0.90 / 0.81 / 0 | bot_1 0.54 / 0.90 / 2 tiers, bot_2 1 / 0.90, bot_3 0.74 / 0.90 |
| lux | bot_2 0.85 / 0.65 / 0, bot_3 0.95 / 0.90 | bot_1 0.90, bot_2 0.49 / 1 / 2 tiers, bot_3 0.82 |
| min | bot_1 0.95 / 0.65, bot_3 0.95 / 0.81 | bot_1 0.49 / 1 / 2 tiers, bot_3 0.82 |
| bio | bot_2 0.85 / 0.81, bot_3 0.95 / 0.72 | bot_2 0.49 / 1 / 1 tier, bot_3 0.66 / 1 / 1 tier |

Hard's main bot loses about half its strength; Open's loses 5-15% plus a 30% slower growth. That asymmetry is why Hard wins sooner and why Open needs the stable player gain (below). Rule of thumb for the player side: each Open step gives the player `open_volume_bonus` 0.05 volume in that market (key, 7 steps give +35%), each Hard step costs the player cash: `hard_fee` 300 a step, or a worse price hit as the story-designer writes it.

Key for gap: `bot_gap_growth` 12 (above).

## 5. Skills and tech

Costs (points) follow the core table: _1 = 1, _3 = 2, _5 = 3, _7 = 4 (10 per market) and Foundations 1 each. Keys `skill_cost_<NODE>`. Tech goals in units crafted by that market's workshop(s), counted from the moment the prerequisite is met: `tech_goal_2` 9, `tech_goal_4` 18, `tech_goal_6` 12 (retuned from 15/30/20: with 3 units a batch, 15+30+20 is 21 workshop cycles, so tech 6 lands after cycle 35 and the capstone has no time; 9+18+12 is 13 cycles, first workshop at cycle ~10, tech 6 done by ~25, capstone learned by ~27, which is what the win table uses).

Magnitudes (sizes: S = 8% player-side, M = 15%, L = 30% unless a number says otherwise). All effect keys are named `skill_<NODE>_<what>`:

| Node | Kind | Cost | Effect key = value |
|---|---|---|---|
| FND_STORAGE | S | 1 | `space_storage_capacity` 500 (unchanged) |
| FND_PERMIT | S | 1 | permits as today; `permit_2_cost` 600, `permit_3_cost` 1500 (unchanged) |
| FND_PROSPECT | S | 1 | clusters usable at routes; `ore_survey_fee` 150 (unchanged) |
| MIL_1 | S | 1 | `skill_MIL_1_upkeep` 0.20 (was A5 0.3 at cost 2; now cost 1 as root) |
| MIL_2 | T | tech 9 | `skill_MIL_2_volume` 0.08 |
| MIL_3 | S | 2 | `skill_MIL_3_route_units` 0.125 (= A4) |
| MIL_4 | T | tech 18 | `skill_MIL_4_price` 0.06 |
| MIL_5 | S | 3 | `skill_MIL_5_hit` 0.18 (L as `event_hit_strength_L`), `skill_MIL_5_every` 8, `skill_MIL_5_cycles` 3 |
| MIL_6 | T | tech 12 | `skill_MIL_6_event_cut` 0.5 (mil price events against you halve) |
| MIL_7 | S | 4 | `skill_MIL_7_growth_mult` 0.5 |
| LUX_1 | S | 1 | `skill_LUX_1_price` 0.06 (was B3 0.08) |
| LUX_2 | T | tech 9 | `skill_LUX_2_event_bonus` 0.5 (price-up events pay +50% pct) |
| LUX_3 | S | 2 | forecast 1 cycle, no number |
| LUX_4 | T | tech 18 | no number |
| LUX_5 | S | 3 | `skill_LUX_5_volume` 0.15 on sales at price-up planets |
| LUX_6 | T | tech 12 | `skill_LUX_6_price` 0.12 |
| LUX_7 | S | 4 | `skill_LUX_7_hit` 0.18 for `skill_LUX_7_cycles` 5, once |
| MIN_1 | S | 1 | none (unlocks) |
| MIN_2 | T | tech 9 | `skill_MIN_2_volume` 0.08, ore loads free of slots |
| MIN_3 | S | 2 | `skill_MIN_3_yield` 0.25 (mining_yield 20 to 25) |
| MIN_4 | T | tech 18 | `skill_MIN_4_batches` 1 |
| MIN_5 | S | 3 | none (unlock) |
| MIN_6 | T | tech 12 | `skill_MIN_6_batch_bonus` 1 unit per batch |
| MIN_7 | S | 4 | `skill_MIN_7_strength_cut` 0.10 (all bots, rest of run) |
| BIO_1 | S | 1 | `skill_BIO_1_order_units` 0.3 (was B2 0.5 at cost 2) |
| BIO_2 | T | tech 9 | `skill_BIO_2_stock_growth` 0.02 a cycle, `skill_BIO_2_stock_cap` 0.20 |
| BIO_3 | S | 2 | `skill_BIO_3_capacity` 0.5 (= A2) |
| BIO_4 | T | tech 18 | none (unlock seed) |
| BIO_5 | S | 3 | `share_window_bio_bonus` 12 |
| BIO_6 | T | tech 12 | `skill_BIO_6_event_cut` 0.25 and reopen 1 cycle sooner |
| BIO_7 | S | 4 | `skill_BIO_7_strength_cut` 0.10 |

Points supply (existing sources retuned so no second tree is cheap): `skill_points_planet` 1, `skill_points_route` 2 -> 1, `skill_points_system` 3 -> 2, `permit_points_2` 3 -> 2, `permit_points_3` 4 -> 2, `skill_points_share_20` 1, `skill_points_share_35` 2.

Supply arithmetic (focused player, by cycle 40): planets visited 7 (of 9 reachable, UNKNOWN exact count) = 7, new route pairs 5 x 1 = 5, system 2 visit 2, permit_2 2, permit_3 2 (1500 credits, affordable), share milestones 1 + 2 = 3. Total 21. Need: 3 Foundations + 10 = 13; reached by about cycle 20-25 (planets and routes arrive early; permits at 13-20). Two full markets need 3 + 20 = 23, plus the second market's share points are only paid at 20% and 35% there. A 60/40 dabbler reaches 20% in the second market (+1) but never 35%: 22 at most, a point short, and arrives after cycle 36. This satisfies the core check; the margin is one point, so it is fragile. If QA shows more than 8 planets or 6 route pairs, set `skill_points_planet` to 0.5 (needs owner) or reduce permit_points_3 to 1.

Tech completion: tech 2 at ~13-15, tech 4 at ~19-21, tech 6 at ~25-27 for a focused player with a workshop at cycle 10. Spread players craft in several workshops, so each tech is later by ~2x; that is a built-in penalty.

## 6. Start, credit curve, bankruptcy

`starting_credits` 2100 and `ship_price` 900 stay (v22/v18). The player starts with no hardwired ship; the first purchase (cycle 1) leaves 1200 of working capital. `ship_cap` 5, `rescue_stipend` 1000, `salvage_share` 0.4 stay.

Focused credit curve (NET 150 a ship, ships bought at 1/5/9/13/17, one workshop at cycle 10, 110 a cycle from it):

| Cycle | 5 | 10 | 15 | 20 | 25 | 30 | 35 | 40 |
|---|---|---|---|---|---|---|---|---|
| Cash | 1,200 | 1,200 | 3,440 | 6,690 | 10,990 | 15,290 | 19,590 | 23,890 |

Second ship by cycle 5-6 (existing target is ~6). Spending sinks: 4 ships 3,600, workshop 900, permits 600 + 1,500, upgrades 900 each (5 = 4,500): about 11k; roughly 12k remains unspent at cycle 40. Cash is therefore no longer a constraint for a focused player, which is intended (it is fuel), but it means the win threshold no longer limits pace; share does.

Bankruptcy risk: real only if the player spreads. Spreading to 3 markets goes cash-negative at cycle 25; 4 markets at cycle 20 (table in section 3). As written in the core doc (stranded needs zero ships and ships are never lost) END_BANKRUPT never triggers; see problem S1.

## 7. Where the core structure breaks the balance, and the smallest fix

- S1. END_BANKRUPT cannot fire: stranded requires zero ships, and ships are never lost. Overhead can push cash below 0 with five ships still owned. Smallest fix: when cash is negative after upkeep and overhead, repossess the newest ship and credit `salvage_share` x `ship_price` (360, existing keys), once a cycle. Bankruptcy then follows naturally from the existing "stranded third time" rule. Modelled above (3 ships repossessed in 3 and 4 market runs).
- S2. END_SWEPT cannot fire as written. No bot is over 50% in all four markets: bot_1 holds 20-45% in its off markets, bot_3 8-30% everywhere (shares by `bot_<b>_<m>` table). Smallest fix: swept = player share under 10% in all four markets at the end of 3 consecutive cycles from cycle 25 (the leading bot named on the end screen). Alternative if the owner keeps the original rule: raise `bot_gap_growth` to 120, which makes bots snowball and also kills the focused win; not recommended.
- S3. Tech 15/30/20 units is too slow (the capstone arrives after cycle 35); retuned to 9/18/12.
- S4. Price skills (MIL_4, LUX_1, LUX_6) cannot raise share because share uses base prices (core rule). They pay in credits only; they are real but weak when cash is unused. They stay as small unlocks; the alternative is a 2% share boost on price-up sales, which the owner can add (Q3).
- S5. The pass window is knife-edge (+/-8% bot strength swings win rates 100% to 0%). Smallest fix: keep a single global key `bot_scale` that QA can move without touching 12 numbers (needs owner approval as a new key).
- S6. Cash piles up (12k unused) for focused players. Smallest fix: leave. Alternative sink: `upgrade_cost` 900 -> 1500 or `workshop_build_cost` 1500; the model above does not need it.

## 8. Event choice effects (player side, for the data goal)

Open (stable): player gains `open_volume_bonus` 0.05 in that market each step (stacks to 0.35). Hard (fast): cash fee `hard_fee` 300, or a price hit to the player of event_pct 0.2 for 3 cycles, plus stance -1. Bot hits per choice use the sizes in 4.1 and the core table. Chain cash rewards are set by story-designer; keep each below one ship's cycle (150) so cash never dominates.

## 9. Proposed `values` (new keys, example values)

Remove: `win_cash`, `skill_A*`, `skill_B*`, `skill_C*`, `skill_cost_A1..F1` (old tree), `skill_cost_M1/M2/F1`, `full_ref_points_per_cycle` (stale), shield_* (if Q5 retire). Set `win_cycle` 40.

New: `share_window` 8, `share_window_bio_bonus` 12, `win_share_pct` 0.50, `win_hold_cycles` 5, `win_earliest_cycle` 20, `sweep_hold_cycles` 3, `sweep_earliest_cycle` 25, `sweep_player_share_max` 0.10, `market_overhead` 150, `market_active_pct` 0.05, `cross_load_trip_mult` 1.5, `bot_gap_growth` 12, `bot_gap_share_pct` 0.10, `bot_noise_pct` 0.10, `bot_tier_mult_1..4` 1.0 / 1.2 / 1.4 / 1.7, `event_hit_strength_S/M/L` 0.05 / 0.10 / 0.18, `event_hit_growth_S/M/L` 0.10 / 0.20 / 0.30, `event_hit_tier` 1, `open_volume_bonus` 0.05, `hard_fee` 300, `workshop_build_cost` 900, `workshop_batches_per_cycle` 1, `size_slots_M` 2, `size_slots_L` 3, `tech_goal_2/4/6` 9 / 18 / 12, `skill_points_share_20/35` 1 / 2, `skill_points_route` 1, `skill_points_system` 2, `permit_points_2` 2, `permit_points_3` 2, per-node `skill_cost_*` and `skill_<NODE>_*` (section 5), `<good>_batch_out` (ingot 3, alloy 2, cells 3, armour 3, cask 3, gems 2, gel 3, seed 2), recipe inputs `<workshop>_in_<good>` per the table, `event_pct_<good>` (1.2), `bot_<b>_<m>_strength/growth` and `bot_<b>_tier_cycle_1/2` (section 4). `tools/sim.py` needs the market model; the scratchpad model used here is the starting point.

Targets block: `win_focus_cycles` [28, 36], `win_earliest_possible` 24, `second_ship_cycle` 6, `spread_win_rate_max` 0.

## 10. Open questions for the owner

1. S1 fix: repossess one ship per cycle while cash is negative (salvage 360). Approve? Without it END_BANKRUPT is dead code.
2. S2 fix: change END_SWEPT to "player under 10% in all four markets for 3 cycles from cycle 25". Approve, or accept that END_SWEPT never fires?
3. Price skills (MIL_4, LUX_1, LUX_6) change credits only, not share. Add a small share effect, or keep them as cash perks?
4. A new key `bot_scale` (one global multiplier) so QA can tune the knife-edge win rate. Approved? Also: is a 56-98% focused win rate acceptable, or do you want a safer 90%+ at the cost of shorter runs?
