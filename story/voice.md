# Star Bazaar: voice and glossary

Draft 3 (higher stakes, closer to the crew, simpler words), 2026-11-05. Owner edits. Every text in story/ follows this file. Glossary, limits and punctuation below are unchanged from draft 2.

## Narrator
A quiet voice that stays close to a small crew in a big, cold sky. It does not joke to be safe. It tells you what is at risk, and it lets the risk sit there. The crew is scared and tired and trying to stay decent. The Commons shares everything and counts all of it, and that is a pressure too: someone is always owed, always watching, always keeping a page.
Two inspirations, blended and kept light:
1. Deep-space dread: cold, empty, and close. A hull that creaks at night. A hum in the walls that stops for one breath. Dark outside the glass, and nobody is coming. Hint at something wrong, never show a monster.
2. The Commons as a soft weight, as flavour only: the Plan and its five-cycle plans, quotas, forms, committees, the common good. Polite people who never say no and never let go. No lecture, no propaganda, no real-world figures, parties or slogans.
What drives a story text is what the player could lose: the crew, the home, a debt owed to someone with a name, a place at the table, time, trust, sleep. Make the player feel the weight of the choice before they make it. Texts do not say if the choice was right. They say what it costs and who feels it.
Irony stays, but small: about one line in six, dry, and never a way out of the feeling. It must never hide what the player needs to know.
Menus, buttons, labels, notices and tutorial lines stay plain and carry none of this. Feeling lives in story texts only (preface, events, endings, skills).
The player is "you" or "the company". Never a gender, never a name.

## Simple words (always)
- Write like you speak to a tired friend. Use the shortest common word. "Use" not "utilise". "Start" not "commence". "Help" not "assist". "Need" not "require". "Show" not "demonstrate".
- Short sentences, one idea each. Most sentences have fewer than 12 words. Never more than 20.
- Plain verbs and plain nouns. Say the thing: "the lights went out", not "illumination failed".
- Feelings by what a body does, not by a label: "your hands are cold", "no one speaks", "you read the line twice". Not "you feel anxious".
- One odd or hard detail beats three pretty ones.
- No rare words, no long Latin words, no stacked clauses, no riddles. If a word would need a dictionary, change it.

## Do
- Say what happens, then (in story texts) what it means for the people in it.
- Plain verbs: buy, sell, learn, close, open, run.
- Raise the stakes in the text, not in the numbers. Name what is at risk in one concrete image: the empty bunk, the unpaid shift, the dark window, the form with your name on it.
- Make it personal and close. A voice on the radio, a hand on a lever, a name on a list. Prefer "the crew" and "your people" to "the company" when a story text can.
- Let doubt show. The choices are hard because each one gives something up. Say what is given up.
- In events, say the price effect in words ("costs more", "pays less") before any musing.
- Skills: plain line first (what it does, no label), flavour line second. The plain line names the real change and starts with a verb. The flavour line may carry the feeling.
- The Bureau is polite and slow. That is the scary part. It never shouts and it never forgets.
- Dread in small doses: one odd sensory detail per story text at most. Silence and waiting work better than noise.
- Keep story-only ideas story-only. The Plan, quotas and the Bureau never change a number in the game.

## Do not
- No numbers in story texts unless the game inserts them through a {placeholder}.
- No promises the mechanics do not keep (no "you will be rich", no "safe", no "the Bureau will take your cash"). High stakes in words must not become a threat the game never carries out.
- No melodrama: no death, no gore, no shouting, no cruelty for its own sake. The weight is quiet.
- No telling the player what to feel or what the choice says about them. Show the cost and stop.
- No exclamation marks, no emoji, no slang, no jokes at the cost of clarity.
- No fancy or rare words (see Simple words). No sentence over 20 words.
- No real-world names, titles or slogans from history or politics (no party names, no leaders, no copied chants). Invent every term.
- No names, phrases or characters from existing films, games or books.
- No synonyms for glossary terms (not "money" for credits, not "fee" for upkeep, not "warehouse" for storage).
- No flavour words in buttons, labels, notices or tutorial lines.
- Chain and event choices stay neutral: both options carry real cost and neither is the "good" one (see the chain rules below).

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
- Story terms the Commons, the Plan, the Bureau, the Common Ledger: capitalised as shown (the Plan, the Bureau, the Commons). "five-cycle plan" is lower case.
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
- Release: retired term (old cash goal). Not used in any text.
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

### Market chains (added 2026-11-03, chain text goal)
- Chain limits: step title 40, body 280, button 28, effect line 200 (Get, Cost, Rivals), result title 32, result text 280, rival line 90, epilogue line 140, rival log line 60. Pool event: title 32, text 280, rivals line 90.
- Effect line shape, always: "Get: ... Cost: ... Rivals: ..." in that order, three sentences, same shape for both options. A boost to a rival is a Cost. No "but", "however" or "at least".
- Option buttons are two verb phrases of nearly equal length (within 5 characters). No verdict words in any chain text: good, bad, right, wrong, fair, unfair, safe, risky, bold, kind, cruel, open, closed, quiet, polite, late, long, short, small, big, plain, clean. A text never says what an option shows about the player.
- Rivals: always by name or by a placeholder ({bot1} Harrow Combine, {bot2} Velvet Concord, {bot3} Ostrel Syndicate, {bot} the marked bot of the option). Never "bot" or "AI" in player text.
- Rival lines: "<Bot>, <Market>: strength down a little." or "growth up clearly." For a tier cut: "<Bot>, <Market>: {cut_std}." The Competitors log uses "{bot}: {market} strength down" and the like (LBL_COMP_MOVE_*).
- Size words: a little (small), clearly (medium), sharply (large, rivals only). Durations: for a few cycles (2 to 3), for a while (4 to 8), for the rest of the run. Credits and tech units come only from {cash_in}, {cash_out} and {n}.
- New placeholders: {bot}, {bot1}, {bot2}, {bot3}, {cash_in}, {cash_out}, {cut}, {cut_std}, {get}, {cost}, {rivals}, {market}, {workshop}, {share}, {bots}. Documented in story/events.md, section "Chain placeholders".
- Terms: Rivals (the three other companies); Competitors (the menu that lists them and their recent moves); the Atelier, the Smelter, the Munitions Line, the Culture Lab (workshops; capitalised as names, lower case in running text). Not "Standings" in player text; the old working name is retired.

### Pathfinder, posts and platforms (added 2026-11-05, T181, pending T179)
- Pathfinder: the scout the player flies. Not part of the fleet, no cargo, no upkeep. Name stays Latin in Russian.
- Unknown world, Unknown dark world: the label of a closed planet. Its real name appears when the Pathfinder arrives.
- Fly here: the button that sends the Pathfinder. Flight time: how long it takes, in cycles.
- Trading post: a living planet the company has established. Button "Establish trading post". Lets the company buy, sell, route and store there.
- Mining platform: the same for a dead world. Button "Establish mining platform" (28 characters, the one exception to the 24 limit for buttons). Lets the company mine there and route what it mines.
- "Build time" is in cycles; the first post is free (default, owner to confirm). Never call a post a base or a colony, a platform a mine or a rig.
- Post, platform and flight events: neutral choices, effect line first, sizes only in words (a small sum, a little, clearly), no digits.

### Empire growth v2, Phase 1 (added 2026-11-06, T267)
- Prosperity tiers: a world's growth steps, shown on its card: Barren (dead world), Outpost, Village, Town, City, Metropolis. Names are placeholders; the count is the economy-designer's. Plain labels, no flavour.
- Restless: the card line when a world's growth progress drops because a need is short. Gentle and recoverable.
- Bazaar capital: the one world where the Star Bazaar is founded; final, one per run. Stages are Foundations, Halls, Towers, Great Hall (placeholders).
- Next Up: the top strip with three slots (Closest growth, Bazaar, Best move). Plain, no flavour, never names a hidden good.
- Retired in player text: share as a goal word (market share).

### Flagship and gigs (added 2026-11-06, T275)
- Flagship: the player's own ship, the Pathfinder grown a small hold. Name: Tessarine (working name, owner decides). It is not part of the fleet and has no upkeep. Pathfinder is retired in player text once the FLAGSHIP ids are wired.
- Hold: the Flagship's cargo space. Dock sheet: the window opened with "Dock and trade"; it pauses time. Buy and Sell there are one-off hand trades. Unload to storage and Load from storage move goods between the hold and Company storage.
- Boost: a short burst of speed that burns energy from the hold.
- Gig board: the list of open offers. Gig kinds: Signal (story) and Rush order (a world wants a good before a deadline). ETA: flight time in cycles. Deadline: cycles left. Premium: credits paid on delivery.
- Rush text tokens: {planet} and {commodity} only; the game fills {commodity} with a visible good.
