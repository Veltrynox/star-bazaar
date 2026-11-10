# Star Bazaar: five new endings per CEO (2026-11-09)

Author: story-designer. PROPOSAL ONLY. Nothing is built. No story/*.md, story/ru, data/, game/ or gdd file was touched. No number is given for a threshold: each is a balance key marked UNKNOWN for the economy owner. English only.
Read: CLAUDE.md, gdd.md (skimmed by the brief), story/endings.md, story/voice.md, data/ceos.json, game/ending_picker.gd, game/end_screen.gd, game/main.gd (`ending_id_of`, `_finish_outcome`, `_finish`, route start near line 1192), game/conditions.gd, game/bazaar.gd (`recap`), game/chains.gd (`decisive_moments`, `marks`), game/gigs.gd (counters), and the two proposals written today (CEO events, LUX_1 connections).
Fit with today's other proposals: the CEO events proposal supplies the pay/bear, world and goods/credits choices (section 3, driver D6). The LUX_1 proposal supplies the "worlds that know you" idea, which ending IDRIS_WIDE echoes through established worlds. If either is rejected, only the driver or one condition in this file changes; no text claims a mechanic that those proposals add.

## 1. How endings are picked today, and how new ones plug in

Facts from the code:
- A run ends in exactly one of three kinds (`ending_id_of`, game/main.gd): `bazaar` (the Opening, a win), `bankrupt` (no ship left, cash below zero), anything else is `unfinished` (term ended before the Opening).
- A win gives `END_<BRANCH>_<GOOD|BAD>`. The branch is the CEO's market (`run_branch()`), the flag is the hidden chain lean (`Chains.ending_flag`). So today every run of one CEO ends in one of two texts. Nothing a player did outside the chain choices changes it.
- Skills learned do not choose the ending. They only add epilogue lines (`EndingPicker.inputs`: capstone, techs done 0 to 3, a broken house tier) under the text. Stages, capital, wings, worlds per tier, reclaimed worlds and the three most decisive chain moments are drawn as a recap block above it (`recap`, `_recap_block`).
- There is no priority list, no tie-break and no multi-match: one formula, one id. `end_screen.show_ending` looks up `<id>_TITLE` and `<id>` and falls back to the GOOD text if a `_BAD` text is missing.
- `RunStats.record(side, ending_id, ...)` stores the id, so a new id is recorded for free.

How new endings plug in (proposed):
1. Only a `bazaar` win can choose a CEO ending. Bankrupt and unfinished are untouched (a possible later addition, see section 8).
2. New data file `data/endings.json` (programmer's call on the name): an ordered list per CEO, each row `{id, visible_when, requires}`. `visible_when` is `branch_is:<market>` so a CEO's ending can never show in another CEO's run. `requires` is a condition tree in the existing grammar (`game/conditions.gd`).
3. Pick rule: walk the rows of the run's CEO in file order. The first row whose `requires` holds wins. If none holds, use today's `END_<MKT>_GOOD` or `_BAD`. This is the fallback ending: it is always reachable, so every win lands on some ending.
4. Several can match. Priority is the file order (strongest and rarest memory first). Tie-break is that same order. The runner-up is not shown (an optional runner-up epilogue line is an idea, section 8).
5. The hidden chain lean stays as it is. It still decides GOOD or BAD for the fallback. The five new endings are written neutral: they do not say whether the market world is kind or cruel. Open question 1 asks whether the owner wants the lean to colour them as well.
6. Skills shape the endings by two routes: as `requires` terms (`skill_learned:<node>`, an existing atom) and through the existing epilogue lines, which still print under any win text. No change to the epilogue code.
7. The end screen needs no change except a lookup: `ending_id_of` calls the new picker, and the screen already reads `<id>_TITLE`, `<id>` and `EPI_*`. One epilogue line is added per new ending (`EPI_<MKT>_<KEY>`, one line, max 140), shown first among the epilogue lines. Programmer to confirm that the line cap of four still holds.

New condition atoms (the only grammar change, two atoms):
- `note_at_least:<key>/<balance>` true when the run note `<key>` is at least the value of the balance key.
- `note_at_most:<key>/<balance>` the same, at most.
"Run notes" are the counters of section 3. Derived notes are computed at `_finish` and are not saved. No other atom is needed: `skill_learned`, `branch_is`, `bazaar_stage`, `any_tier` and `planet_tier` already exist.

## 2. Voice rules used

Bodies are 320 to 435 characters (limit 1000, market ending; checked with awk, all 20 bodies, titles and epilogues are within their limits). Titles are 40 or fewer. Epilogue lines are 140 or fewer. Short sentences, plain words, no digits, no dashes, no exclamation marks, no number that is not a count in the game. The CEO may be named (the CEO events proposal does it); the player stays "you" and "the company". Only energy, food, Voltara, Tillam, Ashgate, the Bazaar, the Flagship and the grey worlds are named. No market good, workshop or storage feature that may be hidden is named. Space Storage is a Foundation skill, drawn from the start, and is named only in BIO_PANTRY, which requires it. The grey worlds are named only in MIN_DEEP, which requires a mining platform. Feeling comes from what a hand or a body does.

## 3. Decision drivers (what to record)

"Run notes" is one small dictionary on Main, saved with the game under one key, default empty. An old save loads with all zeros, so an old run drifts to the fallback ending (honest, harmless). Total new saved state: 9 integers in one dictionary. Derived notes cost nothing to save.

| Id | Note key | What it counts | Source today | Where to count | Saved | Cost |
|---|---|---|---|---|---|---|
| D1 | `quick_routes`, `card_routes` | routes made from the right-click resource popup vs from the planet card | `pending.quick` already exists | game/main.gd where the route is made (about line 1192): `if quick: quick_routes += 1 else: card_routes += 1`. A lane that only adds a ship counts too | 2 ints | XS |
| D2 | `explored`, `established` | worlds the Flagship has visited (Explore on), worlds with a post or platform | `Pathfinder` (planet_visited, post_built, platform_built) | derived at `_finish`; also `platforms` (mining platforms only) | none | XS |
| D3 | `rush_done` (exists), `rush_expired` (new) | rush orders delivered, rush orders that ran out of time (deadlines are now x1.5 longer, so expiry is a real miss) | `Gigs.rush_done` exists. Expiry has no counter. `skipped` counts signals only | game/gigs.gd, where an open rush offer passes its `due` and is removed: `rush_expired += 1`. Add `rush_done` to the note dictionary at finish (verify that Gigs saves it) | 1 int | XS |
| D4 | `restless_cycles` | world-cycles in which a world was Restless (a need was short at cycle end; needs are per cycle and shown as delivered/wanted) | `Prosperity._restless` is the live set; no history | game/prosperity.gd at cycle end: `restless_cycles += _restless.size()`. Hungry is the same event; one counter serves both words | 1 int | XS |
| D5 | `stages`, `wings`, `worlds_city` | Star Bazaar stages built, wings picked, worlds at a high tier (balance key) | `Bazaar.recap()` already returns stages, wings, worlds_per_tier. Quorum is a gate on a stage, so a win already means it was met | derived at `_finish` from `recap`; `worlds_city` is the sum of `worlds_per_tier` at or above `end_city_tier` | none | XS |
| D6 | `ceo_paid`, `ceo_bore`, `ceo_goods`, `ceo_cash` | CEO event choices by kind: paid credits to avoid a cost, bore the cost, took goods, took credits. World choices (which dock) are not counted, they are symmetric | none yet. The CEO events proposal adds the events | the chosen option row gets a `pick` key (`pay`, `bear`, `goods`, `cash`, `world`) in the events data; main.gd adds 1 to the matching note when a choice is applied | 4 ints | S |
| D7 | `peak_ships`, `ships_end` | most ships owned at once; ships owned at the end. Upkeep is paid per ship, so fleet size is the honest proxy | `ships` (game/main.gd) exists, no peak | `peak_ships = max(peak_ships, ships)` where ships rise (buy, rescue); `ships_end` is derived. `repossessions` already exists and is saved; it is copied into the notes at finish | 1 int | XS |
| D8 | `space_cycles` | cycles that ended with goods held in the Space Storage | storage already knows | game/storage.gd or main cycle end: `if space_total() > 0: space_cycles += 1` | 1 int | XS |
| D9 | `warm_worlds` | worlds that show a Warm face at the end (the face is already on the planet card) | `Chains.marks`, mood thresholds | derived at `_finish`; no save | none | S |
| D10 | skills learned | which nodes and how many per market | `Skills.is_learned` | no note; `skill_learned:<node>` atoms | none | none |

Why these and not others: each one is already visible to the player (route notices, Explore, the gig board, Restless card line, the Bazaar card, the Ships menu, the Space Storage panel, the face on a card), so the ending never counts something the player could not see. Rejected as not cheap or not honest: counting favoured worlds in world choices (symmetric, needs per-world state), counting individual planet-card visits (noise), time spent paused, and counting hand trades on the Flagship dock sheet (high volume, no clear meaning).

Balance keys (all UNKNOWN, economy owner; suggested role only):
`end_quick_min`, `end_card_min`, `end_card_quick_max` (route habit); `end_rush_min`, `end_rush_expired_max` (gig discipline); `end_restless_high`, `end_restless_low` (needs, in world-cycles, about the share of the run a world sat short); `end_explored_min`, `end_established_wide`, `end_established_few` (reach); `end_city_tier`, `end_city_worlds` (growth); `end_paid_min`, `end_bore_min`, `end_cash_min` (event habit, each is "most of the picks of that kind"); `end_fleet_big`, `end_fleet_lean` (ships); `end_space_min`; `end_warm_min`. Thresholds should be set so that each ending fires in a minority of that CEO's runs. Suggested design target for the economy owner: no single ending above about a third of its CEO's wins, the fallback below about a fifth.

## 4. Endings by CEO

Format: id, what the ending needs (`requires`), then each text block as `ID | limit | place`. Priority is the order they are listed. Every `requires` is also gated by `branch_is:<market>`.

### 4.1 Marek Voss, Minerals (branch `min`)
Order: LONGSHIFT, DEEP, PICKUP, PAGE, THIN, then fallback `END_MIN_GOOD` or `END_MIN_BAD`.

**END_MIN_LONGSHIFT** requires: `note_at_least:restless_cycles/end_restless_high`.
END_MIN_LONGSHIFT_TITLE | 40 | End screen heading, Marek, many Restless cycles
The Long Shift
END_MIN_LONGSHIFT | 1000 | End screen body, Marek, many Restless cycles
The Bazaar opened. On the worlds along the way, for a long while, the lights were low. Needs went unmet cycle after cycle, and people made do, because people do. Marek read every report. He did not look away from any of them. The doors are open now and the halls are full. Some of the faces in them remember the hungry cycles, and some of those faces are kind. Marek keeps the old reports in a drawer, and does not throw them out.
EPI_MIN_LONGSHIFT | 140 | Epilogue 1, Marek, many Restless cycles
Marek signs the opening page last. His hand does not shake. He holds the pen a little longer than he needs to.

**END_MIN_DEEP** requires: `note_at_least:platforms/1` and `note_at_least:skills_min/end_skills_min` (learned nodes in the Minerals tree; derived).
END_MIN_DEEP_TITLE | 40 | End screen heading, Marek, mining platforms and a deep Minerals tree
Down the Seams
END_MIN_DEEP | 1000 | End screen body, Marek, mining platforms and a deep Minerals tree
The grey worlds are working now. Platforms sit on rock that nobody listed as home, and the crews who run them sleep with the dust on their sleeves. Marek went down to see the first cut himself. He did not say much. He picked up a handful of the stone and put it back where it was. The Bazaar stands because of what came out of the dark. Someone has to remember that, and he does.
EPI_MIN_DEEP | 140 | Epilogue 1, Marek, platforms and a deep Minerals tree
A lamp burns on a platform nobody visits. The crew who keep it call it the porch.

**END_MIN_PICKUP** requires: `note_at_least:rush_done/end_rush_min` and `note_at_least:quick_routes/end_quick_min`.
END_MIN_PICKUP_TITLE | 40 | End screen heading, Marek, many rush orders and quick routes
The Man Who Picked Up
END_MIN_PICKUP | 1000 | End screen body, Marek, many rush orders and quick routes
When the call came, Marek answered. A rush order at Ashgate, a late food run at Tillam, a world short on energy and asking only once. He did not always have the hold for it. He made the hold. The Bazaar opened on a long list of small yeses. Nobody will carve them into a wall. The people who got their goods on time will remember, which is how a name lasts here. The old yard man sends a note. It has one line. It says, you picked up.
EPI_MIN_PICKUP | 140 | Epilogue 1, Marek, rush orders and quick routes
Every rush order on the board has the same reply scratched under it, in Marek's hand. It says, on its way.

**END_MIN_PAGE** requires: `note_at_least:ceo_paid/end_paid_min` and `note_at_most:repossessions/0`.
END_MIN_PAGE_TITLE | 40 | End screen heading, Marek, paid what was owed, nothing taken
Every Crate Written Down
END_MIN_PAGE | 1000 | End screen body, Marek, paid what was owed, nothing taken
The last page is signed, and it balances. Marek checks it twice, then a third time, because that is who he is. Every fee was paid on the day it fell due. Every crate was counted going out and counted coming in. The clerks at the yards stopped asking for proof. They ask how he is. The Bureau has no form for what that is worth. Marek writes the sum in his own book, in pencil, and leaves it blank.
EPI_MIN_PAGE | 140 | Epilogue 1, Marek, paid what was owed
The yard clerks keep a chair for Marek. It is the one with the good cushion. He sits on the edge.

**END_MIN_THIN** requires: `note_at_most:peak_ships/end_fleet_lean`.
END_MIN_THIN_TITLE | 40 | End screen heading, Marek, a small fleet
The Thin Fleet
END_MIN_THIN | 1000 | End screen body, Marek, a small fleet
You won with fewer hulls than anyone thought it could take. Every ship ran full and came home. Nothing sat at a dock, eating upkeep. The crew ate at one table all the way, and the table never grew too big to pass the bread. Marek calls it arithmetic. The crew calls it being looked after. The Bureau notes that the fleet is small and asks, politely, whether more is planned. It is not.
EPI_MIN_THIN | 140 | Epilogue 1, Marek, a small fleet
The ships are few and well used. Each has a name the crew can say without looking.

### 4.2 Idris Kane, Luxury (branch `lux`)
Order: WIDE, FLEET, FULLTABLE, LIGHT, CORNER, then fallback `END_LUX_GOOD` or `END_LUX_BAD`.

**END_LUX_WIDE** requires: `note_at_least:established/end_established_wide` and `skill_learned:LUX_1`.
END_LUX_WIDE_TITLE | 40 | End screen heading, Idris, many worlds reached, LUX_1 learned
Everyone Knows the Smile
END_LUX_WIDE | 1000 | End screen body, Idris, many worlds reached, LUX_1 learned
Idris did not sell to one world. He sold to all of them, a little at a time, and each one told the next. By the day the Bazaar opened, a dock clerk on the farthest post knew the smile and had never seen it. Doors opened wherever your ships landed. Idris takes the credit for the smile and none for the luck. He stands in the doorway and shakes every hand, because someone made the trip.
EPI_LUX_WIDE | 140 | Epilogue 1, Idris, many worlds reached
Letters come from posts you never saw. Most say only that the writer heard the name and wanted to say hello.

**END_LUX_FLEET** requires: `note_at_least:peak_ships/end_fleet_big`.
END_LUX_FLEET_TITLE | 40 | End screen heading, Idris, a large fleet
A Hull for Every Guest
END_LUX_FLEET | 1000 | End screen body, Idris, a large fleet
The hangar is loud. Ships come and go all day, one for each lane, and Idris greets every pilot by name. The fleet was never cheap to keep. Ship upkeep was a weight the crew felt on every payday. But the lanes ran, and a world that waits for a ship forgives a lot. At the Opening Idris stood on the dock and counted the hulls. He lost count, and was glad.
EPI_LUX_FLEET | 140 | Epilogue 1, Idris, a large fleet
Pilots pass in the corridor and nod at each other. It is the sound of a company that is never alone.

**END_LUX_FULLTABLE** requires: `note_at_least:rush_done/end_rush_min` and `note_at_most:rush_expired/end_rush_expired_max`.
END_LUX_FULLTABLE_TITLE | 40 | End screen heading, Idris, rush orders filled in time
A Seat Always Free
END_LUX_FULLTABLE | 1000 | End screen body, Idris, rush orders filled in time
Every order that came to the board was filled before its time ran out. Buyers learned that when Idris said yes, the goods arrived, and they stopped asking twice. One table at the Bazaar stays empty at the end of the night. It is kept for whoever needs a good by morning. Idris does not call it a plan. He calls it manners.
EPI_LUX_FULLTABLE | 140 | Epilogue 1, Idris, rush orders filled in time
The empty table has a card on it. The card is blank on purpose, and someone fills it in each morning.

**END_LUX_LIGHT** requires: `note_at_least:ceo_cash/end_cash_min`.
END_LUX_LIGHT_TITLE | 40 | End screen heading, Idris, took credits over goods
Light Hands
END_LUX_LIGHT | 1000 | End screen body, Idris, took credits over goods
Idris took the credits every time. A gift is polite to accept, and credits are easy to spend, and he spent them well: a round of lunches, a round of favours, a small loan to a buyer who needed it. The Bazaar opened with no crates of keepsakes in its cellar. It opened with a great many people who owe Idris a lunch. He has not decided which is worth more. He picks up the bill.
EPI_LUX_LIGHT | 140 | Epilogue 1, Idris, took credits over goods
The ribbons are all gone. A few buyers wear the ones they kept, tied loosely, in case Idris asks.

**END_LUX_CORNER** requires: `note_at_most:established/end_established_few`.
END_LUX_CORNER_TITLE | 40 | End screen heading, Idris, few worlds, known well
The Corner Table
END_LUX_CORNER | 1000 | End screen body, Idris, few worlds, known well
You kept to a few worlds, and you knew each one well. Idris read their boards like faces and sold to them as if each buyer were his only guest. The Bazaar stands on those few worlds, and they hold it up. The far posts never heard the name. Maybe that is the cost. Idris does not mind. He has a corner table, a clear view of the door, and a smile that never wore thin.
EPI_LUX_CORNER | 140 | Epilogue 1, Idris, few worlds
Three docks know his name, and each has kept a chair. He has not yet sat in all of them.

### 4.3 Sela Oru, Military (branch `mil`)
Order: SCARS, NOIDLE, WAIT, HARD, WATCH, then fallback `END_MIL_GOOD` or `END_MIL_BAD`.

**END_MIL_SCARS** requires: `note_at_least:repossessions/1`.
END_MIL_SCARS_TITLE | 40 | End screen heading, Sela, a ship was repossessed
The Hull She Lost
END_MIL_SCARS | 1000 | End screen body, Sela, a ship was repossessed
A ship was taken, and the crew felt the dock go quiet. Sela went to see the empty berth herself. She did not look away. The Bureau took what the debt asked, in its slow polite way, and left the rest. You rebuilt from what was left. The Bazaar opened with fewer hulls than the plan. The berth is still empty. Someone leaves a lamp there, and Sela does not ask who.
EPI_MIL_SCARS | 140 | Epilogue 1, Sela, a ship was repossessed
She still checks the empty berth before every long flight. The lamp is always lit.

**END_MIL_NOIDLE** requires: `note_at_least:rush_done/end_rush_min` and `note_at_most:rush_expired/end_rush_expired_max`.
END_MIL_NOIDLE_TITLE | 40 | End screen heading, Sela, rush orders filled in time
No Hull Sat Still
END_MIL_NOIDLE | 1000 | End screen body, Sela, rush orders filled in time
Not one order died on the board. Not one hull waited for a stamp it could have bought. Sela flew the worst lanes in the rim, and she learned there what a ship costs when it stands still. Now every ship moves. The Bazaar opened on time, and for once nobody checked the sky for what was coming. Sela did, from habit. She stood at the window until the last hull left the dock. Then she sat down.
EPI_MIL_NOIDLE | 140 | Epilogue 1, Sela, rush orders filled in time
The dock bell rings for a departure, not an arrival. Sela says it is the only bell worth a thought.

**END_MIL_WAIT** requires: `note_at_least:ceo_bore/end_bore_min`.
END_MIL_WAIT_TITLE | 40 | End screen heading, Sela, bore delays rather than pay
She Waited Her Turn
END_MIL_WAIT | 1000 | End screen body, Sela, bore delays rather than pay
The dock was full and the stamp was slow, and Sela waited. She hated every hour of it. A ship that stands still is a ship that is lost, and she knows it in her hands. But she did not pay the clerk to look away. The line moved, as lines do, and the crew watched her stand in it. Nobody said anything. The Bazaar opened a little later than it might have. The people in the line remember who stood there.
EPI_MIL_WAIT | 140 | Epilogue 1, Sela, bore delays
A new clerk at Tillam salutes her, badly, and then looks surprised at himself.

**END_MIL_HARD** requires: `note_at_least:explored/end_explored_min` and `note_at_least:established/end_established_wide`.
END_MIL_HARD_TITLE | 40 | End screen heading, Sela, many worlds explored and settled
The Long Way Round
END_MIL_HARD | 1000 | End screen body, Sela, many worlds explored and settled
The hard lanes were the ones nobody else would fly, and you flew them. The Flagship went out into the dark and came back with names. You put posts on worlds that were only a shape in the glass. Sela knew the cold out there. She did not say it was fine. She said it was worth knowing. Now the map is full of lit places that were black. Each one has a ship docked, and a crew that chose it.
EPI_MIL_HARD | 140 | Epilogue 1, Sela, many worlds explored and settled
On the chart, the first dark world you lit has a small ring drawn round it in her pencil.

**END_MIL_WATCH** requires: `note_at_least:peak_ships/end_fleet_big` and `note_at_most:restless_cycles/end_restless_low`.
END_MIL_WATCH_TITLE | 40 | End screen heading, Sela, a large fleet and calm worlds
The Night Watch
END_MIL_WATCH | 1000 | End screen body, Sela, a large fleet and calm worlds
A big fleet, and every world fed. It should have been chaos, and it was not. Sela ran the lanes like a watch: each ship on its hour, each world on its list. She slept in her chair most nights. At the Opening she took the late watch alone, as she always has, and no ship called for her. She stayed anyway. It was the first quiet night she had ever owned.
EPI_MIL_WATCH | 140 | Epilogue 1, Sela, a large fleet and calm worlds
The radio is silent. Sela leaves it on, and turns the chair a little toward it.

### 4.4 Tamsin Hale, Biotech (branch `bio`)
Order: HUNGRY, RING, CARDS, PANTRY, BYHAND, then fallback `END_BIO_GOOD` or `END_BIO_BAD`.

**END_BIO_HUNGRY** requires: `note_at_least:restless_cycles/end_restless_high`.
END_BIO_HUNGRY_TITLE | 40 | End screen heading, Tamsin, many Restless cycles
Still Writing Back
END_BIO_HUNGRY | 1000 | End screen body, Tamsin, many Restless cycles
The Bazaar opened, and on some worlds the lights had been low for a long time. Tamsin knew the clerks there. She had their cards. She read each hungry report and wrote back a line, by hand. It did not fill a hold. It did not hurt either, and it was all she had on the nights the lanes failed. The halls are full now. She still writes back. Some of the clerks write to her first.
EPI_BIO_HUNGRY | 140 | Epilogue 1, Tamsin, many Restless cycles
A stack of old reports sits by her bed. She reads one before sleep, as other people read a letter.

**END_BIO_RING** requires: `note_at_least:worlds_city/end_city_worlds`.
END_BIO_RING_TITLE | 40 | End screen heading, Tamsin, worlds grown to cities
The Ring Grows Up
END_BIO_RING | 1000 | End screen body, Tamsin, worlds grown to cities
The world you raised from a quiet dock is a city now. Tamsin walked its halls on the opening night and knew the clerks by their steps. The paperwork is friendly and the lines are short. People who were children on the stairs run the desks. She sends a card to every one. The Bazaar stands on a world that was once small enough to know by heart. She still does. It is the same world, and louder.
EPI_BIO_RING | 140 | Epilogue 1, Tamsin, worlds grown to cities
Someone has painted the old dock number on the wall of the new hall, small, by the door.

**END_BIO_CARDS** requires: `note_at_least:warm_worlds/end_warm_min`.
END_BIO_CARDS_TITLE | 40 | End screen heading, Tamsin, many worlds with a warm face
Every Clerk Has a Card
END_BIO_CARDS | 1000 | End screen body, Tamsin, many worlds with a warm face
Warm faces greet you at the docks. Tamsin knew the clerks, and they knew her. When a form had a flaw, a kind word fixed it. When a world ran short, someone called her first. It is not a plan the Bureau can file. It is a habit of being decent, and it carried you further than a good price would. At the Opening a dozen cards arrive by hand. Tamsin reads every name.
EPI_BIO_CARDS | 140 | Epilogue 1, Tamsin, many worlds with a warm face
The cards are pinned to a board by the door. A new one is added most days, and none is taken down.

**END_BIO_PANTRY** requires: `skill_learned:FND_STORAGE` and `note_at_least:space_cycles/end_space_min`.
END_BIO_PANTRY_TITLE | 40 | End screen heading, Tamsin, Space Storage used throughout
The Shelf Is Full
END_BIO_PANTRY | 1000 | End screen body, Tamsin, Space Storage used throughout
The shelves never ran bare. Food sat in the Space Storage through the lean cycles, held for the day a world asked. Tamsin counted the stock every night, and slept better for it. Some called it hoarding. The terraces that were fed from it did not. When the Bazaar opened there was still a full shelf at the back, and a note on it. The note says, for whoever is next.
EPI_BIO_PANTRY | 140 | Epilogue 1, Tamsin, Space Storage used throughout
The note on the shelf is in her hand. Underneath, in another hand, someone has written, thank you.

**END_BIO_BYHAND** requires: `note_at_least:card_routes/end_card_min` and `note_at_most:quick_routes/end_card_quick_max`.
END_BIO_BYHAND_TITLE | 40 | End screen heading, Tamsin, routes set from the planet card
Done by Hand
END_BIO_BYHAND | 1000 | End screen body, Tamsin, routes set from the planet card
Every route was set by hand, at the planet card, with the page open and the numbers read aloud. Tamsin never trusted a lane she had not looked at. It was slower. It was also right more often than not, and when it was wrong she knew why. The Bazaar opened on lanes she can name from memory, in the order she laid them. She runs a finger down the list on the wall. It is the nearest thing to a map she has ever drawn.
EPI_BIO_BYHAND | 140 | Epilogue 1, Tamsin, routes set from the planet card
The list on the wall is in pencil. She has never once rubbed a line out.

## 5. Coverage matrix

Columns are drivers (D ids from section 3). "T" is the term of the `requires`; "S" is a skill atom; blank means not used.

| CEO | Ending (priority) | D1 route habit | D2 reach | D3 gigs | D4 needs | D5 Bazaar growth | D6 events | D7 ships | D8 Space Storage | D9 faces | Skills |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Marek | 1 LONGSHIFT |  |  |  | T high |  |  |  |  |  |  |
| Marek | 2 DEEP |  | T platform |  |  |  |  |  |  |  | T deep Minerals tree |
| Marek | 3 PICKUP | T quick |  | T done |  |  |  |  |  |  |  |
| Marek | 4 PAGE |  |  |  |  |  | T paid | T none lost |  |  |  |
| Marek | 5 THIN |  |  |  |  |  |  | T lean |  |  |  |
| Idris | 1 WIDE |  | T wide |  |  |  |  |  |  |  | S LUX_1 |
| Idris | 2 FLEET |  |  |  |  |  |  | T big |  |  |  |
| Idris | 3 FULLTABLE |  |  | T done, few expired |  |  |  |  |  |  |  |
| Idris | 4 LIGHT |  |  |  |  |  | T credits |  |  |  |  |
| Idris | 5 CORNER |  | T few |  |  |  |  |  |  |  |  |
| Sela | 1 SCARS |  |  |  |  |  |  | T repossessed |  |  |  |
| Sela | 2 NOIDLE |  |  | T done, few expired |  |  |  |  |  |  |  |
| Sela | 3 WAIT |  |  |  |  |  | T bore |  |  |  |  |
| Sela | 4 HARD |  | T explored and wide |  |  |  |  |  |  |  |  |
| Sela | 5 WATCH |  |  |  | T low | T (via fleet) | | T big |  |  |  |
| Tamsin | 1 HUNGRY |  |  |  | T high |  |  |  |  |  |  |
| Tamsin | 2 RING |  |  |  |  | T city worlds |  |  |  |  |  |
| Tamsin | 3 CARDS |  |  |  |  |  |  |  |  | T warm |  |
| Tamsin | 4 PANTRY |  |  |  |  |  |  |  | T cycles | | S FND_STORAGE |
| Tamsin | 5 BYHAND | T card, few quick |  |  |  |  |  |  |  |  |  |

Every listed driver is used by at least one ending: D1 (PICKUP, BYHAND), D2 (DEEP, WIDE, CORNER, HARD), D3 (PICKUP, FULLTABLE, NOIDLE), D4 (LONGSHIFT, HUNGRY, WATCH), D5 (RING, CARDS through faces is D9; Bazaar stages and quorum shape the win itself and feed the recap), D6 (PAGE, LIGHT, WAIT), D7 (THIN, FLEET, SCARS, WATCH), D8 (PANTRY), D9 (CARDS). Skills enter as a term in DEEP, WIDE and PANTRY, and by the existing epilogue lines under every win.
Stages and quorum: every win has all stages and a met quorum, so they cannot tell runs apart. They are shown by the recap, and wings (D5, `wings`) are available as a term if the owner wants one more: for example "picked a wing of each kind" for a Tamsin or Sela variant. Not used here, to keep the set honest.

Plausible-run check:
- A run that makes no CEO event choice, no quick or card routes, never explores, builds one post, has a mid-size fleet, no gig: no `requires` holds, so the fallback `END_<MKT>_GOOD` or `_BAD` shows. Every CEO has that fallback. A win always lands on one ending.
- A run that matches several (for example Sela with a lost ship and perfect rush orders): SCARS wins by priority. The other facts still show in the recap block and the existing epilogue lines.
- A bankrupt or unfinished run is unchanged. They are not in this proposal.
- An old save (no notes): all zero. `restless_cycles/end_restless_low` and the "at most" terms hold for zero, so WATCH needs `peak_ships` big (zero fails) and CORNER (`established` at most few) would fire on an old save. Programmer: treat an absent notes dictionary as "no CEO ending" and go to the fallback. Same for THIN (`peak_ships` at most lean holds at zero), which is why an absent dictionary must short-circuit.
- Reachability: every row carries `branch_is:<market>`, so MIN endings show only in Marek's runs, and so on. The old-save quirk of `branch_is` (true with no branch) is covered by the same short-circuit.
- Hidden things: no text names a market good, a workshop or a hidden feature. The grey worlds appear only in MIN_DEEP, which needs a mining platform. Space Storage appears only in BIO_PANTRY, which needs FND_STORAGE learned.

## 6. Where each decision is counted, and what each costs (summary)

- game/main.gd: route start (D1), ship count (D7), CEO choice apply (D6), notes dictionary and `run_notes()` derived at `_finish`. M in total.
- game/gigs.gd: `rush_expired` (D3). XS.
- game/prosperity.gd: `restless_cycles` (D4). XS.
- game/storage.gd or the cycle-end hook: `space_cycles` (D8). XS.
- game/ending_picker.gd and game/conditions.gd: ordered rows, two atoms (`note_at_least`, `note_at_most`). S.
- data/endings.json: new, 20 rows plus the order. S.
- save: one dictionary key `run_notes`, nine ints. Old saves load as empty (fallback). S.
- No change to prices, costs, growth or tax. No mechanic is added: only counts of things the player already did.

## 7. Effort by role

| Role | Work | Size |
|---|---|---|
| story-designer | After approval: paste the 20 titles, 20 bodies and 20 epilogues into story/endings.md, update the glossary line for "run notes" (internal, never shown), check the lengths | S |
| gameplay-programmer | Notes dictionary and counters (D1, D3, D4, D6, D7, D8), derived notes, the picker with `data/endings.json`, two atoms, save and load, `pick` keys in the CEO event rows | M |
| economy-designer | 20 balance keys (section 3), checks that each ending fires in a minority of runs | S |
| ui-programmer | None required (the end screen reads ids). Optional: a recap row for the ending's driver | none |
| doc-manager | gdd.md ending section and the new atoms in the conditions list | S |
| Russian | Not now. A Haiku pass only when the owner asks | later |

Dependency: D6 needs the CEO events proposal to be approved and built. Without it the three endings PAGE, LIGHT and WAIT cannot fire (swap them for other drivers, see open question 2). The other 17 do not depend on it.

## 8. Ideas for later (not built, max three)

1. Loss and soft endings per CEO: a bankrupt Marek and a bankrupt Sela read differently. Needs the same notes dictionary and three more bodies per CEO.
2. A runner-up epilogue line: the second matched ending adds one line. Needs the picker to return two ids and one extra line per ending.
3. A "last good deed" line: the final gig or CEO event shows in the ending. Needs the last event id saved.

## 9. Open questions for the owner

1. Should the hidden chain lean (GOOD or BAD) colour the new endings? As written, a CEO ending replaces the market text and is neutral, so the lean only shows in the fallback and in the recap's decisive moments. Alternatives: (a) keep it so (simple); (b) add one short lean epilogue line under every CEO ending; (c) write a GOOD and BAD body for each (40 bodies, no new code).
2. Are the three event-driven endings (PAGE, LIGHT, WAIT) acceptable if the CEO events are approved and built first, or should they wait, or be swapped for drivers that already exist (for example a Marek variant on `stages` or a Sela variant on `wings`)?
3. May the CEO be named in an ending body? The CEO events proposal names them; the old endings never do. Names are used here in all 20 bodies; the "you" voice is kept for the company.
