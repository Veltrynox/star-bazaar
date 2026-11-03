# Four Markets: story texts and style guide

> Part of the Four Markets pack. Where the docs disagree, `2026-11-03-four-markets-summary.md` (reconciliation table R1 to R13) decides.

Date: 2026-11-03. Author: story-designer. Builds on design/proposals/2026-11-03-four-markets.md (ids fixed there). Status: PROPOSAL, nothing is wired and no file outside this one and the handoff was touched. Text blocks use the format "ID | max chars | where" with the text on the next line, so a script can check them. Texts contain no digits; every number comes from a placeholder the game fills.

## 0. Changes to story/voice.md (proposed, not applied)

1. Goal story. The cash goal and the Release no longer end the game. Proposed story term: supplier of record (the Bureau's entry for the company that holds more than half of a market). Story only, never shown as a mechanic. "Release", "Corporation", "cash goal" and the Release/Corporation choice screen retire from player texts. The preface, LBL_GOAL, MB and tutorial lines still say the old goal and need a rewrite in a later task (not done here).
2. New length limits (the old ones stay for everything else):
   - Market ending (END_<MKT>_GOOD/_BAD): max 1000, as the old Full tier. Epilogue line: max 140, up to 4 shown. Loss ending: max 600. Soft ending END_OUTCOMPETED: max 700. Bare/Partial/Full tiers retire.
   - Chain step: title 40, body 280, button 28, effect line 200 (Get, Cost, Rivals). Result popup: title 32, text 280. Standings line (plain, one per bot change, up to two under each result): 90.
   - Skill and tech node: name 24, flavour 90, plain line 110.
   - Pool event: unchanged (title 32, text 280).
3. New placeholders: {bot} (name of the bot the text is about), {market} (display name), {workshop} (workshop name), {share} (a percent, number only), {bots} (the three bot shares, built by the game), {cash_in} and {cash_out} (credits gained or paid by an option, number only), {n} (units of tech progress an option gives, number only), {cut} and {cut_std} (tier-cut phrases, see section 3), {goal} (units to craft for a tech), {m}. The earlier {player_effect} is retired; the effect line now states gain and cost itself.
4. New glossary (add to voice.md):
   - Markets: Military, Luxury, Minerals, Biotech. Running text: lower case only when used as a plain noun ("the military market" is avoided; write "Military" capitalised as a market name, always).
   - Share: the player's part of a market, shown as a percent. Standings: the menu with one graph per market (hotkey L).
   - Bots: Harrow Combine, Velvet Concord, Ostrel Syndicate (section 1.2). In the UI and text they are "rivals" or by name; never "AI".
   - Choices have internal ids opt_a and opt_b and a hidden direction value per market. The player never sees either, and no text, tag or screen shows a count, a lean or a stance. No text calls a choice good, bad, right or wrong, safe or risky, fair or ruthless (rules in section 4.2).
   - Size words in text: S = "a little", M = "clearly", L = "sharply". A tier cut = {cut} ("drops a tier", or "loses strength clearly" at the lowest tier). A boost to a bot = "gains a little Military strength". A strength change = "Military strength falls"; a growth change = "grows more slowly". No numbers except the placeholders above.
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

Selection and conditions: as the core doc, section 6 (hidden dir value, thresholds 10 and -10, last nudge decides between). Every text below follows voice.md and uses placeholders only for names and numbers. The ending screen order: heading, ending name, text, epilogue lines (up to four, in the order below), sign-off, stats block, run over line, buttons.

### 2.1 End screen strings

END_TITLE_WIN | 40 | End screen heading for the eight market endings
Supplier of record
END_SIGN_WIN | 140 | End screen, after epilogue lines, market endings
The Bureau stamps the entry. The market is yours to keep, and to explain.
END_STAT_MARKET | 24 | Stats label (value {market})
Market held
END_STAT_SHARE | 24 | Stats label (value {share}%)
Final share
END_STAT_BOTS | 24 | Stats label (value {bots})
Rival shares

The stats block has three rows only: market held, final share, rival shares. END_STAT_RECORD is removed; the end screen shows no counts, labels or record of choices (R11 in full).

### 2.2 Market endings (max 1000)

Condition for every GOOD ending: the win market M fired and dir_M is 10 or more, or dir_M is between -9 and 9 and the last nudge applied in M was positive, or no step in M fired. Condition for every BAD ending: dir_M is -10 or less, or between -9 and 9 with the last nudge negative. These notes are for the programmer only; no number, count or stance word is shown. The texts describe what the world shows after the win, never what kind of owner the player was, so they read right when the result came from a mixed chain. They also never say "you chose" or "you kept".

END_MIL_GOOD_NAME | 40 | End screen, ending name
The Quiet Fleets
END_MIL_GOOD | 1000 | End screen, win Military, good outcome
More than half of Military now runs through you, and the Bureau has entered the company as supplier of record. The fleets you supply do not fire. They arrive, they are seen, and the quarrel at the border post ends by itself. The terms are posted and the ledgers can be read, which is dull, and works. Nobody in the Commons sleeps better, because nobody knows how close it was. Harrow Combine still runs its foundries, smaller and watching. The garrisons write you short letters that begin with thanks and end with a requisition. Far out, something heavy turns over once in the dark and holds still.

END_MIL_BAD_NAME | 40 | End screen, ending name
The Full Racks
END_MIL_BAD | 1000 | End screen, win Military, bad outcome
More than half of Military runs through you, and the fleets answer. Not to the Commons, and not to you exactly. They answer to the order book, and the order book answers to whoever paid last. The Bureau entered you as supplier of record and asked, very quietly, whether copies of the order forms might reach it first. They cannot. A border post has two flags now and one purchase order. You are never at the front. You only stand where the front is paid for. The racks are full and the cores hum. A great many people are armed, and the Plan has not yet decided what to call it.

END_LUX_GOOD_NAME | 40 | End screen, ending name
The Lit Gallery
END_LUX_GOOD | 1000 | End screen, win Luxury, good outcome
More than half of Luxury moves through you, and the doors are wide. Silk, sunmusk and cut glimmers went where the Plan had never thought to send beauty: the dock mess, the night shift, the school on the ring. Masks that once cost a season's rations were lent at festivals and came back with a stain and a story. Velvet Concord still keeps the grand tables, though fewer people stand at them. The Bureau noticed. It drafted a form for the allocation of beauty and then, to its credit, left it blank. The cut glimmers catch the lamps, and for once the lamps look back.

END_LUX_BAD_NAME | 40 | End screen, ending name
The Gilded Cage
END_LUX_BAD | 1000 | End screen, win Luxury, bad outcome
More than half of Luxury is yours, and everyone wants what only you hold. Prices climb the way stairs do in a dream. Buyers who once haggled now wait, and the ones who cannot wait send guards. Your vaults are lit gold and built like a cell. The Bureau entered you as supplier of record and asked, politely, how many locks. Velvet Concord's masks hang in its empty halls. You have everything the sky finds beautiful, and no one left who may touch it unwatched. The cut glimmers hum faintly as you pass, the way glass does before it breaks.

END_MIN_GOOD_NAME | 40 | End screen, ending name
The Footing
END_MIN_GOOD | 1000 | End screen, win Minerals, good outcome
More than half of Minerals comes through you, and most of it went into ground. Ingot from the smelter, seam alloy from the deep cuts, plate from the fabric: the next ring of homes stands on them, with floors that do not ring when walked. Cinderrest and Greywake are quiet. The crews rotate, and the ones who cough are sent up early. Harrow Combine still cuts, at its own pace, in its own corner. The Bureau counted the new homes and found, to its surprise, that a form existed for them. Under the floors the stone is patient. It always was. You only learned to ask.

END_MIN_BAD_NAME | 40 | End screen, ending name
The Strip
END_MIN_BAD | 1000 | End screen, win Minerals, bad outcome
More than half of Minerals comes through you, and the seams are paying for it. Cinderrest and Greywake were cut to the bone, and then to the bone beneath. The white dust has reached the lamps of more rocks, and the Bureau lists every one as uninhabited. They are not. The crews ask about the next seam and you point to the next chart. Ingot, seam alloy and plate leave in long rows, and the dead worlds spread one cut at a time. You were never told they were anything else. The glass in the walls hums once, low, where it stopped being a wall.

END_BIO_GOOD_NAME | 40 | End screen, ending name
The Long Harvest
END_BIO_GOOD | 1000 | End screen, win Biotech, good outcome
More than half of Biotech passes through you, and it goes out the door. Bio-gel and gene seed reached the terraces at Tillam, the fields at Ashgate and clinics nobody had thought to supply. The grey leaves held. A cure went out on plain paper, with no licence number, and was copied by hand in rooms the Bureau never saw. Velvet Concord still sells the fine strains to those who can pay. The Plan took the credit, which is its way. In the culture lab the vats hum at the pace of something that has all the time it needs.

END_BIO_BAD_NAME | 40 | End screen, ending name
The Locked Seed
END_BIO_BAD | 1000 | End screen, win Biotech, bad outcome
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

### 2.4 Epilogue lines (max 140; up to four shown, in this order; they work from the win market's capstone, tech count, tier cut and tiebreak, never from choice counts)

1. Capstone line, only if the capstone of the win market is learned (one per market).
2. Tech line, always (by number of tech done in the win market, zero to three).
3. Rival line, only if rival_broken is true for the win market, meaning a tier really dropped ({bot} = the bot whose tier dropped; use the marked bot of that market only if the tier cut was its last cut).
4. Narrow line, only if the win market ended on the tiebreak (dir between -9 and 9). Same line for good and bad outcomes; it names no direction.
5. Second market line, only if another market is over a quarter share (one line per second market).
If more than four apply, drop the lowest-numbered priority from the end (line 5 first). No line states or implies a count of choices or a type of choice.

EPI_CAP_MIL | 140 | Epilogue 1, Military, capstone learned
The Standing Fleet kept every rival's growth held down to the last cycle. Nobody asked how.
EPI_CAP_LUX | 140 | Epilogue 1, Luxury, capstone learned
You bought one rival's best client with a handshake and a gift. The guild filed it as courtesy.
EPI_CAP_MIN | 140 | Epilogue 1, Minerals, capstone learned
The last seam in reach was yours, and the rivals worked the rest. They do not mention it.
EPI_CAP_BIO | 140 | Epilogue 1, Biotech, capstone learned
The Patent Wall stands. The rivals' vats run slower behind it, and the clerks call that quality control.
EPI_TECH_0 | 140 | Epilogue 2, no tech done in the win market
The {workshop} never finished a tech. It ran on habit and steady hands.
EPI_TECH_1 | 140 | Epilogue 2, one tech done
One tech came out of the {workshop}. It is mentioned in the minutes.
EPI_TECH_2 | 140 | Epilogue 2, two techs done
Two techs came out of the {workshop}. The third is still on the board.
EPI_TECH_3 | 140 | Epilogue 2, all three techs done
All three techs came out of the {workshop}. The board has run out of things to approve.
EPI_RIVAL | 140 | Epilogue 3, a rival was cut a tier in the win market
{bot} was cut down a tier in {market} and has not come back. Its letters are shorter now.
EPI_NARROW | 140 | Epilogue 4, win market decided by the tiebreak, good or bad
The file could have read either way. The last page settled it, and the clerks have already filed it.
EPI_SECOND_MIL | 140 | Epilogue 5, Military is the second market over a quarter
Military ran second, past a quarter of its market. The fleets noticed, and kept your number.
EPI_SECOND_LUX | 140 | Epilogue 5, Luxury is second
Luxury ran second, past a quarter of its market. The masks at the gala came from you.
EPI_SECOND_MIN | 140 | Epilogue 5, Minerals is second
Minerals ran second, past a quarter of its market. The dust remembers you anyway.
EPI_SECOND_BIO | 140 | Epilogue 5, Biotech is second
Biotech ran second, past a quarter of its market. A vat in a back room has your name on it.

## 3. Sample chain: Military

Rewritten for the direction scheme (core doc 4.2, 4.3, 10). Every step has two options, internal ids opt_a and opt_b; the game shuffles the button order per run. The player sees a neutral in-fiction button and a three-part effect line (Get, Cost, Rivals). After choosing, a result popup and one or two Standings lines. The option effects are exactly the Military rows of core 4.3; the hidden nudges (dir_mil) are in that table and are not repeated here, so no text file next to the story can leak them. No text hints at them.

Effect line format (fixed): "Get: <gain>. Cost: <cost>. Rivals: <bot change>." Three parts, always in this order. A boost to a bot is a Cost and is named in the Cost part; cuts go in the Rivals part. Numbers come from placeholders only: {cash_in} and {cash_out} (credits), {n} (units of tech progress), {cut} (the tier-cut phrase, see below). Volume, price and upkeep sizes are words: S "a little", M "clearly", L "sharply" (bots) or "a lot" (player cash or volume, never needed here). Duration words: "for a while" (about 4 to 8 cycles), "for a few cycles" (2 to 4), "for the rest of the run".

Tier cut phrase (answers R8): wherever a step cuts a tier, the game fills {cut} in the effect line and {cut_std} in the Standings line. {cut} = "drops a tier" or, if that bot is already at the lowest tier, "loses strength clearly". {cut_std} = "moved down a tier" or "strength down clearly". Results use neutral wording ("cut back") that is true for both. The tier-cut epilogue line fires only if a tier actually dropped (mil_rival_broken).

Body variants (answers R6): a body for step 2 or later in a chain has two versions, _BODY_A and _BODY_B, chosen by which option id (opt_a or opt_b) was picked in the PREVIOUS step of the SAME chain. They describe what happened, never what kind of person did it. B1 has one body. Result popups share the title of the step in the log.

Marked bot (answers R7): mil_bot_marked = the bot with the biggest CUT from the last chosen option in Military (boosts never count). Size order: tier cut counts as M; L above M above S; strength and growth count the same; a tie goes to the lower bot number. Every Military option cuts at least one bot, so {bot} always names a bot that lost ground. Marked bot per option: A1 both bot_1; A2 opt_a bot_3, opt_b bot_1; A3 both bot_1; B1 opt_a bot_1, opt_b bot_3; B2 opt_a bot_2, opt_b bot_1; B3 opt_a bot_3, opt_b bot_1 (three-way tie); B4 both bot_1.

Per step, game state after a choice: mil_steps_done plus one, dir_mil gets the nudge from core 4.3 (hidden), mil_last_sign is set from that nudge, mil_bot_marked as above, mil_rival_broken set to true only if a tier actually dropped (A2 opt_b, B2 opt_b). Result texts carry no nudge.

### MIL_A1 (chain A, step 1). Trigger: first sale of a Military good, not a common raw, after cycle 4

MIL_A1_TITLE | 40 | Choice screen title
A garrison offers a long contract
MIL_A1_BODY | 280 | Choice screen body
A garrison on Ashgate's high ring has bought your first Military cargo and wants more. The quartermaster offers a long contract, or a clean sale by the lot. Harrow Combine supplies the garrison today and would lose its berth either way. The ink on the form is still wet.
MIL_A1_OPA_BTN | 28 | Button, opt_a
Sign the long contract
MIL_A1_OPA_EFF | 200 | Effect line, opt_a
Get: Military volume up a little for a while. Cost: {cash_out} credits deposit. Rivals: Harrow Combine's Military growth falls a little.
MIL_A1_OPB_BTN | 28 | Button, opt_b
Sell the cargo by the lot
MIL_A1_OPB_EFF | 200 | Effect line, opt_b
Get: {cash_in} credits now. Cost: Ostrel Syndicate gains a little Military strength. Rivals: Harrow Combine's Military strength falls a little.
MIL_A1_OPA_RES_TITLE | 32 | Result popup title, opt_a
The long contract is signed
MIL_A1_OPA_RES | 280 | Result popup, opt_a
The garrison signed for the long term and kept Harrow Combine as a second supplier. Your orders now arrive on a schedule, and the deposit is paid. Harrow's Military growth slows a little. The quartermaster filed the page twice. The ink dried the colour of rust.
MIL_A1_OPA_STD | 90 | Standings line, opt_a
Harrow Combine, Military: growth down a little.
MIL_A1_OPB_RES_TITLE | 32 | Result popup title, opt_b
Sold by the lot
MIL_A1_OPB_RES | 280 | Result popup, opt_b
The garrison bought the whole cargo and paid at the dock. With no standing contract, the berth it freed was filled by an Ostrel Syndicate clerk within the hour. Harrow Combine's Military strength falls a little, and Ostrel's rises a little. Nobody argued with the cash.
MIL_A1_OPB_STD | 90 | Standings line 1, opt_b
Harrow Combine, Military: strength down a little.
MIL_A1_OPB_STD2 | 90 | Standings line 2, opt_b
Ostrel Syndicate, Military: strength up a little.

### MIL_A2 (chain A, step 2). Trigger: share 15% or six cycles after A1

MIL_A2_TITLE | 40 | Choice screen title
A border post asks for supply
MIL_A2_BODY_A | 280 | Body after opt_a of MIL_A1
Word is that your long contract keeps its dates. A border post between two fleets that do not speak asks for a supplier. You could supply both fleets, or arm one. Harrow Combine serves one of them. Ostrel Syndicate carries the messages. The post has one dock and two flags.
MIL_A2_BODY_B | 280 | Body after opt_b of MIL_A1
Word is that you sell by the lot and leave no strings. A border post between two fleets that do not speak asks for a supplier. You could supply both fleets, or arm one. Harrow Combine serves one of them. Ostrel Syndicate carries the messages. The post has one dock and two flags.
MIL_A2_OPA_BTN | 28 | Button, opt_a
Supply both fleets
MIL_A2_OPA_EFF | 200 | Effect line, opt_a
Get: Military price up a little for a while. Cost: Ship upkeep rises a little for a while. Rivals: Ostrel Syndicate's Military growth falls a little.
MIL_A2_OPB_BTN | 28 | Button, opt_b
Supply one fleet only
MIL_A2_OPB_EFF | 200 | Effect line, opt_b
Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits for the stock. Rivals: Harrow Combine {cut} in Military.
MIL_A2_OPA_RES_TITLE | 32 | Result popup title, opt_a
Both fleets are supplied
MIL_A2_OPA_RES | 280 | Result popup, opt_a
Both fleets signed, each told the other had signed too, and both checked. Your hulls keep two sets of berths, so Ship upkeep rises for a while. Ostrel Syndicate carried their messages and now finds the post needs a go-between less. Its Military growth slows a little.
MIL_A2_OPA_STD | 90 | Standings line, opt_a
Ostrel Syndicate, Military: growth down a little.
MIL_A2_OPB_RES_TITLE | 32 | Result popup title, opt_b
One fleet is armed
MIL_A2_OPB_RES | 280 | Result popup, opt_b
You armed the fleet Harrow Combine does not serve, and its engineers left their notes on your bench. Harrow's client fell behind its own line, and Harrow was cut back in Military: smaller orders, smaller crews. The stock cost you. The post calls it a correction.
MIL_A2_OPB_STD | 90 | Standings line, opt_b
Harrow Combine, Military: {cut_std}.

### MIL_A3 (chain A, step 3). Trigger: tech MIL_2 done or share 25%

MIL_A3_TITLE | 40 | Choice screen title
A quartermaster sells a ledger
MIL_A3_BODY_A | 280 | Body after opt_a of MIL_A2
The post's quartermaster has seen you serve both flags, and he is nervous about it. He waits at the dock with a case. In it is Harrow Combine's ledger of clients, prices and berths, copied by hand. A ledger, he says, is only a list until someone reads it aloud.
MIL_A3_BODY_B | 280 | Body after opt_b of MIL_A2
The post's quartermaster has seen you arm one flag, and he is useful about it. He waits at the dock with a case. In it is Harrow Combine's ledger of clients, prices and berths, copied by hand. He names a price, and asks only that you remember who sold it.
MIL_A3_OPA_BTN | 28 | Button, opt_a
Trade on the ledger
MIL_A3_OPA_EFF | 200 | Effect line, opt_a
Get: {cash_in} credits and Military volume up a little for a few cycles. Cost: Ostrel Syndicate gains a little Military strength. Rivals: Harrow Combine's Military strength falls clearly.
MIL_A3_OPB_BTN | 28 | Button, opt_b
Study the ledger
MIL_A3_OPB_EFF | 200 | Effect line, opt_b
Get: {n} units of tech progress at the Munitions Line. Cost: {cash_out} credits to the quartermaster. Rivals: Harrow Combine's Military strength and Ostrel Syndicate's growth fall a little.
MIL_A3_OPA_RES_TITLE | 32 | Result popup title, opt_a
The ledger is put to work
MIL_A3_OPA_RES | 280 | Result popup, opt_a
Your buyers read the ledger and walked into every client Harrow Combine had counted on. Cash came in and orders rose for a few cycles. Harrow's Military strength falls clearly. The case was copied twice before it was closed, and one copy reached Ostrel Syndicate.
MIL_A3_OPA_STD | 90 | Standings line 1, opt_a
Harrow Combine, Military: strength down clearly.
MIL_A3_OPA_STD2 | 90 | Standings line 2, opt_a
Ostrel Syndicate, Military: strength up a little.
MIL_A3_OPB_RES_TITLE | 32 | Result popup title, opt_b
The ledger is studied
MIL_A3_OPB_RES | 280 | Result popup, opt_b
You paid for the case and read it at the Munitions Line. It listed every part Harrow Combine bought and how each was cast, and your crews learned from it. Harrow's Military strength falls a little. Ostrel Syndicate, whose orders were in it too, grows more slowly.
MIL_A3_OPB_STD | 90 | Standings line 1, opt_b
Harrow Combine, Military: strength down a little.
MIL_A3_OPB_STD2 | 90 | Standings line 2, opt_b
Ostrel Syndicate, Military: growth down a little.

### MIL_B1 (chain B, step 1). Trigger: skill MIL_3 learned or share 30%

MIL_B1_TITLE | 40 | Choice screen title
A fleet needs a refit fast
MIL_B1_BODY | 280 | Choice screen body (one body only)
A fleet on the high ring must be refitted before the next treaty review, and every drydock is booked. The admiral will pay for berths, now or on a long booking. Harrow Combine holds most of them, and Ostrel Syndicate counts on the spare slips. Hull plates wait in the dark.
MIL_B1_OPA_BTN | 28 | Button, opt_a
Take the rush job
MIL_B1_OPA_EFF | 200 | Effect line, opt_a
Get: {cash_in} credits now. Cost: Ship upkeep rises clearly for the rest of the run. Rivals: Harrow Combine's Military strength falls clearly.
MIL_B1_OPB_BTN | 28 | Button, opt_b
Book the long berths
MIL_B1_OPB_EFF | 200 | Effect line, opt_b
Get: Military volume up a little for the rest of the run. Cost: {cash_out} credits for the booking. Rivals: Ostrel Syndicate's Military growth falls a little.
MIL_B1_OPA_RES_TITLE | 32 | Result popup title, opt_a
The rush job is done
MIL_B1_OPA_RES | 280 | Result popup, opt_a
You bought the berths Harrow Combine held and refitted the fleet at speed. Your ships ran extra shifts, and Ship upkeep stays higher from now on. Harrow's slips stand empty and its Military strength falls clearly. The plates were still warm when signed for.
MIL_B1_OPA_STD | 90 | Standings line, opt_a
Harrow Combine, Military: strength down clearly.
MIL_B1_OPB_RES_TITLE | 32 | Result popup title, opt_b
The berths are booked
MIL_B1_OPB_RES | 280 | Result popup, opt_b
The admiral booked your berths for the long term, and the refit ran to schedule on the slips Ostrel Syndicate had counted on. The booking cost you, and orders will be steadier. Ostrel's Military growth slows a little. The plates came back with a faint ring in them.
MIL_B1_OPB_STD | 90 | Standings line, opt_b
Ostrel Syndicate, Military: growth down a little.

### MIL_B2 (chain B, step 2). Trigger: four cycles after B1

MIL_B2_TITLE | 40 | Choice screen title
The refit breaks a clause
MIL_B2_BODY_A | 280 | Body after opt_a of MIL_B1
The refit was rushed, and a treaty clause bans one fitting you installed in haste. The office will review it and every fleet that carries it. You may submit your refit, or file the change late. Velvet Concord's parade squadrons carry it. So do Harrow Combine's older fleets.
MIL_B2_BODY_B | 280 | Body after opt_b of MIL_B1
The refit ran to schedule, but a treaty clause bans one fitting you installed on time. The office will review it and every fleet that carries it. You may submit your refit, or file the change late. Velvet Concord's parade squadrons carry it. So do Harrow Combine's older fleets.
MIL_B2_OPA_BTN | 28 | Button, opt_a
Submit the refit to review
MIL_B2_OPA_EFF | 200 | Effect line, opt_a
Get: Military price up a little for a while. Cost: one route's trip cost rises a little for a few cycles. Rivals: Velvet Concord's Military strength falls a little.
MIL_B2_OPB_BTN | 28 | Button, opt_b
File the change late
MIL_B2_OPB_EFF | 200 | Effect line, opt_b
Get: {cash_in} credits for the stripped part. Cost: Military volume down a little for a few cycles. Rivals: Harrow Combine {cut} in Military.
MIL_B2_OPA_RES_TITLE | 32 | Result popup title, opt_a
The office reviews the refit
MIL_B2_OPA_RES | 280 | Result popup, opt_a
You submitted the refit. The office read your forms, then everyone else's. Velvet Concord, whose parade squadrons carry the same part, lost contracts while checked, and its Military strength falls a little. The cleared stamp lifts prices for a while. One route sat in a queue.
MIL_B2_OPA_STD | 90 | Standings line, opt_a
Velvet Concord, Military: strength down a little.
MIL_B2_OPB_RES_TITLE | 32 | Result popup title, opt_b
The change is filed late
MIL_B2_OPB_RES | 280 | Result popup, opt_b
You stripped the part, sold it back and filed late. The office, short of a name, read Harrow Combine's older fleets under the same clause. Harrow was cut back in Military and its fleets stood idle for the review. Your ships waited for new fittings. The clause has only moved.
MIL_B2_OPB_STD | 90 | Standings line, opt_b
Harrow Combine, Military: {cut_std}.

### MIL_B3 (chain B, step 3). Trigger: share 40% or tech MIL_4 done

MIL_B3_TITLE | 40 | Choice screen title
An arms fair sends an invitation
MIL_B3_BODY_A | 280 | Body after opt_a of MIL_B2
The office has finished its review, and the arms fair wants you in the main hall. Ostrel Syndicate keeps a stand there every year, small and always full. You may buy the main hall for the week, or take a modest stand beside Ostrel's. Velvet Concord will be at the gala next door.
MIL_B3_BODY_B | 280 | Body after opt_b of MIL_B2
The arms fair invites you with the care people give a lit fuse. Your late filing is the talk of the corridors. Ostrel Syndicate keeps a stand there every year, small and always full. You may buy the main hall for the week, or take a modest stand beside Ostrel's.
MIL_B3_OPA_BTN | 28 | Button, opt_a
Buy the main hall
MIL_B3_OPA_EFF | 200 | Effect line, opt_a
Get: Military volume up clearly for a while. Cost: {cash_out} credits for the hall. Rivals: Ostrel Syndicate's Military strength falls clearly.
MIL_B3_OPB_BTN | 28 | Button, opt_b
Take a modest stand
MIL_B3_OPB_EFF | 200 | Effect line, opt_b
Get: {n} units of tech progress at the Munitions Line. Cost: Velvet Concord gains a little Military strength. Rivals: all three rivals' Military growth falls a little.
MIL_B3_OPA_RES_TITLE | 32 | Result popup title, opt_a
The main hall is yours
MIL_B3_OPA_RES | 280 | Result popup, opt_a
You bought the hall for the week. Buyers walked past empty stands to reach yours, and your orders rose for a while. Ostrel Syndicate sold from the corridor, and its Military strength falls clearly. The fee was paid on the day. The hall echoed after the last buyer left.
MIL_B3_OPA_STD | 90 | Standings line, opt_a
Ostrel Syndicate, Military: strength down clearly.
MIL_B3_OPB_RES_TITLE | 32 | Result popup title, opt_b
A modest stand
MIL_B3_OPB_RES | 280 | Result popup, opt_b
You took a plain stand beside Ostrel's and listened more than you sold. Two engineers from the next stand talked shop for an hour. All three rivals grow more slowly in Military, though Velvet Concord, which bought the stand opposite, picked up a little strength.
MIL_B3_OPB_STD | 90 | Standings line 1, opt_b
All three rivals, Military: growth down a little.
MIL_B3_OPB_STD2 | 90 | Standings line 2, opt_b
Velvet Concord, Military: strength up a little.

### MIL_B4 (chain B, step 4). Trigger: share 45%. Always fires before a win is possible

MIL_B4_TITLE | 40 | Choice screen title
The fleets ask who sets the roster
MIL_B4_BODY_A | 280 | Body after opt_a of MIL_B3
The fleets you supply now run on your schedule and your price. Their admiral asks, with the care of a man testing ice, who should set the roster: each garrison, or your desk. {bot} has lost ground to you and watches from the door. Either answer will be written down.
MIL_B4_BODY_B | 280 | Body after opt_b of MIL_B3
The fleets you supply now run on what you sell and what you learned. Their admiral asks, with the care of a man testing ice, who should set the roster: each garrison, or your desk. {bot} has lost ground to you and watches from the door. Either answer will be written down.
MIL_B4_OPA_BTN | 28 | Button, opt_a
Roster by garrison
MIL_B4_OPA_EFF | 200 | Effect line, opt_a
Get: Military price up a little for the rest of the run. Cost: Military volume down a little for a few cycles. Rivals: Harrow Combine's Military growth falls clearly.
MIL_B4_OPB_BTN | 28 | Button, opt_b
Roster by contract
MIL_B4_OPB_EFF | 200 | Effect line, opt_b
Get: {cash_in} credits. Cost: Ship upkeep rises clearly for the rest of the run. Rivals: Harrow Combine and Ostrel Syndicate lose Military strength clearly.
MIL_B4_OPA_RES_TITLE | 32 | Result popup title, opt_a
Each garrison sets its roster
MIL_B4_OPA_RES | 280 | Result popup, opt_a
Each garrison now draws its own roster and calls on you by the week. Orders thinned for a few cycles while the rosters were written. After that they settled at a better price. Harrow Combine had counted on the fleets as its client, and its Military growth falls clearly.
MIL_B4_OPA_STD | 90 | Standings line, opt_a
Harrow Combine, Military: growth down clearly.
MIL_B4_OPB_RES_TITLE | 32 | Result popup title, opt_b
Your desk sets the roster
MIL_B4_OPB_RES | 280 | Result popup, opt_b
Your desk now sets the roster, and the fleets are held ready on contract terms. A large payment arrived the same week. Hulls kept ready cost more to keep, and Ship upkeep stays higher. Harrow Combine and Ostrel Syndicate lose Military strength clearly. The admiral signed.
MIL_B4_OPB_STD | 90 | Standings line, opt_b
Harrow Combine and Ostrel Syndicate, Military: strength down clearly.

Check against R-BOT and the trade-off rule: all 14 options change at least one bot stat; every option has a Get and a Cost; three options pay their Cost as a boost to a rival (A1 opt_b, A3 opt_a, B3 opt_b) and none is named safe or risky. No text names a direction. The two B4 options are written to the same length and pattern.

## 4. Style guide for the other three chains

### 4.1 Tone per market

- Military: drill, treaty, berth, requisition, clause, garrison. Stolid and procedural. The irony is in the form. One odd detail per text: a heavy thing turning in the dark, a hull that rings, ink that dries the colour of rust.
- Luxury: masks, guilds, a seat at the table, gilt, scent. Lighter and more vain. The irony is in what a room believes. Odd detail: glass that hums before it breaks, a mask with no face behind it.
- Minerals: dust, heat, cold, patience, Cinderrest and Greywake. Terse. Few adjectives. The irony is that the rock is never in a hurry. Odd detail: white dust in even rings, glass that rings in the teeth.
- Biotech: vats, strains, clinics, licences. Slow, damp, clinical and polite. The irony is consent and paperwork. Odd detail: something growing a colour it was not supposed to, a vat that hums at a patient pace.
- Each bot has a fixed voice. Harrow Combine: heavy, formal, slow to forgive. Velvet Concord: soft, gilded, denies everything in advance. Ostrel Syndicate: grey, small, polite, already in the room. Use the STD_BOTx_VOICE lines as the guide.

### 4.2 Neutral choice rules (replaces the old Open and Hard style rule)

Apply to every chain step in Luxury, Minerals and Biotech, and to any later choice event.

1. No moral labels. Buttons, effect lines, bodies and results never use good, bad, right, wrong, fair, unfair, ruthless, kind, cruel, honest, dirty, safe, risky, bold, greedy, generous, selfish, noble, open or closed as a verdict on an option. Words like "fair" may appear only inside the fiction as something a character says, never as the narrator's judgement of the player's act.
2. Buttons are two in-fiction actions, same length class (within about four characters of each other), same grammar (two verb phrases, or two noun phrases), no adjective that praises or blames. Do not pair a soft verb with a hard verb. Pair like with like: "Roster by garrison" and "Roster by contract"; "Sign the long contract" and "Sell the cargo by the lot".
3. Effect lines use the fixed three-part format "Get: ... Cost: ... Rivals: ...", the same order and about the same length for both options of a step. State the cost as plainly as the gain: same type size, same verb strength, same sentence shape. A boost to a bot goes in the Cost part ("Ostrel Syndicate gains a little Military strength"). Never write "but", "however" or "at least"; never put a cost in a smaller or later sentence than its gain.
4. Size words for effects: S "a little", M "clearly", L "sharply" (bots) or "a lot" (player). Durations: "for a while", "for a few cycles", "for the rest of the run". Numbers only from placeholders {cash_in}, {cash_out}, {n}; tier cuts only via {cut} and {cut_std}.
5. Use the trade-off pairs of core 4.5 as the shape of each step, and name which currencies trade: cash now vs steady volume; tech vs cash; bot cut vs your own dip; price vs volume; boost one bot vs weaken two; and in B3 and B4, permanent gain with a short dip vs large cash with higher upkeep. One option gets one currency, the other gets a different one. Never both options pay out in the same currency.
6. Bodies are neutral. They set the scene, name the stakes of both options and the bots involved, and end on the question or an odd detail, not on a hint. The two body variants (after opt_a, after opt_b) mention what happened last in plain facts: what the player signed, bought, filed, paid. They never say what that shows about the player.
7. Chain B step 4 asks the question the ending is about, but in operational words, so that both answers sound like a defensible rota or a ledger line. Suggested pairs: Luxury, who keeps the guest list (the gallery or the guild desk); Minerals, who sets the pace of the seam (the crew rota or the buyer's schedule); Biotech, who files the seed (each clinic or your lab). Do not use words that name the ending (commons, open, locked, wall, cage, strip, harvest).
8. Results do not judge and do not teach. They say what happened, to whom, with the bot change in words, then one dry or odd line.
9. Competitor effects: see 4.3. Pace: the same Get, Cost, Rivals order on every option.
10. Checks before a text is accepted: grep for the banned words of rule 1 in all chain files; compare character counts of the two buttons and the two effect lines of each step; read the pair aloud and check that it is not obvious which one a player who liked the ending would pick.

### 4.3 Competitor effects

- Name the bot in the effect line and again in the result, in the second half of the text. Use the display name, never "rival 1" or the id.
- Size words: S "a little", M "clearly", L "sharply". Strength: "Military strength falls". Growth: "Military growth falls" or "grows more slowly". Tier: {cut}. Hit on all three: "All three rivals". A boost: "gains a little Military strength" (strength up) or "grows faster" (growth up), always named in the Cost part and shown in a Standings line.
- How competitor effects are phrased: the bot is the subject of the clause, the player is the cause only in the result ("lost contracts while it was checked", not "you crushed it"). Never write "you hurt" or "you help" a bot; never call a cut a win or a boost a mistake.
- Close every result with Standings lines, one per bot change, up to two: "<Bot>, <Market>: <stat> down <size>." or "<Bot>, <Market>: <stat> up <size>." For tier cuts: "<Bot>, <Market>: {cut_std}." For two bots with the same change: "<Bot A> and <Bot B>, <Market>: ...". Plain, like the Standings menu.
- Where a text names the marked bot, use {bot}; it always names a bot the last choice cut (rule in section 3). Texts that cannot be sure which bot was marked name no bot.
- No text promises more than the data does: a hit is on the stat named and the Standings graph will show it. Never say a bot is ruined or out (bots never leave).

## 5. Sample shared one-time events (EV40+)

Format as events.md: ID | title (32) | tag | kind. Tags use good ids as in EV24. Planets are suggestions (economy-designer maps them to the planets that make or want the good). Fire once per run. Checked after the direction redesign: none of the six events mentions stance, Open, Hard or a choice, so none changed.

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

## 6. Consistency answers and open questions

Answers to the earlier consistency issues, under the direction scheme:

- R6 (which step the body variant follows): the previous step of the same chain, keyed by the option id picked there (opt_a or opt_b). B1 has one body. Fixed in section 3.
- R7 (tie on the marked bot): the marked bot is the one with the biggest cut from the last chosen option in that market; boosts never count; tier cut counts as M; strength and growth count the same; a tie goes to the lower bot number. Every Military option cuts at least one bot, so {bot} always names a bot that lost ground. Luxury, Minerals and Biotech tables also cut at least one bot per option (core R-BOT), so the rule holds there.
- R8 (tier cut on a bot already at the lowest tier, and an option with no text): the game fills {cut} and {cut_std} with the tier wording or the strength fallback of core 4.3; result texts use "cut back", which is true for both. The tier epilogue fires only if a tier really dropped. The earlier case of an option with no bot change is gone: every option now cuts or boosts a bot.

Open questions:

1. Effect lines say "a little" or "clearly" for volume, price and upkeep, but show credits and tech units as numbers. Show percentages too (placeholders {vol}, {price}, {upkeep}), or keep words? The "never hide a number" rule favours numbers; the effect line limit of 200 may have to grow to 230 if so.
2. The B4 buttons ("Roster by garrison" and "Roster by contract") are operational, but "contract" still sounds colder than "garrison". The same is likely in the other markets. Owner may want a playtest read before the other three chains are written.
3. EPI_NARROW appears when the market ended on the tiebreak (dir between -9 and 9). It does not say good or bad, but a sharp player may infer that the last choice mattered. Keep it, or cut it?
4. A strong lean that the last two steps turn is not detected by the epilogues. A run that leaned one way and ended the other reads from the ending text alone. A dedicated "turned late" line would need the game to expose the sign of dir_<mkt> before B3. Not written.
5. Names remain undecided (owner answer 7): Ostrel Syndicate, Seam Alloy, and the renamed endings The Lit Gallery and The Full Racks (the old names had the word Open in them).
6. The Standings lines for a boosted bot ("strength up a little") are visible, honest and fit the core rule, but the player will read a boost as a mistake in hindsight. Intended?
7. Pool events and shared texts that mention a Release, a Corporation or a cash goal still need the later rewrite (unchanged from before).