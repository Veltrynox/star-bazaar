# Skills (draft 2, tone rework)

Format: ID | name (max 24) | flavour (max 90) | plain meaning (max 110). Appears on the skill screen: name on the node, flavour then plain line in the detail panel. Costs and values are shown by the game from data, never written here. Prerequisites as in gdd-skills.md: each node needs the one above it in its branch; C3 also needs A1. The plain line is the only line that states the effect.

## Logistics (how goods move and are kept)
A1 | Space Storage
Flavour: One great hold in the sky, held in common, quietly kept by you.
Plain: Unlocks Space Storage, one large company storage per system. Planet storage feeds it slowly.

A2 | Deep Holds
Flavour: A shelf is a promise that something will be there. The Plan loves a shelf.
Plain: Raises the capacity of Company storage on planets.

A3 | Second Hull
Flavour: The Bureau calls it a vessel of the common good. It is a bigger hull.
Plain: Unlocks the large ship, the Voruun Hauler, besides the small Skerrit.

A4 | Quick Loading
Flavour: Dock time is shared time. Spend less of it.
Plain: A route moves more goods each cycle.

A5 | Drydock Deals
Flavour: Every machine is a slow bill with wings, and it hums while it waits.
Plain: Lowers Ship upkeep.

## Research (understanding the market and the sky)
B1 | Market Ledger
Flavour: The Common Ledger records everything but prices. Keep your own.
Plain: Shows the price history of each planet in its panel.

B2 | Standing Orders
Flavour: A good form is one you only file once.
Plain: Local Buy and Sell orders handle more goods per cycle.

B3 | Price Whisper
Flavour: Prices move before people do. Listen to the walls.
Plain: Shows the expected price move for the next cycle before it happens.

B4 | Event Forecast
Flavour: The sky has moods. The Plan pretends not to notice them.
Plain: Shows the next event one cycle before it happens.

## Expansion (reach)
C1 | Permit Charter
Flavour: A stamp is also a kind of door. Keep the stamp warm.
Plain: Lets you buy permits to open new systems. Permits cost skill points and credits.

C2 | Survey Beacon
Flavour: Better to know a place before it counts you.
Plain: Shows the planets of a permitted system before your first visit.

C3 | Long Haul
Flavour: Distance is only a long way of saying not yet, and not on the ledger.
Plain: Allows routes between systems. Needs Space Storage (A1).

C4 | Colonial Rights
Flavour: The second door is always cheaper than the first, and filed in fewer copies.
Plain: Lowers the credit price of later permits.

## Screen strings
SK_HEADER | 24 | Skill screen title | Skills
SK_BRANCH_A | 24 | Column header | Logistics
SK_BRANCH_B | 24 | Column header | Research
SK_BRANCH_C | 24 | Column header | Expansion
SK_STATE_LEARNED | 24 | Node state | Learned
SK_STATE_AVAILABLE | 24 | Node state | Available
SK_STATE_LOCKED | 24 | Node state | Locked
SK_NEEDS | 60 | Locked node line | Needs: {skill}.
SK_COST | 24 | Detail panel label | Cost: {amount} points
SK_NO_CREDITS | 110 | Skill screen footer | Skills cost skill points, never credits.

## Notes for the owner (ideas only, no changes)
- C1 to C4 depend on systems 2 and 3, which are on hold. The screen should say "No systems available yet." (NOT_SKILL_NO_SYSTEMS) next to C1 so the player is not misled.
- A4 and B2 both say "more per cycle". If they move different numbers, the Economy Designer should confirm the wording is distinct.
