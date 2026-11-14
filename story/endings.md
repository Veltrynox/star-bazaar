# Endings (Four Markets, 2026-11-03)

The run ends with exactly one ending. The old Release/Corporation endings, the choice screen and the cash goal are retired. The end screen (game/end_screen.gd) reads the title from <id>_TITLE and the body from <id>. It shows no counts, labels, direction or record of choices; the readout of shares is drawn by the game.
Texts carry no placeholders: the game passes none to the ending body. The strongest rival and best market are shown by the game's own stat line and readout.
Selection (programmer notes, never shown): win in market M gives END_<MKT>_GOOD (GOOD or BAD by the hidden chain direction of that market; nothing of it is shown); no ship left and cash still negative gives END_BANKRUPT; the player under a tenth of every market for the sweep window gives END_SWEPT; the window closing with no market held gives END_OUTCOMPETED.
The BAD texts describe what the world shows after the same win. They never say the player chose anything and never judge the player.

## Market endings, good (max 1000; titles max 40)

END_MIL_GOOD_TITLE | 40 | End screen heading, win Military, good outcome
The Quiet Fleets

END_MIL_GOOD | 1000 | End screen body, win Military, good outcome
More than half of Military now runs through you, and the Bureau has entered the company as supplier of record. The fleets you supply do not fire. They arrive, they are seen, and the quarrel at the border post ends by itself. The terms are posted and the ledgers can be read, which is dull, and works. Nobody in the Commons sleeps better, because nobody knows how close it was. Harrow Combine still runs its foundries, smaller and watching. The garrisons write you short letters that begin with thanks and end with a requisition.

END_LUX_GOOD_TITLE | 40 | End screen heading, win Luxury, good outcome
The Lit Gallery

END_LUX_GOOD | 1000 | End screen body, win Luxury, good outcome
More than half of Luxury moves through you, and the doors are wide. Silk and cut glimmers went where the Plan had never thought to send beauty: the dock mess, the night shift, the school on the ring. Masks that once cost a season's rations were lent at festivals and came back with a stain and a story. Velvet Concord still keeps the grand tables, though fewer people stand at them. The Bureau drafted a form for the allocation of beauty and then, to its credit, left it blank.

END_MIN_GOOD_TITLE | 40 | End screen heading, win Minerals, good outcome
The Footing

END_MIN_GOOD | 1000 | End screen body, win Minerals, good outcome
More than half of Minerals comes through you, and most of it went into ground. Ingot from the smelter, alloy from the deep cuts, plate from the fabric: the next ring of homes stands on them, with floors that do not ring when walked. The crews rotate on a posted schedule. Harrow Combine still cuts, at its own pace, in its own corner. The Bureau counted the new homes and found, to its surprise, that a form existed for them. Under the floors the stone is patient. It always was.

END_BIO_GOOD_TITLE | 40 | End screen heading, win Biotech, good outcome
The Long Harvest

END_BIO_GOOD | 1000 | End screen body, win Biotech, good outcome
More than half of Biotech passes through you, and it goes out the door. Bio-gel and gene seed reached the terraces at Tillam, the fields at Ashgate and clinics nobody had thought to supply. A cure went out on plain paper, with no licence number, and was copied by hand in rooms the Bureau never saw. Velvet Concord still sells the fine strains to those who can pay. The Plan took the credit, which is its way. In the culture lab the vats hum at the pace of something with all the time it needs.

## Market endings, bad (max 1000; titles max 40)

END_MIL_BAD_TITLE | 40 | End screen heading, win Military, bad outcome
The Full Racks

END_MIL_BAD | 1000 | End screen body, win Military, bad outcome
More than half of Military runs through you, and the fleets answer. Not to the Commons, and not to you exactly. They answer to the order book, and the order book answers to whoever paid last. The Bureau entered you as supplier of record and asked, very quietly, whether copies of the order forms might reach it first. They cannot. A border post has two flags now and one purchase order. You are never at the front. You only stand where the front is paid for. The racks are full and the cores hum. A great many people are armed, and the Plan has not yet decided what to call it.

END_LUX_BAD_TITLE | 40 | End screen heading, win Luxury, bad outcome
The Gilded Cage

END_LUX_BAD | 1000 | End screen body, win Luxury, bad outcome
More than half of Luxury is yours, and everyone wants what only you hold. Prices climb the way stairs do in a dream. Buyers who once haggled now wait, and the ones who cannot wait send guards. Your vaults are lit gold and built like a cell. The Bureau entered you as supplier of record and asked, politely, how many locks. Velvet Concord's masks hang in its empty halls. You hold everything the sky finds beautiful, and no one left may touch it unwatched. The cut glimmers hum faintly as you pass, the way glass does before it breaks.

END_MIN_BAD_TITLE | 40 | End screen heading, win Minerals, bad outcome
The Strip

END_MIN_BAD | 1000 | End screen body, win Minerals, bad outcome
More than half of Minerals comes through you, and the seams are paying for it. Cinderrest and Greywake were cut to the bone, and then to the bone beneath. White dust has reached the lamps of more rocks, and the Bureau lists every one as uninhabited. They are not. The crews work each cut to its rim until it is gone. Ingot, alloy and plate leave in long rows, and the dead worlds spread one cut at a time. Harrow Combine's crews drift off to other rock. The glass in the walls hums once, low, where it stopped being a wall.

END_BIO_BAD_TITLE | 40 | End screen heading, win Biotech, bad outcome
The Locked Seed

END_BIO_BAD | 1000 | End screen body, win Biotech, bad outcome
More than half of Biotech is yours, and the seed is locked. Gene seed leaves the culture lab under a seal and a ticket for every batch. The terraces at Tillam and the fields at Ashgate grow what you allow, on terms the Bureau calls reasonable. Nothing is withheld in anger. It is withheld by paperwork, which is quieter. Velvet Concord cannot sell what your wall will not let it copy. The vats are clean and the shelves are full. In the lab, something small and patented turns toward the light.

## Loss and soft endings

END_BANKRUPT_TITLE | 40 | End screen heading, no ship left and cash still negative (loss)
The Ledger Closes

END_BANKRUPT | 600 | End screen body, no ship left and cash still negative (loss)
The company has no ships left, and the cash is still below zero. Each cycle the Bureau took the newest hull to cover the debt, and now the last is gone. Your ships are entered in the Common Ledger, and your name is given a quota that is equal and exactly the size of everyone else's. A clerk reads the closing form aloud and adds that nothing here was ever owed to you. The three rivals go on selling. The sky did not notice.


## End screen texts

END_STAT_CYCLES | 24 | End screen stats label
Cycles taken

END_STAT_CASH | 24 | End screen stats label
Final credits

END_RUN_OVER | 110 | End screen, above the buttons, every ending
This run is over. Start a new game or go to the main menu.

END_BTN_NEW | 24 | End screen button
New game

END_BTN_MENU | 24 | End screen button
Main menu

END_BTN_QUIT | 24 | End screen button
Quit game

## Epilogue lines (added 2026-11-03; max 140; up to four shown, in this order)
Shown under the ending text of the win market. They say what the company did (a capstone, a tech, a tier cut, a second market), never how many choices were of a kind, never a direction or a stance. If more than four apply, drop from the end. Placeholders: {workshop} (the win market's workshop), {bot} (the rival whose tier dropped; mil/lux/min/bio_rival_broken_bot), {market} (display name). The 11 ending ids are unchanged.
Order: 1 capstone (only if the win market's capstone is learned), 2 tech (always, by techs done in the win market), 3 rival (only if a tier really dropped in the win market), 4 second market (only if another market is over a quarter share; one line per second market).

EPI_CAP_MIL | 140 | Epilogue 1, win Military, capstone learned
The Standing Fleet kept every rival's growth held down to the last cycle. Nobody asked how.

EPI_CAP_LUX | 140 | Epilogue 1, win Luxury, capstone learned
You bought one rival's best client with a handshake and a gift. The guild filed it as courtesy.

EPI_CAP_MIN | 140 | Epilogue 1, win Minerals, capstone learned
The last seam in reach was yours, and the rivals worked the rest. They do not mention it.

EPI_CAP_BIO | 140 | Epilogue 1, win Biotech, capstone learned
The Patent Wall stands. The rivals' vats run slower behind it, and the clerks call that quality control.

EPI_TECH_0 | 140 | Epilogue 2, no tech done in the win market
The {workshop} never finished a tech. It ran on habit and steady hands.

EPI_TECH_1 | 140 | Epilogue 2, one tech done
One tech came out of the {workshop}. It is mentioned in the minutes.

EPI_TECH_2 | 140 | Epilogue 2, two techs done
Two techs came out of the {workshop}. The third is still on the board.

EPI_TECH_3 | 140 | Epilogue 2, all three techs done
All three techs came out of the {workshop}. The board has run out of things to approve.

EPI_RIVAL_MIL | 140 | Epilogue 3, a rival lost a tier in Military ({bot})
{bot} lost a tier in Military and has not come back. Its letters are shorter now.

EPI_RIVAL_LUX | 140 | Epilogue 3, a rival lost a tier in Luxury ({bot})
{bot} lost a tier in Luxury. Its masks are still worn, by fewer faces.

EPI_RIVAL_MIN | 140 | Epilogue 3, a rival lost a tier in Minerals ({bot})
{bot} lost a tier in Minerals. Its crews cut the same rock, with less to show.

EPI_RIVAL_BIO | 140 | Epilogue 3, a rival lost a tier in Biotech ({bot})
{bot} lost a tier in Biotech. Its vats run on, and its clinics ask for less.


## The Unfinished Bazaar (2026-11-06, T267, soft ending when the term ends before the Opening)
Kind, never a loss. The epilogue line is picked by stages done. Programmer: EPI_STAGES_3 is used for three or more. EPI_UNFINISHED_CAPITAL is added when a capital was founded.

END_UNFINISHED_TITLE | 40 | End screen heading, term ended before the Bazaar opened (soft ending)
The Unfinished Bazaar

END_UNFINISHED | 700 | End screen body, term ended before the Bazaar opened (soft ending)
The term is over. The Bazaar is not open, and the Bureau has written that down without any word for it. You did not lose. The crew is paid, the ships are docked, and the worlds you grew are still lit. Someone has left a lamp on in the half-built hall. The Plan will start a new five cycles. The people on the stairs go on climbing them. They have time. So do you, if you want it.

EPI_STAGES_0 | 140 | Epilogue, unfinished Bazaar, no stage done
No stage was finished. The ground is marked out, and the crew sits on it to eat.

EPI_STAGES_1 | 140 | Epilogue, unfinished Bazaar, one stage done
One stage stands. Children from the lower rings walk in and out of it.

EPI_STAGES_2 | 140 | Epilogue, unfinished Bazaar, two stages done
Two stages stand. The third is a frame, and in the evening the wind plays it.

EPI_STAGES_3 | 140 | Epilogue, unfinished Bazaar, three or more stages done
Only the last hall is missing. The roof has a gap, and the stars use it.

EPI_UNFINISHED_CAPITAL | 140 | Epilogue, unfinished Bazaar, a capital was founded; {planet}
{planet} keeps the site and keeps the lamp lit. Its people call it the Bazaar already.

## Win epilogues: capital, worlds, reclaimed world, wings (2026-11-06, T301)
Lines added to the win screen by what the run did. No counts, no lean words. {planet} is the capital. Wing lines name the wing, one per wing.

EPI_CAPITAL | 140 | Epilogue, win, the capital; {planet}
At {planet} the lamps stay on past the hour. The Bureau opens a new page for it.

EPI_WORLDS_GROWN | 140 | Epilogue, win, worlds grown
Lights burn on worlds that were dark when you came. Someone walks home along them.

EPI_RECLAIMED | 140 | Epilogue, win, a dead world was reclaimed
The grey world has a green edge now. A child there asks what the red haze was.

EPI_WING_1A | 140 | Epilogue, win, Wing of Holds
The Wing of Holds is full of crates. The Flagship sits low at its dock.

EPI_WING_1B | 140 | Epilogue, win, Wing of Reach
The Wing of Reach has a long window. From it, other systems look close.

EPI_WING_2A | 140 | Epilogue, win, Wing of Tolls
The Wing of Tolls keeps a long desk and a short queue. Everyone is counted twice.

EPI_WING_2B | 140 | Epilogue, win, Wing of Benches
The Wing of Benches smells of hot metal. The night shift has its own kettle.

EPI_WING_3A | 140 | Epilogue, win, Wing of Lamps
The Wing of Lamps has shutters for storms. When a storm comes, they stay open.

EPI_WING_3B | 140 | Epilogue, win, Wing of Couriers
The Wing of Couriers has a bell for late arrivals. It rings more than it should.

## CEO endings (2026-11-10, from design/proposals/2026-11-09-ceo-endings.md, owner approved)
A win with a matching condition shows one of these instead of END_<MKT>_GOOD or _BAD. Selection is the programmer's (ordered rows per CEO, first match wins, fallback is GOOD or BAD). The bodies are neutral. The CEO may be named. EPI_<MKT>_<KEY> is epilogue 1 under its ending; the two LEAN lines of the CEO print under any of these endings, by the hidden chain lean (GOOD or BAD), never named as such. Max body 1000, title 40, epilogue 140.

END_MIN_LONGSHIFT_TITLE | 40 | End screen heading, Marek, many Restless cycles
The Long Shift

END_MIN_LONGSHIFT | 1000 | End screen body, Marek, many Restless cycles
The Bazaar opened. On the worlds along the way, for a long while, the lights were low. Needs went unmet cycle after cycle, and people made do, because people do. Marek read every report. He did not look away from any of them. The doors are open now and the halls are full. Some of the faces in them remember the hungry cycles, and some of those faces are kind. Marek keeps the old reports in a drawer, and does not throw them out.

EPI_MIN_LONGSHIFT | 140 | Epilogue 1, Marek, many Restless cycles
Marek signs the opening page last. His hand does not shake. He holds the pen a little longer than he needs to.

END_MIN_DEEP_TITLE | 40 | End screen heading, Marek, mining platforms and a deep Minerals tree
Down the Seams

END_MIN_DEEP | 1000 | End screen body, Marek, mining platforms and a deep Minerals tree
The grey worlds are working now. Platforms sit on rock that nobody listed as home, and the crews who run them sleep with the dust on their sleeves. Marek went down to see the first cut himself. He did not say much. He picked up a handful of the stone and put it back where it was. The Bazaar stands because of what came out of the dark. Someone has to remember that, and he does.

EPI_MIN_DEEP | 140 | Epilogue 1, Marek, platforms and a deep Minerals tree
A lamp burns on a platform nobody visits. The crew who keep it call it the porch.

END_MIN_PICKUP_TITLE | 40 | End screen heading, Marek, many signals and salvage answered
The Man Who Picked Up

END_MIN_PICKUP | 1000 | End screen body, Marek, many signals and salvage answered
When the call came, Marek answered. A signal out of the dark past Ashgate, a drifting pod off Tillam, a voice asking only once. He did not always have the fuel for it. He found the fuel. The Bazaar opened on a long list of small yeses. Nobody will carve them into a wall. The ones who were answered will remember, which is how a name lasts here. The old yard man sends a note. It has one line. It says, you picked up.

EPI_MIN_PICKUP | 140 | Epilogue 1, Marek, many signals and salvage answered
Every signal on the board has the same reply scratched under it, in Marek's hand. It says, on its way.

END_MIN_THIN_TITLE | 40 | End screen heading, Marek, a small fleet
The Thin Fleet

END_MIN_THIN | 1000 | End screen body, Marek, a small fleet
You won with fewer hulls than anyone thought it could take. Every ship ran full and came home. Nothing sat at a dock, eating upkeep. The crew ate at one table all the way, and the table never grew too big to pass the bread. Marek calls it arithmetic. The crew calls it being looked after. The Bureau notes that the fleet is small and asks, politely, whether more is planned. It is not.

EPI_MIN_THIN | 140 | Epilogue 1, Marek, a small fleet
The ships are few and well used. Each has a name the crew can say without looking.

END_LUX_WIDE_TITLE | 40 | End screen heading, Idris, many worlds reached, LUX_1 learned
Everyone Knows the Smile

END_LUX_WIDE | 1000 | End screen body, Idris, many worlds reached, LUX_1 learned
Idris did not sell to one world. He sold to all of them, a little at a time, and each one told the next. By the day the Bazaar opened, a dock clerk on the farthest post knew the smile and had never seen it. Doors opened wherever your ships landed. Idris takes the credit for the smile and none for the luck. He stands in the doorway and shakes every hand, because someone made the trip.

EPI_LUX_WIDE | 140 | Epilogue 1, Idris, many worlds reached
Letters come from posts you never saw. Most say only that the writer heard the name and wanted to say hello.

END_LUX_FLEET_TITLE | 40 | End screen heading, Idris, a large fleet
A Hull for Every Guest

END_LUX_FLEET | 1000 | End screen body, Idris, a large fleet
The hangar is loud. Ships come and go all day, one for each lane, and Idris greets every pilot by name. The fleet was never cheap to keep. Ship upkeep was a weight the crew felt on every payday. But the lanes ran, and a world that waits for a ship forgives a lot. At the Opening Idris stood on the dock and counted the hulls. He lost count, and was glad.

EPI_LUX_FLEET | 140 | Epilogue 1, Idris, a large fleet
Pilots pass in the corridor and nod at each other. It is the sound of a company that is never alone.

END_LUX_FULLTABLE_TITLE | 40 | End screen heading, Idris, signals and salvage answered, few missed
A Seat Always Free

END_LUX_FULLTABLE | 1000 | End screen body, Idris, signals and salvage answered, few missed
Nothing sat unanswered on the board. Every signal found a ship, and every pod found a dock. Those who called learned that when Idris said yes, someone came, and they stopped asking twice. One table at the Bazaar stays empty at the end of the night. It is kept for whoever needs a good by morning. Idris does not call it a plan. He calls it manners.

EPI_LUX_FULLTABLE | 140 | Epilogue 1, Idris, signals and salvage answered, few missed
The empty table has a card on it. The card is blank on purpose, and someone fills it in each morning.

END_LUX_CORNER_TITLE | 40 | End screen heading, Idris, few worlds, known well
The Corner Table

END_LUX_CORNER | 1000 | End screen body, Idris, few worlds, known well
You kept to a few worlds, and you knew each one well. Idris read their boards like faces and sold to them as if each buyer were his only guest. The Bazaar stands on those few worlds, and they hold it up. The far posts never heard the name. Maybe that is the cost. Idris does not mind. He has a corner table, a clear view of the door, and a smile that never wore thin.

EPI_LUX_CORNER | 140 | Epilogue 1, Idris, few worlds
Three docks know his name, and each has kept a chair. He has not yet sat in all of them.

END_MIL_SCARS_TITLE | 40 | End screen heading, Sela, a ship was repossessed
The Hull She Lost

END_MIL_SCARS | 1000 | End screen body, Sela, a ship was repossessed
A ship was taken, and the crew felt the dock go quiet. Sela went to see the empty berth herself. She did not look away. The Bureau took what the debt asked, in its slow polite way, and left the rest. You rebuilt from what was left. The Bazaar opened with fewer hulls than the plan. The berth is still empty. Someone leaves a lamp there, and Sela does not ask who.

EPI_MIL_SCARS | 140 | Epilogue 1, Sela, a ship was repossessed
She still checks the empty berth before every long flight. The lamp is always lit.

END_MIL_NOIDLE_TITLE | 40 | End screen heading, Sela, signals and salvage answered, few missed
No Hull Sat Still

END_MIL_NOIDLE | 1000 | End screen body, Sela, signals and salvage answered, few missed
Not one signal faded on the board. Not one hull waited for a stamp it could have bought. Sela flew the worst lanes in the rim, and she learned there what a ship costs when it stands still. Now every ship moves. The Bazaar opened on time, and for once nobody checked the sky for what was coming. Sela did, from habit. She stood at the window until the last hull left the dock. Then she sat down.

EPI_MIL_NOIDLE | 140 | Epilogue 1, Sela, signals and salvage answered, few missed
The dock bell rings for a departure, not an arrival. Sela says it is the only bell worth a thought.

END_MIL_HARD_TITLE | 40 | End screen heading, Sela, many worlds explored and settled
The Long Way Round

END_MIL_HARD | 1000 | End screen body, Sela, many worlds explored and settled
The hard lanes were the ones nobody else would fly, and you flew them. The Flagship went out into the dark and came back with names. You put posts on worlds that were only a shape in the glass. Sela knew the cold out there. She did not say it was fine. She said it was worth knowing. Now the map is full of lit places that were black. Each one has a ship docked, and a crew that chose it.

EPI_MIL_HARD | 140 | Epilogue 1, Sela, many worlds explored and settled
On the chart, the first dark world you lit has a small ring drawn round it in her pencil.

END_MIL_WATCH_TITLE | 40 | End screen heading, Sela, a large fleet and calm worlds
The Night Watch

END_MIL_WATCH | 1000 | End screen body, Sela, a large fleet and calm worlds
A big fleet, and every world fed. It should have been chaos, and it was not. Sela ran the lanes like a watch: each ship on its hour, each world on its list. She slept in her chair most nights. At the Opening she took the late watch alone, as she always has, and no ship called for her. She stayed anyway. It was the first quiet night she had ever owned.

EPI_MIL_WATCH | 140 | Epilogue 1, Sela, a large fleet and calm worlds
The radio is silent. Sela leaves it on, and turns the chair a little toward it.

END_BIO_HUNGRY_TITLE | 40 | End screen heading, Tamsin, many Restless cycles
Still Writing Back

END_BIO_HUNGRY | 1000 | End screen body, Tamsin, many Restless cycles
The Bazaar opened, and on some worlds the lights had been low for a long time. Tamsin knew the clerks there. She had their cards. She read each hungry report and wrote back a line, by hand. It did not fill a hold. It did not hurt either, and it was all she had on the nights the lanes failed. The halls are full now. She still writes back. Some of the clerks write to her first.

EPI_BIO_HUNGRY | 140 | Epilogue 1, Tamsin, many Restless cycles
A stack of old reports sits by her bed. She reads one before sleep, as other people read a letter.

END_BIO_RING_TITLE | 40 | End screen heading, Tamsin, worlds grown to cities
The Ring Grows Up

END_BIO_RING | 1000 | End screen body, Tamsin, worlds grown to cities
The world you raised from a quiet dock is a city now. Tamsin walked its halls on the opening night and knew the clerks by their steps. The paperwork is friendly and the lines are short. People who were children on the stairs run the desks. She sends a card to every one. The Bazaar stands on a world that was once small enough to know by heart. She still does. It is the same world, and louder.

EPI_BIO_RING | 140 | Epilogue 1, Tamsin, worlds grown to cities
Someone has painted the old dock number on the wall of the new hall, small, by the door.

END_BIO_CARDS_TITLE | 40 | End screen heading, Tamsin, many worlds with a warm face
Every Clerk Has a Card

END_BIO_CARDS | 1000 | End screen body, Tamsin, many worlds with a warm face
Warm faces greet you at the docks. Tamsin knew the clerks, and they knew her. When a form had a flaw, a kind word fixed it. When a world ran short, someone called her first. It is not a plan the Bureau can file. It is a habit of being decent, and it carried you further than a good price would. At the Opening a dozen cards arrive by hand. Tamsin reads every name.

EPI_BIO_CARDS | 140 | Epilogue 1, Tamsin, many worlds with a warm face
The cards are pinned to a board by the door. A new one is added most days, and none is taken down.

END_BIO_PANTRY_TITLE | 40 | End screen heading, Tamsin, Space Storage used throughout
The Shelf Is Full

END_BIO_PANTRY | 1000 | End screen body, Tamsin, Space Storage used throughout
The shelves never ran bare. Food sat in the Space Storage through the lean cycles, held for the day a world asked. Tamsin counted the stock every night, and slept better for it. Some called it hoarding. The terraces that were fed from it did not. When the Bazaar opened there was still a full shelf at the back, and a note on it. The note says, for whoever is next.

EPI_BIO_PANTRY | 140 | Epilogue 1, Tamsin, Space Storage used throughout
The note on the shelf is in her hand. Underneath, in another hand, someone has written, thank you.

END_BIO_BYHAND_TITLE | 40 | End screen heading, Tamsin, routes set from the planet card
Done by Hand

END_BIO_BYHAND | 1000 | End screen body, Tamsin, routes set from the planet card
Every route was set by hand, at the planet card, with the page open and the numbers read aloud. Tamsin never trusted a lane she had not looked at. It was slower. It was also right more often than not, and when it was wrong she knew why. The Bazaar opened on lanes she can name from memory, in the order she laid them. She runs a finger down the list on the wall. It is the nearest thing to a map she has ever drawn.

EPI_BIO_BYHAND | 140 | Epilogue 1, Tamsin, routes set from the planet card
The list on the wall is in pencil. She has never once rubbed a line out.

EPI_MIN_LEAN_GOOD | 140 | Epilogue, win with a Minerals (Marek Voss) CEO ending, world turned out kind
The halls are warm, and the stone under them held. Marek stands on it a while and lets himself be glad.

EPI_MIN_LEAN_BAD | 140 | Epilogue, win with a Minerals (Marek Voss) CEO ending, world turned out cold
The halls are loud and the seams are bare. Marek counts what the rock gave, and what it was never asked for.

EPI_LUX_LEAN_GOOD | 140 | Epilogue, win with a Luxury (Idris Kane) CEO ending, world turned out kind
Doors open before the ships land. Idris says the sky is kind, and for once he is not selling anything.

EPI_LUX_LEAN_BAD | 140 | Epilogue, win with a Luxury (Idris Kane) CEO ending, world turned out cold
The smile is still on every door, but the welcome has gone cold. Idris notices who stopped saying his name.

EPI_MIL_LEAN_GOOD | 140 | Epilogue, win with a Military (Sela Oru) CEO ending, world turned out kind
The border is quiet and the dock is warm. Sela lets her shoulders drop one inch, where nobody sees.

EPI_MIL_LEAN_BAD | 140 | Epilogue, win with a Military (Sela Oru) CEO ending, world turned out cold
The racks are full and the quiet is a held breath. Sela keeps her coat on indoors.

EPI_BIO_LEAN_GOOD | 140 | Epilogue, win with a Biotech (Tamsin Hale) CEO ending, world turned out kind
The terraces answer when Tamsin calls. Every card that comes back has a warm word on it.

EPI_BIO_LEAN_BAD | 140 | Epilogue, win with a Biotech (Tamsin Hale) CEO ending, world turned out cold
The cards come back short and formal. Tamsin reads them twice and cannot find herself in them.

## The chronicle (2026-11-13, owner request: the end screen tells the run as a story, not as a list)
Built by game/end_story.gd from what the run did (Bazaar recap, run notes, the decision log). One paragraph per topic; a line with a zero count is left out. _ONE is used for a count of 1, _MANY for more ({n}). Numbers come only through placeholders.

END_STORY_HEAD | 60 | end_story.gd, the chronicle on the end screen: heading above the chronicle; {company}
What {company} leaves behind

END_STORY_HEAD_PLAIN | 60 | end_story.gd, the chronicle on the end screen: heading above the chronicle when the company has no name
What you leave behind

END_STORY_BAZAAR_WIN | 260 | end_story.gd, the chronicle on the end screen: win; {system}, {m} halls, {cycles}
The Star Bazaar stands in {system}. You raised all {m} of its halls in {cycles} cycles. On the last night the doors opened, and nobody on the dock spoke for a while.

END_STORY_BAZAAR_PART | 260 | end_story.gd, the chronicle on the end screen: run ended with the Bazaar founded and some stages done; {system}, {n}, {m}
The Star Bazaar stands in {system}, unfinished. {n} of its {m} halls have a roof. The rest are chalk lines on a cold floor, and the crews still walk around them.

END_STORY_BAZAAR_BARE | 260 | end_story.gd, the chronicle on the end screen: run ended with the Bazaar founded and no stage done; {system}, {m}
The Star Bazaar was founded in {system}, and that is all. None of its {m} halls was raised. The first stone sits alone under a work lamp.

END_STORY_BAZAAR_NEVER | 220 | end_story.gd, the chronicle on the end screen: run ended with no Bazaar founded
The Star Bazaar was never founded. Its place is still an empty berth on a Bureau map, with your name in pencil beside it.

END_STORY_WINGS_LEAD | 120 | end_story.gd, the chronicle on the end screen: lead sentence before the wing lines (EPI_WING_*)
Each hall you finished grew a wing, and you chose what it would be for.

END_STORY_WORLDS_LEAD | 160 | end_story.gd, the chronicle on the end screen: lead sentence of the worlds paragraph
The worlds on your lanes are not the worlds you found.

END_STORY_WORLDS_NONE | 200 | end_story.gd, the chronicle on the end screen: no world reached a tier
No world grew under your lanes. The docks you found are the docks you leave, and the lamps are no brighter.

END_STORY_TIER_1_ONE | 200 | end_story.gd, the chronicle on the end screen: one world at tier 1
One world is still an outpost: a dock, a lamp and a crew that knows every face.

END_STORY_TIER_1_MANY | 200 | end_story.gd, the chronicle on the end screen: {n} worlds at tier 1
{n} worlds are still outposts: a dock, a lamp and a crew that knows every face.

END_STORY_TIER_2_ONE | 220 | end_story.gd, the chronicle on the end screen: one world at tier 2
Because your ships kept coming, one outpost became a village. Children were born there who have never counted rations.

END_STORY_TIER_2_MANY | 220 | end_story.gd, the chronicle on the end screen: {n} worlds at tier 2
Because your ships kept coming, {n} outposts became villages. Children were born there who have never counted rations.

END_STORY_TIER_3_ONE | 220 | end_story.gd, the chronicle on the end screen: one world at tier 3
You raised one town. It has a market square now, and people with enough in their hands to argue in it.

END_STORY_TIER_3_MANY | 220 | end_story.gd, the chronicle on the end screen: {n} worlds at tier 3
You raised {n} towns. Each has a market square now, and people with enough in their hands to argue in it.

END_STORY_TIER_4_ONE | 220 | end_story.gd, the chronicle on the end screen: one world at tier 4
One world grew into a city. Its lights can be seen from the lane, and someone is always waiting under them.

END_STORY_TIER_4_MANY | 220 | end_story.gd, the chronicle on the end screen: {n} worlds at tier 4
{n} worlds grew into cities. Their lights can be seen from the lane, and someone is always waiting under them.

END_STORY_TIER_5_ONE | 220 | end_story.gd, the chronicle on the end screen: one world at tier 5
One world is a metropolis. It no longer remembers being small, but its oldest dock still carries your mark.

END_STORY_TIER_5_MANY | 220 | end_story.gd, the chronicle on the end screen: {n} worlds at tier 5
{n} worlds are metropolises. They no longer remember being small, but their oldest docks still carry your mark.

END_STORY_RECLAIMED_ONE | 220 | end_story.gd, the chronicle on the end screen: one dead world reclaimed
One dead world is alive again. The grey rock has a green edge, and a child there asks what the red haze was.

END_STORY_RECLAIMED_MANY | 220 | end_story.gd, the chronicle on the end screen: {n} dead worlds reclaimed
{n} dead worlds are alive again. The grey rock has a green edge, and the children there ask what the red haze was.

END_STORY_ROUTES_ONE | 160 | end_story.gd, the chronicle on the end screen: one route started in the run
You opened one route across the dark, and it carried everything.

END_STORY_ROUTES_MANY | 160 | end_story.gd, the chronicle on the end screen: {n} routes started in the run
You opened {n} routes across the dark.

END_STORY_ROUTES_CLOSED_ONE | 160 | end_story.gd, the chronicle on the end screen: one route removed
You closed one of them, and a dock went quiet.

END_STORY_ROUTES_CLOSED_MANY | 160 | end_story.gd, the chronicle on the end screen: {n} routes removed
You closed {n} of them, and each time a dock went quiet.

END_STORY_FLEET_ONE | 180 | end_story.gd, the chronicle on the end screen: peak fleet of one ship
You did it with one ship. Its crew never had a quiet cycle.

END_STORY_FLEET_MANY | 180 | end_story.gd, the chronicle on the end screen: peak fleet; {n} ships
At its largest the fleet was {n} ships, and every hull had a crew that slept in shifts.

END_STORY_REPO_ONE | 180 | end_story.gd, the chronicle on the end screen: one ship repossessed
The Bureau took one of your ships for the debt. Its crew walked home.

END_STORY_REPO_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} ships repossessed
The Bureau took {n} of your ships for the debt. Their crews walked home.

END_STORY_POSTS_ONE | 180 | end_story.gd, the chronicle on the end screen: one post or platform built
Your people built one post on rock that had nothing, and stayed to run it.

END_STORY_POSTS_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} posts and platforms built
Your people built {n} posts and platforms on rock that had nothing, and stayed to run them.

END_STORY_PERMITS_ONE | 180 | end_story.gd, the chronicle on the end screen: one permit bought
You paid the Bureau for the way into one more system, and the map grew.

END_STORY_PERMITS_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} permits bought
You paid the Bureau for the way into {n} more systems, and the map grew each time.

END_STORY_SKILLS_ONE | 180 | end_story.gd, the chronicle on the end screen: one skill learned
The company learned one skill. Somebody stayed up late for it.

END_STORY_SKILLS_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} skills learned
The company learned {n} skills. Somebody stayed up late for every one.

END_STORY_WORKS_ONE | 180 | end_story.gd, the chronicle on the end screen: one workshop, Fabric or hub built
You set up one place where things are made or handed on. The night shift there has its own kettle.

END_STORY_WORKS_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} workshops, Fabric and hubs built
You set up {n} places where things are made or handed on. Each night shift has its own kettle.

END_STORY_GIGS_ONE | 180 | end_story.gd, the chronicle on the end screen: one signal answered
The Flagship answered one signal out in the dark.

END_STORY_GIGS_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} signals answered
The Flagship answered {n} signals out in the dark.

END_STORY_GIGS_LOST_ONE | 180 | end_story.gd, the chronicle on the end screen: one signal expired
One more went quiet before it could come.

END_STORY_GIGS_LOST_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} signals expired
{n} more went quiet before it could come.

END_STORY_RESTLESS_ONE | 200 | end_story.gd, the chronicle on the end screen: one world-cycle spent Restless
Once a world ended a cycle without what it needed. The people there remember it.

END_STORY_RESTLESS_MANY | 200 | end_story.gd, the chronicle on the end screen: {n} world-cycles spent Restless (one per world per cycle)
{n} times a world ended a cycle without what it needed. The people there remember.

END_STORY_CHOICES_ONE | 180 | end_story.gd, the chronicle on the end screen: one event or gig choice made
Once the choice was yours alone, and you made it.

END_STORY_CHOICES_MANY | 180 | end_story.gd, the chronicle on the end screen: {n} event and gig choices made
{n} times the choice was yours alone, and each time you made it.

END_STORY_MOMENTS_LEAD | 120 | end_story.gd, the chronicle on the end screen: lead sentence before the decisive moments
Some cycles weighed more than the rest.

END_STORY_MOMENT | 120 | end_story.gd, the chronicle on the end screen: one decisive moment; {cycle}, {moment} (its title)
Cycle {cycle}: {moment}.

END_STORY_TOTAL | 200 | end_story.gd, the chronicle on the end screen: closing line; {n} decisions in the run
In all you made {n} decisions. Somebody lived with each of them.

END_STORY_BUSIEST | 200 | end_story.gd, the chronicle on the end screen: closing line; {cycle}, {n} decisions in that cycle
The longest day was cycle {cycle}, when you made {n} of them before the lamps went down.

END_STORY_FOOT | 120 | end_story.gd, the chronicle on the end screen: small line under the story; {cycles}, {cash}
Cycles taken: {cycles}. Final credits: {cash}.

END_KIT_AND | 12 | end_story.gd, joins world names in a list (A, B and C)
and

## Ending scene kits (2026-11-13, written by Codex at the owner's request; end_story.gd assembles <ID>_OPEN, the CEO's ENDB_<MKT>_* beats, the lean line, then <ID>_CLOSE)

END_BIO_GOOD_OPEN | 900 | End screen, The Long Harvest scene opening; no placeholders
A clinic worker lays a sheet beside the charter crate. The Star Bazaar's lamps are lit. Tamsin holds the paper flat while the worker finds a pen.

It is the cure, copied by hand. There is no licence number. Medicine and gene seed have reached terraces, fields, and clinics beyond the usual lists.

Across the hall, Velvet Concord's fine strains wait behind glass. A Bureau clerk slowly writes the Plan's name above the harvest. Tamsin keeps her palm on the sheet.

END_BIO_GOOD_CLOSE | 600 | End screen, The Long Harvest scene close; no placeholders
The clinic worker finishes a copy and passes it across. Someone else pulls a sheet of plain paper from a bag. From the culture lab comes the slow hum of the vats.

Tamsin moves her hand so they can use the table. The charter crate is empty beside them. The cure goes out folded small enough for a pocket.

END_BIO_BAD_OPEN | 900 | End screen, The Locked Seed scene opening; no placeholders
By the lab counter, a grower holds an empty seed tray. The Star Bazaar's lamps have come on. Tamsin smooths a folded ticket against the counter.

Inside the culture lab, sealed batches fill the shelves. Each needs its own ticket before it can leave. The Bureau clerk checks the grower's form, slowly and without a frown.

Velvet Concord has sent a request to copy a strain. It rests under the same glass as the grower's ticket. A shoot with a patent tag bends toward the lamp.

END_BIO_BAD_CLOSE | 600 | End screen, The Locked Seed scene close; no placeholders
The clerk slides the ticket back. "Please bring the matching copy." The grower looks from the stamp to the sealed shelf.

The clerk turns to the next form. Tamsin is still holding the returned ticket. The grower shifts the empty tray to the other arm.

END_BIO_HUNGRY_OPEN | 900 | End screen, Still Writing Back scene opening; no placeholders
A dock clerk brings an envelope into the Great Hall. People pass with plates from the opening table. The clerk waits beside Tamsin's chair, holding the envelope by its edges.

Tamsin sets the opening page aside. There are old shortfall reports beneath it, kept in the order they came. She knows the clerk's hand before she reads the name.

The clerk pulls a chair close enough to share the desk. Tamsin uncaps her pen.

END_BIO_HUNGRY_CLOSE | 600 | End screen, Still Writing Back scene close; no placeholders
The envelope holds a hungry report and a line asking after her. Tamsin reads the report again before she answers. The plates keep passing behind the clerk.

She writes a line by hand. The clerk waits for the ink, then folds the page to fit a pocket. The old reports stay beside her chair.

END_BIO_RING_OPEN | 900 | End screen, The Ring Grows Up scene opening; no placeholders
In the city you helped grow, Tamsin stops beside some old paint. The dock mark is still there, low on the wall. A clerk catches her looking and rests a hand over it.

Tamsin knows that hand. Its owner used to sit on the stairs with schoolwork. Now the clerk runs the desk, and the queue is short.

People have come from the rings to mark the Bazaar's opening. The clerk has left a space for her card by the desk. Beyond it, the new hall fills with voices.

END_BIO_RING_CLOSE | 600 | End screen, The Ring Grows Up scene close; no placeholders
Tamsin writes the clerk's name on a card and fills the waiting space. Before she goes, she touches the old paint with a fingertip. The clerk is already calling the next name.

She takes the turn toward the stairs without asking. Her hand finds the old rail before she looks down.

END_BIO_CARDS_OPEN | 900 | End screen, Every Clerk Has a Card scene opening; no placeholders
A courier sets a packet of cards on Tamsin's chair. The Star Bazaar's guests are waiting along the wall. She loosens the thread without sitting down.

She knows the clerks' writing. They have sent word about short stock and caught flaws in her forms. The top card asks her to visit without an order to place.

There is a bare board by the hall's entrance. The courier holds up the packet, then looks at the board. Tamsin asks for pins.

END_BIO_CARDS_CLOSE | 600 | End screen, Every Clerk Has a Card scene close; no placeholders
She reads each name before pressing a pin through its card. The courier reaches for the loose thread.

Tamsin takes the thread and slips it into her pocket. There is room on the board for the next card.

END_BIO_PANTRY_OPEN | 900 | End screen, The Shelf Is Full scene opening; no placeholders
At the back of Space Storage, Tamsin checks the food shelf. Music from the Bazaar's opening reaches the stock desk. A storage hand waits with Tamsin's coat over an arm.

The shelf is full. It held food through the lean stretches, when calls came from the terraces. Some called the stock hoarding. The terrace crews sent back the empty crates.

A note in Tamsin's hand hangs from the edge. It says, for whoever is next. There is a new line below it.

END_BIO_PANTRY_CLOSE | 600 | End screen, The Shelf Is Full scene close; no placeholders
The storage hand points to the new line. It says, thank you. Tamsin holds the paper steady with her thumb.

She closes the stock book and takes her coat. The note stays where a hand reaching for food will find it.

END_BIO_BYHAND_OPEN | 900 | End screen, Done by Hand scene opening; no placeholders
The Bureau clerk asks for a route map. Tamsin points to the pencil list beside the Star Bazaar's loading desk. The clerk takes a seat and turns a clean page.

She kept each planet card open as she set its route. Someone read the stock aloud. If a lane failed, she wrote why beside it. No line has been rubbed out.

The opening crowd passes behind them. Tamsin puts a finger at the top of the list. The clerk waits for her to begin.

END_BIO_BYHAND_CLOSE | 600 | End screen, Done by Hand scene close; no placeholders
Tamsin names the lanes in the order she laid them. Her finger pauses where a note crowds the margin. The clerk asks whether to copy the notes as well.

"All of it," Tamsin says. She holds the list flat while the clerk writes. Her finger waits beside the next lane.

ENDB_BIO_BAZAAR_WIN | 420 | End screen beat, completed Bazaar; {system} system name, {m} stages, {cycles} elapsed cycles
The Star Bazaar stands in {system}, raised through all {m} stages in {cycles} cycles. Tamsin kept the builders' cards from Foundations, Halls, Towers, and Great Hall. Each bears a name she can put to a face.

ENDB_BIO_BAZAAR_PART | 420 | End screen beat, partly built Bazaar; {system} system name, {n} stages completed, {m} total stages
In {system}, you founded the Star Bazaar and completed {n} of its {m} stages. Tamsin kept the cards from the crews who worked there. Their unfinished lists still have names beside each job.

ENDB_BIO_BAZAAR_BARE | 420 | End screen beat, founded Bazaar with no completed stage; {system} system name, {m} total stages
You founded the Star Bazaar in {system}. None of its {m} stages was completed. Tamsin left space on the work sheet for the building crew's names.

ENDB_BIO_BAZAAR_NEVER | 420 | End screen beat, Bazaar never founded; no placeholders
You never founded the Star Bazaar. Tamsin carried a blank site card among her clerk cards. Its corners softened with the others.

ENDB_BIO_WING_1A | 420 | End screen beat, Wing of Holds chosen, larger Flagship hold; no placeholders
The Wing of Holds gave the Flagship a larger hold. A crew packing food could leave fewer crates on the dock. Tamsin checked the new limit before changing her load sheet.

ENDB_BIO_WING_1B | 420 | End screen beat, Wing of Reach chosen, farther hub reach; no placeholders
The Wing of Reach let hubs serve worlds farther away. More dock clerks could put their needs on the same desk. Tamsin kept the distant cards beside the near ones.

ENDB_BIO_WING_2A | 420 | End screen beat, Wing of Tolls chosen, higher world tax; no placeholders
The Wing of Tolls made your worlds pay more tax. Its clerks counted the larger sums into your income. Tamsin read the receipts with the worlds' requests beside them.

ENDB_BIO_WING_2B | 420 | End screen beat, Wing of Benches chosen, lower workshop build costs; no placeholders
The Wing of Benches made new workshops cost less to build. A workshop crew could get its work space for fewer credits. Tamsin folded the new price sheet to fit behind her clerk cards.

ENDB_BIO_WING_3A | 420 | End screen beat, Wing of Lamps chosen, larger Flagship hold; no placeholders
The Wing of Lamps gave the Flagship a larger hold. More food or lab stock could travel in the same load. Tamsin marked the larger limit where the loading crew could read it.

ENDB_BIO_WING_3B | 420 | End screen beat, Wing of Couriers chosen, higher world tax; no placeholders
The Wing of Couriers raised the tax paid by your worlds. A clerk carried each larger count up the stair to the Bureau. Tamsin checked which world each payment came from before filing it.

ENDB_BIO_TIER_1_ONE | 420 | End screen beat, world still at Outpost tier; {names} is a single world name
{names} remains an Outpost. Its clerk can call the whole dock crew without using the board. Tamsin's card hangs where a shift hand can reach it.

ENDB_BIO_TIER_1_MANY | 420 | End screen beat, worlds still at Outpost tier; {n} worlds
On {n} worlds, the tier card still reads Outpost. The dock clerks know whose cup is missing from the mess. Tamsin leaves their requests beside the larger orders.

ENDB_BIO_TIER_2_ONE | 420 | End screen beat, world grown to Village tier; {names} is a single world name
Your trade helped {names} become a Village. Families live beside the growing beds now. A shift hand can wave to a child at a window on the walk back.

ENDB_BIO_TIER_2_MANY | 420 | End screen beat, worlds grown to Village tier; {names} is a ready plural list, {n} worlds
With your trade, {names} grew into {n} Villages. Homes stand beyond the loading yards. Parents coming off shift have someone to wave to at a window.

ENDB_BIO_TIER_3_ONE | 420 | End screen beat, world grown to Town tier; {names} is a single world name
Your shipments helped {names} grow into a Town. A clinic worker can finish a shift and buy supper on the way home. The clinic clerk has a desk away from the loading bench.

ENDB_BIO_TIER_3_MANY | 420 | End screen beat, worlds grown to Town tier; {names} is a ready plural list, {n} worlds
{names} became {n} Towns through the trade you brought. There are streets between their homes, clinics, and market stalls. The clerks need longer address books when they write to Tamsin.

ENDB_BIO_TIER_4_ONE | 420 | End screen beat, world grown to City tier; {names} is a single world name
You helped {names} grow into a City. People who once waited with their parents now run the supply desks. Tamsin's cards reach clerks she remembers standing on chairs to see the counter.

ENDB_BIO_TIER_4_MANY | 420 | End screen beat, worlds grown to City tier; {names} is a ready plural list, {n} worlds
{names} grew into {n} Cities with your trade. Their desk crews include people who learned their letters on old cargo slips. Tamsin has to ask which desk when a familiar voice calls.

ENDB_BIO_TIER_5_ONE | 420 | End screen beat, world grown to Metropolis tier; {names} is a single world name
{names} became a Metropolis, fed by the trade you brought. People travel between home and work without passing the old dock. Tamsin still sends her cards there, addressed to the clerk behind the old counter.

ENDB_BIO_TIER_5_MANY | 420 | End screen beat, worlds grown to Metropolis tier; {names} is a ready plural list, {n} worlds
{names} became {n} Metropolises through your trade. Whole shifts live far from the docks that brought their families. A clerk can know a district by heart and never see the whole city. Tamsin still asks after the old dock mess.

ENDB_BIO_WORLDS_NONE | 420 | End screen beat, no world grew; no placeholders
No world grew through your trade. Tamsin's clerk cards still carried the old addresses. There was no new street to write below them.

ENDB_BIO_RECLAIMED_ONE | 420 | End screen beat, dead world reclaimed; {names} is a single world name
Your supplies made {names} a living world again. The mining stopped there. People could tend growing beds instead of drawing stock from the cut. Tamsin copied "trading post" over the old platform address.

ENDB_BIO_RECLAIMED_MANY | 420 | End screen beat, dead worlds reclaimed; {names} is a ready plural list, {n} worlds
{names} are living worlds again, {n} places reclaimed with your supplies. Their mining stopped, and crews began tending beds beside the old work paths. Tamsin needed new cards for people who had come to stay.

ENDB_BIO_POSTS_ONE | 420 | End screen beat, Flagship built a trading post or mining platform; no placeholders
The Flagship built a post or platform for your company. A clerk stayed to keep the stock sheets. Tamsin wrote back until she knew that hand without the name.

ENDB_BIO_POSTS_MANY | 420 | End screen beat, Flagship built trading posts and mining platforms; {n} combined total
The Flagship built {n} trading posts and mining platforms. Each needed hands to check stock and keep the papers dry. Tamsin's card box grew heavier with their clerks' names.

ENDB_BIO_SYSTEMS_MANY | 420 | End screen beat, systems reached; {n} systems
Your company reached {n} systems. Tamsin could no longer keep every clerk's working hours in her head. She marked them on the cards before making a call.

ENDB_BIO_FLEET_ONE | 420 | End screen beat, largest fleet had a single ship; {ship} is the singular ship type name
Your fleet never grew beyond a {ship} hull. Its crew's names fitted on the back of Tamsin's card. She left room beside them for the loading shift.

ENDB_BIO_FLEET_MANY | 420 | End screen beat, largest fleet; {n} ships, {ship} is the singular ship type name
At its largest, your fleet held {n} {ship} hulls. Each had hands expecting stock sheets and a place in the loading queue. Tamsin learned to match a pilot's writing to a hull.

ENDB_BIO_ROUTES_ONE | 420 | End screen beat, route started; no placeholders
You started a route. Tamsin wrote its goods beside the receiving clerk's name. The crew could look at her page and know who would count the load.

ENDB_BIO_ROUTES_MANY | 420 | End screen beat, routes started; {n} routes
You started {n} routes. Tamsin kept the receiving clerks' names beside the goods on each line. A tired loader could find a contact without waking her.

ENDB_BIO_ROUTES_CLOSED_ONE | 420 | End screen beat, route removed, follows routes beat; no placeholders
You removed a route. Tamsin marked the change beside its old line. She waited while the loading clerk read it back.

ENDB_BIO_ROUTES_CLOSED_MANY | 420 | End screen beat, routes removed, follows routes beat; {n} routes
You removed {n} routes. Tamsin kept the old lines and wrote each change beside them. Loading clerks had to know which instructions no longer held.

ENDB_BIO_SKILLS_ONE | 420 | End screen beat, skill learned; no placeholders
Your people learned a new skill. Tamsin asked for the steps in plain words. A tired hand on the next shift would have to use them.

ENDB_BIO_SKILLS_MANY | 420 | End screen beat, skills learned; {n} skills
Your people learned {n} skills. Tamsin kept notes where the next shift could find them. The marks grew uneven when someone stayed late to finish a page.

ENDB_BIO_WORKS_ONE | 420 | End screen beat, a workshop, the Fabric, or a hub built; no placeholders
You built a place for making goods or passing stock on. Tamsin wrote the shift contact inside its stock book. A tired hand could find a name before reaching for the radio.

ENDB_BIO_WORKS_MANY | 420 | End screen beat, workshops, the Fabric, and hubs built; {n} combined total
You built {n} places to make goods or pass stock on. Each needed stock sheets and someone to answer the radio. Tamsin kept a shift contact inside the cover of each book.

ENDB_BIO_GIGS_ONE | 420 | End screen beat, signal answered by the Flagship; no placeholders
The Flagship answered a signal. Tamsin asked what the crew found before she asked what they brought back. She left their account beside the job's payment line.

ENDB_BIO_GIGS_MANY | 420 | End screen beat, signals answered by the Flagship; {n} signals
The Flagship answered {n} signals. Your crew reached the places those calls came from. Tamsin kept their accounts with the job papers, even when there was no payment to enter.

ENDB_BIO_GIGS_LOST_ONE | 420 | End screen beat, signal went quiet unanswered; no placeholders
A signal went quiet before the Flagship answered it. Tamsin kept the call with the job papers. The space for a reply stayed blank.

ENDB_BIO_GIGS_LOST_MANY | 420 | End screen beat, signals went quiet unanswered; {n} signals
{n} signals went quiet without an answer from the Flagship. Tamsin copied their calls onto a sheet she kept outside the closed jobs. She could not fill in the reply column.

ENDB_BIO_RESTLESS_ONE | 420 | End screen beat, a world ended a cycle with an unmet need; no placeholders
A world ended a cycle without what it needed. Its clerk sent the shortfall on the usual sheet. Tamsin read past the total to the line asking when more could come.

ENDB_BIO_RESTLESS_MANY | 420 | End screen beat, unmet needs counted per world per cycle; {n} occurrences, not elapsed cycles
{n} times, a world ended a cycle short of what it needed. A clerk had to count the missing stock for people waiting below. Tamsin kept those reports even after the sheets grew soft at the fold.

ENDB_BIO_RESCUES_ONE | 420 | End screen beat, relief credits kept the company alive; no placeholders
Relief credits kept the company going when it could not carry itself. Tamsin signed the receipt at the Bureau desk. The clerk checked the company name slowly, though they had known each other for years.

ENDB_BIO_RESCUES_MANY | 420 | End screen beat, relief credits kept the company alive; {n} payments
Relief credits kept the company alive {n} times. Tamsin went back to the Bureau with the papers. The clerk offered her the same chair and checked each receipt slowly.

ENDB_BIO_REPO_ONE | 420 | End screen beat, ship repossessed by the Bureau for debt; no placeholders
The Bureau repossessed a ship for debt. Its clerk asked the crew to take their time. Tamsin took the shift card from the hull's file and kept it with her own.

ENDB_BIO_REPO_MANY | 420 | End screen beat, ships repossessed by the Bureau for debt; {n} ships
The Bureau repossessed {n} ships for debt. The clerks waited while the crews took their things ashore. Tamsin kept the crew cards after the hull files passed across the desk.

ENDB_BIO_MOMENTS_LEAD | 420 | End screen beat, single sentence before the game's list of decisive moments; no placeholders
Tamsin kept these moments beside the names of the people who had to live with them.

ENDB_BIO_LEAN_GOOD | 420 | End screen beat, warm world response before the scene close on a win; no placeholders
The terrace clerks answer when Tamsin calls. Their cards ask after her before listing the stock. She smooths each card flat before putting it away.

ENDB_BIO_LEAN_BAD | 420 | End screen beat, cold world response before the scene close on a win; no placeholders
The cards still come back, with stock lists and the right stamps. They address Tamsin by her full name. She runs her finger down a margin where there used to be a note.

END_UNFINISHED_OPEN | 900 | End screen, term ended before the Bazaar opened; {company}, {ceo} is the CEO's full name; no Bazaar site assumed
The Bureau's notice lies on the control post table. The term is over. The Star Bazaar has not opened.

{ceo} sets the work record of {company} beside the notice. The crew has been paid. They sit down in their work coats. Someone shifts a cup to make room for the page.

You draw your chair closer. Someone holds the page flat while you read.

END_UNFINISHED_CLOSE | 600 | End screen, after any subset of CEO beats for the unfinished ending; {ceo} is the CEO's full name
The hand lifts from the page. {ceo} reaches for the cover, then leaves the book open. You put the Bureau's notice under the cup.

Beyond the glass, the dock lamps still burn. The next shift comes in with coats over their arms. You pull up a chair for them.

END_BANKRUPT_OPEN | 900 | End screen, no fleet ships left and credits still negative; {company}, {ceo} is the CEO's full name
The Bureau clerk sets the ledger on a square of felt. {ceo} sits beside you at the desk. The clerk reads the name {company} and waits for you to nod.

Each cycle, the Bureau took the newest hull. The fleet is gone, and the company still owes credits. The ships are listed in the Common Ledger now.

The clerk lays the last form beside the book. Before you sign, the record of the company's work must be read. The clerk smooths the page and begins.

END_BANKRUPT_CLOSE | 600 | End screen, after any subset of CEO beats, the last bankruptcy form is signed; {ceo} is the CEO's full name
The clerk turns the form toward you. Your new quota is the same as everyone else's. The clerk reads the line that says nothing was owed to you. Then the pen is set within reach.

You sign. {ceo} holds your copy flat while the ink dries. The clerk sets the closed ledger back on its square of felt. Beyond the glass, the freight lights keep their pace.

END_LUX_GOOD_OPEN | 900 | End screen, The Lit Gallery, opening; {company} and {ceo} optional
A child stands beneath the gallery lamps, holding a festival mask. There is a food stain on its silk tie. Idris kneels to look.

The Star Bazaar has taken in the charter cargo. Its bright cloth is still spread beside the crate. Dock cooks browse the display tables beside teachers. Their work bags rest against the table legs.

A Bureau clerk waits with a form for lending beautiful things. The line for who may borrow them is blank. The child holds the mask out.

END_LUX_GOOD_CLOSE | 600 | End screen, The Lit Gallery, closing; {company} and {ceo} optional
Idris takes the mask and rubs the stain with his thumb. It stays.

The clerk asks who should be allowed to borrow it. Idris looks at the child. The child has already reached for it again.

He hands it back. The clerk folds the blank form and puts the pen away.

END_LUX_BAD_OPEN | 900 | End screen, The Gilded Cage, opening; {company} and {ceo} optional
The vault guard asks Idris to hold out his hands. Behind the glass, gems catch the gold light. The guard knows his face. The check takes its time.

A buyer waits outside with a price slip. There are crossed-out prices beneath the latest line. Their own guard waits on the stair. These pieces cannot be bought elsewhere.

The Star Bazaar is open. A Bureau clerk has come to list the locks. Idris smiles and waits for the vault guard to let him pass.

END_LUX_BAD_CLOSE | 600 | End screen, The Gilded Cage, closing; {company} and {ceo} optional
The vault guard steps aside. Idris walks between the cases, his hands held clear of the glass.

The clerk asks, very gently, whether the list includes the inner lock. Idris turns. The vault guard has followed him in.

Outside, the buyer presses the price slip flat against the pane. Idris lowers his empty hands.

END_LUX_WIDE_OPEN | 900 | End screen, Everyone Knows the Smile, opening; {company} and {ceo} optional
The guest brings a folded list to the Star Bazaar. Idris meets them on the step.

They say his name before he gives it. At their far trading post, people knew the smile from other people's stories. Their clerk has sent them to meet it.

Behind them, the charter cloth lies beside its broken seal. Voices from other posts cross the hall. Idris holds out his hand. The guest moves the list so they can take it.

END_LUX_WIDE_CLOSE | 600 | End screen, Everyone Knows the Smile, closing; {company} and {ceo} optional
The guest unfolds the list. Idris lets the next hand wait while he reads the world names.

"Which dock?" he asks.

The guest points. Idris pulls a chair onto the step for them. He stays beside it, greeting each person who made the trip.

END_LUX_FLEET_OPEN | 900 | End screen, A Hull for Every Guest, opening; {company} and {ceo} optional
Idris has taken a piece of chalk to the hangar rail. Each passing hull gets a mark. The pay clerk leans beside him, holding the ship upkeep sheet.

The Star Bazaar is taking guests. A pilot crosses the hangar still wearing flight gloves. Idris greets them by name, then turns back to the glass.

Engines sound through the rail beneath his hand. The chalk hovers above a mark he may have made already.

END_LUX_FLEET_CLOSE | 600 | End screen, A Hull for Every Guest, closing; {company} and {ceo} optional
Idris has lost his place in the count. He wipes the chalk on his coat and gives the pilot his hand.

Beyond the glass, hulls pass on the lanes. He leaves the marks unfinished. He knows the names coming over the radio.

END_LUX_FULLTABLE_OPEN | 900 | End screen, A Seat Always Free, opening; {company} and {ceo} optional
A server sets a blank card on a table at the Bazaar. Idris turns it so it faces the room.

Guests have come with old signal slips in their pockets. Some brought parcels. Others brought nothing they could sell. Idris makes room for their coats.

The server asks whose table this is. Idris draws the spare chair back, but does not sit.

END_LUX_FULLTABLE_CLOSE | 600 | End screen, A Seat Always Free, closing; {company} and {ceo} optional
A guest stops beside the blank card. "I need a cargo by morning," they say. The server reaches for a pen.

Idris lays a hand on the chair. "Sit while you tell us."

The guest takes off their coat. Idris slides the card across for them to write their name.

END_LUX_CORNER_OPEN | 900 | End screen, The Corner Table, opening; {company} and {ceo} optional
The table is tucked into a corner of the Star Bazaar. From his chair, Idris can see each guest arrive.

A dock clerk has brought a board from home. Its edges are worn where Idris used to rest his hands. The clerk lays it beside his plate and waits.

There are few world names on it. Idris has bought lunch for people at each of them. The clerk taps a line with a finger.

END_LUX_CORNER_CLOSE | 600 | End screen, The Corner Table, closing; {company} and {ceo} optional
Idris reads the line the clerk is pointing to. Then he asks after the person who wrote it.

At the far posts, clerks still ask how to spell his name. Here, the server sets down his usual meal without asking.

He moves his plate aside so the clerk can sit.

ENDB_LUX_BAZAAR_WIN | 420 | End screen, Idris, completed Bazaar; {system} system, {m} stages, {cycles} elapsed cycles
In {system}, your Star Bazaar is built. Your crews raised all {m} stages in {cycles} cycles. They laid the Foundations, built the Halls and Towers, and roofed the Great Hall. A loader sets a silk parcel on a counter once marked only in chalk.

ENDB_LUX_BAZAAR_PART | 420 | End screen, Idris, founded Bazaar; {system} system, {n} stages done, {m} total stages
You founded the Star Bazaar in {system} and raised {n} of its {m} stages. Idris kept the plans weighted with a buyer's sample case. Workers ate beside those plans and traced where their counters would go.

ENDB_LUX_BAZAAR_BARE | 420 | End screen, Idris, founded Bazaar with no completed stage; {system} system, {m} total stages
You founded the Star Bazaar in {system}, with {m} stages to build. No stage is built. Idris laid samples across the plans while builders took measurements. The crew had a site to point to, even without a hall to stand in.

ENDB_LUX_BAZAAR_NEVER | 420 | End screen, Idris, Bazaar never founded; no specific placeholders
The Star Bazaar stayed among Idris's sketches. He kept them with the price slips he took to lunch. Buyers who asked for a stall could point to a drawing, but could not stand there.

ENDB_LUX_WING_1A | 420 | End screen, Idris, Wing of Holds and larger Flagship hold; no specific placeholders
At the Wing of Holds, wide racks were built for the Flagship's cargo. Its hold grew larger. Loaders could fit more of a buyer's order under the same hatch.

ENDB_LUX_WING_1B | 420 | End screen, Idris, Wing of Reach and longer hub reach; no specific placeholders
You raised the Wing of Reach, with signal masts above its gallery. Hubs could reach farther. Clerks farther from a hub could put its deliveries on their boards.

ENDB_LUX_WING_2A | 420 | End screen, Idris, Wing of Tolls and higher world tax; no specific placeholders
The Wing of Tolls gave the clerks a hall for their counts. Worlds paid more tax to your company. Idris waited while each world clerk checked the sum again.

ENDB_LUX_WING_2B | 420 | End screen, Idris, Wing of Benches and cheaper workshop construction; no specific placeholders
You raised the Wing of Benches, a room of shared tools. New workshops cost less to build. Idris could leave more credits for the stock their crews would need.

ENDB_LUX_WING_3A | 420 | End screen, Idris, Wing of Lamps and larger Flagship hold; no specific placeholders
The Wing of Lamps put light over the Flagship's loading dock. Its hold grew larger. Crews could lay out more of Idris's parcels before deciding what would fit.

ENDB_LUX_WING_3B | 420 | End screen, Idris, Wing of Couriers and higher world tax; no specific placeholders
The Wing of Couriers gave the worlds a stair for sending up their accounts. Your company took more tax from those worlds. A courier held the folded sheet flat while Idris checked what each name now owed.

ENDB_LUX_TIER_1_ONE | 420 | End screen, Idris, world still at Outpost; {names} is a single world name
{names} is still an Outpost. A dock hand there keeps a jar for blooms beside the bunk. Buyers write the names of the people who will carry their parcels home. Idris keeps those names on the wrapping.

ENDB_LUX_TIER_1_MANY | 420 | End screen, Idris, worlds still at Outpost; {n} worlds, no names supplied
{n} worlds remain Outposts. At their posts, a buyer still knows who will carry each parcel home. Idris writes the names on the wrapping, even when the order only asks for blooms.

ENDB_LUX_TIER_2_ONE | 420 | End screen, Idris, world grown to Village; {names} is a single world name
{names} is a Village now, grown through your trade. Dock hands have homes beyond the shift rooms. A child waits at a kitchen table while a parent trims blooms for the market.

ENDB_LUX_TIER_2_MANY | 420 | End screen, Idris, worlds grown to Village; {names} is a plural ready list, {n} worlds
{names} are Villages now, {n} worlds grown through your trade. Dock hands have homes beyond the shift rooms. Children wait at kitchen tables while their parents trim blooms for market. The price board shares a wall with notices for lessons.

ENDB_LUX_TIER_3_ONE | 420 | End screen, Idris, world grown to Town; {names} is a single world name
{names} has become a Town through your trade. Cloth sellers live above their stalls, away from the loading shifts. A tailor's child gives directions by streets missing from Idris's early maps.

ENDB_LUX_TIER_3_MANY | 420 | End screen, Idris, worlds grown to Town; {names} is a plural ready list, {n} worlds
{names} are Towns now, {n} places your trade helped raise. Cloth sellers live above their stalls. Their children walk to lessons past street signs Idris no longer knows by heart.

ENDB_LUX_TIER_4_ONE | 420 | End screen, Idris, world grown to City; {names} is a single world name
With your trade, {names} grew into a City. Dressmakers and dock crews live along streets that run beyond the port. A worker takes a parcel across town for a sister's wedding. Idris has to ask which way.

ENDB_LUX_TIER_4_MANY | 420 | End screen, Idris, worlds grown to City; {names} is a plural ready list, {n} worlds
{names} are Cities now, {n} worlds grown through your trade. Dressmakers share streets with dock crews and teachers. A wedding parcel can cross a whole district without passing the port. Idris asks for street names with his orders.

ENDB_LUX_TIER_5_ONE | 420 | End screen, Idris, world grown to Metropolis; {names} is a single world name
{names} became a Metropolis through your trade. Whole districts make and mend what once came through a dock counter. A silk worker rides home past streets where nobody knows the company name. There is a place set for them there.

ENDB_LUX_TIER_5_MANY | 420 | End screen, Idris, worlds grown to Metropolis; {names} is a plural ready list, {n} worlds
{names} are Metropolises now, {n} worlds your trade helped raise. Families live far beyond the old docks, among shops Idris has never visited. After a shift among silk rolls, a worker rides home through streets full of other lives.

ENDB_LUX_WORLDS_NONE | 420 | End screen, Idris, no world grew; no specific placeholders
No world grew through your trade. Idris kept looking from the price slips to the dock. At your posts, the same shift rooms held the same bunks. There was no new street beyond them.

ENDB_LUX_RECLAIMED_ONE | 420 | End screen, Idris, dead world reclaimed; {names} is a single world name
You brought life back to the dead world {names}. No more cargo would be mined there. A loader put a work coat on a hook at home. Idris sent blooms for the table.

ENDB_LUX_RECLAIMED_MANY | 420 | End screen, Idris, dead worlds reclaimed; {names} is a plural ready list, {n} worlds
{names} are living worlds again, {n} places with homes on the old mining ground. Crews hang their work coats beside kitchen shelves. Idris used to ask what could be taken out. The orders now carry blooms for people staying there.

ENDB_LUX_POSTS_ONE | 420 | End screen, Idris, a trading post or mining platform built by the Flagship; no specific placeholders
The Flagship built a place for trade or mining. A crew kept its cargo desk and put your company stamp beside it. Idris had a name to ask for when he called.

ENDB_LUX_POSTS_MANY | 420 | End screen, Idris, trading posts and mining platforms built by the Flagship; {n} combined total
The Flagship built {n} trading posts and mining platforms. Crews kept the cargo desks and the stock lists there. Idris learned who to ask for before he asked the price.

ENDB_LUX_SYSTEMS_MANY | 420 | End screen, Idris, company reach; {n} systems, at least two
Your company reached {n} systems. Price slips crossed those gaps, each with a clerk's hand in the margin. Idris learned how long a reply could take when the buyer lived under another sun.

ENDB_LUX_FLEET_ONE | 420 | End screen, Idris, peak fleet of a single ship; {ship} is a singular ship type name
At its largest, your fleet was a lone {ship}. Idris could put a buyer's whole order against the space in that hold. The crew heard what he promised before they packed it.

ENDB_LUX_FLEET_MANY | 420 | End screen, Idris, peak fleet; {n} ships, {ship} is a singular ship type name
At its largest, your fleet held {n} {ship} hulls. Idris could offer cargo space before a buyer finished asking. The crews waited by the pay desk while the ship upkeep sheet was read.

ENDB_LUX_ROUTES_ONE | 420 | End screen, Idris, a route started; no specific placeholders
You started a route. Idris could trace a cargo's planned journey beside its price. The crew checked that line before tying the parcels.

ENDB_LUX_ROUTES_MANY | 420 | End screen, Idris, routes started; {n} routes
You started {n} routes. On Idris's sheets, cargo had places to go as well as prices. Crews checked those lines before tying the parcels.

ENDB_LUX_ROUTES_CLOSED_ONE | 420 | End screen, Idris, a route removed, after routes beat; no specific placeholders
You removed a route from the plan. Idris crossed its arrival off his working sheet. A clerk had to be told that cargo would no longer come that way.

ENDB_LUX_ROUTES_CLOSED_MANY | 420 | End screen, Idris, routes removed, after routes beat; {n} routes
You removed {n} routes from the plan. Idris crossed their arrivals off his working sheets. Dock clerks had to be told which arrivals to rub off their boards. He left room for their replies.

ENDB_LUX_SKILLS_ONE | 420 | End screen, Idris, a skill learned; no specific placeholders
Your people learned a new skill. Idris tried the lesson on the back of a price slip. A crew hand checked it before he used it on an order.

ENDB_LUX_SKILLS_MANY | 420 | End screen, Idris, skills learned; {n} skills
Your people learned {n} skills. Lessons shared space with Idris's price slips. When a lesson worked, a crew hand passed the marked page along.

ENDB_LUX_WORKS_ONE | 420 | End screen, Idris, a workshop, Fabric or hub built; no specific placeholders
You built a place where goods could be made or passed on. Idris took a buyer's sample to the new work desk. The people there checked the stock before they heard his price.

ENDB_LUX_WORKS_MANY | 420 | End screen, Idris, workshops, Fabric and hubs built; {n} combined total
You built {n} places for making goods or passing them on. Idris carried samples between their desks. The people working there knew what was missing from an order before he could finish reading it.

ENDB_LUX_GIGS_ONE | 420 | End screen, Idris, a signal answered by the Flagship; no specific placeholders
The Flagship reached a signal sent into the dark. Idris wrote the reply on the board before he filed the cargo slips. There was a voice behind that line, even if the call was old.

ENDB_LUX_GIGS_MANY | 420 | End screen, Idris, signals answered by the Flagship; {n} signals
{n} signals brought the Flagship off its usual work. Idris filed their replies beside his orders. On those pages, people had asked for more than a price.

ENDB_LUX_GIGS_LOST_ONE | 420 | End screen, Idris, a signal went quiet unanswered; no specific placeholders
A signal went quiet without an answer from your Flagship. Idris kept its last mark on the board. He could say where the ship had been. He could not say who was still listening.

ENDB_LUX_GIGS_LOST_MANY | 420 | End screen, Idris, signals went quiet unanswered; {n} signals
The board lost {n} signals before your Flagship could answer. Idris kept their last known positions beside the orders he had filled. The pages did not say whether anyone still waited.

ENDB_LUX_RESTLESS_ONE | 420 | End screen, Idris, a world-cycle with an unmet need; no specific placeholders
A world ended a cycle short of what it needed. Idris read the need sheet beside the sales. At a dock counter, someone folded an order slip and put it back in a pocket.

ENDB_LUX_RESTLESS_MANY | 420 | End screen, Idris, unmet needs; {n} occurrences counted per world per cycle, not elapsed cycles
{n} times, a world ended a cycle without all it needed. The same world could appear on that list again. Idris read it beside the sales, with a thumb holding each page flat. At the counters, people kept order slips for cargo that had not come.

ENDB_LUX_RESCUES_ONE | 420 | End screen, Idris, relief credits kept the company alive; no specific placeholders
Relief credits kept the company going when it could not carry itself. Idris signed the receipt without his usual talk. The crew waited until it was stamped before they unpacked their work things.

ENDB_LUX_RESCUES_MANY | 420 | End screen, Idris, relief credits kept the company alive; {n} occasions
Relief credits kept the company going {n} times. Idris held his hand over the same line on each form. Each time, the crew waited for the stamp before setting out their work things.

ENDB_LUX_REPO_ONE | 420 | End screen, Idris, a ship repossessed for debt; no specific placeholders
The Bureau took a ship against the company's debt. Its clerk waited while the crew brought their things ashore. Idris stood beside the cargo ramp. There was no price left for him to discuss.

ENDB_LUX_REPO_MANY | 420 | End screen, Idris, ships repossessed for debt; {n} ships
The Bureau took {n} ships against the company's debt. The clerks read the forms slowly and let each crew collect its things. Idris learned to leave a space beside the ramp for the bags.

ENDB_LUX_MOMENTS_LEAD | 420 | End screen, Idris, single sentence before the decisive-moments list; no specific placeholders
Idris stops turning pages when he reaches these entries in the company book.

ENDB_LUX_LEAN_GOOD | 420 | End screen, Idris, warm response from the worlds, before win closing; no specific placeholders
Across your worlds, clerks say Idris's name before they ask for his order. A place is made at their tables while his ships are still coming in. He leaves the prices out of his reply.

ENDB_LUX_LEAN_BAD | 420 | End screen, Idris, cold response from the worlds, before win closing; {company} company name
Across your worlds, the smile still marks the company counters. Replies come addressed to {company}, with no word for Idris. He reads past the heading, then moves his thumb back to it.

END_MIL_GOOD_OPEN | 900 | End screen, The Quiet Fleets, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
A garrison courier waits by the new hall's notice board. He has brought a letter for {company}. Sela Oru clears a patch of the long table for him.

The fleets you supply stood at the border without firing. The quarrel stopped when they arrived. Crews from the post check the terms with their fingers.

The Bureau clerk sets down the supplier record. She waits for Sela to finish reading the letter.

END_MIL_GOOD_CLOSE | 600 | End screen, The Quiet Fleets, scene close; {company} company, {ceo} full CEO name
The letter begins with thanks. Beneath it, the garrison has listed what it needs next.

Sela smooths the page where the courier's thumb held it. She puts the request beside the terms, where anyone can read. He pulls up a chair and helps her check it.

END_MIL_BAD_OPEN | 900 | End screen, The Full Racks, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
The racks of arms along the new hall are full. A depot clerk lays an order book before Sela Oru. His thumb holds her place while the Bureau clerk waits.

{company} is entered as supplier of record. Fleets wait for cargo, then follow the latest paid order. At a border post, the flags of either side share a purchase order.

The Bureau clerk asks for copies before the next dispatch. Sela reaches for the book. The depot clerk keeps his thumb on the page.

END_MIL_BAD_CLOSE | 600 | End screen, The Full Racks, scene close; {company} company, {ceo} full CEO name
The depot clerk says the copies cannot be sent. The Bureau clerk thanks him and leaves her request to be filed.

A loader brings a crate for the border post. Sela looks for its flag on the order. The clerk puts his finger on the line that says who paid.

END_MIL_SCARS_OPEN | 900 | End screen, The Hull She Lost, repossession win, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
Someone has left a lamp in the empty berth. Sela Oru walks past the new hall to reach it. She stops where a hull used to hide the far wall.

The Bureau took a ship against your debt. The clerk read the form slowly and waited for each name. Sela stood here while the crew carried their bags ashore.

The crews rebuilt from what the Bureau left. The Bazaar stands, with a hull still missing from her old plan. A dock hand waits with a fresh charge for the lamp.

END_MIL_SCARS_CLOSE | 600 | End screen, The Hull She Lost, scene close; {company} company, {ceo} full CEO name
The dock hand bends to lift the lamp. Sela steps aside so he can change its charge.

He sets it back where the gangway used to rest. She checks that it is lit before she goes. She does not ask who keeps it there.

END_MIL_NOIDLE_OPEN | 900 | End screen, No Hull Sat Still, many signals answered and few missed, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
The departure bell reaches Sela Oru through the hall's glass. She turns before the guests do. A loaded hull is moving clear of the dock.

The charter cargo is in. The Bazaar opened within its term. Out on the lanes, your crews kept going when signals came. Calls rarely faded without an answer.

A dock hand brings her a chair. She rests her palm on its back and watches the hull.

END_MIL_NOIDLE_CLOSE | 600 | End screen, No Hull Sat Still, scene close; {company} company, {ceo} full CEO name
The last departure clears the glass. The dock hand leaves the chair where she can see the lanes.

Sela checks the sky beyond the ship, then the space behind it. The bell falls still. She sits. Her palms lie flat on her knees.

END_MIL_HARD_OPEN | 900 | End screen, The Long Way Round, many worlds explored and established, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
The chart will not lie flat on the new table. Sela Oru holds its curled edge with her wrist. A worn pencil rests beside a ring round a distant world.

The Flagship found the way to places no clerk could name. Your crews built posts there and stayed. Their calls have come through to the Bazaar.

Someone asks Sela to mark the route for the next crew. She puts her pencil on the old ring.

END_MIL_HARD_CLOSE | 600 | End screen, The Long Way Round, scene close; {company} company, {ceo} full CEO name
Sela draws the route slowly enough for the waiting pilot to copy. She marks where the long cold stretch begins.

The pilot asks what it is like out there. She rests her finger on the ring. "There are people there now," she says.

END_MIL_WATCH_OPEN | 900 | End screen, The Night Watch, large peak fleet and few unmet needs, scene opening; {company} company, {ceo} full CEO name, {system} Bazaar system
The late watch has a chair turned toward the radio. Sela Oru takes it while the hall is still full. Someone sets a cup beside her.

Your fleet grew, and the worlds rarely had to wait for supplies. Sela kept a list for each watch. The crews have worked through those lists.

The lamps are on in the Bazaar. A dock hand asks whether she wants the radio turned down. She shakes her head.

END_MIL_WATCH_CLOSE | 600 | End screen, The Night Watch, scene close; {company} company, {ceo} full CEO name
The cup has gone cold. Sela wraps her hands round it without drinking.

No ship calls. She turns the chair a little nearer the radio. She leaves it on and loosens her grip on the cup.

ENDB_MIL_BAZAAR_WIN | 420 | End screen beat, finished Bazaar, win only; {system} site system, {m} total stages, {cycles} cycles taken
The Star Bazaar stands in {system}, all {m} stages raised in {cycles} cycles. Your crews signed off the Foundations, Halls, Towers and Great Hall. A builder sets her gloves beside a powder rack, clear of the loading shift.

ENDB_MIL_BAZAAR_PART | 420 | End screen beat, founded Bazaar with stages completed; {system} site system, {n} completed stages, {m} total stages
You founded the Star Bazaar in {system}. Your crews completed {n} of its {m} stages. Sela kept the unfinished loads on a separate sheet. A crew can point to each finished part and say who worked there.

ENDB_MIL_BAZAAR_BARE | 420 | End screen beat, founded Bazaar with no stage completed; {system} site system, {m} total stages
You marked the Star Bazaar site in {system}. None of its {m} stages has been built. Sela put the first load on her sheet. The crew knew where to put cargo before there was a floor.

ENDB_MIL_BAZAAR_NEVER | 420 | End screen beat, Bazaar never founded; no special placeholders
No Star Bazaar site bears your company's name. Sela kept a clean sheet for its first cargo list. There is no shared hall where the far posts can meet.

ENDB_MIL_WING_1A | 420 | End screen beat, Wing of Holds chosen, larger Flagship hold; no special placeholders
The Wing of Holds gave the Flagship a bigger hold. Sela checked the space with a loader's tape. There was room for cargo that would once have waited ashore.

ENDB_MIL_WING_1B | 420 | End screen beat, Wing of Reach chosen, longer hub reach; no special placeholders
The Wing of Reach let your hubs serve farther worlds. Sela drew the wider reach on the supply charts. Dock crews beyond the old line could ask a hub for what they lacked.

ENDB_MIL_WING_2A | 420 | End screen beat, Wing of Tolls chosen, higher world tax; no special placeholders
The Wing of Tolls raised the tax your worlds paid. A clerk read the higher sum to a dock hand. He took the receipt back to the crew who had sent him.

ENDB_MIL_WING_2B | 420 | End screen beat, Wing of Benches chosen, lower workshop build cost; no special placeholders
The Wing of Benches made new workshops cost less to build. Sela kept the lower build bills with her spare plans. A crew needed fewer credits before it could set its tools down.

ENDB_MIL_WING_3A | 420 | End screen beat, Wing of Lamps chosen, larger Flagship hold; no special placeholders
The Wing of Lamps added more room to the Flagship's hold. Loaders could fit a larger cargo beneath its straps. Sela checked where each crate would sit before she signed the loading sheet.

ENDB_MIL_WING_3B | 420 | End screen beat, Wing of Couriers chosen, higher world tax; no special placeholders
The Wing of Couriers raised the tax your worlds paid. Bureau clerks carried the counts up its stair. A crew down below waited for its copy before going back to work.

ENDB_MIL_TIER_1_ONE | 420 | End screen beat, world still at Outpost; {names} single world name
{names} is still an Outpost. Its dock crew know whose bunk is empty on each watch. The lamp over the scales lights faces they all know.

ENDB_MIL_TIER_1_MANY | 420 | End screen beat, worlds still at Outpost; {n} world count
{n} worlds are still Outposts. The dock crews there still know every name on their shift. On Sela's supply sheets, each small post takes a line of its own.

ENDB_MIL_TIER_2_ONE | 420 | End screen beat, world grown to Village; {names} single world name
{names} grew into a Village as your loads reached it. Homes spread beyond the rooms kept for visiting crews. A loader can finish a shift and walk to a kitchen of her own.

ENDB_MIL_TIER_2_MANY | 420 | End screen beat, worlds grown to Village; {names} ready world list with plural verb, {n} world count
{names} grew into {n} Villages as your loads reached them. Homes spread beyond the rooms kept for visiting crews. Loaders began ending their shifts at tables their families had set.

ENDB_MIL_TIER_3_ONE | 420 | End screen beat, world grown to Town; {names} single world name
{names} became a Town with the trade you brought. The depot is no longer the only place to find work. A fitter can send her child to school before taking a shift.

ENDB_MIL_TIER_3_MANY | 420 | End screen beat, worlds grown to Town; {names} ready world list with plural verb, {n} world count
{names} became {n} Towns with the trade you brought. The depots are no longer the only places to find work. Fitters can send their children to school before taking a shift.

ENDB_MIL_TIER_4_ONE | 420 | End screen beat, world grown to City; {names} single world name
{names} grew into a City on the goods your crews brought. A depot fitter rides home past streets that were blank on Sela's chart. At his stop, people are already waiting to ride to the next shift.

ENDB_MIL_TIER_4_MANY | 420 | End screen beat, worlds grown to City; {names} ready world list with plural verb, {n} world count
{names} grew into {n} Cities on the goods your crews brought. Depot fitters ride home past streets that were blank on Sela's charts. At each stop, people are already waiting to ride to the next shift.

ENDB_MIL_TIER_5_ONE | 420 | End screen beat, world grown to Metropolis; {names} single world name
{names} became a Metropolis through the trade you kept bringing. Whole districts have grown beyond sight of the docks. People rent homes there without ever asking which ship will take them away.

ENDB_MIL_TIER_5_MANY | 420 | End screen beat, worlds grown to Metropolis; {names} ready world list with plural verb, {n} world count
{names} became {n} Metropolises through the trade you kept bringing. Whole districts have grown beyond sight of the docks. People rent homes there without ever asking which ship will take them away.

ENDB_MIL_WORLDS_NONE | 420 | End screen beat, no world grew at all; no special placeholders
No world rose to a new tier through your trade. Sela's supply charts have no larger settlements to mark. The dock crews worked among the same bunks and loading racks they knew before.

ENDB_MIL_RECLAIMED_ONE | 420 | End screen beat, dead world brought back to life; {names} single reclaimed world name
{names} came back to life with the supplies you sent. The mining platform became a trading post. A cook wrote a meal list where the mining shifts had been.

ENDB_MIL_RECLAIMED_MANY | 420 | End screen beat, dead worlds brought back to life; {names} ready world list with plural verb, {n} reclaimed world count
{names} are living worlds again. You brought {n} dead worlds back with supplies. Their mining platforms became trading posts, with cooks setting meal tables in the old tool rooms.

ENDB_MIL_POSTS_ONE | 420 | End screen beat, Flagship built a trading post or mining platform; no special placeholders
Your Flagship built a place for a trading or mining crew. Sela checked its supply list before she checked the build stamp. People had to live beside the work once the ship flew on.

ENDB_MIL_POSTS_MANY | 420 | End screen beat, trading posts and mining platforms built by Flagship; {n} combined count
The Flagship built {n} trading posts and mining platforms. Sela checked their supply lists before she checked the build stamps. Each mark on the chart meant a crew who had stayed behind.

ENDB_MIL_SYSTEMS_MANY | 420 | End screen beat, systems reached, at least a pair; {n} system count
Your company reached {n} systems. Sela kept a supply chart for each stretch beyond the jump. The next crew out could ask someone what waited on the other side.

ENDB_MIL_FLEET_ONE | 420 | End screen beat, largest fleet held a single ship; {ship} singular ship type name
The fleet never grew beyond a {ship} hull. Sela had to fit each route around what that ship could carry. When it came in, the dock crew knew whose boots would reach the gangway.

ENDB_MIL_FLEET_MANY | 420 | End screen beat, largest fleet, not final fleet; {n} peak ship count, {ship} singular ship type name
At its largest, your fleet held {n} {ship} hulls. Sela kept spare plans for a ship that failed to arrive. More crews had a berth to find when their watch was done.

ENDB_MIL_ROUTES_ONE | 420 | End screen beat, route started; no special placeholders
You started a cargo route. Sela read its load sheet and kept a spare plan. At either end, someone could ask when the ship would come.

ENDB_MIL_ROUTES_MANY | 420 | End screen beat, routes started; {n} route count
You started {n} cargo routes. Sela read their load sheets and kept spare plans. Behind each line on the chart were people waiting to load or unload.

ENDB_MIL_ROUTES_CLOSED_ONE | 420 | End screen beat, route removed, follows routes started; no special placeholders
You removed a route from the chart. Sela kept its old load sheet with a line through it. A loading crew no longer had that ship on its list.

ENDB_MIL_ROUTES_CLOSED_MANY | 420 | End screen beat, routes removed, follows routes started; {n} removed route count
You removed {n} routes from the chart. Sela kept the old load sheets with lines through them. Crews had to check the new lists before they set cargo out.

ENDB_MIL_SKILLS_ONE | 420 | End screen beat, skill learned; no special placeholders
Your people learned a skill they had not brought aboard. Sela made room for it in the crew's notes. Someone else could follow the steps without waiting for the hand who knew them.

ENDB_MIL_SKILLS_MANY | 420 | End screen beat, skills learned; {n} learned skill count
Your people learned {n} skills. The notes have grease marks where a tired hand held them. Sela had the pages copied for the next watch.

ENDB_MIL_WORKS_ONE | 420 | End screen beat, workshop, Fabric or hub built; no special placeholders
You built a place to make goods or send them onward. Sela put its work on the supply plan. People had somewhere to report for a shift.

ENDB_MIL_WORKS_MANY | 420 | End screen beat, workshops, Fabric and hubs built; {n} combined building count
You built {n} places to make goods or send them onward. Sela put their shifts beside the fleet's load lists. People had somewhere to report for work.

ENDB_MIL_GIGS_ONE | 420 | End screen beat, signal answered by Flagship; no special placeholders
The Flagship went to a signal from beyond the trade lanes. Sela took its bearing before she read the next load sheet. Your crew saw what had kept the call going.

ENDB_MIL_GIGS_MANY | 420 | End screen beat, signals answered by Flagship; {n} answered signal count
The Flagship answered {n} signals off the trade lanes. Sela kept their bearings among her supply notes. Your crew saw places no standing order would have taken them.

ENDB_MIL_GIGS_LOST_ONE | 420 | End screen beat, signal went quiet unanswered; no special placeholders
A signal went quiet without an answer from your Flagship. Sela kept its bearing after the mark had left the board. There was no reply she could put beside it.

ENDB_MIL_GIGS_LOST_MANY | 420 | End screen beat, signals went quiet unanswered; {n} unanswered signal count
{n} signals went quiet without an answer from your Flagship. Sela kept the bearings after their marks had left the board. None of those lines had a reply beside it.

ENDB_MIL_RESTLESS_ONE | 420 | End screen beat, a world short of needs at cycle end, counted per world per cycle; no special placeholders
A world ended a cycle short of what it needed. At a depot, someone read the delivery sheet again before handing it back. Sela kept that shortfall beside the loads that did get through.

ENDB_MIL_RESTLESS_MANY | 420 | End screen beat, needs short at cycle end, counted per world per cycle; {n} occurrences, not elapsed cycles
{n} times, a world's needs were still short at cycle end. Depot clerks checked the cargo lists and sent the shortfalls back. Sela kept those pages beside the lists of what got through.

ENDB_MIL_RESCUES_ONE | 420 | End screen beat, relief credits kept company alive; no special placeholders
You needed relief credits to keep the company going. Sela put the payment on the supply sheet. A crew could plan another shift before it had to pack.

ENDB_MIL_RESCUES_MANY | 420 | End screen beat, relief credits kept company alive; {n} relief payment count
Relief credits kept the company going {n} times. Sela kept each payment on her supply sheets. Crews waited to learn whether they could set out their tools again.

ENDB_MIL_REPO_ONE | 420 | End screen beat, ship repossessed for debt; no special placeholders
The Bureau repossessed a ship against your debt. Its clerk waited while the crew took their bags ashore. Sela checked the list of what they could carry off.

ENDB_MIL_REPO_MANY | 420 | End screen beat, ships repossessed for debt; {n} repossessed ship count
The Bureau repossessed {n} ships against your debt. Its clerks read the forms slowly and waited for the crews. Sela checked each list of bags before a gangway was drawn back.

ENDB_MIL_MOMENTS_LEAD | 420 | End screen beat, single sentence before decisive moment list; no special placeholders
These are the entries Sela kept at the front of her book.

ENDB_MIL_LEAN_GOOD | 420 | End screen beat, warm Military worlds, win only, immediately before scene close; no special placeholders
The border posts are quiet when Sela calls. A dock hand asks after her crew before asking for a load. She lowers her shoulders while she listens.

ENDB_MIL_LEAN_BAD | 420 | End screen beat, cold Military worlds, win only, immediately before scene close; no special placeholders
At the border posts, clerks ask for the order before a name. The racks are full, and voices stay low around them. Sela holds her coat shut while she listens.

END_MIN_GOOD_OPEN | 900 | End screen, The Footing, scene opening; no placeholders
A child at the new ring of homes will not leave the lift.

Her mother stamps on the floor ahead. It gives back no thin ring of metal. Marek waits beside her with a bag of spare bolts. The next crew's shift is posted beside the lift. Behind the windows, the Star Bazaar is lit.

A Bureau clerk has come to count the homes. They stand on the ingot, alloy and plate your crews brought. He finds their form and smooths it on his knee.

END_MIN_GOOD_CLOSE | 600 | End screen, The Footing, scene close; no placeholders
The child puts a foot out. Marek keeps his bag still while she presses her weight down.

Her mother takes off her work gloves. They walk past him toward their home. Marek listens until their steps fade. Nothing rattles beneath them.

END_MIN_BAD_OPEN | 900 | End screen, The Strip, scene opening; no placeholders
A worker sets her lamp on the Bazaar's new stone floor. White dust rings its base.

The Bureau clerk asks where she lives. She points to the name on her work coat. He turns the page toward her. The place is listed as uninhabited.

Marek stands beside her. Behind the clerk, ingot, alloy and plate are stacked for sale. Her crew's old cut has no seam left to follow. The next cut is already marked.

END_MIN_BAD_CLOSE | 600 | End screen, The Strip, scene close; no placeholders
The clerk asks her to sign beneath the entry. She wipes the dust from her fingers first. She reads it again before she signs.

He thanks her and puts the page away. Marek lifts the lamp for her. A pale ring stays on the floor.

END_MIN_LONGSHIFT_OPEN | 900 | End screen, The Long Shift, scene opening; no placeholders
Marek pulls at a drawer in the Bazaar office. It sticks. The old shortage reports have bent against the wood.

A worker waits with the opening page. She sees her own hand on the top report. Back at her post, she wrote it while the shift ate what was left.

The hall outside is full of voices. Marek takes the report out and lays it beside the page. The worker pulls up a chair.

END_MIN_LONGSHIFT_CLOSE | 600 | End screen, The Long Shift, scene close; no placeholders
He signs the opening page after the others. The worker waits while he holds the pen.

Marek smooths her old report and puts it back. This time the drawer shuts. He leaves the key in it.

END_MIN_DEEP_OPEN | 900 | End screen, Down the Seams, scene opening; no placeholders
Someone has brought a stone from a mining platform to the Bazaar. It rests on a work coat by Marek's boots.

The crew took it from the cut he went down to see. He remembers lifting a handful there and setting it back. Dust still sits in the sleeves of the coat.

A Bureau clerk waits to list the gift. Marek crouches beside it. The crew have left the face with the tool marks showing.

END_MIN_DEEP_CLOSE | 600 | End screen, Down the Seams, scene close; no placeholders
Marek sets the stone below the hall's beam. The clerk writes down its weight.

Marek asks him to leave room beneath it. The crew give their names for that line. Marek holds the page steady while they spell them.

END_MIN_PICKUP_OPEN | 900 | End screen, The Man Who Picked Up, scene opening; no placeholders
Marek cannot get the note to lie flat. An old yard man sent it wrapped round a spare bolt.

Around him, guests fill the Bazaar. Some know his voice from a call. Others have brought a pod tag or an old tool case. Nobody asks for a speech.

The note says, you picked up. Marek sets the bolt on its corner. Beside it lies the list of lanes he put to work when the calls came.

END_MIN_PICKUP_CLOSE | 600 | End screen, The Man Who Picked Up, scene close; no placeholders
The note goes beside the signal board. Marek presses its corners flat with his thumb.

Someone calls his name from the hall. He sets down the spare bolt and turns before they finish.

END_MIN_THIN_OPEN | 900 | End screen, The Thin Fleet, scene opening; no placeholders
The Bureau clerk cannot find room for the fleet form. The bread is being passed across the crew's table.

Marek draws in his elbows to make space. Every pilot who brought your goods fits along the bench. The Bazaar fills the window behind them.

The clerk reads the list of ships. Marek says each name before the clerk reaches it. Then the clerk asks, politely, how many more are planned.

END_MIN_THIN_CLOSE | 600 | End screen, The Thin Fleet, scene close; no placeholders
Marek turns the form over. He writes nothing on the blank side.

The clerk waits. Marek shakes his head and passes the bread. At the far end, a pilot takes it without getting up.

ENDB_MIN_BAZAAR_WIN | 420 | End screen beat, Bazaar completed; {system} is its system, {m} stages, {cycles} elapsed cycles
The Star Bazaar stands in {system}, with all {m} stages raised. Foundations, Halls, Towers and Great Hall took {cycles} cycles. Marek knows whose hands set the stone beneath the benches.

ENDB_MIN_BAZAAR_PART | 420 | End screen beat, Bazaar founded with stages done; {system} is its system, {n} completed stages of {m} total
The Star Bazaar was founded in {system}. Your crews raised {n} of its {m} stages. Marek checked each finished joint before he signed the work sheet.

ENDB_MIN_BAZAAR_BARE | 420 | End screen beat, Bazaar founded with no stages done; {system} is its system, {m} total stages
You founded the Star Bazaar in {system}. None of its {m} stages was raised. The crews had a site on their cargo sheets. They had no finished work there to put their names to.

ENDB_MIN_BAZAAR_NEVER | 420 | End screen beat, Bazaar never founded; no placeholders
You never founded the Star Bazaar. Its name stayed on a loose sheet above Marek's bench. Crews read it while waiting for their next load.

ENDB_MIN_WING_1A | 420 | End screen beat, Wing of Holds, larger Flagship hold; no placeholders
The Wing of Holds gave the Flagship more room for cargo. Marek checked the hold against his load sheets. The crew could pack more than the old chalk line allowed.

ENDB_MIN_WING_1B | 420 | End screen beat, Wing of Reach, longer hub reach; no placeholders
The Wing of Reach let hubs serve worlds farther away. Names beyond the old reach could go on a hub's list. Marek left space beside them for the goods their crews needed.

ENDB_MIN_WING_2A | 420 | End screen beat, Wing of Tolls, higher world tax; no placeholders
The Wing of Tolls made your worlds pay more tax. The worlds' clerks had larger sums to send up. Marek kept their receipts with his parts orders.

ENDB_MIN_WING_2B | 420 | End screen beat, Wing of Benches, lower workshop build cost; no placeholders
The Wing of Benches made new workshops cost less to build. Marek rubbed the old build price off his slate. He left the space for the crew's list of tools.

ENDB_MIN_WING_3A | 420 | End screen beat, Wing of Lamps, larger Flagship hold; no placeholders
The Wing of Lamps gave the Flagship a bigger hold. Under its loading lamps, the crew marked out the added room. Marek checked that the last crate could clear the straps.

ENDB_MIN_WING_3B | 420 | End screen beat, Wing of Couriers, higher world tax; no placeholders
The Wing of Couriers raised the tax paid by your worlds. The couriers carried the higher counts up to the Bureau. Marek checked the sums against the worlds on his supply sheet.

ENDB_MIN_TIER_1_ONE | 420 | End screen beat, a world still at Outpost; {names} is a single world name
{names} remains an outpost. The crew still shares a bench with the tool rack. A worker has hung a child's coat beside a shift jacket.

ENDB_MIN_TIER_1_MANY | 420 | End screen beat, worlds still at Outpost; {n} worlds, at least two
{n} worlds remain outposts. Their crews still clear tools from the bench before eating. Children learn to keep their elbows clear of the parts trays.

ENDB_MIN_TIER_2_ONE | 420 | End screen beat, a world grown to Village; {names} is a single world name
{names} grew into a village through your trade. A fitter can walk home after a shift now. Her child keeps a place for her at a kitchen table.

ENDB_MIN_TIER_2_MANY | 420 | End screen beat, worlds grown to Village; {names} is a plural list, {n} is its count
{names} are villages now, {n} worlds built up through your trade. Fitters leave their boots beneath kitchen benches after work. Their children know which pair to tug at.

ENDB_MIN_TIER_3_ONE | 420 | End screen beat, a world grown to Town; {names} is a single world name
Your trade helped {names} grow into a town. The school has benches of its own now. The teacher hands back the stools borrowed from the loading yard.

ENDB_MIN_TIER_3_MANY | 420 | End screen beat, worlds grown to Town; {names} is a plural list, {n} is its count
{names} are towns now, {n} worlds raised through your trade. Their schools have benches built for children. The loading crews have their stools back.

ENDB_MIN_TIER_4_ONE | 420 | End screen beat, a world grown to City; {names} is a single world name
Your trade helped {names} grow into a city. Fitters rent rooms along streets beyond the old loading yard. A fitter can change jobs without packing up her home.

ENDB_MIN_TIER_4_MANY | 420 | End screen beat, worlds grown to City; {names} is a plural list, {n} is its count
{names} are cities now, {n} worlds grown through your trade. Workers move between jobs without leaving the streets they know. Their children give directions by the old loading yards.

ENDB_MIN_TIER_5_ONE | 420 | End screen beat, a world grown to Metropolis; {names} is a single world name
{names} has become a metropolis through your trade. Crews from far docks live above shops near the old post. A retired loader points it out when his grandchildren visit.

ENDB_MIN_TIER_5_MANY | 420 | End screen beat, worlds grown to Metropolis; {names} is a plural list, {n} is its count
{names} are metropolises now, {n} worlds built up through your trade. The old loading yards sit among whole districts of homes. Retired crews show their grandchildren where they used to eat.

ENDB_MIN_WORLDS_NONE | 420 | End screen beat, no world grew; no placeholders
No world grew through your trade. Work coats still hang above the same bunks. A worker folds a sketch of a larger room. It goes back in the coat pocket.

ENDB_MIN_RECLAIMED_ONE | 420 | End screen beat, a dead world reclaimed; {names} is a single world name
{names} was dead rock when your people came. You brought it back to life, and mining there stopped. A former cutter tends a patch of green beside the post.

ENDB_MIN_RECLAIMED_MANY | 420 | End screen beat, dead worlds reclaimed; {names} is a plural list, {n} is its count
{names} are living worlds again, {n} places reclaimed through your work. Mining stopped there. Hands that packed rock samples now check new leaves for frost.

ENDB_MIN_POSTS_ONE | 420 | End screen beat, a trading post or mining platform built by the Flagship; no placeholders
The Flagship built a place for a crew to work. They chalked a shift list beside the hatch. Marek put the crew's spares on his next parts order.

ENDB_MIN_POSTS_MANY | 420 | End screen beat, combined trading posts and mining platforms built by the Flagship; {n} total built
Your Flagship built {n} trading posts and mining platforms. Each needed hands to fit the frame and stay to run it. Marek's parts lists reached places his old yard never served.

ENDB_MIN_SYSTEMS_MANY | 420 | End screen beat, systems reached by the company; {company} is its name, {n} total systems
{company} reached {n} systems. Yard hands who had never shared a shift began sending each other parts lists. Marek checked the bolt sizes before he checked the greetings.

ENDB_MIN_FLEET_ONE | 420 | End screen beat, largest fleet was a ship; {ship} is the singular ship type
At its largest, the fleet had a {ship}. Marek kept its parts list in his coat. The crew knew where to find him when a bolt would not fit.

ENDB_MIN_FLEET_MANY | 420 | End screen beat, largest fleet; {n} hulls, {ship} is the singular ship type
At its largest, the fleet had {n} {ship} hulls. Marek checked their upkeep before he ordered spares. Each hull put another crew's shift in your hands.

ENDB_MIN_ROUTES_ONE | 420 | End screen beat, a route started; no placeholders
You started a route for your goods. Marek wrote its ends on a parts slip. At the far dock, someone cleared a place to set the load.

ENDB_MIN_ROUTES_MANY | 420 | End screen beat, routes started; {n} routes
You started {n} routes. Marek wrote down what each would carry before he counted the credits. At the far docks, hands made room among the waiting crates.

ENDB_MIN_ROUTES_CLOSED_ONE | 420 | End screen beat, a route removed, after routes started; no placeholders
You closed a route you had started. Marek struck it from the cargo sheet. He kept the old sheet so the crews could check what had changed.

ENDB_MIN_ROUTES_CLOSED_MANY | 420 | End screen beat, routes removed, after routes started; {n} routes
You closed {n} routes you had started. Crews had to read the cargo sheets again. Marek kept the old copies so each change could be traced.

ENDB_MIN_SKILLS_ONE | 420 | End screen beat, a skill learned; no placeholders
Your people learned a skill. Marek had them try it before he filed the lesson. The next shift pulled up stools to watch.

ENDB_MIN_SKILLS_MANY | 420 | End screen beat, skills learned; {n} skills
Your people learned {n} skills. The notes passed between shifts, with grease on the corners. Marek kept the pages whose errors had been crossed out.

ENDB_MIN_WORKS_ONE | 420 | End screen beat, a workshop, Fabric or hub built; no placeholders
You built a place where goods could be made or sent on. Its crew set up a bench before they unpacked the tools. Marek checked what they needed, down to the spare bolts.

ENDB_MIN_WORKS_MANY | 420 | End screen beat, combined workshops, Fabric and hubs built; {n} total built
You built {n} places where goods could be made or sent on. Crews set up their benches beside the stock lists. Each crew kept mugs there, with names scratched underneath.

ENDB_MIN_GIGS_ONE | 420 | End screen beat, a signal answered by the Flagship; no placeholders
The Flagship answered a signal. The crew laid down their yard tools and went to look. Marek read their report before he returned to the parts list.

ENDB_MIN_GIGS_MANY | 420 | End screen beat, signals answered by the Flagship; {n} signals
The Flagship answered {n} signals. Crews left their other work to go and look. Marek read each report before he let the next shift take the desk.

ENDB_MIN_GIGS_LOST_ONE | 420 | End screen beat, a signal went quiet unanswered; no placeholders
A signal faded without a reply from your Flagship. The crew had no report to bring back. Marek left space for it between the finished jobs.

ENDB_MIN_GIGS_LOST_MANY | 420 | End screen beat, signals went quiet unanswered; {n} signals
{n} signals went quiet without an answer from your Flagship. Marek had no reports to put beside their marks. He kept those spaces on the work sheet.

ENDB_MIN_RESTLESS_ONE | 420 | End screen beat, a world ended a cycle with unmet needs; no placeholders
A world had unmet needs at a cycle's end. Its crew stretched the stock or worked around what had not come. Marek read the report with their names beside it.

ENDB_MIN_RESTLESS_MANY | 420 | End screen beat, unmet needs counted per world per cycle; {n} such instances, not cycles or goods
{n} times a world had unmet needs at a cycle's end. People stretched the stock or worked around what had not come. Marek read their reports with the crew lists beside him.

ENDB_MIN_RESCUES_ONE | 420 | End screen beat, relief credits kept the company alive; {company} is its name
Relief credits kept {company} running when its own credits ran short. Marek signed the receipt with the crew waiting across the desk. They could go back to work.

ENDB_MIN_RESCUES_MANY | 420 | End screen beat, relief credits kept the company alive; {company} is its name, {n} payments
Relief credits kept {company} alive {n} times. Marek kept the receipts where he could see them. The crews behind those payments got more time to find paying work.

ENDB_MIN_REPO_ONE | 420 | End screen beat, a ship repossessed for debt; no placeholders
The Bureau took a ship against your debt. The clerk asked for a signature, then waited while the crew packed. Marek put their tools on his own bench.

ENDB_MIN_REPO_MANY | 420 | End screen beat, ships repossessed for debt; {n} ships
The Bureau took {n} ships against your debt. The clerks read the forms slowly while crews carried their tools to the dock. Marek made room for those tools at his own bench.

ENDB_MIN_MOMENTS_LEAD | 420 | End screen beat, a sentence before the decisive moments list; no placeholders
Marek marked these entries for anyone who takes the desk next.

ENDB_MIN_LEAN_GOOD | 420 | End screen beat, warm worlds, just before scene close on a win; no placeholders
When Marek asks about the work, the crews make room on their bench. The stone beneath their boots holds. He sits without reaching for the parts book.

ENDB_MIN_LEAN_BAD | 420 | End screen beat, cold worlds, just before scene close on a win; no placeholders
The halls are loud, and the cut seams lie bare. Crews give Marek the weights he asks for. Their hands stay on the work. Nobody asks him to sit.
