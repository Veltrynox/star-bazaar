# Mechanics audit, 2026-11-11

Source of truth: the game code (`game/`) and data (`data/`), not `gdd.md` (it is out of date, see the last section).
Method: every public function, signal, balance number, event, ending, good and availability rule was cross-referenced against its callers and readers, then the suspicious ones were read by hand. Nothing was run. Translation and sound were left out on purpose.

Three words used below:
- **Not connected**: the code exists and may even run each cycle, but the player can never reach it or it changes nothing.
- **Outdated**: left over from a design that was removed (market share, rivals, shield, pirates).
- **Unused**: code or numbers nothing reads.

## Summary

| Area | State | What to do |
| --- | --- | --- |
| Routes, orders, ships, lane upgrade and split, salvage sale | Connected | Nothing |
| CEOs (stats and perks), skills (all 30 effect types), tech nodes | Connected | Nothing |
| Workshops, Fabric, Null Core build and fit | Connected | Null Core "pirate immunity" protects from nothing (see 2.3) |
| Prosperity, needs, need pricing, tax | Connected | Nothing |
| Hubs (panel, pool, switches, release) | Connected | One empty hook (1.6) |
| Star Bazaar (found, stages, wings, Opening, card) | Connected | Nothing |
| Raids and salvage pods | Connected | Weakened-lane countdown is never shown (1.7) |
| Space Storage and Storage Link | Connected | Nothing |
| House weather, convoys, chains softening weather | Connected | Old "rival" naming inside (2.1) |
| **Mining intensity (gentle / normal / hard)** | **Not connected** | Add the control or remove the lever (1.1) |
| **Dead-world danger meter** | **Not connected** | Give it an effect or remove it (1.2) |
| **Gig rewards "perk" and "knowledge"** | **Not connected** | Wire the three rewards or change the two gigs (1.3) |
| **Six price events on goods the world does not trade** | **Not connected** | Move them to worlds that price the good (1.4) |
| **Three CEO endings** | **Not reachable** | Build the CEO events or drop the rows (1.5) |
| Market share, rival strength, sweep, shield, pirates leftovers | Outdated | Delete (section 2) |
| About 100 balance numbers | Unused | Delete (section 3) |
| 23 written events and 5 written gigs | Text only | Cheapest new content available (section 4) |

## 1. Not connected

### 1.1 Mining intensity has no control
`DeadWorlds.set_intensity` and `Clusters.set_intensity` (`game/dead_worlds.gd:86`, `game/clusters.gd:120`) are the only way to change the gentle / normal / hard step, and no panel calls them. Every dead world and cluster therefore stays on "normal" for the whole run. The yield and danger multipliers, the raid chance scaling with mining danger, and six balance numbers (`mining_intensity_yield_*`, `mining_intensity_danger_*`) all sit behind a lever the player cannot touch.

### 1.2 The danger meter counts and does nothing
Each cycle `main._tick_danger` raises the danger of every dead world that is being mined, and it is saved. Nothing reads the value except a planet-panel line that is switched off in `data/availability.json` (`dead_danger_meter`, "hidden until danger has a mechanical effect"). The follow-up effects it was meant to drive are gone: `dead_income_*`, `dead_ore_loss_*` and `dead_shore_cost` are read by no code. Raids use the mining intensity (1.1), not this meter.

### 1.3 Two of the gig reward kinds are dead ends
Signal gigs can pay a "perk" (`cheap_post`) or "knowledge" (`price_view`, `sell_hint`). They are granted and saved, but `Gigs.perk_active` and `Gigs.has_knowledge` have no callers, so the reward has no effect. Only two signal gigs exist (`data/gigs.json`: GIG01, GIG02) and three of their four options pay one of these. In practice a signal gig today has one option that gives something (a small goods lot).

### 1.4 Six price events name a good the world does not trade
The pool filter only checks that the good is visible and priced at *some* open world, not at the world the event names. These events can fire and announce a price change that moves nothing, because the named world has no price for the good (unless a need happens to have opened a buyer there):

| Event | World | Good |
| --- | --- | --- |
| EV41 | Ashgate | rounds |
| EV42 | Tillam | arms |
| EV44 | Ashgate | gems |
| EV45 | Ashgate | attar |
| EV48 | Ashgate | plate |
| EV51 | Tillam | seed |

Related: every timed pool event (price, closure, shortage, congestion) targets Voltara, Tillam or Ashgate. Flintmoor and all of systems 2 to 5 never get weather or price events, so the event layer goes quiet for a player who has moved on from the first three worlds.

### 1.5 Three CEO endings cannot appear
`END_MIN_PAGE`, `END_LUX_LIGHT` and `END_MIL_WAIT` (`data/endings.json`) need the counters `ceo_paid`, `ceo_cash` and `ceo_bore`. Nothing increments them: the CEO events that would are a proposal only (`design/proposals/2026-11-09-ceo-events.md`). The other 17 CEO endings are reachable.

### 1.6 The hub does not reduce rush orders
`Gigs.hub_fed` (`game/gigs.gd:395`) always returns false. The rush generator asks it so that worlds a hub already feeds post fewer rush orders; today a hub-fed world posts them like any other.

### 1.7 Small ones
- `Raids.malus_left` has no caller: a raided lane is weaker for some cycles, but no panel says for how long.
- `Pathfinder.dock_reason`, `dock_sale_value` and `boost_refill_left` have no callers: the dock sheet shows refusals, but not why docking is unavailable, the value of a sale before it is made, or when the next boost charge returns.
- `map.fly_establish_requested` is connected in `main.gd` but never emitted (the handler is reached through the right-click menu instead).
- `main._on_trade_mission_complete` is an empty function nobody calls.
- Signals nobody in the game listens to: `Bazaar.founded`, `Bazaar.wing_chosen`, `Pathfinder.build_started`, the six `StorageLink.link_*` signals, `map.beat_chime` (emitted six times, presumably waiting for sound). `main.cycle_ended`, `routes_settled`, `route_blocked`, `notice_posted` and `run_ended` are also unlistened in the game; they are the hooks the bots use, so they stay.
## 2. Outdated

### 2.1 Rivals and market share
The share system and the Competitors screen are removed, but a layer of it is still in the code:
- `Markets.hit_bot`, `Markets.bot_mods`, `Markets.tier_off`, `Markets.size_pct`, `Chains.effective_tier`, `Chains.win_open` and `Bots.tier`: the stored rival modifiers are never written any more, so these always return the starting values. They now only pick a word in the chain log ("tier", "lowest") and the "a rival lost ground" epilogue line.
- Chain and event data still describe every choice as a hit on `bot_1..3` with a stat and a size (`data/chains.json`). The game turns each hit into "soften or delay that house's next weather", which works, but the data says something else than what happens.
- `rival_ships.gd`, `rival_card.gd`: these are the house ships and convoys (weather forecast) and are in use; only the names are old.
- Texts still in `story_text.json` with no reader: `LBL_SHARE_TITLE` and the other share-panel labels, `NOT_SKILL_REASON_SHARE`, `END_SWEPT`. `SK_BIO_2_PLAIN` still says "Biotech sales count 12% more toward share".
- `qa/gui/competitors_shot.gd` opens a Competitors screen that no longer exists (removed with the old tooling, see the removal note).

### 2.2 Solar shield
Event `EV18` (shield offer) is still generated into `data/events.json` with its texts, and is listed as retired in `data/chains.json`, so it never fires. The save migration still strips the old shield state, which is fine to keep.

### 2.3 Pirates
`route_engine.pirates_active` is a flag nothing ever sets to true, so the volume cut it guards and the Null Core's "pirates cannot touch this ship" never matter. Raids are the real threat now and the Null Core is immune to those; the tooltip text (`NULL_CORE_FIT`) still talks about pirates. `EV19` (nomads and pirates, 14 texts) and `pirate_hire_cost`, `pirate_nomads_per_eviction` have no reader.

### 2.4 Debug menu
The debug menu's own list says "Not built yet, skipped: solar shield, pirates, nomads, asteroid approach, asteroid fields". Asteroid approach and clusters are built; shield, pirates and nomads are cut. The menu also has no entries for the newer systems (hubs, gigs, raids, Bazaar stages, reclaim).

## 3. Unused

### 3.1 Balance numbers nothing reads (`data/balance.json`)
861 numbers in the file; about 100 have no reader in code or data:
- **Share and win (31)**: `win_hold_cycles`, `win_earliest_cycle`, `sweep_hold_cycles`, `sweep_earliest_cycle`, `sweep_share_pct`, `market_active_pct`, `share_points_enabled`, `skill_points_share_20`, `skill_points_share_35`, `ending_second_market_pct`, and the 20 `chain_*_trig_share_pct` keys. Probably also `share_window`, `market_overhead` (no reader found by name).
- **Rivals (32)**: `bot_gap_growth`, `bot_gap_share_pct`, `bot_noise_pct`, `bot_tier_mult_1..4`, the 24 `bot_N_<market>_strength` / `_growth` keys, `rival_ship_wait_s`. Probably also `bot_scale`.
- **Dead worlds and ore (9)**: `dead_shore_cost`, `dead_ore_loss_chance`, `dead_ore_loss_pct`, `dead_ore_loss_cycles`, `dead_income_cycles`, `dead_income_cut`, `dead_income_boost`, `ore_refill_units`, `ore_survey_fee`.
- **Other (9)**: `permit_margin_bonus`, `full_ref_points_per_cycle`, `planet_to_space_rate`, `pirate_hire_cost`, `pirate_nomads_per_eviction`, `size_slots_M`, `size_slots_L`, `gig_marker_pulse_hz`, `gig_marker_pulse_fast_hz`.
- The `targets` block (`win_no_skills_cycles`, `win_skilled_cycles`, `win_full_tree_cycles`, `check_early_win_cycle`) belonged to the old economy runs and is removed with them.
- The file's `source` note is 36,000 characters of change history, most of it about systems that no longer exist.

### 3.2 Functions nothing calls
`Events.debris_penalty`, `Storage.planet_rating`, `Chains.chain_of`, `CashForecast.expenses_total`, `Gigs.has_def`, `Gigs.is_clear`, `RouteEngine.local_preview`, `SkillTree.craft_text`, `StoryText.ending_name`, `main.clusters_near_planet`, `main.pending_event_icon`, `ShipPreview.make_passive` / `set_active`, `world_growth_view._draw_weather` / `_draw_hover_face`, `planet_panel._txt`, `trade._name`, `map._ground_point`, `rival_ships._tint`, plus the ones named in 1.3, 1.7 and 2.1. About 30 in all; none is large.

## 4. Written but not built
Finished English text exists for content that has no data row or code, so it never appears. This is the cheapest way to add variety:

| Content | Count | Texts |
| --- | --- | --- |
| Signal gigs GIG03 to GIG07 | 5 gigs | 56 |
| Trading post events EV_PST01 to 06 | 6 events | 60 |
| Mining platform events EV_PLT01 to 04 | 4 events | 40 |
| Flight events EV_FLT01 to 04 | 4 events | 40 |
| Branch follow-ups BE01 to BE03 | 3 events | 54 |
| CEO events (proposal, 5 per CEO) | 20 events | proposal only |

With only two signal gigs, the Flagship's "special jobs" loop is the thinnest part of the game compared with how much text is waiting for it.

## 5. Questions the bot check should answer
These are design questions the audit can raise but only play can settle; the new economy check measures them:
- **Crafted goods can be bought.** Plate, rounds, arms, attar, gems, ingot, alloy, medicine and seed all have a Buy price at Voltara or a system 2 world. A player can buy them instead of building the workshop. Is the workshop still worth its cost?
- **Dead worlds for non-Minerals CEOs.** Dross, nullglass, plate, the Fabric and the Null Core are visible only on a Minerals run. For the other three CEOs a dead world is only something to reclaim (and a raid nest). Is that enough reason to go there?
- **Systems 3 to 5** are live placeholders that trade only energy and food and have no events. Do they add anything to a run except permit cost and quorum worlds?
- **Spores** are sold at Tillam and Ashgate (system 1) but the good stays hidden until system 2 opens; the rule's note says its prices are only in system 2.

## 6. Doc drift (`gdd.md`)
Not game defects; listed so the GDD can be brought back in line when you want it:
- Section 1 still gives the goal as "hold more than half of one market against three rivals". The win is the Star Bazaar.
- Section 3 has contradicting duplicates: two "Spreading penalty" paragraphs (with and without market overhead), two "House weather" paragraphs (convoy built / not built), two "Rush generator" paragraphs, two Fabric paragraphs (pirates planned / raids built), and a "Share in a market comes from..." paragraph two lines after "There is no market share".
- Hubs and gigs are described as "engine only"; both have panels and are playable.
- Prosperity appears twice at the end of section 4, once saying "prices and rewards come in later tasks".
- The skills paragraph still mentions share milestones "kept behind a switch"; the switch has no reader.
