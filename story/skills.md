# Skills (four market trees)

Format: ID | max length | place | text. Appears on the skill screen: name on the node, plain line first, then flavour line (changed 2026-11-04). Costs and values are shown by the game from data, never written here. Prerequisites are shown by the game too. The plain line (line 1, no label) is the only line that states the effect; the flavour line (line 2) never repeats it.

## Screen strings
SK_HEADER | 24 | Skill screen title | Skills
SK_NEEDS | 60 | Locked node line | Needs: {skill}.
SK_COST | 24 | Detail panel label, unused after 2026-11-04 (cost shown by the game) | Cost: {amount} points
SK_NO_CREDITS | 110 | Skill screen footer | Skills cost skill points, never credits.
SK_BOT_USE | 24 | Skill screen, menu button on a learned bot skill (Embargo Desk, Guild Seal) | Use on...
SK_BOT_USED | 40 | Skill screen, note on a once-per-run bot skill already used | Used this run.
SK_BOT_COOLDOWN | 40 | Skill screen, note on a bot skill that is recharging; {n} is cycles left | Ready in {n} cycles.

## Nodes (ids SK_<node>_NAME / _FLAVOUR / _PLAIN, tech nodes also _CRAFT)
Sizes in words: a little (S), clearly (M), sharply (L). Prerequisites and costs are shown by the game.

SK_FND_STORAGE_NAME | 24 | Skill screen, node name | Space Storage
SK_FND_STORAGE_FLAVOUR | 90 | Skill screen, detail panel | One great hold in the sky, held in common, quietly kept by you.
SK_FND_STORAGE_PLAIN | 110 | Skill screen, detail panel | Lets you keep one large company storage per system, the Space Storage. Planet storage feeds it slowly.

SK_FND_PERMIT_NAME | 24 | Skill screen, node name | Permit Charter
SK_FND_PERMIT_FLAVOUR | 90 | Skill screen, detail panel | No ship leaves the home sky without a charter. This is the charter.
SK_FND_PERMIT_PLAIN | 110 | Skill screen, detail panel | Lets you buy permits for new systems and run routes between systems.

SK_FND_PROSPECT_NAME | 24 | Skill screen, node name | Prospecting
SK_FND_PROSPECT_FLAVOUR | 90 | Skill screen, detail panel | The Commons owns every rock. It has not counted the ones nobody has looked at.
SK_FND_PROSPECT_PLAIN | 110 | Skill screen, detail panel | Lets routes start at asteroid clusters and shows how much ore each cluster holds.

SK_MIL_1_NAME | 24 | Skill screen, node name | Drydock Deals
SK_MIL_1_FLAVOUR | 90 | Skill screen, detail panel | Every machine is a slow bill with wings. Cut the bill.
SK_MIL_1_PLAIN | 110 | Skill screen, detail panel | Lowers Ship upkeep clearly. Unlocks the Munitions Line and pulse cells.

SK_MIL_2_NAME | 24 | Skill screen, node name | Cell Casting
SK_MIL_2_FLAVOUR | 90 | Skill screen, detail panel | A cell is a small sun with a rule printed on it.
SK_MIL_2_PLAIN | 110 | Skill screen, detail panel | Raises Military volume a little. Tech: craft {goal} units at the Munitions Line.
SK_MIL_2_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_3_NAME | 24 | Skill screen, node name | Quick Loading
SK_MIL_3_FLAVOUR | 90 | Skill screen, detail panel | Dock time is shared time. Spend less of it.
SK_MIL_3_PLAIN | 110 | Skill screen, detail panel | Lets routes carrying Military goods move a little more each cycle.

SK_MIL_4_NAME | 24 | Skill screen, node name | Armour Plating
SK_MIL_4_FLAVOUR | 90 | Skill screen, detail panel | Plate a hull and the quarrel goes elsewhere.
SK_MIL_4_PLAIN | 110 | Skill screen, detail panel | Military goods sell for a little more. Unlocks hull armour. Tech: craft {goal} units.
SK_MIL_4_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_5_NAME | 24 | Skill screen, node name | Embargo Desk
SK_MIL_5_FLAVOUR | 90 | Skill screen, detail panel | A polite desk with a very long reach.
SK_MIL_5_PLAIN | 110 | Skill screen, detail panel | Lets you pick a rival every {m} cycles: its Military strength falls sharply for {n} cycles.

SK_MIL_6_NAME | 24 | Skill screen, node name | Contract Doctrine
SK_MIL_6_FLAVOUR | 90 | Skill screen, detail panel | Write the terms first. The sky respects a clause.
SK_MIL_6_PLAIN | 110 | Skill screen, detail panel | Military price events against you hit clearly weaker. Tech: craft {goal} units.
SK_MIL_6_CRAFT | 60 | Skill screen, tech node progress line | Munitions Line crafts: {n} of {goal}

SK_MIL_7_NAME | 24 | Skill screen, node name | Standing Fleet
SK_MIL_7_FLAVOUR | 90 | Skill screen, detail panel | A fleet that is always there needs no speech.
SK_MIL_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Military growth in half for the rest of the run. Capstone.

SK_LUX_1_NAME | 24 | Skill screen, node name | Price Whisper
SK_LUX_1_FLAVOUR | 90 | Skill screen, detail panel | Prices move before people do. Listen to the walls.
SK_LUX_1_PLAIN | 110 | Skill screen, detail panel | Shows next cycle's prices. Luxury goods sell for a little more. Unlocks the Atelier and cut glimmers.

SK_LUX_2_NAME | 24 | Skill screen, node name | Fine Finishing
SK_LUX_2_FLAVOUR | 90 | Skill screen, detail panel | A good edge earns a second look. A third earns a price.
SK_LUX_2_PLAIN | 110 | Skill screen, detail panel | Luxury price-up events pay clearly more. Tech: craft {goal} units at the Atelier.
SK_LUX_2_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_3_NAME | 24 | Skill screen, node name | Event Forecast
SK_LUX_3_FLAVOUR | 90 | Skill screen, detail panel | The sky has moods. The Plan pretends not to notice them.
SK_LUX_3_PLAIN | 110 | Skill screen, detail panel | Warns you one cycle before an event, in all four markets.

SK_LUX_4_NAME | 24 | Skill screen, node name | Cask Cellar
SK_LUX_4_FLAVOUR | 90 | Skill screen, detail panel | Some things improve in the dark. So do some excuses.
SK_LUX_4_PLAIN | 110 | Skill screen, detail panel | Luxury stock survives asteroid cuts to storage. Unlocks vintage casks. Tech: craft {goal} units.
SK_LUX_4_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_5_NAME | 24 | Skill screen, node name | Patron's List
SK_LUX_5_FLAVOUR | 90 | Skill screen, detail panel | The right name on the right list is worth a ship.
SK_LUX_5_PLAIN | 110 | Skill screen, detail panel | Counts sales at a planet with a price-up event as clearly more volume toward your Luxury share.

SK_LUX_6_NAME | 24 | Skill screen, node name | Hallmark
SK_LUX_6_FLAVOUR | 90 | Skill screen, detail panel | A stamp from your hand makes a stone worth more.
SK_LUX_6_PLAIN | 110 | Skill screen, detail panel | Luxury goods sell for clearly more. Tech: craft {goal} units.
SK_LUX_6_CRAFT | 60 | Skill screen, tech node progress line | Atelier crafts: {n} of {goal}

SK_LUX_7_NAME | 24 | Skill screen, node name | Guild Seal
SK_LUX_7_FLAVOUR | 90 | Skill screen, detail panel | Buy the client, not the goods. The guild keeps a form for it.
SK_LUX_7_PLAIN | 110 | Skill screen, detail panel | Lets you pick a rival once per run: its Luxury strength falls sharply for {n} cycles. Capstone.

SK_MIN_1_NAME | 24 | Skill screen, node name | Fabrication Licence
SK_MIN_1_FLAVOUR | 90 | Skill screen, detail panel | A licence to make one good plate from two bad rocks. Stamped in triplicate.
SK_MIN_1_PLAIN | 110 | Skill screen, detail panel | Unlocks the Fabric, the Smelter and ingot. Needs Prospecting.

SK_MIN_2_NAME | 24 | Skill screen, node name | Smelting
SK_MIN_2_FLAVOUR | 90 | Skill screen, detail panel | Heat is honest. It only asks what you put in.
SK_MIN_2_PLAIN | 110 | Skill screen, detail panel | Raises Minerals volume a little. Ore orders ignore the size cap. Tech: craft {goal} units at the Smelter.
SK_MIN_2_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_3_NAME | 24 | Skill screen, node name | Cold Survey
SK_MIN_3_FLAVOUR | 90 | Skill screen, detail panel | A rock no one lives on still has a ledger line. Someone must read it.
SK_MIN_3_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Cinderrest and mine dross. Cluster yield up a little. Dead worlds open later.

SK_MIN_4_NAME | 24 | Skill screen, node name | Alloying
SK_MIN_4_FLAVOUR | 90 | Skill screen, detail panel | Two metals agree if you hold them hot enough.
SK_MIN_4_PLAIN | 110 | Skill screen, detail panel | Minerals workshops make one more batch a cycle. Unlocks seam alloy. Tech: craft {goal} units.
SK_MIN_4_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_5_NAME | 24 | Skill screen, node name | Deep Cut
SK_MIN_5_FLAVOUR | 90 | Skill screen, detail panel | Under the dust lies glass that hums. The Bureau has no form for it yet.
SK_MIN_5_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Greywake and mine nullglass. Needs Cold Survey.

SK_MIN_6_NAME | 24 | Skill screen, node name | Lattice Works
SK_MIN_6_FLAVOUR | 90 | Skill screen, detail panel | A good lattice forgives the one who made it.
SK_MIN_6_PLAIN | 110 | Skill screen, detail panel | Each Minerals batch yields one more unit. Tech: craft {goal} units.
SK_MIN_6_CRAFT | 60 | Skill screen, tech node progress line | Smelter crafts: {n} of {goal}

SK_MIN_7_NAME | 24 | Skill screen, node name | Cornered Seam
SK_MIN_7_FLAVOUR | 90 | Skill screen, detail panel | The last seam in reach belongs to someone. Now it is you.
SK_MIN_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Minerals strength clearly for the rest of the run. Capstone.

SK_BIO_1_NAME | 24 | Skill screen, node name | Standing Orders
SK_BIO_1_FLAVOUR | 90 | Skill screen, detail panel | A good form is one you only file once. The Bureau will not mind.
SK_BIO_1_PLAIN | 110 | Skill screen, detail panel | Buy and Sell orders move clearly more units a cycle. Unlocks the Culture Lab and bio-gel.

SK_BIO_2_NAME | 24 | Skill screen, node name | Culture Banks
SK_BIO_2_FLAVOUR | 90 | Skill screen, detail panel | Something grows in the dark and asks for nothing. For now.
SK_BIO_2_PLAIN | 110 | Skill screen, detail panel | Grows Biotech stock in planet storage each cycle, to a cap. Tech: craft {goal} units at the Culture Lab.
SK_BIO_2_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_3_NAME | 24 | Skill screen, node name | Seed Bank
SK_BIO_3_FLAVOUR | 90 | Skill screen, detail panel | A shelf is a promise that something will be there.
SK_BIO_3_PLAIN | 110 | Skill screen, detail panel | Lets planet storage hold clearly more.

SK_BIO_4_NAME | 24 | Skill screen, node name | Gene Splicing
SK_BIO_4_FLAVOUR | 90 | Skill screen, detail panel | A small cut, a small stitch. The vat hums approval.
SK_BIO_4_PLAIN | 110 | Skill screen, detail panel | Unlocks gene seed. Tech: craft {goal} units.
SK_BIO_4_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_5_NAME | 24 | Skill screen, node name | Clinic Contracts
SK_BIO_5_FLAVOUR | 90 | Skill screen, detail panel | A clinic pays slowly, which the Bureau calls trust.
SK_BIO_5_PLAIN | 110 | Skill screen, detail panel | Counts a longer span of cycles in your Biotech share, so it moves more steadily.

SK_BIO_6_NAME | 24 | Skill screen, node name | Hardy Strains
SK_BIO_6_FLAVOUR | 90 | Skill screen, detail panel | A strain that survives the form survives most things.
SK_BIO_6_PLAIN | 110 | Skill screen, detail panel | Biotech events cost you a little less. A closed planet reopens a cycle sooner. Tech: craft {goal} units.
SK_BIO_6_CRAFT | 60 | Skill screen, tech node progress line | Culture Lab crafts: {n} of {goal}

SK_BIO_7_NAME | 24 | Skill screen, node name | Patent Wall
SK_BIO_7_FLAVOUR | 90 | Skill screen, detail panel | A wall made of paper outlasts one made of stone.
SK_BIO_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Biotech strength clearly for the rest of the run. Capstone.
