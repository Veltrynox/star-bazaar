# Ship select, CEO bios and CEO stats (2026-11-05)

Status: PROPOSAL, waits for the owner. Numbers marked (E) are set by economy-designer; no value here is final. Source: owner request.

## 1. Flow
New Game -> **Company screen** (name + CEO, now with bio and stats panel) -> **Ship screen** (new) -> Start. Back on each screen goes one step back. CEO first because the story is "who you are", then "what you fly". Start on the ship screen is disabled until a ship is picked (same rule as the CEO).

Ship screen: left, a 3D preview (rotating turntable, drag to turn), right, the ship list and a stat card. **4 curated ships, not 8.** Eight is too many for a first-minute choice and 4 stats each is a wall of text. Models 01..04 are used now; 05..08 stay for later (bigger ship classes, rivals, ship upgrades). UNKNOWN: which 4 of the 8 look most different from each other (owner picks by eye).

What the choice means: the chosen type is the **starting ship, its look in game, and its stats**. Every ship the player buys later is the same type (one fleet doctrine). No mixed fleets (keeps code and UI simple). The 3D model shows in the preview and as the ship icon/portrait where the game shows a ship; lanes and map keep their current flat icons.

## 2. Ships (all modifiers on balance.json: cargo 32, maintenance 40, trip_cost 60, ship_price 900, ship_cap 6)
Fields reuse `data/ships.json` (`cargo_mult`, `upkeep_mult`, `speed`) plus new `trip_mult`, `price_mult`, `cap_add`. Speed stays display only.

| Id | Name (working) | Role | cargo | upkeep | trip cost | price | other |
|---|---|---|---|---|---|---|---|
| small | Skerrit | All-rounder, the current ship | x1.00 | x1.00 | x1.00 | x1.00 | speed 1.0 |
| bulk | Bulkhead | Big hold, costly to run | x1.25 | x1.25 | x1.10 | x1.10 | speed 0.8 |
| dart | Dart | Cheap short hops, small hold | x0.80 | x0.70 | x0.85 | x0.90 | speed 1.3 |
| fleet | Tramp | Many hulls, each one weak | x0.90 | x1.00 | x1.00 | x1.15 | ship_cap +1, speed 1.0 |

Tradeoff logic: each ship's profit per ship per cycle should land within +-3 pct of Skerrit at the typical route (E decides the final steps). Bulkhead wins on high-margin full lanes and loses when cash is tight early. Dart is the safe first-cycles pick and falls behind late. Tramp gives a 7th hull (more routes) for a higher entry price and a smaller hold. Skerrit is the plain baseline and the "I do not want to think" choice; it has no perk, which is its price.

## 3. CEOs (names are working, story-designer may change them)
Each CEO has 3 small stats on a 1-3 scale and **exactly 5 points in total** (so no CEO is strictly better), plus one small perk that reuses an effect type from data/skills.json. One step of a stat = a small modifier (E sets the step; proposed order of size: 1 to 2 pct).

Stats: **Haggling** (`sale_price_pct`), **Thrift** (`upkeep_mult`, lowers maintenance), **Nerve** (`event_cut_pct`, smaller hit from bad events).

| Portrait | Name | Haggling / Thrift / Nerve | Perk (effect type) | Bio brief (2-3 sentences; story-designer writes EN + RU) |
|---|---|---|---|---|
| ceo_man_01 | Marek Voss | 1 / 3 / 1 | Old Contacts: bad events are announced one cycle early (`event_warning`) | Retired fleet quartermaster who kept ten ships alive on a shoestring. Counts every bolt; distrusts luck. Starts his own company because nobody would let him buy spare parts in bulk. |
| ceo_man_02 | Idris Kane | 3 / 1 / 1 | Quick Read: first-cycle price tips on the home market (`reveal_prices`) | Former broker with a famous smile and a bad habit of buying lunch for rivals. Reads a price board like other people read faces. Spends freely, sells hard. |
| ceo_woman_01 | Sela Oru | 1 / 1 / 3 | Hard Lanes: +1 route capacity step on the first lane (`route_capacity_pct`) | Flew supply runs through the worst lanes of the rim and still got home. Not afraid of bad news, only of idle ships. Prefers a plan with a backup and a second backup. |
| ceo_woman_02 | Tamsin Hale | 2 / 2 / 1 | Station Born: contract orders ask for more units, so a filled order pays more (`order_size_pct`) | Grew up in the Bazaar's docking rings; knows every clerk by name. Her contracts come with friendly paperwork and larger quantities. Calm, a little proud of the old place. |

Perks are small on purpose (E: about the size of one skill node at 1 step, never more than 3 pct of income). No perk touches cash or skill points (pillar: money never buys skill points).

## 4. Dominant-start check
16 combinations (4 CEO x 4 ships). Rules: (a) no combo beats the median combo by more than 1 cycle on median win cycle over 100 seeds; (b) no combo wins below 60 pct of the rate of the best. Method: QA bot runs with new options `--ceo=<id> --ship=<id>` on the sim (tools/sim.py needs the same modifiers). Likely pressure points: Thrift 3 + Dart (upkeep stacking to x0.7 x ~0.95), Haggling 3 + Bulkhead (big loads sold at +). If any combo is outlier, E trims the step, not the design. Upkeep modifiers multiply with skill `upkeep_mult` and are floored (E: floor x0.5).

## 5. Availability rule
No bio, ship line, perk name or stat label may name a good. Use only "cargo", "lanes", "events", "contracts", "prices", "maintenance". `Quick Read` must not list goods; it reveals the next price move text only for goods already visible via `Availability`. Run `_test_availability` text scan over the new ids.

## 6. Programmer mapping
**Data (new or extended)**
- `data/ships.json`: 4 types, new fields `trip_mult`, `price_mult`, `cap_add`, `model` (res://assets/ships/ship_corvette_0N/model_ship_corvette_0N.glb), `name_id`, `role_id`, `desc_id`. Keep `price_key`; modifiers are multipliers only.
- `data/ceos.json` (new): id (= portrait id), `name_id`, `bio_id`, `perk_name_id`, `perk_desc_id`, `stats {haggling, thrift, nerve}`, `perk {type, target, key}` where `key` names a balance value.
- `data/balance.json` (E adds): `ceo_step_haggling`, `ceo_step_thrift`, `ceo_step_nerve`, `ceo_perk_<id>_*`, `upkeep_floor`. Bump data_version.
- No edit to `data/availability.json` (no new good). Ship/CEO screens are not goods lists.

**Text ids (story-designer, EN + RU, in story/*.md and story/ru/)**
`LBL_SHIP_SCREEN_TITLE`, `LBL_SHIP_PICK_HINT`, `LBL_SHIP_START`, `LBL_STAT_CARGO`, `LBL_STAT_UPKEEP`, `LBL_STAT_TRIP`, `LBL_STAT_PRICE`, `LBL_STAT_SPEED`, `LBL_STAT_CAP`; per ship (x4) `LBL_SHIP_<ID>`, `TXT_SHIP_<ID>_ROLE`, `TXT_SHIP_<ID>_DESC`; `LBL_CEO_STAT_HAGGLING`, `LBL_CEO_STAT_THRIFT`, `LBL_CEO_STAT_NERVE`, `LBL_CEO_PERK`; per CEO (x4) `LBL_CEO_<ID>_NAME`, `TXT_CEO_<ID>_BIO`, `LBL_CEO_<ID>_PERK`, `TXT_CEO_<ID>_PERK_DESC`. `LBL_SHIP_SMALL` stays (Skerrit). Total about 36 ids per language. Generated files via `tools/build_story.py` only.

**Save fields**: `company.ceo_id` (string, default "ceo_man_01" for old saves = no perk applied, `""` = none), `company.ship_type` (default "small"), save version +1. Runtime: `Company.pending_ceo`, `pending_ship` next to `pending_company`. Old saves load with Skerrit and no CEO perk.

**Code**: gameplay-programmer applies ship and CEO modifiers where cargo, maintenance, trip_cost, ship_price and ship_cap are read (one helper, not scattered). ui-programmer: ship screen scene (SubViewport + Node3D + Camera3D + light + turntable, loads GLB like game/station.gd, frees on exit, preview only, ship is not in the main scene), CEO bio/stat panel on company screen. QA: bot options and the 16-combo sweep.

## 7. Proposals and costs
1. Ship screen with 3D preview and 4 ship types: ui-programmer M, gameplay-programmer M, economy-designer S.
2. CEO bios, stats, perks: story-designer M (EN+RU), economy-designer S, gameplay-programmer S, ui-programmer S.
3. Dominant-start sweep: qa-tester S.
Risk: choice paralysis at start (mitigation: 4 ships, Skerrit baseline, text card under 4 lines). Load time of a GLB in a menu (mitigation: load once, async).

## Open questions for the owner
1. 4 curated ships (recommended) or all 8 with stat differences?
2. Is one ship type per fleet fine, or must mixed fleets be possible later?
3. Should the CEO perk and stats be shown after the start (company panel) or only at selection?
