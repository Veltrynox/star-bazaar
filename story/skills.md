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
SK_FND_STORAGE_FLAVOUR | 90 | Skill screen, detail panel | One hold for all the crew owns. Someone has to count it every night.
SK_FND_STORAGE_PLAIN | 110 | Skill screen, detail panel | Lets you keep one large company storage per system, the Space Storage. Planet storage feeds it slowly.

SK_FND_PERMIT_NAME | 24 | Skill screen, node name | Permit Charter
SK_FND_PERMIT_FLAVOUR | 90 | Skill screen, detail panel | A stamped page lets the ship leave. The crew waits by the door for it.
SK_FND_PERMIT_PLAIN | 110 | Skill screen, detail panel | Lets you buy permits for new systems and run routes between systems.

SK_FND_PROSPECT_NAME | 24 | Skill screen, node name | Prospecting
SK_FND_PROSPECT_FLAVOUR | 90 | Skill screen, detail panel | You stare at a blank patch of sky until it shows you something worth a trip.
SK_FND_PROSPECT_PLAIN | 110 | Skill screen, detail panel | Lets routes start at asteroid clusters and shows how much each cluster holds.

SK_MIL_1_NAME | 24 | Skill screen, node name | Quartermaster's Terms
SK_MIL_1_FLAVOUR | 90 | Skill screen, detail panel | The yard thanks you for the order. You do not ask what it is for.
SK_MIL_1_PLAIN | 110 | Skill screen, detail panel | Cuts Ship upkeep by 20%. Unlocks Military crafting in your second system.

SK_MIL_2_NAME | 24 | Skill screen, node name | Night Shift Casting
SK_MIL_2_FLAVOUR | 90 | Skill screen, detail panel | The furnace never cools now. Neither do the hands that tend it.
SK_MIL_2_PLAIN | 140 | Skill screen, detail panel | Military workshops make one more batch a cycle, if you haul the inputs. Tech: craft {goal} units.
SK_MIL_2_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_3_NAME | 24 | Skill screen, node name | Convoy Pilots
SK_MIL_3_FLAVOUR | 90 | Skill screen, detail panel | They fly through the wreck of other convoys. They do not read the names.
SK_MIL_3_PLAIN | 110 | Skill screen, detail panel | Routes with Military goods carry 12.5% more a cycle and ignore debris events on the lane.

SK_MIL_4_NAME | 24 | Skill screen, node name | Carbine Line
SK_MIL_4_FLAVOUR | 90 | Skill screen, detail panel | Every crate is signed for. Your name is on the last line of each.
SK_MIL_4_PLAIN | 110 | Skill screen, detail panel | Unlocks a second Military product. Tech: craft {goal} units.
SK_MIL_4_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_5_NAME | 24 | Skill screen, node name | Embargo Desk
SK_MIL_5_FLAVOUR | 90 | Skill screen, detail panel | One call and a rival's yard goes quiet. A clerk thanks you for your patience.
SK_MIL_5_PLAIN | 110 | Skill screen, detail panel | Every {m} cycles pick a rival: its Military strength falls by half for {n} cycles.

SK_MIL_6_NAME | 24 | Skill screen, node name | The Long Contract
SK_MIL_6_FLAVOUR | 90 | Skill screen, detail panel | The buyer sends a card of thanks. You know what the cargo is for.
SK_MIL_6_PLAIN | 140 | Skill screen, detail panel | Events that cut your Military prices hit half as hard. Military sales pay 6% more. Tech: craft {goal} units.
SK_MIL_6_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_7_NAME | 24 | Skill screen, node name | Standing Fleet
SK_MIL_7_FLAVOUR | 90 | Skill screen, detail panel | Ships wait on every lane. People thank you for the quiet. You know its price.
SK_MIL_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Military growth in half for the rest of the run. Capstone.

SK_LUX_1_NAME | 24 | Skill screen, node name | The Whisper Circle
SK_LUX_1_FLAVOUR | 90 | Skill screen, detail panel | You hear what the rich will pay before they know it. They smile when you pass.
SK_LUX_1_PLAIN | 110 | Skill screen, detail panel | Shows next cycle's prices. Unlocks Luxury crafting.

SK_LUX_2_NAME | 24 | Skill screen, node name | A Finer Finish
SK_LUX_2_FLAVOUR | 90 | Skill screen, detail panel | No one buys the thing. They buy the look on the next person's face.
SK_LUX_2_PLAIN | 140 | Skill screen, detail panel | Luxury sales count 8% more toward share and pay 6% more. Tech: craft {goal} units.
SK_LUX_2_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_3_NAME | 24 | Skill screen, node name | Early Invitation
SK_LUX_3_FLAVOUR | 90 | Skill screen, detail panel | You learn of trouble first. It earns a seat, and a dread of losing it.
SK_LUX_3_PLAIN | 110 | Skill screen, detail panel | Warns you one cycle before an event, in all four markets.

SK_LUX_4_NAME | 24 | Skill screen, node name | The Cutting Room
SK_LUX_4_FLAVOUR | 90 | Skill screen, detail panel | A stone is cut until it shines. What was cut away is not on the list.
SK_LUX_4_PLAIN | 110 | Skill screen, detail panel | Unlocks a second Luxury product, made from two trade goods. Tech: craft {goal} units.
SK_LUX_4_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_5_NAME | 24 | Skill screen, node name | Patron's List
SK_LUX_5_FLAVOUR | 90 | Skill screen, detail panel | Your name is on the list. Another name came off to make room.
SK_LUX_5_PLAIN | 110 | Skill screen, detail panel | Sales at a price-up planet count 30% more toward your Luxury share, and the event pays 25% more.

SK_LUX_6_NAME | 24 | Skill screen, node name | Hallmark
SK_LUX_6_FLAVOUR | 90 | Skill screen, detail panel | Your mark is pressed in every piece. They love the mark more than you.
SK_LUX_6_PLAIN | 140 | Skill screen, detail panel | Each Luxury batch yields one more unit. Luxury sales pay 8% more. Tech: craft {goal} units.
SK_LUX_6_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_7_NAME | 24 | Skill screen, node name | Guild Seal
SK_LUX_7_FLAVOUR | 90 | Skill screen, detail panel | You decide who is let in. A rival stands outside and watches the door.
SK_LUX_7_PLAIN | 110 | Skill screen, detail panel | Every {m} cycles pick a rival: its Luxury strength falls by 40% for {n} cycles. Capstone.

SK_MIN_1_NAME | 24 | Skill screen, node name | Fabrication Licence
SK_MIN_1_FLAVOUR | 90 | Skill screen, detail panel | You sign to take from the ground. The ground does not sign back.
SK_MIN_1_PLAIN | 110 | Skill screen, detail panel | Unlocks Minerals crafting. Needs Prospecting.

SK_MIN_2_NAME | 24 | Skill screen, node name | The Long Burn
SK_MIN_2_FLAVOUR | 90 | Skill screen, detail panel | The furnace takes its time, then yours. You sit alone with the glow.
SK_MIN_2_PLAIN | 110 | Skill screen, detail panel | Orders for mined cargo ignore the size cap. Tech: craft {goal} units.
SK_MIN_2_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_3_NAME | 24 | Skill screen, node name | Cold Survey
SK_MIN_3_FLAVOUR | 90 | Skill screen, detail panel | Cold rock, no air, no voice on the radio. You are the only thing awake.
SK_MIN_3_PLAIN | 140 | Skill screen, detail panel | Lets routes start at Cinderrest and mine its salt. Cluster yield up 25%. Dead worlds open later.

SK_MIN_4_NAME | 24 | Skill screen, node name | Double Burn
SK_MIN_4_FLAVOUR | 90 | Skill screen, detail panel | Twice the heat, twice the hours. The ground takes back what you spend.
SK_MIN_4_PLAIN | 110 | Skill screen, detail panel | Minerals workshops make one more batch a cycle. Tech: craft {goal} units.
SK_MIN_4_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_5_NAME | 24 | Skill screen, node name | Deep Cut
SK_MIN_5_FLAVOUR | 90 | Skill screen, detail panel | Under the dust, glass that hums. It hums when you cut. It does not stop when you leave.
SK_MIN_5_PLAIN | 110 | Skill screen, detail panel | Lets routes start at Greywake and mine its humming glass. Needs Cold Survey.

SK_MIN_6_NAME | 24 | Skill screen, node name | Lattice Works
SK_MIN_6_FLAVOUR | 90 | Skill screen, detail panel | Every piece leans on the next. Pull one out and the rest remember.
SK_MIN_6_PLAIN | 140 | Skill screen, detail panel | Each Minerals batch yields one more unit and sales pay 8% more. Unlocks a further product. Tech: craft {goal} units.
SK_MIN_6_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_7_NAME | 24 | Skill screen, node name | Cornered Seam
SK_MIN_7_FLAVOUR | 90 | Skill screen, detail panel | The last seam is yours. The rest dig worse rock and owe the dark for it.
SK_MIN_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Minerals strength by 30% for the rest of the run. Capstone.

SK_BIO_1_NAME | 24 | Skill screen, node name | Culture Charter
SK_BIO_1_FLAVOUR | 90 | Skill screen, detail panel | A form says what may live in your vats. You sign for every small life.
SK_BIO_1_PLAIN | 110 | Skill screen, detail panel | Unlocks Biotech crafting in your second system.

SK_BIO_2_NAME | 24 | Skill screen, node name | Culture Banks
SK_BIO_2_FLAVOUR | 90 | Skill screen, detail panel | Something grows in the cold. It does not ask who feeds it. It knows.
SK_BIO_2_PLAIN | 140 | Skill screen, detail panel | Stored Biotech grows 2% a cycle, up to +20%. Biotech sales count 12% more toward share. Tech: craft {goal} units.
SK_BIO_2_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_3_NAME | 24 | Skill screen, node name | The Long Ward
SK_BIO_3_FLAVOUR | 90 | Skill screen, detail panel | Rows of jars hold the sleeping stock. You walk past at night and count.
SK_BIO_3_PLAIN | 110 | Skill screen, detail panel | Planet storage holds 50% more. Biotech stock may now grow up to +30% before it stops.

SK_BIO_4_NAME | 24 | Skill screen, node name | Gene Splicing
SK_BIO_4_FLAVOUR | 90 | Skill screen, detail panel | One small stitch and the crop changes. Who signs for the change? You do.
SK_BIO_4_PLAIN | 110 | Skill screen, detail panel | Unlocks the last Biotech product. Biotech sales pay 10% more. Tech: craft {goal} units.
SK_BIO_4_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_5_NAME | 24 | Skill screen, node name | Clinic Contracts
SK_BIO_5_FLAVOUR | 90 | Skill screen, detail panel | A clinic waits for your crate. Someone on a cot waits for the clinic.
SK_BIO_5_PLAIN | 110 | Skill screen, detail panel | Biotech share counts 12 more cycles, so it moves steadily. Biotech stock survives storage cuts.

SK_BIO_6_NAME | 24 | Skill screen, node name | Hardy Strains
SK_BIO_6_FLAVOUR | 90 | Skill screen, detail panel | It lives through the cold, the form and the fever. You stop asking if it should.
SK_BIO_6_PLAIN | 140 | Skill screen, detail panel | Biotech events hit 40% weaker. A closed planet reopens a cycle sooner. Sales pay 8% more. Tech: craft {goal} units.
SK_BIO_6_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_7_NAME | 24 | Skill screen, node name | Patent Wall
SK_BIO_7_FLAVOUR | 90 | Skill screen, detail panel | A cure with your name on it. Those who need it must ask you first.
SK_BIO_7_PLAIN | 110 | Skill screen, detail panel | Cuts all rivals' Biotech strength by 25% for the rest of the run. Capstone.

## Side skills
SK_LUX_5B_NAME | 24 | Skill screen, node name | The Long Wait
SK_LUX_5B_FLAVOUR | 90 | Skill screen, detail panel | You know what they will want next season. You start to want it too.
SK_LUX_5B_PLAIN | 110 | Skill screen, detail panel | Prices and events are shown 2 cycles ahead.

SK_MIN_5B_NAME | 24 | Skill screen, node name | Shift Roll Call
SK_MIN_5B_FLAVOUR | 90 | Skill screen, detail panel | Hats will not stop a rock. So each shift starts with names read aloud.
SK_MIN_5B_PLAIN | 110 | Skill screen, detail panel | Minerals routes carry 10% more and ignore debris. Minerals price events hit 30% weaker.
