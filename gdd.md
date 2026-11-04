Star Bazaar: Game Design Document (fifth draft, short form)
Date: 4 November 2026

This file holds the main design only. It has no balance numbers.
- Numbers (prices, costs, caps, thresholds, timings, rival strengths, event effects) live in data/balance.json and data/planets.json and are owned by the economy designer. Where this file and the data disagree, the data wins.
- How the player acts today (screens, flow): story/game-flow.md.
- Skill trees, space storage, game menu: gdd-skills.md.
- Agent workflow and constraints: gdd-process.md. Change history: gdd-log.md.
- Story voice and texts: story/ (voice.md, endings.md, events.md).

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
The game runs in cycles. Time can be paused at any time to look, plan and buy; nothing earns while paused.

Each cycle the player reads the income and picks the next investment:
- a new route,
- one more ship on a route,
- a workshop,
- a permit to open a new solar system,
- a skill.

Then the routes earn. Every route pays its income at the end of the cycle, already net of its trip cost and maintenance. The player cannot run out of money mid-trip, and an unprofitable route idles and costs nothing.

Inflow: route income, events. Outflow: ships, permits, workshops, upgrades (all chosen by the player), and market overhead from spreading too wide.

Rescue: a player with no ships and no money for one gets a small stipend, a few times at most. It is a setback, never a loss and never a way to win.

========================================
3. MECHANICS
========================================
Planets and prices. Planets trade on prices only. The margin on a good is the sell price minus the buy price. Players read the planet panels to choose routes.

Orders and routes.
- Each planet has a company storage per good.
- A Buy order brings stock into storage; a Sell order sells it. Both are toggles, and no ship is needed.
- "Send to..." makes a one-way route that moves stock from one storage to another. It takes a free ship from the company automatically.
- Several ships can run on one lane. The shared orders of its planets and a total ship cap limit how many.
- Route states: running, stalled (empty source), waiting for room, blocked (a closed or permanently full destination).
- A route is one record (source, destination, ships, level, orders), so later upgrades and finer control can be added without changing the loop.

Ships. One small ship type. Each ship earns on its own. A ship's first cycle on a route pays pro rata, so buying at the last second earns nothing extra.

Markets and workshops.
- Four abstract markets, never map objects. Every good belongs to one market; a few raw goods (energy, food, ore) feed any market.
- Each market has one workshop, built once and unlocked by that market's skill tree. Crafted goods are sold like any other.
- Share in a market comes from the player's sales of that market's goods over a recent window compared with the three rivals. Only sales at a planet count.

Rivals. Three computer companies that exist only as numbers (graphs and a Competitors menu, never on the map). They grow in every market, faster in markets the player ignores. Events, chain choices and skills can slow them.

Spreading penalty. Working in several markets at once costs overhead, mixed cargo loads cost more, and skill points are finite. A focused run wins; a spread run does not.

Permits and systems. System 1 (Hollin Reach) is the playable core. System 2 (Dunmere Reach) opens with a permit that needs the Permit Charter skill. System 3 is on hold.

Skills. Skill points come from first visits, first routes, entering new systems and share milestones in a market. Three Foundations plus four market trees (see gdd-skills.md). The on-screen name is "Skill points".

Events. One event happens every few cycles, never more than one per cycle. Every event first shows as a small icon; the game does not pause. A pure price change is minor: its icon fades out if ignored and the price effect applies anyway. Any other event (choices, chain steps, closed planets) is important: its icon stays until clicked and no further event comes before it is answered. Clicking an icon opens the event window, pauses, and moves the map to the planet it names and highlights it.
- Market chains: each market has a seven-step chain. Every step offers two neutral choices; each gives something, costs something and hits a rival. A hidden lean per market, built from those choices, picks the GOOD or BAD ending of that market. The game never shows it.
- Shared pool: one-time events that change prices, close planets for a while, or hit rivals.

========================================
4. WIN, LOSS AND ENDINGS
========================================
Win. Hold more than the win share of one market, for several cycles in a row (the early win), or at the end of the final cycle (the late win). A market's win is not declared before its chain is finished or a late cycle is reached. The market held picks the ending.

Loss and soft ending (checked in this order: win, swept, bankrupt):
- Bankrupt: cash stays negative after ships are repossessed and none is left.
- Swept: share stays under a low line in all four markets for several cycles.
- Outcompeted (soft, not a loss): the last cycle passes with no market held.

Endings. The run ends with exactly one ending and no choice screen.
- Win: END_MIL_GOOD / BAD, END_LUX_GOOD / BAD, END_MIN_GOOD / BAD, END_BIO_GOOD / BAD.
- Loss: END_BANKRUPT, END_SWEPT.
- Soft: END_OUTCOMPETED.
- Epilogue lines under a win say what the company did (capstone skill, finished techs, a rival that lost ground, a strong second market). They never show counts, labels or the hidden direction.
- No achievements, trophies or badges. The reward for good play is ending quality only.

Retired: the cash goal, the Release or Corporation choice, and the shield.

========================================
5. UI
========================================
- Top bar: goal line, cash, date, share panel, forecast of net income per route.
- Planet panel with buy and sell prices; route and ship panels show net income, status and what one more ship would add.
- Notification board for missions and notices; event pop-ups with one or more choices.
- Competitors menu (opened from the game menu, the share panel or L): per market, a share graph, a table and a log of recent rival moves.
- New Game opens a separate New company screen: a typed or randomly generated company name and one of four CEO portraits; the game menu shows both.
- Debug and game-control menus are stripped from the release build.
- Look: quiet dark glass, plain labels, no story terms in menus (design/art/style.md).

========================================
6. STORY AND TONE
========================================
Alien-industrial dread (cold hulls, humming ducts, dark outside the glass; a hint, never a monster) mixed lightly with collectivist bureaucracy as flavour only. The player wants a market of their own in a society that shares everything and counts all of it, and the three rivals stand in the way. No real-world figures, parties or slogans.

Story terms (the Commons, the Plan, the Bureau, the Common Ledger, fellow hand) appear in story texts only. Menus, buttons and tutorial lines stay plain. Texts are written in story/*.md; tools/build_story.py generates data/story_text.json and data/events.json from them. Do not edit those two files by hand.

The game opens with a preface, then three planets and a mission hint to set up the first route. The first cycles teach: read two planets' prices, set up a route, watch it pay, then choose between a second ship and a second route.

========================================
7. PLANNED
========================================
Not built; the owner decides if and when.
- Ship upgrades as the first use of route level.
- Route level and finer route control (commodity choice, minimum margin, priority).
- Debris fields, pirates and nomads, asteroid fields.
- Space buildings and trade posts.
- Galaxy view that opens after system 2, ship dots with trails, per-type planet textures.

========================================
8. OPEN QUESTIONS (owner)
========================================
- Pacing targets for the market goal need a human playtest.
- Whether the permit margin bonus does anything.
- Whether space storage stock can be sold by Sell orders.
- Which spending the "money never buys skill points" rule covers.
- Rival and ending names are working names, judged in play.
