Star Bazaar: Game Design Document

This file holds the main design only. It has no balance numbers.
- Numbers (prices, costs, caps, thresholds, timings, rival strengths, event effects, ship and CEO multipliers) live in data/balance.json, data/planets.json, data/systems.json, data/ships.json, data/ceos.json and data/goods.json and are owned by the economy designer. Where this file and the data disagree, the data wins.
- How the player acts today (screens, flow): story/game-flow.md.
- Skill trees, space storage, permits, game menu: gdd-skills.md.
- Agent workflow and constraints: gdd-process.md.
- Story voice and texts: story/ (voice.md, endings.md, events.md, skills.md).
- Proposals and their status: design/proposals/.

========================================
1. THE GAME
========================================
Star Bazaar is a single-player space trading game for macOS, made in Godot 4 (GDScript).

The player runs a trading company, not a freighter. Ships fly by themselves on automated routes. The player decides where to invest; the routes do the work. Cash is fuel, not the goal.

Goal: take over one market. Hold more than half of the share of one of four markets (Military, Luxury, Minerals, Biotech) against three rival companies.

Pillars:
- Company manager, not hand trader. The player never buys or sells cargo by hand.
- Trading stays profitable but never trivial.
- The win must feel earned. Focus on one market wins; spreading over many does not.
- Money never buys skill points.
- The owner makes every design decision.

========================================
2. CORE LOOP
========================================
The game runs in cycles; the length of a cycle in real time is a balance value (data/balance.json), not fixed by this file. Time can be paused at any time to look, plan and buy; nothing earns while paused. The game starts paused after the preface.

Each cycle the player reads the income and picks the next investment:
- a new route, or an upgrade of a full route,
- one more ship on a route,
- a workshop (and the goods to feed it),
- a permit to open a new solar system,
- a skill.

Ten solar systems are planned in all. Built: two designed systems of five planets each. Systems 3 to 5 are live temporary placeholders (a few planets, temporary names, prices and suns) and systems 6 to 10 are switched-off placeholders; none of 3 to 10 is designed yet.

Then the routes earn. Every route pays its income at the end of the cycle, already net of its trip cost and maintenance. The player cannot run out of money mid-trip, and an unprofitable route idles and costs nothing.

Inflow: route income, local Sell orders, events. Outflow: ships, permits, workshops, upgrades, links and the Null Core (all chosen by the player), and market overhead from spreading too wide.

Rescue: a player with no ships and no money for one, or no income and nothing left to sell, gets a small stipend, a few times at most, never twice in a cycle and never in a repossession cycle. It is a setback, never a way to win. When every stipend is spent and the run cannot restart, it ends in bankruptcy (section 4).

========================================
3. MECHANICS
========================================
Planets and prices. Planets trade on prices only. The margin on a good is the sell price minus the buy price. Players read the planet panels to choose routes. Each planet has a type and a role (what it has plenty of, what it lacks).

Orders and routes.
- Each planet has a company storage per good.
- A Buy order brings stock into storage; a Sell order sells it. Both are toggles, and no ship is needed.
- "Send to..." makes a one-way route that moves stock from one storage to another. It takes a free ship from the company automatically. The destination can be a planet, a Space Storage station or (with Prospecting) the start can be an asteroid cluster.
- Several ships can run on one lane. The shared orders of its planets and a total ship cap limit how many.
- Route states: running, stalled (empty source), waiting for room, blocked (a closed or permanently full destination).
- Route level: a full lane can be upgraded once to level 2, which raises its margin for a one-off fee. A route is one record (source, destination, ship, level, orders), so finer control can be added later without changing the loop.
- Route offset: a route's line bends round other planets, the sun and other routes. A longer bent path raises that ship's upkeep a little, up to a cap.
- Mixed load: a lane that carries goods of several markets pays more trip cost. Several goods of one market sold at one planet in a cycle earn a small bonus, capped per planet. Stock stuck at a planet with no buyer can be dumped as a salvage sale at a share of the normal price (always worse than a Sell order).

Ships. There are four ship types in data/ships.json: Skerrit (the plain all-rounder), Bulkhead (carries more, costs more to run and fly, slow), Dart (cheaper trips, fast) and Tramp (cheap upkeep, a little less cargo, a higher purchase price, room for one more ship in the cap). A fleet has one type, fixed by the CEO (there is no separate ship step) and kept for the whole run. Types differ only by multipliers on the balance values (cargo, upkeep, trip cost, price) and by an addition to the ship cap. Speed is shown and drives the scout flight (see Discovery). Each ship earns on its own. A ship's first cycle on a route pays pro rata, so buying at the last second earns nothing extra. A fleet total is limited by a ship cap: the base cap in balance.json plus the cap bonus of the fleet's ship type (data/ships.json).

CEOs. The player picks one of four CEOs on the New company screen (data/ceos.json); Start goes straight into the game. Each CEO comes with a fixed branch (one market, one CEO per market, stored as run.branch) and a fixed ship type; the branch hides no goods and changes no win or ending rule. Each has three stats from one to three (haggling lifts sale prices, thrift cuts ship upkeep, nerve softens bad events; cash effects only, no share effect) and one perk: an early warning of the next events, a view of the home market's prices in the first cycle, extra capacity on the first lane, or larger orders. The CEO is a small head start, never a way to win by itself.

Markets, goods and workshops.
- Four abstract markets, never map objects. Every good belongs to one market except energy, a common raw good that feeds any market. The full goods list, recipes and workshops are in data/goods.json and data/markets.json.
- Raw trade goods are bought at planets. Ore comes from asteroid clusters, dross and nullglass from dead worlds (see Mining). Crafted goods come from workshops and are sold like any other. Some crafted goods are inputs of others (for example rounds feed arms, medicine feeds seed, ingots and plate feed alloy).
- Workshops: Smelter and Fabric (Minerals), Munitions Line (Military), Atelier (Luxury), Culture Lab (Biotech). Each is built once, for a one-off fee, in a system the player picks, and is unlocked by that market's skill tree. Each cycle a workshop crafts a few batches from stock in company storage (the Space Storage of its system) and puts the output back; no credits move. Inputs missing means the workshop stalls and says what it needs.
- The Fabric turns dross and nullglass into lattice plate at the trading post. It also builds the Null Core, a rare one-per-run fit for one ship: lower trip cost and immunity to pirate volume cuts. Pirates are planned (task T250), not built: no pirate ever appears yet, so the immunity has no effect for now.
- Share in a market comes from the player's sales of that market's goods over a recent window compared with the three rivals. Only sales at a planet count. Skills can raise the weight of sales, stretch the window or cut rivals (gdd-skills.md).

Mining. Prospecting (a Foundation skill) lets a route start at an asteroid cluster. Ore is loaded for free at a cluster; the only cost is the lane. A cluster holds a finite amount, drawn down by each cycle's yield, and never refills; an empty cluster's lane stalls. There is no refill or survey yet (balance.json carries unused ore_refill_units and ore_survey_fee keys; no code reads them). A few clusters are active in each system. Cold Survey and Deep Cut open the two dead worlds.

Dead worlds. Cinderrest (system 1, dross) and Greywake (system 2, nullglass) are rock worlds with no market of their own for food or energy. They open from a set cycle and once their skill is learned. A dead world's panel offers mining instead of buying. Each cycle a running route mines it, a danger meter rises, and events follow on a delay (income cuts or boosts, lost cargo). The meter's size and the loss rules are balance values.

Rivals. Three computer companies (working names Harrow Combine, Velvet Concord, Ostrel Syndicate) that exist only as numbers (graphs and a Competitors menu); each has one scenery ship for the whole game, tinted per competitor; clicking it shows a card with the competitor and its strongest market (otherwise a visual only: no cargo, no blocking, no combat, no effect on any number). It starts in system 1, flies to a destination and then idles there; it moves again only when the game gives a reason (a system opened by permit, an event popup), and then it may visit an opened system; it is drawn only while it is in the viewed system, and a closed system shows no ship traffic. The player has one Pathfinder that changes system when it jumps. Each has a base strength and a growth in every market, tier-ups at fixed cycles, a small seeded random noise (so a run and a reloaded save agree), and extra growth in markets where the player is absent. Events, chain choices and skills can slow them or move their tier. Numbers are in balance.json (bot_* keys).

Spreading penalty. Working in several markets at once costs overhead, mixed cargo loads cost more, and skill points are finite. A focused run wins; a spread run does not.

Permits and systems. System 1 (Hollin Reach) is the playable core. System 2 (Dunmere Reach) opens with a permit that needs the Permit Charter skill; the permit is bought in the system window (galaxy view, click the system), not in the Skills window. Systems 3 to 5 are temporary placeholders that are live in a normal game: each opens with a permit like system 2 (Permit Charter needed) and has a few planets with temporary names and prices, to be replaced by designed content. Systems 6 to 10 are switched off.

Space Storage and Storage Link. One Space Storage per system, a big company storage that planet storage feeds slowly (gdd-skills.md section 4). It also backs routes and Sell orders in its system: a Sell order and a route can draw on it when the planet storage is empty. Clicking a station opens its stock view. A Storage Link joins the Space Storages of two systems for goods only (never credits): it needs a build cost in goods and an upkeep in energy only (a small amount per cycle), moves stock by standing orders each cycle without a ship, goes dormant when upkeep runs out and can collapse if left dormant. It appears only once its rule in data/availability.json is true.

Discovery (built, on by default). The Pathfinder is the player's own scout ship, separate from the fleet (no cargo, no route, no ship-cap slot). With discovery on, only the home world starts open; the player flies the Pathfinder to other planets, which reveals them, then builds a trading post (living world) or a mining platform (dead world) there. Only such established planets can be bought from, sold to, routed or stored on. The key discovery_enabled in balance.json switches it; at 0 every planet is open from the start and the scout does nothing. The game ships with it on (owner decision 2026-11-05). Exploration mode (button in the Ships panel): the Pathfinder flies by itself to each world of its current system that is not yet established, surveys it and builds the post or platform at the normal cost, waiting at the world while cash is short. A manual order or the button ends it; it follows the game clock, stays in its system, is saved, and shows one notice when every world of the system stands. See design/proposals/2026-11-05-ship-flight-discovery.md.

Progressive disclosure (Availability). A good, workshop or storage feature is shown only when the player could use it now; hidden means not drawn at all, and no text may name a hidden good. Rules live in data/availability.json and are evaluated by game/conditions.gd, the same evaluator used for chain triggers, event filters and workshop unlocks. At the start only energy and food at Voltara show. Goods and features appear as skills are learned, systems opened and workshops built.

Skills. Skill points come from first visits, first routes, entering new systems and the first time any world reaches a Prosperity tier (market share milestones no longer pay, kept behind a switch), plus one from paying to deflect the asteroid event. Six Foundations (three required before any market tree, three optional) plus four market trees of fifteen or sixteen nodes (see gdd-skills.md). The on-screen name is "Skill points".

Events. One event happens every few cycles, never more than one per cycle. Every event first shows as a small icon; the game does not pause. A pure price change is minor: its icon fades out if ignored and the price effect applies anyway. Any other event (choices, chain steps, closed planets) is important: its icon stays until clicked and no further event comes before it is answered. Clicking an icon opens the event window, pauses, and moves the map to the planet it names and highlights it. An event pool filter only picks goods and planets that are visible and open at that moment.
- Market chains: each market has a seven-step chain (data/chains.json). Steps fire on a trigger (first sale after a cycle, a share level, cycles since the previous step). Every step offers two neutral choices; each gives something, costs something and hits a rival. A hidden lean per market, built from those choices, picks the GOOD or BAD ending of that market. The game never shows it.
- Shared pool: one-time events that change prices, close planets for a while, or hit rivals.
- Branch events (EV52 to EV55, one per market): early one-time pool events, only in the first cycles and only once that market's goods are visible and traded. Two cash options: a dark-market sale (more cash) or a public sale (less). Hidden: a dark sale may be spotted once per run (chance in balance), after which half of the profitable events (positive pool events and chain options with a gain) never appear. Never shown in any text.
- Debris in orbit: pay a fee to clear it or leave it; routes from that planet carry less while it stays. Some skills make a market's routes immune.
- Asteroid approach: pay to deflect it (earns a skill point and leaves a small new cluster to mine) or decline and risk a cut to a planet's storage.
- Skills can announce events one or two cycles early.

========================================
4. WIN, LOSS AND ENDINGS
========================================
Win. The run is won by raising the Star Bazaar. Once a world reaches the capital tier the player may found the Bazaar there: one capital per run, final. It is raised in stages; each stage needs a bill of the run branch's goods (by goods tier, climbing with the stage) held in the capital's planet storage, a quorum of other worlds at a prosperity tier and, from a set stage, a quorum world in another system. A stage completes at cycle end when all three hold; the bill is consumed. The last stage wins (the Opening flight is added later). Market share no longer wins, sweeps or costs overhead; markets keep counting silently for now. The run branch picks the ending family and the hidden lean picks GOOD or BAD.

Loss and soft ending:
- Bankrupt: cash stays negative after ships are repossessed and none is left, or the run is a dead end (every stipend spent, no income, nothing running, nothing to sell, not enough cash to restart).
- Unfinished (soft, never a loss): the term (last cycle) ends before the Bazaar is finished; the epilogue scales with the stages done.

Free play. Every end screen offers Continue: the run goes on with no further endings (the Bazaar keeps counting).

Endings. The run ends with exactly one ending.
- Win: END_MIL_GOOD / BAD, END_LUX_GOOD / BAD, END_MIN_GOOD / BAD, END_BIO_GOOD / BAD.
- Loss: END_BANKRUPT.
- Soft: END_UNFINISHED.
- Epilogue lines under a win say what the company did (capstone skill, finished techs, a rival that lost ground, a strong second market). They never show counts, labels or the hidden direction.
- No achievements, trophies or badges. The reward for good play is ending quality only.
- Run stats of answered runs are kept locally only (user://stats.json). The autosave is user://autosave.json.

Retired: the cash goal, the Release or Corporation choice, and the shield (its leftover shield_* keys in balance.json are removed by task T255).
Prosperity (empire growth v2, phase 1, T256): every world with a post has a Prosperity tier (a dead world is Barren, with no ladder yet). Each world has a short need list, set by rule: energy plus the run's branch goods of its tier or lower, minus what it already sells to the player. Sales at the world fill its needs during the cycle. At cycle end every need met is a step of progress, any shortfall costs steps, and a full ladder raises the tier. A world never loses a tier. A need whose good is not yet visible shows as locked. Growth pays: every world pays a tax each cycle by its tier (one summary notice), and the first time any world reaches a tier the run earns skill points (never bought with credits). Conditions can ask any_tier:<n> and planet_tier:<planet>/<n>.

Need pricing (T257): prices follow need. A need opens a buyer at a world that had no sell price for the good. A need that stays short makes its sell price rise a step each cycle, up to a cap, and it settles back once met (hungry). Units sold above a need's demand in a cycle pay only a share of the price (surplus); one switch extends surplus to every sale for the owner to try. Forecasts, lane margins and best-partner hints use the same prices, so the best lane moves as worlds grow and dumping one good on one world stops paying.
Prosperity (empire growth v2, phase 1, T256): every world with a post has a Prosperity tier (a dead world is Barren, with no ladder yet). Each world has a short need list, set by rule: energy plus the run's branch goods of its tier or lower, minus what it already sells to the player. Sales at the world fill its needs during the cycle. At cycle end every need met is a step of progress, any shortfall costs steps, and a full ladder raises the tier. A world never loses a tier. A need whose good is not yet visible shows as locked. Prices and rewards come in later tasks.

Growth on the map (T264): each world with a post draws a thin ring of notches (progress in its tier; amber-red while it is restless) and its need icons under the name: met bright, a short amber pulse when a need becomes met, unmet dim, locked as "?". Closed, barren and not-yet-established worlds show nothing. The Bazaar capital gets a small marker once a capital is set. Drawn in screen space, ignores clicks.

Planet tier look (T265): a grown world looks grown. Night-side city lights (a few points at tier 1, denser per tier) and a warm halo ring show on the planet, driven by its Prosperity tier. A tier change eases in over about a second (scaled by the motion setting). Planet size and dead worlds are unchanged.
