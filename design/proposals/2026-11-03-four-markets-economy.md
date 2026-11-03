# Four Markets: economy numbers

> Part of the Four Markets pack. Where the docs disagree, `2026-11-03-four-markets-summary.md` (reconciliation table R1 to R13) decides.

Date: 2026-11-03. Author: economy-designer. Status: PROPOSAL. `data/balance.json` is NOT edited; this file is the spec for the later data goal. Core design: `design/proposals/2026-11-03-four-markets.md` (ids fixed, not renamed). All numbers below come from a paper model written for this task (player volume ramp + 3 bots + the 28 chain steps from the core doc with neutral options opt_a / opt_b and the hidden `dir_<mkt>` rules, seeded noise, 60-200 seeds per case; direction rerun 2026-11-03 replaced the Open/Hard tables with all 2^7 option paths per market). The sim script lives in the session scratchpad only; porting it into `tools/sim.py` is part of the data goal (section 9). Stated limits: the player model is a ramp (ships at cycles 1/5/9/13/17, per-ship volume from the existing 16 units a cycle), not the Godot route engine, so QA bots must re-check every win cycle here.

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

Player volume per cycle in the focus market (bv = units x base price), before any option: ships at cycles 1 / 5 / 9 / 13 / 17 x 16 units x 34 bv = 544 per ship, plus crafted goods 0 before cycle 10 rising 30 a cycle to 600 (one workshop), times the skill bonus (+25% by cycle 36, ramped from cycle 8, from MIL_2, MIL_3, MIN_2 type nodes), times a unit-value factor (mil 1.00, lux 1.24, min 0.88, bio 0.94 = 34 / 42 / 30 / 32 bv per unit over 34), times a per-run skill factor (lognormal 7%). Arithmetic: cycle 36 = (5 x 544 + 600) x 1.25 = 4,150 plus option volume gets (about +4%) = 4.2k, as the table shows. Cash gained or paid by an option moves the ship ramp only before cycle 17 (cash / (150 x ships) cycles earlier or later); after that the player owns five ships and cash is worth nothing to share. Bots (section 4) are 2.4k at the start and 3.1k to 4.0k later.

Worked example, Military, focused, all 128 option paths x 10 seeds averaged, `bot_scale` 0.85 (bv per cycle; share is the 8-cycle window):

| Cycle | Player | Bots total | Share |
|---|---|---|---|
| 1 | 550 | 2363 | 19% |
| 4 | 550 | 2494 | 18% |
| 8 | 1270 | 2550 | 25% |
| 12 | 1947 | 2775 | 34% |
| 16 | 2608 | 3017 | 41% |
| 20 | 3338 | 3362 | 46% |
| 24 | 3737 | 3289 | 51% |
| 28 | 3994 | 4068 | 52% |
| 32 | 4229 | 3911 | 51% |
| 36 | 4301 | 4204 | 51% |
| 40 | 4301 | 4136 | 51% |

The averaged share sits at 51-52% from cycle 24, so single runs cross above or below, see win rates below.

### 2.1 Focused win rate per market and path class

Focused player, full tree, all 2^7 = 128 option paths per market, 200 seeds per path, same seeds for every path (so differences between paths are the options, not luck). A path is one choice of opt_a or opt_b for each of the 7 steps. Cells: win rate / median win cycle / median final share of a run.

| Path class | mil | lux | min | bio |
|---|---|---|---|---|
| all 128 paths, mean (random path) | 77% / 27 / 52% | 88% / 26 / 52% | 84% / 28 / 52% | 72% / 28 / 51% |
| best path to worst path | 94% to 57% | 99% to 58% | 97% to 61% | 89% to 51% |
| paths ending good (dir 10 or more) | 72% / 27 / 52% | 91% / 26 / 52% | 87% / 28 / 53% | 68% / 28 / 51% |
| paths ending bad (dir -10 or less) | 82% / 27 / 53% | 84% / 26 / 52% | 80% / 28 / 52% | 76% / 28 / 52% |
| chain-committed: the + option every step | 70% / 27 / 51% | 96% / 26 / 52% | 94% / 27 / 53% | 58% / 29 / 51% |
| chain-committed: the - option every step | 88% / 27 / 53% | 80% / 25 / 51% | 74% / 29 / 52% | 80% / 27 / 52% |
| opt_a every step | 70% / 27 / 52% | 70% / 28 / 51% | 68% / 30 / 51% | 76% / 31 / 51% |
| opt_b every step | 88% / 27 / 53% | 99% / 24 / 53% | 95% / 27 / 54% | 80% / 27 / 52% |
| max own volume at every step | 79% / 27 / 52% | 94% / 25 / 52% | 88% / 29 / 53% | 88% / 28 / 52% |
| max bot cut at every step | 80% / 29 / 52% | 90% / 27 / 52% | 85% / 29 / 52% | 70% / 29 / 51% |
| max cash at every step | 82% / 26 / 52% | 96% / 26 / 53% | 86% / 29 / 52% | 71% / 27 / 51% |

Reading: all path classes win between 58% and 99% (best-worst across all 512 market paths: 99% to 51%; 5 of 512 paths are under the 56% floor (Biotech) and 8 are over 98% (Luxury), so the 56-98% claim holds for 499 of 512 paths and for every named class); the median win cycle is 24-31 in every class; final share is 51-54% for every class. A focused skill-complete player wins at cycle 26-28 in the median, floor 24 by the hold rule; the old "27-39" band is gone because the stance volume bonus no longer exists. With no events (no steps) the same player ends at 44-46% and wins 3-9% of runs: the steps decide the win, as designed. With low skill (volume bonus +10%) a focused player wins rarely: skills are required. A win never fired before B4: 0 of 19,794 mil wins, 22,536 lux, 21,469 min, 18,558 bio (core 4.2 holds).

Class gaps: good versus bad ending 72 vs 82 (mil), 91 vs 84 (lux), 87 vs 80 (min), 68 vs 76 (bio): at most 10 points and the sign differs by market, so no ending is the easier one.

### 2.2 No dominant option: step-by-step spread and retune

For each step the win-rate delta = mean win rate of the 64 paths with opt_a at that step minus the mean of the 64 with opt_b (other steps vary). Final table, positive = opt_a better, points:

| Step | mil | lux | min | bio |
|---|---|---|---|---|
| A1 | -7 | +5 | +5 | +5 |
| A2 | -9 | -6 | -8 | +7 |
| A3 | +2 | -1 | -5 | -3 |
| B1 | +2 | -5 | -7 | +6 |
| B2 | -3 | -7 | -5 | -10 |
| B3 | +7 | -6 | 0 | -1 |
| B4 | -10 | -8 | -9 | -6 |

Spread: -10 to +7 points, largest 10 (MIL_B4, BIO_B2), mean of absolute deltas 5.5; the + dir option is opt_a in 14 of 28 steps and the option with the larger bot cut is + in 14 of 28, so neither position, size nor bot cut predicts the ending. Delta sign is not constant in any market.

Before the retune (first pass with the core 4.3 cells) steps beyond 10 points were: MIL_B2 -13, MIL_B3 +10, LUX_A2 -11, LUX_B2 -10, LUX_B4 -16, MIN_A2 -11, MIN_B3 -33, MIN_B4 -19, BIO_B2 -12, BIO_B3 -22 (all because the better option had a volume or a strength cut and the other paid in cash, which is worth nothing late, or hit a minor bot, or used a growth cut that is worth about a quarter of a strength cut). The smallest retunes of Gets / Costs / Bot (24 cells; dir untouched), each listed as core cell to new cell:

| Cell | Core 4.3 | Retuned | Why |
|---|---|---|---|
| MIL_B1 a bot | bot_1 str M down | bot_1 str L down | cash option lagged |
| MIL_B2 b bot | bot_1 tier -1 | bot_1 str S down | tier cut too strong (fires before tier-up, R8) |
| MIL_B3 a gets | vol +M 5 cy | vol +S 5 cy | a ahead by 10-12 |
| MIL_B3 b bot | bot_2 str S UP | bot_2 str S down | b lagged (a boost cost late is too heavy against a growth cut) |
| MIL_B4 a bot | bot_1 gro M down | bot_1 str M down | growth cut too weak late |
| MIL_B4 b bot | bot_3 str M down | bot_3 str S down | b ahead by 10 |
| LUX_A2 a bot | bot_2 gro S down | bot_2 gro L down | a lagged |
| LUX_B2 a bot | bot_3 gro S down | bot_3 gro L down | a lagged |
| LUX_B2 b costs | bot_2 str S UP | bot_2 str M UP | b ahead |
| LUX_B3 a bot | bot_2 gro M down | bot_2 gro L down | a lagged |
| LUX_B3 b bot | bot_2 str M down | bot_2 str S down | b ahead |
| LUX_B4 a bot | bot_2 str M down | bot_2 str L down | a lagged by 16-19 |
| LUX_B4 b gets | vol +M rest | vol +S rest | b ahead |
| MIN_A2 a bot | bot_3 gro S down | bot_3 gro M down | a lagged |
| MIN_B2 b bot | bot_1 str M down | bot_1 str S down | b ahead |
| MIN_B3 a bot | bot_1 str S UP, bot_3 str S down | bot_1 str L down, bot_3 str S down | cash +L is worthless late, option lagged by 33 |
| MIN_B3 b bot | bot_1 tier -1 | bot_1 str M down | b too strong |
| MIN_B4 a bot | bot_1 gro M down | bot_1 str L down | growth too weak late |
| MIN_B4 b bot | bot_3 str M down | bot_3 str S down | b ahead |
| BIO_A2 a costs | cash S | cash M | a ahead by 10 |
| BIO_B2 a bot | bot_2 gro S down | bot_2 gro M down | a lagged |
| BIO_B2 b gets | cash +M | cash +S | b ahead |
| BIO_B3 a bot | bot_3 gro M down | bot_2 str L down, bot_3 gro M down | a hit only a minor bot, lagged by 22 |
| BIO_B3 b gets | vol +S rest | vol +S 6 cy | b ahead |
| BIO_B4 a bot | bot_2 str M down | bot_2 str L down | a lagged |

Calibration changes for this run: `bot_scale` 0.85 (new global key, owner approved), `bot_2_lux_strength` 1700 to 1900 (the lux player's 42 bv per unit made Luxury win at cycle 24 on every path), jitter assumptions in section 4. MIL_B3 b and MIN_B3 a are no longer boosts, so 8 of 28 steps carry a boost (was 10); R-BOT still holds (every option changes at least one bot stat).

Spreading numbers (the sim with the same chains): see the table in section 3.

Balance flag: the pass margin is steep in bot strength. A change of +-0.02 in `bot_scale` moves the mean focused win rate about 8-10 points. QA must run 100 seeds on the real game before any bot number is touched (tool in section 9).

## 3. Spreading penalty

Keys: `market_overhead` 150 (core suggestion untuned; set to 150 because credits pile up, see 6), `market_active_pct` 0.05, `cross_load_trip_mult` 1.5, `workshop_build_cost` 900 (Fabric stays `fabric_build_cost` 600), `bot_gap_growth` 12, `bot_gap_share_pct` 0.10.

Formulas:
- overhead per cycle = `market_overhead` x (n_active - 1)^2, n_active = markets where the player's share of its own volume exceeds `market_active_pct`.
- mixed load trip cost = `trip_cost` x `cross_load_trip_mult` per leg (60 -> 90) and no bundle bonus (5%, cap 150).
- gap rule: a market where the player's share is under 10% and cycle >3 adds `bot_gap_growth` to each bot's strength every cycle (cumulative).
- skill points: not enough for two markets (see 5).
- workshop: 900 each one-time (one per market).

Examples, 5 ships (cap), NET 150 a ship, workshops built at cycles 10/16/22/28, markets opened at cycles 1/6/12/18 (model run on the credit curve in section 6). Share columns come from the option-path sim of section 2 (random option path, 60 runs per market, 240 runs per row, `bot_scale` 0.85, overhead applied as an early-ship delay):

| Markets | Overhead per cycle | Total overhead, 40 cycles | Cash at cycle 40 | Best share ever, median (max) | Wins |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 23,900 | 52% (59%) | 193 / 240 |
| 2 (85/15) | 150 | 5,250 | 18,800 | 46% (53%) | 11 / 240 |
| 3 | 600 | 18,300 | -7,800 (3 ships repossessed) | 25% (30%) | 0 / 240 |
| 4 | 1,350 | 35,550 | -26,700 (3 ships repossessed) | 20% (24%) | 0 / 240 |

Cash column: option cash cells add at most +-1.5k to the cash at cycle 40 (seven steps at 150-600), about 6% of 23.9k, left unchanged. Focus beats dabbling in cash (23.9k versus 18.8k for just two) and in share (52% versus 46%). The 85/15 split leaks 4.6% wins (Open question 4). Mixed-cargo example: two markets in one route load costs 30 extra per leg; with 5 routes that is 150 a cycle, about as much as one overhead step, so it hurts but is not the main brake. A player can sit at 5% of volume in a side market to avoid overhead; that player has no real second market (5% of 5000 is 250 bv). Left as is.

Gap-rule effect when ignoring a market (player absent, bots only): bot totals per market grow from 2.2-3.3k at cycle 1 to 5.0-5.9k at cycle 20 and 7.9-9.5k at cycle 40, so a market entered at cycle 25 needs 5k+ bv to just reach 40% (a full fleet gives ~5k). It does not get cheap.

## 4. Bots

Keys per bot b and market m: `bot_<b>_<m>_strength` (s0), `bot_<b>_<m>_growth` (g, added each cycle), `bot_<b>_tier_cycle_1/2` (tier-up cycles). Tier multipliers `bot_tier_mult_1..4` = 1.0, 1.2, 1.4, 1.7 (tier 1 start; the three bots reach tier 3 at the second cycle; tier 4 is only by events at +1). Noise `bot_noise_pct` 0.10 for all three (core). Volume = (s0 x strength hits + accumulated growth + gap growth) x tier mult x (1 +/- noise) x `bot_scale` (0.85, global; owner approved). Each run also draws one persistent strength factor per bot (lognormal 7%), a player-skill factor (7%) and the 10% per-cycle noise.

s0 (strength, bv per cycle) / g (growth per cycle):

| Bot | Personality | mil | lux | min | bio | Tier-ups at |
|---|---|---|---|---|---|---|
| bot_1 Harrow Combine | heavy, slow | 1690 / 22 | 600 / 5 | 1410 / 22 | 410 / 5 | 13, 27 |
| bot_2 Velvet Concord | lux and bio, faster growth | 440 / 8 | 1900 / 38 | 370 / 8 | 1170 / 38 | 11, 24 |
| bot_3 Dunmere Syndicate | even, steady, high growth off-lean | 630 / 18 | 860 / 18 | 530 / 18 | 590 / 18 | 14, 28 |

Market totals at start (before `bot_scale`): mil 2.8k, lux 3.4k (bot_2 lux strength 1700 to 1900, see 2.2), min 2.5k, bio 2.2k. Lux is bigger because its player price per unit is higher (PV lux 42 vs mil 34, min 30, bio 32 bv per unit in the model).

Bot growth curve (bots only, no event hits, gap rule active because the player is absent, before `bot_scale`; multiply by 0.85 for the game), total bv per cycle:

| Cycle | mil | lux | min | bio |
|---|---|---|---|---|
| 1 | 2784 | 3483 | 2485 | 2195 |
| 5 | 3153 | 3843 | 2580 | 2463 |
| 10 | 3564 | 4271 | 3131 | 2986 |
| 15 | 4426 | 5722 | 4113 | 4438 |
| 20 | 5397 | 6075 | 4381 | 4975 |
| 25 | 6285 | 7532 | 5650 | 5915 |
| 30 | 7418 | 8630 | 6884 | 7219 |
| 35 | 8123 | 8754 | 6889 | 7490 |
| 40 | 8564 | 9752 | 8087 | 7940 |

Per bot in mil (cycles 1/10/20/30/40): bot_1 1716 / 2161 / 2941 / 3733 / 4333; bot_2 446 / 551 / 969 / 1427 / 1616; bot_3 621 / 851 / 1486 / 2257 / 2613.

Bots with a focused player and the option paths (this is what the player faces), after `bot_scale` 0.85, mean over 128 paths x 20 seeds, per cycle: Military 2.4k at cycle 1, 3.1k (range 2.9-3.3k) at cycles 17-20, 4.0k (3.8-4.2k) at cycles 33-36; Luxury 4.1k / 5.3k; Minerals 2.9k / 3.6k; Biotech 3.0k / 4.0k. With no steps fired the same bots are 3.5k / 4.8k (mil), 4.6k / 6.5k (lux), 3.2k / 4.4k (min), 3.3k / 4.8k (bio) and the focused player ends at 44-46% share and wins 3-9% of runs. The old per-stance bot totals are retired: a random path is 4.0k scaled (4.7k before `bot_scale`), and the player side is 4.2k at cycle 36 because only the volume gets of the chosen options count.

Gap rule: `bot_gap_growth` 12 per cycle while player share is under 10% (a market the player ignores gets +12 on each bot, so +36 total a cycle, ~+1.1k by cycle 30).

### 4.1 Event hit sizes (apply to the stat named in the core doc chain table)

Bot stat hits come in two directions. Down hits weaken a bot, UP hits (boosts used as costs, R-BOT) strengthen it. All keys live in 8.1.

| Hit | Effect | Keys |
|---|---|---|
| strength down S / M / L | strength x (1 - 5% / 10% / 18%), permanent, multiplicative | `event_hit_strength_S` 0.05, `_M` 0.10, `_L` 0.18 |
| strength UP S / M | strength x (1 + 5% / 10%) | `event_hit_strength_up_S` 0.05, `_M` 0.10 |
| growth down S / M / L | growth x (1 - 10% / 20% / 30%) from now on | `event_hit_growth_S` 0.10, `_M` 0.20, `_L` 0.30 |
| growth UP S | growth x 1.10 from now on | `event_hit_growth_up_S` 0.10 |
| tier -1 | drops one tier (x1.2 to x1.0 or x1.4 to x1.2, about -14 to -17%); on a bot at tier 1 it becomes strength down M (R8); later schedule steps still apply | `event_hit_tier` 1 |
| timed (embargo, Guild Seal, LUX_A3) | strength x (1 - 18%) for the stated cycles | `skill_MIL_5_hit`, `skill_LUX_7_hit` (section 5) |

Cumulative effect of a complete chain on each bot (7 steps, all 128 paths, final multipliers; growth in Military includes MIL_7 x0.5 and strength in Minerals and Biotech includes the MIN_7 / BIO_7 x0.90 capstone):

| Market | bot_1 strength / growth | bot_2 strength / growth | bot_3 strength / growth |
|---|---|---|---|
| mil | 0.54-0.85 / 0.41-0.50 | 0.90-1.00 / 0.45-0.50 | 0.85-1.10 / 0.33-0.50 |
| lux | 0.95-1.00 / 1.00 | 0.60-0.99 / 0.44-1.10 | 0.81-1.00 / 0.70-1.00 |
| min | 0.40-0.69 / 0.81-1.00 | 0.90 / 1.00 | 0.81-0.95 / 0.72-1.00 |
| bio | 0.90 / 1.00 | 0.42-0.77 / 0.72-1.00 | 0.77-0.95 / 0.72-0.90 |

Reading: the lead bot of the market (bot_1 in mil and min, bot_2 in lux and bio) loses 15-60% strength depending on the path, and a lean bot can end above 1.00 when its boost option is taken and nothing cuts it back. The spread now comes from which options are picked, and 2.2 shows it does not decide the win.

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

Option tech cells (tech +3 / +4) shorten that by n/3 cycles each: the Military focused path with every tech option (MIL_A2 b, A3 b, B3 b = 11 units, 3.7 cycles) reaches tech 6 at about cycle 22-23 instead of 25-27, so the capstone arrives at about cycle 24; the sim gives the capstone at cycle 27 for all paths (conservative). Options give no skill points, so the point margin below is unchanged.

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
- S5. The pass window is steep with respect to bot strength. Resolved by the approved global key `bot_scale` (0.85); with the player and bot jitter now in the sim, 0.84 gives mean win rates 86 / 91 / 89 / 79% and 0.86 gives 78 / 85 / 81 / 69% (mil / lux / min / bio, after the first retune pass), so +-0.02 moves each market about 8-10 points, no cliff. QA still re-checks on the real game.
- S6. Cash piles up (12k unused) for focused players. Smallest fix: leave. Alternative sink: `upgrade_cost` 900 -> 1500 or `workshop_build_cost` 1500; the model above does not need it.

## 8. Event choice effects: every cell mapped to numbers (replaces Open/Hard)

The Open/Hard stance, `open_volume_bonus` and `hard_fee` are removed. Every step has two neutral options `opt_a` / `opt_b`; each option has Gets, Costs, Bot and a hidden `dir` nudge. Cash and price effects are paid in cash only; share counts base prices, so only volume, tech and bot cells move share.

### 8.1 Unit map (core 4.3 words to keys)

| Cell word | Key | Value | Notes |
|---|---|---|---|
| volume S / M | `event_volume_S` / `_M` | 0.05 / 0.10 | multiplies the player's volume in that market for "n cy" or "rest" (to cycle 40); stacks multiplicatively; a negative is the same size |
| cash S / M / L | `event_cash_S/M/L` | 150 / 300 / 600 | one time; sign shows gain or fee (M equals the old `hard_fee`) |
| price S / M | `event_price_S` / `_M` | 0.08 / 0.15 | of the market's sell prices for n cy; a "price dip" is the same size negative; worth about 20 / 37 credits per ship per cycle (8% / 15% of the 245 gross margin) |
| ship upkeep up S / M | `event_upkeep_S` / `_M` | 0.20 / 0.40 | of ship upkeep 75: +15 / +30 per ship per cycle |
| route trip cost S | `event_trip_S` | 0.33 | of `trip_cost` 60 = 20 per cycle, one route, up or down |
| tech +3 / +4 | `event_tech_3` / `_4` | 3 / 4 units | crafting progress in that market's workshop; 3 = one batch; moves tech completion about n/3 cycles earlier |
| workshop idle | `event_idle_cycles` | 2 | no batch for 2 cycles (sim: -4% volume) |
| batches +1 for 4 cy | `workshop_batches_per_cycle` +1 | 4 cy | sim: +5% volume |
| bot strength down S / M / L | `event_hit_strength_S/M/L` | 0.05 / 0.10 / 0.18 | permanent, multiplicative; timed ones say "n cy" |
| bot growth down S / M / L | `event_hit_growth_S/M/L` | 0.10 / 0.20 / 0.30 | from now on |
| bot strength UP S / M | `event_hit_strength_up_S` / `_M` | 0.05 / 0.10 | the same percent upward; used as a cost |
| bot growth UP S | `event_hit_growth_up_S` | 0.10 | used as a cost |
| tier -1 | `event_hit_tier` | 1 | on a tier-1 bot: strength down M instead (R8) |

### 8.2 All 28 steps, with numbers (final, after the retunes in 2.2)

Cell order: Gets / Costs / Bot / dir. A bot UP (boost) sits in Costs. Sizes are per 8.1. `dir` values are the core table nudges, unchanged.

**MIL**

| Id | opt_a: Gets / Costs / Bot / dir | opt_b: Gets / Costs / Bot / dir |
|---|---|---|
| MIL_A1 | vol +5% 8 cy / cash -150 / bot_1 gro -10% / +6 | cash +300 / bot_3 str +5% (boost) / bot_1 str -5% / -8 |
| MIL_A2 | price +8% 6 cy / upkeep +20% 6 cy / bot_3 gro -10% / -9 | tech +3 / cash -300 / bot_1 tier -1 / +10 |
| MIL_A3 | cash +150, vol +5% 4 cy / bot_3 str +5% (boost) / bot_1 str -10% / +12 | tech +4 / cash -300 / bot_1 str -5%, bot_3 gro -10% / -14 |
| MIL_B1 | cash +300 / upkeep +40% 8 cy / bot_1 str -18% / -10 | vol +5% rest / cash -300 / bot_3 gro -10% / +8 |
| MIL_B2 | price +8% 8 cy / one route trip cost +33% 4 cy / bot_2 str -5% / +11 | cash +150 / vol -5% 3 cy / bot_1 str -5% / -13 |
| MIL_B3 | vol +5% 5 cy / cash -300 / bot_3 str -10% / -16 | tech +4 / none / bot_2 str -5%, bot_1 gro -10%, bot_2 gro -10%, bot_3 gro -10% / +14 |
| MIL_B4 | price +8% 8 cy / vol -5% 4 cy / bot_1 str -10% / +24 | cash +600 / upkeep +40% 8 cy / bot_1 str -10%, bot_3 str -5% / -26 |

**LUX**

| Id | opt_a: Gets / Costs / Bot / dir | opt_b: Gets / Costs / Bot / dir |
|---|---|---|
| LUX_A1 | price +8% 6 cy / vol -5% 4 cy / bot_2 str -5% / +5 | cash +300 / bot_2 gro +10% (boost) / bot_3 str -5% / -7 |
| LUX_A2 | tech +3 / cash -300 / bot_2 gro -30% / -9 | vol +5% rest / price -8% 3 cy / bot_2 tier -1 / +10 |
| LUX_A3 | price +15% 4 cy / cash -150 / bot_2 str -18% 3 cy / -12 | vol +5% 6 cy / price -8% 3 cy / bot_3 str -5% / +13 |
| LUX_B1 | cash +300 / vol -5% 4 cy / bot_2 gro -10% / +9 | vol +10% 5 cy / cash -300 / bot_2 str -10% / -10 |
| LUX_B2 | tech +3 / price -8% 3 cy / bot_3 gro -30% / -11 | cash +150 / bot_2 str +10% (boost) / bot_2 tier -1 / +12 |
| LUX_B3 | price +15% 6 cy / vol -5% 6 cy / bot_2 gro -30% / +15 | cash +300 / bot_1 str +5% (boost) / bot_1 str -10%, bot_2 str -5% / -14 |
| LUX_B4 | price +8% 8 cy / cash -300 / bot_2 str -18% / -25 | vol +5% rest / price -8% 8 cy / bot_2 str -10%, bot_3 str -10% / +26 |

**MIN**

| Id | opt_a: Gets / Costs / Bot / dir | opt_b: Gets / Costs / Bot / dir |
|---|---|---|
| MIN_A1 | cash +150 / vol -5% 5 cy / bot_1 gro -10% / +7 | vol +5% 5 cy / cash -300 / bot_1 str -5% / -6 |
| MIN_A2 | vol +5% 6 cy / cash -300 / bot_3 gro -20% / -9 | cash +150 / vol -5% 3 cy / bot_1 str -10% / +10 |
| MIN_A3 | one route trip cost -33% 6 cy / bot_3 str +5% (boost) / bot_1 str -5% / +13 | vol +10% 4 cy / cash -150, upkeep +20% 4 cy / bot_1 tier -1 / -12 |
| MIN_B1 | cash +300 / vol -5% 4 cy / bot_1 gro -10% / -9 | tech +4 / cash -300 / bot_1 str -10% / +8 |
| MIN_B2 | price +8% 6 cy / workshop idle 2 cy / bot_3 gro -10% / +11 | workshop batches +1 for 4 cy / cash -300 / bot_1 str -5% / -10 |
| MIN_B3 | cash +600 / vol -10% 2 cy / bot_1 str -18%, bot_3 str -5% / -14 | vol +5% 6 cy / cash -150 / bot_1 str -10% / +16 |
| MIN_B4 | price +8% 8 cy / cash -300 / bot_1 str -18% / -24 | vol +5% rest, cash +300 / upkeep +20% 8 cy / bot_1 str -10%, bot_3 str -5% / +25 |

**BIO**

| Id | opt_a: Gets / Costs / Bot / dir | opt_b: Gets / Costs / Bot / dir |
|---|---|---|
| BIO_A1 | tech +3 / cash -150 / bot_2 gro -10% / +6 | cash +300 / price -8% 3 cy / bot_2 str -5% / -7 |
| BIO_A2 | vol +5% rest / cash -300 / bot_3 gro -10% / -8 | tech +3 / vol -5% 4 cy / bot_2 tier -1 / +9 |
| BIO_A3 | price +8% 4 cy / workshop idle 2 cy / bot_2 str -5% / +12 | cash +300 / bot_3 str +5% (boost) / bot_2 str -10% / -13 |
| BIO_B1 | vol +10% 5 cy / cash -300 / bot_2 str -10% / -10 | tech +4 / upkeep +20% 6 cy / bot_3 str -5% / +9 |
| BIO_B2 | price +8% 6 cy / vol -5% 4 cy / bot_2 gro -20% / +11 | cash +150 / bot_2 str +5% (boost) / bot_3 tier -1 / -12 |
| BIO_B3 | cash +300 / vol -5% 5 cy / bot_2 str -18%, bot_3 gro -20% / -15 | vol +5% 6 cy / cash -300 / bot_2 str -5%, bot_3 gro -10% / +14 |
| BIO_B4 | price +8% 8 cy / vol -5% 4 cy / bot_2 str -18% / +25 | cash +600 / upkeep +20% 8 cy / bot_2 str -10%, bot_3 str -10% / -24 |

Counts (QA data check): the + option is opt_a in 14 of 28 steps; the option with the larger bot cut is + in 14 of 28 steps; 8 options carry a bot boost (MIL_A1 b, MIL_A3 a, LUX_A1 b, LUX_B2 b, LUX_B3 b, MIN_A3 a, BIO_A3 b, BIO_B2 b).

### 8.3 Direction keys

`dir_min` -100, `dir_max` 100, `dir_good_min` 10, `dir_bad_max` -10, `dir_echo_mult` 1.25 (floor; same sign as the previous step of the same chain), `dir_swing_mult` 1.5 (floor; B3 and B4, only for a nudge against the current lean), `dir_swing_threshold` 40. Nudge keys: `dir_<mkt>_<step>_<a|b>`, 56 values, the dir column above (A1 5-8, A2 8-10, A3 10-14, B1 8-10, B2 10-12, B3 14-16, B4 24-26). Checked in the sim: the dir sum has mean -5.5 / +1.3 / +3.1 / -1.6 and sd 42 over all 128 paths (mil/lux/min/bio); the good ending comes in 45 / 52 / 53 / 48% of runs; an ending class is reachable from every start.

## 9. Proposed `values` (new keys, example values)

Remove: `win_cash`, `skill_A*`, `skill_B*`, `skill_C*`, `skill_cost_A1..F1` (old tree), `skill_cost_M1/M2/F1`, `full_ref_points_per_cycle` (stale), shield_* (if Q5 retire). Set `win_cycle` 40.

New: `share_window` 8, `share_window_bio_bonus` 12, `win_share_pct` 0.50, `win_hold_cycles` 5, `win_earliest_cycle` 20, `sweep_hold_cycles` 3, `sweep_earliest_cycle` 25, `sweep_player_share_max` 0.10, `market_overhead` 150, `market_active_pct` 0.05, `cross_load_trip_mult` 1.5, `bot_gap_growth` 12, `bot_gap_share_pct` 0.10, `bot_noise_pct` 0.10, `bot_tier_mult_1..4` 1.0 / 1.2 / 1.4 / 1.7, `event_hit_strength_S/M/L` 0.05 / 0.10 / 0.18, `event_hit_growth_S/M/L` 0.10 / 0.20 / 0.30, `event_hit_tier` 1, `bot_scale` 0.85, `event_volume_S/M` 0.05 / 0.10, `event_cash_S/M/L` 150 / 300 / 600, `event_price_S/M` 0.08 / 0.15, `event_upkeep_S/M` 0.20 / 0.40, `event_trip_S` 0.33, `event_tech_3/4` 3 / 4, `event_idle_cycles` 2, `event_hit_strength_up_S/M` 0.05 / 0.10, `event_hit_growth_up_S` 0.10, `dir_echo_mult` 1.25, `dir_swing_mult` 1.5, `dir_swing_threshold` 40, `dir_good_min` 10, `dir_bad_max` -10, `dir_min` -100, `dir_max` 100, 56 nudge keys `dir_<mkt>_<step>_<a|b>` (section 8.3), `workshop_build_cost` 900, `workshop_batches_per_cycle` 1, `size_slots_M` 2, `size_slots_L` 3, `tech_goal_2/4/6` 9 / 18 / 12, `skill_points_share_20/35` 1 / 2, `skill_points_route` 1, `skill_points_system` 2, `permit_points_2` 2, `permit_points_3` 2, per-node `skill_cost_*` and `skill_<NODE>_*` (section 5), `<good>_batch_out` (ingot 3, alloy 2, cells 3, armour 3, cask 3, gems 2, gel 3, seed 2), recipe inputs `<workshop>_in_<good>` per the table, `event_pct_<good>` (1.2), `bot_<b>_<m>_strength/growth` and `bot_<b>_tier_cycle_1/2` (section 4; `bot_2_lux_strength` 1900). `tools/sim.py` needs the market model; the scratchpad model used here is the starting point.

Targets block: `win_focus_cycles` [25, 30] (path medians 26-28), `win_earliest_possible` 24, `second_ship_cycle` 6, `spread_win_rate_max` 0.05 (see Q4), `option_step_spread_max` 10 (win-rate points between the two options of any step).

## 10. Open questions for the owner

Owner answers already applied: S1 and S2 approved (core summary Q5), price skills stay cash perks (Q4), `bot_scale` and the 56-98% focused win rate approved (Q6). New, from the direction rerun:

1. **Late cash is worth nothing (core 4.2/4.3, B3 and B4 and some A steps).** After about cycle 16 a focused player has 12k unspent (section 6), so "cash +L / upkeep up / price dip" costs and gets are worth about 0 to share. Un-retuned, MIN_B3 favoured the option with volume and a tier cut by 37 win-rate points. Smallest fix: done by retuning bot sizes (section 2.2), no structure change. Owner choice if wanted: give cash a late sink (upgrade_cost 900 to 1500) so cash gets stay real; not needed for the sim.
2. **Growth hits are about a quarter as strong as strength hits late (core 4.3 sizes).** "growth M down" at a step that fires near cycle 18 removes 20% of 22 a cycle for ~10 cycles; "strength M down" removes 10% of the whole bot at once. Smallest fix: when two options differ in size class, treat a growth cut as one size smaller than a strength cut. Applied as bot retunes in 2.2 (growth S to M/L where the option lagged; MIL_B4 and MIN_B4 growth M became strength M and L).
3. **Tier -1 cells fire before the bot's first tier-up (cycle 11-14) in most paths (core 4.3, R8).** A tier cut on a tier-1 bot becomes "strength M down" (R8), so MIL_A2 b, LUX_A2 b, LUX_B2 b, MIN_A3 b, BIO_A2 b and BIO_B2 b are mostly strength cuts. Smallest fix: store tier cuts as a persistent offset applied when the schedule tier is read (floor 1), so the cut bites at cycle 11-14. Not applied; it makes those options ~5 points stronger, so tell me before the data goal.
4. **85/15 two-market split wins 4.6% (11 of 240).** Overhead is capped in effect (ramp delay saturates): the "spread never wins" target is missed by 5 points. Smallest fix: leave (a player who keeps 85% in one market is a focused player), or set `market_active_pct` 0.15 so a 15% side market counts as active at once. Needs owner choice.
5. **Win cycle (core 2.1 target 28-36 passes) lands at 25-30 (medians 26-28).** To push medians to 28-30 `bot_scale` must go to about 0.88, which drops the mean win rate to 45-70%, under the 56% floor for some paths. Accepted: win window 25-30. Owner: acceptable?
6. **Dir tiebreak**: ending class and win rate are not tied (good-ending paths win 72/91/87/68%, bad-ending 82/84/80/76% in mil/lux/min/bio), so no ending is "easier"; no change needed. Listed only so QA checks it on the real game.
