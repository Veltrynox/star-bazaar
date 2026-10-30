Star Bazaar: Skill Tree, Space Storage and Game Menu (design draft 1)
Date: 27 October 2026
Split out of gdd.md. Read only when your brief lists it. Owner: the project owner.

Status: DRAFT (economy numbers set in balance.json v5, 2026-10-27; story names in story/skills.md). Owner answers 2026-10-27: branches are Logistics, Research, Expansion; Space Storage costs expansion points; permits cost expansion points; the skill screen does not pause the game. Skill names and the node list are still proposals for the owner to edit (task T72). Nothing here is built yet. Numbers are not in this file: they are [GCM:<key>] tokens that point to data/balance.json (or data/skills.json once it exists). Prices, point values and costs are the Economy Designer's job.

SECTION INDEX
  1. PRINCIPLES
  2. EXPANSION POINTS
  3. THE THREE BRANCHES (Logistics, Research, Expansion)
  4. SPACE STORAGE (the default skill)
  5. PERMITS SKILL
  6. SKILL TREE SCREEN
  7. GAME MENU
  8. DATA AND CODE HOOKS
  9. ENDINGS (to design)
  10. OPEN QUESTIONS

========================================
1. PRINCIPLES
========================================
Money is only for reaching the final goal (win_cash). Growth in ability comes from expansion, so skills are bought with expansion points, never with credits.
The player earns points by doing things that grow the company (see section 2), so the tree rewards reach, not wealth.
Every skill opens a new way to play. It never only adds a hidden number. If a skill changes a number, the screen says which number.
There are three branches. The player can learn skills in any branch from the start, in any order the prerequisites allow. Respec is not planned.
The tree is not required to win, but ignoring it makes the goal harder. What the player learns also shapes which ending they get (section 9). Exact balance comes after the owner plays it.

========================================
2. EXPANSION POINTS
========================================
Points are earned once per event:
  - First visit to a planet: [GCM:skill_points_planet] point(s).
  - First route made between a new pair of planets: [GCM:skill_points_route] point(s).
  - First route or storage in a new system: [GCM:skill_points_system] point(s).
The same planet, pair or system never pays twice. Closing and re-opening a route does not pay again.
Name: these are "expansion points" in data keys and in this file; the one on-screen name is "Skill points" (top bar and skill screen header), per the glossary in story/voice.md.
The player starts with 0 points; the home planet (Voltara) gives the first on cycle 1 (sim assumption, not yet confirmed in code). Values: [GCM:skill_points_planet], [GCM:skill_points_route], [GCM:skill_points_system]. A route counts once per planet pair, direction ignored. System 1 has no system bonus.
System 1 total: 3 planets plus 2 profitable pairs x 2 = 7 points (9 if the loss-making Tillam-Ashgate pair is counted). The whole tree costs 20 points (A: 1, 1, 3, 2; B: 1, 2, 2, 2; C: 1, 1, 2, 2). So system 1 buys one short branch or about 4 nodes, never the tree; the full tree needs systems 2 and 3, which are on hold.
The top bar shows "Skill points: N" next to the Skills button. A small mark appears on the button when the player has points and a skill is available.
A notice appears when points are earned ("+1 skill point: first visit to Tillam").

========================================
3. THE THREE BRANCHES
========================================
Skills below are proposals. "Cost" is in expansion points, set by the Economy Designer: [GCM:skill_cost_<id>] (balance.json has all twelve, A1, A2, A4, A5, B1 to B4, C1 to C4; A3 was cut 2026-10-28). Effect keys: A4 skill_A4_route_units; A5 skill_A5_upkeep; B2 skill_B2_order_units; B3 skill_B3_margin.

BRANCH A: LOGISTICS (how goods move and are kept)
  A1 Space Storage - the first node of the branch; it costs expansion points like any skill (section 4).
  A2 Bigger Holds - raises the capacity of company storage on planets.
  (A3 Second Hull and the large ship were cut by the owner on 2026-10-28; A4 now follows A2.)
  A4 Fast Loading - raises how much a route moves per cycle.
  A5 Drydock Deals - lowers ship upkeep.

BRANCH B: RESEARCH (understanding the market and the sky; the old Trade ideas live here)
  B1 Market Ledger - shows the price history of each planet in its panel.
  B2 Standing Orders - local Buy and Sell orders handle more per cycle.
  B3 Price Whisper - shows the next cycle's expected price move before it happens.
  B4 Event Forecast - shows the next event one cycle early.

BRANCH C: EXPANSION (reach)
  C1 Permit Charter - the player may buy permits for new systems (section 5).
  C2 Survey Beacon - reveals the planets of a permitted system before the first visit.
  C3 Long Haul - routes between systems become possible (needs the Space Storage link in section 4).
  C4 Colonial Rights - lowers the credit price of later permits.

Prerequisites: each branch is a short chain. A node needs the node above it in the same branch. C3 also needs A1. No other cross-branch links in this draft.

========================================
4. SPACE STORAGE (the first skill)
========================================
Space Storage is the first node of the Logistics branch and the natural first purchase. It costs expansion points ([GCM:skill_cost_A1]); it is not free. Early points come from the first planet visits and the first route, so it is reachable in the first cycles. Until it is learned the player has planet storage only.
Gate (decision by the owner, 2026-10-28): A1 stays Locked until the player has visited all planets of system 1 (Voltara, Tillam, Ashgate) and has made at least one route; it then costs [GCM:skill_cost_A1] as usual. Saves with A1 already learned keep it.
Rules:
  - One space storage per system, much bigger than a planet storage. The capacity is [GCM:space_storage_capacity].
  - It is company property and is set up on the first use, like planet storage.
  - Planet storage is the small, abstract buffer. Planet storage transfers into the space storage slowly (rate [GCM:planet_to_space_rate]). The space storage then holds the stock.
  - Routes can run planet to space storage and space storage to space storage (between systems, once C3 is learned).
  - When a route breaks for any reason (no ship, blocked, a closed planet), the space storage keeps feeding the connection for a while, so a short problem does not break the trade.
  - Clicking a space storage on the map shows its stock per commodity with the 5-line rating bar, and its connections, with a Remove button, the same as a planet.
  - Ships still only carry goods between planets and storages.
Build note: this replaces the earlier plan that the space storage unlocks after some time (task T64). It is unlocked by learning the skill; T64 remains the task that builds it.

========================================
5. PERMITS SKILL
========================================
Permit Charter (C1) is the skill that lets the player buy permits for other systems. Without it, the permit button does not appear.
Learning the skill does not open a system. It only allows the purchase. Each permit costs expansion points ([GCM:permit_points_2], [GCM:permit_points_3]) as well as the credits already in gdd.md ([GCM:permit_2_cost], [GCM:permit_3_cost]), and opens one system. Owner decision 2026-10-27: permits cost expansion points.
Systems 2 and 3 are still on hold in this build (see gdd.md and state.md). Until the owner lifts the hold, the skill can be learned but there is nothing to buy; the screen says "no systems available yet".

========================================
6. SKILL TREE SCREEN
========================================
Opening: a "Skills" button in the top bar (hotkey K) opens the screen at any time, running or paused. Esc or the same button closes it. The game does not pause while it is open (owner decision).
Layout: three columns, one per branch, each a vertical chain from the first skill at the top. A header shows "Skill points: N".
Node states: learned (gold), available (bright outline, can be bought now), locked (dim, shows what it needs).
Clicking a node shows its name, what it does in plain words, its cost and its prerequisites. A Learn button spends the points. Nothing is hidden: if a skill changes a number, the text says the number.
The screen shows no credits. Skills never cost credits.

========================================
7. GAME MENU
========================================
A menu button in the top bar (hotkey Esc) opens a short list. It is built as a list of entries so the owner can add more later without redesign.
Entries in this draft:
  - Resume (close the menu).
  - Skills (opens the skill tree screen; same screen as the top-bar button).
  - Main menu (saves, then returns to the main menu; asks for confirmation).
  - Quit game (saves, then exits; asks for confirmation).
Reserved slots for later, not built yet, in this order: Settings (sound, display; first, because every build needs it), Help (controls and tutorial replay), Statistics (cash history, routes), Save and load slots.
The menu pauses the game while open. The skill tree opened from its own top-bar button does not.

========================================
8. DATA AND CODE HOOKS
========================================
  - New file data/skills.json: id, branch, name, text, cost token, prerequisites, effect key. The code reads it; nothing is hard-coded.
  - The game asks has_skill("<id>") wherever a skill changes a rule (for example the permit button, ship type choice, storage capacity). A skill's effect keys point to balance.json values, so the Economy Designer can retune them.
  - Save game stores the learned skill ids and the points. Old saves start with Space Storage learned and zero points.
  - The skill screen and the game menu are separate scenes, so the menu list can grow without touching the tree.

========================================
9. ENDINGS (drafted in story/endings.md; wiring T77 to T80)
========================================
Update 2026-10-27: the win now ends with a choice, Release or Stay as a corporation, and each side has three tiers (Bare, Partial, Full) picked from the skills learned; see "The win choice and endings" in gdd.md and story/endings.md for the tables and ids. Inputs from the tree: learned skill ids, learned count per branch, dominant branch, branches fully learned, systems reached. Full is unreachable until systems 2 and 3 are unblocked. The Expansion branch has no income effect while they are on hold, so it only shapes the ending tier. The earlier text below is kept as history.
The skills the player learns decide which ending they get. The cash goal stays the win condition (gdd.md); the ending is the story told when it is reached, so one run can end in different ways depending on the branch the company leaned on (for example Logistics, Research or Expansion, or a balance of all three). The loss ending is separate.
How many endings, and how the skills pick one (a majority branch, a key skill, or a set of choices) is the owner's call. The story agent proposes wording and structure once the owner answers.

========================================
10. OPEN QUESTIONS
========================================
Answered 2026-10-27: branches are Logistics, Research, Expansion; Space Storage costs points; permits cost points; the screen does not pause the game; the first menu entry after the basics is Settings.
Still open (task T72 for the owner):
  1. What skills belong in each of the three branches, and which skills push toward which ending? (Drafted in story/skills.md and story/endings.md; owner to confirm.)
  2. How many endings, and how does the tree choose one? (Drafted: 2 sides x 3 tiers, tables in story/endings.md; owner to confirm.)
  3. Starting points: answered in the economy handoff, start at 0, first points from the first visit and route (home planet gives 1).
  4. Expansion has no income effect while systems 2 and 3 are on hold: acceptable as an ending-only branch?
