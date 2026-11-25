# Events, system 1 (draft 2, tone rework)

Format: ID | title (max 32) | tag | kind, then text (max 280). Appears in the event popup under "News from the sky" (NOT_EVENT_PREFIX), with an OK button (BTN_OK).
Tags are from the brief only: [price up: planet, commodity], [price down: ...], [planet closed: planet]. Effect size and duration are the Economy Designer's. Planet closed means closed for a while; routes touching it are blocked. The Plan, quotas and the Bureau are story only and change nothing.
Kind: P = plain price news, Q = quiet musing, I = ironic. Dread = one small odd detail.

## Chain placeholders (market chains, ids EV_<step>_..., text in story/screens.md; added 2026-11-03)

The game fills these in chain text. No text contains a digit; every number comes from a placeholder.

| Placeholder | Filled with | Used in |
|---|---|---|
| {bot1}, {bot2}, {bot3} | Display names of the three houses (bot_1 Harrow Combine, flood; bot_2 Velvet Concord, shortage; bot_3 Ostrel Syndicate, congestion), from STD_BOT1_NAME to STD_BOT3_NAME. Never hard-coded in chain text, so a rename needs no text edit. | bodies, effect lines, results, house lines |
| {bot} | The marked house of the option just chosen (R7: biggest effect on its weather, boosts never count, a held-back cut counts as clearly, softer and later count the same, a tie goes to the lower bot number). Table below. In a result text it always names a house the option changed. In a step 2+ body of Military B4 it names the marked house of the previous Military step. | results, MIL_B4 bodies |
| {cash_in}, {cash_out} | Credits gained or paid by the option, number only (150, 300 or 600 from economy 8.1). | effect lines |
| {n} | Units of tech progress the option gives, number only (3 or 4). | effect lines |
| {cut} | In an effect line: "is held back" (read with the house name and Weather label: its next weather is held back), or "gets clearly softer weather" when that house has nothing left to hold back. Sentence shape: "<House> {cut}." | effect lines |
| {cut_std} | In a house line: "next weather held back", or "next weather clearly softer" when nothing is left to hold back. | house lines (_STD) |
| {market} | Market display name. No longer used in house lines or Weather lines (kept for epilogue lines). | epilogue lines |
| {get}, {cost}, {rivals} | Phrases for the template CH_EFFECT_LINE (Get / Cost / Weather, 200 characters). The id {rivals} is kept so the code needs no change; it is filled with the Weather part. Same size words as the written effect lines. Only for lines the game builds itself; the written EV_<step>_OP?_EFF lines are final and need no template. | CH_EFFECT_LINE |
| {workshop}, {share}, {bots} | As in story/voice.md. | endings |

Size words (fixed): volume, price and upkeep up or down 5 or 8 or 20 percent or one trip cost of a third = "a little"; 10 or 15 or 40 percent = "clearly". House weather uses the same three words. Weather that lands softer or harder (was strength: 5 percent "a little", 10 "clearly", 18 "sharply") and weather that comes later or sooner (was growth: 10 percent "a little", 20 "clearly", 30 "sharply"). A cut that held back a tier is only ever {cut} or {cut_std}. A boost to a house is a Cost and reads "<House>'s weather lands a little harder" or "<House>'s next weather comes a little sooner"; the matching house line says "next weather lands a little harder" or "next weather comes a little sooner". Durations: 2 to 3 cycles "for a few cycles", 4 to 8 cycles "for a while", to cycle 40 "for the rest of the run". A timed house effect says "for a few cycles".

House effect is visible in every step three ways: the effect line (Weather part), the result text (the marked house as {bot}, other changed houses by {bot1} to {bot3}) and one or two house lines (_STD, _STD2) shown under the result and written into the house weather log (LBL_COMP_MOVE_*). Cuts come before boosts in the house lines. The held-back result text says "held back"; the house line carries {cut_std}. Rule of the rewrite: no chain text says a house is beaten, cut down or weaker. Choices only delay or soften a house's next weather, or make it come sooner or land harder.

Marked house per option (R7), computed by hand from economy 8.2; the game computes it itself and must agree. Rows MIL_C1 to BIO_C3 (added 2026-11-11) follow the plan file handoffs/story-designer/2026-11-11-event-expansion.json, where each option has exactly one house effect:

| Step | opt_a {bot} | opt_b {bot} |
|---|---|---|
| MIL_A1 | Harrow Combine | Harrow Combine |
| MIL_A2 | Ostrel Syndicate | Harrow Combine |
| MIL_A3 | Harrow Combine | Harrow Combine |
| MIL_B1 | Harrow Combine | Ostrel Syndicate |
| MIL_B2 | Velvet Concord | Harrow Combine |
| MIL_B3 | Ostrel Syndicate | Harrow Combine |
| MIL_B4 | Harrow Combine | Harrow Combine |
| MIL_C1 | Ostrel Syndicate | Velvet Concord |
| MIL_C2 | Harrow Combine | Velvet Concord |
| MIL_C3 | Ostrel Syndicate | Harrow Combine |
| LUX_A1 | Velvet Concord | Ostrel Syndicate |
| LUX_A2 | Velvet Concord | Velvet Concord |
| LUX_A3 | Velvet Concord | Ostrel Syndicate |
| LUX_B1 | Velvet Concord | Velvet Concord |
| LUX_B2 | Ostrel Syndicate | Velvet Concord |
| LUX_B3 | Velvet Concord | Harrow Combine |
| LUX_B4 | Velvet Concord | Velvet Concord |
| LUX_C1 | Velvet Concord | Ostrel Syndicate |
| LUX_C2 | Velvet Concord | Ostrel Syndicate |
| LUX_C3 | Velvet Concord | Harrow Combine |
| MIN_A1 | Harrow Combine | Harrow Combine |
| MIN_A2 | Ostrel Syndicate | Harrow Combine |
| MIN_A3 | Harrow Combine | Harrow Combine |
| MIN_B1 | Harrow Combine | Harrow Combine |
| MIN_B2 | Ostrel Syndicate | Harrow Combine |
| MIN_B3 | Harrow Combine | Harrow Combine |
| MIN_B4 | Harrow Combine | Harrow Combine |
| MIN_C1 | Harrow Combine | Ostrel Syndicate |
| MIN_C2 | Harrow Combine | Ostrel Syndicate |
| MIN_C3 | Harrow Combine | Ostrel Syndicate |
| BIO_A1 | Velvet Concord | Velvet Concord |
| BIO_A2 | Ostrel Syndicate | Velvet Concord |
| BIO_A3 | Velvet Concord | Velvet Concord |
| BIO_B1 | Velvet Concord | Ostrel Syndicate |
| BIO_B2 | Velvet Concord | Ostrel Syndicate |
| BIO_B3 | Velvet Concord | Velvet Concord |
| BIO_B4 | Velvet Concord | Velvet Concord |
| BIO_C1 | Velvet Concord | Ostrel Syndicate |
| BIO_C2 | Velvet Concord | Ostrel Syndicate |
| BIO_C3 | Velvet Concord | Ostrel Syndicate |

Flavour pass 2 (2026-11-04, Military and Biotech). Story terms and cast for these two markets (flavour only, no mechanic; voice.md glossary not edited this session, owner to approve):
- Military: the Admiralty (wills things, in triplicate), the Fleet Office (its clerks), the estimate (a campaign budget that renews itself with the words "until victory"), the Quartermaster-Saint (patron of counters, a stamp-and-thumb figure), litanies and blessed crates (ritual around paperwork). Cast: Quartermaster Hanno Sulo (A1, A3), Tavi Brask (your Munitions Line engineer, talks to the press; A2, A3), Admiral Gabe Nuer (B1), Inspector Kethra Voss (B2, stamp worn like a sidearm), Madame Orlenne Vaux (B3, the Feast of Arms with its relic cannon), the Fleet Office clerk (B4).
- Biotech: dread of the sealed and the cold chain. Cast: Director Hesk (A1, A3, always says the sample is fine), Imre Fenn (seal fitter, the one who knew; A1, A3), Doctor Marrow (A2, volunteers by rota), the grower's manager (B1, same line), Ottoline Ryke (cold-chain hand; B2, B4), the derelict hull renamed Aisle (B4).
- Planets in these chains are system 1 only (Tillam, Ashgate), so no step names a system 2 planet before it opens. No step names a hidden good or workshop: Munitions Line appears only in steps that need MIL_1, Culture Lab only in steps that need BIO_1.
Chain flavour lines: MIL A: the quartermaster's war that never ends, ledgers and rites. MIL B: an admiral's sensor scheme, an inspector with a stamp, a feast of arms, a budget with no last page. BIO A: the unlabelled canister, the manager who says it is fine, the fitter who knew. BIO B: the cold chain, the strain that changes, a numbered exchange, racks in a sealed derelict.

Neutrality checks run on all 28 steps (script, not the game): no digit, no banned verdict word (good, bad, right, wrong, fair, safe, risky, bold, kind, open, closed, quiet, polite, late, long, short, small, big, plain, clean and the rest of 4.2 rule 1), no "but", "however" or "at least" in any text; button lengths within 5 characters, effect lines and results within 25 percent of each other. Each step's pair shares one grammar and one length class. The old Minerals chain events EV29 to EV37 stay in this file until the chain is wired; their choice texts name stances (Keep mining, Share the lane) and must be retired with the Open and Hard framing, not reused.

EV01 | Voltara's reactors run wild | [price down: Voltara, energy] | P
Energy at Voltara costs less and pays less. Pavo Quill kept the reactors running past shift change. His meal sits untouched beside the controls. Cheap power leaves room in your budget. His crew must sell more to earn the same.

EV02 | Grey blight on Tillam's terraces | [price up: Tillam, food] | P
Food at Tillam costs more and pays more. Grower Sella wipes grey dust from a dead leaf onto her sleeve. Her harvest crate is empty. A Seed Bank lets planet storage hold clearly more. Until then, each load costs more to bring home.

EV03 | Ashgate's harvest comes in heavy | [price down: Ashgate, food] | P
Food at Ashgate costs less and pays less. Clerk Nera's book lists half the harvest. Her son wheels the rest to the dock in a handcart. Buying costs less today. Nera needs the sacks sold before damp reaches the grain.

EV04 | Voltara's crews go hungry | [price up: Voltara, food] | P
Food at Voltara costs more and pays more. Loader Venn folds his ration slip around a heel of bread. The Bureau thanks the crews for waiting. Your next load can pay more here. Venn keeps the slip for tomorrow.

EV05 | Frost on Tillam | [price up: Tillam, energy] | P
Energy at Tillam costs more and pays more. The heaters run without rest. Brindle scrapes frost from the inside of a duct with his cup. He asks when the next load comes. You check what it will cost to send it.

EV06 | Ashgate lights every furnace | [price up: Ashgate, energy] | P
Energy at Ashgate costs more and pays more. Every foundry has relit for the new Plan. Brakeman Olan holds his coat against the furnace glare. He was meant to be home by now. The next load will cost more before it pays more.

EV07 | Tillam's docks go on strike | [planet closed: Tillam] | P
Tillam's port is closed for a while. Routes touching Tillam are blocked. Dockhand Sella hangs her unpaid shift slips on the gate. The Bureau asks for time to review them. Hardy Strains reopens a closed planet a cycle sooner.

EV08 | Ashgate seals its port | [planet closed: Ashgate] | P
Ashgate's port is closed for a while. Routes touching Ashgate are blocked. Doctor Eda presses a notice to the glass with her bare palm. Her coat is still inside the sealed dock. Your crews wait outside with their cargo.

EV09 | Voltara goes dark | [planet closed: Voltara] | I
Voltara's port is closed for a while. Routes touching Voltara are blocked after a grid fault. Clerk Neris holds a candle over the arrival book. She keeps a thumb on your ship's name. There is no berth she can give it.

EV10 | A lender walks Tillam's market | [price down: Tillam, energy] | Q
Energy at Tillam costs less and pays less for now. Shylo Vane has bought the sellers' debts. Trader Senn empties his stock to settle his share. He rubs the old price from his board. You can buy cheaply from him today.

EV11 | Ashgate's foreman says enough | [price down: Ashgate, energy] | Q
Energy at Ashgate costs less and pays less. Foreman Dov Rennick sent his crew home after the shift met its target. He hangs the furnace key beside his child's coat. Your stock will pay less here. His hands have stopped shaking.

EV12 | Voltara buys before the news | [price up: Voltara, energy] | Q
Energy at Voltara costs more and pays more. Wex said the far beacons had failed. They still shine above a dock stripped of stock. Buyer Eren holds an empty fuel can. Price Whisper shows next cycle's prices before you commit another load.

EV13 | A family buys Ashgate's food | [price up: Ashgate, food] | Q
Food at Ashgate costs more and pays more. Corvale's family bought every food contract. He flattens a receipt beneath the canteen's empty bread tray. Your cargo can earn more here. The cook asks which name she should put on her order.

EV14 | The inspector's count | [price down: Voltara, food] | I
Food at Voltara costs less and pays less. Inspector Pell marked the stores full on his form. Cook Venn turns an empty bin toward him. Pell asks for the bin's entry in the book. Your next sale pays less while they check.

EV15 | Tillam's festival of founders | [price up: Tillam, food] | I
Food at Tillam costs more and pays more. The founders' festival has filled the halls. Cook Sella removes her mask to count the bread left. Your cargo can earn more here. She sets aside a crust before opening the kitchen door.

EV16 | A ship leaves Tillam half empty | [price down: Tillam, food] | Q
Food at Tillam costs less and pays less. A ship left for uncharted rock with room still in its hold. Cook Eren sells the food he saved for a friend aboard. He leaves her cup beside the till. The sale must pay for his own stay.

## Goods events (T154, 2026-11-02): silk, logic cores, ore
EV21_TITLE | pool event title | The weavers stop work
EV21_BODY | pool event text | Silk at Brannock costs more and pays more. Weaver Nelle lays her shuttle across a form that counts her hours twice. The looms have stopped. Your next load can earn more. Nelle needs her hours counted before she takes the shuttle back.

EV22_TITLE | pool event title | Borrowed sleeves at Quillon
EV22_BODY | pool event text | Silk at Quillon costs more and pays more. Gala steward Coren pins a borrowed sleeve over his worn cuff. Every guest wants cloth before the doors close. Patron's List makes a price rise like this pay more. Coren asks how soon you can dock.

EV24_TITLE | pool event title | Ash in the control room
EV24_BODY | pool event text | Spy software at Cindrel costs more and pays more. Fire has blackened the reactor controls. Fitter Ressa wipes ash from the shift list until her own name shows. Replacing the lost stock costs more. So does each day her crew waits for it.

EV25_TITLE | pool event title | The tractors stand still
EV25_BODY | pool event text | Spy software at Mossfell costs more and pays more. The recalled tractors stand beside unworked rows. Foreman Iven holds a starter key against his palm. The new checks need software before the machines can return. His crew waits by the field gate.

EV26 | A rich seam is logged twice | [price down: Voltara, ore] | Q
Ore at Voltara costs less and pays less. Surveyor Edda has found her seam listed in separate offices. She lays the matching maps edge to edge. Smelting lets ore orders ignore the size cap. You can buy more cheaply while her sellers earn less.

EV28 | Voltara's foundry wants rock | [price up: Voltara, ore] | P
Ore at Voltara costs more and pays more. Foundry hand Olan draws the new rock order on a dusted bench. The old order still shows beneath it. Prospecting lets routes start at asteroid clusters, where ore is free. The route still costs you.

EV60 | Energy runs short at Voltara | [shortage: Voltara, energy] | Q
Energy demand and prices at Voltara rise for a few cycles. Grid hand Pavo cups his hands around an unlit panel. The night shift needs more power than the order booked. A load can pay more here. Bringing it still takes time and credits.

EV61 | Food runs short at Tillam | [shortage: Tillam, food] | Q
Food demand and prices at Tillam rise for a few cycles. Cook Eren scrapes the last grain from a bin's seam. The terraces cannot fill his next order yet. Your load can earn more here. He keeps the empty bin by the door.

EV62 | Food runs short at Ashgate | [shortage: Ashgate, food] | Q
Food demand and prices at Ashgate rise for a few cycles. Ration clerk Nera lays the stock form inside an empty bread tray. She has counted again. A load can earn more here. The names waiting for it fill the back of her form.

EV63 | Traffic jams at Tillam | [congestion: Tillam] | Q
Lanes touching Tillam cost more per trip for a few cycles. Dockhand Sella presses a thumb into her untouched lunch. The convoy queue has no promised berth. Keep your ships here and pay more. Send them elsewhere and leave these orders waiting.

EV64 | Traffic jams at Voltara | [congestion: Voltara] | Q
Lanes touching Voltara cost more per trip for a few cycles. Pilot Rusk taps the dark berth light with a fingernail. Every captain waits for clearance. Keep the lanes running at a higher cost, or send their cargo away from waiting buyers.

# Events, choice events (draft 1, T96 T100 T103 T108, 2026-10-28)

Format: ID | place | tag, then text. Choice events use the choice screen limits: title max 40, body max 280, button max 28, effect line max 90. Outcome texts are event popups: title max 32, text max 280, shown under NOT_EVENT_PREFIX with BTN_OK. No numbers: the game inserts any amount through a placeholder. Tags name the effect in words as the owner described it; the Economy Designer sets size and duration. Planet = {planet}.

## Debris in orbit [route efficiency down: {planet}, while the debris stays]
EV17_TITLE | choice title | Wreckage circles {planet}
EV17_BODY | choice body | Routes from {planet} carry less while wreckage stays in orbit. Captain Rusk offers to clear it for credits. A hull strip knocks against his window. Pay him and give up those credits. Leave it and crews from {planet} keep losing room in each load.
EV17_PAY_BTN | button | Pay for clearance
EV17_PAY_EFF | effect line | Pay for clearance. Debris clears. Routes from {planet} carry full loads again.
EV17_LEAVE_BTN | button | Keep the debris
EV17_LEAVE_EFF | effect line | Routes from {planet} carry less. Debris stays until you pay to clear it.
EV17_PAID_TITLE | popup title | Routes from {planet} restored
EV17_PAID | popup | Routes from {planet} carry full loads again. Rusk cleared the debris and sent his receipt. He rubs a dent in his tug's window while you check it. Those credits are spent. Your next crew has room for the cargo it had to leave behind.
EV17_LEFT_TITLE | popup title | Debris remains at {planet}
EV17_LEFT | popup | Routes from {planet} still carry less. Rusk keeps the offer available. Your pilot leaves a crate beside the hatch to make the reduced load. Its buyer's name faces out. Rusk's tug waits beyond the wreckage.

## Asteroid approach [warning; pay the state: no skill point, no reputation; decline: 50/50 bad outcome or nothing; bad outcome is storage destroyed or storage capacity cut]
EV20_TITLE | choice title | A rock on the dock chart
EV20_BODY | choice body | An asteroid is approaching. The state can turn it aside for credits. Dockhand Neris traces its path across the storage door on her chart. Pay and spend credits needed elsewhere. Refuse and storage may be hit. Cask Cellar protects Luxury stock from such a cut.
EV20_PAY_BTN | button | Pay for deflection
EV20_PAY_EFF | effect line | Pay the state. The asteroid is deflected. Gain an expansion point.
EV20_DECLINE_BTN | button | Refuse payment
EV20_DECLINE_EFF | effect line | An even chance: company storage is hit or spared. A hit destroys it or cuts capacity.
EV20_PAID_TITLE | popup title | The rock changes course
EV20_PAID | popup | The state deflected the asteroid. Your company gains an expansion point. Neris folds the path chart along the storage door's outline. The receipt goes beside your other costs. Your crews unload through the door she marked.
EV20_REWARD | notice (shown after EV20_PAID) | Asteroid deflected. Your company gains an expansion point.
EV20_HIT_TITLE | popup title | Company storage lost
EV20_HIT_DESTROYED | popup | The asteroid struck {planet}. Your company storage there and all its stock are gone. Neris holds the old load sheet against her chest. The Bureau asks her to list what was stored. She starts with the crates promised to your next crew.
EV20_HIT_CAPACITY | popup | The asteroid grazed {planet}. Your company storage there now holds less. Neris chalks the new stock line below the crack in the wall. Your crew moves the waiting crates back. The load sheet still asks for the old amount.
EV20_MISS_TITLE | popup title | The rock leaves your sky
EV20_MISS | popup | The asteroid passed without a hit. Nothing changes. Neris takes the path chart off the storage door. She folds it into her work coat. Your crews carry on loading, stepping around the place where she stood.

# Choice events with follow-ups (rewritten 2026-11-11)

Three story events with two choices each, one engine tag per choice (price up, price down, planet closed), and a follow-up popup that comes a few cycles after the choice (a choice carries follow_id; the follow-up is never drawn at random). Limits as the choice screen: title 40, body 280, button 28, effect line 90; popups: title 32, text 280. No numbers. Gates are in the plan file handoffs/story-designer/2026-11-11-event-expansion.json. BE01 and BE03 are Biotech only (they name food), BE02 is Luxury only (it names musk, silk and blooms).

## BE01 Tillam's sealed granary [2 choices, Biotech, Tillam]
BE01_TITLE | choice title | Grain behind the lock
BE01_BODY | choice body | Tillam's grain waits behind the committee's lock. Cook Eren presses an empty sack against his knees in the queue. Release the grain and food pays less. Keep it stored and food costs more. The committee asks your crew to carry it, or leave the lock.
BE01_OPEN_BTN | button | Release the grain
BE01_OPEN_EFF | effect line | Food at Tillam costs less and pays less for a while. Tillam remembers the release.
BE01_SHUT_BTN | button | Keep the grain stored
BE01_SHUT_EFF | effect line | Food at Tillam costs more and pays more for a while. Tillam remembers the refusal.
BE01_OPEN_TITLE | popup title | The sacks pass hand to hand
BE01_OPEN | popup | Food at Tillam costs less and pays less while stores are full. Eren holds his sack beneath the grain chute. Your next load will earn less here. The committee clerk writes the released stock as a loan. Eren asks whose name goes beside it.
BE01_SHUT_TITLE | popup title | The queue stays outside
BE01_SHUT | popup | Food at Tillam costs more and pays more while it stays scarce. Eren folds his empty sack for the walk home. The grain remains behind the lock. Your stock can earn more here. He stops at your dock to ask when it will arrive.

[follow-up of BE01_OPEN, tag: price up: Tillam, energy]
BE01A_TITLE | popup title | Heat reaches the terraces
BE01A | popup | Energy at Tillam costs more and pays more for a while. The committee runs the terrace heaters high after the grain release. Eren hangs his emptied sack near a warm duct. Your next energy load costs more before it earns more here.

[follow-up of BE01_SHUT, tag: planet closed: Tillam]
BE01B_TITLE | popup title | The queue reaches the docks
BE01B | popup | Tillam's port is closed for a while. Routes touching Tillam are blocked. Eren brings his folded sack to the dock gate. The granary queue stands beside him. Your pilot has a load ready. Eren keeps his hand on the latch.

## BE02 The beacon over Dunmere Reach [2 choices, Luxury, system 2]
BE02_TITLE | choice title | A pulse beyond the chart
BE02_BODY | choice body | A beacon over Dunmere Reach repeats the dock call. Pilot Ressa stops with her cup against her lip. Answer it and Quillon's musk costs more. Report it and Quillon closes for checks. The Bureau asks for a reply. Your ships pass that light each cycle.
BE02_ANSWER_BTN | button | Reply to the beacon
BE02_ANSWER_EFF | effect line | Musk at Quillon costs more and pays more for a while. The beacon answers.
BE02_REPORT_BTN | button | Report the beacon
BE02_REPORT_EFF | effect line | Quillon closes for a while. Routes touching Quillon are blocked during checks.
BE02_ANSWER_TITLE | popup title | Your call comes back
BE02_ANSWER | popup | Musk at Quillon costs more and pays more. Ressa sent the reply. The beacon went dark, then returned her pattern. Buyers began ordering for a festival no clerk could name. Ressa sets her cup down without drinking. Your next musk load has buyers.
BE02_REPORT_TITLE | popup title | Checks close the port
BE02_REPORT | popup | Quillon's port is closed for a while. Routes touching Quillon are blocked. The Bureau thanks Ressa for her report and begins its checks. She holds the reply slip beside the berth light. Beyond the dock glass, the beacon repeats her call.

[follow-up of BE02_ANSWER, tag: price up: Mossfell, blooms]
BE02A_TITLE | popup title | Stems for unnamed guests
BE02A | popup | Hothouse blooms at Mossfell cost more and pay more for a while. Visitors from the beacon's rock arrive without papers. Grower Nelle turns a heavy coin over in her palm. They count each stem before taking it. She asks where to send the next load.

[follow-up of BE02_REPORT, tag: price down: Quillon, silk]
BE02B_TITLE | popup title | The held stock goes on sale
BE02B | popup | Quillon's port reopens after the checks find nothing. Silk costs less and pays less for a while as held stock reaches the docks. Ressa pins the report beside her berth slip. Through the glass, the beacon still flashes. She leaves the report there.

## BE03 A family offers cover [2 choices, Biotech, Ashgate, after the family bought Ashgate's food (EV13)]
BE03_TITLE | choice title | Corvale offers dock cover
BE03_BODY | choice body | Corvale offers to keep other food traders off Ashgate's docks for a share. He smooths the note beneath your cook's order. Accept and food costs more. Refuse and food pays less as his buyers withdraw. Your crew watches his hand leave the paper.
BE03_ACCEPT_BTN | button | Accept the offer
BE03_ACCEPT_EFF | effect line | Food at Ashgate costs more and pays more for a while. The family will claim a favour.
BE03_REFUSE_BTN | button | Refuse the offer
BE03_REFUSE_EFF | effect line | Food at Ashgate costs less and pays less for a while. The family waits.
BE03_ACCEPT_TITLE | popup title | Corvale's people take posts
BE03_ACCEPT | popup | Food at Ashgate costs more and pays more under the family's prices. Corvale's people stand at the docks. Cook Nera tucks her order inside her sleeve before passing them. Your cargo earns more here. Other traders wait beyond the gate.
BE03_REFUSE_TITLE | popup title | The buyers step away
BE03_REFUSE | popup | Food at Ashgate costs less and pays less as the family's buyers withdraw. Corvale takes back his note. Cook Nera lays her order flat again. Your stock will earn less. She reads the new price before choosing how much to ask for.

[follow-up of BE03_ACCEPT, tag: planet closed: Ashgate]
BE03A_TITLE | popup title | The favour stops your ships
BE03A | popup | Ashgate's docks close to every ship except the family's. Routes touching Ashgate are blocked for a while. Corvale sends thanks with a bill for his cover. Nera presses your waiting load sheet beneath it. His clerk asks her to leave both.

[follow-up of BE03_REFUSE, tag: price down: Ashgate, energy]
BE03B_TITLE | popup title | A reader by the furnace
BE03B | popup | Energy at Ashgate costs less and pays less for a while. The family's buyers stay away from the furnaces. Corvale's courier sits by the dock with an unread page. Nera carries her order past him. He keeps his finger on the same line.

# Events, dead worlds: retired (2026-11-03)

The old Minerals events EV29 to EV37 (three dead-world choice events and six follow-ups) are retired. Minerals chain A (MIN_A1 to MIN_A3) replaced them. Their text, banners and data entries are removed; ids EV29 to EV37 are not reused. See data/chains.json pool_retired.

# Events, shared pool EV40 to EV51 (added 2026-11-03)

Twelve one-time pool events for the new goods and workshops, three per market (Military EV40 to EV42, Luxury EV43 to EV45, Minerals EV46 to EV48, Biotech EV49 to EV51). Each fires once per run. They are NOT rows in data/events.json yet: the build writes only text ids (EV<nn>_TITLE max 32, EV<nn>_BODY max 280, EV<nn>_EFF max 90, the rivals line). The tag and kind sit in the table below for the economy and gameplay tasks that add the rows and the art. Planets are suggestions; the economy designer maps them to the planets that trade the good.
Tags updated 2026-11-04 to match data/chains.json pool_new (planets and goods as the game applies them). Pool events do carry a small bot effect there; the game builds the Rivals line itself (Chains.pool_rivals_line), so the EV<nn>_EFF lines below are not shown. Older note: pool events carry no bot effect (core 4.4), so every rivals line says that no rival changes. If a pool event ever gets a bot effect, rewrite its EV<nn>_EFF line first.

| Id | Tag | Kind |
|---|---|---|
| EV40 | [price down: Voltara, rivets] | P |
| EV41 | [price up: Cindrel, rounds] | Q |
| EV42 | [price up: Quillon, arms] | I |
| EV43 | [price down: Tillam, musk] | I |
| EV44 | [price up: Brannock, gems] | Q |
| EV45 | [price down: Quillon, attar] | P |
| EV46 | [price up: Voltara, ingot] | P |
| EV47 | [price down: Voltara, alloy] | I |
| EV48 | [price up: Quillon, plate] | P |
| EV49 | [planet closed: Ashgate] | I |
| EV50 | [price down: Mossfell, spores] | Q |
| EV51 | [price up: Brannock, seed] | Q |

EV40_TITLE | pool event title | The order has no last load
EV40_BODY | pool event text | Rivet guns at Voltara cost less and pay less. Hanno Sulo holds the filled order beside another stack. Its last line still says until victory. His crew keeps casting. Contract Doctrine softens Military price events. Your next sale pays less for their work.
EV40_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.

EV43_TITLE | pool event title | Sunmusk without an order
EV43_BODY | pool event text | Sunmusk at Tillam costs less and pays less. Dockhand Eren cannot find an order for the convoy's stock. He covers his nose with his sleeve while checking the crates. Buying costs less today. Sellers keep asking him when someone will take it away.
EV43_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.

EV46_TITLE | pool event title | Cold metal in the smelter
EV46_BODY | pool event text | Ingot at Voltara costs more and pays more until the furnace relights. A cracked line has stopped the smelter. Fitter Edda holds her hands over metal that no longer warms them. Your next load can earn more. Her crew still needs stock to work.
EV46_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.

EV47_TITLE | pool event title | Alloy before the builders
EV47_BODY | pool event text | Seam alloy at Voltara costs less and pays less. The line finished before the builders placed their orders. Loader Marel rubs a stack mark from his sleeve. Buying costs less now. He asks where to put the next load while these stacks wait.
EV47_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.

EV49_TITLE | pool event title | A seal on the lab door
EV49_BODY | pool event text | Ashgate's port is closed for a while. Routes touching Ashgate are blocked after a culture changed colour. Ottoline Ryke checks names through the sealed lab door. Her thumb rests beside an unanswered name. Hardy Strains reopens a closed planet a cycle sooner.
EV49_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.

EV50_TITLE | pool event title | Spores beyond the orders
EV50_BODY | pool event text | Spore cultures at Mossfell cost less and pay less. Damp has brought more than the buyers ordered. Grower Imre wipes a wet crate lid before setting down his lunch. Buying costs less now. He keeps the unsold crates beside the shift's work.
EV50_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.


# Early branch events, one per market, EV52 to EV55 (added 2026-11-06, T233)

Four one-time pool events, one per market (Military EV52, Luxury EV53, Minerals EV54, Biotech EV55). They fire early, in the first cycles. TEXT ONLY: no row in data/events.json, no tag; T234 adds the mechanics. Each has a title, a body, a rivals line (EVnn_EFF, as the other pool events) and two options, A (the dark-market buyer) and B (the public market). Ids per option: EVnn_A_BTN (28), EVnn_A_EFF (90), EVnn_A_TITLE (32), EVnn_A (result, 280); the same with B.
Placeholder: {cash_in} is the credits the chosen option pays, number only. T234 fills it per option (A more than B). {market} is filled by the game in the EVnn_EFF line.
No text names a good, a planet or a number: the goods of the early cycles are only energy and food, so each event speaks of crates, sets, cases and trays. The effect lines say only "pays more now" or "pays less now". No text hints at being seen, a risk or a later cost.

EV52_TITLE | pool event title | An order at the back gate
EV52_BODY | pool event text | The Fleet Office needs its crates. Bosk Two-Stamps waits at the back gate with more credits than the public counter pays. Blue ink fills the crack in his thumb. He wants part of the order. Your loader holds the list against the waiting crates.
EV52_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.
EV52_A_BTN | button | Sell at the back gate
EV52_A_EFF | effect line | Gain {cash_in} credits now. This sale pays more.
EV52_A_TITLE | popup title | Bosk takes the crates
EV52_A | popup | You gain {cash_in} credits now. Bosk pays more than the public counter would. He presses his stained thumb onto the slip. Your loader crosses the sold crates off the Fleet Office list. Bosk folds the slip before the ink dries.
EV52_B_BTN | button | Sell at the counter
EV52_B_EFF | effect line | Gain {cash_in} credits now. This sale pays less.
EV52_B_TITLE | popup title | The clerk checks the list
EV52_B | popup | You gain {cash_in} credits, less than Bosk offered. The counter clerk matches every crate to the order. Your loader keeps a finger beside the next unchecked line. The clerk thanks her and turns back to the list.

EV53_TITLE | pool event title | Sets for the gala table
EV53_BODY | pool event text | The Orrel House needs its table sets. Madame Fenn offers more credits for some aboard her barge. Gala steward Nelle holds a seating card with a bent corner. Sell to Fenn for more, or take the sets to the public stalls for less.
EV53_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.
EV53_A_BTN | button | Sell aboard the barge
EV53_A_EFF | effect line | Gain {cash_in} credits now. This sale pays more.
EV53_A_TITLE | popup title | Fenn wraps the glass
EV53_A | popup | You gain {cash_in} credits now, more than the stalls would pay. Fenn wraps the sets in her shawl. Nelle turns over the seating card in her hand. The gala table will have fewer glasses when its guests arrive.
EV53_B_BTN | button | Sell at the stalls
EV53_B_EFF | effect line | Gain {cash_in} credits now. This sale pays less.
EV53_B_TITLE | popup title | Glass beneath the lamps
EV53_B | popup | You gain {cash_in} credits, less than Fenn offered. Buyers at the public stalls turn each glass beneath the lamps. Nelle keeps the bent seating card beside the sets. Your crew waits while the buyers work through the price.

EV54_TITLE | pool event title | Samples at the yard gate
EV54_BODY | pool event text | Deepline Works wants its sealed sample cases. Tamsk Reddock offers more credits for some at his slag yard. Your loader Edda grips a case by its worn handle. Sell to Tamsk for more, or carry the samples to the assay hall for less.
EV54_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.
EV54_A_BTN | button | Sell at the slag yard
EV54_A_EFF | effect line | Gain {cash_in} credits now. This sale pays more.
EV54_A_TITLE | popup title | Tamsk counts out the notes
EV54_A | popup | You gain {cash_in} credits now, more than the assay hall would pay. Tamsk takes the sealed cases. Edda eases her fingers off the worn handle. The cases leave for the slag yard with Deepline's labels still attached.
EV54_B_BTN | button | Sell at the assay hall
EV54_B_EFF | effect line | Gain {cash_in} credits now. This sale pays less.
EV54_B_TITLE | popup title | The seals are read aloud
EV54_B | popup | You gain {cash_in} credits, less than Tamsk offered. The assay clerk reads each seal before signing. Edda keeps her fingers curled around the empty handle space. Your crew waits for the clerk to finish the last case.

EV55_TITLE | pool event title | Trays for Lowmoor Clinics
EV55_BODY | pool event text | Lowmoor Clinics needs its chilled trays. Dr Pell Oruk waits behind the cold dock with more credits than the clinic desk pays. Nurse Ressa rubs a thumb over a ward label. Sell some trays to him for more, or take them to the desk for less.
EV55_EFF | pool event weather line | Weather: all houses keep their next weather unchanged.
EV55_A_BTN | button | Sell behind the dock
EV55_A_EFF | effect line | Gain {cash_in} credits now. This sale pays more.
EV55_A_TITLE | popup title | The ward label stays on
EV55_A | popup | You gain {cash_in} credits now, more than the clinic desk would pay. Dr Oruk takes the trays in a cold box. Ressa's thumb leaves a damp mark beside the ward label. The ward will get fewer trays.
EV55_B_BTN | button | Sell at the desk
EV55_B_EFF | effect line | Gain {cash_in} credits now. This sale pays less.
EV55_B_TITLE | popup title | Ressa checks each label
EV55_B | popup | You gain {cash_in} credits, less than Dr Oruk offered. Ressa reads each tray's ward label at the clinic desk. Her thumb stops on the last name. She signs for the load before carrying it through.

# Thread events TH01 to TH10: "The Lask page" (added 2026-11-06, T224)

One thread of ten connected choice events, not tied to any skill branch or market. TEXT ONLY: no row in data/events.json yet (the gameplay-programmer adds the rows, see handoffs/story-designer/2026-11-06-T224.json). English only. Ids are TH<nn>; per story: TH<nn>_TITLE (32), TH<nn>_BODY (280), then per option A and B: TH<nn>_<K>_BTN (28), TH<nn>_<K>_EFF (90), TH<nn>_<K>_TITLE (32), TH<nn>_<K> (popup, 280).
Thread: Maren Oake, once a Bureau bookkeeper, flies the tug Slow Receipt and hunts one old debt: the loan that bought the first ship of a crew like yours. One of its three lenders, Teodor Lask, was never repaid. The hunt goes through the dock book, a list, a rival seeker (Aurel Dask of the Quill Lender House), a scraped hull, a Bureau letter, a held tug, a letter from his daughter Ines Lask, a reading, and a last choice about what is owed.
Rules kept: every story works for either option of the one before (TH<nn> fires after TH<nn-1> by follow-up, whichever button was pressed). Both buttons per story are neutral and of near equal length; each carries one real effect named in words. All tags are at Voltara (the home world, a post from the start) in energy or food, the two goods visible from the start. Tillam, Ashgate and a far station appear only as places named in passing. No digits; the only placeholder is {cash_out} in TH10_A_EFF and TH10_A.

| Id | Trigger | A tag | B tag |
|---|---|---|---|
| TH01 | pool, once, from a start cycle (balance key to set), first of the thread | [price up: Voltara, food] | [price down: Voltara, energy] |
| TH02 | follow of TH01 (either option) | [price down: Voltara, food] | [price up: Voltara, energy] |
| TH03 | follow of TH02 | [price up: Voltara, food] | [price down: Voltara, energy] |
| TH04 | follow of TH03 | [price down: Voltara, food] | [price up: Voltara, energy] |
| TH05 | follow of TH04 | [price up: Voltara, energy] | [price down: Voltara, food] |
| TH06 | follow of TH05 | [price down: Voltara, food] | [planet closed: Voltara] |
| TH07 | follow of TH06 | [price up: Voltara, food] | [price down: Voltara, energy] |
| TH08 | follow of TH07 | [price up: Voltara, food] | [price up: Voltara, energy] |
| TH09 | follow of TH08 | [price down: Voltara, energy] | [price down: Voltara, food] |
| TH10 | follow of TH09 | [cash: pay {cash_out}] (new tag, see handoff) | [price up: Voltara, food] |

## TH01 A tug asks for your book
TH01_TITLE | event title | Oake asks for the dock book
TH01_BODY | event text | Maren Oake docks Slow Receipt at Voltara. The former Bureau clerk rests a split fingernail on your dock book. She is tracing an unpaid loan. Let her read it and food costs more. Send her to the Bureau and energy pays less. She waits for your hand to move.
TH01_A_BTN | button | Give Oake the book
TH01_A_EFF | effect line | For a while, food at Voltara costs more and pays more.
TH01_A_TITLE | popup title | A line on Oake's cuff
TH01_A | popup | Food at Voltara costs more and pays more for a while. Oake's helpers fill the canteen as she reads your dock book. At dawn she writes a name on her cuff. She holds it toward the lamp before returning your book.
TH01_B_BTN | button | Send Oake to the desk
TH01_B_EFF | effect line | For a while, energy at Voltara costs less and pays less.
TH01_B_TITLE | popup title | Oake waits beneath the cranes
TH01_B | popup | Energy at Voltara costs less and pays less for a while. Cranes stand idle as the Bureau checks Oake's request. She rests your dock's visitor slip on her knee. Each time the clerk looks up, her hand lifts from it.

## TH02 The first page
TH02_TITLE | event title | Lask never came to collect
TH02_BODY | event text | Oake brings the loan page that bought a crew's first ship. Her finger stops beside Teodor Lask's unpaid name. Search your papers and food pays less. Ask old dock crews and energy costs more. Oake lays a blank sheet beside the page for what you find.
TH02_A_BTN | button | Search the old papers
TH02_A_EFF | effect line | For a while, food at Voltara costs less and pays less.
TH02_A_TITLE | popup title | A receipt with no sum
TH02_A | popup | Food at Voltara costs less and pays less for a while. Your crew searches old crates and eats from tins. Oake finds Lask's name on a receipt with no sum. She holds it against the loan page. The blank spaces line up.
TH02_B_BTN | button | Ask the dock crews
TH02_B_EFF | effect line | For a while, energy at Voltara costs more and pays more.
TH02_B_TITLE | popup title | Lamps after the shift
TH02_B | popup | Energy at Voltara costs more and pays more for a while. The old crews keep lamps burning while they talk. A loader traces Lask's name in spilled tea. He remembers hearing it. He cannot place the voice.

## TH03 Lask on a relief list
TH03_TITLE | event title | A name on the relief list
TH03_BODY | event text | Cook Eren at Tillam found Lask on a relief list from the blight years. The list is locked away. Oake holds a request for your seal. Send it by ship and food costs more at home. Wait for the post ship and energy pays less.
TH03_A_BTN | button | Send a request ship
TH03_A_EFF | effect line | For a while, food at Voltara costs more and pays more.
TH03_A_TITLE | popup title | Your seal leaves the dock
TH03_A | popup | Food at Voltara costs more and pays more for a while. A hold went to Oake's letter instead of cargo. She presses your seal flat before the hatch shuts. Eren will have the request sooner. Your waiting food buyers have no load from that ship.
TH03_B_BTN | button | Wait for the post ship
TH03_B_EFF | effect line | For a while, energy at Voltara costs less and pays less.
TH03_B_TITLE | popup title | Oake keeps the letter dry
TH03_B | popup | Energy at Voltara costs less and pays less for a while. Dock work slows while the letter waits for the post ship. Oake keeps it beneath her coat when the roof drips. Eren has no request to show the committee yet.

## TH04 A second seeker
TH04_TITLE | event title | Dask asks for a copy
TH04_BODY | event text | Aurel Dask of the Quill Lender House asks to copy Lask's page. He sets his pen across Oake's notes. He says his people can find the heir sooner. Give him a copy and food pays less. Refuse and energy costs more. His pen stays there.
TH04_A_BTN | button | Give Dask a copy
TH04_A_EFF | effect line | For a while, food at Voltara costs less and pays less.
TH04_A_TITLE | popup title | Dask takes the copied names
TH04_A | popup | Food at Voltara costs less and pays less for a while. Dask's agents sell stores to fund the search. Oake watches him blot the copied names with his cuff. He thanks her. Her hand remains on the page he leaves.
TH04_B_BTN | button | Refuse Dask a copy
TH04_B_EFF | effect line | For a while, energy at Voltara costs more and pays more.
TH04_B_TITLE | popup title | Dask keeps his ship above you
TH04_B | popup | Energy at Voltara costs more and pays more for a while. Dask holds his house's stock back. Oake watches his ship's lamps through the dock glass. She folds the page beneath her hand. The lamps are still there after shift change.

## TH05 A hull with a scraped name
TH05_TITLE | event title | The name scraped from a hull
TH05_BODY | event text | Oake finds the loan's hull number beneath a tarp in Voltara's sealed yard. Bare metal shows where its name was. Unseal the yard and energy costs more as cranes move. Keep it sealed and food pays less. Oake presses the page against the fence.
TH05_A_BTN | button | Unseal the old yard
TH05_A_EFF | effect line | For a while, energy at Voltara costs more and pays more.
TH05_A_TITLE | popup title | A cup beside the bunk
TH05_A | popup | Energy at Voltara costs more and pays more for a while. Cranes and lamps serve the reopened yard. Oake finds a cup beneath the hull's bunk. She holds it by the handle. Nobody has a name to put beside it yet.
TH05_B_BTN | button | Leave the yard sealed
TH05_B_EFF | effect line | For a while, food at Voltara costs less and pays less.
TH05_B_TITLE | popup title | Oake stays by the fence
TH05_B | popup | Food at Voltara costs less and pays less for a while. Crews leave the sealed yard without eating at the stalls. Oake keeps the hull page pressed to the fence. The scraped patch of metal shows beyond it. She cannot reach the tarp.

## TH06 The Bureau answers
TH06_TITLE | event title | The Bureau asks you to sign
TH06_BODY | event text | The Bureau says the Commons settled Lask's debt. It asks you to confirm Oake has stopped her search. She holds the letter by its stiff fold. Sign and relief stores make food pay less. Say she continues and Voltara closes for checks.
TH06_A_BTN | button | Confirm she stopped
TH06_A_EFF | effect line | For a while, food at Voltara costs less and pays less.
TH06_A_TITLE | popup title | Your name beneath the answer
TH06_A | popup | Food at Voltara costs less and pays less for a while. The Bureau sends relief stores after your signed reply. Oake reads your name beneath the claim that she has stopped. She folds the reply into Lask's page. Both fit inside her coat.
TH06_B_BTN | button | Confirm she continues
TH06_B_EFF | effect line | Voltara closes for a while. All routes touching Voltara are blocked.
TH06_B_TITLE | popup title | Inspectors take the dock book
TH06_B | popup | Voltara's port is closed for a while. Routes touching Voltara are blocked after you confirm Oake still searches. The Bureau inspectors thank you for the dock book. Oake watches a clerk tie it with tape. Your next load waits outside.

## TH07 Slow Receipt is held
TH07_TITLE | event title | A coat on a dock crate
TH07_BODY | event text | The Bureau holds Slow Receipt for an unfiled form. Oake sleeps on a crate with her shoes still on. Give her your bunk and food costs more. Find her a room ashore and energy pays less. Your crew leaves soup beside the borrowed coat.
TH07_A_BTN | button | Give Oake your bunk
TH07_A_EFF | effect line | For a while, food at Voltara costs more and pays more.
TH07_A_TITLE | popup title | Oake sets down her shoes
TH07_A | popup | Food at Voltara costs more and pays more for a while. Oake joins your canteen and takes your bunk. She sets her shoes beneath it with their toes aligned. Your blanket hangs over the chair where you will sleep.
TH07_B_BTN | button | Find Oake a room
TH07_B_EFF | effect line | For a while, energy at Voltara costs less and pays less.
TH07_B_TITLE | popup title | A key away from the tug
TH07_B | popup | Energy at Voltara costs less and pays less for a while. Oake's room has a cold heater. She wraps its key in the borrowed coat's pocket. Each morning she walks back to Slow Receipt. The Bureau still holds it at the dock.

## TH08 A letter from a far station
TH08_TITLE | event title | Ines asks for a voice
TH08_BODY | event text | Ines Lask sends a letter from a far station. Her pen has caught in the same word twice. She asks for no credits. Read her father's debt at the dock and food costs more. Read it by relay and energy costs more. She wants people there.
TH08_A_BTN | button | Read at the dock
TH08_A_EFF | effect line | For a while, food at Voltara costs more and pays more.
TH08_A_TITLE | popup title | Bread passes through the hall
TH08_A | popup | Food at Voltara costs more and pays more for a while. Crews gather for Ines's letter and bring bread to share. Oake moves a cup to make room on the table. None of these crews knew her father. They wait to hear his name.
TH08_B_BTN | button | Read by relay
TH08_B_EFF | effect line | For a while, energy at Voltara costs more and pays more.
TH08_B_TITLE | popup title | A room at the far end
TH08_B | popup | Energy at Voltara costs more and pays more for a while. The relay stays on to reach Ines's station. Oake bends toward the speaker when a chair scrapes at the far end. Someone has sat down to listen.

## TH09 The reading
TH09_TITLE | event title | The name waits on the page
TH09_BODY | event text | Oake holds the loan page toward you. Her thumb covers the crease beside Lask's name. Read it yourself and energy pays less as lamps dim. Ask Oake to read and food pays less as stalls shut. The listening crews wait for a voice.
TH09_A_BTN | button | Read the loan page
TH09_A_EFF | effect line | For a while, energy at Voltara costs less and pays less.
TH09_A_TITLE | popup title | Your mouth forms his name
TH09_A | popup | Energy at Voltara costs less and pays less for a while. Lamps dim for the reading. Your mouth dries at Teodor Lask's name. Oake keeps the page steady while you finish the sum. The crews stay seated after your last word.
TH09_B_BTN | button | Ask Oake to read
TH09_B_EFF | effect line | For a while, food at Voltara costs less and pays less.
TH09_B_TITLE | popup title | Oake stops at Lask
TH09_B | popup | Food at Voltara costs less and pays less for a while. The stalls shut as Oake reads. Her finger stops beneath Lask's name. She takes a breath before saying the sum. The crews wait through the pause.

## TH10 What is owed
TH10_TITLE | event title | A place to put the debt
TH10_BODY | event text | Oake lays Lask's page beside your accounts. Pay Ines and those credits leave your company. Enter the debt as shared and nobody is paid. Food costs more while clerks count the stores. Ines has asked for neither. Oake sets her pen between the books.
TH10_A_BTN | button | Pay Ines the debt
TH10_A_EFF | effect line | Pay {cash_out} credits to Ines Lask. No other effects.
TH10_A_TITLE | popup title | A line through Lask's name
TH10_A | popup | You pay {cash_out} credits to Ines Lask. A clerk draws a line through her father's name. Oake folds the page into your dock book. Those credits cannot fund your next load. Slow Receipt leaves with its running lamp above the hatch.
TH10_B_BTN | button | Record the shared debt
TH10_B_EFF | effect line | Pay nothing. For a while, food at Voltara costs more and pays more.
TH10_B_TITLE | popup title | The page goes into a drawer
TH10_B | popup | You pay nothing. Food at Voltara costs more and pays more for a while as clerks count the stores. The Bureau records Lask's debt as shared and settled. Oake watches the clerk lower it into a drawer. Ines receives no credits.

# Events, expansion (2026-11-11): posts, platforms, lanes, Military, Luxury, Minerals, Biotech

Pool events added on 2026-11-11. Every one is a pool row (data/chains.json pool_new) with a gate and one effect per option; the plan file handoffs/story-designer/2026-11-11-event-expansion.json names effect, world, good and gate for each. All rows are 3-field text rows (the build writes no events.json row). Each fires once per run. Plain event: EV<nn>_TITLE (32), EV<nn>_BODY (280). Choice event: those two, then per option key K: _K_BTN (28), _K_EFF (90), _K_TITLE (32), _K (popup, 280). Effect lines say only what the one option does, in words ("a small sum", "for a while"). No digits, no names of hidden goods: a text names a good only when its gate makes that good visible.
The posts and platforms events (EV_PST01 to EV_PST06, EV_PLT01 to EV_PLT04) and the lane events (EV_FLT01 to EV_FLT04) are the old pending texts, rewritten to effects the game has today and wired as ordinary pool events; they no longer need a "post built" or "in flight" trigger.

## Shared pool: posts and lanes (any CEO)

EV_PST01_TITLE | pool event title | Your name beside theirs
EV_PST01_BODY | pool event text | Sign, and energy at Flintmoor costs more and pays more. Leave, and the dock refunds a small sum. Clerk Nera Venn holds the book flat. The last crew pressed a thumb into the wet ink. Your crew waits for the pen.
EV_PST01_SIGN_BTN | button | Sign the book
EV_PST01_SIGN_EFF | effect line | Energy at Flintmoor costs more and pays more for a while.
EV_PST01_SIGN_TITLE | popup title | Nera dries the page
EV_PST01_SIGN | popup | Energy at Flintmoor costs more and pays more for a while. Nera blots your name. Your crew leans in to see it beside the others. The refund slip goes back in her drawer.
EV_PST01_LEAVE_BTN | button | Leave without signing
EV_PST01_LEAVE_EFF | effect line | You gain a small sum, the dock's refund for a name not written.
EV_PST01_LEAVE_TITLE | popup title | A refund without a name
EV_PST01_LEAVE | popup | You gain a small sum as the dock's refund. Nera sets the pen across the blank line. Your crew files past her desk. Nobody asks to see the book again.

EV_PST02_TITLE | pool event title | Ilsa has not reached your page
EV_PST02_BODY | pool event text | A gift costs a small sum and brings Brannock's stamp today. Waiting makes energy cost less and pay less there. Warden Ilsa Dorne smooths a bent page. Your crew sits on the crates they came to unload.
EV_PST02_GIFT_BTN | button | Send a gift
EV_PST02_GIFT_EFF | effect line | Pay a small sum. The stamp comes today.
EV_PST02_GIFT_TITLE | popup title | The crates can move
EV_PST02_GIFT | popup | You paid a small sum. Brannock's stamp arrives today. Ilsa sets the gift beneath her desk before calling your crew. A loader stands with the crate's edge still pressed into his palm.
EV_PST02_WAIT_BTN | button | Wait for the stamp
EV_PST02_WAIT_EFF | effect line | Energy at Brannock costs less and pays less for a while.
EV_PST02_WAIT_TITLE | popup title | Ilsa turns another page
EV_PST02_WAIT | popup | Energy at Brannock costs less and pays less for a while. Buyers have moved on while you waited. Ilsa checks the next page. Your loader rubs the crate mark from his palm.

EV_PST03_TITLE | pool event title | Mara holds the beam
EV_PST03_BODY | pool event text | Buy a part for a small sum, or pay more per trip at Cindrel for a few cycles. Foreman Mara Voss holds the survey beam steady with her knee. She can keep it there until the shift changes. Then someone must take her place.
EV_PST03_PART_BTN | button | Buy the part
EV_PST03_PART_EFF | effect line | Pay a small sum. The beam is fixed today.
EV_PST03_PART_TITLE | popup title | Mara can step away
EV_PST03_PART | popup | You paid a small sum. The beam is fixed today. Mara takes her knee off the frame and waits. The line holds. She sits beside the hauler while your crew starts unloading.
EV_PST03_SHIFT_BTN | button | Wait for another shift
EV_PST03_SHIFT_EFF | effect line | Lanes that touch Cindrel cost more per trip for a few cycles.
EV_PST03_SHIFT_TITLE | popup title | Another knee at the frame
EV_PST03_SHIFT | popup | Lanes that touch Cindrel cost more per trip for a few cycles. Haulers wait for the beam. Mara shows the next worker where to brace it. She leaves her cup within his reach.

EV_PST04_TITLE | pool event title | What Odo has left
EV_PST04_BODY | pool event text | The lease makes energy at Mossfell cost more and pay more. The cells go into Company storage instead. Odo Pell holds out a seal with its strap worn through. His old post has closed. He asks which part you can use.
EV_PST04_LEASE_BTN | button | Take the lease
EV_PST04_LEASE_EFF | effect line | Energy at Mossfell costs more and pays more for a while.
EV_PST04_LEASE_TITLE | popup title | Odo lets go of the seal
EV_PST04_LEASE | popup | Energy at Mossfell costs more and pays more for a while. Odo puts the seal in your hand. He wheels the cells back inside. Your clerk threads a new strap through the seal before using it.
EV_PST04_CELLS_BTN | button | Take the spare cells
EV_PST04_CELLS_EFF | effect line | Some energy is added to your Company storage at Mossfell.
EV_PST04_CELLS_TITLE | popup title | Odo brings the cart
EV_PST04_CELLS | popup | Some energy is added to your Company storage at Mossfell. Odo unloads the cells himself. The lease stays under his arm. He asks your loader to keep the empty cart by the door.

EV_PST05_TITLE | pool event title | A place beside Rell
EV_PST05_BODY | pool event text | Share the dock, and energy at Quillon costs more and pays more. Take another berth for a small sum. Broker Rell Sorn moves his cup to make room. His stool has worn a hollow in the floor. Your crates fill the space behind him.
EV_PST05_SHARE_BTN | button | Share the dock
EV_PST05_SHARE_EFF | effect line | Energy at Quillon costs more and pays more for a while.
EV_PST05_SHARE_TITLE | popup title | Rell shifts his stool
EV_PST05_SHARE | popup | Energy at Quillon costs more and pays more for a while. Rell shifts his stool for your clerk. Their elbows meet over the orders. Your crew has buyers here, and a desk they must share.
EV_PST05_MOVE_BTN | button | Take the other berth
EV_PST05_MOVE_EFF | effect line | You gain a small sum.
EV_PST05_MOVE_TITLE | popup title | The walk to your desk
EV_PST05_MOVE | popup | You gain a small sum for taking the other berth. Rell watches your crew carry the crates farther down. Your clerk sets a cup on the new desk. The first buyers stop at Rell's.

EV_PST06_TITLE | pool event title | Sena waits at the rail
EV_PST06_BODY | pool event text | A dock visit makes energy at Tillam cost more and pay more. Keep working for energy in Company storage instead. Sena Pell waits at the rail with her child. The child holds a bolt from your first ship. Your loader has seen them.
EV_PST06_OPEN_BTN | button | Hold a dock visit
EV_PST06_OPEN_EFF | effect line | Energy at Tillam costs more and pays more for a while.
EV_PST06_OPEN_TITLE | popup title | Sena comes aboard
EV_PST06_OPEN | popup | Energy at Tillam costs more and pays more for a while. Your loader leaves the spare cells to show Sena around. Her child fits the bolt against an empty hole. The loader crouches beside them.
EV_PST06_WORK_BTN | button | Keep to the work
EV_PST06_WORK_EFF | effect line | Some energy is added to your Company storage at Tillam.
EV_PST06_WORK_TITLE | popup title | The bolt goes home
EV_PST06_WORK | popup | Some energy is added to your Company storage at Tillam. Your loader keeps stacking cells. Sena takes her child's hand at the rail. The bolt leaves a round dent in the child's palm.

EV_FLT01_TITLE | pool event title | The name beneath the paint
EV_FLT01_BODY | pool event text | Sell the wreck for a small sum, or take its cells for Company storage at Voltara. Pilot Tavi Renn finds an empty hull across the lane. Nobody is aboard. Beneath the scraped name, a patch of blue paint matches her old berth.
EV_FLT01_TOW_BTN | button | Sell it as scrap
EV_FLT01_TOW_EFF | effect line | You gain a small sum for the salvage.
EV_FLT01_TOW_TITLE | popup title | Tavi watches the tow
EV_FLT01_TOW | popup | You gain a small sum for the salvage. The scrap crew takes the hull with its cells still fitted. Tavi keeps the rear glass on until the blue patch is gone. Then she returns to the route board.
EV_FLT01_STRIP_BTN | button | Strip its cells
EV_FLT01_STRIP_EFF | effect line | Some energy is added to your Company storage at Voltara.
EV_FLT01_STRIP_TITLE | popup title | The cells reach home
EV_FLT01_STRIP | popup | Some energy is added to your Company storage at Voltara. Tavi helps lift the cells from the wreck. The hull rolls away without them. She wipes blue paint from her glove before signing the stock sheet.

EV_FLT02_TITLE | pool event title | Eda keeps the band
EV_FLT02_BODY | pool event text | Pay a small sum to check the call here. Otherwise, Brannock trips cost more for a few cycles. Eda Venn asks for help on an old band. Then she starts reading a recipe. Tavi holds a finger above the radio switch.
EV_FLT02_RELAY_BTN | button | Pay the relay fee
EV_FLT02_RELAY_EFF | effect line | Pay a small sum. The band is checked from here.
EV_FLT02_RELAY_TITLE | popup title | Someone answers Eda
EV_FLT02_RELAY | popup | You paid a small sum. The relay checked the band from here. Eda was waiting at an old cook station, reading to keep the call alive. Tavi lowers her finger when another voice says Eda's name.
EV_FLT02_HOLD_BTN | button | Hold the course
EV_FLT02_HOLD_EFF | effect line | Lanes that touch Brannock cost more per trip for a few cycles.
EV_FLT02_HOLD_TITLE | popup title | Ships turn toward the call
EV_FLT02_HOLD | popup | Lanes that touch Brannock cost more per trip for a few cycles. Other ships turned to check Eda's call. Tavi holds your course. Eda starts the recipe again before the replies fill the band.

## Military pool

EV41_TITLE | pool event title | Bren counts the spent rounds
EV41_BODY | pool event text | Munitions at Cindrel cost more and pay more. The drill order kept running after the crews went home. Bren Sorn sets a spent case beside the order. His next shift starts soon. He asks where the new rounds will come from.

EV42_TITLE | pool event title | Weapons before the march
EV42_BODY | pool event text | Weapons at Quillon cost more and pay more. Clerk Dena Marr signs for the parade crates before a route is set. Her sleeve catches on a nail. She frees it, signs the next receipt, and asks if the crews may go home yet.

EV81_TITLE | pool event title | A light at Flintmoor
EV81_BODY | pool event text | Flintmoor needs more energy and pays more for a few cycles. A rush order may follow. At the powder works, Mara Voss cups a hand around a dim lamp. The next crew waits beside her. Nobody takes off a coat.

EV82_TITLE | pool event title | Noll waits below the office
EV82_BODY | pool event text | Pay a small sum to clear the ship today. Otherwise, Tillam trips cost more for a few cycles. Mate Noll Renn waits below the stamp office. He has folded his supper into a scrap of cloth. Ships gather behind his hull.
EV82_PAY_BTN | button | Pay for the stamp
EV82_PAY_EFF | effect line | Pay a small sum. The ship moves today.
EV82_PAY_TITLE | popup title | Noll climbs aboard
EV82_PAY | popup | You paid a small sum. The ship moves today. Noll takes the stamp to the dock without unfolding his supper. The clerk lays your payment slip beside the forms still waiting.
EV82_WAIT_BTN | button | Wait its turn
EV82_WAIT_EFF | effect line | Lanes that touch Tillam cost more per trip for a few cycles.
EV82_WAIT_TITLE | popup title | Supper below the stairs
EV82_WAIT | popup | Lanes that touch Tillam cost more per trip for a few cycles. Noll sits below the office stairs and unfolds his supper. When the clerk calls a name, he puts it down. The name belongs to another crew.

EV83_TITLE | pool event title | Where Iven keeps watch
EV83_BODY | pool event text | A patrol raises blast powder prices at Voltara or energy prices at Flintmoor. Both cost more and pay more. Captain Iven Rusk waits for your answer. His lamp has a cracked shade. Dock crews at both ends have asked him to stay.
EV83_VOLT_BTN | button | Watch Voltara
EV83_VOLT_EFF | effect line | Blast powder at Voltara costs more and pays more for a while.
EV83_VOLT_TITLE | popup title | Iven lights Voltara's dock
EV83_VOLT | popup | Blast powder at Voltara costs more and pays more for a while. Iven sets his lamp above the dock. Traders stay to unload. Flintmoor's foreman reads the patrol notice again, then folds it into his coat.
EV83_FLINT_BTN | button | Watch Flintmoor
EV83_FLINT_EFF | effect line | Energy at Flintmoor costs more and pays more for a while.
EV83_FLINT_TITLE | popup title | Iven lights Flintmoor's yard
EV83_FLINT | popup | Energy at Flintmoor costs more and pays more for a while. Iven's lamp hangs over the yard. Traders start unloading. At Voltara, a loader takes down the chair left for the patrol and uses it himself.

EV84_TITLE | pool event title | The fare they still owe
EV84_BODY | pool event text | Take a small sum, or blast powder for Company storage at Flintmoor. Bren Sorn's crew has come to repay the trip home you gave them. Bren holds a bag with a patched seam. Behind him, his crew has brought the powder cart.
EV84_CASH_BTN | button | Take the credits
EV84_CASH_EFF | effect line | You gain a small sum.
EV84_CASH_TITLE | popup title | Bren sets down the bag
EV84_CASH | popup | You gain a small sum. Bren leaves the patched bag on your desk. His crew takes the powder cart away. Before he goes, he asks whether the loader who brought them home still works here.
EV84_GOODS_BTN | button | Take the powder
EV84_GOODS_EFF | effect line | Some blast powder is added to your Company storage at Flintmoor.
EV84_GOODS_TITLE | popup title | Bren brings the cart in
EV84_GOODS | popup | Some blast powder is added to your Company storage at Flintmoor. Bren's crew unloads the cart. He puts the credits back inside his coat. Your loader comes down to help, and Bren leaves room beside him.

EV85_TITLE | pool event title | All the holds reach Voltara
EV85_BODY | pool event text | Blast powder at Voltara costs less and pays less. The delayed convoy has arrived with every hold full. Dena Marr rubs a thumb over her old sale price. Your crew has powder waiting too. The buyers walk past it toward the new crates.

EV_FLT03_TITLE | pool event title | Iven asks for a toll
EV_FLT03_BODY | pool event text | Pay a small toll, or pay more per trip at Quillon for a few cycles. Captain Iven Rusk calls from his cutter. He holds the toll sheet against a cracked lamp shade. Your pilot knows his voice. The rest of your fleet uses this lane.
EV_FLT03_PAY_BTN | button | Pay the toll
EV_FLT03_PAY_EFF | effect line | Pay a small sum. The lane stays as it is.
EV_FLT03_PAY_TITLE | popup title | Iven records the payment
EV_FLT03_PAY | popup | You paid a small sum. The lane stays as it is. Iven sends a receipt and moves his cutter aside. Your pilot places the receipt beneath the route board, where the crew can see what passage cost.
EV_FLT03_AROUND_BTN | button | Fly around the cutter
EV_FLT03_AROUND_EFF | effect line | Lanes that touch Quillon cost more per trip for a few cycles.
EV_FLT03_AROUND_TITLE | popup title | Quillon by another route
EV_FLT03_AROUND | popup | Lanes that touch Quillon cost more per trip for a few cycles. Your ships go around the cutter. Tavi redraws the lane with a finger. Iven's lamp stays at the edge of the glass until she turns away.

EV91_TITLE | pool event title | Bren closes the dock gate
EV91_BODY | pool event text | Cindrel closes for a while. Routes touching it are blocked. Range officer Bren Sorn calls a drill and lowers the dock gate. Your loader has a coat on the far side. Bren hangs it over the rail before checking the latch.

EV92_TITLE | pool event title | The rivets cannot go both ways
EV92_BODY | pool event text | Choose where rivets cost more and pay more: Quillon or Cindrel. Dena Marr needs them for dock repairs. Bren Sorn needs them for gun racks. Dena sends a bent rivet with her order. Bren asks you to read his before choosing.
EV92_QUILLON_BTN | button | Answer Quillon
EV92_QUILLON_EFF | effect line | Rivets at Quillon cost more and pay more for a while.
EV92_QUILLON_TITLE | popup title | Dena clears a shelf
EV92_QUILLON | popup | Rivets at Quillon cost more and pay more for a while. Dena clears a shelf beside the repair tools. Bren asks when his turn will come. Your clerk holds his note while the convoy leaves.
EV92_CINDREL_BTN | button | Answer Cindrel
EV92_CINDREL_EFF | effect line | Rivets at Cindrel cost more and pay more for a while.
EV92_CINDREL_TITLE | popup title | Bren clears the racks
EV92_CINDREL | popup | Rivets at Cindrel cost more and pay more for a while. Bren clears the gun racks for the crew. Dena sends no further note. Her bent rivet stays beside the order on your desk.

EV93_TITLE | pool event title | What the Fleet Office owes
EV93_BODY | pool event text | Take a small sum, or rivets for Company storage at Quillon. Fleet clerk Nera Venn has brought the old account to settle. She holds the receipt flat with a chipped cup. Your crew can use the credits. The rivets are already on the dock.
EV93_CASH_BTN | button | Take the credits
EV93_CASH_EFF | effect line | You gain a small sum.
EV93_CASH_TITLE | popup title | Nera closes the cash page
EV93_CASH | popup | You gain a small sum. Nera marks the cash page and sends the rivets back to the depot. A ring from her cup crosses the old balance. Your clerk waits for it to dry before filing the receipt.
EV93_GOODS_BTN | button | Take the rivets
EV93_GOODS_EFF | effect line | Some rivets are added to your Company storage at Quillon.
EV93_GOODS_TITLE | popup title | Nera signs for the crates
EV93_GOODS | popup | Some rivets are added to your Company storage at Quillon. Nera closes the cash page without a payment. Your crew takes the crates from the dock. She keeps her cup on the receipt until the last crate is counted.

## Luxury pool

EV44_TITLE | pool event title | Dema's last gem
EV44_BODY | pool event text | Gems at Brannock cost more and pay more. Cutter Dema Voss found a flaw that caught the light. The case sold out. Now she holds the last gem against her sleeve. Buyers wait for another like it. She keeps turning it in her hand.

EV45_TITLE | pool event title | The attar nobody signed for
EV45_BODY | pool event text | Attar at Quillon costs less and pays less. The convoy brought more than the guild would take. Rell Sorn wipes a ring of oil from a crate lid. Your crew's stock stands beside his. He asks your price before naming his own.

EV76_TITLE | pool event title | Odo keeps the lunch receipt
EV76_BODY | pool event text | Hothouse blooms at Voltara cost more and pay more. Odo Pell left lunch with the buyer's next order. He slides a stained napkin across your desk. Your crew can earn more from the blooms. The buyer's growers will pay more to replace them.

EV77_TITLE | pool event title | Rell remembers teaching you
EV77_BODY | pool event text | Pay a small sum, or let hothouse blooms at Ashgate cost less and pay less for a while. Rell Sorn asks thanks for teaching you the trade. He sets your first receipt on the table. His friends have crates of blooms at the dock.
EV77_THANK_BTN | button | Pay the broker
EV77_THANK_EFF | effect line | Pay a small sum.
EV77_THANK_TITLE | popup title | Rell folds the receipt
EV77_THANK | popup | You paid a small sum. Rell folds your first receipt and puts it away. His friends leave their crates stacked. Your clerk enters the payment beside the next ship's upkeep and reads the balance again.
EV77_SKIP_BTN | button | Decline the payment
EV77_SKIP_EFF | effect line | Hothouse blooms at Ashgate cost less and pay less for a while.
EV77_SKIP_TITLE | popup title | Rell's friends unpack
EV77_SKIP | popup | Hothouse blooms at Ashgate cost less and pay less for a while. Rell's friends unpack at the dock. Your crew lowers its own sale board. Rell leaves your first receipt on the table for you to keep.

EV78_TITLE | pool event title | A name beside each order
EV78_BODY | pool event text | Raise musk prices at Tillam or hothouse bloom prices at Ashgate. Both cost more and pay more. Buyer Eda Venn has asked for musk. Sena Pell needs blooms. You can tip off a buyer. Your clerk has worn a hole through Sena's old order.
EV78_TILLAM_BTN | button | Tell the Tillam buyer
EV78_TILLAM_EFF | effect line | Musk at Tillam costs more and pays more for a while.
EV78_TILLAM_TITLE | popup title | Eda reads your message
EV78_TILLAM | popup | Musk at Tillam costs more and pays more for a while. Eda presses your message flat and calls her buyers. Your clerk puts Sena's order back beneath it. The hole in the page shows through.
EV78_ASHGATE_BTN | button | Tell the Ashgate buyer
EV78_ASHGATE_EFF | effect line | Hothouse blooms at Ashgate cost more and pay more for a while.
EV78_ASHGATE_TITLE | popup title | Sena calls her buyers
EV78_ASHGATE | popup | Hothouse blooms at Ashgate cost more and pay more for a while. Sena calls her buyers with your message in hand. Eda asks whether you saw her musk order. Your clerk puts down the pen before answering.

EV79_TITLE | pool event title | Sena sends something back
EV79_BODY | pool event text | Take a small sum, or hothouse blooms for Company storage at Ashgate. Sena Pell sends thanks for the deal you let her keep. Her note is tied to a crate with a piece of her work sash. She can send credits instead. She asks you to choose.
EV79_CASH_BTN | button | Take the credits
EV79_CASH_EFF | effect line | You gain a small sum.
EV79_CASH_TITLE | popup title | Sena sends the payment
EV79_CASH | popup | You gain a small sum. Sena sends credits and takes the blooms back to her stall. Her note stays on your desk. Your clerk unties the strip of sash and folds it beside the receipt.
EV79_GOODS_BTN | button | Take the blooms
EV79_GOODS_EFF | effect line | Some hothouse blooms are added to your Company storage at Ashgate.
EV79_GOODS_TITLE | popup title | Sena's crate comes in
EV79_GOODS | popup | Some hothouse blooms are added to your Company storage at Ashgate. Sena sends no credits. Your loader carries the crate inside with the strip of sash still tied to it. He leaves her note on top.

EV80_TITLE | pool event title | Odo waits behind his blooms
EV80_BODY | pool event text | Hothouse blooms at Mossfell cost less and pay less. Buyers know Odo Pell will lower his price if they wait. He holds his smile while they pass. A petal sticks to his cuff. Your crew turns its sale board toward the same buyers.

EV94_TITLE | pool event title | The sleeves Dema lent you
EV94_BODY | pool event text | Pay a small sum, or silk at Brannock costs less and pays less for a while. Dema Voss bills your crew for borrowed gala sleeves. A pin is still caught in the bill. She will take the story to the looms if the credits do not come.
EV94_PAY_BTN | button | Pay the bill
EV94_PAY_EFF | effect line | Pay a small sum.
EV94_PAY_TITLE | popup title | Dema returns the sleeves
EV94_PAY | popup | You paid a small sum. Dema sends the sleeves back with a receipt. Your loader hangs them above his work coat. He takes the pin from the bill and fixes the receipt to the cloth.
EV94_TELL_BTN | button | Let the house talk
EV94_TELL_EFF | effect line | Silk at Brannock costs less and pays less for a while.
EV94_TELL_TITLE | popup title | The bill reaches the looms
EV94_TELL | popup | Silk at Brannock costs less and pays less for a while. Dema takes the sleeve story to the looms. Weavers lower their offers to the crews she names. Your loader removes the pin from the bill and leaves the bill in view.

EV95_TITLE | pool event title | The cloth in Dema's hands
EV95_BODY | pool event text | Musk at Brannock costs more and pays more. The dyers need it to fix a batch after the vats ran dry. Dema Voss spreads the cloth over her knees. A pale band runs through it. She keeps her hands on either side while the buyers count.

EV96_TITLE | pool event title | Room beneath the lamp
EV96_BODY | pool event text | Raise attar prices or gem prices at Voltara. Both cost more and pay more. Rell Sorn wants attar under the display lamp. Dema Voss has brought gems. Her empty case leaves a square in the dust. Only a single display fits.
EV96_ATTAR_BTN | button | Set out the attar
EV96_ATTAR_EFF | effect line | Attar at Voltara costs more and pays more for a while.
EV96_ATTAR_TITLE | popup title | Rell takes the display
EV96_ATTAR | popup | Attar at Voltara costs more and pays more for a while. Rell sets his bottles beneath the lamp. Dema closes her gem case. She holds it on her knees while the buyers lean over his stock.
EV96_GEMS_BTN | button | Set out the gems
EV96_GEMS_EFF | effect line | Gems at Voltara cost more and pay more for a while.
EV96_GEMS_TITLE | popup title | Dema takes the display
EV96_GEMS | popup | Gems at Voltara cost more and pay more for a while. Dema puts her case beneath the lamp. Rell wraps his attar bottles again. He keeps the sales cloth folded across his arm while her buyers gather.

## Minerals pool

EV48_TITLE | pool event title | Mara draws another room
EV48_BODY | pool event text | Plate at Quillon costs more and pays more. Builders have claimed every sheet for a hall still drawn on the wall. Mara Voss adds a room for the dock crew. Chalk catches in a crack. She works around it while your clerk reads the new price.

EV70_TITLE | pool event title | Noll writes from Cinderrest
EV70_BODY | pool event text | Dross at Cinderrest costs more and pays more for a while. Noll Renn, who sold you your first spare parts, asks for stock before his shift. A thumbprint blurs his name. Your clerk checks what you can spare before reading the note aloud.

EV71_TITLE | pool event title | Nera finds an extra crate
EV71_BODY | pool event text | Take a small sum, or ore for Company storage at Voltara. Clerk Nera Venn finds spare parts beyond the count you signed. She rests her heel against the extra crate. The yard will pay for it either way. Your crew waits for you to choose.
EV71_CASH_BTN | button | Take the credits
EV71_CASH_EFF | effect line | You gain a small sum.
EV71_CASH_TITLE | popup title | The crate stays at the yard
EV71_CASH | popup | You gain a small sum. Nera marks the spare parts as paid. The ore stays in the yard. Your loader takes the receipt and runs a thumb along its crease before carrying it to the cash desk.
EV71_ORE_BTN | button | Take the ore
EV71_ORE_EFF | effect line | Some ore is added to your Company storage at Voltara.
EV71_ORE_TITLE | popup title | Ore in place of credits
EV71_ORE | popup | Some ore is added to your Company storage at Voltara. Nera closes the cash page without a payment. Your loader checks the sacks, then signs. The extra crate stays beside her heel until the count is done.

EV72_TITLE | pool event title | Nera checks the next bolt
EV72_BODY | pool event text | Pay a small sum to finish the check today. Otherwise, Ashgate trips cost more for a few cycles. Bureau clerk Nera Venn asks to see each part. She lays a white cloth beneath the bolts. Your crew's supper waits behind her chair.
EV72_PAY_BTN | button | Pay for the check
EV72_PAY_EFF | effect line | Pay a small sum. The check ends today.
EV72_PAY_TITLE | popup title | Nera folds the cloth
EV72_PAY | popup | You paid a small sum. The check ends today. Nera finishes the last row before folding her white cloth. Your crew carries the bolts aboard. The receipt goes on your desk beside the upkeep page.
EV72_WAIT_BTN | button | Wait for the check
EV72_WAIT_EFF | effect line | Lanes that touch Ashgate cost more per trip for a few cycles.
EV72_WAIT_TITLE | popup title | Supper beside the bolts
EV72_WAIT | popup | Lanes that touch Ashgate cost more per trip for a few cycles. Nera keeps checking the bolts. Your crew eats beside her chair. She moves the white cloth away from their plates and turns another page.

EV73_TITLE | pool event title | Mara can lend her crew
EV73_BODY | pool event text | Choose where ore costs more and pays more: Cindrel or Quillon. Mara Voss can lend her crew to a dock. Cindrel needs hands at the furnace. Quillon needs hands in the yard. She puts her patched gloves between the requests and waits.
EV73_CINDREL_BTN | button | Send them to Cindrel
EV73_CINDREL_EFF | effect line | Ore at Cindrel costs more and pays more for a while.
EV73_CINDREL_TITLE | popup title | Mara joins Cindrel's shift
EV73_CINDREL | popup | Ore at Cindrel costs more and pays more for a while. Mara takes her crew to the furnace. Quillon's yard master sends back the unused work list. She folds it inside her patched glove before starting.
EV73_QUILLON_BTN | button | Send them to Quillon
EV73_QUILLON_EFF | effect line | Ore at Quillon costs more and pays more for a while.
EV73_QUILLON_TITLE | popup title | Mara joins Quillon's shift
EV73_QUILLON | popup | Ore at Quillon costs more and pays more for a while. Mara takes her crew to the yard. The furnace clerk at Cindrel asks who will come instead. She turns a patched glove in her hands before answering.

EV74_TITLE | pool event title | Noll reads the blank page
EV74_BODY | pool event text | Dross at Ashgate costs less and pays less for a while. A shipment came to the wrong dock. Noll Renn holds up its blank delivery page. Your crew has dross waiting to sell. He looks from their crates to the new price and puts the page down.

EV_FLT04_TITLE | pool event title | Tavi eases back the lever
EV_FLT04_BODY | pool event text | Slow down and pay more per trip at Flintmoor for a few cycles. Push through and pay a small repair sum. Dust taps against Tavi Renn's glass. She rests her hand on the speed lever. Your loaded ships are coming along the same lane.
EV_FLT04_SLOW_BTN | button | Slow down
EV_FLT04_SLOW_EFF | effect line | Lanes that touch Flintmoor cost more per trip for a few cycles.
EV_FLT04_SLOW_TITLE | popup title | Tavi keeps her hand there
EV_FLT04_SLOW | popup | Lanes that touch Flintmoor cost more per trip for a few cycles. Your ships slow with Tavi. Dust taps the glass until her shift ends. She leaves her hand on the lever while the next pilot sits down.
EV_FLT04_PUSH_BTN | button | Push through
EV_FLT04_PUSH_EFF | effect line | Pay a small sum for hull repairs.
EV_FLT04_PUSH_TITLE | popup title | Tavi reads the repair sheet
EV_FLT04_PUSH | popup | You paid a small sum for hull repairs. Your ships pushed through the dust. At the dock, Tavi lays her palm against a new dent. She takes the repair sheet inside and holds it while your clerk counts the credits.

EV_PLT01_TITLE | pool event title | Noll brings the night crew
EV_PLT01_BODY | pool event text | Hire the crew for dross in Company storage at Cinderrest, or send them home for a small refund. Noll Renn arrives from the Bureau's labour desk. His crew has brought a kettle with a mended handle. They ask where the night shift sleeps.
EV_PLT01_NIGHT_BTN | button | Hire the night crew
EV_PLT01_NIGHT_EFF | effect line | Some dross is added to your Company storage at Cinderrest.
EV_PLT01_NIGHT_TITLE | popup title | Noll hangs up the kettle
EV_PLT01_NIGHT | popup | Some dross is added to your Company storage at Cinderrest. Noll's crew signs on. He hangs their kettle beside the shift board. When the home flight leaves, a worker keeps a hand around its mended handle.
EV_PLT01_DAY_BTN | button | Send the crew home
EV_PLT01_DAY_EFF | effect line | You gain a small sum, the labour desk's refund.
EV_PLT01_DAY_TITLE | popup title | Noll takes the kettle back
EV_PLT01_DAY | popup | You gain a small sum as the labour desk's refund. Noll takes his crew home without adding dross to your storage. He carries the kettle aboard. Your foreman clears their names from the shift board before sitting down.

EV_PLT02_TITLE | pool event title | Mara hears the roof
EV_PLT02_BODY | pool event text | Pay a small sum for props, or close Cinderrest for a while and block routes touching it. Mara Voss has brought everyone out of the gallery. A low note comes through the floor. She leaves her gloves beside the entry while you decide.
EV_PLT02_PROP_BTN | button | Pay for props
EV_PLT02_PROP_EFF | effect line | Pay a small sum. Routes from Cinderrest keep running.
EV_PLT02_PROP_TITLE | popup title | Mara checks each prop
EV_PLT02_PROP | popup | You paid a small sum. Routes from Cinderrest keep running. Mara checks each new prop before calling the crew back. The note fades as she works. She picks up her gloves at the entry and follows the last worker in.
EV_PLT02_SEAL_BTN | button | Seal the gallery
EV_PLT02_SEAL_EFF | effect line | Cinderrest closes for a while. Routes touching it are blocked.
EV_PLT02_SEAL_TITLE | popup title | Mara stays outside
EV_PLT02_SEAL | popup | Cinderrest closes for a while. Routes touching it are blocked. Mara checks the last worker's name before sealing the gallery. The note still comes through the floor. She sits beside the crew with her gloves in her lap.

EV_PLT03_TITLE | pool event title | Noll's unmarked seam
EV_PLT03_BODY | pool event text | Log the find for a small sum, or keep nullglass for Company storage at Greywake. Noll Renn's drill has reached a seam missing from the surveys. A clear chip rests in his glove. He has left the Bureau's report blank until you answer.
EV_PLT03_LOG_BTN | button | Log the find
EV_PLT03_LOG_EFF | effect line | You gain a small sum as a finder's share.
EV_PLT03_LOG_TITLE | popup title | Noll fills in the report
EV_PLT03_LOG | popup | You gain a small sum as a finder's share. Noll sends the report to the Bureau and waits for the stamped copy. The chip goes into the sample box. Your storage gets no lot from the find.
EV_PLT03_HIDE_BTN | button | Keep the find unlogged
EV_PLT03_HIDE_EFF | effect line | Some nullglass is added to your Company storage at Greywake.
EV_PLT03_HIDE_TITLE | popup title | Noll puts the chip away
EV_PLT03_HIDE | popup | Some nullglass is added to your Company storage at Greywake. Noll leaves the report blank and helps load the carts. There is no finder's payment. He puts the clear chip in his glove before closing the drawer.

EV_PLT04_TITLE | pool event title | Eda has both orders
EV_PLT04_BODY | pool event text | Choose where nullglass costs more and pays more: Cindrel or Quillon. At Greywake, shift lead Eda Venn lays both buyers' orders on the bunk. A hum rises through its frame. Each buyer asks for the next lot. She leaves room for you to sit.
EV_PLT04_CINDREL_BTN | button | Send to Cindrel
EV_PLT04_CINDREL_EFF | effect line | Nullglass at Cindrel costs more and pays more for a while.
EV_PLT04_CINDREL_TITLE | popup title | Eda answers Cindrel
EV_PLT04_CINDREL | popup | Nullglass at Cindrel costs more and pays more for a while. Eda sends the lot there. Quillon's order stays beside her bunk. She folds it under the pillow. The hum comes through the frame when she lies down.
EV_PLT04_QUILLON_BTN | button | Send to Quillon
EV_PLT04_QUILLON_EFF | effect line | Nullglass at Quillon costs more and pays more for a while.
EV_PLT04_QUILLON_TITLE | popup title | Eda answers Quillon
EV_PLT04_QUILLON | popup | Nullglass at Quillon costs more and pays more for a while. Eda sends the lot there. Cindrel's order stays beside her bunk. She folds it under the pillow. The hum comes through the frame when she lies down.

## Biotech pool

EV51_TITLE | pool event title | Sena keeps the seeds covered
EV51_BODY | pool event text | Seed stock at Brannock costs more and pays more. Planting came early, and growers bought ahead of the frost. Sena Pell pulls a cloth over the last tray. Buyers ask her to lift it. She keeps a hand on the edge while your crew reads the price.

EV88_TITLE | pool event title | Eda and Sena both ask
EV88_BODY | pool event text | Choose where spores cost more and pay more: Tillam or Ashgate. Eda Venn asks you to speak for Tillam's dock. Sena Pell asks for Ashgate's. Your clerk holds their letters together. Sena's has been folded until the paper has split.
EV88_TILLAM_BTN | button | Speak for Tillam
EV88_TILLAM_EFF | effect line | Spores at Tillam cost more and pay more for a while.
EV88_TILLAM_TITLE | popup title | Eda has your word
EV88_TILLAM | popup | Spores at Tillam cost more and pay more for a while. Eda posts your word beside the order board. Sena asks your clerk to keep her letter. He places a sheet beneath the split so it can still be read.
EV88_ASHGATE_BTN | button | Speak for Ashgate
EV88_ASHGATE_EFF | effect line | Spores at Ashgate cost more and pay more for a while.
EV88_ASHGATE_TITLE | popup title | Sena has your word
EV88_ASHGATE | popup | Spores at Ashgate cost more and pay more for a while. Sena posts your word beside the order board. Eda sends back your last letter. She has flattened its folds before putting it in the cover.

## Minerals pool, one more (EV75)

EV75_TITLE | pool event title | Mara finds the yard stock
EV75_BODY | pool event text | Ore at Quillon costs less and pays less for a while. Mara Voss found stock behind a sealed yard gate. Builders no longer need your crew's ore. She brings back the key with rust across her palm. Your loader lowers the sale board without a word.

## Production charter events (T370, 2026-11-12; pool choice events, mechanics in data/chains.json by the gameplay agent, once per run)

EV97_TITLE | pool event title | Ilsa leaves the world blank
EV97_BODY | pool event text | Pay a small sum for a production charter, or let it lapse for a small payment. Warden Ilsa Dorne has brought the depot form. It lets a world buy and store more. She covers the blank world line with her hand while your clerk counts the credits.
EV97_SIGN_BTN | button | Sign the charter
EV97_SIGN_EFF | effect line | You gain a production charter and pay a small fee.
EV97_SIGN_TITLE | popup title | Ilsa passes you the form
EV97_SIGN | popup | You gain a production charter and pay a small sum. Open a world's card to choose where to use it. Ilsa waits while your clerk enters the cost. She leaves the world line blank for you.
EV97_LAPSE_BTN | button | Let the form lapse
EV97_LAPSE_EFF | effect line | You gain a small sum.
EV97_LAPSE_TITLE | popup title | Ilsa files the unused form
EV97_LAPSE | popup | You gain a small sum. You receive no production charter. Ilsa marks the unused form and waits for your clerk to sign the payment slip. She keeps her hand over the world line until she closes the folder.

EV98_TITLE | pool event title | Dema asks for a world's name
EV98_BODY | pool event text | Accept a production charter and lower a home Luxury good's buy and sell prices. Decline for a small sum. Patron Dema Voss wants her name on a world. Her ring has worn a dent in the form. She asks who will hear of it first.
EV98_ACCEPT_BTN | button | Accept the charter
EV98_ACCEPT_EFF | effect line | Gain a production charter. A home Luxury good costs less and pays less for a while.
EV98_ACCEPT_TITLE | popup title | Dema sends the notice
EV98_ACCEPT | popup | You gain a production charter. A Luxury good at your home world costs less and pays less for a while. Dema sends word of her gift to the other patrons. Your clerk holds the form where her ring dented it and checks your stock.
EV98_DECLINE_BTN | button | Decline the charter
EV98_DECLINE_EFF | effect line | You gain a small sum.
EV98_DECLINE_TITLE | popup title | Dema takes the form back
EV98_DECLINE | popup | You gain a small sum. You receive no production charter. Dema takes the form back and leaves the payment slip. Your clerk slides it toward you. The dent from her ring is pressed into the copy beneath.

## Bribery at the depot (EV_BRB01, all branches, 2026-11-14 owner request; written by Codex)

EV_BRB01_TITLE | choice title | A bribe at {planet}
EV_BRB01_BODY | choice body | The Bureau accuses depot worker Bram Hale of taking a bribe at {planet}. Pay the fine and keep him. Fire him, pay no fine, and trips from {planet} cost more for a while. Or quietly pay the accuser a smaller sum to drop the complaint.
EV_BRB01_FINE_BTN | button | Pay the fine
EV_BRB01_FINE_EFF | effect line | Pay {cash_out} credits. Bram Hale stays. The company record stays clean.
EV_BRB01_FINE_TITLE | popup title | The penalty is recorded
EV_BRB01_FINE | popup | The Bureau records the payment and closes the case. Bram Hale keeps his job. He removes a folded note from his desk and begins the next route sheet.
EV_BRB01_FIRE_BTN | button | Fire Bram Hale
EV_BRB01_FIRE_EFF | effect line | No fine. Trips from {planet} cost more for a while.
EV_BRB01_FIRE_TITLE | popup title | Bram leaves the depot
EV_BRB01_FIRE | popup | Bram Hale is dismissed. A new worker signs the contracts again, and trips from {planet} cost more for a while. Bram carries his mug out in both hands.
EV_BRB01_HUSH_BTN | button | Pay the accuser
EV_BRB01_HUSH_EFF | effect line | Pay {cash_out} credits to the accuser. Nothing goes on the record.
EV_BRB01_HUSH_TITLE | popup title | The complaint is withdrawn
EV_BRB01_HUSH | popup | The accuser takes the payment and withdraws the complaint. Bram Hale stays. He puts the clean Bureau form over the first payment note and locks both in the same drawer.
