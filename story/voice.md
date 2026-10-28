# Star Bazaar: voice and glossary

Draft 2 (tone rework, T74), 2026-10-27. Owner edits. Every text in story/ follows this file.

## Narrator
A quiet, practical observer: a small crew in a large, cold sky, inside a society that shares everything and counts all of it. Dry, a little wry, never loud. About one line in four carries irony; the irony never hides what the player must know.
Two inspirations, blended and kept light:
1. Deep-space dread: cold, industrial, indifferent. Hulls that creak like something asleep, ducts that hum, dark outside the glass, machines that feel half grown. Hint at strangeness, never show a monster.
2. Collective bureaucracy, as flavour only: the Commons, the Plan and its five-cycle plans, quotas, forms, committees, rations, the common good. Gentle wit, no lecture, no propaganda, no real-world figures, parties or slogans.
The joke is the player: a trader chasing a cash goal inside a society that preaches sharing. The cash goal buys a Release, the way off the ledger. Story texts (preface, events, endings, skills) carry the joke and the thread: the common good, enough, debt, distance, escape. Menus, buttons, labels, notices and tutorial lines stay plain and carry none of it.
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
- Preface: max 700. Loss ending: max 600. Endings by tier: Bare max 350, Partial max 700, Full max 1000. Full epilogue line (_EPI): max 140.
- Choice screen: title max 40, body max 280, button max 28, effect line max 90.

## Capitalisation and punctuation
- Buttons and menu entries: Sentence case, no full stop ("Learn", "Main menu", "Quit game"). "Send to..." keeps its three dots.
- Labels: Sentence case, no colon in the text (the UI adds it): Buy price, Sell price, Company storage, Ship upkeep, Expenses.
- Notices and tutorial lines: sentence case, end with a full stop.
- Planet names, ship names and the game name are capitalised. Branch names are capitalised: Logistics, Research, Expansion. Commodities are lower case: energy, food.
- Story terms the Commons, the Plan, the Bureau, the Common Ledger, the Release: capitalised as shown (the Plan, the Bureau, the Commons). "five-cycle plan" is lower case.
- Dash: use a comma or full stop, not a long dash.
- Placeholders: {planet}, {planet_a}, {planet_b}, {commodity}, {amount}, {skill}, {cash}, {goal}, {cycle}, {branches} (count of branches with a skill learned), {systems} (count of systems reached). The last two are end screen stats only. The game fills them.

## Glossary (exact terms)
- Branches: Logistics, Research, Expansion.
- Company storage: the company's own storage on a planet. Space Storage: the per-system storage, a skill (A1).
- Route: one-way link between two planets, made with "Send to..." on a storage row, run by one ship.
- Ship upkeep: the recurring cost of a ship, shown to the player.
- Expenses: label for what the company pays out.
- Income before costs, Income after costs, Trip cost: route and statistics labels (LBL_GROSS, LBL_NET, LBL_TRIP_COST). "Waiting for room": route status when the destination is full (ST_WAITING_ROOM).
- Buy price, Sell price: price labels in the planet panel. Buy and Sell on a row are standing orders, on or off.
- Expansion points (shown as "Skill points" in the top bar): spent on skills and permits.
- Permits: allow entry to a new system (on hold in this build).
- Cycles: the game's time unit.
- Ships: Skerrit (small), Voruun Hauler (large). Working names.
- Cash goal: the credit target that wins the game. Credits: the currency.
- System 1: Voltara (abundant energy, scarce food), Tillam and Ashgate (abundant food, scarce energy).
- Hollin Reach: system 1 (owner approved, T92).
- System 2: Dunmere Reach (owner approved, T92). Planets: Brannock (food-rich hub), Cindrel (energy-rich), Mossfell (food-rich outpost), Quillon (consumer market, wants both goods). Texts and ids: story/screens.md, section "Systems and system 2".
- Owner decisions (T92): the UI label "Skill points" stays on screen for expansion points. "Corporation" follows the capitalisation rule in the Story terms entry below. The end screen {branches} is a plain count.
- Rescue notice: when the company has no ships and too little cash. Never "game over". Story texts may call the payment "relief".

### Story terms (new in draft 2, flavour only, never shown as a mechanic)
- The Commons: the shared society of the system. Owns "everything", counts all of it.
- The Plan: the Commons' schedule, in five-cycle plans. Story only. It sets no quota in the game.
- The Bureau: the polite, slow office that keeps forms and the Common Ledger.
- Common Ledger: the Commons' record of who has what. Different from the player's cash.
- Release: the form that takes a person off the ledger and sells them an uncounted planet. This is what the cash goal buys. In UI text keep "cash goal"; "Release" appears only in story texts and on the choice screen (CHOICE_RELEASE).
- Fellow hand: how people in the Commons address each other. Replaces any "comrade" wording.
- Corporation: the form of the company that stays on the Common Ledger after the cash goal (choice screen and corporate endings). Lower case in the button ("Stay as a corporation"), a plain noun in story text. Story only, never a mechanic.
- Common good: stock phrase, used with a straight face and a raised eyebrow.
