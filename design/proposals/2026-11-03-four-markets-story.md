# Four Markets: story texts and style guide

> Part of the Four Markets pack. Where the docs disagree, `2026-11-03-four-markets-summary.md` (reconciliation table R1 to R13) decides.

Date: 2026-11-03. Author: story-designer. Builds on design/proposals/2026-11-03-four-markets.md (ids fixed there). Status: PROPOSAL, nothing is wired and no file outside this one and the handoff was touched. Text blocks use the format "ID | max chars | where" with the text on the next line, so a script can check them. Texts contain no digits; every number comes from a placeholder the game fills.

## 0. Changes to story/voice.md (proposed, not applied)

1. Goal story. The cash goal and the Release no longer end the game. Proposed story term: supplier of record (the Bureau's entry for the company that holds more than half of a market). Story only, never shown as a mechanic. "Release", "Corporation", "cash goal" and the Release/Corporation choice screen retire from player texts. The preface, LBL_GOAL, MB and tutorial lines still say the old goal and need a rewrite in a later task (not done here).
2. New length limits (the old ones stay for everything else):
   - Market ending (END_<MKT>_GOOD/_BAD): max 1000, as the old Full tier. Epilogue line: max 140, up to 4 shown. Loss ending: max 600. Soft ending END_OUTCOMPETED: max 700. Bare/Partial/Full tiers retire.
   - Chain step: title 40, body 280, button 28, effect line 90. Result popup: title 32, text 280. Standings line (one plain line under each result): 90.
   - Skill and tech node: name 24, flavour 90, plain line 110.
   - Pool event: unchanged (title 32, text 280).
3. New placeholders: {bot} (name of the bot the text is about), {market} (display name), {workshop} (workshop name), {share} (a percent, number only), {bots} (the three bot shares, built by the game), {player_effect} (one plain phrase from data: the player-side result of a choice, max 20 characters, for example "Price held up" or "Cash now"; economy-designer writes it), {goal} (units to craft for a tech), {m}.
4. New glossary (add to voice.md):
   - Markets: Military, Luxury, Minerals, Biotech. Running text: lower case only when used as a plain noun ("the military market" is avoided; write "Military" capitalised as a market name, always).
   - Share: the player's part of a market, shown as a percent. Standings: the menu with one graph per market (hotkey L).
   - Bots: Harrow Combine, Velvet Concord, Ostrel Syndicate (section 1.2). In the UI and text they are "rivals" or by name; never "AI".
   - Open and Hard are internal names. The player never sees them. No text calls a choice good, bad, right or wrong.
   - Size words in text: S = "a little", M = "clearly", L = "sharply". A tier cut = "drops a tier". A strength change = "Military strength falls"; a growth change = "grows more slowly". No numbers.
   - Goods and workshops: section 1.3 and 1.4.
5. Retire from the glossary for the new goal: Corporation, Release (as a goal), cash goal. Keep the Commons, the Plan, the Bureau and the Common Ledger.

## 1. Names

### 1.1 The four markets

Display names stay as in the core doc. Voice line = a story line for the Standings tab tooltip or the first mention (max 90, optional).

| Id | Name | Voice line |
|---|---|---|
| mil | Military | Fleets want steady supply and ask no questions. The forms are very thorough. |
| lux | Luxury | Few units, large moods. Everything here is worth what the room believes. |
| min | Minerals | Dust, heat and patience. The dead worlds keep their own accounts. |
| bio | Biotech | Slow and damp. Things grow here while the Bureau is still filing. |

### 1.2 The bots

Standings line = the plain line in the Standings menu (max 110). Voice line = story only: event results, ending text, never a menu (max 110). The Standings menu stays plain and carries no flavour.

STD_BOT1_NAME | 24 | Standings legend and tooltips, bot_1
Harrow Combine
STD_BOT1_LINE | 110 | Standings, under the bot name
Heavy volume, slow growth. Strongest in Military and Minerals.
STD_BOT1_VOICE | 110 | Story only (events, endings)
Old foundries and older contracts. It moves like a hull: slowly, and without stopping.
STD_BOT2_NAME | 24 | Standings legend and tooltips, bot_2
Velvet Concord
STD_BOT2_LINE | 110 | Standings, under the bot name
Volume swings with events. Strongest in Luxury and Biotech.
STD_BOT2_VOICE | 110 | Story only
Soft voices, gilt cuffs and a denial ready for every question.
STD_BOT3_NAME | 24 | Standings legend and tooltips, bot_3
Ostrel Syndicate
STD_BOT3_LINE | 110 | Standings, under the bot name
Small and steady in all four markets. It can sweep them all.
STD_BOT3_VOICE | 110 | Story only
Many small offices, one polite clerk at each. It is always already in the room.

Note: the core doc working name "Dunmere Syndicate" clashes with the system 2 name Dunmere Reach. Proposed final name: Ostrel Syndicate (see Open questions).

Standings menu strings (all plain):

STD_TITLE | 24 | Menu title and game menu entry
Standings
STD_DESC | 110 | Game menu, hint on the entry
Shows your share and the three rivals in each market.
STD_TAB_MIL | 24 | Tab
Military
STD_TAB_LUX | 24 | Tab
Luxury
STD_TAB_MIN | 24 | Tab
Minerals
STD_TAB_BIO | 24 | Tab
Biotech
STD_LINE_50 | 40 | Graph, label on the 50% line
Share needed to win
STD_YOU | 24 | Graph legend, player line
Your company
STD_NOW | 60 | Graph header, current share
{market}: your share is {share}%.
STD_TIER_MARK | 90 | Tooltip on a tier mark on a bot line
{bot} moved to a new tier in {market}.
CHIP_BEST | 40 | Top bar chip, best market and share
{market} {share}%

### 1.3 Goods (working names settled)

Display name in the UI is capitalised; running text is lower case. Only one change: the alloy.

| Id | Display name | Running text | Note |
|---|---|---|---|
| rivets | Rivet Guns | rivet guns | kept |
| cells | Pulse Cells | pulse cells | kept |
| armour | Hull Armour | hull armour | kept |
| musk | Sunmusk | sunmusk | kept |
| cask | Vintage Cask | vintage cask | kept |
| gems | Cut Glimmers | cut glimmers | kept |
| ingot | Ingot | ingot | kept |
| alloy | Seam Alloy | seam alloy | renamed: "Lattice Alloy" is too close to Lattice Plate (plate) and the tech Lattice Works |
| spores | Spore Cultures | spore cultures | kept |
| gel | Bio-Gel | bio-gel | kept |
| seed | Gene Seed | gene seed | kept |

### 1.4 Workshops

UI name (capitalised, with "the" in running text, lower case there): Fabric (existing, plate), Smelter (min), Munitions Line (mil), Atelier (lux), Culture Lab (bio). Running text: the fabric, the smelter, the munitions line, the atelier, the culture lab. All kept from the core doc.
One-line UI hint for each workshop panel (max 110):

WS_SMELTER_HINT | 110 | Workshop panel
The Smelter turns ore into ingot, and plate and ingot into seam alloy.
WS_MUNITIONS_HINT | 110 | Workshop panel
The Munitions Line turns energy and logic cores into pulse cells, and cells into hull armour.
WS_ATELIER_HINT | 110 | Workshop panel
The Atelier turns food into vintage casks, and ore and silk into cut glimmers.
WS_CULTURE_HINT | 110 | Workshop panel
The Culture Lab turns food and spore cultures into bio-gel, and gel into gene seed.

### 1.5 The four trees

Format: ID | name (24) | flavour (90) | plain line (110). The plain line names the real change; {n}, {m} and {goal} are filled from data. Tech nodes say "Tech" first. Costs are shown by the game.

Foundations
FND_STORAGE | Space Storage | One great hold in the sky, held in common, quietly kept by you. | Unlocks Space Storage, one large company storage per system. Planet storage feeds it slowly.
FND_PERMIT | Permit Charter | No ship leaves the home sky without a charter. This is the charter. | Lets you buy permits for new systems and run routes between systems.
FND_PROSPECT | Prospecting | The Commons owns every rock. It has not counted the ones nobody has looked at. | Lets routes start at asteroid clusters and shows how much ore each cluster holds.

Military
MIL_1 | Drydock Deals | Every machine is a slow bill with wings. Cut the bill. | Ship upkeep is {n}% lower. Unlocks the Munitions Line and pulse cells.
MIL_2 | Cell Casting | A cell is a small sun with a rule printed on it. | Tech: craft {goal} units at the Munitions Line. Military sales count {n}% more volume.
MIL_3 | Quick Loading | Dock time is shared time. Spend less of it. | Routes carrying Military goods move {n} more units a cycle.
MIL_4 | Armour Plating | Plate a hull and the quarrel goes elsewhere. | Tech: craft {goal} units. Unlocks hull armour. Military goods sell for {n}% more.
MIL_5 | Embargo Desk | A polite desk with a very long reach. | Every {m} cycles, pick one bot: its Military strength falls sharply for {n} cycles.
MIL_6 | Contract Doctrine | Write the terms first. The sky respects a clause. | Tech: craft {goal} units. Military price events against you hit {n}% weaker.
MIL_7 | Standing Fleet | A fleet that is always there needs no speech. | Capstone. All bots' Military growth is cut in half for the rest of the run.

Luxury
LUX_1 | Price Whisper | Prices move before people do. Listen to the walls. | Shows next cycle's prices. Luxury goods sell for {n}% more. Unlocks the Atelier and cut glimmers.
LUX_2 | Fine Finishing | A good edge earns a second look. A third earns a price. | Tech: craft {goal} units at the Atelier. Luxury price-up events pay {n}% more.
LUX_3 | Event Forecast | The sky has moods. The Plan pretends not to notice them. | Warns one cycle before an event. Works in all four markets.
LUX_4 | Cask Cellar | Some things improve in the dark. So do some excuses. | Tech: craft {goal} units. Unlocks vintage casks. Stored Luxury stock keeps its value when a planet closes.
LUX_5 | Patron's List | The right name on the right list is worth a ship. | Sales at a planet with a price-up event count {n}% more volume toward your Luxury share.
LUX_6 | Hallmark | A stamp from your hand makes a stone worth more. | Tech: craft {goal} units. Luxury goods sell for {n}% more.
LUX_7 | Guild Seal | Buy the client, not the goods. The guild keeps a form for it. | Capstone. Once per run, pick a bot: its Luxury strength falls sharply for {n} cycles.

Minerals
MIN_1 | Fabrication Licence | A licence to make one good plate from two bad rocks. Stamped in triplicate. | Unlocks the Fabric and the Smelter, and ingot. Needs Prospecting.
MIN_2 | Smelting | Heat is honest. It only asks what you put in. | Tech: craft {goal} units at the Smelter. Minerals volume up {n}%. Ore loads take no order space.
MIN_3 | Cold Survey | A rock no one lives on still has a ledger line. Someone must read it. | Lets routes start at Cinderrest and mine dross. Cluster yield up {n}%. Dead worlds open later.
MIN_4 | Alloying | Two metals agree if you hold them hot enough. | Tech: craft {goal} units. Unlocks seam alloy. Workshops in Minerals make one more batch a cycle.
MIN_5 | Deep Cut | Under the dust lies glass that hums. The Bureau has no form for it yet. | Lets routes start at Greywake and mine nullglass.
MIN_6 | Lattice Works | A good lattice forgives the one who made it. | Tech: craft {goal} units. Each Minerals batch yields one more unit.
MIN_7 | Cornered Seam | The last seam in reach belongs to someone. Now it is you. | Capstone. All bots' Minerals strength falls for the rest of the run.

Biotech
BIO_1 | Standing Orders | A good form is one you only file once. The Bureau will not mind. | Buy and Sell orders move {n} more units a cycle. Unlocks the Culture Lab and bio-gel.
BIO_2 | Culture Banks | Something grows in the dark and asks for nothing. For now. | Tech: craft {goal} units at the Culture Lab. Biotech stock in planet storage grows each cycle, to a cap.
BIO_3 | Seed Bank | A shelf is a promise that something will be there. | Planet storage holds {n}% more.
BIO_4 | Gene Splicing | A small cut, a small stitch. The vat hums approval. | Tech: craft {goal} units. Unlocks gene seed.
BIO_5 | Clinic Contracts | A clinic pays slowly, which the Bureau calls trust. | Biotech share counts the last {n} cycles instead of {m}. Your share moves more steadily.
BIO_6 | Hardy Strains | A strain that survives the form survives most things. | Tech: craft {goal} units. Biotech events cost you less. A closed planet reopens one cycle sooner.
BIO_7 | Patent Wall | A wall made of paper outlasts one made of stone. | Capstone. All bots' Biotech strength falls for the rest of the run.

Tech notice (when a tech completes, max 110):
NOT_TECH_DONE | 110 | Notice
Tech finished: {skill}.

## 2. Endings

Selection and conditions: as the core doc, section 6. Every text below follows voice.md and uses placeholders only for names and numbers. The ending screen order: heading, ending name, text, epilogue lines (up to four, in the order below), sign-off, stats block, run over line, buttons.

### 2.1 End screen strings

END_TITLE_WIN | 40 | End screen heading for the eight market endings
Supplier of record
END_SIGN_WIN | 140 | End screen, after epilogue lines, market endings
The Bureau stamps the entry. The market is yours to keep, and to explain.
END_STAT_MARKET | 24 | Stats label (value {market})
Market held
END_STAT_SHARE | 24 | Stats label (value {share}%)
Final share
END_STAT_RECORD | 24 | Stats label (value: Open and Hard counts, built by the game)
Choices made
END_STAT_BOTS | 24 | Stats label (value {bots})
Rival shares

Under END_STAT_RECORD the game writes "{n} open, {m} hard". The words Open and Hard appear only here, as plain counts of the two kinds of choice. Ask the owner if even that should stay hidden (Open questions).

### 2.2 Market endings (max 1000)

END_MIL_GOOD_NAME | 40 | End screen, ending name
The Quiet Fleets
END_MIL_GOOD | 1000 | End screen, win Military, stance 0 or more
More than half of Military now runs through you, and the Bureau has entered the company as supplier of record. The fleets you supply do not fire. They arrive, they are seen, and the quarrel at the border post ends by itself. You kept the terms fair and the ledgers open, which is dull, and works. Nobody in the Commons sleeps better, because nobody knows how close it was. Harrow Combine still runs its foundries, smaller and watching. The garrisons write you short letters that begin with thanks and end with a requisition. Far out, something heavy turns over once in the dark and holds still.

END_MIL_BAD_NAME | 40 | End screen, ending name
The Open Arsenal
END_MIL_BAD | 1000 | End screen, win Military, stance below 0
More than half of Military runs through you, and the fleets answer. Not to the Commons, and not to you exactly. They answer to the contract, and the contract answers to whoever paid last. The Bureau entered you as supplier of record and asked, very quietly, whether copies of the order forms might reach it first. They cannot. A border post has two flags now and one purchase order. You are never at the front. You only stand where the front is paid for. The racks are full and the cores hum. A great many people are armed, and the Plan has not yet decided what to call it.

END_LUX_GOOD_NAME | 40 | End screen, ending name
The Open Gallery
END_LUX_GOOD | 1000 | End screen, win Luxury, stance 0 or more
More than half of Luxury moves through you, and you kept the doors open. Silk, sunmusk and cut glimmers went where the Plan had never thought to send beauty: the dock mess, the night shift, the school on the ring. Masks that once cost a season's rations were lent at festivals and came back with a stain and a story. Velvet Concord still keeps the grand tables, though fewer people stand at them. The Bureau noticed. It drafted a form for the allocation of beauty and then, to its credit, left it blank. The cut glimmers catch the lamps, and for once the lamps look back.

END_LUX_BAD_NAME | 40 | End screen, ending name
The Gilded Cage
END_LUX_BAD | 1000 | End screen, win Luxury, stance below 0
More than half of Luxury is yours, and everyone wants what only you hold. Prices climb the way stairs do in a dream. Buyers who once haggled now wait, and the ones who cannot wait send guards. Your vaults are lit gold and built like a cell. The Bureau entered you as supplier of record and asked, politely, how many locks. Velvet Concord's masks hang in its empty halls. You have everything the sky finds beautiful, and no one left who may touch it unwatched. The cut glimmers hum faintly as you pass, the way glass does before it breaks.

END_MIN_GOOD_NAME | 40 | End screen, ending name
The Footing
END_MIN_GOOD | 1000 | End screen, win Minerals, stance 0 or more
More than half of Minerals comes through you, and you spent it on ground. Ingot from the smelter, seam alloy from the deep cuts, plate from the fabric: the next ring of homes stands on them, with floors that do not ring when walked. Cinderrest and Greywake are quiet. The crews rotate, and the ones who cough are sent up early. Harrow Combine still cuts, at its own pace, in its own corner. The Bureau counted the new homes and found, to its surprise, that a form existed for them. Under the floors the stone is patient. It always was. You only learned to ask.

END_MIN_BAD_NAME | 40 | End screen, ending name
The Strip
END_MIN_BAD | 1000 | End screen, win Minerals, stance below 0
More than half of Minerals comes through you, and the seams are paying for it. Cinderrest and Greywake were cut to the bone, and then to the bone beneath. The white dust has reached the lamps of more rocks, and the Bureau lists every one as uninhabited. They are not. The crews ask about the next seam and you point to the next chart. Ingot, seam alloy and plate leave in long rows, and the dead worlds spread one cut at a time. You were never told they were anything else. The glass in the walls hums once, low, where it stopped being a wall.

END_BIO_GOOD_NAME | 40 | End screen, ending name
The Long Harvest
END_BIO_GOOD | 1000 | End screen, win Biotech, stance 0 or more
More than half of Biotech passes through you, and you let it go. Bio-gel and gene seed reached the terraces at Tillam, the fields at Ashgate and clinics nobody had thought to supply. The grey leaves held. A cure went out on plain paper, with no licence number, and was copied by hand in rooms the Bureau never saw. Velvet Concord still sells the fine strains to those who can pay. The Plan took the credit, which is its way. In the culture lab the vats hum at the pace of something that has all the time it needs.

END_BIO_BAD_NAME | 40 | End screen, ending name
The Locked Seed
END_BIO_BAD | 1000 | End screen, win Biotech, stance below 0
More than half of Biotech is yours, and the seed is locked. Gene seed leaves the culture lab with a licence stamped on every grain and a form for each harvest. The terraces at Tillam and the fields at Ashgate grow what you allow, on terms the Bureau calls reasonable. Nothing is withheld by cruelty. It is withheld by paperwork, which is quieter. Velvet Concord cannot sell what your wall will not let it copy. The vats are clean and the shelves are full. In the lab, something small and patented turns toward the light.

### 2.3 Non-win endings

END_BANKRUPT_NAME | 40 | End screen, ending name
The Ledger Closes
END_BANKRUPT | 600 | End screen, third stranding (loss)
The company was stranded again, with no ships and too little cash to buy one, and the Bureau had no relief left to file. The third notice is the last. Your ships are entered in the Common Ledger, and your name is given a quota that is fair and equal and exactly the size of everyone else's. A clerk reads the closing form aloud and adds that nothing here was ever owed to you. The three rivals go on selling. The Standings graph shows a flat line where you were. The sky did not notice.

END_SWEPT_NAME | 40 | End screen, ending name
One Name on Every Row
END_SWEPT | 600 | End screen, one bot over half of every market (loss; {bot} is the sweeping bot)
{bot} holds more than half of every market, and the Bureau finds this very convenient. One supplier means one form instead of four. Your ships still run, and your orders are still taken, politely, at {bot}'s counters. The Standings graph shows four lines near the floor and one above everything else. No one did anything cruel. The market simply learned your name last. The sky did not notice, and the Plan thanked {bot} for its service.

END_OUTCOMPETED_NAME | 40 | End screen, ending name
A Fair Share
END_OUTCOMPETED | 700 | End screen, cycle limit with no market over half (soft ending; {market} best market, {share} its share, {bot} the strongest rival)
The window closed with no market held. Your best was {market}, at {share}% of it, and the strongest of the three rivals was {bot}. You did not lose. The company is solvent, the ships run, and the Bureau lists you as a participant, a word with no weight. A spread of small shares does not add up to a market. A single market, held all the way, does. The sky has no opinion. It never needed one.

### 2.4 Epilogue lines (max 140; up to four shown, in this order)

1. Capstone line, only if the capstone of the win market is learned (one per market).
2. Tech line, always (by number of tech done in the win market, zero to three).
3. Rival line, only if rival_broken is true for the win market ({bot} = mil_bot_marked of that market).
4. Second market line, only if another market is over a quarter share (one line per second market).

EPI_CAP_MIL | 140 | Epilogue 1, Military, capstone learned
The Standing Fleet kept every rival's growth held down to the last cycle. Nobody asked how.
EPI_CAP_LUX | 140 | Epilogue 1, Luxury, capstone learned
You bought one rival's best client with a handshake and a gift. The guild filed it as courtesy.
EPI_CAP_MIN | 140 | Epilogue 1, Minerals, capstone learned
The last seam in reach was yours, and the rivals worked the rest. They do not mention it.
EPI_CAP_BIO | 140 | Epilogue 1, Biotech, capstone learned
The Patent Wall stands. The rivals' vats run slower behind it, and the clerks call that quality control.
EPI_TECH_0 | 140 | Epilogue 2, no tech done in the win market
The {workshop} never finished a tech. It ran on habit and good hands.
EPI_TECH_1 | 140 | Epilogue 2, one tech done
One tech came out of the {workshop}. It is mentioned in the minutes.
EPI_TECH_2 | 140 | Epilogue 2, two techs done
Two techs came out of the {workshop}. The third is still on the board.
EPI_TECH_3 | 140 | Epilogue 2, all three techs done
All three techs came out of the {workshop}. The board has run out of things to approve.
EPI_RIVAL | 140 | Epilogue 3, a rival was cut a tier in the win market
{bot} was cut down a tier in {market} and has not come back. Its letters are shorter now.
EPI_SECOND_MIL | 140 | Epilogue 4, Military is the second market over a quarter
Military ran second, past a quarter of its market. The fleets noticed, and kept your number.
EPI_SECOND_LUX | 140 | Epilogue 4, Luxury is second
Luxury ran second, past a quarter of its market. The masks at the gala came from you.
EPI_SECOND_MIN | 140 | Epilogue 4, Minerals is second
Minerals ran second, past a quarter of its market. The dust remembers you anyway.
EPI_SECOND_BIO | 140 | Epilogue 4, Biotech is second
Biotech ran second, past a quarter of its market. A vat in a back room has your name on it.

## 3. Sample chain: Military

Bot hits are named in words, never numbers. Every step has two choices; the player sees the button, the effect line and then, after choosing, the result popup with a Standings line. Flags are exactly the core doc: stance_mil Open +1, Hard -1; mil_steps_done +1 per step; mil_bot_marked = the bot hit most by that choice (a tie goes to the lower bot number); mil_rival_broken = true if the choice cuts a tier. {player_effect} is one plain phrase from data. Suggested player effects (economy-designer decides, not binding): Open = steady gain such as a Military price held up for a while; Hard = more cash or a bigger edge now, with a cost or risk. Tag form for data: [bot: <bot id>, <market>, <strength|growth|tier> <down S|M|L | -1>] and [player: economy sets].

Bodies for steps 2 and later have two variants, chosen by the previous choice in the same chain (O after Open, H after Hard). B1 has one body (see Open questions). Result popups share the title of the step in the log.

### MIL_A1 (3 steps, chain A). Trigger: first sale in Military after cycle 4

MIL_A1_TITLE | 40 | Choice screen title
A garrison offers a long contract
MIL_A1_BODY | 280 | Choice screen body
A garrison on Ashgate's high ring has bought your first Military cargo and wants a long contract. The quartermaster calls it a partnership. Harrow Combine supplies the garrison today and would lose its berth. The ink on the form is still wet.
MIL_A1_OPEN_BTN | 28 | Button
Sign the standard term
MIL_A1_OPEN_EFF | 90 | Effect line
Harrow Combine's Military growth falls a little. {player_effect}
MIL_A1_HARD_BTN | 28 | Button
Take sole supply
MIL_A1_HARD_EFF | 90 | Effect line
Harrow Combine's Military strength falls clearly. A rumour follows. {player_effect}
MIL_A1_OPEN_RES_TITLE | 32 | Result popup title
A fair term, signed
MIL_A1_OPEN_RES | 280 | Result popup
The garrison signed at the standard term and kept Harrow Combine as a second supplier. Harrow's orders shrink a little each cycle, and its Military growth slows. The quartermaster filed the page under good order. The ink dried the colour of rust.
MIL_A1_OPEN_STD | 90 | Standings line under the result
Harrow Combine, Military: growth down a little.
MIL_A1_HARD_RES_TITLE | 32 | Result popup title
Sole supply, signed
MIL_A1_HARD_RES | 280 | Result popup
The garrison named you its only supplier. Harrow Combine lost its berth and much of its Military volume at once. By evening a rumour crossed the high ring: you undercut honest hulls. It is half true, the fastest kind. Harrow's agents took note.
MIL_A1_HARD_STD | 90 | Standings line under the result
Harrow Combine, Military: strength down clearly.

Flags: Open: stance_mil +1, mil_steps_done +1, mil_bot_marked = bot_1. Hard: stance_mil -1, mil_steps_done +1, mil_bot_marked = bot_1, hostile rumour (player-side risk, economy sets). rival_broken unchanged.

### MIL_A2. Trigger: share 15% or six cycles after A1

MIL_A2_TITLE | 40 | Choice screen title
A post wants both sides supplied
MIL_A2_BODY_O | 280 | Body after Open in A1
Word is that your terms are fair. A border post between two fleets that do not speak asks you to supply both. Each side will pay, and neither will say so aloud. Harrow Combine serves one of them. Ostrel Syndicate carries the messages. The post has one dock and two flags.
MIL_A2_BODY_H | 280 | Body after Hard in A1
Word is that you take what you want. A border post between two fleets that do not speak asks for a supplier who can be firm. You could supply both, or only the fleet Harrow Combine does not serve. Ostrel Syndicate carries their messages and watches the dock.
MIL_A2_OPEN_BTN | 28 | Button
Supply both sides
MIL_A2_OPEN_EFF | 90 | Effect line
Ostrel Syndicate's Military growth falls a little. {player_effect}
MIL_A2_HARD_BTN | 28 | Button
Arm one side only
MIL_A2_HARD_EFF | 90 | Effect line
Harrow Combine drops a tier in Military. {player_effect}
MIL_A2_OPEN_RES_TITLE | 32 | Result popup title
Both sides pay
MIL_A2_OPEN_RES | 280 | Result popup
Both fleets signed. Each was told the other had signed too, and both checked. Ostrel Syndicate, which carried their messages, finds the post no longer needs a go-between, and its Military growth slows a little. The two flags have stopped looking at each other.
MIL_A2_OPEN_STD | 90 | Standings line under the result
Ostrel Syndicate, Military: growth down a little.
MIL_A2_HARD_RES_TITLE | 32 | Result popup title
One side is armed
MIL_A2_HARD_RES | 280 | Result popup
You armed the fleet Harrow Combine does not serve. It came back stronger, and Harrow's client fell behind its own line. Harrow drops a tier in Military: smaller orders, smaller crews. The post calls it a correction. Nobody called it war.
MIL_A2_HARD_STD | 90 | Standings line under the result
Harrow Combine, Military: moved down a tier.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_3. (The core doc's "bot_3 tier stays" is no change and has no text; see Open questions.) Hard: stance -1, steps +1, mil_bot_marked = bot_1, mil_rival_broken = true.

### MIL_A3. Trigger: tech MIL_2 done or share 25%

MIL_A3_TITLE | 40 | Choice screen title
A quartermaster sells a ledger
MIL_A3_BODY_O | 280 | Body after Open in A2
The quartermaster of the border post is grateful and nervous. He waits at the dock with a case. In it is Harrow Combine's ledger of clients, prices and berths, copied by hand. He asks little. A ledger, he says, is only a list until someone reads it aloud.
MIL_A3_BODY_H | 280 | Body after Hard in A2
The quartermaster of the border post is neither grateful nor nervous, only useful. He waits at the dock with a case. In it is Harrow Combine's ledger of clients, prices and berths, copied by hand. He asks a good price, and that you remember who sold it.
MIL_A3_OPEN_BTN | 28 | Button
Match their prices
MIL_A3_OPEN_EFF | 90 | Effect line
Harrow Combine's Military strength falls a little. {player_effect}
MIL_A3_HARD_BTN | 28 | Button
Undercut every client
MIL_A3_HARD_EFF | 90 | Effect line
Harrow Combine and Ostrel Syndicate lose Military strength clearly. {player_effect}
MIL_A3_OPEN_RES_TITLE | 32 | Result popup title
Prices matched
MIL_A3_OPEN_RES | 280 | Result popup
You read the ledger and matched Harrow Combine's prices where they were fair, and no lower. Clients stayed with you without being pulled. Harrow's Military strength slips a little. The quartermaster took his payment and left the case. It was lighter than it looked.
MIL_A3_OPEN_STD | 90 | Standings line under the result
Harrow Combine, Military: strength down a little.
MIL_A3_HARD_RES_TITLE | 32 | Result popup title
Every client undercut
MIL_A3_HARD_RES | 280 | Result popup
You undercut Harrow Combine for every client in the ledger, and Ostrel Syndicate for the ones it shared. Both lost Military strength within a cycle. Harrow's clerks are searching for the leak. Ostrel's are not, which is worse.
MIL_A3_HARD_STD | 90 | Standings line under the result
Harrow Combine and Ostrel Syndicate, Military: strength down clearly.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_1. Hard: stance -1, steps +1, mil_bot_marked = bot_1 (tie with bot_3, lower number wins). rival_broken unchanged.

### MIL_B1 (4 steps, chain B). Trigger: skill MIL_3 learned or share 30%

MIL_B1_TITLE | 40 | Choice screen title
A fleet needs a refit fast
MIL_B1_BODY | 280 | Choice screen body (one body only)
A fleet on the high ring must be refitted before the next treaty review, and every drydock is booked. The admiral will pay for berths. Harrow Combine holds most of them, and Ostrel Syndicate counts on the spare slips. Hull plates hang in the dark, waiting.
MIL_B1_OPEN_BTN | 28 | Button
Refit at the usual pace
MIL_B1_OPEN_EFF | 90 | Effect line
Ostrel Syndicate's Military growth falls a little. {player_effect}
MIL_B1_HARD_BTN | 28 | Button
Rush it, take their berths
MIL_B1_HARD_EFF | 90 | Effect line
Harrow Combine's Military strength falls sharply. Ship upkeep rises.
MIL_B1_OPEN_RES_TITLE | 32 | Result popup title
The usual pace
MIL_B1_OPEN_RES | 280 | Result popup
The refit ran to schedule on the slips Ostrel Syndicate had counted on, and its Military growth slows a little. The admiral signed the review on time and never mentioned the delay he did not suffer. The hull plates came back with a faint ring in them.
MIL_B1_OPEN_STD | 90 | Standings line under the result
Ostrel Syndicate, Military: growth down a little.
MIL_B1_HARD_RES_TITLE | 32 | Result popup title
A rushed refit
MIL_B1_HARD_RES | 280 | Result popup
You bought the berths Harrow Combine held and refitted the fleet at speed. Harrow's Military strength falls sharply, its crews idle and its slips empty. Your ships ran extra shifts, and Ship upkeep rises. The plates were still warm when they were signed for.
MIL_B1_HARD_STD | 90 | Standings line under the result
Harrow Combine, Military: strength down sharply.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_3. Hard: stance -1, steps +1, mil_bot_marked = bot_1, Ship upkeep up (core doc).

### MIL_B2. Trigger: four cycles after B1

MIL_B2_TITLE | 40 | Choice screen title
The refit breaks a clause
MIL_B2_BODY_O | 280 | Body after Open in B1
The refit ran to the usual pace, but a treaty clause bans one fitting you installed in good faith. The treaty office will review it. You may open the whole refit to review, or file late and say nothing. Velvet Concord's parade squadrons carry the same part.
MIL_B2_BODY_H | 280 | Body after Hard in B1
The refit was rushed, and a treaty clause bans one fitting you installed in haste. The treaty office will review it, and every fleet that carries the same part. You may open the refit to review, or file late and say nothing. Harrow Combine's older fleets carry it too.
MIL_B2_OPEN_BTN | 28 | Button
Open the refit to review
MIL_B2_OPEN_EFF | 90 | Effect line
Velvet Concord's Military strength falls a little. {player_effect}
MIL_B2_HARD_BTN | 28 | Button
File late, say nothing
MIL_B2_HARD_EFF | 90 | Effect line
Harrow Combine drops a tier in Military. {player_effect}
MIL_B2_OPEN_RES_TITLE | 32 | Result popup title
The office reviews the refit
MIL_B2_OPEN_RES | 280 | Result popup
You opened the refit to review. The office read your forms and then everybody else's. Velvet Concord, whose parade squadrons carry the same part, lost contracts while it was checked, and its Military strength falls a little. The office thanked you for the trouble. It meant it.
MIL_B2_OPEN_STD | 90 | Standings line under the result
Velvet Concord, Military: strength down a little.
MIL_B2_HARD_RES_TITLE | 32 | Result popup title
A late filing
MIL_B2_HARD_RES | 280 | Result popup
You filed late and kept quiet. The office, short of someone to blame, read Harrow Combine's older fleets under the same clause. Harrow drops a tier in Military, and its fleets stand idle for the review. The clause is still in force. It has only moved.
MIL_B2_HARD_STD | 90 | Standings line under the result
Harrow Combine, Military: moved down a tier.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_2. Hard: stance -1, steps +1, mil_bot_marked = bot_1, mil_rival_broken = true.

### MIL_B3. Trigger: share 40% or tech MIL_4 done

MIL_B3_TITLE | 40 | Choice screen title
An arms fair sends an invitation
MIL_B3_BODY_O | 280 | Body after Open in B2
The treaty office has cleared you, and the arms fair wants you in the main hall. Ostrel Syndicate keeps a stand there every year, small and always full. You may take a modest stand beside it, or buy the hall for the week.
MIL_B3_BODY_H | 280 | Body after Hard in B2
The arms fair invites you with the care people give a lit fuse. Ostrel Syndicate keeps a stand there every year, small and always full. You may take a modest stand beside it, or buy the main hall and everything on its floor for the week.
MIL_B3_OPEN_BTN | 28 | Button
Take a modest stand
MIL_B3_OPEN_EFF | 90 | Effect line
Ostrel Syndicate's Military strength falls clearly. {player_effect}
MIL_B3_HARD_BTN | 28 | Button
Buy the main hall
MIL_B3_HARD_EFF | 90 | Effect line
All three rivals' Military growth falls a little. You pay a fee now.
MIL_B3_OPEN_RES_TITLE | 32 | Result popup title
A modest stand
MIL_B3_OPEN_RES | 280 | Result popup
You took a plain stand beside Ostrel Syndicate's and sold plainly. Buyers who came for one table stayed for two, and by the closing bell Ostrel's Military strength had fallen clearly. The syndicate noticed and has not minded. Nobody in a grey coat ever seems to.
MIL_B3_OPEN_STD | 90 | Standings line under the result
Ostrel Syndicate, Military: strength down clearly.
MIL_B3_HARD_RES_TITLE | 32 | Result popup title
The main hall, bought
MIL_B3_HARD_RES | 280 | Result popup
You bought the hall for the week. Harrow Combine, Velvet Concord and Ostrel Syndicate all sold from the corridors, and all three grow more slowly in Military. The fee was large and paid on the day. The hall echoed for days after the last buyer left.
MIL_B3_HARD_STD | 90 | Standings line under the result
All three rivals, Military: growth down a little.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_3. Hard: stance -1, steps +1, mil_bot_marked = bot_1 (three-way tie, lowest number), fee paid (player-side, economy sets).

### MIL_B4. Trigger: share 45%. It always fires before a win is possible.

MIL_B4_TITLE | 40 | Choice screen title
The fleet asks who it answers to
MIL_B4_BODY_O | 280 | Body after Open in B3
The fleets you supply now run on your schedule. Their admiral asks, with the care of a man testing ice, who they answer to. {bot} has lost the most to you and watches from the door. You may say the Commons, and put the fleets under open watch, or say the contract.
MIL_B4_BODY_H | 280 | Body after Hard in B3
The fleets you supply now run on your schedule and your price. Their admiral asks who they answer to, and does not ask kindly. {bot} has lost the most to you and watches from the door. You may say the Commons, and put the fleets under open watch, or say the contract.
MIL_B4_OPEN_BTN | 28 | Button
Answer to the Commons
MIL_B4_OPEN_EFF | 90 | Effect line
Harrow Combine loses its client: its Military growth falls clearly. {player_effect}
MIL_B4_HARD_BTN | 28 | Button
Answer to the contract
MIL_B4_HARD_EFF | 90 | Effect line
Harrow Combine and Ostrel Syndicate lose Military strength sharply. {player_effect}
MIL_B4_OPEN_RES_TITLE | 32 | Result popup title
The fleets are watched
MIL_B4_OPEN_RES | 280 | Result popup
You named the Commons. The fleets now report to an open committee, and the contract carries a clause a clerk can read. Harrow Combine had counted on them as its client. It loses them, and its Military growth falls clearly. The admiral saluted a form. The form saluted back.
MIL_B4_OPEN_STD | 90 | Standings line under the result
Harrow Combine, Military: growth down clearly.
MIL_B4_HARD_RES_TITLE | 32 | Result popup title
The fleets keep the contract
MIL_B4_HARD_RES | 280 | Result popup
You named the contract. The fleets came to heel at once, and the terms stayed yours. Harrow Combine and Ostrel Syndicate lost Military strength sharply, with no client left to serve. The admiral did not salute. He signed.
MIL_B4_HARD_STD | 90 | Standings line under the result
Harrow Combine and Ostrel Syndicate, Military: strength down sharply.

Flags: Open: stance +1, steps +1, mil_bot_marked = bot_1. Hard: stance -1, steps +1, mil_bot_marked = bot_1 (tie with bot_3). Seven steps seen with all choices Open give stance +7 (END_MIL_GOOD); all Hard give -7 (END_MIL_BAD).

Check against R-BOT: every one of the 14 choices changes a bot stat. Open also helps the player or steadies them (via {player_effect}); Hard also costs or risks (rumour, upkeep, fee, or a data-set cost).

## 4. Style guide for the other three chains

### 4.1 Tone per market

- Military: drill, treaty, berth, requisition, clause, garrison. Stolid and procedural. The irony is in the form. One odd detail per text: a heavy thing turning in the dark, a hull that rings, ink that dries the colour of rust.
- Luxury: masks, guilds, a seat at the table, gilt, scent. Lighter and more vain. The irony is in what a room believes. Odd detail: glass that hums before it breaks, a mask with no face behind it.
- Minerals: dust, heat, cold, patience, Cinderrest and Greywake. Terse. Few adjectives. The irony is that the rock is never in a hurry. Odd detail: white dust in even rings, glass that rings in the teeth.
- Biotech: vats, strains, clinics, licences. Slow, damp, clinical and polite. The irony is consent and paperwork. Odd detail: something growing a colour it was not supposed to, a vat that hums at a patient pace.
- Each bot has a fixed voice. Harrow Combine: heavy, formal, slow to forgive. Velvet Concord: soft, gilded, denies everything in advance. Ostrel Syndicate: grey, small, polite, already in the room. Use the STD_BOTx_VOICE lines as the guide.

### 4.2 Open and Hard choices

- The player never sees "Open" or "Hard". Both buttons read as a defensible decision. No moral words, no "good" or "bad", no "fair" as a label on the button.
- Open buttons use verbs of sharing, keeping terms and waiting: sign the standard term, supply both, take a modest stand, answer to the Commons, open the refit to review. Hard buttons use verbs of taking and closing: take, buy, rush, undercut, file late, answer to the contract.
- Open effect lines name the smaller bot hit first, then {player_effect}. Hard effect lines name the bigger bot hit first, then the cost, risk or fee in words ("A rumour follows", "Ship upkeep rises", "You pay a fee now"). Never hide the cost.
- Bodies are neutral on the choice. Variants O and H change the mood of the opening lines to match what the player did last, in the same chain, and keep the same two options.
- Chain B step 4 (share 45%) always asks the question the ending turns on, in the market's own words. For Military: the Commons or the contract. Suggested pairs: Luxury, open the gallery or close the guild; Minerals, rest the seam or cut the last of it; Biotech, share the seed or lock it.
- Result texts do not judge. They say what happened and who it happened to, then one dry or odd line, never a lesson.

### 4.3 Competitor effects

- Name the bot in the effect line and again in the result text, in the second half of the text. Use the display name, never "rival 1" or the id.
- Size words: S "a little", M "clearly", L "sharply". Strength: "Military strength falls". Growth: "Military growth falls" or "grows more slowly". Tier: "drops a tier in Military". Hit on all three: "All three rivals". Delayed hit for a few cycles: "for a while".
- Close every result with a Standings line: "<Bot>, <Market>: <stat> down <size>." For tier cuts: "<Bot>, <Market>: moved down a tier." For two bots: "<Bot A> and <Bot B>, <Market>: ...". These lines are plain, like the Standings menu.
- Where a text names the bot the story marked, use {bot}. Texts that cannot be sure which bot was marked must name no bot, or use {bot}.
- No text promises more than the tag does: a hit is on the stat named, and the Standings graph will show it. Do not say a bot is "ruined" or "out" (bots never leave).

## 5. Sample shared one-time events (EV40+)

Format as events.md: ID | title (32) | tag | kind. Tags use good ids as in EV24. Planets are suggestions (economy-designer maps them to the planets that make or want the good). Fire once per run.

EV40 | Rivet guns pile up at Voltara | [price down: Voltara, rivets] | P
Voltara's foundry made more rivet guns than the garrisons ordered, and the surplus is stacked to the roof. Rivet guns there cost less and pay less. A clerk has asked whether a surplus is a kind of order. The stacks tick as they cool.

EV41 | Pulse cells are recalled | [price up: Ashgate, cells] | Q
A batch of pulse cells ran hot in the field, and the maker pulled the lot. Pulse cells at Ashgate cost more and pay more while the shelves stay bare. The recall notice says no one was harmed. It says so twice. The cells in storage hum a note too low to name.

EV43 | A glut of sunmusk | [price down: Quillon, musk] | I
A convoy of sunmusk reached Quillon on one tide, and nobody had ordered it. Sunmusk there costs less and pays less. The scent hangs in the corridors, and the buyers cannot agree what it smells of. The Bureau calls that variety.

EV46 | The smelter goes cold | [price up: Voltara, ingot] | P
Voltara's smelter lost its heat to a cracked line, and the casting stopped. Ingot there costs more and pays more until the furnace is lit again. The crew stand by the dead furnace. The metal inside still ticks as it shrinks.

EV49 | Quarantine at the culture lab | [planet closed: Brannock] | I
A culture in Brannock's lab grew a colour it was not supposed to, and the doctors closed the port to look at it. Routes touching Brannock are blocked for a while. The form says contained. The vats say nothing and go on growing.

EV50 | Spores come in cheap | [price down: Mossfell, spores] | Q
A damp season at Mossfell raised spores in every crate, more than anyone could sell. Spore cultures there cost less and pay less. The growers say a surplus is only an ambition that lost its form. The crates sweat in rows.

## 6. Open questions (consistency issues and ambiguities in the core doc)

1. Energy and food are Military and Biotech goods and every player sells them from cycle 1. So Military and Biotech are both active from the start (market_overhead for two markets, and MIL_A1 and BIO_A1 fire for everyone at cycle 5, "first sale after cycle 4"). Is that intended? Suggest A1 triggers on the first sale of a market's own non-raw good, or the 5% rule ignores common raws.
2. Name clash: Dunmere Syndicate vs Dunmere Reach (system 2). Proposed: Ostrel Syndicate. Also Lattice Alloy vs Lattice Plate: proposed Seam Alloy. Owner decides; the ids do not change.
3. "Texts for steps 2+ have two variants by the last choice": last in the same chain or last in the market? A3 can fire after B1 and B1 can fire before A1 is finished. I wrote variants by the previous step of the same chain, and B1 with one body.
4. mil_bot_marked: the bot hit most across all choices (a running tally) or the bot hit by the last choice? Ties are undefined. I assumed the lower bot number wins a tie and wrote the {bot} text for either reading.
5. MIL_A2 Open says "bot_3 tier stays (no change) and growth S down". "Tier stays" is no effect, so only the growth hit has text.
6. Tier cuts (MIL_A2 Hard, MIL_B2 Hard): what if the bot is already at tier 1? The text says "drops a tier"; the game should either guarantee tier 2 or more at that point, or the text must be softened.
7. Event counts: the shared pool is said to keep 25 events. EV01-16, EV17, EV20, EV21, EV22, EV24, EV25, EV26, EV28 are 24. EV19 (nomads and pirates) and BE01-BE03 (branching events) are not named as kept or retired. They use cash and follow-ups, and EV19 has a "pirates reduce trade" effect with no bot or market tie.
8. The Open/Hard counts on the end screen reveal the hidden record. Fine for the screen, but the player has never been told that a choice is Open or Hard. Keep the counts, or show a plain line like "Your choices decided this ending"?
9. Goal story: the Release is gone as the goal, so the preface, the mission board, the tutorial lines, LBL_GOAL, STORY ARC in screens.md and the whole Release/Corporation text set in endings.md are out of date. A rewrite task is needed; "supplier of record" is my proposal for the story frame.
10. An odd count: seven steps a market is an odd number, so stance never ties if all seven are seen. The "tie is good" rule only matters when steps are missing.
