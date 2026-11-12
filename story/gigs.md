# Gigs (T217, draft 1)

Format: ID | place | text (one text per line). Limits by id suffix: _TITLE 32, _BTN 28 (written to 24), _HOOK 420, _EPI 140, everything else 280 (see GIG_TEXT_MAX in tools/build_story.py).
A gig is one signal in the Pathfinder's system. Hook: shown with the label "Signal" and the system name; the story stays hidden. Arrive: the window on arrival. Two neutral buttons, each gives something and costs something. Branch outcome ids end _OUT_MIL, _OUT_LUX, _OUT_MIN, _OUT_BIO (Military, Luxury, Minerals, Biotech); the game shows the one for the company's branch after the player picks A or B. Epilogue: one line, same for every branch.
No text names a good, a number, a skill point or a mechanic. The game picks what is given and taken (a small cash sum, a small lot of the branch's goods, a small fee, or Flagship idle time; data/gigs.json); the outcome lines only describe the scene and may say "a small sum", "a small fee" or "a lot". Updated 2026-11-11: the outcome lines of GIG01 to GIG06 now match those rewards.

## GIG01 The wreck of the Ninth Tally (ship crash, salvage)

GIG01_TITLE | Gig 01, arrival window title | The Ninth Tally
GIG01_HOOK | Gig 01, signal hint | A beacon on the Commons band, one tone, over and over. The crew checked the Bureau's lists and found a hauler marked overdue in this sector. The tone has not changed in all that time, as if someone set it and walked away. Every ship that heard it logged it and flew on.
GIG01_ARRIVE | Gig 01, arrival window text | A Commons hauler, split along the spine. Its lights are dark. The bunks are empty and made. A Common Ledger plate is still bolted by the hatch. Cutting into the hold takes the scout's time. The flight log is quick to pull, but then the hold stays sealed.
GIG01_A_BTN | Gig 01, button A | Cut the hold free
GIG01_B_BTN | Gig 01, button B | Pull the flight log
GIG01_A_OUT_MIL | Gig 01, outcome A, Military | The crates carry a depot stamp you know. The seals hold. The scout rides heavy on the way back, and the torch is still warm.
GIG01_A_OUT_LUX | Gig 01, outcome A, Luxury | Bright cloth, wrapped tight, a sweet smell in the folds. The scout smells of it all the way back. The empty bunks stay behind you.
GIG01_A_OUT_MIN | Gig 01, outcome A, Minerals | Dull grey crates, heavy for their size. Dust on your gloves that will not brush off. The scout is slow on the way back.
GIG01_A_OUT_BIO | Gig 01, outcome A, Biotech | Damp sealed tubs, warm to the touch. Something in them shifts once, then stops. You do not look twice.
GIG01_B_OUT_MIL | Gig 01, outcome B, Military | The log lists every stop and every order. A depot clerk pays a small sum for a copy. A hand wrote the last line twice. The hold stays sealed, and you leave it there.
GIG01_B_OUT_LUX | Gig 01, outcome B, Luxury | The log lists ports, buyers and who paid for what. A broker pays a small sum for a copy. The last page is a list of names. The hold stays sealed behind you.
GIG01_B_OUT_MIN | Gig 01, outcome B, Minerals | The log lists every claim the hauler passed, and what each one held. A claim office pays a small sum for a copy. The hold stays sealed. The scout turns away.
GIG01_B_OUT_BIO | Gig 01, outcome B, Biotech | The log lists each stop where the cargo was kept cold, and where it stopped being cold. A clinic pays a small sum for a copy. The hold stays sealed.
GIG01_EPI | Gig 01, epilogue line | The Bureau lists the Ninth Tally as overdue. It will stay on that page.

## GIG02 The relay keeper (a lamp still lit)

GIG02_TITLE | Gig 02, arrival window title | The relay lamp
GIG02_HOOK | Gig 02, signal hint | A relay lamp is blinking a keeper's check: twice, a pause, twice again. The relay marks a debris field that ships use as a short cut, and it was struck from the Plan cycles ago. Nobody was sent to pay its keeper or relieve him. If the lamp is still lit, the old keeper is still out there, alone, keeping ships off the rocks.
GIG02_ARRIVE | Gig 02, arrival window text | An old man in a shift coat waves from the relay glass. He has kept this lamp for years without pay, so ships do not hit the debris. He is ill and wants to go home, but no one will take his shift. Take him to a dock and the lamp goes dark, or keep it for him while he rests.
GIG02_A_BTN | Gig 02, button A | Take the keeper home
GIG02_B_BTN | Gig 02, button B | Keep the lamp for him
GIG02_A_OUT_MIL | Gig 02, outcome A, Military | He pays with what he has: crates from the relay shelf, stamped for a depot you know. The dock charges a small fee for an extra passenger. The lamp goes out behind you, and the short cut is closed for now.
GIG02_A_OUT_LUX | Gig 02, outcome A, Luxury | He pays with what he has: bright parcels traders left for him over the years. The dock charges a small fee for an extra passenger. The lamp goes out behind you, and the short cut is closed for now.
GIG02_A_OUT_MIN | Gig 02, outcome A, Minerals | He pays with what he has: rock sacks from the relay shelf, marked in grease pencil. The dock charges a small fee for an extra passenger. The lamp goes out behind you, and the short cut is closed for now.
GIG02_A_OUT_BIO | Gig 02, outcome A, Biotech | He pays with what he has: damp jars he grew on the window shelf. The dock charges a small fee for an extra passenger. The lamp goes out behind you, and the short cut is closed for now.
GIG02_B_OUT_MIL | Gig 02, outcome B, Military | Your crew keeps the lamp through a long shift while he sleeps. Passing haulers leave a small sum in the relay box, as they always did. His log shows who passed and what they carried. When he wakes, he looks better.
GIG02_B_OUT_LUX | Gig 02, outcome B, Luxury | Your crew keeps the lamp through a long shift while he sleeps. Passing traders leave a small sum in the relay box, as they always did. His log shows which ships called and where they sold well. When he wakes, he looks better.
GIG02_B_OUT_MIN | Gig 02, outcome B, Minerals | Your crew keeps the lamp through a long shift while he sleeps. Passing haulers leave a small sum in the relay box, as they always did. His log shows which ships hauled rock and where they sold it. When he wakes, he looks better.
GIG02_B_OUT_BIO | Gig 02, outcome B, Biotech | Your crew keeps the lamp through a long shift while he sleeps. Passing haulers leave a small sum in the relay box, as they always did. His log shows which ships carried cold cargo and where. When he wakes, he looks better.
GIG02_EPI | Gig 02, epilogue line | The Bureau still lists the relay as closed. The ships that use the short cut know better.

## Phase 2 signals (T275, 2026-11-06). GIG03 and GIG04 are shared: all four branch outcomes. GIG05 (Military and Minerals) and GIG06 (Luxury and Biotech) are branch gigs: outcome lines only for those two branches, and the game offers each only to a company with that branch.

## GIG03 The quota drum (a Plan marker adrift)

GIG03_TITLE | Gig 03, arrival window title | The quota drum
GIG03_HOOK | Gig 03, signal hint | The sensors catch a crash beacon in the dark. Its frequency belongs to a Belo Industries hauler. Belo ships have been seen carrying living cargo sealed in black slime, the kind clinics refuse to sign for and the Bureau prefers not to list. The beacon still repeats its call, and nobody on that hull has answered it. Something drifts near the wreck. Do we look?
GIG03_ARRIVE | Gig 03, arrival window text | A steel drum drifts in the dark, stamped with a five-cycle plan nobody finished. It taps against its own tether. Inside, a ledger and a quota page with a blank line for the world. If you take up the quota, the scout stays long. If you copy the ledger, the quota stays blank.
GIG03_A_BTN | Gig 03, button A | Take up the quota
GIG03_B_BTN | Gig 03, button B | Copy the ledger
GIG03_A_OUT_MIL | Gig 03, outcome A, Military | You write one of your worlds on the blank line, and the stamp takes. The quota is yours now, and the yard there will know it. The Plan has one line fewer to mourn.
GIG03_A_OUT_LUX | Gig 03, outcome A, Luxury | You write a world on the blank line, in your best hand, and the page seems pleased. A quota for a gift that never came is yours now. The drum taps once more.
GIG03_A_OUT_MIN | Gig 03, outcome A, Minerals | You write a world on the blank line, and the drum stops tapping. The old quota wanted rock and never got it. It is yours now.
GIG03_A_OUT_BIO | Gig 03, outcome A, Biotech | You write a world on the blank line. The ink dries green at the edges, which ink should not do. The quota is yours now. The drum goes quiet.
GIG03_B_OUT_MIL | Gig 03, outcome B, Military | The ledger lists every drop and every handler. You copy it by hand, and a depot clerk pays a small sum for the copy. The lot stays closed behind you.
GIG03_B_OUT_LUX | Gig 03, outcome B, Luxury | The ledger lists who was owed a gift and who sent it. You copy the names, and a broker pays a small sum for them. The lot stays closed behind you.
GIG03_B_OUT_MIN | Gig 03, outcome B, Minerals | The ledger lists each claim and its weight. You copy the pages, and a claim office pays a small sum for them. The lot stays closed behind you.
GIG03_B_OUT_BIO | Gig 03, outcome B, Biotech | The ledger lists which trays came from which shelf, and when. You copy it, and a clinic pays a small sum for the copy. The lot stays closed behind you.
GIG03_EPI | Gig 03, epilogue line | The Bureau marks the quota drum as found. It does not mark it as finished.

## GIG04 The empty berth (a station that kept the lights)

GIG04_TITLE | Gig 04, arrival window title | The empty berth
GIG04_HOOK | Gig 04, signal hint | A docking call, in a calm voice, repeated word for word. It offers a berth, gives the berth number, and leaves no space to answer. The station is small and off every lane, and it is not on the current Plan. The voice sounds pleased to have you coming, which is more than the crew can say for any dock on the board.
GIG04_ARRIVE | Gig 04, arrival window text | A small station, lit and clean. Every berth is empty and ready. A voice offers you one. A table is set for a crew of six. You may take the stores in the pantry, or stay for the meal and the talk. One asks a berth fee. The other takes the scout's time.
GIG04_A_BTN | Gig 04, button A | Load the pantry stores
GIG04_B_BTN | Gig 04, button B | Stay for the meal
GIG04_A_OUT_MIL | Gig 04, outcome A, Military | Rations in sealed packs, stamped for a depot you know. The voice thanks you for each pack, and asks a berth fee, which you pay. The table stays set.
GIG04_A_OUT_LUX | Gig 04, outcome A, Luxury | Tins of sweet things, bright labels, never opened. The voice thanks you for each tin, and asks a berth fee, which you pay. The table stays set.
GIG04_A_OUT_MIN | Gig 04, outcome A, Minerals | Dry stores and tool kits, still in their grease paper. The voice thanks you for each one, and asks a berth fee, which you pay. The table stays set.
GIG04_A_OUT_BIO | Gig 04, outcome A, Biotech | Jars of culture, a label in neat hand on each. The voice thanks you for each jar, and asks a berth fee, which you pay. The table stays set.
GIG04_B_OUT_MIL | Gig 04, outcome B, Military | You eat. The voice tells you the stops on the old patrol line, one by one, and hands you a purse for the company. No one else sits down.
GIG04_B_OUT_LUX | Gig 04, outcome B, Luxury | You eat. The voice tells you who dined here, and what each of them paid for, and hands you a purse for the company. No one else sits down.
GIG04_B_OUT_MIN | Gig 04, outcome B, Minerals | You eat. The voice tells you where the nearest rock was cut, and by whom, and hands you a purse for the company. No one else sits down.
GIG04_B_OUT_BIO | Gig 04, outcome B, Biotech | You eat. The voice tells you what grew in the station's garden, and what went wrong, and hands you a purse for the company. No one else sits down.
GIG04_EPI | Gig 04, epilogue line | The station keeps its lights on. The Bureau has no form for that.

## GIG05 The proving range (Military, Minerals)

GIG05_TITLE | Gig 05, arrival window title | The proving range
GIG05_HOOK | Gig 05, signal hint | A flat tone, struck once on the hour, and it stops in the middle of the count. The crew traced it to a test range the Bureau closed long ago. The old book would show who ran it and why they left. The Bureau still holds the file, and nobody has asked to see it.
GIG05_ARRIVE | Gig 05, arrival window text | A test range, long abandoned. Targets hang in a line. A rack of tools sits by the control hut, and a crane arm still holds a crate. You can take the rack, or follow the range book to where the last test was logged.
GIG05_A_BTN | Gig 05, button A | Strip the tool rack
GIG05_B_BTN | Gig 05, button B | Follow the range book
GIG05_A_OUT_MIL | Gig 05, outcome A, Military | Drill heads and clamps, in a rack made for one team. Each carries a mark. You do not read them aloud.
GIG05_A_OUT_MIN | Gig 05, outcome A, Minerals | Cutters, bits and a core drill, all heavy and oiled. The crane arm lets go of the crate. It floats away.
GIG05_B_OUT_MIL | Gig 05, outcome B, Military | The book ends at a bearing. You write it down, and a depot clerk pays a small sum for the page. The last test was never finished, and the book does not say why.
GIG05_B_OUT_MIN | Gig 05, outcome B, Minerals | The book ends at a rock field, with depths in pencil. You copy the page, and a claim office pays a small sum for it. The crate stays in the crane.
GIG05_EPI | Gig 05, epilogue line | The range is struck from the Plan. The targets are still hanging.

## GIG06 The sealed garden (Luxury, Biotech)

GIG06_TITLE | Gig 06, arrival window title | The sealed garden
GIG06_HOOK | Gig 06, signal hint | A soft chime, and behind it a faint warm light that no hull lamp makes. It is steady, like a window left lit in a dark street. The sealed garden was never put on a Plan, so no crew owes it a visit. The warm light shows on the board, and no ship has gone near.
GIG06_ARRIVE | Gig 06, arrival window text | A glass hull, fogged from inside. Green behind it, thick and still. A hatch will open for a cut flower, or for a full bag of the garden's seed. Either one means going in. Either one means leaving something behind.
GIG06_A_BTN | Gig 06, button A | Cut the best blooms
GIG06_B_BTN | Gig 06, button B | Bag the garden seed
GIG06_A_OUT_LUX | Gig 06, outcome A, Luxury | Pale petals the width of a hand, with a scent that stays on your sleeve for days. A buyer takes them at the dock for a small sum. The beds look bare behind you.
GIG06_A_OUT_BIO | Gig 06, outcome A, Biotech | Thick blooms, wet at the stem. Your gloves come out stained, and a clinic buys the blooms for a small sum. The beds look bare behind you.
GIG06_B_OUT_LUX | Gig 06, outcome B, Luxury | Fine seed, sorted by colour, each bag tied with thread. The hatch keeper asks a small toll, and you pay it. The beds stay green, but no one will cut them now.
GIG06_B_OUT_BIO | Gig 06, outcome B, Biotech | Seed in damp paper, each lot tagged by shelf. The hatch keeper asks a small toll, and you pay it. The beds stay green. The air inside smells close.
GIG06_EPI | Gig 06, epilogue line | The garden is listed as tended. No keeper is named on the page.

## GIG07 The Opening (T301, 2026-11-06; the win gig, one button, all four branches)
The last Bazaar stage is done. The Flagship flies the charter cargo to the capital. One button, no choice. Docking wins the run. No text names a good or a number. Where it shows (2026-11-11): at the Opening docking only. When the Flagship docks at the Bazaar capital with the charter cargo after the last Bazaar stage, the arrival window shows GIG07_TITLE and GIG07_ARRIVE with one button GIG07_A_BTN; the press shows GIG07_A_OUT_<branch> and then the win screen. GIG07_HOOK is the one-line hint on the board while the cargo is sealed.

GIG07_TITLE | Gig 07, arrival window title | The Opening
GIG07_HOOK | Gig 07, signal hint | The last hall is roofed, and the Bazaar has gone quiet. One crate sits sealed and signed at the dock, and the board holds it for the Flagship. Every hand that built the hall has put a name on it. No one will break the seal for anyone else.
GIG07_ARRIVE | Gig 07, arrival window text | The charter cargo is sealed and signed by every hand that built the hall. The crew lines the dock and no one speaks. Every lamp in the Bazaar is dark. It waits for one crate, carried in by you.
GIG07_A_BTN | Gig 07, button | Bring the crate in
GIG07_A_OUT_MIL | Gig 07, docking outcome, Military | The crate goes down the long hall in step. The seal breaks. The lamps come on one row at a time, and no one gives an order.
GIG07_A_OUT_LUX | Gig 07, docking outcome, Luxury | The crate goes in on a cloth of bright thread. The seal breaks, and a warm scent crosses the hall. The lamps come on.
GIG07_A_OUT_MIN | Gig 07, docking outcome, Minerals | The crate goes in heavy and slow on a flat cart. The seal breaks with a dull knock. The lamps come on, and the walls hum.
GIG07_A_OUT_BIO | Gig 07, docking outcome, Biotech | The crate goes in damp and warm. The seal breaks, and the air in the hall turns green and close. The lamps come on.
