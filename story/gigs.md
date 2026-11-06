# Gigs (T217, draft 1)

Format: ID | place | text (one text per line). Limits by id suffix: _TITLE 32, _BTN 28 (written to 24), _HOOK 140, _EPI 140, everything else 280 (see GIG_TEXT_MAX in tools/build_story.py).
A gig is one signal in the Pathfinder's system. Hook: shown with the label "Signal" and the system name; the story stays hidden. Arrive: the window on arrival. Two neutral buttons, each gives something and costs something. Branch outcome ids end _OUT_MIL, _OUT_LUX, _OUT_MIN, _OUT_BIO (Military, Luxury, Minerals, Biotech); the game shows the one for the company's branch after the player picks A or B. Epilogue: one line, same for every branch.
No text names a good, a number, a skill point or a mechanic. The game picks what is given and taken; the outcome lines only describe the scene.

## GIG01 The wreck of the Ninth Tally (ship crash, salvage)

GIG01_TITLE | Gig 01, arrival window title | The Ninth Tally
GIG01_HOOK | Gig 01, signal hint | A weak beacon repeats one tone. Nobody has answered it.
GIG01_ARRIVE | Gig 01, arrival window text | A Commons hauler, split along the spine. Its lights are dark. The bunks are empty and made. A Common Ledger plate is still bolted by the hatch. Cutting into the hold takes the scout's time. The flight log is quick to pull, but then the hold stays sealed.
GIG01_A_BTN | Gig 01, button A | Cut the hold free
GIG01_B_BTN | Gig 01, button B | Pull the flight log
GIG01_A_OUT_MIL | Gig 01, outcome A, Military | The crates carry a depot stamp you know. The seals hold. The scout rides heavy on the way back, and the torch is still warm.
GIG01_A_OUT_LUX | Gig 01, outcome A, Luxury | Bright cloth, wrapped tight, a sweet smell in the folds. The scout smells of it all the way back. The empty bunks stay behind you.
GIG01_A_OUT_MIN | Gig 01, outcome A, Minerals | Dull grey crates, heavy for their size. Dust on your gloves that will not brush off. The scout is slow on the way back.
GIG01_A_OUT_BIO | Gig 01, outcome A, Biotech | Damp sealed tubs, warm to the touch. Something in them shifts once, then stops. You do not look twice.
GIG01_B_OUT_MIL | Gig 01, outcome B, Military | The log lists every stop and every order. A hand wrote the last line twice. The hold stays sealed, and you leave it there.
GIG01_B_OUT_LUX | Gig 01, outcome B, Luxury | The log lists ports, buyers and who paid for what. The last page is a list of names. The hold stays sealed behind you.
GIG01_B_OUT_MIN | Gig 01, outcome B, Minerals | The log lists every claim the hauler passed, and what each one held. The hold stays sealed. The scout turns away.
GIG01_B_OUT_BIO | Gig 01, outcome B, Biotech | The log lists each stop where the cargo was kept cold, and where it stopped being cold. The hold stays sealed.
GIG01_EPI | Gig 01, epilogue line | The Bureau lists the Ninth Tally as overdue. It will stay on that page.

## GIG02 The relay keeper (a lamp still lit)

GIG02_TITLE | Gig 02, arrival window title | The relay lamp
GIG02_HOOK | Gig 02, signal hint | A relay light blinks twice, stops, then blinks twice again.
GIG02_ARRIVE | Gig 02, arrival window text | A relay station with one lamp lit. A keeper in a shift coat waves from the glass. The shift form lies half filled. If you carry the keeper out, the form stays blank and the lamp goes dark. If you stand the watch, the scout waits and the keeper stays.
GIG02_A_BTN | Gig 02, button A | Carry the keeper out
GIG02_B_BTN | Gig 02, button B | Stand the keeper's watch
GIG02_A_OUT_MIL | Gig 02, outcome A, Military | The keeper hands you a code strip from the relay shelf. The lamp goes out behind you. The form stays blank.
GIG02_A_OUT_LUX | Gig 02, outcome A, Luxury | The keeper presses a little gift into your hand, wrapped in bright cloth. The lamp goes out behind you.
GIG02_A_OUT_MIN | Gig 02, outcome A, Minerals | The keeper gives you a rock map, marked in grease pencil. The lamp goes out behind you.
GIG02_A_OUT_BIO | Gig 02, outcome A, Biotech | The keeper gives you a jar of seed from a window shelf. It is still damp. The lamp goes out behind you.
GIG02_B_OUT_MIL | Gig 02, outcome B, Military | You hold the lamp for a shift. The relay log shows who passed and what they carried. The keeper sleeps in a chair.
GIG02_B_OUT_LUX | Gig 02, outcome B, Luxury | You hold the lamp for a shift. The relay log shows which ships called, and where they sold well. The keeper sleeps in a chair.
GIG02_B_OUT_MIN | Gig 02, outcome B, Minerals | You hold the lamp for a shift. The relay log shows which ships hauled rock, and where they sold it. The keeper sleeps in a chair.
GIG02_B_OUT_BIO | Gig 02, outcome B, Biotech | You hold the lamp for a shift. The relay log shows which ships carried cold cargo, and where they sold it. The keeper sleeps in a chair.
GIG02_EPI | Gig 02, epilogue line | The keeper's form is filed under the common good. The Bureau does not ask who filled it in.
