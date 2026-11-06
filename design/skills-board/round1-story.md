# Round 1: story-designer proposal

Author: story-designer, 2026-11-05. Own proposal, written without reading other round1 files. Names max 24, flavour max 90, plain line max 110 (tech lines 140, as existing tech lines, because they end with "Tech: craft {goal} units."). Sizes in words only; economy sets numbers. Plain lines name no good: they say "Military goods", "mined goods", "the second product". Costs are my suggestion (S 1, M 2, L 3, T tech).

Format per skill: ID | Name | prereqs | cost | effect | role, competes with | PLAIN | FLAVOUR | flag.

## Foundations (outside the market gate; each a small reader's or scout's tool)

FND_LEDGER | Route Ledger | none | S | each route row shows Income after costs per cycle | clarity for 1 point of tempo; competes with every other first point | PLAIN: Shows each route's Income after costs per cycle on its row. | FLAVOUR: The Bureau keeps a ledger for everyone. Now you keep one for yourself. | flag: none. Uses glossary term.

FND_RIVAL_WATCH | Rival Watch | FND_LEDGER | S | Competitors screen shows each rival's expected share a few cycles ahead | tells you which market to push | PLAIN: Shows each rival's expected market share a few cycles ahead on the Competitors screen. | FLAVOUR: Rivals file forms too. Someone has to read them. | flag: none.

FND_PATHFINDER | Pathfinder Tuning | FND_PROSPECT | M | Pathfinder flight time shorter (replaces feature's FND_DOCKS) | helps whoever expands fast; useless to a one-lane player | PLAIN: Cuts the Pathfinder's flight time by a little. | FLAVOUR: The scout learns the dark. The dark does not return the favour. | flag: new effect type; fiction strong. FND_DOCKS (route upgrade cost) has no route upgrade fiction I can find, so I did not write it.

## Military (identity: ships, fleet cost, rival pressure)

MIL_8 | Surplus Hulls | MIL_1 | M | a new Skerrit costs less to buy | early fleet vs MIL_3 lane size | PLAIN: Cuts the price of a new Skerrit by a little. | FLAVOUR: Last cycle's hulls, inspected twice and approved once. | flag: needs ship price effect (new type).

MIL_9 | Cell Press | MIL_2 tech | T | Military sales count more toward share | rewards crafting | PLAIN: Military sales count a little more toward market share. Tech: craft {goal} units. | FLAVOUR: Press them flat, stamp them, ship them. | flag: none.

MIL_10 | Hardened Stores | MIL_3 | M | asteroid hits do not trim stored Military stock | for storage-heavy play; competes with MIL_5 | PLAIN: Asteroid hits no longer cut your stored Military goods. | FLAVOUR: Rock falls on everyone. Your shelves are thicker than most. | flag: none.

MIL_11 | Proof Range | MIL_4 tech | T | second product sells for more cash | finishing the line | PLAIN: The second Military product sells for a little more. Tech: craft {goal} units. | FLAVOUR: A shell that survives the test is a shell with a price. | flag: weak, thin price tech.

MIL_12 | Open Arsenal | MIL_4 tech | M | Military share window longer | defends a lead | PLAIN: Your Military sales count toward market share for more cycles. | FLAVOUR: Leave the doors open. Let the Ledger see how much is inside. | flag: none.

MIL_13 | Pressure Doctrine | MIL_5 | L | Embargo Desk recharges sooner | deepens pressure build; competes with MIL_6 branch | PLAIN: Embargo Desk recharges sooner. | FLAVOUR: The desk learns to file its forms before the last ones are stamped. | flag: new effect type; useless without MIL_5, which is its prereq.

MIL_14 | Spare Casings | MIL_6 tech | T | each Military batch makes one more unit | percent tech | PLAIN: Each Military batch makes one more unit. Tech: craft {goal} units. | FLAVOUR: Waste is a word for things the Plan has not yet counted. | flag: thin.

MIL_15 | Long Shadow | MIL_7, MIL_14 | L | all rivals' Military strength cut a little, permanent | capstone extension | PLAIN: Cuts all rivals' Military strength by a little for the rest of the run. | FLAVOUR: They notice you before they see you. | flag: stacks with MIL_7; auto-win risk (economy). Fiction ok.

## Luxury (identity: information, events, atelier)

LUX_8 | Salon Circle | LUX_1 | M | Luxury share window longer | early hold on share; competes with LUX_3 | PLAIN: Your Luxury sales count toward market share for more cycles. | FLAVOUR: Everyone who matters has been to dinner. Everyone remembers the host. | flag: none.

LUX_9 | Second Loom | LUX_2 tech | T | Atelier makes one more batch a cycle | output | PLAIN: Luxury workshops make one more batch a cycle, if you haul the inputs. Tech: craft {goal} units. | FLAVOUR: One loom hums. Two sound like a choir. | flag: duplicates MIL_2 shape.

LUX_10 | Trend Desk | LUX_3 | M | events that cut your Luxury prices hit softer | pairs with warning: see it, then soften it | PLAIN: Events that cut your Luxury prices hit a little softer. | FLAVOUR: A trend is just a rumour with a budget. | flag: none.

LUX_11 | Collector's Eye | LUX_4 tech | T | second product sells for more cash | finishing the line | PLAIN: The second Luxury product sells for a little more. Tech: craft {goal} units. | FLAVOUR: Someone will pay for the one you kept back. | flag: weak, thin price tech.

LUX_12 | Press Room | LUX_5B | M | Luxury route capacity up | body for the information side branch | PLAIN: Routes with Luxury goods carry a little more each cycle. | FLAVOUR: News travels fastest in a crate. | flag: fiction weak, press and cargo do not connect. Alternative name Courier Pool.

LUX_13 | Patron's Purse | LUX_5 | L | Mixed load bonus larger when Luxury is in the mix | diversify cargo vs focus | PLAIN: Mixed load pays more when a Luxury good is part of the mix. | FLAVOUR: One guest buys a gift. A table full of guests buys a room. | flag: new effect type; uses glossary term Mixed load.

LUX_14 | Auction House | LUX_6 tech | T | Luxury sales count more toward share | percent tech | PLAIN: Luxury sales count clearly more toward market share. Tech: craft {goal} units. | FLAVOUR: The hammer falls. The Bureau records who held it. | flag: thin; same effect as MIL_9. Consider merging with LUX_9.

LUX_15 | Grand Salon | LUX_7, LUX_14 | L | all rivals' Luxury growth slowed, permanent | long game vs LUX_7's single hit | PLAIN: Slows all rivals' Luxury growth for the rest of the run. | FLAVOUR: A table that seats everyone, with your name on the card. | flag: third copy of the capstone shape (MIL_15, BIO_15); consider fewer.

## Minerals (identity: mining, dead worlds, ore)

MIN_8 | Deep Hold | MIN_1 | M | more room for mined goods in storage | pairs with free order slots | PLAIN: Company storage holds a little more of your mined goods. | FLAVOUR: Dig the hold deeper. The rock will not mind. | flag: new effect type; "mined goods" avoids naming ore early.

MIN_9 | Slag Reclaim | MIN_2 tech | T | smelter needs fewer inputs per batch | crafting pays back | PLAIN: The Smelter needs fewer inputs for each batch. Tech: craft {goal} units. | FLAVOUR: Nothing is waste if you let the furnace look twice. | flag: new effect type.

MIN_10 | Steady Hands | MIN_3 | M | less mined cargo lost on dead worlds | makes MIN_5 worth the risk | PLAIN: Mining a dead world loses less cargo to the dark. | FLAVOUR: The rock shifts. Your crew shifts with it. | flag: names dead worlds; fine once MIN_3 is learned, which reveals them. Needs the Danger meter wording check.

MIN_11 | Hot Foundry | MIN_4 tech | T | Minerals sell for more cash | finishing the line | PLAIN: Minerals sell for a little more. Tech: craft {goal} units. | FLAVOUR: Metal sells best while it still glows. | flag: weak, thin price tech.

MIN_12 | Rock Brokers | MIN_5B | M | price-up events pay more for Minerals | upside for the safe branch | PLAIN: Events that raise Minerals prices pay a little more. | FLAVOUR: Someone always needs a wall by next cycle. | flag: none.

MIN_13 | Null Core Tuning | MIN_5 | L | fitted ship's Trip cost lower | dead-world line only | PLAIN: Cuts the Trip cost of the ship fitted with a Null Core. | FLAVOUR: The core hums at a pitch no one asked for. Tune it anyway. | flag: names Null Core, a late item. Safe only if this node shows after MIN_5 (its prereq). Weak for a player who never builds one.

MIN_14 | Mass Smelting | MIN_6 tech | T | Minerals sales count more toward share | percent tech | PLAIN: Minerals sales count clearly more toward market share. Tech: craft {goal} units. | FLAVOUR: One furnace, one pour, one very large shipment. | flag: thin.

MIN_15 | Motherlode | MIN_7, MIN_14 | L | cluster yield second step | capstone extension, stacks with MIN_3 | PLAIN: Asteroid clusters give more each cycle. | FLAVOUR: The map said empty. The map was wrong. | flag: economy must cap the stack.

## Biotech (identity: stock that grows, storage, patience)

BIO_8 | Common Vats | BIO_1 | M | Biotech route capacity up | early lane size vs BIO_3 storage | PLAIN: Routes with Biotech goods carry a little more each cycle. | FLAVOUR: The vats are shared. The growth, oddly, is yours. | flag: none.

BIO_9 | Spore Bank | BIO_2 tech | T | Culture Lab makes one more batch a cycle | output | PLAIN: Biotech workshops make one more batch a cycle, if you haul the inputs. Tech: craft {goal} units. | FLAVOUR: Keep a little of everything. Something will wake up. | flag: none.

BIO_10 | Deep Shelf | BIO_3 | M | Biotech stored in the Space Storage also grows (replaces feature's Cold Chain) | gives Space Storage a Biotech role | PLAIN: Biotech goods in the Space Storage also grow while they wait. | FLAVOUR: The great hold is quiet and warm. Things grow in it. | flag: new effect type. Cold Chain (debris immunity) is a third copy of MIL_3 and MIN_5B, so I do not propose it.

BIO_11 | Graft Lines | BIO_4 tech | T | each Biotech batch makes one more unit | percent tech | PLAIN: Each Biotech batch makes one more unit. Tech: craft {goal} units. | FLAVOUR: Join two cuttings. Report one harvest. | flag: thin, same shape as MIL_14.

BIO_12 | Patient Orchard | BIO_5 | L | Biotech stock grows faster | leave stock to grow vs sell now | PLAIN: Stored Biotech goods grow faster each cycle. | FLAVOUR: The Plan counts in five cycles. The orchard counts in seasons. | flag: new effect type. Strong identity.

BIO_13 | Market Days | BIO_5 | M | Biotech sales at a planet with a price-up event count more | timing sales | PLAIN: Biotech sales at a planet with a price-up event count clearly more toward share. | FLAVOUR: The square fills. Bring what has grown. | flag: parallels LUX_5; ok.

BIO_14 | Living Contracts | BIO_6 tech | T | Biotech sells for more cash | price tech | PLAIN: Biotech sells for a little more. Tech: craft {goal} units. | FLAVOUR: A contract that grows in value, like everything else in the hold. | flag: weak, thin price tech.

BIO_15 | Evergreen | BIO_7, BIO_14 | L | all rivals' Biotech growth slowed, permanent | capstone extension | PLAIN: Slows all rivals' Biotech growth for the rest of the run. | FLAVOUR: It outlasts every plan. | flag: third copy of the capstone shape; same as MIL_15 and LUX_15.

## Summary of flags
- Weakest fiction or effect: LUX_12 (press and cargo), all four price techs (MIL_11, LUX_11, MIN_11, BIO_14), the "percent" techs (MIL_14, LUX_14, MIN_14, BIO_11).
- Duplicate shapes: MIL_15, LUX_15, BIO_15 (same capstone extension, three markets). I would keep at most two, or give each a different effect. Share-window and share-volume techs repeat across markets; the plain lines differ only by market name.
- Hidden goods: no plain line names a good. MIN_10 names dead worlds and MIN_13 names the Null Core; both sit behind prerequisites that reveal them. Check against `data/availability.json` before wiring.
- Could drop for lack of a fiction hook: FND_DOCKS (not written), BIO_10 Cold Chain (replaced by Deep Shelf).
- Slots left empty: none for story reasons. All 35 have a name and line; three Foundations are written (LEDGER, RIVAL_WATCH, PATHFINDER).
