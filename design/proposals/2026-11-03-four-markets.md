# Four Markets: the new goal, the new trees, the new endings

> Part of the Four Markets pack. Where the docs disagree, `2026-11-03-four-markets-summary.md` (reconciliation table R1 to R13) decides.

Date: 2026-11-03. Author: feature-designer. Status: CORE DESIGN, WAITS FOR OWNER on the questions in section 9. economy-designer and story-designer build on this file next, so ids and names below are fixed and will not be renamed. Display names (goods, bots, ending titles) are working names; story-designer finalises text. No balance numbers are set here except structure; where a size is written (S/M/L, "small/medium/large") economy-designer maps it to a value in data/balance.json.

Owner decisions this file follows: replace the old A/B/C tree and the old endings; keep existing shared events as the one-time pool; share = player sales / total sales per market over a rolling window; win = over 50% share in one market; lose = bankruptcy or one bot over 50% in every market; 3 bots seen only on a stats graph; markets are abstract categories, never map objects; spreading must fail by numbers; crafting feeds markets (Minerals and Biotech most).

## 0. How the loop changes (summary)

- The goal line becomes: "Goal: more than 50% of one market." Cash is no longer the goal. Cash is the fuel (ships, workshops, fees).
- Every good belongs to one market. Selling it at a planet adds to your sales volume in that market. Three bots add their own volume. Share = yours / all.
- Skills (skill points) and tech (researched by crafting) raise your volume, lift prices, or hurt bots. Events are choices that hit bots and shape the ending.
- Money still never buys skill points.

## 1. The four markets and the goods

Market ids (fixed): `mil`, `lux`, `min`, `bio`. Display: Military, Luxury, Minerals, Biotech.

| Id | One-line identity | Plays like |
|---|---|---|
| mil | Steady buyers and big volume; the only market where you can hit a rival directly. | Throughput + sabotage |
| lux | Few units, huge price swings; timing and events win it. | Timing + price |
| min | Bulk, mining and smelting; slow to build, hard to dislodge. | Crafting + capacity |
| bio | Slow compounding; labs and stored stock grow over time, events can hurt. | Crafting + patience |

### 1.1 Every existing good, assigned

| Good id | Today's name | Market | Tier | Note |
|---|---|---|---|---|
| energy | Energy | mil | 1 | fuel for fleets; also a common raw (usable in any recipe) |
| food | Food | bio | 1 | also a common raw |
| chips | Logic Cores | mil | 2 | trade |
| silk | Starsilk | lux | 2 | trade |
| ore | Rock Ore | min | 1 | mined free at clusters; also a common raw |
| dross | Dross Salt | min | 2 | mined at dead world Cinderrest |
| nullglass | Nullglass | min | 2 | mined at dead world Greywake |
| plate | Fabric plate (Voltara plate_buy/sell) | min | 3 | crafted at the Fabric (existing) |

Null Core (ship fitting, existing) is not a good and stays unchanged.

Rule "common raws": energy, food and ore may be used as recipe inputs for any market. Buying or mining them is not a sale and adds no overhead. Crafted tier 3+ goods use only own-market goods plus common raws. So a Military player never needs Minerals to reach the top of Military.

### 1.2 New goods (11)

Price bands are tiers, not prices: T1 8-30, T2 20-45, T3 50-90, T4 110-250 credits. economy-designer sets real prices, planets that make or want each, and recipe batch size.

| Id | Working name | Market | Tier | How obtained | Recipe (workshop) | Unlocked by |
|---|---|---|---|---|---|---|
| rivets | Rivet Guns | mil | 2 | trade (made at Voltara) | none | none |
| cells | Pulse Cells | mil | 3 | crafted | 2 energy + 1 chips (Munitions Line) | MIL_1 |
| armour | Hull Armour | mil | 4 | crafted | 3 cells + 1 chips (Munitions Line) | MIL_4 (tech) |
| musk | Sunmusk | lux | 2 | trade (made at lush/ocean worlds) | none | none |
| cask | Vintage Cask | lux | 3 | crafted | 3 food (Atelier) | LUX_4 (tech) |
| gems | Cut Glimmers | lux | 4 | crafted | 2 ore + 1 silk (Atelier) | LUX_1 |
| ingot | Ingot | min | 2 | crafted | 2 ore (Smelter) | MIN_1 |
| alloy | Lattice Alloy | min | 4 | crafted | 1 plate + 2 ingot (Smelter) | MIN_4 (tech) |
| spores | Spore Cultures | bio | 2 | trade (made at lush/ocean/agrarian) | none | none |
| gel | Bio-Gel | bio | 3 | crafted | 2 food + 1 spores (Culture Lab) | BIO_1 |
| seed | Gene Seed | bio | 4 | crafted | 2 gel + 1 spores (Culture Lab) | BIO_4 (tech) |

Totals: 8 old goods + 11 new = 19. Trade goods: 8 old minus plate, plus rivets, musk, spores. Crafted: plate, ingot, alloy, cells, armour, cask, gems, gel, seed. Crafting weight: min 3 crafted (plate, ingot, alloy) + Fabric existing, bio 3 of 4, mil 2 of 5, lux 2 of 3 trade-heavy. Minerals and Biotech lean on crafting most; Luxury and Military lean on trade and events.

### 1.3 Workshops (generalises the existing Fabric)

One workshop per market, built once at a trading post for a one-time credit cost (same rule as `fabric_build_cost`; money buys the building, never skill points):
`smelter` (min; the Fabric stays as the plate station and is built the same way), `munitions` (mil, "Munitions Line"), `atelier` (lux), `culture_lab` (bio). A workshop makes the market's recipes at `workshop_batches_per_cycle` (start 1, as the Fabric). A workshop is unlocked by the node noted in the table (the root skill of the market). Crafted goods are put in company storage and sold by normal Sell orders and routes.

## 2. Market share, window, win and lose

Formulas (fixed names):
- Sales volume of a sale = units sold x base sell price of the good (base price from data, not the event-adjusted price, so price events never inflate share). Only a Sell order or a route delivery that sells at a planet counts. Moving to storage or a planet-to-planet transfer is not a sale.
- `V_p(M, c)` = player volume in market M in cycle c. `V_b(M, c)` = bot b volume (b = bot_1, bot_2, bot_3).
- `share(M, c) = sum over last W cycles of V_p / sum over last W cycles of (V_p + V_bot_1 + V_bot_2 + V_bot_3)`.
- Rolling window `share_window` W = 8 cycles (BIO_5 raises it to 12 for bio only). Before the window is full it uses the cycles played. If total volume is 0, share = 0.

Run length: `win_cycle` = 40 cycles of 1 minute (replaces 30). Bots start at cycle 1.

Win:
- Early win: share(M) over 50% (strictly greater) at the end of 5 consecutive cycles (`win_hold_cycles` 5), checked from cycle 20 (`win_earliest_cycle` 20). The game pauses and shows the ending of M.
- Final check: at the end of cycle 40, if any market has share over 50%, that market wins. If two markets qualify at once, the higher share wins.
- Win market = `win_market`; it picks the ending pair (section 6).

Lose / non-win:
- `END_BANKRUPT`: stranded (zero ships and cash below ship_price, existing rule) a third time. The first two keep today's rescue stipend. (Today's rescue is a setback, not a loss; this adds the real loss owner asked for.)
- `END_SWEPT`: from cycle 20, one bot is over 50% share in all four markets at the end of 3 consecutive cycles (`sweep_hold_cycles` 3).
- `END_OUTCOMPETED`: cycle 40 reached, no market over 50%. Not a "game over" screen: a soft ending that names the player's best market and share and the leading bot, so the run still reads as a result.
Bot behaviour is numeric only; bots never appear on the map.

### 2.1 Bots (fixed ids)

| Id | Working name | Lean | Notes |
|---|---|---|---|
| bot_1 | Harrow Combine | mil, min | heavy volume, slow growth |
| bot_2 | Velvet Concord | lux, bio | spiky volume (swings with events), medium growth |
| bot_3 | Dunmere Syndicate | all four evenly | low per-market volume, steady; the sweep threat |

Per bot, per market, three stats (fixed names), all set by economy-designer: `strength` (base volume per cycle in base-value units), `growth` (added to strength per cycle), `tier` (1-4; each tier multiplies strength; tier rises on a fixed schedule per bot, e.g. first at cycle ~10, then ~10 later). Volume each cycle = strength x tier multiplier x small seeded noise (+-10%).
Gap rule: a market where the player's share is under 10% gives each bot extra `growth` (`bot_gap_growth`). Bots fill markets you ignore.
Event hits (section 4) change these three stats only: `strength` by S/M/L percent, `growth` by S/M/L, `tier` by -1 or +1.
Target (economy-designer checks in sim): a focused player in one market passes 50% between cycles 28 and 36; a player split over two markets reaches 50% in none; over all four, never.

### 2.2 Spreading punished (all by numbers)

1. Multi-market overhead: each cycle the player pays `market_overhead` x (n_active - 1)^2 credits, where n_active = markets with player volume above 5% of the player's total volume in the window. 1 market: 0. 2: x1. 3: x4. 4: x9. Paid like upkeep.
2. Mixed cargo: the N3 bundle bonus (`bundle_bonus_pct`) now applies only to a load of goods from one market. A route load of two or more markets pays `cross_load_trip_mult` (start 1.25) on trip_cost.
3. Skill points are finite and shared. One full market tree costs 10 points. With the 3 Foundations, two full markets (23) is a stretch; four (43) is out of reach.
4. Gap rule above: ignoring a market lets bots grow there, so it never becomes cheap to enter later.
5. Workshop cost per market (one-time credits), and tech only advances in the market whose goods you craft.
6. Points from share (section 3.4) are earned only in a market where you already have volume, which rewards depth.

## 3. Skills and tech

The old A/B/C tree is replaced. Skills cost skill points; tech costs no points and is researched by crafting.

### 3.1 Shape (same for every market)

Seven nodes per market, ids `<MKT>_1` .. `<MKT>_7` (MKT = MIL, LUX, MIN, BIO). 4 skills (S) and 3 tech (T). 5 tiers.

| Node | Kind | Tier | Prerequisite | Skill cost |
|---|---|---|---|---|
| _1 | skill | 1 | Foundation named in 3.3 where noted | 1 |
| _2 | tech | 2 | _1 | craft goal |
| _3 | skill | 2 | _1 | 2 |
| _4 | tech | 3 | _2 | craft goal |
| _5 | skill | 3 | _3 | 3 |
| _6 | tech | 4 | _4 and _5 | craft goal |
| _7 | skill (capstone) | 5 | _6 | 4 |

Full tree: 10 skill points. Tech: `tech_goal_2` 15, `tech_goal_4` 30, `tech_goal_6` 20 units crafted (counted in that market's workshop only; counting starts when the prerequisite is met, so no pre-grinding; economy-designer may retune per market). A tech completes by itself and shows a notice.
Effects are tied to the four channels: your volume (V), price, capacity/crafting, and bot interaction. Sizes S/M/L set by economy-designer.

### 3.2 Nodes

**Military (MIL)**
- MIL_1 S Drydock Deals (old A5): ship upkeep lower (M); unlocks Munitions Line and `cells`.
- MIL_2 T Cell Casting: Military volume up (S).
- MIL_3 S Quick Loading (old A4): routes carrying Military goods move more per cycle (S).
- MIL_4 T Armour Plating: unlocks `armour`; Military sale price up (S).
- MIL_5 S Embargo Desk: every 8 cycles, choose one bot: its Military strength down (L) for 3 cycles. Bot interaction.
- MIL_6 T Contract Doctrine: Military price events against you are weaker (M).
- MIL_7 S Standing Fleet (capstone): all bots' Military growth halved for the rest of the run.

**Luxury (LUX)**
- LUX_1 S Price Whisper (old B3): shows next cycle's prices; Luxury sale price up (S); unlocks Atelier and `gems`.
- LUX_2 T Fine Finishing: Luxury price-up events pay more (M).
- LUX_3 S Event Forecast (old B4): warns of the next event one cycle early (all markets).
- LUX_4 T Cask Cellar: unlocks `cask`; stored Luxury stock does not lose value when a planet closes.
- LUX_5 S Patron's List: sales at a planet with a price-up event count extra volume in share (M).
- LUX_6 T Hallmark: Luxury sale price up (M).
- LUX_7 S Guild Seal (capstone): once per run, buy a rival's best client: one chosen bot's Luxury strength down (L) for 5 cycles.

**Minerals (MIN)**
- MIN_1 S Fabrication Licence (old F1, now root; needs Foundation FND_PROSPECT): unlocks the Fabric and Smelter and `ingot`.
- MIN_2 T Smelting: Minerals volume up (S); ore loads take no order space.
- MIN_3 S Cold Survey (old M1): mine dross at Cinderrest; cluster yield up (S).
- MIN_4 T Alloying: unlocks `alloy`; workshop batches per cycle +1 in min.
- MIN_5 S Deep Cut (old M2): mine nullglass at Greywake.
- MIN_6 T Lattice Works: each Minerals batch yields +1 unit.
- MIN_7 S Cornered Seam (capstone): bots' Minerals strength down (M) for the rest of the run.

**Biotech (BIO)**
- BIO_1 S Standing Orders (old B2): Buy and Sell orders move more (M); unlocks Culture Lab and `gel`.
- BIO_2 T Culture Banks: Biotech stock held in planet storage grows slowly each cycle (capped).
- BIO_3 S Seed Bank (old A2): planet storage capacity up (M).
- BIO_4 T Gene Splicing: unlocks `seed`.
- BIO_5 S Clinic Contracts: Biotech share window is 12 cycles instead of 8 (steadier share).
- BIO_6 T Hardy Strains: Biotech events cost the player less (S) and a closed planet reopens one cycle sooner.
- BIO_7 S Patent Wall (capstone): bots' Biotech strength down (M) for the rest of the run.

Capstone and bot-interaction skills are the "bot interaction" channel the owner asked for; they stack with event hits.

### 3.3 Foundations (not a market, not in endings)

Three small unlocks the game needs to function, kept from the old tree. Ids fixed: `FND_STORAGE`, `FND_PERMIT`, `FND_PROSPECT`. Skill points, cost 1 each, learnable from cycle 1, order free.
- FND_STORAGE (old A1 + A2 folded): Space Storage; the old Deep Holds capacity bonus is dropped here (it lives in BIO_3).
- FND_PERMIT (old C1 + C3): Permit Charter; permits for system 2 and routes between systems (Long Haul folded in).
- FND_PROSPECT (old B1): routes may start at asteroid clusters.
Total points available in any run: Foundations 3 + one market 10 = 13 for a focused player.

### 3.4 Points

Existing sources stay (planet, route, system). New: `skill_points_share_20` (first time share in a market reaches 20%: +1) and `skill_points_share_35` (+2) per market, paid once per market. This pays depth, not width. economy-designer checks the supply: a focused run must afford its market's 10 plus Foundations; two full markets must not be affordable by cycle 40.

### 3.5 Old skills: map or drop

| Old | Fate |
|---|---|
| A1 Space Storage | FND_STORAGE |
| A2 Deep Holds | BIO_3 (storage capacity) |
| A4 Quick Loading | MIL_3 |
| A5 Drydock Deals | MIL_1 |
| B1 Prospecting | FND_PROSPECT |
| B2 Standing Orders | BIO_1 |
| B3 Price Whisper | LUX_1 |
| B4 Event Forecast | LUX_3 |
| C1 Permit Charter | FND_PERMIT |
| C2 Survey Beacon | dropped (the permit rule keeps the survey inside FND_PERMIT) |
| C3 Long Haul | folded into FND_PERMIT |
| C4 Colonial Rights | dropped (permit credit discount removed) |
| M1 Cold Survey | MIN_3 |
| M2 Deep Cut | MIN_5 |
| F1 Fabrication Licence | MIN_1 (root; no longer needs M1 and M2) |

Saves: old saves do not load into the new goal (see Q2).

## 4. Events

### 4.1 Types

1. Market chains (new, per market): story with choices, bot hits, ending flags.
2. Shared one-time pool: simple events, each fires at most once per run, drawn at `event_interval` (4). A chain step takes priority over a pool event in its cycle; max one event per cycle.

### 4.2 Chain format (fixed)

- Per market: two chains. Chain A: 3 steps (ids `<MKT>_A1`..`A3`). Chain B: 4 steps (ids `<MKT>_B1`..`B4`). 7 steps per market, 28 total. Each step is one event in data/events.json (kind `C`), existing fields (`choices`, `follow_id`, `follow_after`) reused.
- Every step has exactly 2 choices: Open and Hard. Open is the fair or slow path; Hard is the fast or ruthless path. Hard pays more now (cash, price or bigger bot hit); Open pays later or steadily. Neither is strictly better.
- State carried per market: `stance_<mkt>` (integer: Open +1, Hard -1 per step), `<mkt>_steps_done`, `<mkt>_bot_marked` (the bot hit most; feeds later step text), `<mkt>_rival_broken` (true if a bot's tier in that market was cut). Story texts for steps 2+ have two body variants chosen by the last choice (so one event row, two bodies, not branching ids).
- Triggers (rules, with min 3 cycles between steps of a market): A1 first sale in the market after cycle 4; A2 share 15% or 6 cycles after A1; A3 tech _2 done or share 25%; B1 skill _3 learned or share 30%; B2 4 cycles after B1; B3 share 40% or tech _4 done; B4 share 45%. B4 therefore always fires before a 50% win is possible. Missing steps count 0.
- Rule R-BOT (fixed): every market chain choice, both Open and Hard, changes at least one bot stat (strength, growth or tier of a bot in that market). Open also changes the player's side (stable gain); Hard also costs the player something or raises risk. Every choice's effect is shown in the tag line like current events.
- Delayed results (follow-ups) reuse `follow_after` (default `dead_follow_cycles` 4). A result is a normal event that also names a bot stat change.

### 4.3 Chain table (sizes S/M/L = bot hit; Open +1, Hard -1)

Format: id | trigger | situation | Open: bot effect | Hard: bot effect.

Military (bots most often hit: bot_1)
- MIL_A1 | first sale | a garrison offers a long contract | Open: bot_1 growth S down | Hard: bot_1 strength M down, hostile rumour
- MIL_A2 | share 15% | a border post asks you to supply both sides | Open: bot_3 tier stays (no change) and bot_3 growth S down | Hard: bot_1 tier -1 (you arm its enemy)
- MIL_A3 | tech _2 | a quartermaster sells you his rivals' ledger | Open: bot_1 strength S down | Hard: bot_1, bot_3 strength M down each
- MIL_B1 | skill _3 | a fleet needs a refit fast | Open: bot_3 growth S down | Hard: bot_1 strength L down, upkeep up
- MIL_B2 | +4 | the refit breaks a treaty clause | Open: bot_2 strength S down | Hard: bot_1 tier -1
- MIL_B3 | share 40% | an arms fair invites you | Open: bot_3 strength M down | Hard: all three bots growth S down, a fee
- MIL_B4 | share 45% | the fleet asks who it answers to | Open: bot_1 growth M down (it loses its client) | Hard: bot_1 and bot_3 strength L down

Luxury (bot_2 mostly)
- LUX_A1 | first sale | a patron wants exclusive first pick | Open: bot_2 strength S down | Hard: bot_2 strength M down, prices up
- LUX_A2 | share 15% | a master weaver is poached or paid | Open: bot_2 growth S down | Hard: bot_2 tier -1
- LUX_A3 | tech _2 | a rumour of a rival's flaw | Open: bot_3 strength S down | Hard: bot_2 strength L down for 3 cycles, risk of price drop
- LUX_B1 | skill _3 | a gala wants your goods | Open: bot_2 growth S down | Hard: bot_2 strength M down
- LUX_B2 | +4 | the gala's guest list leaks | Open: bot_3 growth S down | Hard: bot_2 tier -1
- LUX_B3 | share 40% | a duke asks for a price lock | Open: bot_2 growth M down | Hard: bot_1 and bot_2 strength M down
- LUX_B4 | share 45% | the guild offers a seat | Open: bot_2 strength M down | Hard: bot_2 and bot_3 strength L down

Minerals (chain A is the three dead-world event pairs already in the game, retrofitted)
- MIN_A1 = EV29 (Cinderrest sickness; follow EV30, EV31) | Open (pull out): bot_1 growth S down | Hard (keep mining): bot_1 strength M down
- MIN_A2 = EV32 (Greywake wall; follow EV33, EV34) | Open (shore up): bot_3 growth S down | Hard (carry on): bot_1 strength M down
- MIN_A3 = EV35 (rival warns; follow EV36, EV37) | Open (share the lane): bot_1 strength S down | Hard (race): bot_1 tier -1
- MIN_B1 | skill _3 | a rich seam, claimed twice | Open: bot_1 growth S down | Hard: bot_1 strength L down
- MIN_B2 | +4 | a smelter strike | Open: bot_3 growth S down | Hard: bot_1 strength M down
- MIN_B3 | share 40% | a bidder offers to buy your stock | Open: bot_3 strength S down | Hard: bot_1 tier -1
- MIN_B4 | share 45% | the last seam in reach | Open: bot_1 growth M down | Hard: bot_1 and bot_3 strength L down

Biotech (bot_2 and bot_3)
- BIO_A1 | first sale | a blight sample arrives | Open: bot_2 growth S down | Hard: bot_2 strength M down
- BIO_A2 | share 15% | a clinic asks for open seed | Open: bot_3 growth S down | Hard: bot_2 tier -1
- BIO_A3 | tech _2 | a lab accident | Open: bot_2 strength S down | Hard: bot_2 and bot_3 strength M down
- BIO_B1 | skill _3 | a cure needs a rare strain | Open: bot_3 strength S down | Hard: bot_2 strength L down
- BIO_B2 | +4 | the strain mutates | Open: bot_2 growth S down | Hard: bot_3 tier -1
- BIO_B3 | share 40% | a patent request | Open: bot_3 growth M down | Hard: bot_2 and bot_3 strength M down
- BIO_B4 | share 45% | the seed bank door | Open: bot_2 strength M down | Hard: bot_2 and bot_3 strength L down

These lines are intent only; story-designer writes situations, titles and both variants. economy-designer maps S/M/L, player-side effects and cash. Plans must follow rule R-BOT. Minerals chain A needs text and tag edits only (the events exist); EV31, EV33, EV34, EV36, EV37 stay as results and also gain a bot stat line.

### 4.4 Shared one-time pool

Kept (25): EV01-EV16 (price and closure events), EV17 (debris), EV20 (asteroid), goods events EV21, EV22, EV24, EV25, EV26, EV28. All become fire-once-per-run. Their balance and text stay, no bot stat needed (optional).
Retired (1): EV18 (shield offer). The shield and its hidden ending flag go with the old endings. If the owner wants the shield mechanic kept without the ending role, it stays as a pool event (Q5).
New simple events (12): three per market, `EV40`..`EV51`, each a single price or closure event for the new goods or workshops (for example a Sunmusk glut, a Pulse Cell recall, a smelter outage, a Culture Lab quarantine). Format identical to EV01-16. No choice needed; if a choice exists it follows R-BOT (optional).
Pool size 37; at `event_interval` 4 the run draws about 10 over 40 cycles, so the pool never runs dry and chain steps (28 over the run, 7 per market) add about 7 for a focused player.

## 5. How everything pushes toward the goal

| Action | Pushes by |
|---|---|
| Goods sold | share directly (V_p) |
| Skills learned | volume, price, capacity, or bot hits (3.2) |
| Tech crafted | tech completes, unlocks recipes and effects; crafted goods are higher tier, so more base value per sale |
| Events | choices cut bot stats; Open also steadies your side; every step moves stance |
| Crossing a share mark | skill points (3.4), and the next chain step |

## 6. Endings

Eight market endings plus three non-win endings. Ids fixed (`END_*`).

| Id | Market | Kind | Theme (story-designer writes) |
|---|---|---|---|
| END_MIL_GOOD | mil | good | Peacekeeper: the fleets deter; the Commons feels safe |
| END_MIL_BAD | mil | bad | Warlord: the arsenal answers to whoever pays |
| END_LUX_GOOD | lux | good | Patron: beauty reaches the many, the Plan notices |
| END_LUX_BAD | lux | bad | Gilded cage: everyone wants what only you hold |
| END_MIN_GOOD | min | good | Foundation: the seams build the next homes |
| END_MIN_BAD | min | bad | Strip: the dead worlds spread |
| END_BIO_GOOD | bio | good | Harvest: seed and cure for all |
| END_BIO_BAD | bio | bad | Patent wall: the seed is locked |
| END_BANKRUPT | none | loss | the third stranding; the ledger closes |
| END_SWEPT | none | loss | one bot owns every market |
| END_OUTCOMPETED | none | soft | cycle 40, no market over 50% |

Selection rule (first match wins): the win fires for `win_market` M. Ending = `END_<MKT>_GOOD` if `stance_M` is 0 or higher; otherwise `END_<MKT>_BAD`. A tie is good. Because every chain step has an Open and a Hard choice and B4 fires before 50%, stance is almost always defined. If fewer than 4 steps were seen (very fast or odd run), good is the default.
Flavour lines inside an ending (not new endings) come from: capstone `<MKT>_7` learned, the number of tech done in M (0 to 3), `<mkt>_rival_broken`, and the second-best market over 25%. Up to 4 epilogue lines, story-designer sets copy. This replaces the old Bare/Partial/Full tiers.
The old Release/Corporation choice screen and all old END_* ids are retired. The final screen shows the win market, its share, the Open/Hard record and the three bots' shares.

## 7. Bots on the stats menu

Per cycle the game stores V_p and each bot's V for all four markets (80 numbers a cycle). A new menu "Standings" (hotkey `L`, also in the game menu) shows four tabs, one per market, each a line graph over the cycles played: player line plus bot_1, bot_2, bot_3 lines, with the 50% line marked and the current share written. A header chip in the top bar shows the best market and share ("Military 34%"). Bots never appear on the map. A bot's tier change is shown as a mark on its line.

## 8. What this touches (for later goals)

Data (economy-designer):
- data/balance.json: remove `win_cash`; set `win_cycle` 40; add `share_window`, `win_hold_cycles`, `win_earliest_cycle`, `sweep_hold_cycles`, `market_overhead`, `cross_load_trip_mult`, `bot_gap_growth`, `skill_points_share_20`, `skill_points_share_35`, `workshop_*_build_cost`, `workshop_batches_per_cycle`, `tech_goal_2/4/6`, per-node `skill_cost_<id>` and effect keys, per-bot `bot_<n>_<mkt>_strength/growth/tier_schedule`, event hit sizes S/M/L; drop old skill keys and shield keys (or keep if Q5).
- New data/goods.json (id, market, tier, kind, recipe), data/markets.json, data/bots.json, data/skills.json rewrite (Foundations plus 28 nodes), data/events.json (28 chain rows, 12 pool rows, once-only flag, bot effect fields), data/planets.json and systems.json prices for 11 goods, data/planet_types.json for trade-good sources, tools/sim.py (market model, bots, overhead), pace targets.
Code (gameplay-programmer): new market/share/bot module (per-cycle volume, window, hold, win and lose checks), goal/stats hooks in run_stats.gd, trade.gd (goods list beyond 8, sales tagging by market), route_engine.gd (cross_load rule, bundle bonus per market), generalise fabric.gd to workshops, a tech progress tracker, events.gd (stance, steps, once-only pool, bot effect tag, chain triggers, R-BOT), rewrite skill_tree.gd and ending_picker.gd, end_screen.gd flow, remove the Release/Corporation choice, save_game.gd (new version), cash_forecast.gd (goal line), debug_menu.gd (Force goal becomes Force market share), planet_panel.gd and ship_panel.gd for new goods and workshops.
UI (ui-programmer): skill screen redesigned (Foundations row plus four market columns, tech nodes show craft progress), Standings menu and top-bar chip, goal line text, workshop panel, end screen, tutorial copy, notices.
Story (story-designer): 28 chain steps (+ results), 12 pool events, 11 goods, 11 endings and epilogue lines, skill and tech texts, bot names, goal text, glossary in story/voice.md.
Docs (doc-manager): gdd.md goal, loss, endings, skills sections; gdd-skills.md; story/endings.md; story/skills.md; story/events.md.
QA (qa-analyst): bot strategies (focus one market, spread two, spread four, ignore), sim check that no spread wins and focus wins in the target window, end-to-end per ending.
Art (artist, optional): market icons, goods icons.

## 9. Open questions for the owner

1. Run length: is 40 cycles right (the old run was 30) so trees and chains have room? Default chosen: 40.
2. Old saves: the goal and tree change, so old saves are dropped. Acceptable? Default chosen: yes, version bump.
3. Good/bad rule: ending quality comes from Open vs Hard chain choices only (stance 0 or more = good). Do you also want skills or share to affect it? Default chosen: no.
4. Loss weakness: "one bot over 50% in every market" is hard to trigger. Is the soft ending `END_OUTCOMPETED` at cycle 40 an acceptable non-win? Default chosen: yes.
5. Shield (EV18) and its planet effect: retire with the old ending, or keep as a pool event? Default chosen: retire.
6. Names: bots, goods, ending themes are working names; OK for story-designer to settle?
