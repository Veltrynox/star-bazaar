# Skills (four market trees)

Format: ID | max length | place | text. Appears on the skill screen: name on the node, plain line first, then flavour line (changed 2026-11-04). Costs and values are shown by the game from data, never written here. Prerequisites are shown by the game too. The plain line (line 1, no label) is the only line that states the effect; the flavour line (line 2) never repeats it.

## Screen strings
SK_HEADER | 24 | Skill screen title | Skills
SK_NEEDS | 60 | Locked node line | Needs: {skill}.
SK_COST | 24 | Detail panel label, unused after 2026-11-04 (cost shown by the game) | Cost: {amount} points
SK_NO_CREDITS | 110 | Skill screen footer | Skills cost skill points, never credits.
SK_BOT_USE | 24 | Skill screen, menu button on a learned house skill (Embargo Desk, Guild Seal; pick a house) | Use on...
SK_BOT_USED | 40 | Skill screen, note on a once-per-run house skill already used | Used this run.
SK_BOT_COOLDOWN | 40 | Skill screen, note on a house skill that is recharging; {n} is cycles left | Ready in {n} cycles.

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
SK_MIL_5_FLAVOUR | 90 | Skill screen, detail panel | One call and a house's convoys wait at the gate. A clerk thanks you for your patience.
SK_MIL_5_PLAIN | 110 | Skill screen, detail panel | Every {m} cycles pick a house: its weather on your worlds and lanes is {pct} weaker for {n} cycles.

SK_MIL_6_NAME | 24 | Skill screen, node name | The Long Contract
SK_MIL_6_FLAVOUR | 90 | Skill screen, detail panel | The buyer sends a card of thanks. You know what the cargo is for.
SK_MIL_6_PLAIN | 140 | Skill screen, detail panel | Events that cut your Military prices hit half as hard. Military sales pay 6% more. Tech: craft {goal} units.
SK_MIL_6_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_7_NAME | 24 | Skill screen, node name | Watch Fleet
SK_MIL_7_FLAVOUR | 90 | Skill screen, detail panel | Ships wait on every lane and call each convoy before it lands. You know its price.
SK_MIL_7_PLAIN | 110 | Skill screen, detail panel | Adds {n} cycles of warning before house weather lands, for the rest of the run. Capstone.

SK_LUX_1_NAME | 24 | Skill screen, node name | The Whisper Circle
SK_LUX_1_FLAVOUR | 90 | Skill screen, detail panel | You hear what the rich will pay before they know it. They smile when you pass.
SK_LUX_1_PLAIN | 110 | Skill screen, detail panel | Shows next cycle's prices. Unlocks Luxury crafting.

SK_LUX_2_NAME | 24 | Skill screen, node name | A Finer Finish
SK_LUX_2_FLAVOUR | 90 | Skill screen, detail panel | No one buys the thing. They buy the look on the next person's face.
SK_LUX_2_PLAIN | 140 | Skill screen, detail panel | Luxury units sold into a world's need count a little more toward it. Sales pay 6% more. Tech: craft {goal} units.
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
SK_LUX_5_PLAIN | 110 | Skill screen, detail panel | Sales at a price-up planet count clearly more toward a world's need, and the event pays 25% more.

SK_LUX_6_NAME | 24 | Skill screen, node name | Hallmark
SK_LUX_6_FLAVOUR | 90 | Skill screen, detail panel | Your mark is pressed in every piece. They love the mark more than you.
SK_LUX_6_PLAIN | 140 | Skill screen, detail panel | Each Luxury batch yields one more unit. Luxury sales pay 8% more. Tech: craft {goal} units.
SK_LUX_6_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_7_NAME | 24 | Skill screen, node name | Guild Seal
SK_LUX_7_FLAVOUR | 90 | Skill screen, detail panel | You decide who is let in. A house convoy waits outside and watches the door.
SK_LUX_7_PLAIN | 110 | Skill screen, detail panel | Every {m} cycles pick a house: its weather on your worlds and lanes is {pct} weaker for {n} cycles. Capstone.

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

SK_MIN_7_NAME | 24 | Skill screen, node name | Braced Seam
SK_MIN_7_FLAVOUR | 90 | Skill screen, detail panel | The seam is shored and the shaft takes the blow. Weather passes over it.
SK_MIN_7_PLAIN | 110 | Skill screen, detail panel | Makes house weather {pct} weaker on your worlds and lanes for the rest of the run. Capstone.

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
SK_BIO_5_PLAIN | 110 | Skill screen, detail panel | Cuts the progress a world loses after a short-need cycle a little. Biotech stock survives storage cuts.

SK_BIO_6_NAME | 24 | Skill screen, node name | Hardy Strains
SK_BIO_6_FLAVOUR | 90 | Skill screen, detail panel | It lives through the cold, the form and the fever. You stop asking if it should.
SK_BIO_6_PLAIN | 140 | Skill screen, detail panel | Biotech events hit 40% weaker. A closed planet reopens a cycle sooner. Sales pay 8% more. Tech: craft {goal} units.
SK_BIO_6_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_7_NAME | 24 | Skill screen, node name | Cold Wall
SK_BIO_7_FLAVOUR | 90 | Skill screen, detail panel | A sealed wall around every vat. Floods and queues stop at the door.
SK_BIO_7_PLAIN | 110 | Skill screen, detail panel | Makes house weather {pct} weaker on your worlds and lanes for the rest of the run. Capstone.

## Side skills
SK_LUX_5B_NAME | 24 | Skill screen, node name | The Long Wait
SK_LUX_5B_FLAVOUR | 90 | Skill screen, detail panel | You know what they will want next season. You start to want it too.
SK_LUX_5B_PLAIN | 110 | Skill screen, detail panel | Prices and events are shown 2 cycles ahead.

SK_MIN_5B_NAME | 24 | Skill screen, node name | Shift Roll Call
SK_MIN_5B_FLAVOUR | 90 | Skill screen, detail panel | Hats will not stop a rock. So each shift starts with names read aloud.
SK_MIN_5B_PLAIN | 110 | Skill screen, detail panel | Minerals routes carry 10% more and ignore debris. Minerals price events hit 30% weaker.

## Skills fill (T207 proposal, 35 nodes; ids kept from design/proposals/2026-11-05-skills-fill.md)
Text only. Sizes are in words; the economy designer sets numbers. Nodes are not yet in data/skills.json.

SK_FND_LEDGER_NAME | 24 | Skill screen, node name | Route Ledger
SK_FND_LEDGER_FLAVOUR | 90 | Skill screen, detail panel | A column of small numbers, honest to the last coin. You read it twice.
SK_FND_LEDGER_PLAIN | 110 | Skill screen, detail panel | Each route shows its net profit per cycle after trip cost and Ship upkeep.

SK_FND_RIVAL_WATCH_NAME | 24 | Skill screen, node name | Rival Watch
SK_FND_RIVAL_WATCH_FLAVOUR | 90 | Skill screen, detail panel | You learn where the others will stand before they do. They learn you looked.
SK_FND_RIVAL_WATCH_PLAIN | 110 | Skill screen, detail panel | The Competitors screen shows each rival's expected share 3 cycles ahead.

SK_FND_DOCKS_NAME | 24 | Skill screen, node name | Dock Contracts
SK_FND_DOCKS_FLAVOUR | 90 | Skill screen, detail panel | A fixed fee, a stamped berth, a clerk who stops asking.
SK_FND_DOCKS_PLAIN | 110 | Skill screen, detail panel | Upgrading a route costs less.

SK_MIL_8_NAME | 24 | Skill screen, node name | Yard Account
SK_MIL_8_FLAVOUR | 90 | Skill screen, detail panel | A ledger of hulls, signed in triplicate. The yard knows your name.
SK_MIL_8_PLAIN | 110 | Skill screen, detail panel | Ships cost less to buy.

SK_MIL_9_NAME | 24 | Skill screen, node name | Cell Press
SK_MIL_9_FLAVOUR | 90 | Skill screen, detail panel | Cells pressed on your own floor. No freight, no waiting.
SK_MIL_9_PLAIN | 140 | Skill screen, detail panel | Military units sold into a world's need count a little more toward it. Tech: craft {goal} units.
SK_MIL_9_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_10_NAME | 24 | Skill screen, node name | Hardened Stores
SK_MIL_10_FLAVOUR | 90 | Skill screen, detail panel | Steel door, one guard, a lock with a number. The cuts stop outside.
SK_MIL_10_PLAIN | 110 | Skill screen, detail panel | Storage cuts do not trim your stored Military goods.

SK_MIL_11_NAME | 24 | Skill screen, node name | Proof Range
SK_MIL_11_FLAVOUR | 90 | Skill screen, detail panel | The range is loud. The buyer pays for loud.
SK_MIL_11_PLAIN | 140 | Skill screen, detail panel | Your second Military product sells for more. Tech: craft {goal} units.
SK_MIL_11_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_12_NAME | 24 | Skill screen, node name | Open Arsenal
SK_MIL_12_FLAVOUR | 90 | Skill screen, detail panel | The doors stay open, and a hungry town waits a little longer for you.
SK_MIL_12_PLAIN | 110 | Skill screen, detail panel | Cuts the progress a world loses after a cycle with a short need clearly.

SK_MIL_13_NAME | 24 | Skill screen, node name | Pressure Doctrine
SK_MIL_13_FLAVOUR | 90 | Skill screen, detail panel | You make the call sooner now. The clerk has learned your voice.
SK_MIL_13_PLAIN | 110 | Skill screen, detail panel | Embargo Desk recharges sooner.

SK_MIL_14_NAME | 24 | Skill screen, node name | War Economy
SK_MIL_14_FLAVOUR | 90 | Skill screen, detail panel | Every crate has a second use on the ledger. Nobody says it aloud.
SK_MIL_14_PLAIN | 140 | Skill screen, detail panel | Each Military batch yields more units. Tech: craft {goal} units.
SK_MIL_14_CRAFT | 60 | Skill screen, tech node progress line | Military workshop crafts: {n} of {goal}

SK_MIL_15_NAME | 24 | Skill screen, node name | Last Line
SK_MIL_15_FLAVOUR | 90 | Skill screen, detail panel | The line holds because nobody wants to test it.
SK_MIL_15_PLAIN | 110 | Skill screen, detail panel | Makes house weather a further {pct} weaker on your worlds and lanes for the rest of the run. Capstone.

SK_LUX_8_NAME | 24 | Skill screen, node name | Salon Circle
SK_LUX_8_FLAVOUR | 90 | Skill screen, detail panel | Small room, soft chairs, hard questions. Few leave before dawn.
SK_LUX_8_PLAIN | 110 | Skill screen, detail panel | Cuts the progress a world loses after a cycle with a short need a little.

SK_LUX_9_NAME | 24 | Skill screen, node name | Second Loom
SK_LUX_9_FLAVOUR | 90 | Skill screen, detail panel | A second loom hums beside the first. The thread is never enough.
SK_LUX_9_PLAIN | 140 | Skill screen, detail panel | Luxury workshops make one more batch a cycle. Tech: craft {goal} units.
SK_LUX_9_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_10_NAME | 24 | Skill screen, node name | Trend Desk
SK_LUX_10_FLAVOUR | 90 | Skill screen, detail panel | You see the cold front coming and have the coat ready.
SK_LUX_10_PLAIN | 110 | Skill screen, detail panel | Events that cut your Luxury prices hit weaker.

SK_LUX_11_NAME | 24 | Skill screen, node name | Collector's Eye
SK_LUX_11_FLAVOUR | 90 | Skill screen, detail panel | One buyer wants the piece more than all the rest. You wait for that one.
SK_LUX_11_PLAIN | 140 | Skill screen, detail panel | Your second Luxury product sells for more. Tech: craft {goal} units.
SK_LUX_11_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_12_NAME | 24 | Skill screen, node name | Press Room
SK_LUX_12_FLAVOUR | 90 | Skill screen, detail panel | Your name on the page, in a good typeface. The page is not free.
SK_LUX_12_PLAIN | 110 | Skill screen, detail panel | Luxury routes carry more a cycle.

SK_LUX_13_NAME | 24 | Skill screen, node name | Patron's Purse
SK_LUX_13_FLAVOUR | 90 | Skill screen, detail panel | A mixed crate pleases every hand at the table.
SK_LUX_13_PLAIN | 110 | Skill screen, detail panel | Units sold into a world's need count a little more. Routes with mixed cargo earn a larger bonus.

SK_LUX_14_NAME | 24 | Skill screen, node name | Auction House
SK_LUX_14_FLAVOUR | 90 | Skill screen, detail panel | The hammer falls and the room exhales. You count afterwards.
SK_LUX_14_PLAIN | 140 | Skill screen, detail panel | Luxury units sold into a world's need count clearly more toward it. Tech: craft {goal} units.
SK_LUX_14_CRAFT | 60 | Skill screen, tech node progress line | Luxury workshop crafts: {n} of {goal}

SK_LUX_15_NAME | 24 | Skill screen, node name | Gilt Window
SK_LUX_15_FLAVOUR | 90 | Skill screen, detail panel | From the salon balcony you see every convoy coming. The guests think it is for them.
SK_LUX_15_PLAIN | 110 | Skill screen, detail panel | Adds {n} more cycles of warning before house weather lands, for the rest of the run. Capstone.

SK_MIN_8_NAME | 24 | Skill screen, node name | Deep Hold
SK_MIN_8_FLAVOUR | 90 | Skill screen, detail panel | A bigger hold, a lower ceiling. The crew learns to stoop.
SK_MIN_8_PLAIN | 110 | Skill screen, detail panel | Storage holds more mined cargo.

SK_MIN_9_NAME | 24 | Skill screen, node name | Slag Reclaim
SK_MIN_9_FLAVOUR | 90 | Skill screen, detail panel | What the fire leaves is melted down again. Waste becomes a habit you drop.
SK_MIN_9_PLAIN | 140 | Skill screen, detail panel | Workshop recipes need less mined cargo. Units sold into a world's need count a little more. Tech: craft {goal} units.
SK_MIN_9_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_10_NAME | 24 | Skill screen, node name | Safe Passage
SK_MIN_10_FLAVOUR | 90 | Skill screen, detail panel | A beacon on every cold rock. Fewer crews go missing.
SK_MIN_10_PLAIN | 110 | Skill screen, detail panel | Mined cargo is lost less often on dead worlds.

SK_MIN_11_NAME | 24 | Skill screen, node name | Hot Foundry
SK_MIN_11_FLAVOUR | 90 | Skill screen, detail panel | The pour is bright and quick. Buyers like the shine.
SK_MIN_11_PLAIN | 140 | Skill screen, detail panel | Minerals sales pay more. Tech: craft {goal} units.
SK_MIN_11_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_12_NAME | 24 | Skill screen, node name | Seam Brokers
SK_MIN_12_FLAVOUR | 90 | Skill screen, detail panel | A man with a ledger and a smile pays well for a sure thing.
SK_MIN_12_PLAIN | 110 | Skill screen, detail panel | Minerals price events in your favour pay more.

SK_MIN_13_NAME | 24 | Skill screen, node name | Core Tuning
SK_MIN_13_FLAVOUR | 90 | Skill screen, detail panel | Dials, a steady hand, a long cold trip made a little shorter.
SK_MIN_13_PLAIN | 110 | Skill screen, detail panel | Trips to dead worlds cost less.

SK_MIN_14_NAME | 24 | Skill screen, node name | Mass Melt
SK_MIN_14_FLAVOUR | 90 | Skill screen, detail panel | The big furnace never asks what it is melting. It asks for more.
SK_MIN_14_PLAIN | 140 | Skill screen, detail panel | Minerals units sold into a world's need count clearly more toward it. Tech: craft {goal} units.
SK_MIN_14_CRAFT | 60 | Skill screen, tech node progress line | Minerals workshop crafts: {n} of {goal}

SK_MIN_15_NAME | 24 | Skill screen, node name | Motherlode
SK_MIN_15_FLAVOUR | 90 | Skill screen, detail panel | The seam goes deeper than the map. Nobody tells the map.
SK_MIN_15_PLAIN | 110 | Skill screen, detail panel | Cluster yield rises again. Capstone.

SK_BIO_8_NAME | 24 | Skill screen, node name | Gel Cooperatives
SK_BIO_8_FLAVOUR | 90 | Skill screen, detail panel | Neighbours share a vat and a quarrel. The gel does not mind.
SK_BIO_8_PLAIN | 110 | Skill screen, detail panel | Biotech routes carry more a cycle.

SK_BIO_9_NAME | 24 | Skill screen, node name | Spore Bank
SK_BIO_9_FLAVOUR | 90 | Skill screen, detail panel | A cold shelf of sleepers, ready to wake when you need them.
SK_BIO_9_PLAIN | 140 | Skill screen, detail panel | Biotech workshops make one more batch a cycle. Tech: craft {goal} units.
SK_BIO_9_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_10_NAME | 24 | Skill screen, node name | Cold Chain
SK_BIO_10_FLAVOUR | 90 | Skill screen, detail panel | Frost in every crate, from the vat to the door.
SK_BIO_10_PLAIN | 110 | Skill screen, detail panel | Biotech routes ignore debris events on the lane.

SK_BIO_11_NAME | 24 | Skill screen, node name | Graft Lines
SK_BIO_11_FLAVOUR | 90 | Skill screen, detail panel | A cutting, a stitch, a row of small green promises.
SK_BIO_11_PLAIN | 140 | Skill screen, detail panel | Each Biotech batch yields more units. Tech: craft {goal} units.
SK_BIO_11_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_12_NAME | 24 | Skill screen, node name | Patient Orchard
SK_BIO_12_FLAVOUR | 90 | Skill screen, detail panel | Nothing to do but wait. It is harder than it sounds.
SK_BIO_12_PLAIN | 110 | Skill screen, detail panel | Stored Biotech grows faster each cycle.

SK_BIO_13_NAME | 24 | Skill screen, node name | Market Days
SK_BIO_13_FLAVOUR | 90 | Skill screen, detail panel | The stalls open when the news does. Your jars are ready.
SK_BIO_13_PLAIN | 110 | Skill screen, detail panel | Biotech sales at a price-up planet count more toward that world's need.

SK_BIO_14_NAME | 24 | Skill screen, node name | Living Contracts
SK_BIO_14_FLAVOUR | 90 | Skill screen, detail panel | A signed promise to deliver something alive. The ink is still wet.
SK_BIO_14_PLAIN | 140 | Skill screen, detail panel | Biotech sales pay more. Tech: craft {goal} units.
SK_BIO_14_CRAFT | 60 | Skill screen, tech node progress line | Biotech workshop crafts: {n} of {goal}

SK_BIO_15_NAME | 24 | Skill screen, node name | Early Bloom
SK_BIO_15_FLAVOUR | 90 | Skill screen, detail panel | Pollen drifts ahead of every convoy, and the vats lean toward it.
SK_BIO_15_PLAIN | 110 | Skill screen, detail panel | Adds {n} more cycles of warning before house weather lands, for the rest of the run. Capstone.
