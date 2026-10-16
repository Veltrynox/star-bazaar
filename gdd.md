Game Design Document - Second Draft
Date: 16 October 2026

GIT: https://github.com/Veltrynox/star-bazaar/blob/main/gdd.md

========================================
1. EXECUTIVE SUMMARY / GAME SPECIFICITY
========================================

Oneliner: Star Bazaar is a single-player space trading game

Name: Star Bazaar
Genre: Space trading game
Engine: Unreal Engine 5
Platforms: macOS and Steam Deck (native Linux build).
View: Tilted top-down galaxy map.
Prototype scope: 10 planets, 5 commodities, 3 ship classes, 2 rival companies.
Constrains: I only have 7-8 weeks and AI agents to finish the game alongside my work and limited token budget, 2h per day max for the gamedevelopment + weekend 4-5h.
Target Audience: A strategy player like myself who likes spacecraft, stellaris types of games as the hypothetical end user.

Core loop: Check planet markets, buy cargo where it is cheap, fly it to where demand is high, sell, then reinvest in ships, upgrades and automated routes.

Win: At day 30, X% or more is Dominant Victory, having the largest share is Victory, and anything else is Defeat. Every campaign gets a clear verdict, and 60% becomes a stretch goal.

Loss: Negative cash or Rival share is more

1.1 DEVELOPER BACKGROUND AND SCOPE JUSTIFICATION
 
My Unreal knowledge - no game shipped, but worked with C++ and API, so I feel confident.
Ship models and sounds will not be produced from scratch during this
project. I will use an existing personal/licensed asset library for ship
meshes and sound effects.
Most of the codebase (economy simulator, rival logic, UI wiring, save
system, proxy integration) will be written with the help of AI coding
agents under my direction, rather than by hand.

1.2 PURPOSE AND TARGET AUDIENCE
This is a course capstone project: a complete, polished prototype built
and evaluated within one semester, not a commercial release with a price
or marketing plan.

========================================
2. GAME MECHANICS / PLAYER EXPERIENCE
========================================
The player makes money by moving goods between planets whose supply and demand differ, and spends it on a bigger, partly automated fleet.

2.0 Setting and Premise
Tone: Space-merchant fantasy set in a grimy, blue-collar industrial future. Ships are worn and heavy.

The Star Bazaar is a trade station on a new frontier. In 30 days its Merchant Council votes on an exclusive trade charter, decided by trade share. The player runs a small, broke hauling outfit (name and colour chosen at start) with Krugg, a sarcastic ex-tycoon alien partner who delivers onboarding objectives.

Rivals decide by simple rules, but each has a portrait, a voice and about 10 pre-written lines triggered by key moments:

The Vexari Consortium: boastful alien hagglers; fast ships, chase events.
Halvorsen-Krane Interstellar: a cold megacorp that speaks in memos; bulk freighters on long routes.

Event headlines carry neutral informative tone.

2.1 Onboarding and pacing

The first X (TBD later the exact timing) minutes teach the game through a 6-step objective chain shown in a small panel: buy on Kessa → sell on Doran → return trade → buy a survey permit → buy a second ship and automate it → reach 30% share. Each step gives a small credit reward. Players can skip the chain.

Systems unlock in stages: manual trading (day 1), first permit (days 3–5), first event, scripted to hit the starting planets (day 5), first upkeep (day 7, warned from day 5), automated routes with the second ship (days 8–10), restricted license (around day 15). Rivals start with one ship each and grow from day 8.

Balance targets: first permit ≈ 3–4 Light Hauler trips; permits rise in cost; restricted license ≈ one Bulk Freighter.

2.1 Loss mechanics
A player lose if you they can't pay weekly upkeep, with X day of grace and a warning. Show the danger ahead of time with a runway number, such as “Upkeep due in 2 days: 4,800 cr.”

2.2 Win mechanics
Every buy and sell at a planet market adds credits to the company that made it.

2.3 Time and campaign

The game runs in pausable real time at three speeds: pause, normal and double. One in-game day lasts 2 real minutes at normal speed, so a full campaign takes about an hour.

2.4 Starting situation

The player starts with one Light Hauler, a 20,000-credits and access to two planets. Kessa produces energy cheaply but imports food. Doran farms food but needs energy. The first profitable trade is visible within the first minute; the other eight planets unlock through survey permits.

2.5 Trading

Tapping a planet opens its market panel: buy price, sell price, stock and a trend arrow for each commodity. Prices come from each planet's production, consumption and stock. Buying in bulk raises the local price, so the player cannot drain one market forever.

The prototype trades five commodities:

- Technology modules: electronics and industrial parts.
- Science modules: laboratory equipment and research materials.
- Food: crops and processed supplies.
- Energy: fuel cells and reactor parts.
- Luxury goods: rare consumer items, sold only on two restricted planets.

2.6 Ships

There are three ship classes:

- Courier: small cargo hold, fastest speed, low weekly upkeep. Used for quick runs to chase events.
- Light Hauler: medium cargo hold, fast speed, medium weekly upkeep. The starting ship and an all-rounder.
- Bulk Freighter: large cargo hold, slow speed, high weekly upkeep. Moves cheap goods on long automated routes.

Ships have built-in running costs. The route card shows one number, expected profit per trip after fuel and upkeep, so players can compare routes at a glance.

2.7 Automated routes
The player assigns a ship to a two-planet route, a commodity and a maximum buy price. The ship loops on its own.
If the buy price is above the limit or the company can’t afford a load, the ship waits docked at the buy planet and re-checks every few in-game hours. Idle ships still pay upkeep.
Every route has a visible status: Running, Waiting (price too high / low cash), Blocked by event, or Losing money. Each non-running status shows its reason, how long it has lasted, and a one-tap fix where possible (e.g. “Raise limit to X”).
Status appears on the map (icon over a docked ship), on the route card (status line, last-5-runs dots, tappable profit breakdown), and as a HUD fleet badge counting idle routes. The first stop of each route triggers one toast; the weekly upkeep report lists idle days per ship.

2.8 Upgrades and permits

- Expanded hold: +50% cargo on one ship.
- Tuned engines: +25% speed on one ship.
- Survey permit: unlocks one more planet.
- Restricted trade license: unlocks the two luxury-goods planets.

2.9 Market events

Every 5 in-game days a news alert slides in with a headline and a story of up to 45 words. The affected planets pulse on the map, their price arrows change, and a chip shows how many days the effect lasts. The player can pause, read and reroute. The same could happen when a player lands on the planet.

Examples:

- A reactor fire on Kessa cuts energy output; energy demand there doubles for 4 days.
- A crop blight on Doran halves food production for 3 days.
- A research grant on Vell raises demand for science modules.
- A smuggled luxury cargo floods Orin; luxury prices drop for 2 days.
- An ion storm raises fuel costs on the Kessa to Vell lane.

Every event changes at least one market number. Stories with no effect on play are not allowed.

2.10 Rival companies

Two rival companies trade alongside the player, with ships in their own colours on the map. Each day, each rival picks their strategy (TBD the strategy) it can afford and buys from the same stock the player does. Rivals react to events too. Their decisions come from simple game rules. But the player can see only the outcome of their action in a report at some point, not their plans.

2.11 Cut from the prototype, but keep in mind for the future.

Quality tiers for goods, trading posts, a company headquarters, crew management and multiplayer are out of scope. They can return after the semester if the core loop is fun.

2.12 UI
Trade share bar pinned to the top of the screen, split into three colours (you, Rival A, Rival B), with a tick mark at the win threshold and a small up or down arrow for today’s change.
Day counter next to it: “Day 12 / 30.”
Cash and next upkeep beside the counter, turning red when cash won’t cover the bill.
Cause and effect in the news feed, for example: “Helix Corp undercut you on Kessa energy, share −3%.” This connects player actions to the bar.
Per-planet share as a small three-colour strip on each market panel, so the player knows where to fight.
End screen: a line graph of all three shares over 30 days, with event markers. This makes the verdict feel earned rather than arbitrary.

========================================
3. AI ARCHITECTURE
========================================

The game uses Claude agents. Each agent does a single job and returns structured output that Unreal Engine imports or validates.

3.1 Dev crew (offline, during development)

The crew mirrors a small studio. The Design Review Agent acts as lead designer; the others are specialists.

1. Design Review Agent (lead designer): This agent checks the GDD and the game's data tables for rule conflicts whenever either one changes
- Model: Claude Opus 5.5.
- Input: GDD text and all data tables as JSON and the engine's code library.
- Output: error report JSON listing the rule, location, conflict and suggested fix.

2. Economy Data Agent (systems designer): This agent writes each planet's production, consumption and starting prices when a planet or commodity is added to the design
- Model: Claude Sonnet 5.5.
- Input: planet concept, commodity list and balance targets and the engine's code library.
- Output: planet rows as JSON for the Unreal Data Table.

3. Event Library Agent (narrative writer): This agent pre-writes 200 fallback market events when the event rules change.
- Model: Claude Sonnet 5.5.
- Input: event rules, planet IDs and commodity IDs.
- Output: 200 event JSON objects.

4. Agent that works on the gameplay systems, inventory etc.
- Model: Claude Sonnet 5.5.
- Input: event rules, planet IDs and commodity IDs and the engine's code library.
- Output: 200 event JSON objects.

5. Agent that works of galaxy creating logic
- Model: Claude Sonnet 5.5.
- Input: Code library
- Output: A system that generates a galaxy.

6. Agent that plays the game and finds issues in the game
- Runs during the game? TODO

========================================
4. PROMPT CONSTRAINTS ( I'll improve this part as I learn more about the agents! )
========================================

========================================
5. ENGINE INTEGRATION
========================================
TBD - will do after I finalize the game idea

========================================
6. TECHNICAL STRATEGY
========================================
TBD - will do after I finalize the game idea

6.3 Other constraints:
TBD - will do after I finalize the game idea

6.4 Token budget:
TBD - will do after I finalize the game idea

6.6 Milestones (WILL CHANGE LATER AFTER the first draft)
 
1. Basic gameplay loop (~25 hours): buy on Kessa, sell on Doran, pay the
   weekly bill, win or lose. Core loop playable with no network, minimal
   UI, one ship, two planets.
 
2. Improving the logic (~30 hours): full economy across all 10 planets,
   automated routes, upgrades, permits, two rival companies, scoring and
   the win/loss checks (60% market share, insolvency).
 
3. Improving the visuals (~20 hours): ship models and backgrounds
   integrated from the existing asset library, planet art, UI polish,
   market panel and route card visuals.
 
4. Balance and test (~15 hours): full 30-day run across all 10 planets,
   tuning prices/events, checks of the 60% win and insolvency loss
   conditions, platform build checks on macOS and Steam Deck.
 
Total: ~115 hours, matching the stated ~105-120 hour budget for 7-8 weeks.