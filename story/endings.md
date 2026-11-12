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

END_MIN_PICKUP_TITLE | 40 | End screen heading, Marek, many rush orders and quick routes
The Man Who Picked Up

END_MIN_PICKUP | 1000 | End screen body, Marek, many rush orders and quick routes
When the call came, Marek answered. A rush order at Ashgate, a late food run at Tillam, a world short on energy and asking only once. He did not always have the hold for it. He made the hold. The Bazaar opened on a long list of small yeses. Nobody will carve them into a wall. The people who got their goods on time will remember, which is how a name lasts here. The old yard man sends a note. It has one line. It says, you picked up.

EPI_MIN_PICKUP | 140 | Epilogue 1, Marek, rush orders and quick routes
Every rush order on the board has the same reply scratched under it, in Marek's hand. It says, on its way.

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

END_LUX_FULLTABLE_TITLE | 40 | End screen heading, Idris, rush orders filled in time
A Seat Always Free

END_LUX_FULLTABLE | 1000 | End screen body, Idris, rush orders filled in time
Every order that came to the board was filled before its time ran out. Buyers learned that when Idris said yes, the goods arrived, and they stopped asking twice. One table at the Bazaar stays empty at the end of the night. It is kept for whoever needs a good by morning. Idris does not call it a plan. He calls it manners.

EPI_LUX_FULLTABLE | 140 | Epilogue 1, Idris, rush orders filled in time
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

END_MIL_NOIDLE_TITLE | 40 | End screen heading, Sela, rush orders filled in time
No Hull Sat Still

END_MIL_NOIDLE | 1000 | End screen body, Sela, rush orders filled in time
Not one order died on the board. Not one hull waited for a stamp it could have bought. Sela flew the worst lanes in the rim, and she learned there what a ship costs when it stands still. Now every ship moves. The Bazaar opened on time, and for once nobody checked the sky for what was coming. Sela did, from habit. She stood at the window until the last hull left the dock. Then she sat down.

EPI_MIL_NOIDLE | 140 | Epilogue 1, Sela, rush orders filled in time
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
