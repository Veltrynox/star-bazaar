# Skills (draft 2, tone rework)

Format: ID | name (max 24) | flavour (max 90) | plain meaning (max 110). Appears on the skill screen: name on the node, flavour then plain line in the detail panel. Costs and values are shown by the game from data, never written here. Prerequisites as in gdd-skills.md: each node needs the one above it in its branch; C3 also needs C2 and A1; C4 needs C2. The plain line is the only line that states the effect.

## Logistics (how goods move and are kept)
A1 | Space Storage
Flavour: One great hold in the sky, held in common, quietly kept by you.
Plain: Unlocks Space Storage, one large company storage per system. Planet storage feeds it slowly.

A2 | Deep Holds
Flavour: A shelf is a promise that something will be there. The Plan loves a shelf.
Plain: Planet storage holds 50% more. A planet closed by an event reopens one cycle sooner.

A4 | Quick Loading
Flavour: Dock time is shared time. Spend less of it, and the hull hums less.
Plain: Each ship moves 18 units a cycle instead of 16.

A5 | Drydock Deals
Flavour: Every machine is a slow bill with wings, and it hums while it waits.
Plain: Ship upkeep is 30% lower: 14 credits a cycle instead of 20.

## Research (understanding the market and the sky)
B1 | Prospecting
Flavour: The Commons owns every rock. It has not yet counted the ones nobody has looked at.
Plain: Lets you start routes at asteroid clusters and shows how much ore each cluster still holds.

B2 | Standing Orders
Flavour: A good form is one you only file once. The Bureau will not mind.
Plain: Buy and Sell orders handle 60 units a cycle instead of 40.

B3 | Price Whisper
Flavour: Prices move before people do. Listen to the walls.
Plain: Shows next cycle's prices. Goods sell for 8% more per unit.

B4 | Event Forecast
Flavour: The sky has moods. The Plan pretends not to notice them.
Plain: Warns one cycle before an event. Price events name planet and commodity. Closed planets reopen a cycle sooner.

## Expansion (reach)
C1 | Permit Charter
Flavour: No ship leaves the home sky without a charter. This is the charter.
Plain: Lets you buy permits. A permit opens a new system for routes. It costs credits and skill points.

C2 | Survey Beacon
Flavour: Better to know a place before it counts you.
Plain: Press Survey on a system to see its planets and base prices. Its permit then costs 1 skill point less.

C3 | Long Haul
Flavour: Distance is only a long way of saying not yet, and not on the ledger.
Plain: Routes can run between systems. Needs Survey Beacon (C2) and Space Storage (A1).

C4 | Colonial Rights
Flavour: The second door is always cheaper than the first, and filed in fewer copies.
Plain: Permits cost 20% fewer credits. Needs Survey Beacon (C2).

## Research, dead worlds (added 2026-11-03; M and F ids use the standard id format, they sit in Research after B1)
SK_M1_NAME | 24 | Skill screen, node name | Cold Survey
SK_M1_FLAVOUR | 90 | Skill screen, detail panel | A rock no one lives on still has a ledger line. Someone must go and read it.
SK_M1_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Cinderrest and mine dross there. Needs Prospecting (B1). Dead worlds open later.
SK_M2_NAME | 24 | Skill screen, node name | Deep Cut
SK_M2_FLAVOUR | 90 | Skill screen, detail panel | Under the dust lies glass that hums. The Bureau has no form for it yet.
SK_M2_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Greywake and mine nullglass there. Needs Cold Survey (M1).
SK_F1_NAME | 24 | Skill screen, node name | Fabrication Licence
SK_F1_FLAVOUR | 90 | Skill screen, detail panel | A licence to make one good plate from two bad rocks. Stamped in triplicate, as ever.
SK_F1_PLAIN | 110 | Skill screen, detail panel | Unlocks the fabric: dross and nullglass make plate. Plate and nullglass make a Null Core. Needs M1 and M2.

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
- C1 to C4 depend on systems 2 and 3. System 2 is in the Alpha; system 3 is on hold. Until system 3 exists, C4 (Colonial Rights) has no permit to discount, because the only permit in the build is system 2 and it is usually bought first. The screen should say "No systems available yet." (NOT_SKILL_NO_SYSTEMS) when no permit is left to buy.
- A4 and B2 both say "more per cycle". If they move different numbers, the Economy Designer should confirm the wording is distinct.

## Four market trees (added 2026-11-03; ids SK_<node>_NAME / _FLAVOUR / _PLAIN, tech nodes also _CRAFT)
Sizes in words: a little (S), clearly (M), sharply (L). Prerequisites and costs are shown by the game. The old A/B/C text above stays until the cleanup.

SK_FND_STORAGE_NAME | 24 | Skill screen, node name | Space Storage
SK_FND_STORAGE_FLAVOUR | 90 | Skill screen, detail panel | One great hold in the sky, held in common, quietly kept by you.
SK_FND_STORAGE_PLAIN | 110 | Skill screen, detail panel | Unlocks Space Storage, one large company storage per system. Planet storage feeds it slowly.

SK_FND_PERMIT_NAME | 24 | Skill screen, node name | Permit Charter
SK_FND_PERMIT_FLAVOUR | 90 | Skill screen, detail panel | No ship leaves the home sky without a charter. This is the charter.
SK_FND_PERMIT_PLAIN | 110 | Skill screen, detail panel | Lets you buy permits for new systems and run routes between systems.

SK_FND_PROSPECT_NAME | 24 | Skill screen, node name | Prospecting
SK_FND_PROSPECT_FLAVOUR | 90 | Skill screen, detail panel | The Commons owns every rock. It has not counted the ones nobody has looked at.
SK_FND_PROSPECT_PLAIN | 110 | Skill screen, detail panel | Lets routes start at asteroid clusters and shows how much ore each cluster holds.

SK_MIL_1_NAME | 24 | Skill screen, node name | Drydock Deals
SK_MIL_1_FLAVOUR | 90 | Skill screen, detail panel | Every machine is a slow bill with wings. Cut the bill.
SK_MIL_1_PLAIN | 110 | Skill screen, detail panel | Ship upkeep is clearly lower. Unlocks the Munitions Line and pulse cells.

SK_MIL_2_NAME | 24 | Skill screen, node name | Cell Casting
SK_MIL_2_FLAVOUR | 90 | Skill screen, detail panel | A cell is a small sun with a rule printed on it.
SK_MIL_2_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units at the Munitions Line. Military volume up a little.
SK_MIL_2_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_3_NAME | 24 | Skill screen, node name | Quick Loading
SK_MIL_3_FLAVOUR | 90 | Skill screen, detail panel | Dock time is shared time. Spend less of it.
SK_MIL_3_PLAIN | 110 | Skill screen, detail panel | Routes carrying Military goods move a little more each cycle.

SK_MIL_4_NAME | 24 | Skill screen, node name | Armour Plating
SK_MIL_4_FLAVOUR | 90 | Skill screen, detail panel | Plate a hull and the quarrel goes elsewhere.
SK_MIL_4_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Unlocks hull armour. Military goods sell for a little more.
SK_MIL_4_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_5_NAME | 24 | Skill screen, node name | Embargo Desk
SK_MIL_5_FLAVOUR | 90 | Skill screen, detail panel | A polite desk with a very long reach.
SK_MIL_5_PLAIN | 110 | Skill screen, detail panel | Every {m} cycles, pick one rival: its Military strength falls sharply for {n} cycles.

SK_MIL_6_NAME | 24 | Skill screen, node name | Contract Doctrine
SK_MIL_6_FLAVOUR | 90 | Skill screen, detail panel | Write the terms first. The sky respects a clause.
SK_MIL_6_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Military price events against you hit clearly weaker.
SK_MIL_6_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_7_NAME | 24 | Skill screen, node name | Standing Fleet
SK_MIL_7_FLAVOUR | 90 | Skill screen, detail panel | A fleet that is always there needs no speech.
SK_MIL_7_PLAIN | 110 | Skill screen, detail panel | Capstone. All rivals' Military growth is cut in half for the rest of the run.

SK_LUX_1_NAME | 24 | Skill screen, node name | Price Whisper
SK_LUX_1_FLAVOUR | 90 | Skill screen, detail panel | Prices move before people do. Listen to the walls.
SK_LUX_1_PLAIN | 110 | Skill screen, detail panel | Shows next cycle's prices. Luxury goods sell for a little more. Unlocks the Atelier and cut glimmers.

SK_LUX_2_NAME | 24 | Skill screen, node name | Fine Finishing
SK_LUX_2_FLAVOUR | 90 | Skill screen, detail panel | A good edge earns a second look. A third earns a price.
SK_LUX_2_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units at the Atelier. Luxury price-up events pay clearly more.
SK_LUX_2_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_3_NAME | 24 | Skill screen, node name | Event Forecast
SK_LUX_3_FLAVOUR | 90 | Skill screen, detail panel | The sky has moods. The Plan pretends not to notice them.
SK_LUX_3_PLAIN | 110 | Skill screen, detail panel | Warns one cycle before an event. Works in all four markets.

SK_LUX_4_NAME | 24 | Skill screen, node name | Cask Cellar
SK_LUX_4_FLAVOUR | 90 | Skill screen, detail panel | Some things improve in the dark. So do some excuses.
SK_LUX_4_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Unlocks vintage casks. Stored Luxury stock keeps its value when a planet closes.
SK_LUX_4_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_5_NAME | 24 | Skill screen, node name | Patron's List
SK_LUX_5_FLAVOUR | 90 | Skill screen, detail panel | The right name on the right list is worth a ship.
SK_LUX_5_PLAIN | 110 | Skill screen, detail panel | Sales at a planet with a price-up event count clearly more volume toward your Luxury share.

SK_LUX_6_NAME | 24 | Skill screen, node name | Hallmark
SK_LUX_6_FLAVOUR | 90 | Skill screen, detail panel | A stamp from your hand makes a stone worth more.
SK_LUX_6_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Luxury goods sell for clearly more.
SK_LUX_6_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_7_NAME | 24 | Skill screen, node name | Guild Seal
SK_LUX_7_FLAVOUR | 90 | Skill screen, detail panel | Buy the client, not the goods. The guild keeps a form for it.
SK_LUX_7_PLAIN | 110 | Skill screen, detail panel | Capstone. Once per run, pick a rival: its Luxury strength falls sharply for {n} cycles.

SK_MIN_1_NAME | 24 | Skill screen, node name | Fabrication Licence
SK_MIN_1_FLAVOUR | 90 | Skill screen, detail panel | A licence to make one good plate from two bad rocks. Stamped in triplicate.
SK_MIN_1_PLAIN | 110 | Skill screen, detail panel | Unlocks the Fabric and the Smelter, and ingot. Needs Prospecting.

SK_MIN_2_NAME | 24 | Skill screen, node name | Smelting
SK_MIN_2_FLAVOUR | 90 | Skill screen, detail panel | Heat is honest. It only asks what you put in.
SK_MIN_2_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units at the Smelter. Minerals volume up a little. Ore loads take no order space.
SK_MIN_2_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_3_NAME | 24 | Skill screen, node name | Cold Survey
SK_MIN_3_FLAVOUR | 90 | Skill screen, detail panel | A rock no one lives on still has a ledger line. Someone must read it.
SK_MIN_3_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Cinderrest and mine dross. Cluster yield up a little. Dead worlds open later.

SK_MIN_4_NAME | 24 | Skill screen, node name | Alloying
SK_MIN_4_FLAVOUR | 90 | Skill screen, detail panel | Two metals agree if you hold them hot enough.
SK_MIN_4_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Unlocks seam alloy. Minerals workshops make one more batch a cycle.
SK_MIN_4_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_5_NAME | 24 | Skill screen, node name | Deep Cut
SK_MIN_5_FLAVOUR | 90 | Skill screen, detail panel | Under the dust lies glass that hums. The Bureau has no form for it yet.
SK_MIN_5_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Greywake and mine nullglass. Needs Cold Survey.

SK_MIN_6_NAME | 24 | Skill screen, node name | Lattice Works
SK_MIN_6_FLAVOUR | 90 | Skill screen, detail panel | A good lattice forgives the one who made it.
SK_MIN_6_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Each Minerals batch yields one more unit.
SK_MIN_6_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_7_NAME | 24 | Skill screen, node name | Cornered Seam
SK_MIN_7_FLAVOUR | 90 | Skill screen, detail panel | The last seam in reach belongs to someone. Now it is you.
SK_MIN_7_PLAIN | 110 | Skill screen, detail panel | Capstone. All rivals' Minerals strength falls clearly for the rest of the run.

SK_BIO_1_NAME | 24 | Skill screen, node name | Standing Orders
SK_BIO_1_FLAVOUR | 90 | Skill screen, detail panel | A good form is one you only file once. The Bureau will not mind.
SK_BIO_1_PLAIN | 110 | Skill screen, detail panel | Buy and Sell orders move clearly more units a cycle. Unlocks the Culture Lab and bio-gel.

SK_BIO_2_NAME | 24 | Skill screen, node name | Culture Banks
SK_BIO_2_FLAVOUR | 90 | Skill screen, detail panel | Something grows in the dark and asks for nothing. For now.
SK_BIO_2_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units at the Culture Lab. Biotech stock in planet storage grows each cycle, to a cap.
SK_BIO_2_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_3_NAME | 24 | Skill screen, node name | Seed Bank
SK_BIO_3_FLAVOUR | 90 | Skill screen, detail panel | A shelf is a promise that something will be there.
SK_BIO_3_PLAIN | 110 | Skill screen, detail panel | Planet storage holds clearly more.

SK_BIO_4_NAME | 24 | Skill screen, node name | Gene Splicing
SK_BIO_4_FLAVOUR | 90 | Skill screen, detail panel | A small cut, a small stitch. The vat hums approval.
SK_BIO_4_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Unlocks gene seed.
SK_BIO_4_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_5_NAME | 24 | Skill screen, node name | Clinic Contracts
SK_BIO_5_FLAVOUR | 90 | Skill screen, detail panel | A clinic pays slowly, which the Bureau calls trust.
SK_BIO_5_PLAIN | 110 | Skill screen, detail panel | Biotech share counts a longer span of cycles, so it moves more steadily.

SK_BIO_6_NAME | 24 | Skill screen, node name | Hardy Strains
SK_BIO_6_FLAVOUR | 90 | Skill screen, detail panel | A strain that survives the form survives most things.
SK_BIO_6_PLAIN | 110 | Skill screen, detail panel | Tech: craft {goal} units. Biotech events cost you a little less. A closed planet reopens a cycle sooner.
SK_BIO_6_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_7_NAME | 24 | Skill screen, node name | Patent Wall
SK_BIO_7_FLAVOUR | 90 | Skill screen, detail panel | A wall made of paper outlasts one made of stone.
SK_BIO_7_PLAIN | 110 | Skill screen, detail panel | Capstone. All rivals' Biotech strength falls clearly for the rest of the run.
