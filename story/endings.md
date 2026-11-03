# Endings (Four Markets, placeholder pass 2026-11-03)

The run ends with exactly one ending. The old Release/Corporation endings, the choice screen and the cash goal are retired. The end screen (game/end_screen.gd) reads the title from <id>_TITLE and the body from <id>. It shows no counts, labels, direction or record of choices; the readout of shares is drawn by the game.
Texts carry no placeholders: the game passes none to the ending body. The strongest rival and best market are shown by the game's own stat line and readout.
Selection (programmer notes, never shown): win in market M gives END_<MKT>_GOOD (the BAD variants come in a later goal, until then every win is GOOD); no ship left and cash still negative gives END_BANKRUPT; the player under a tenth of every market for the sweep window gives END_SWEPT; the window closing with no market held gives END_OUTCOMPETED.
Texts are placeholder quality: in voice, to be finalised with the BAD variants.

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

## Loss and soft endings

END_BANKRUPT_TITLE | 40 | End screen heading, no ship left and cash still negative (loss)
The Ledger Closes

END_BANKRUPT | 600 | End screen body, no ship left and cash still negative (loss)
The company has no ships left, and the cash is still below zero. Each cycle the Bureau took the newest hull to cover the debt, and now the last is gone. Your ships are entered in the Common Ledger, and your name is given a quota that is equal and exactly the size of everyone else's. A clerk reads the closing form aloud and adds that nothing here was ever owed to you. The three rivals go on selling. The sky did not notice.

END_SWEPT_TITLE | 40 | End screen heading, player under a tenth of every market (loss)
The Floor of Every Graph

END_SWEPT | 600 | End screen body, player under a tenth of every market for the sweep window (loss)
For three cycles running, your company held less than a tenth of every market, and the Bureau has stopped listing you as a competitor. The strongest of the three rivals fills the shelves where yours stood. Your ships still run, and your orders are still taken, politely, at counters that are no longer yours. Nothing cruel was done. A market is a room, and you were not in it.

END_OUTCOMPETED_TITLE | 40 | End screen heading, window closed with no market held (soft ending)
No Market Held

END_OUTCOMPETED | 700 | End screen body, window closed with no market over half (soft ending)
The window closed with no market held. You did not lose. The company is solvent, the ships run, and the Bureau lists you as a participant, a word with no weight. A spread of small shares does not add up to a market. A single market, held all the way, does. The sky has no opinion. It never needed one.

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

EPI_SECOND_MIL | 140 | Epilogue 4, Military is a second market over a quarter share
Military ran second, past a quarter of its market. The fleets noticed, and kept your number.

EPI_SECOND_LUX | 140 | Epilogue 4, Luxury is a second market over a quarter share
Luxury ran second, past a quarter of its market. The masks at the gala came from you.

EPI_SECOND_MIN | 140 | Epilogue 4, Minerals is a second market over a quarter share
Minerals ran second, past a quarter of its market. The dust remembers you anyway.

EPI_SECOND_BIO | 140 | Epilogue 4, Biotech is a second market over a quarter share
Biotech ran second, past a quarter of its market. A vat in a back room has your name on it.
