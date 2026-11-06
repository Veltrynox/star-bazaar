# Round 2: story-designer verdicts

Author: story-designer, 2026-11-05. Read: README (round 2 rules) and all four round1 files. Numbers below are economy's round-1 placeholders, quoted, not mine. Plain lines max 110 characters (tech lines 140), and name no hidden good: they say "second product", "mined goods" or "Minerals". Flavour lines stay as in round1-story.md unless noted. I moved toward the economy and QA variants wherever they found a dead, trap or loop risk. Format: SLOT | backed by | verdict | NAME (prereq, cost) | PLAIN line.

## Foundations (outside the market gate)
- FND_1 | story, economy, feature, qa (all four wrote it) | AGREE | Route Ledger (none, S) | Shows each route's Income after costs per cycle on its row, and marks a loss.
- FND_2 | none | REJECT-leave-empty | Rival Watch (my own R1) is dead for a reader of the graphs (economy). Rival info moves to LUX_8, where the Luxury branch needs it. Bulk Orders (QA) is a first-hour loan that dies once cash binds: no.
- FND_3 | story + feature | CHANGE | Survey Drive (FND_PROSPECT, S) | The Pathfinder flies faster. Drop feature's post/platform cost cut (hidden-feature risk, and economy's cost-cutting upgrade is not wanted). Refit/Docks (economy, feature): REJECT here, they need route level 3 code and a one-lane/wide fork I would rather not name in the skill list. Flavour: "The scout learns the dark. The dark does not return the favour."

## Military
- MIL_8 | story + economy + qa | AGREE | Surplus Hulls (MIL_1, M) | Cuts the price of a new Skerrit by 15 percent. (Feature's Leased Hulls: REJECT, lease spam.) Name: I keep mine; Quartermaster is a person, this is a deal.
- MIL_9 | all four ideas but feature | AGREE | Cell Press (MIL_2 tech, goal 8) | Military sales count a little more toward market share. Tech: craft 8 units.
- MIL_10 | economy | CHANGE | Scrap Rights (MIL_3, M) | Scrapping a ship refunds a larger share of its price. Hardened Stores (my R1, QA): REJECT, asteroid cuts too rare (economy). Needs code check that scrapping a ship exists as worded; otherwise leave empty. Flavour: "The yard pays by weight. Learn the weight."
- MIL_11 | story + economy + qa | AGREE | Proof Range (MIL_4 tech, goal 12) | The second Military product sells for a little more. Tech: craft 12 units. Line-only, cash only, harmless.
- MIL_12 | feature | CHANGE | Dragnet (MIL_5, M) | Embargo Desk can hit two rivals at once, each by a smaller amount. Economy/QA must set the split so the total never beats one hit and strength stays above 0.2 of base (E5). Open Arsenal: REJECT (economy and QA both found the climber trap). Flavour: "One form, two names. The Desk is not particular."
- MIL_13 | feature + economy fallback | REJECT-leave-empty | Pressure Doctrine is a number on MIL_5, Second Embargo (QA) is Dragnet again. Nothing distinct.
- MIL_14 | story + economy + qa-alt | AGREE | Spare Casings (MIL_6 tech, goal 14) | Each Military batch makes one more unit. Tech: craft 14 units. Cap per economy: workshop stack not to shrink the goals.
- MIL_15 | feature | CHANGE | Full Mobilisation (MIL_7, L) | Once per run, for a few cycles, ships cost no upkeep. Drop "ignores route events" (too strong). Chosen so the three market capstones are not all the same rival cut; MIL stack is the highest auto-win risk (economy) and a timed surge adds none of the rival pressure. Economy sets the length; QA tests it cannot win alone before cycle 23. Flavour: "Every hull, every crew, one season. The Bureau notes the date."

## Luxury
- LUX_8 | feature | AGREE | Rival Whisper (LUX_1, M) | Competitors screen shows each rival's next tier-up cycle and who leads in three cycles. Replaces my Salon Circle (share-window climber trap) and FND_2. Flavour: "Rivals file forms too. Someone has to read them."
- LUX_9 | story + economy + qa | AGREE | Second Loom (LUX_2 tech, goal 10) | Luxury workshops make one more batch a cycle. Tech: craft 10 units.
- LUX_10 | story + economy + qa | AGREE | Trend Desk (LUX_3, M) | Events that cut Luxury prices hit 35 percent softer. Market event-cut total must stay at or under 0.9 (E4). Forward Contract (feature) goes to ideas.
- LUX_11 | story + economy + qa | AGREE | Collector's Eye (LUX_4 tech, goal 12) | The second Luxury product sells for a little more. Tech: craft 12 units. Targets the market, not the good (E2).
- LUX_12 | story + economy + qa | CHANGE (name) | Courier Pool (LUX_5B, M) | Luxury routes carry 10 percent more each cycle. Name change because press and cargo did not connect. Flavour: "News travels fastest in a crate."
- LUX_13 | story + economy + feature | AGREE | Patron's Purse (LUX_5, M, per economy) | Mixed load pays more when a Luxury good is part of the mix. Cap per planet stays.
- LUX_14 | story + economy + qa | AGREE | Auction House (LUX_6 tech, goal 14) | Luxury sales count a little more toward market share. Tech: craft 14 units. Sum with Second Loom must stay under economy's volume cap of 0.20.
- LUX_15 | story + economy + qa | AGREE | Grand Salon (LUX_7 + LUX_14, L) | Slows all rivals' Luxury growth by 25 percent for the rest of the run. Needs E3 fixed first.

## Minerals
- MIN_8 | story + economy | AGREE, conditional | Deep Hold (MIN_1, M) | Company storage holds 50 percent more of your mined goods. Dead risk: QA must confirm ore fills planet storage; if not, leave empty. Strip Mining (feature) is the trap economy named, so REJECT.
- MIN_9 | story + economy | AGREE | Slag Reclaim (MIN_2 tech, goal 10) | The Smelter needs one less input for each batch. Tech: craft 10 units.
- MIN_10 | economy + story | AGREE | Safe Passage (MIN_3, M) | Mining a dead world loses half as much cargo to the dark. (Names dead worlds: shown only after MIN_3.)
- MIN_11 | story + economy + qa | AGREE | Hot Foundry (MIN_4 tech, goal 12) | Minerals sell for a little more cash. Tech: craft 12 units.
- MIN_12 | story + economy + qa | AGREE | Rock Brokers (MIN_5B, M) | Events that raise Minerals prices pay 25 percent more. I avoid "Ore" in the title.
- MIN_13 | economy | AGREE | Null Core Tuning (MIN_5, M) | Lets you fit up to three Null Cores and cuts each one's Trip cost. Shown only after MIN_5.
- MIN_14 | story + economy + qa | AGREE | Mass Smelting (MIN_6 tech, goal 14) | Minerals sales count a little more toward market share. Tech: craft 14 units.
- MIN_15 | economy | AGREE (fallback M) | Motherlode (MIN_7 + MIN_14, L) | Asteroid clusters hold more before they run dry, and surveys cost half. Economy's finite-richness reasoning beats the yield version.

## Biotech
- BIO_8 | story + economy + qa | AGREE | Common Vats (BIO_1, M) | Routes with Biotech goods carry 12.5 percent more each cycle.
- BIO_9 | story + economy + qa | AGREE | Spore Bank (BIO_2 tech, goal 10) | Biotech workshops make one more batch a cycle. Tech: craft 10 units.
- BIO_10 | economy + qa | CHANGE | Cold Chain (BIO_3, M) | Biotech routes ignore debris events, and price events cut Biotech prices 20 percent less. Replaces my Deep Shelf: growth in Space Storage makes free goods (E11). Deep Shelf goes to ideas. Flavour: "The cold keeps what the Plan forgets."
- BIO_11 | story + economy + qa | AGREE | Graft Lines (BIO_4 tech, goal 14) | Each Biotech batch makes one more unit. Tech: craft 14 units. (Feature left it empty; the free-output cap in (b) covers the concern.)
- BIO_12 | story + economy + feature | AGREE, blocked | Patient Orchard (BIO_5, L) | Stored Biotech goods grow faster, up to a higher limit. Do not ship before the E11 check (do grown units count toward share).
- BIO_13 | economy | AGREE only if code gives it a stock-fed limit, else leave empty | Market Days (BIO_5, M) | Biotech sales from stored goods at a price-up planet count more toward share.
- BIO_14 | story + economy + qa | AGREE | Living Contracts (BIO_6 tech, goal 14) | Biotech sells for a little more cash. Tech: craft 14 units.
- BIO_15 | story + economy + qa | AGREE | Evergreen (BIO_7 + BIO_14, L) | Slows all rivals' Biotech growth by 25 percent for the rest of the run. BIO_7 and BIO_15 together capped near 40 percent effective. Needs E3 fixed.

## (a) QA code findings each backed skill must respect
- E1/E2: only market targets; no "all" except Route Ledger style unlocks; no good targets for price.
- E3: fix `bot_strength_mult`/`bot_growth_mult` before LUX_15, BIO_15 (and any chosen-bot node).
- E4: event cut per market at most 0.9 (LUX_10, MIN_12 safe; BIO_10 with BIO_6 gives 0.6).
- E5: Dragnet keeps any rival at 0.2 of base or more.
- E7/E8: no duplicate max or boolean nodes backed.
- E10: no new upkeep node (none backed; Full Mobilisation sits above the floor).
- E11: BIO_12, BIO_10 growth-adjacent nodes wait on the grown-stock check.
- E12: costs assume points compete with permits (2 each). E13/E14: owner questions, not mine.

## (b) Stacks accepted or capped
- Accept: price techs (line-only, under 0.30); workshop output techs if goals stay 8 to 14.
- Cap: volume sum per market at most 0.20; rival cuts BIO_7 + BIO_15 about 0.4 effective; Dragnet total hit; Full Mobilisation length.
- Re-sim always-expand after Surplus Hulls (economy).

## (c) Cut first if the set is too big
Full Mobilisation, Dragnet, Market Days, Deep Hold, Scrap Rights (the five that need new code or have a dead risk). Order: Market Days, Deep Hold, Scrap Rights, Dragnet, Full Mobilisation.

## Ideas for the owner (not for this build)
- Forward Contract (feature LUX_10): lock a price when an event is announced; needs a new once-per-N-cycles order.
- Deep Shelf: Biotech grows in the Space Storage; needs a storage-growth rule and a cap.
