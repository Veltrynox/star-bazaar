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

## Phase 2 signals (T275, 2026-11-06). GIG03 and GIG04 are shared: all four branch outcomes. GIG05 (Military and Minerals) and GIG06 (Luxury and Biotech) are branch gigs: outcome lines only for those two branches, and the game offers each only to a company with that branch.

## GIG03 The quota drum (a Plan marker adrift)

GIG03_TITLE | Gig 03, arrival window title | The quota drum
GIG03_HOOK | Gig 03, signal hint | A tapping on the open band. Always eleven taps, then a gap.
GIG03_ARRIVE | Gig 03, arrival window text | A steel drum drifts in the dark, stamped with a five-cycle plan nobody finished. It taps against its own tether. Inside, a ledger and a sealed lot. If you open the lot, the Plan loses a line. If you copy the ledger, the lot stays closed.
GIG03_A_BTN | Gig 03, button A | Open the sealed lot
GIG03_B_BTN | Gig 03, button B | Copy the ledger
GIG03_A_OUT_MIL | Gig 03, outcome A, Military | The lot is packed in order, each crate numbered. You count them twice. The Plan is one line short, and no one is there to mind.
GIG03_A_OUT_LUX | Gig 03, outcome A, Luxury | Folded cloth between paper sheets, still bright. The paper carries a stamp. You leave the stamp where it is.
GIG03_A_OUT_MIN | Gig 03, outcome A, Minerals | Heavy slabs in grey wrap, marked for a claim that was never cut. The drum stops tapping when the lot is out.
GIG03_A_OUT_BIO | Gig 03, outcome A, Biotech | Cold trays, a green smell in the seam. The drum taps once more, then goes quiet.
GIG03_B_OUT_MIL | Gig 03, outcome B, Military | The ledger lists every drop and every handler. You copy it by hand. The lot stays closed behind you.
GIG03_B_OUT_LUX | Gig 03, outcome B, Luxury | The ledger lists who was owed a gift and who sent it. You copy the names. The lot stays closed behind you.
GIG03_B_OUT_MIN | Gig 03, outcome B, Minerals | The ledger lists each claim and its weight. You copy the pages. The lot stays closed behind you.
GIG03_B_OUT_BIO | Gig 03, outcome B, Biotech | The ledger lists which trays came from which shelf, and when. You copy it. The lot stays closed behind you.
GIG03_EPI | Gig 03, epilogue line | The Bureau marks the quota drum as found. It does not mark it as finished.

## GIG04 The empty berth (a station that kept the lights)

GIG04_TITLE | Gig 04, arrival window title | The empty berth
GIG04_HOOK | Gig 04, signal hint | A docking call, repeated. A calm voice, no reply space.
GIG04_ARRIVE | Gig 04, arrival window text | A small station, lit and clean. Every berth is empty and ready. A voice offers you one. A table is set for a crew of six. You may take the stores in the pantry, or stay for the meal and the talk. Both take the scout's time.
GIG04_A_BTN | Gig 04, button A | Load the pantry stores
GIG04_B_BTN | Gig 04, button B | Stay for the meal
GIG04_A_OUT_MIL | Gig 04, outcome A, Military | Rations in sealed packs, stamped for a depot you know. The voice thanks you for each pack. The table stays set.
GIG04_A_OUT_LUX | Gig 04, outcome A, Luxury | Tins of sweet things, bright labels, never opened. The voice thanks you for each tin. The table stays set.
GIG04_A_OUT_MIN | Gig 04, outcome A, Minerals | Dry stores and tool kits, still in their grease paper. The voice thanks you for each one. The table stays set.
GIG04_A_OUT_BIO | Gig 04, outcome A, Biotech | Jars of culture, a label in neat hand on each. The voice thanks you for each jar. The table stays set.
GIG04_B_OUT_MIL | Gig 04, outcome B, Military | You eat. The voice tells you the stops on the old patrol line, one by one. No one else sits down.
GIG04_B_OUT_LUX | Gig 04, outcome B, Luxury | You eat. The voice tells you who dined here, and what each of them paid for. No one else sits down.
GIG04_B_OUT_MIN | Gig 04, outcome B, Minerals | You eat. The voice tells you where the nearest rock was cut, and by whom. No one else sits down.
GIG04_B_OUT_BIO | Gig 04, outcome B, Biotech | You eat. The voice tells you what grew in the station's garden, and what went wrong. No one else sits down.
GIG04_EPI | Gig 04, epilogue line | The station keeps its lights on. The Bureau has no form for that.

## GIG05 The proving range (Military, Minerals)

GIG05_TITLE | Gig 05, arrival window title | The proving range
GIG05_HOOK | Gig 05, signal hint | A flat tone, struck on the hour. It stops mid-count.
GIG05_ARRIVE | Gig 05, arrival window text | A test range, long abandoned. Targets hang in a line. A rack of tools sits by the control hut, and a crane arm still holds a crate. You can take the rack, or follow the range book to where the last test was logged.
GIG05_A_BTN | Gig 05, button A | Strip the tool rack
GIG05_B_BTN | Gig 05, button B | Follow the range book
GIG05_A_OUT_MIL | Gig 05, outcome A, Military | Drill heads and clamps, in a rack made for one team. Each carries a mark. You do not read them aloud.
GIG05_A_OUT_MIN | Gig 05, outcome A, Minerals | Cutters, bits and a core drill, all heavy and oiled. The crane arm lets go of the crate. It floats away.
GIG05_B_OUT_MIL | Gig 05, outcome B, Military | The book ends at a bearing. You write it down. The last test was never finished, and the book does not say why.
GIG05_B_OUT_MIN | Gig 05, outcome B, Minerals | The book ends at a rock field, with depths in pencil. You copy the page. The crate stays in the crane.
GIG05_EPI | Gig 05, epilogue line | The range is struck from the Plan. The targets are still hanging.

## GIG06 The sealed garden (Luxury, Biotech)

GIG06_TITLE | Gig 06, arrival window title | The sealed garden
GIG06_HOOK | Gig 06, signal hint | A soft chime and a faint warm light. The beacon is a window.
GIG06_ARRIVE | Gig 06, arrival window text | A glass hull, fogged from inside. Green behind it, thick and still. A hatch will open for a cut flower, or for a full bag of the garden's seed. Either one means going in. Either one means leaving something behind.
GIG06_A_BTN | Gig 06, button A | Cut the best blooms
GIG06_B_BTN | Gig 06, button B | Bag the garden seed
GIG06_A_OUT_LUX | Gig 06, outcome A, Luxury | Pale petals the width of a hand, with a scent that stays on your sleeve for days. The beds look bare behind you.
GIG06_A_OUT_BIO | Gig 06, outcome A, Biotech | Thick blooms, wet at the stem. Your gloves come out stained. The beds look bare behind you.
GIG06_B_OUT_LUX | Gig 06, outcome B, Luxury | Fine seed, sorted by colour, each bag tied with thread. The beds stay green, but no one will cut them now.
GIG06_B_OUT_BIO | Gig 06, outcome B, Biotech | Seed in damp paper, each lot tagged by shelf. The beds stay green. The air inside smells close.
GIG06_EPI | Gig 06, epilogue line | The garden is listed as tended. No keeper is named on the page.
