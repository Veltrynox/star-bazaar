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
