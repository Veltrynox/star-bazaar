# Gigs (T217, draft 1)

Format: ID | place | text (one text per line). Limits by id suffix: _TITLE 32, _BTN 28 (written to 24), _HOOK 420, _EPI 140, everything else 280 (see GIG_TEXT_MAX in tools/build_story.py).
A gig is one signal in the Pathfinder's system. Hook: shown with the label "Signal" and the system name; the story stays hidden. Arrive: the window on arrival. Two neutral buttons, each gives something and costs something. Branch outcome ids end _OUT_MIL, _OUT_LUX, _OUT_MIN, _OUT_BIO (Military, Luxury, Minerals, Biotech); the game shows the one for the company's branch after the player picks A or B. Epilogue: one line, same for every branch.
No text names a good, a number, a skill point or a mechanic. The game picks what is given and taken (a small cash sum, a small lot of the branch's goods, a small fee, or Flagship idle time; data/gigs.json); the outcome lines only describe the scene and may say "a small sum", "a small fee" or "a lot". Updated 2026-11-11: the outcome lines of GIG01 to GIG06 now match those rewards.

## GIG01 The wreck of the Ninth Tally (ship crash, salvage)

GIG01_TITLE | Gig 01, arrival window title | Mera's sealed hold
GIG01_HOOK | Gig 01, signal hint | The Ninth Tally's beacon is still calling. Freight clerk Pell sends you its last crew list. Her sister Mera signed the final shift. Pell has rubbed a hole beside that name. Other ships have logged the signal and gone on. She asks you to look.
GIG01_ARRIVE | Gig 01, arrival window text | The Ninth Tally is split along its spine. Mera's coat lies tucked into an empty bunk. Cutting the hold free keeps the Flagship here a while. Pulling the flight log is quick and earns a small sum. Then you leave the cargo sealed inside.
GIG01_A_BTN | Gig 01, button A | Cut into the hold
GIG01_B_BTN | Gig 01, button B | Take the flight log
GIG01_A_OUT_MIL | Gig 01, outcome A, Military | The depot accepts the sealed crates. Cutting them free kept the Flagship at the wreck a while. Iven rubs the depot stamp with his thumb. Mera's coat stayed in its bunk.
GIG01_A_OUT_LUX | Gig 01, outcome A, Luxury | The lot is wrapped for a buyer who never came. Iven finds Mera's name sewn into the cloth. Cutting it free kept the Flagship there a while. The empty bunks stay behind.
GIG01_A_OUT_MIN | Gig 01, outcome A, Minerals | Iven lifts the heavy crates free. Grey dust fills the seams of his gloves. The lot is yours. The Flagship has spent time at the wreck, and Mera's flight log stays unread.
GIG01_A_OUT_BIO | Gig 01, outcome A, Biotech | The sealed tubs are still warm. Iven keeps his hands round a lid until the lift takes it. The lot is yours. The Flagship has waited through the work. Mera's bunk stays empty.
GIG01_B_OUT_MIL | Gig 01, outcome B, Military | A depot clerk pays a small sum for the log. Mera wrote the last order over a torn line. You send Pell a copy. The hold stays sealed when you leave.
GIG01_B_OUT_LUX | Gig 01, outcome B, Luxury | A broker pays a small sum for the log of ports and buyers. Mera pressed hard enough to mark the next page. Pell gets a copy. The cargo stays behind its seal.
GIG01_B_OUT_MIN | Gig 01, outcome B, Minerals | A claim office pays a small sum for the log of claims and loads. Mera's pencil stops at an empty weight box. You send Pell the page. The hold stays sealed.
GIG01_B_OUT_BIO | Gig 01, outcome B, Biotech | A clinic pays a small sum for the log of cold stops. Mera underlined the stop where cooling failed. You send Pell a copy. The cargo stays sealed inside.
GIG01_EPI | Gig 01, epilogue line | The Bureau thanks Pell for her letter. The Ninth Tally remains overdue. She folds the reply along the crew list's crease.

## GIG02 The relay keeper (a lamp still lit)

GIG02_TITLE | Gig 02, arrival window title | Orven's relay lamp
GIG02_HOOK | Gig 02, signal hint | Orven's lamp still marks the way through the debris. The Bureau lists his relay as closed. His pay stopped with that line. His voice comes through after the signal. He asks which dock still takes passengers. You hear him set the radio down before he coughs.
GIG02_ARRIVE | Gig 02, arrival window text | Orven grips the lamp switch with a cloth round his hand. Take him home for a small dock fee, and he gives you his stores. The lamp goes dark. Keep his shift and earn a small sum. The Flagship waits while he sleeps. He will still be the keeper.
GIG02_A_BTN | Gig 02, button A | Bring him to dock
GIG02_B_BTN | Gig 02, button B | Take his lamp shift
GIG02_A_OUT_MIL | Gig 02, outcome A, Military | Orven gives you the relay's depot crates. You pay a small dock fee for him. He keeps the switch cloth in his fist through the flight. Behind you, the lamp goes dark. Ships must go round the debris.
GIG02_A_OUT_LUX | Gig 02, outcome A, Luxury | Orven gives you the parcels traders left him. The gift tags are still tied on. You pay his small dock fee. He stands by the hatch until it opens. Behind you, the unlit passage must wait.
GIG02_A_OUT_MIN | Gig 02, outcome A, Minerals | Orven gives you the relay's marked sacks. He checks each weight with a finger. You pay a small dock fee to bring him home. The lamp is out. Ships must take the way round.
GIG02_A_OUT_BIO | Gig 02, outcome A, Biotech | Orven gives you his sealed jars. A ring on the shelf shows where each stood. You pay a small dock fee for him. He steps ashore. The lamp stays dark behind you.
GIG02_B_OUT_MIL | Gig 02, outcome B, Military | The Flagship waits through Orven's shift. Haulers leave a small sum in the lamp box. Their depot marks fill his log. He wakes with the switch cloth pressed to his cheek. You give him back the watch.
GIG02_B_OUT_LUX | Gig 02, outcome B, Luxury | The Flagship waits while Orven sleeps. Traders leave a small sum in the lamp box. Their buyers' names fill his log. He wakes and smooths his coat before taking the switch from you.
GIG02_B_OUT_MIN | Gig 02, outcome B, Minerals | You keep the lamp while Orven sleeps. Haulers leave a small sum and log their loads. The Flagship waits through the shift. He wakes and checks the pencil weights before he sits down at the switch.
GIG02_B_OUT_BIO | Gig 02, outcome B, Biotech | The Flagship waits through the watch. Haulers leave a small sum and log their cold cargo. Orven sleeps with his hand curled round nothing. When he wakes, you place the switch cloth back in it.
GIG02_EPI | Gig 02, epilogue line | The Bureau's closed-relay form has no space for Orven's name. Passing crews still use it when they call.

## Phase 2 signals (T275, 2026-11-06). GIG03 and GIG04 are shared: all four branch outcomes. GIG05 (Military and Minerals) and GIG06 (Luxury and Biotech) are branch gigs: outcome lines only for those two branches, and the game offers each only to a company with that branch.

## GIG03 The unused charter (a Bureau pod adrift)

GIG03_TITLE | Gig 03, arrival window title | The blank world line
GIG03_HOOK | Gig 03, signal hint | A Bureau pod calls for a desk that no longer exists. Clerk Edrin signed its last receipt. Below his name, someone wrote that the charter had not reached its world. The paper shows a cup ring. The pod has kept calling since that desk was cleared.
GIG03_ARRIVE | Gig 03, arrival window text | Edrin's charter lets a world produce more and store more. Its world line is blank, worn thin by an eraser. Claim it for a world you choose, and the Flagship waits longer. Copy the ledger for a small sum, and it waits a while. The charter stays here.
GIG03_A_BTN | Gig 03, button A | Keep the charter
GIG03_B_BTN | Gig 03, button B | Sell a ledger copy
GIG03_A_OUT_MIL | Gig 03, outcome A, Military | You keep the charter for a world you choose. It will let that world produce more and store more. The Flagship waits while Iven checks the yard seal. Edrin left the world line blank. Your crew holds the pen now.
GIG03_A_OUT_LUX | Gig 03, outcome A, Luxury | The charter is yours to use at a world you choose. It lets that world produce more and store more. The Flagship waits through the claim. Iven puts a cloth under Edrin's page before he lifts it.
GIG03_A_OUT_MIN | Gig 03, outcome A, Minerals | You claim the charter for a world you choose. It lets that world produce more and store more. The Flagship waits through the work. Iven traces the old load stamp. Edrin's blank world line is still yours to fill.
GIG03_A_OUT_BIO | Gig 03, outcome A, Biotech | You keep the charter for a world you choose. It lets that world produce more and store more. The Flagship waits through the claim. A green shelf mark rubs off on Iven's hand. He holds the page by its edges.
GIG03_B_OUT_MIL | Gig 03, outcome B, Military | The Flagship waits while you copy each drop and handler. A depot clerk pays a small sum. Edrin's signature shows through the thin page. You leave the charter blank and close the pod.
GIG03_B_OUT_LUX | Gig 03, outcome B, Luxury | A broker pays a small sum for the names of gift senders and those still owed. The Flagship waits while you copy them. Iven flattens a folded corner. Edrin's charter stays blank in the pod.
GIG03_B_OUT_MIN | Gig 03, outcome B, Minerals | A claim office pays a small sum for the ledger's loads and weights. The Flagship waits while you copy them. Edrin's pencil wore through the last total. You leave the blank charter in the pod.
GIG03_B_OUT_BIO | Gig 03, outcome B, Biotech | The Flagship waits while you copy each shelf and batch. A clinic pays a small sum. Edrin's hand grew cramped near the end. Iven closes the cover. The blank charter stays in the pod.
GIG03_EPI | Gig 03, epilogue line | The Bureau thanks you for finding the pod. Edrin's last receipt stays attached to a desk that no longer exists.

## GIG04 The empty berth (a station that kept the lights)

GIG04_TITLE | Gig 04, arrival window title | Sella has set the table
GIG04_HOOK | Gig 04, signal hint | A voice gives her name as Sella and offers your crew a berth. The station lies off every lane. Her call leaves no gap for an answer. Iven starts to ask whether anyone is there. She tells him the table is ready. He keeps his hand on the radio.
GIG04_ARRIVE | Gig 04, arrival window text | Sella's voice welcomes you to empty berths. A spoon rests across a bowl at the head of the table. Take the pantry stores and pay a small berth fee. Or stay for the meal and a small sum. The Flagship waits while her voice fills the empty seats.
GIG04_A_BTN | Gig 04, button A | Take the stores
GIG04_B_BTN | Gig 04, button B | Eat at the table
GIG04_A_OUT_MIL | Gig 04, outcome A, Military | You take the sealed depot packs and pay the small berth fee. Sella thanks Iven for each load. He reaches to put away a bowl. Her voice asks him to leave it where it is.
GIG04_A_OUT_LUX | Gig 04, outcome A, Luxury | You take the wrapped pantry parcels and pay the small berth fee. Sella reads each label aloud. Iven brushes a place card with his sleeve. No guest comes to claim it.
GIG04_A_OUT_MIN | Gig 04, outcome A, Minerals | You load the stores and tool kits, then pay the small berth fee. Sella thanks the crew by the hatch. Iven folds the grease paper over an empty shelf. The table stays set.
GIG04_A_OUT_BIO | Gig 04, outcome A, Biotech | You take the sealed jars and pay the small berth fee. Sella reads the shelf labels as you work. Iven finds a thumbprint under a lid. The voice asks whether your crew will stay. You close the hatch.
GIG04_B_OUT_MIL | Gig 04, outcome B, Military | The Flagship waits while you eat. Sella names the crews on the old patrol line. A drawer holds a small sum for your visit. Iven leaves his chair pulled out when you go. No other chair has moved.
GIG04_B_OUT_LUX | Gig 04, outcome B, Luxury | You stay for the meal. Sella reads the old guests' orders. A drawer holds a small sum for your visit. The Flagship has waited through the talk. Iven folds his napkin beside an untouched place.
GIG04_B_OUT_MIN | Gig 04, outcome B, Minerals | The Flagship waits while Sella names the crews who cut the nearby rock. You eat and take the small sum left for your visit. Iven lays his spoon across his bowl. The other spoons have not moved.
GIG04_B_OUT_BIO | Gig 04, outcome B, Biotech | You stay while Sella tells you which garden beds failed. The Flagship waits through the meal. You take the small sum left for your visit. Iven holds his cup until her voice starts the welcome again.
GIG04_EPI | Gig 04, epilogue line | Sella calls after you to mind the step. The Bureau's list has no keeper at that station. Iven checks the name again.

## GIG05 The proving range (Military, Minerals)

GIG05_TITLE | Gig 05, arrival window title | Dena's last test
GIG05_HOOK | Gig 05, signal hint | The range tone stops before its check is done. Shift chief Dena signed the last test book. The Bureau can send a copy when your request reaches the desk. Iven listens to the tone again. He knows the pause where a crew should answer.
GIG05_ARRIVE | Gig 05, arrival window text | Dena's glove hangs from a tool rack. Beyond it, targets wait for the last test. Strip the rack for a lot, and the Flagship waits a while. Follow her book for a small sum, and it waits longer. The rack stays here. Iven rests his hand on the gate.
GIG05_A_BTN | Gig 05, button A | Take the tools
GIG05_B_BTN | Gig 05, button B | Trace the last test
GIG05_A_OUT_MIL | Gig 05, outcome A, Military | The Flagship waits while Iven frees the lot from the rack. Dena scratched crew names into the clamps. He turns each name inward before stacking it. The last test stays unread.
GIG05_A_OUT_MIN | Gig 05, outcome A, Minerals | You take the heavy cutters and drill. The Flagship waits through the work. Iven leaves Dena's glove on its hook. The crane still holds its crate. No hand comes to lower it.
GIG05_B_OUT_MIL | Gig 05, outcome B, Military | The Flagship waits while you follow Dena's last test bearing. A depot clerk pays a small sum for the page. Iven holds a finger beneath the final blank line. The tools stay on their rack.
GIG05_B_OUT_MIN | Gig 05, outcome B, Minerals | The Flagship waits while you follow Dena's notes into the rock field. A claim office pays a small sum for the copied depths. Her pencil snapped at the last mark. The crane keeps its crate.
GIG05_EPI | Gig 05, epilogue line | The Bureau confirms that the range is closed. Dena's last test still has a space for the crew to sign.

## GIG06 The sealed garden (Luxury, Biotech)

GIG06_TITLE | Gig 06, arrival window title | Vela's garden hatch
GIG06_HOOK | Gig 06, signal hint | A garden glows behind a glass hull. No visit is owed to it under the Plan. A chime brings a voice to the radio. Vela asks whether you have come for flowers or seed. Iven wipes the screen where her hand leaves a print. The print is on her side.
GIG06_ARRIVE | Gig 06, arrival window text | Vela opens the fogged hatch with a sleeve over her hand. Cut blooms for a small sum, and the Flagship waits through the work. Or pay a small toll for a bag of seed. The beds stay green. Vela keeps the shears on the table between you.
GIG06_A_BTN | Gig 06, button A | Cut the blooms
GIG06_B_BTN | Gig 06, button B | Take the seed
GIG06_A_OUT_LUX | Gig 06, outcome A, Luxury | The Flagship waits while you cut. A dock buyer pays a small sum for the blooms. Their scent stays in Iven's sleeve. Vela takes the shears back. The bare beds show where he stood.
GIG06_A_OUT_BIO | Gig 06, outcome A, Biotech | The Flagship waits through the cutting. A clinic pays a small sum for the blooms. Iven scrubs a stain from his glove. Vela lays the shears down beside the beds you left bare.
GIG06_B_OUT_LUX | Gig 06, outcome B, Luxury | You pay Vela's small toll and take the bags of seed. She ties each bag with thread from her sleeve. The beds stay green. She puts the unused shears back in their drawer.
GIG06_B_OUT_BIO | Gig 06, outcome B, Biotech | You pay Vela's small toll for the seed lot. She folds damp paper round each bag. Iven cups his hands beneath them. The beds stay green behind the hatch. The shears have not moved.
GIG06_EPI | Gig 06, epilogue line | The garden is listed as tended. Vela asks you to add her name. There is room below the stamp.

## GIG08 The drive yard (Military)
Branch gig, Military only: outcome lines for Military only. Option A permanently raises the Flagship's top speed to the Dart's. Option B gives a small sum of cash. A costs the scout a long wait, B a short one.

GIG08_TITLE | Gig 08, arrival window title | Renn's waiting drive
GIG08_HOOK | Gig 08, signal hint | Renn still runs the yard's test drive. The Bureau closed the yard after the drive proved faster than the approved hulls. He sends you the fit sheet with a thumbprint in oil. The drive would fit your Flagship. A buyer has asked him to stop the test.
GIG08_ARRIVE | Gig 08, arrival window text | Renn has kept the drive on its cradle. An oil ring marks where his cup stood. Fit it and the Flagship flies as fast as a Dart for good. The work takes a long wait. Sell it for a small sum and wait less. Renn holds out the buyer's note.
GIG08_A_BTN | Gig 08, button A | Fit the drive
GIG08_B_BTN | Gig 08, button B | Sell it to the buyer
GIG08_A_OUT_MIL | Gig 08, outcome A, Military | Renn's crew fits the drive through a long wait. The Flagship now flies as fast as a Dart, for good. Iven sets his cup on the deck. For the first time, it stays where he puts it. The spare plates stay in the yard.
GIG08_B_OUT_MIL | Gig 08, outcome B, Military | After a brief wait, a depot clerk pays a small sum for the drive. Renn wipes the cradle where it stood. The Flagship leaves at its old speed. Iven lifts his cup before the deck starts to shake.
GIG08_EPI | Gig 08, epilogue line | The Bureau's yard file stays closed. Renn sends the crew a copy of the fit sheet, with the oil mark still on it.

## GIG07 The Opening (T301, 2026-11-06; the win gig, one button, all four branches)
The last Bazaar stage is done. The Flagship flies the charter cargo to the Star Bazaar station. One button, no choice. Arriving at the station wins the run. No text names a good or a number. Where it shows (2026-11-11): at the Opening docking only. When the Flagship reaches the Star Bazaar station with the charter cargo after the last Bazaar stage, the arrival window shows GIG07_TITLE and GIG07_ARRIVE with one button GIG07_A_BTN; the press shows GIG07_A_OUT_<branch> and then the win screen. GIG07_HOOK is the one-line hint on the board while the cargo is sealed.

GIG07_TITLE | Gig 07, arrival window title | The charter at the door
GIG07_HOOK | Gig 07, signal hint | The last hall has a roof. The charter cargo waits for the Flagship at the dock. Every hand that built the Star Bazaar has signed its crate. Iven points to his name under a patch of dried glue. The hall lamps are dark. The crew waits for you to bring it in.
GIG07_ARRIVE | Gig 07, arrival window text | The Flagship docks with the signed charter cargo. The crew stands along the hall they built. Iven wipes his hands before taking the crate. Beyond him, the Star Bazaar's lamps are dark. You reach for the other handle. The crew makes room.
GIG07_A_BTN | Gig 07, button | Carry the crate in
GIG07_A_OUT_MIL | Gig 07, docking outcome, Military | You carry the crate with Iven. He waits for the crew to gather before he breaks the seal. The hall lamps come on. He puts the lid down where every name can still be read. No order follows.
GIG07_A_OUT_LUX | Gig 07, docking outcome, Luxury | Iven spreads a cloth beneath the crate. You break the seal. A warm scent reaches the crew at the door. The lamps come on. He smooths the cloth where a builder has rested a hand.
GIG07_A_OUT_MIN | Gig 07, docking outcome, Minerals | You push the loaded cart beside Iven. He braces a foot against the wheel while you break the seal. The lamps come on. He holds the cart a moment longer, then lifts his foot.
GIG07_A_OUT_BIO | Gig 07, docking outcome, Biotech | The crate leaves a damp square on Iven's coat. You break the seal together. Warm air reaches the crew at the door. The lamps come on. He leaves his coat over the cart and goes to meet them.
