# Star Bazaar: voice and glossary

Draft 2 (tone rework, T74), 2026-10-27. Owner edits. Every text in story/ follows this file.

## Narrator
A quiet, practical observer: a small crew in a large, cold sky, inside a society that shares everything and counts all of it. Dry, a little wry, never loud. About one line in four carries irony; the irony never hides what the player must know.
Two inspirations, blended and kept light:
1. Deep-space dread: cold, industrial, indifferent. Hulls that creak like something asleep, ducts that hum, dark outside the glass, machines that feel half grown. Hint at strangeness, never show a monster.
2. Collective bureaucracy, as flavour only: the Commons, the Plan and its five-cycle plans, quotas, forms, committees, rations, the common good. Gentle wit, no lecture, no propaganda, no real-world figures, parties or slogans.
The joke is the player: a trader chasing market share inside a society that preaches sharing. Story texts (preface, events, endings, skills) carry the joke and the thread: the common good, enough, debt, distance, escape. Menus, buttons, labels, notices and tutorial lines stay plain and carry none of it.
The player is "you" or "the company". Never a gender, never a name.

## Do
- Say what happens, then (in story texts) what it means.
- Plain verbs: buy, sell, learn, close, open, run.
- Short sentences. One idea per sentence.
- In events, say the price effect in words ("costs more", "pays less") before any musing.
- Skills: flavour line first, plain-meaning line second. The plain line names the real change.
- Bureaucratic comedy: forms, stamps, committees, quotas, "the Plan allows". Let the Bureau be polite and slow.
- Dread in small doses: one odd sensory detail per story text at most.
- Keep story-only ideas story-only. The Plan, quotas and the Bureau never change a number in the game.

## Do not
- No numbers in story texts unless the game inserts them through a {placeholder}.
- No promises the mechanics do not keep (no "you will be rich", no "safe", no "the Bureau will take your cash").
- No exclamation marks, no emoji, no slang, no jokes at the cost of clarity.
- No real-world names, titles or slogans from history or politics (no party names, no leaders, no copied chants). Invent every term.
- No names, phrases or characters from existing films, games or books.
- No synonyms for glossary terms (not "money" for credits, not "fee" for upkeep, not "warehouse" for storage).
- No flavour words in buttons, labels, notices or tutorial lines.

## Length limits
- Button, menu entry: max 24 characters.
- Notice, tutorial line, mission hint: max 110 characters (one line, two at most).
- Event text: max 280. Event title: max 32. Skill name: max 24. Skill flavour: max 90. Skill plain line: max 110.
- Preface: max 700. Loss ending: max 600. Soft ending: max 700. Market ending: max 1000. Ending title (_TITLE): max 40. Epilogue line (_EPI): max 140.

## Capitalisation and punctuation
- Buttons and menu entries: Sentence case, no full stop ("Learn", "Main menu", "Quit game"). "Send to..." keeps its three dots.
- Labels: Sentence case, no colon in the text (the UI adds it): Buy price, Sell price, Company storage, Ship upkeep, Expenses.
- Notices and tutorial lines: sentence case, end with a full stop.
- Planet names, ship names and the game name are capitalised. Market and foundation names are capitalised: Military, Luxury, Minerals, Biotech, Foundations. Commodities are lower case: energy, food.
- Story terms the Commons, the Plan, the Bureau, the Common Ledger, the Release: capitalised as shown (the Plan, the Bureau, the Commons). "five-cycle plan" is lower case.
- Dash: use a comma or full stop, not a long dash.
- Placeholders: {planet}, {planet_a}, {planet_b}, {commodity}, {amount}, {skill}, {cash}, {arrow}, {cycles}, {n}, {m}, {total}, {cycle}, {cap} (credit cap of the Mixed load bonus, LBL_MIXED_LOAD, with {n} as the applied percent), {in} (units arriving next cycle), {out} (units leaving next cycle), {after} (stock after next cycle, LBL_NEXT_CYCLE). The game fills them.

## Glossary (exact terms)
- Skill trees: Foundations (Space Storage, Permit Charter, Prospecting) and four markets: Military, Luxury, Minerals, Biotech. The old branches Logistics, Research, Expansion are gone.
- Company storage: the company's own storage on a planet. Space Storage: the per-system storage, a skill.
- Mixed load: the bonus for selling two or more different goods at one planet in the same cycle. Shown on the Sell row only when it applies, as "Mixed load +{n}% (max {cap} credits)". Never call it a bundle in player text. Added 2026-11-02.
- Route: one-way link between two planets, made with "Send to..." on a storage row, run by one ship.
- Stop at: a Send to... with one stop on the way. The ship sells up to the stop's Sell order amount there, then carries the rest on. Picker line: "Stop at A: sell up to N here, carry the rest to B." Never call it a waypoint or a bundle. Added 2026-11-02.
- Ship upkeep: the recurring cost of a ship, shown to the player.
- Expenses: label for what the company pays out.
- Income before costs, Income after costs, Trip cost: route and statistics labels (LBL_GROSS, LBL_NET, LBL_TRIP_COST). "Waiting for room": route status when the destination is full (ST_WAITING_ROOM).
- Buy price, Sell price: price labels in the planet panel. Buy and Sell on a row are standing orders, on or off.
- Expansion points (shown as "Skill points" in the top bar): spent on skills and permits.
- Permits: allow entry to a new system. Permit Charter unlocks them; system 2 is open in the Alpha.
- Cycles: the game's time unit.
- Ships: Skerrit (the only ship type). Working name.
- Credits: the currency. The goal is market share (LBL_GOAL_MARKETS); there is no cash goal.
- New goods (T154, working names, owner decides): Starsilk (id silk, luxury), Logic Cores (id chips, tech), Rock Ore (id ore, mined). UI shows the names; running text uses lower case: silk, logic cores, ore. Asteroid cluster: a pack of rock on the map that gives ore free until it is empty. Prospecting (B1): the skill that lets routes start at a cluster. Added 2026-11-02.
- System 1: Voltara (abundant energy, scarce food), Tillam and Ashgate (abundant food, scarce energy).
- Hollin Reach: system 1 (owner approved, T92).
- System 2: Dunmere Reach (owner approved, T92). Planets: Brannock (food-rich hub), Cindrel (energy-rich), Mossfell (food-rich outpost), Quillon (consumer market, wants both goods). Texts and ids: story/screens.md, section "Systems and system 2".
- Owner decisions (T92): the UI label "Skill points" stays on screen for expansion points.
- Salvage: the one-time payout when goods cannot be kept or sold on the company's lanes (storage full or no buyer). Shown with the amount now and what a Sell order would pay. Plain word, no flavour. Added 2026-11-02.
- Rescue notice: when the company has no ships and too little cash. Never "game over". Story texts may call the payment "relief".

- Dead worlds (working names, owner decides): Cinderrest (system 1) and Greywake (system 2), rock worlds with a mining base and no food or energy market. Goods: Dross Salt (id dross, mined on Cinderrest) and Nullglass (id nullglass, mined on Greywake). UI shows the names; running text uses lower case: dross, nullglass. Danger: the meter that rises while a dead world is mined. Added 2026-11-02.

### Story terms (new in draft 2, flavour only, never shown as a mechanic)
- The Commons: the shared society of the system. Owns "everything", counts all of it.
- The Plan: the Commons' schedule, in five-cycle plans. Story only. It sets no quota in the game.
- The Bureau: the polite, slow office that keeps forms and the Common Ledger.
- Common Ledger: the Commons' record of who has what. Different from the player's cash.
- Release: the form that takes a person off the ledger and sells them an uncounted planet. Story texts and the preface only; no mechanic and no UI label.
- Fellow hand: how people in the Commons address each other. Replaces any "comrade" wording.
- Common good: stock phrase, used with a straight face and a raised eyebrow.

- Dead worlds open late (2026-11-03): they unlock at cycle 15 (a balance value, never written in running text; the game fills {n}). Before that the planet panel says it is closed until then. Mining Cinderrest needs Cold Survey, mining Greywake needs Deep Cut, both in Minerals. Fabrication Licence unlocks the fabric.
- Fabric: the machine at the trading post that turns dross and nullglass into Lattice Plate (id plate, working name; running text: plate). Null Core: an item built once from plate and nullglass, fitted to one ship. Plate and Null Core are working names, owner decides. Fitted ship: the ship that carries the Null Core. Added 2026-11-03.

### Four markets (added 2026-11-03, from design/proposals/2026-11-03-four-markets-story.md)
- Markets: Military, Luxury, Minerals, Biotech, always capitalised. Foundations: the three small unlocks (Space Storage, Permit Charter, Prospecting).
- Skill: costs skill points. Tech: costs no points, finishes by crafting at the market's workshop. Capstone: the last skill of a market.
- Rivals: the three other companies in a market. Never "bots" or "AI" in player text.
- Size words in skill lines: a little (small), clearly (medium), sharply (large, rivals only). No raw numbers; the game fills {n}, {m}, {goal} (units to craft), {name} (node name).
- Skill and tech node limits: name 24, flavour 90, plain line 110, craft-progress line 60 (_CRAFT). Screen labels 24 to 60, notices 110.
