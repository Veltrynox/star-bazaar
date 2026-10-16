SPACE TRADE SIM: FRONTIER ROUTES
Game Design Document - First Draft
Date: 14 October 2026


========================================
1. EXECUTIVE SUMMARY
========================================

Space Trade Sim: Star Bazaar is a single-player economic strategy game. The player grows a one-ship trading company into the dominant hauler of a ten-planet frontier region.

Genre: Casual economic strategy.
Engine: Unreal Engine 5.
Platforms: macOS and Steam Deck (native Linux build).
View: Tilted top-down galaxy map.
Campaign length: 30 in-game days, about 60 real minutes (1 day = 2 minutes), a player can pause a game at any time.
Prototype scope: 10 planets, 5 commodities, 3 ship classes, 2 rival companies.

Core loop: check planet markets, buy cargo where it is cheap, fly it to where demand is high, sell, then reinvest in ships, upgrades and automated routes.

Win: hold at least 60% of the region's trade routes when day 30 ends. A market-share bar at the top of the screen in a menu window.

Loss: the company is insolvent if its cash is below zero by the end of the 30 day period, or the competitive “AI” holds more than 60% of the turnover.

The One Wow: every 4 in-game days or on landing to a planet for finding trades - the Market Event Agent writes a trade-wire news story that reacts to the player's own network or gives you some interesting story that also add or removes something from the resources.

How AI is used: a crew of five offline Claude agents produces the game's data, ship models, sounds and fallback events during development. One runtime agent generates market events during play. Deterministic game code calculates every price and every credit; no agent can change them directly.


========================================
2. GAME MECHANICS
========================================

The player makes money by moving goods between planets whose supply and demand differ, and spends it on a bigger, partly automated fleet.

2.1 Time and campaign

The game runs in pausable real time at three speeds: pause, normal and double. One in-game day lasts 2 real minutes at normal speed, so a full campaign takes about an hour. Payment days fall on days 7, 14, 21 and 28; a countdown on the top bar shows the next one and the amount due.

2.2 Starting situation

The player starts with one Light Hauler, a 50,000-credit loan and access to two planets. Kessa produces energy cheaply but imports food. Doran farms food but needs energy. The first profitable trade is visible within the first minute; the other eight planets unlock through survey permits.

2.3 Trading

Tapping a planet opens its market panel: buy price, sell price, stock and a trend arrow for each commodity. Prices come from each planet's production, consumption and stock. Buying in bulk raises the local price, so the player cannot drain one market forever.

The prototype trades five commodities:

- Technology modules: electronics and industrial parts.
- Science modules: laboratory equipment and research materials.
- Food: crops and processed supplies.
- Energy: fuel cells and reactor parts.
- Luxury goods: rare consumer items, sold only on two restricted planets.

2.4 Ships

There are three ship classes:

- Courier: small cargo hold, fastest speed, low weekly upkeep. Used for quick runs to chase events.
- Light Hauler: medium cargo hold, fast speed, medium weekly upkeep. The starting ship and an all-rounder.
- Bulk Freighter: large cargo hold, slow speed, high weekly upkeep. Moves cheap goods on long automated routes.

Every jump burns fuel, and every ship adds to the weekly maintenance bill. The route card shows fuel and upkeep beside expected profit, so the player sees whether a trip pays.

2.5 Automated routes

The player assigns a ship to a two-planet route, a commodity and a maximum buy price. The ship loops on its own. It skips a run when the price is above the limit or the company lacks the cash. The route card shows profit per trip and turns red when a route starts losing money.

2.6 Upgrades and permits

- Expanded hold: +50% cargo on one ship.
- Tuned engines: +25% speed on one ship.
- Survey permit: unlocks one more planet.
- Restricted trade license: unlocks the two luxury-goods planets.

2.7 Market events (what the player sees)

Every 3 in-game days a news alert slides in with a headline and a story of up to 45 words. The affected planets pulse on the map, their price arrows change, and a chip shows how many days the effect lasts. The player can pause, read and reroute.

Examples:

- A reactor fire on Kessa cuts energy output; energy demand there doubles for 4 days.
- A crop blight on Doran halves food production for 3 days.
- A research grant on Vell raises demand for science modules.
- A smuggled luxury cargo floods Orin; luxury prices drop for 2 days.
- An ion storm raises fuel costs on the Kessa to Vell lane.

Every event changes at least one market number. Stories with no effect on play are not allowed.

2.8 Rival companies

Two rival companies trade alongside the player, with ships in their own colours on the map. Each day, each rival picks the most profitable route it can afford and buys from the same stock the player does. Rivals react to events too, so the player has to move first. Their decisions come from simple game rules, not from a language model.

2.9 Cut from the prototype

Quality tiers for goods, trading posts, a company headquarters, crew management and multiplayer are out of scope. They can return after the semester if the core loop is fun.


========================================
3. AI ARCHITECTURE
========================================

The game uses six Claude agents. Five form an offline dev crew that builds the game's content and never ships with it. One runs during play and is the One Wow agent. Each agent does a single job and returns structured output that Unreal Engine imports or validates.

3.1 Dev crew (offline, during development)

The crew mirrors a small studio. The Design Review Agent acts as lead designer; the others are specialists.

1. Design Review Agent (lead designer): This agent checks the GDD and the game's data tables for rule conflicts whenever either one changes, and the player sees a campaign without dead ends, such as a route that loses money on every trip or one that earns unlimited money.

2. Economy Data Agent (systems designer): This agent writes each planet's production, consumption and starting prices when a planet or commodity is added to the design, and the player sees ten markets that each have their own shortages and surpluses.

3. Ship Model Agent (3D artist): This agent writes a Blender Python script that assembles a low-poly ship from modular parts when a ship class is added to the ship table, and the player sees a Courier, Light Hauler and Bulk Freighter whose cargo pods visibly match their capacity.

4. Sound Agent (sound designer): This agent writes MetaSound parameter presets when a ship class or a UI event is added, and the player hears a distinct engine hum for each ship class, a chime on each sale and an alarm sting on market-shock news.

5. Event Library Agent (narrative writer): This agent pre-writes 200 fallback market events when the event rules change, and the player sees offline events that look and play exactly like live ones.

3.2 Runtime agent (during play)

6. Market Event Agent (live-ops writer, ONE WOW): This agent writes one bounded market event every 3 in-game days, aimed at the player's current trade network, and the player sees a news alert, pulsing planets and prices that jump on the map.

This is the One Wow agent because its output is the most visible to the player and changes their next decision. The dev crew shapes how the game looks and sounds; this agent shapes what the player does next.

3.3 Agent inputs and outputs

Design Review Agent
- Runs: offline, once per revision.
- Model: Claude Opus 5.5.
- Input: GDD text and all data tables as JSON.
- Output: error report JSON listing the rule, location, conflict and suggested fix.

Economy Data Agent
- Runs: offline, once per new planet or commodity.
- Model: Claude Sonnet 5.5.
- Input: planet concept, commodity list and balance targets.
- Output: planet rows as JSON for the Unreal Data Table.

Ship Model Agent
- Runs: offline, once per ship class.
- Model: Claude Sonnet 5.5.
- Input: ship spec JSON (cargo, speed, part list).
- Output: Blender Python script that exports an FBX file.

Sound Agent
- Runs: offline, once per ship class or UI event.
- Model: Claude Sonnet 5.5.
- Input: sound brief (event, mood, length).
- Output: MetaSound preset JSON.

Event Library Agent
- Runs: offline, through the Batch API.
- Model: Claude Sonnet 5.5.
- Input: event rules, planet IDs and commodity IDs.
- Output: 200 event JSON objects.

Market Event Agent
- Runs: during play, every 3 in-game days.
- Model: Claude Haiku 5.5.
- Input: market snapshot, the player's top 3 routes, the last 3 events and the rules.
- Output: one event JSON object.

3.4 Deterministic systems (no language model)

- Economy Simulator: turns stock, production, consumption and event effects into prices, and settles every purchase, sale, fuel bill and payment.
- Rival Logic: picks routes for the two rival companies using fixed profit rules.
- Event Validator: checks each event against the schema and limits in section 4 before the economy applies it; a failed event is replaced by one from the fallback library.


========================================
4. PROMPT CONSTRAINTS
========================================

Every agent returns JSON only, in a fixed schema, so that code can check its output before anything reaches Unreal Engine.

4.1 Market Event Agent (runtime)

- Return exactly one JSON object; no text outside it.
- Choose event_type from five types: supply_drop, demand_spike, supply_glut, lane_hazard, demand_drop.
- Use only planet and commodity IDs from the list in the prompt; never invent new ones.
- Affect at most 2 planets and 2 commodities.
- Keep magnitude between 0.10 and 0.60 (a 10% to 60% change) and duration_days between 2 and 5.
- Target a planet on one of the player's top 3 routes in at most every second event, so events surprise the player without singling them out.
- Do not repeat an event type used in the last 3 events.
- Write a headline of at most 8 words and a story of at most 45 words.
- Tone: dry frontier trade-wire news. Name the cause and the effect on trade; no jokes, no second person, no advice to the player.
- Never mention credits, the player's balance or rival companies.

Sample output:

{
  "event_type": "demand_spike",
  "planets": ["kessa"],
  "commodities": ["energy"],
  "magnitude": 0.50,
  "duration_days": 4,
  "headline": "Reactor fire grounds Kessa grid",
  "story": "A coolant failure has shut Kessa's main reactor. Colony officials are buying fuel cells at any price while crews work on repairs, expected to take four days."
}

4.2 Dev crew

Design Review Agent
- Must return: a list of issues, each with rule, location, conflict, severity and suggested_fix.
- Hard limits: report only conflicts it can trace to a quoted line or data row; no style opinions.
- Style: plain, one sentence per issue.

Economy Data Agent
- Must return: planet rows matching the Data Table columns.
- Hard limits: prices between 10 and 500 credits; every planet produces at least 1 and imports at least 1 commodity.
- Style: planet descriptions of at most 25 words.

Ship Model Agent
- Must return: one Blender Python script.
- Hard limits: uses only the approved part kit; at most 1,500 triangles; cargo pod count equals cargo capacity divided by 10.
- Style: commented code, no add-ons.

Sound Agent
- Must return: MetaSound preset JSON.
- Hard limits: 0.2 to 3 seconds for UI sounds; loops for engines; parameters only from the approved list.
- Style: short brief per sound.

Event Library Agent
- Must return: an array of event objects in the 4.1 schema.
- Hard limits: same limits as 4.1; no two events with the same headline.
- Style: same tone as 4.1.


========================================
5. ENGINE INTEGRATION
========================================

All Claude output enters Unreal Engine 5 as data or assets, never as code the game runs. Offline content is checked when it is imported; live events are checked in game.

Pipeline overview:

Offline lane (during development):
Dev crew agents (5 Claude agents, Opus and Sonnet 5.5) -> structured output (JSON rows, Blender scripts, presets) -> import and check (Blender exports FBX, editor imports JSON) -> Unreal assets (Data Tables, meshes, sounds, 200 fallback events).

Live lane (one event every 3 in-game days):
Game snapshot (market table, top routes, last events) -> serverless proxy (holds the API key, limits each player) -> Market Event Agent (Claude Haiku 5.5, returns one event) -> Event Validator (schema, IDs, limits; retries once if bad) -> Economy Simulator (applies the effect, recalculates prices) -> news alert and map (headline, pulsing planets, new prices).

If a live reply fails, the Event Validator takes a fallback event from the offline event library instead.

5.1 Offline content

- Planet and event data: the Economy Data and Event Library agents write JSON. An editor import script loads it into Data Tables for planets, commodities and fallback events, and rejects any row that breaks the schema.
- Ship models: the Ship Model Agent's script runs in Blender and exports an FBX file. Unreal imports it as a static mesh with fixed socket names for engine glow and cargo pods.
- Sounds: an editor utility script turns the Sound Agent's presets into MetaSound assets.
- Design reviews: the Design Review Agent's report is read by the designer and is never imported.

5.2 Live events

1. One in-game day before an event is due, a C++ event subsystem builds the snapshot from the economy.
2. The game sends one HTTPS request through Unreal's HTTP module to the proxy, which calls Claude Haiku 5.5 with the section 4.1 prompt.
3. The reply is parsed with Unreal's JSON tools into a market event struct.
4. The Event Validator checks it. On failure the game retries once. A second failure, a reply slower than 20 seconds or no network means an unused event from the fallback Data Table is used instead.
5. The Economy Simulator applies the effect for its duration. A UMG news widget shows the headline and story, and the affected planets pulse on the map.

5.3 Builds

The same project builds for macOS and as a native Linux build for Steam Deck. The only network call is the HTTPS request in step 2, so the game is fully playable offline.


========================================
6. TECHNICAL STRATEGY
========================================

The whole semester's Claude usage is estimated at about $31, budgeted at $50; a single campaign costs at most $0.016 in live events.

6.1 Agent roles

- Design Review Agent: lead designer. One job: find rule conflicts in the GDD and data. Model: Claude Opus 5.5.
- Economy Data Agent: systems designer. One job: write planet market data. Model: Claude Sonnet 5.5.
- Ship Model Agent: 3D artist. One job: script ship models from parts. Model: Claude Sonnet 5.5.
- Sound Agent: sound designer. One job: write MetaSound presets. Model: Claude Sonnet 5.5.
- Event Library Agent: narrative writer. One job: pre-write 200 fallback events. Model: Claude Sonnet 5.5 through the Batch API.
- Market Event Agent (One Wow): live-ops writer. One job: write one live event every 3 in-game days. Model: Claude Haiku 5.5.

6.2 Biggest constraint: the game depends on a network API

The Market Event Agent needs an internet connection. A Steam Deck is often played offline, an API call can take seconds or fail, and an API key must never ship inside the game files.

How it is handled:

1. Key stays off the device: the game calls a small serverless proxy that holds the Claude API key and rate-limits each player.
2. Never blocks play: the request is sent one in-game day before the event is due. Ships, prices and the clock keep running while it waits.
3. Always has an answer: if the reply is late, invalid or the device is offline, the game plays an event from the 200-event fallback library. The player sees the same alert either way.

6.3 Other constraints

Unreliable structured output
- Effect: bad JSON or a made-up planet could break the economy.
- Handling: the Event Validator checks every field; one retry, then a fallback event.

Rate limits
- Effect: too many calls are refused.
- Handling: the live game makes 1 call per 6 real minutes; offline crew jobs run through the Batch API.

Context and cost
- Effect: sending the full game state wastes tokens.
- Handling: send a compact snapshot (market table, top 3 routes, last 3 events, rules).

Tokenizer
- Effect: newer Claude models count about 30% more tokens for the same text.
- Handling: the estimates below are already set generously above expected use.

6.4 Token budget: live game

Prices for Claude Haiku 5.5: $0.10 per million input tokens and $0.50 per million output tokens.

- One event call: 4,000 input tokens and 800 output tokens, costing $0.0008.
- One campaign of 10 events: 40,000 input tokens and 8,000 output tokens, costing $0.008.
- One campaign, worst case (every event retried once): 80,000 input tokens and 16,000 output tokens, costing $0.016.
- 1,000 campaigns, worst case: 80 million input tokens and 16 million output tokens, costing $16.

6.5 Token budget: dev crew for the semester

Prices per million input / output tokens: Claude Opus 5.5 $4 / $20, Claude Sonnet 5.5 $2 / $10, Claude Sonnet 5.5 through the Batch API $1 / $5.

- Design Review: 30 runs at 60,000 input and 6,000 output tokens each. Total 1.8M input and 0.18M output. Cost $10.80.
- Economy Data: 40 runs at 15,000 input and 8,000 output tokens each. Total 0.6M input and 0.32M output. Cost $4.40.
- Ship Model: 45 runs (3 classes x 15 tries) at 10,000 input and 6,000 output tokens each. Total 0.45M input and 0.27M output. Cost $3.60.
- Sound: 30 runs at 8,000 input and 4,000 output tokens each. Total 0.24M input and 0.12M output. Cost $1.68.
- Event Library: 800 runs (4 batches x 200) at 3,000 input and 800 output tokens each. Total 2.4M input and 0.64M output. Cost $5.60.
- Testing the live agent: 300 campaigns at the worst-case rate from 6.4. Total 24M input and 4.8M output. Cost $4.80.

Total: $30.88.

The budget is set at $50 to cover extra iterations. Usage is checked weekly in the Claude Console.

6.6 Milestones

1. Economy without AI: buy on Kessa, sell on Doran, pay the weekly bill, win or lose. Playable with no network.
2. Fleet and rivals: three ship classes, automated routes, upgrades, permits and two rival companies.
3. Dev crew content: planet data, ship models, sounds and the 200-event fallback library generated and imported.
4. Live events: proxy, Market Event Agent, Event Validator and the news alert UI.
5. Balance and test: all 10 planets, a full 30-day run, and checks of the 60% win and insolvency loss.

The game is playable after milestone 1, so a late AI feature cannot leave it unshippable.


Sources

- Claude API pricing: https://platform.claude.com/docs/en/about-claude/pricing (checked 14 October 2026)