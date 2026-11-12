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
Night-shift engineer Pavo Quill ran Voltara's reactors past the safe-hours rule. Nothing blew up, so the day shift read the rule as a typo. Energy at Voltara costs less and pays less. The cores hum a note nobody tuned, and nobody wants to ask who is listening.

EV02 | Grey blight on Tillam's terraces | [price up: Tillam, food] | P
Grey blight crept up Tillam's terraces overnight and rubs off like ash. The committee ruled it a rumour, since no form reports it, and asked the blight to file one. Food at Tillam costs more and pays more. A Seed Bank lets planet storage hold clearly more against the next one.

EV03 | Ashgate's harvest comes in heavy | [price down: Ashgate, food] | P
Ashgate's harvest came in heavy, and the Common Ledger counted only half. Food at Ashgate costs less and pays less. The other half sits on the dock, real and uncounted, while a boy sells it by the sack from a handcart. What is not on the form is still food, until it rots.

EV04 | Voltara's crews go hungry | [price up: Voltara, food] | P
A cheerful official told Voltara's crews that hunger is a slow phase of a smooth future, and handed out a booklet on chewing. Food at Voltara costs more and pays more. The cut was equal for all. The crews note that equal is not full, and read the booklet twice.

EV05 | Frost on Tillam | [price up: Tillam, energy] | P
Winter came early to Tillam and the heaters never stop. Energy at Tillam costs more and pays more. Frost grows inside the ducts in patterns no one will explain. Old duct-keeper Brindle leaves it a cup of warm oil each night. The cup is empty by morning.

EV06 | Ashgate lights every furnace | [price up: Ashgate, energy] | P
A plan reached Ashgate this morning, written in a hurry and stamped twice. Every foundry was relit to meet it. Energy at Ashgate costs more and pays more. An old brakeman asked what the rush was. Nobody answered, and the furnaces glared on all night.

EV07 | Tillam's docks go on strike | [planet closed: Tillam] | P
Tillam's dock crews walked out over a debt they say is owed. The Bureau asked where the debt lives, and the crews pointed at the main gate. The port is closed for a while, and routes touching Tillam are blocked. Hardy Strains reopens a closed planet a cycle sooner.

EV08 | Ashgate seals its port | [planet closed: Ashgate] | P
Something turned up in Ashgate's lower docks, and the doctors will only say the port is closed. Routes touching Ashgate are blocked until they say otherwise. The dock cat was seen leaving at speed. Nobody here is a witness. Everybody is a suspect.

EV09 | Voltara goes dark | [planet closed: Voltara] | I
A fault in Voltara's grid took the port with it. The planet that lights everyone cannot light its own docks. The port is closed for a while, and routes touching Voltara are blocked. The law says lights on. The emergency says off. A clerk decides, by candle.

EV10 | A lender walks Tillam's market | [price down: Tillam, energy] | Q
A lender's agent, a thin man named Shylo Vane, walked Tillam's market and bought every debt in sight. Sellers panicked, settled up and dumped their stock. Energy at Tillam costs less and pays less for now. A debt is real until someone stops believing in the paper.

EV11 | Ashgate's foreman says enough | [price down: Ashgate, energy] | Q
Ashgate foreman Dov Rennick read the numbers, said the shift had made enough, and sent his crew home. Energy at Ashgate costs less and pays less. Enough is a word the Plan does not print. By evening three more foremen had found it, and the furnaces cooled.

EV12 | Voltara buys before the news | [price up: Voltara, energy] | Q
A trader named Wex whispered on Voltara's docks that the far beacons had gone dark. They had not. Buyers bought energy hard anyway, and the lie came true by supper. Energy at Voltara costs more and pays more. Price Whisper shows next cycle's prices, rumour or not.

EV13 | A family buys Ashgate's food | [price up: Ashgate, food] | Q
A family with old credits quietly bought every food contract on Ashgate. Their agent, a polite man named Corvale, asked only that nobody ask why. Food at Ashgate costs more and pays more. The Commons has no form for that question yet. It is writing one.

EV14 | The inspector's count | [price down: Voltara, food] | I
Inspector Pell counted Voltara's food stores and found them sufficient, on a form. The market believed the form. Food at Voltara costs less and pays less. The pantries are still bare, now correctly accounted for. The form reads smoothly. That is most of the truth.

EV15 | Tillam's festival of founders | [price up: Tillam, food] | I
Tillam declared a festival of founders, and everyone wore a founder's mask. Food at Tillam costs more and pays more. Three committees claim to be the real founders. By midnight nobody can tell who is who, and nobody will take off a mask to clear the tables.

EV16 | A ship leaves Tillam half empty | [price down: Tillam, food] | Q
A ship left Tillam half empty, bound for a rock nobody has charted. Those who stayed sold spare food to pay for staying. Food at Tillam costs less and pays less. A letter came back, from a Tillam that chose otherwise. No one has answered it. It sits on the sill.

## Goods events (T154, 2026-11-02): silk, logic cores, ore
EV21_TITLE | pool event title | Brannock's weavers down tools
EV21_BODY | pool event text | Brannock's silk weavers downed tools over a form that counted their hours twice. Silk at Brannock costs more and pays more. An old weaver says to watch the cricket in the vat, which changes shape when it sees another. Nobody has gone near the vat since.

EV22_TITLE | pool event title | Quillon holds a gala
EV22_BODY | pool event text | Quillon's buyers hold a gala to celebrate a quota met on paper. Silk at Quillon costs more and pays more. Everyone borrows a sleeve and a mask, and by the second hour the guests look alike. Patron's List makes a price rise like this pay more.

EV24_TITLE | pool event title | Fire in Cindrel's reactor hall
EV24_BODY | pool event text | A fire swept Cindrel's reactor hall and left the control floor black. Spy software at Cindrel costs more and pays more. The report calls it a gentle step toward a better line. Ash settled on the walls in neat rows. Nobody has dared to read them.

EV25_TITLE | pool event title | Mossfell recalls its tractors
EV25_BODY | pool event text | Mossfell recalled its farm tractors to be retrained as safe. Spy software at Mossfell costs more and pays more. The retrained ones freeze when two foremen give opposite orders. The old ones were told to keep quiet and keep going, and they do. They do not look at you.

EV26 | A rich seam is logged twice | [price down: Voltara, ore] | Q
A survey crew found a rich seam and logged it in two offices, so it is counted twice and sold twice. Ore at Voltara costs less and pays less while the news is fresh. With Smelting, ore orders ignore the size cap, so a cheap week can be a big one.

EV28 | Voltara's foundry wants rock | [price up: Voltara, ore] | P
Voltara's foundry ordered more rock than the Plan had dreamed of. Ore at Voltara costs more and pays more. Every shortcut the founders took lies under the furnace floor, and the furnace wants more. Prospecting lets routes start at asteroid clusters, where the rock is free.

EV60 | Energy runs short at Voltara | [shortage: Voltara, energy] | Q
Voltara's night grid asked for more power than the day shift ever booked. Energy at Voltara is wanted harder for a few cycles and the hunger shows in the price. Whoever lands a load in time sells into it.

EV61 | Food runs short at Tillam | [shortage: Tillam, food] | Q
Tillam's pantries ran lean before the terraces could catch up. Food at Tillam is wanted harder for a few cycles and the hunger shows in the price. A full hold arrives as good news here.

EV62 | Food runs short at Ashgate | [shortage: Ashgate, food] | Q
Ashgate's ration clerks counted twice and found the shelves thinner than the form said. Food at Ashgate is wanted harder for a few cycles and the hunger shows in the price.

EV63 | Traffic jams at Tillam | [congestion: Tillam] | Q
A line of convoys waits outside Tillam's docks for a slot nobody can promise. Lanes that touch Tillam cost more per trip for a few cycles. Ride it out or send the ships elsewhere.

EV64 | Traffic jams at Voltara | [congestion: Voltara] | Q
Voltara's dock beacons flicker and every captain waits for the next one to go first. Lanes that touch Voltara cost more per trip for a few cycles. Ride it out or send the ships elsewhere.

# Events, choice events (draft 1, T96 T100 T103 T108, 2026-10-28)

Format: ID | place | tag, then text. Choice events use the choice screen limits: title max 40, body max 280, button max 28, effect line max 90. Outcome texts are event popups: title max 32, text max 280, shown under NOT_EVENT_PREFIX with BTN_OK. No numbers: the game inserts any amount through a placeholder. Tags name the effect in words as the owner described it; the Economy Designer sets size and duration. Planet = {planet}.

## Debris in orbit [route efficiency down: {planet}, while the debris stays]
EV17_TITLE | choice title | Wreckage is circling {planet}
EV17_BODY | choice body | A field of old wrecks circles {planet}. Captain Rusk offers to sweep it for a fee. The Bureau filed the wreckage as unowned, so no one has to move it. Routes from {planet} carry less while it stays.
EV17_PAY_BTN | button | Pay the fee
EV17_PAY_EFF | effect line | Pay the fee. The debris is cleared and routes from {planet} run as before.
EV17_LEAVE_BTN | button | Leave the debris
EV17_LEAVE_EFF | effect line | Routes from {planet} carry less while the debris stays. It does not clear itself.
EV17_PAID_TITLE | popup title | Orbit over {planet} is clear
EV17_PAID | popup | Rusk's tugs swept the orbit and handed you a receipt. Routes from {planet} carry their full load again. The wreckage went somewhere. Rusk smiled when you asked, so you stopped asking.
EV17_LEFT_TITLE | popup title | Debris stays over {planet}
EV17_LEFT | popup | You left the wreck. Ships from {planet} thread around it in the dark and carry less. The offer stays open. Rusk's tug waits at the edge of the field, patient as a bill.

## Asteroid approach [warning; pay the state: no skill point, no reputation; decline: 50/50 bad outcome or nothing; bad outcome is storage destroyed or storage capacity cut]
EV20_TITLE | choice title | An asteroid is approaching
EV20_BODY | choice body | A rock is coming in on a slow path. The Bureau saw it late, as it sees everything. The state can turn it aside for a fee, and says it does so out of love. Refusing is a shorter form. Cask Cellar keeps Luxury stock safe from such a cut.
EV20_PAY_BTN | button | Pay the state
EV20_PAY_EFF | effect line | Cost: payment to the state. Asteroid dealt with. The company gains one expansion point.
EV20_DECLINE_BTN | button | Decline
EV20_DECLINE_EFF | effect line | An even chance: company storage is hit, or nothing happens.
EV20_PAID_TITLE | popup title | The asteroid is deflected
EV20_PAID | popup | The state turned the rock aside and sent you the receipt. The company gains one expansion point. The asteroid drifts on toward someone else's sky. Nobody on the dock looked up until it was gone.
EV20_REWARD | notice (shown after EV20_PAID) | Event reward: the asteroid is dealt with and the company gains an expansion point.
EV20_HIT_TITLE | popup title | Company storage destroyed
EV20_HIT_DESTROYED | popup | The asteroid struck {planet}. Your company storage there is gone, and what it held with it. The Bureau entered it as an adjustment to the Common Ledger. Nobody said sorry. Your crew stood where the door used to be.
EV20_HIT_CAPACITY | popup | The asteroid grazed {planet}. Your company storage there is cracked and holds less. The Bureau wrote the word partial. The crack runs up the wall in a straight line. Your crew keep their distance from it.
EV20_MISS_TITLE | popup title | The asteroid passes
EV20_MISS | popup | The asteroid passed the system and kept going. Nothing was hit and nothing changes. The Bureau withdrew its warning, but kept the form. For one night your crew slept in their boots.

# Choice events with follow-ups (rewritten 2026-11-11)

Three story events with two choices each, one engine tag per choice (price up, price down, planet closed), and a follow-up popup that comes a few cycles after the choice (a choice carries follow_id; the follow-up is never drawn at random). Limits as the choice screen: title 40, body 280, button 28, effect line 90; popups: title 32, text 280. No numbers. Gates are in the plan file handoffs/story-designer/2026-11-11-event-expansion.json. BE01 and BE03 are Biotech only (they name food), BE02 is Luxury only (it names musk, silk and blooms).

## BE01 Tillam's sealed granary [2 choices, Biotech, Tillam]
BE01_TITLE | choice title | Tillam's sealed granary
BE01_BODY | choice body | Tillam keeps grain behind a lock only the committee can open. Winter is close and the stores outside are thin. The committee will open it for a company that carries the grain out, and wants an answer today. The queue has not moved since dawn.
BE01_OPEN_BTN | button | Open it to the crowd
BE01_OPEN_EFF | effect line | Food at Tillam costs less and pays less for a while. Tillam remembers.
BE01_SHUT_BTN | button | Keep the lock shut
BE01_SHUT_EFF | effect line | Food at Tillam costs more and pays more for a while. Tillam remembers.
BE01_OPEN_TITLE | popup title | The granary opens
BE01_OPEN | popup | The lock gave way. The grain went out by hand, sack to sack, and no one in the line spoke. Food at Tillam costs less and pays less while stores are full. The committee recorded a loan. Nobody asked who owes whom.
BE01_SHUT_TITLE | popup title | The lock stays shut
BE01_SHUT | popup | You said no. The lock stayed on and the queue grew in the cold. Food at Tillam costs more and pays more while it is scarce. A child at the front sat on her bag and watched your ship. Inside the granary, something shifted.

[follow-up of BE01_OPEN, tag: price up: Tillam, energy]
BE01A_TITLE | popup title | Tillam burns bright for you
BE01A | popup | Tillam remembered the grain. Heaters on every terrace run high, and the committee calls it a gift. Energy at Tillam costs more and pays more for a while. The frost in the ducts has gone quiet, as if it was fed.

[follow-up of BE01_SHUT, tag: planet closed: Tillam]
BE01B_TITLE | popup title | Tillam closes its port
BE01B | popup | The queue that waited in the cold came down to the docks. Tillam's port is closed for a while, and routes touching Tillam are blocked. No one shouts. They stand in rows and watch your ships sit still.

## BE02 The beacon over Dunmere Reach [2 choices, Luxury, system 2]
BE02_TITLE | choice title | A beacon over Dunmere Reach
BE02_BODY | choice body | A beacon pulses over Dunmere Reach, from a rock no chart lists. Its pattern repeats, then changes, as if it heard the dock talk. The Bureau office at Quillon wants it logged and silenced. Your crews want to answer. Your ships pass it every cycle.
BE02_ANSWER_BTN | button | Answer the beacon
BE02_ANSWER_EFF | effect line | Musk at Quillon costs more and pays more for a while. Something answers back.
BE02_REPORT_BTN | button | Report it to the Bureau
BE02_REPORT_EFF | effect line | Quillon closes its port to check the sky. Routes touching Quillon are blocked for a while.
BE02_ANSWER_TITLE | popup title | The beacon is answered
BE02_ANSWER | popup | A crew sent a few pulses back. The beacon went dark, then lit again in the same order. Quillon's buyers heard, and bought musk as if a festival had been called. Musk there costs more and pays more. No one will say what the festival is for.
BE02_REPORT_TITLE | popup title | Quillon checks the sky
BE02_REPORT | popup | The Bureau filed the beacon as a fault and closed Quillon's port to inspect the sky. Routes touching Quillon are blocked for a while. The inspectors were polite. The beacon pulsed once, as if it had read the form.

[follow-up of BE02_ANSWER, tag: price up: Mossfell, blooms]
BE02A_TITLE | popup title | Visitors reach Mossfell
BE02A | popup | Small ships came in from the quiet rock and docked at Mossfell without papers. They want hothouse blooms and pay in odd, heavy coins. Hothouse blooms at Mossfell cost more and pay more for a while. They gave no names. They counted every stem twice, and watched your crew do it.

[follow-up of BE02_REPORT, tag: price down: Quillon, silk]
BE02B_TITLE | popup title | The inspection finds nothing
BE02B | popup | The inspectors found no fault and Quillon's port reopened. Stock held back for the check came out all at once. Silk at Quillon costs less and pays less for a while. The beacon is still up there. The report says it is not.

## BE03 A family offers cover [2 choices, Biotech, Ashgate, after the family bought Ashgate's food (EV13)]
BE03_TITLE | choice title | A family offers cover
BE03_BODY | choice body | The family that bought Ashgate's food contracts sends a polite note. For a share, they will keep the docks quiet and the other traders out. They also mention how fragile a dock can be. Your crew read the note over your shoulder. No one spoke.
BE03_ACCEPT_BTN | button | Accept their cover
BE03_ACCEPT_EFF | effect line | Food at Ashgate costs more and pays more for a while. The family will call in the favour.
BE03_REFUSE_BTN | button | Refuse politely
BE03_REFUSE_EFF | effect line | Food at Ashgate costs less and pays less for a while. The family will wait.
BE03_ACCEPT_TITLE | popup title | The family keeps the docks
BE03_ACCEPT | popup | The family's people took the docks at dawn, in clean coats. Food at Ashgate costs more and pays more, since their prices came with them. The docks are quiet. Your crew lower their voices there. A quiet dock has an owner.
BE03_REFUSE_TITLE | popup title | The note is declined
BE03_REFUSE | popup | You sent back a polite no. The family sent back a polite nod. Food at Ashgate costs less and pays less as their buyers step back to watch. No one was threatened. Your crew check the locks twice each night.

[follow-up of BE03_ACCEPT, tag: planet closed: Ashgate]
BE03A_TITLE | popup title | The family calls its favour
BE03A | popup | The family closed Ashgate's docks to every ship but its own, and sent you the bill for the quiet. Routes touching Ashgate are blocked for a while. The note was courteous. A favour is a debt that keeps its place.

[follow-up of BE03_REFUSE, tag: price down: Ashgate, energy]
BE03B_TITLE | popup title | The family waits
BE03B | popup | The family did nothing, which was its answer. Its buyers stayed away from the furnaces, and energy at Ashgate costs less and pays less for a while. A courier sits in a booth on the dock, reading, never turning a page. He is there every shift.

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
| EV50 | [price down: Tillam, spores] | Q |
| EV51 | [price up: Brannock, seed] | Q |

EV40_TITLE | pool event title | Rivet guns pile up at Voltara
EV40_BODY | pool event text | Voltara's foundry kept casting rivet guns after the Admiralty's order was filled, since its last line reads until victory. Stacks reach the roof. Rivet guns at Voltara cost less and pay less. A clerk asked if victory knew. Contract Doctrine softens Military price events.
EV40_EFF | pool event weather line | Weather: no house changes its next weather.

EV43_TITLE | pool event title | A glut of sunmusk
EV43_BODY | pool event text | A convoy of sunmusk reached Tillam on one tide, and nobody had ordered it. Sunmusk at Tillam costs less and pays less. The scent hangs in the corridors, and no two buyers agree what it smells of. The Bureau calls that variety. One dockhand calls it a headache.
EV43_EFF | pool event weather line | Weather: no house changes its next weather.

EV46_TITLE | pool event title | The smelter goes cold
EV46_BODY | pool event text | Voltara's smelter lost its heat to a cracked line, and the casting stopped. Ingot at Voltara costs more and pays more until the furnace is lit again. The crew stand by the dead furnace with their hands out. The metal inside still ticks as it shrinks.
EV46_EFF | pool event weather line | Weather: no house changes its next weather.

EV47_TITLE | pool event title | Alloy rolls off the line early
EV47_BODY | pool event text | Voltara's line turned out seam alloy a week early, before the builders had placed an order. Seam alloy at Voltara costs less and pays less. The bales are stacked to the lamps, and a clerk is counting them for the third time. The count has not improved.
EV47_EFF | pool event weather line | Weather: every house keeps its next weather as it was.

EV49_TITLE | pool event title | Quarantine at the culture lab
EV49_BODY | pool event text | A culture in Ashgate's lab grew a colour it was not meant to, and the doctors sealed the port. Routes touching Ashgate are blocked for a while. The notice says contained. The night shift counts heads each hour. One is short. Hardy Strains reopens a closed planet a cycle sooner.
EV49_EFF | pool event weather line | Weather: no house changes its next weather.

EV50_TITLE | pool event title | Spores come in cheap
EV50_BODY | pool event text | A damp season at Tillam raised spore cultures in every crate, more than anyone could sell. Spore cultures at Tillam cost less and pay less. The manager says the crates are fine. The crates sweat in rows, and the ones in the corner have grown a lid of their own.
EV50_EFF | pool event weather line | Weather: every house keeps its next weather as it was.


# Early branch events, one per market, EV52 to EV55 (added 2026-11-06, T233)

Four one-time pool events, one per market (Military EV52, Luxury EV53, Minerals EV54, Biotech EV55). They fire early, in the first cycles. TEXT ONLY: no row in data/events.json, no tag; T234 adds the mechanics. Each has a title, a body, a rivals line (EVnn_EFF, as the other pool events) and two options, A (the dark-market buyer) and B (the public market). Ids per option: EVnn_A_BTN (28), EVnn_A_EFF (90), EVnn_A_TITLE (32), EVnn_A (result, 280); the same with B.
Placeholder: {cash_in} is the credits the chosen option pays, number only. T234 fills it per option (A more than B). {market} is filled by the game in the EVnn_EFF line.
No text names a good, a planet or a number: the goods of the early cycles are only energy and food, so each event speaks of crates, sets, cases and trays. The effect lines say only "pays more now" or "pays less now". No text hints at being seen, a risk or a later cost.

EV52_TITLE | pool event title | A Fleet Office rush order
EV52_BODY | pool event text | The Fleet Office gave you a rush order, and three larger crews want it if you slip. At the depot's back gate, Bosk Two-Stamps offers ready cash for some crates. His thumbs are blue from stamping forms nobody wrote. Sell fast, or sell at the counter.
EV52_EFF | pool event weather line | Weather: no house changes its next weather.
EV52_A_BTN | button | Sell to Bosk Two-Stamps
EV52_A_EFF | effect line | Pays more now: {cash_in} credits.
EV52_A_TITLE | popup title | Bosk has one stamp
EV52_A | popup | Bosk paid in worn notes and stamped your slip. He owns one stamp. The name is a rumour he started himself. The crates left by the back gate before the clerk finished his tea. You gain {cash_in} credits now.
EV52_B_BTN | button | Sell at the public counter
EV52_B_EFF | effect line | Pays less now: {cash_in} credits.
EV52_B_TITLE | popup title | The counter takes its time
EV52_B | popup | The counter clerk checked each crate against the order, then checked the order against the crates. A stamp thumped somewhere in the back. It paid {cash_in} credits, less than the back gate would have.

EV53_TITLE | pool event title | The Orrel House gala order
EV53_BODY | pool event text | The Orrel House ordered cut-glass table sets for its gala, and two older firms bid for the same carriage. On a pleasure barge by the dock ring, Madame Fenn offers cash for a few sets. She calls every sale a private viewing and charges for the chair.
EV53_EFF | pool event weather line | Weather: every house keeps its next weather as it was.
EV53_A_BTN | button | Sell to Madame Fenn
EV53_A_EFF | effect line | Pays more now: {cash_in} credits.
EV53_A_TITLE | popup title | A private viewing
EV53_A | popup | The viewing lasted as long as it took to count the notes. Madame Fenn charged for the chair anyway. The sets went down the ramp wrapped in her shawls. You gain {cash_in} credits now. The gala table will be a few glasses short.
EV53_B_BTN | button | Sell at the open stalls
EV53_B_EFF | effect line | Pays less now: {cash_in} credits.
EV53_B_TITLE | popup title | The stalls open at noon
EV53_B | popup | You laid the sets out on the open stalls under the dock lamps. Buyers turned each glass to the light and haggled over chips that were not there. It paid {cash_in} credits, less than the barge would have.

EV54_TITLE | pool event title | Deepline Works sample run
EV54_BODY | pool event text | The Deepline Works hired you to carry sealed sample cases to its assay hall, and a faster crew is already loading. Tamsk Reddock, who runs the slag yard, offers cash for some cases. He weighs everything on one thumb and says heavy. Even the empty ones.
EV54_EFF | pool event weather line | Weather: none of the three houses changes its next weather.
EV54_A_BTN | button | Sell to Tamsk Reddock
EV54_A_EFF | effect line | Pays more now: {cash_in} credits.
EV54_A_TITLE | popup title | Tamsk says heavy
EV54_A | popup | Tamsk lifted a case on his thumb and said heavy, as he does every time. Then he paid in full from a tin. The cases rolled off to the slag yard on a cart with one good wheel. You gain {cash_in} credits now.
EV54_B_BTN | button | Sell to the assay hall
EV54_B_EFF | effect line | Pays less now: {cash_in} credits.
EV54_B_TITLE | popup title | The assay hall counts
EV54_B | popup | The assay hall took the cases at its own rate and its own pace. A clerk read each seal aloud, twice. Your crew stood in the cold while the ink dried. It paid {cash_in} credits, less than the slag yard would have.

EV55_TITLE | pool event title | Lowmoor Clinics need trays
EV55_BODY | pool event text | The Lowmoor Clinics hired you to carry chilled sample trays to their wards, and a rival crew has a faster hull. Dr Pell Oruk waits behind the cold dock and offers cash for some trays. He tests each coin with a tooth and calls it mostly healthy.
EV55_EFF | pool event weather line | Weather: no house changes its next weather.
EV55_A_BTN | button | Sell to Dr Pell Oruk
EV55_A_EFF | effect line | Pays more now: {cash_in} credits.
EV55_A_TITLE | popup title | Mostly healthy coins
EV55_A | popup | Dr Oruk bit every coin and found them mostly healthy. Then he paid in full. The trays left by the back door in a cold box, still labelled for a ward. You gain {cash_in} credits now. The ward gets fewer trays.
EV55_B_BTN | button | Sell at the clinic desk
EV55_B_EFF | effect line | Pays less now: {cash_in} credits.
EV55_B_TITLE | popup title | The clinic desk signs
EV55_B | popup | The clinic desk took the trays by the book. A nurse read every label aloud and the ward bell rang twice. It paid {cash_in} credits, less than the cold dock would have.

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
TH01_TITLE | event title | A tug asks for your book
TH01_BODY | event text | A tug named Slow Receipt docks at Voltara. Its owner, Maren Oake, once kept books for the Bureau. She asks to read your dock book, page by page. She says she hunts one debt. She does not say whose.
TH01_A_BTN | button | Hand over the dock book
TH01_A_EFF | effect line | Food at Voltara costs more and pays more for a while.
TH01_A_TITLE | popup title | Oake reads by lamplight
TH01_A | popup | Oake read all night and turned each page with one finger. Her helpers filled the canteen. Food at Voltara costs more and pays more for a while. At dawn she thanked you and wrote one line on her cuff.
TH01_B_BTN | button | Send her to the Bureau desk
TH01_B_EFF | effect line | Energy at Voltara costs less and pays less for a while.
TH01_B_TITLE | popup title | Oake takes a number
TH01_B | popup | The desk took her name and gave her a number. She waited in the long row while cranes stood idle overhead. Energy at Voltara costs less and pays less for a while. She did not complain. She counted the row.

## TH02 The first page
TH02_TITLE | event title | The first page
TH02_BODY | event text | Oake comes back with a page, brown at the edges. It is the loan that bought the first ship of a crew like yours. Three lenders signed it. Two were repaid. The third, Teodor Lask, never came to collect.
TH02_A_BTN | button | Search your own papers
TH02_A_EFF | effect line | Food at Voltara costs less and pays less for a while.
TH02_A_TITLE | popup title | A day among old crates
TH02_A | popup | Your crew spent the day among old crates and ate from tins. Food at Voltara costs less and pays less for a while. One crate held a receipt with Lask's name on it. It was blank where the sum should be.
TH02_B_BTN | button | Ask the old dock crews
TH02_B_EFF | effect line | Energy at Voltara costs more and pays more for a while.
TH02_B_TITLE | popup title | Talk after the shift
TH02_B | popup | The old crews talked late and kept the lamps burning. Energy at Voltara costs more and pays more for a while. Most had heard the name Lask. None could say where they had heard it, and each one lowered a voice to say so.

## TH03 Lask on a relief list
TH03_TITLE | event title | Lask on a relief list
TH03_BODY | event text | A cook at Tillam writes that the name Lask is on an old relief list from the blight years. The committee keeps it in a locked drawer. Oake asks you to carry her request there, with your seal on it.
TH03_A_BTN | button | Send a ship with the request
TH03_A_EFF | effect line | Food at Voltara costs more and pays more for a while.
TH03_A_TITLE | popup title | A ship leaves with a letter
TH03_A | popup | A hold went to Oake's letter and not to cargo. Food at Voltara costs more and pays more for a while. The ship left with the letter strapped to a crate, like a passenger who might change its mind.
TH03_B_BTN | button | Wait for the next post ship
TH03_B_EFF | effect line | Energy at Voltara costs less and pays less for a while.
TH03_B_TITLE | popup title | The letter waits
TH03_B | popup | The letter sat on the dock for the next post ship. Docks ran slow and drew less power. Energy at Voltara costs less and pays less for a while. Oake sat beside the letter the whole time, as if it might be taken.

## TH04 A second seeker
TH04_TITLE | event title | A second seeker
TH04_BODY | event text | A man in a grey coat, Aurel Dask of the Quill Lender House, finds Oake on your dock. His house buys old paper. He asks to copy the Lask page, and says he will find the heir sooner. He does not say what he will do then.
TH04_A_BTN | button | Let Dask copy the page
TH04_A_EFF | effect line | Food at Voltara costs less and pays less for a while.
TH04_A_TITLE | popup title | Dask copies the page
TH04_A | popup | Dask copied the page in a fast, tidy hand. His agents sold stores on the dock to pay for the hunt. Food at Voltara costs less and pays less for a while. He thanked Oake twice. She did not look up.
TH04_B_BTN | button | Refuse to copy the page
TH04_B_EFF | effect line | Energy at Voltara costs more and pays more for a while.
TH04_B_TITLE | popup title | Dask goes back to his ship
TH04_B | popup | Dask bowed and held his house's stock back from the dock. Energy at Voltara costs more and pays more for a while. His ship stayed in orbit, lamps lit, and it was still there when the crew went to bed.

## TH05 A hull with a scraped name
TH05_TITLE | event title | A hull with a scraped name
TH05_BODY | event text | Under a tarp in Voltara's old yard sits a hull with its name scraped off. Oake reads a hull number through the dirt. It matches the page. The yard is sealed, and opening it pulls cranes from the shift.
TH05_A_BTN | button | Open the old yard
TH05_A_EFF | effect line | Energy at Voltara costs more and pays more for a while.
TH05_A_TITLE | popup title | The tarp comes off
TH05_A | popup | The cranes swung over to the yard and the lamps burned all shift. Energy at Voltara costs more and pays more for a while. Inside the hull was a bunk, a cup and a tally scratched on the wall. The last mark is shorter than the rest.
TH05_B_BTN | button | Keep the yard sealed
TH05_B_EFF | effect line | Food at Voltara costs less and pays less for a while.
TH05_B_TITLE | popup title | The yard stays shut
TH05_B | popup | You kept the yard sealed. The crews who came to look went home without eating at the stalls. Food at Voltara costs less and pays less for a while. Oake stood at the fence until the lamps changed over.

## TH06 The Bureau answers
TH06_TITLE | event title | The Bureau answers
TH06_BODY | event text | The Bureau sends a letter, courteous and slow. It says the Commons settled the Lask debt long ago. The page copies a closed entry. It asks Oake to stop. It asks you to confirm that she has.
TH06_A_BTN | button | Confirm she has stopped
TH06_A_EFF | effect line | Food at Voltara costs less and pays less for a while.
TH06_A_TITLE | popup title | The Bureau is satisfied
TH06_A | popup | You signed the confirmation. The Bureau sent relief stores to the dock as thanks. Food at Voltara costs less and pays less for a while. Oake read the confirmation twice, then folded it and put it with the page.
TH06_B_BTN | button | Say she has not stopped
TH06_B_EFF | effect line | Voltara closes its port for a while. Routes touching Voltara are blocked.
TH06_B_TITLE | popup title | Voltara closes its port
TH06_B | popup | You wrote that she had not stopped. The Bureau sent inspectors, and they closed Voltara's port for a while. Routes touching Voltara are blocked. They were very careful with the dock book. They kept it overnight.

## TH07 Slow Receipt is held
TH07_TITLE | event title | Slow Receipt is held
TH07_BODY | event text | The Bureau holds Slow Receipt at the dock for a form not yet filed. Oake sleeps in a borrowed coat on a crate. Some of your people want her gone before the next audit. Others bring her soup.
TH07_A_BTN | button | Keep her in your bunk
TH07_A_EFF | effect line | Food at Voltara costs more and pays more for a while.
TH07_A_TITLE | popup title | A bunk with her name
TH07_A | popup | The empty bunk was hers by morning. Two tables formed in the canteen, one with soup and one without. Food at Voltara costs more and pays more for a while. Nobody asked which table the tug belonged to.
TH07_B_BTN | button | Find her a room ashore
TH07_B_EFF | effect line | Energy at Voltara costs less and pays less for a while.
TH07_B_TITLE | popup title | A room ashore
TH07_B | popup | A clerk found her a room in the old block, with one cold heater. Energy at Voltara costs less and pays less for a while. She came to the dock each morning to look at her tug. It did not look back.

## TH08 A letter from a far station
TH08_TITLE | event title | A letter from a far station
TH08_BODY | event text | A letter reaches the dock. Ines Lask, daughter of Teodor, is old and writes slowly. She asks for no money. She asks that someone read the debt aloud once, in a room with people in it.
TH08_A_BTN | button | Read it aloud on the dock
TH08_A_EFF | effect line | Food at Voltara costs more and pays more for a while.
TH08_A_TITLE | popup title | The dock hall fills
TH08_A | popup | Word went round, and the hall filled with crews who had never met a Lask. They brought bread and stood. Food at Voltara costs more and pays more for a while. The back rows were the last to leave.
TH08_B_BTN | button | Read it aloud by relay
TH08_B_EFF | effect line | Energy at Voltara costs more and pays more for a while.
TH08_B_TITLE | popup title | The relay stays on
TH08_B | popup | The relay ran all night to carry one voice to a far room. Energy at Voltara costs more and pays more for a while. At the far end someone coughed once, and the line went on listening.

## TH09 The reading
TH09_TITLE | event title | The reading
TH09_BODY | event text | The reading is tonight. The page has three names and a sum written long ago. Someone must say it aloud. Oake holds the page with both hands. She says it is your dock, and your crew, so it is your voice.
TH09_A_BTN | button | Read the page yourself
TH09_A_EFF | effect line | Energy at Voltara costs less and pays less for a while.
TH09_A_TITLE | popup title | Your voice on the page
TH09_A | popup | Your voice shook on the third name, and the hall heard it. Most lamps were turned down to hear better. Energy at Voltara costs less and pays less for a while. When you finished no one clapped. They stayed seated.
TH09_B_BTN | button | Let Oake read the page
TH09_B_EFF | effect line | Food at Voltara costs less and pays less for a while.
TH09_B_TITLE | popup title | Oake reads it flat
TH09_B | popup | Oake read in a dry, flat voice, as she had read a thousand pages. At the third name she stopped, then went on. Food at Voltara costs less and pays less for a while. The stalls closed early and the hall stayed full.

## TH10 What is owed
TH10_TITLE | event title | What is owed
TH10_BODY | event text | Oake closes her ledger. The Lask debt stands in full, with its years. You can pay it to Ines Lask, and the page is struck. Or the Commons can enter it as shared, and the Bureau will call it settled. Ines has not asked for either.
TH10_A_BTN | button | Pay the debt to Ines
TH10_A_EFF | effect line | Pay {cash_out} credits to Ines Lask. Nothing else changes.
TH10_A_TITLE | popup title | The page is struck
TH10_A | popup | You paid {cash_out} credits to Ines Lask, and a clerk drew one line through her father's name. Oake folded the page into your dock book. Slow Receipt left on the next tide, light, with its lamp on.
TH10_B_BTN | button | Enter it as shared
TH10_B_EFF | effect line | Pay nothing. Food at Voltara costs more and pays more for a while.
TH10_B_TITLE | popup title | The debt is shared
TH10_B | popup | The clerk entered the debt in the Common Ledger and the Bureau stamped it settled. Nobody was paid. Food at Voltara costs more and pays more for a while, as clerks counted the dock stores. The page went into a drawer with its three names.

# Events, expansion (2026-11-11): posts, platforms, lanes, Military, Luxury, Minerals, Biotech

Pool events added on 2026-11-11. Every one is a pool row (data/chains.json pool_new) with a gate and one effect per option; the plan file handoffs/story-designer/2026-11-11-event-expansion.json names effect, world, good and gate for each. All rows are 3-field text rows (the build writes no events.json row). Each fires once per run. Plain event: EV<nn>_TITLE (32), EV<nn>_BODY (280). Choice event: those two, then per option key K: _K_BTN (28), _K_EFF (90), _K_TITLE (32), _K (popup, 280). Effect lines say only what the one option does, in words ("a small sum", "for a while"). No digits, no names of hidden goods: a text names a good only when its gate makes that good visible.
The posts and platforms events (EV_PST01 to EV_PST06, EV_PLT01 to EV_PLT04) and the lane events (EV_FLT01 to EV_FLT04) are the old pending texts, rewritten to effects the game has today and wired as ordinary pool events; they no longer need a "post built" or "in flight" trigger.

## Shared pool: posts and lanes (any CEO)

EV_PST01_TITLE | pool event title | A dock that keeps a book
EV_PST01_BODY | pool event text | The dock at Flintmoor keeps a visitors' book. The clerk wants your name in it before the first crate moves. The cover is cold to the touch. Nobody can say who opened it. A signed name earns the dock's favour. An unsigned one earns a refund.
EV_PST01_SIGN_BTN | button | Sign the book
EV_PST01_SIGN_EFF | effect line | Energy at Flintmoor costs more and pays more for a while.
EV_PST01_SIGN_TITLE | popup title | The book is signed
EV_PST01_SIGN | popup | The clerk blotted your name and nodded, as if it had always been there. The dock's buyers took note, and energy at Flintmoor costs more and pays more for a while. On the page beside yours, someone else's handwriting changed.
EV_PST01_LEAVE_BTN | button | Leave without signing
EV_PST01_LEAVE_EFF | effect line | You gain a small sum, the dock's refund for a name not written.
EV_PST01_LEAVE_TITLE | popup title | The book stays shut
EV_PST01_LEAVE | popup | You left the clerk waiting, pen raised. The clerk sent a small sum after you, the fee for a name not written. You gain a small sum. The clerk wrote a line anyway, in a hand that was not the clerk's.

EV_PST02_TITLE | pool event title | The Port Warden's stamp
EV_PST02_BODY | pool event text | Warden Ilsa Dorne must inspect the new post at Brannock before she can stamp its lease. She inspects slowly. Your crew wait on the dock with the crates unopened. A gift would hurry her. Waiting would work, in time.
EV_PST02_GIFT_BTN | button | Send a gift
EV_PST02_GIFT_EFF | effect line | Pay a small sum. The stamp comes today.
EV_PST02_GIFT_TITLE | popup title | The Warden is hurried
EV_PST02_GIFT | popup | The gift went up the stairs and the stamp came down, still wet. You paid a small sum. The Warden did not smile. Your crew took that for thanks.
EV_PST02_WAIT_BTN | button | Wait for the stamp
EV_PST02_WAIT_EFF | effect line | Energy at Brannock costs less and pays less for a while.
EV_PST02_WAIT_TITLE | popup title | The stamp takes its time
EV_PST02_WAIT | popup | You waited. The Warden checked every rivet, then the shadows between them. Buyers at Brannock held back while the dock stood idle, so energy there costs less and pays less for a while.

EV_PST03_TITLE | pool event title | The beam will not hold
EV_PST03_BODY | pool event text | The survey beam at Cindrel will not hold a line. The foreman blames the weather, which is indoors. A part can be bought from a passing hauler. Or your crew can wait for the next shift to have an idea.
EV_PST03_PART_BTN | button | Buy the part
EV_PST03_PART_EFF | effect line | Pay a small sum. The beam is fixed today.
EV_PST03_PART_TITLE | popup title | The part is fitted
EV_PST03_PART | popup | The hauler's mate named a price and you paid a small sum. By evening the beam held its line. The crew now knows where the weather comes from.
EV_PST03_SHIFT_BTN | button | Wait for the next shift
EV_PST03_SHIFT_EFF | effect line | Lanes that touch Cindrel cost more per trip for a few cycles.
EV_PST03_SHIFT_TITLE | popup title | The shift has an idea
EV_PST03_SHIFT | popup | The next shift had an idea, and it was to wait for the one after. Haulers stacked up behind the dead beam, so lanes that touch Cindrel cost more per trip for a few cycles. The beam flickered once, toward nothing anyone had aimed at.

EV_PST04_TITLE | pool event title | A broker with spare fittings
EV_PST04_BODY | pool event text | A broker named Odo Pell meets your ship at Mossfell with a tray of seals and a lease. A neighbouring post closed, and he must clear its books. He talks as if the deal were already done. He can hand over the lease, or the spare cells in its stores.
EV_PST04_LEASE_BTN | button | Take the lease
EV_PST04_LEASE_EFF | effect line | Energy at Mossfell costs more and pays more for a while.
EV_PST04_LEASE_TITLE | popup title | The lease changes hands
EV_PST04_LEASE | popup | Pell counted the seals twice and gave you one extra, as a courtesy. Buyers at Mossfell followed the lease, so energy there costs more and pays more for a while. The seals are warm, as if someone had only just let go of them.
EV_PST04_CELLS_BTN | button | Take the spare cells
EV_PST04_CELLS_EFF | effect line | Some energy is added to your Company storage at Mossfell.
EV_PST04_CELLS_TITLE | popup title | The cells are counted
EV_PST04_CELLS | popup | Pell wheeled out the spare cells on a cart and read each tag aloud. Some energy is added to your Company storage at Mossfell. He said the closed post would not miss them, and looked at the sky as if someone might.

EV_PST05_TITLE | pool event title | A desk already stands here
EV_PST05_BODY | pool event text | A desk with a broker's seal already stands on the dock at Quillon. It has a kettle, a stool and a long record of waiting. The agent offers you the next stool, or a small sum to take your crates to another berth. He does not offer to move.
EV_PST05_SHARE_BTN | button | Share the dock
EV_PST05_SHARE_EFF | effect line | Energy at Quillon costs more and pays more for a while.
EV_PST05_SHARE_TITLE | popup title | The dock is shared
EV_PST05_SHARE | popup | You took the next stool. The agent poured two cups and drank both. Buyers at Quillon saw two seals at one dock and bought hard, so energy there costs more and pays more for a while.
EV_PST05_MOVE_BTN | button | Take the other berth
EV_PST05_MOVE_EFF | effect line | You gain a small sum.
EV_PST05_MOVE_TITLE | popup title | A berth farther down
EV_PST05_MOVE | popup | You took the far berth. The agent counted out a small sum without being asked, and you gain a small sum. The kettle went cold between the seals.

EV_PST06_TITLE | pool event title | Residents come to look
EV_PST06_BODY | pool event text | Tillam has grown, and its residents gather at the dock to see your ships. They stand in rows. A child asks if you will stay. The clerk says that is a question for the Plan. No one leaves until someone speaks.
EV_PST06_OPEN_BTN | button | Hold an open dock
EV_PST06_OPEN_EFF | effect line | Energy at Tillam costs more and pays more for a while.
EV_PST06_OPEN_TITLE | popup title | The dock stays open
EV_PST06_OPEN | popup | You set out chairs and a schedule, and the rows turned into a queue. The crowd bought energy for its stoves, so energy at Tillam costs more and pays more for a while. The child left with a bolt in her pocket.
EV_PST06_WORK_BTN | button | Keep to the work
EV_PST06_WORK_EFF | effect line | Some energy is added to your Company storage at Tillam.
EV_PST06_WORK_TITLE | popup title | The rows thin out
EV_PST06_WORK | popup | You kept to the work and the rows thinned by dusk. The dock clerk stacked spare cells in your storage, a thanks that came with a stamp. Some energy is added to your Company storage at Tillam. The child watched until the last crate was stamped. Then she walked home alone.

EV_FLT01_TITLE | pool event title | A wreck on the lane
EV_FLT01_BODY | pool event text | A hull drifts across the lane, cold, its name scraped off. The Flagship's scanner counts no one aboard, then counts again. Salvage is salvage, if no one comes to claim it. The hull can be sold as scrap, or stripped for its cells.
EV_FLT01_TOW_BTN | button | Sell it as scrap
EV_FLT01_TOW_EFF | effect line | You gain a small sum for the salvage.
EV_FLT01_TOW_TITLE | popup title | The wreck is sold
EV_FLT01_TOW | popup | A scrap crew towed the hull away and paid at the dock. You gain a small sum for the salvage. The scanner counted one aboard as the hull went. It did not count again.
EV_FLT01_STRIP_BTN | button | Strip its cells
EV_FLT01_STRIP_EFF | effect line | Some energy is added to your Company storage at Voltara.
EV_FLT01_STRIP_TITLE | popup title | The cells come out
EV_FLT01_STRIP | popup | Your crew pulled the hull's cells one by one and carried them home. Some energy is added to your Company storage at Voltara. In the rear glass the hull turned slowly, showing its scraped patch, then its other side.

EV_FLT02_TITLE | pool event title | A call on an old band
EV_FLT02_BODY | pool event text | A distress call comes in on an old band, the voice polite and unhurried. By the time the Flagship turns, the call has become a recipe. A relay fee would let you check it from here. Or the band can stay busy while you hold your course.
EV_FLT02_RELAY_BTN | button | Pay the relay fee
EV_FLT02_RELAY_EFF | effect line | Pay a small sum. The band is checked from here.
EV_FLT02_RELAY_TITLE | popup title | The relay answers
EV_FLT02_RELAY | popup | You paid a small sum, and the relay checked the band without a turn. The relay reported a pot, a stove and a very long wait. It filed the call as cooked.
EV_FLT02_HOLD_BTN | button | Hold the course
EV_FLT02_HOLD_EFF | effect line | Lanes that touch Brannock cost more per trip for a few cycles.
EV_FLT02_HOLD_TITLE | popup title | The call fades
EV_FLT02_HOLD | popup | You held the course. Other ships turned to answer, and the dock beacons at Brannock jammed with their replies. Lanes that touch Brannock cost more per trip for a few cycles. The voice said the last step twice, very slowly, and was gone.

## Military pool

EV41_TITLE | pool event title | Cindrel fires a training round
EV41_BODY | pool event text | Cindrel's reactor crews were ordered to drill with live munitions, to prove the drill was real. The order ran three days past the drill. Munitions at Cindrel cost more and pay more. The blast doors still hum a low note when no one is near them.

EV42_TITLE | pool event title | Quillon buys a parade
EV42_BODY | pool event text | Quillon's buyers ordered weapons for a parade, since a march looks bare without them. Weapons at Quillon cost more and pay more. The parade has no route and no date. The crates arrive anyway, each signed for by a different clerk in the same hand.

EV81_TITLE | pool event title | Energy runs short at Flintmoor
EV81_BODY | pool event text | Flintmoor's powder works asked for more power than the moon's grid books. Old rim crews know the sound of a grid about to say no. Energy at Flintmoor is wanted harder for a few cycles and the hunger shows in the price. A rush order may follow.

EV82_TITLE | pool event title | A hull waits for a stamp
EV82_BODY | pool event text | A ship sits at Tillam waiting for a clearance stamp. A clerk will stamp it today for a payment. Or it waits its turn, and the dock fills behind it. Every idle hour is counted by someone who is not you.
EV82_PAY_BTN | button | Pay for the stamp
EV82_PAY_EFF | effect line | Pay a small sum. The ship moves today.
EV82_PAY_TITLE | popup title | The hull moves
EV82_PAY | popup | The stamp landed and the hull was gone by the next bell. You paid a small sum. Your crew did not watch it go.
EV82_WAIT_BTN | button | Wait its turn
EV82_WAIT_EFF | effect line | Lanes that touch Tillam cost more per trip for a few cycles.
EV82_WAIT_TITLE | popup title | The dock fills up
EV82_WAIT | popup | One hull waited and others stacked behind it. Lanes that touch Tillam cost more per trip for a few cycles. The rim taught your crew to wait. It never taught them to like it.

EV83_TITLE | pool event title | One patrol, two ends
EV83_BODY | pool event text | A patrol cutter can hold one end of a lane for a while. Traders go where the line is watched. Voltara's dock or Flintmoor's yard gets it. The other keeps its own luck, and says so.
EV83_VOLT_BTN | button | Watch Voltara
EV83_VOLT_EFF | effect line | Blast powder at Voltara costs more and pays more for a while.
EV83_VOLT_TITLE | popup title | A watched dock
EV83_VOLT | popup | Traders at Voltara saw the patrol light and stayed late. Blast powder at Voltara costs more and pays more for a while. The patrol never looked at the cargo, only at the people.
EV83_FLINT_BTN | button | Watch Flintmoor
EV83_FLINT_EFF | effect line | Energy at Flintmoor costs more and pays more for a while.
EV83_FLINT_TITLE | popup title | A watched yard
EV83_FLINT | popup | Traders at Flintmoor saw the patrol light and unloaded without checking the door twice. Energy at Flintmoor costs more and pays more for a while. The cutter's lamp stayed on all shift.

EV84_TITLE | pool event title | A rim crew pays a debt
EV84_BODY | pool event text | A crew you once carried home pays what they owe. They offer credits, or a hold of blast powder left at Flintmoor. They do not ask which you prefer. They only ask that it be taken.
EV84_CASH_BTN | button | Take the credits
EV84_CASH_EFF | effect line | You gain a small sum.
EV84_CASH_TITLE | popup title | The debt is paid
EV84_CASH | popup | The credits came in a worn bag. You counted them once and nodded once. You gain a small sum.
EV84_GOODS_BTN | button | Take the powder
EV84_GOODS_EFF | effect line | Some blast powder is added to your Company storage at Flintmoor.
EV84_GOODS_TITLE | popup title | The powder is stacked
EV84_GOODS | popup | The crew loaded the sacks themselves. Some blast powder is added to your Company storage at Flintmoor. You walked the shelf twice afterwards.

EV85_TITLE | pool event title | A convoy arrives all at once
EV85_BODY | pool event text | A convoy that was late came in all at once at Voltara, every hold full of powder. Blast powder at Voltara costs less and pays less. The lane keeps its notes and moves on. Bad news is only news.

EV_FLT03_TITLE | pool event title | A toll on the lane
EV_FLT03_BODY | pool event text | A patrol cutter hails the Flagship. It says the lane to Quillon is private and has been since the cutter was painted. A toll is asked, politely. The cutter's gun looks at the toll, not at you. Your ships use the same lane.
EV_FLT03_PAY_BTN | button | Pay the toll
EV_FLT03_PAY_EFF | effect line | Pay a small sum. The lane stays as it is.
EV_FLT03_PAY_TITLE | popup title | The toll is paid
EV_FLT03_PAY | popup | You paid a small sum and the cutter blinked twice, which is how it says thank you. The gun turned away last, like someone leaving a room backwards.
EV_FLT03_AROUND_BTN | button | Take the wide way
EV_FLT03_AROUND_EFF | effect line | Lanes that touch Quillon cost more per trip for a few cycles.
EV_FLT03_AROUND_TITLE | popup title | The wide way
EV_FLT03_AROUND | popup | Your ships swung wide around a lane that was private by decree. Lanes that touch Quillon cost more per trip for a few cycles. The cutter followed for a while, to see that the sky was not borrowed.

EV91_TITLE | pool event title | Cindrel closes for a drill
EV91_BODY | pool event text | Cindrel's range officer called a drill and cleared every dock to run it. The drill is real, the officer says. The port is closed for a while, and routes touching Cindrel are blocked. The sirens ran a full day. No one learned what they were practising against.

EV92_TITLE | pool event title | Two buyers want one convoy
EV92_BODY | pool event text | Two buyers sent word on the same morning, each sure the rivets were meant for them. One sits at Quillon, behind a desk. One sits at Cindrel, behind a gun rack. A convoy can answer one of them first. The other will say it understands.
EV92_QUILLON_BTN | button | Answer Quillon
EV92_QUILLON_EFF | effect line | Rivets at Quillon cost more and pay more for a while.
EV92_QUILLON_TITLE | popup title | Quillon is answered
EV92_QUILLON | popup | The convoy turned toward Quillon's desks. Rivets there cost more and pay more for a while. The buyer at Cindrel sent a note that said it understood, and the note was very neat.
EV92_CINDREL_BTN | button | Answer Cindrel
EV92_CINDREL_EFF | effect line | Rivets at Cindrel cost more and pay more for a while.
EV92_CINDREL_TITLE | popup title | Cindrel is answered
EV92_CINDREL | popup | The convoy turned toward Cindrel's gun racks. Rivets there cost more and pay more for a while. The desk at Quillon logged the delay and kept the page.

EV93_TITLE | pool event title | The Fleet Office pays in kind
EV93_BODY | pool event text | A Fleet Office clerk settles an old account at Quillon. The estimate allows credits, or a lot of rivets from the depot shelf. The clerk does not say which the estimate prefers. The clerk says that is for the next estimate.
EV93_CASH_BTN | button | Take the credits
EV93_CASH_EFF | effect line | You gain a small sum.
EV93_CASH_TITLE | popup title | The account is settled
EV93_CASH | popup | The clerk stamped a slip and counted out credits in worn notes. You gain a small sum. The stamp was dry, and the clerk pressed it anyway.
EV93_GOODS_BTN | button | Take the rivets
EV93_GOODS_EFF | effect line | Some rivets are added to your Company storage at Quillon.
EV93_GOODS_TITLE | popup title | The shelf is emptied
EV93_GOODS | popup | Depot hands rolled out the rivet crates and stacked them in your bay at Quillon. Some rivets are added to your Company storage there. The clerk counted them off in the same voice as the credits.

## Luxury pool

EV44_TITLE | pool event title | A rich cut at Brannock
EV44_BODY | pool event text | A cutter at Brannock found a flaw that makes every gem in the case look finer, and the case sold out by noon. Gems at Brannock cost more and pay more. Nobody can find the flaw again. The cutter has stopped trying to look.

EV45_TITLE | pool event title | Attar floods Quillon
EV45_BODY | pool event text | A convoy of attar reached Quillon on one tide, and the perfumers' guild took no stock of it. Attar at Quillon costs less and pays less. Every stall smells of a different promise. The guild counts it as one scent and sends no one to check.

EV76_TITLE | pool event title | Lunch at a buyer's table
EV76_BODY | pool event text | A broker buys lunch for a Voltara buyer and leaves with the buyer's order in his head. Hothouse blooms at Voltara cost more and pay more. The buyer thinks it was a coincidence. The broker's smile is the first thing anyone recalls.

EV77_TITLE | pool event title | An old broker wants thanks
EV77_BODY | pool event text | A broker who says he taught you everything wants to be thanked. His friends sit at Ashgate's dock, and they are patient. Thank him in credits, or let them sell low at Ashgate for a while.
EV77_THANK_BTN | button | Thank him
EV77_THANK_EFF | effect line | Pay a small sum.
EV77_THANK_TITLE | popup title | A warm farewell
EV77_THANK | popup | The broker took the credits and the credit, and told everyone at Ashgate what a fine pupil he had. You paid a small sum.
EV77_SKIP_BTN | button | Smile and go
EV77_SKIP_EFF | effect line | Hothouse blooms at Ashgate cost less and pay less for a while.
EV77_SKIP_TITLE | popup title | The friends sell low
EV77_SKIP | popup | The broker's friends sold blooms at Ashgate for what they fetched. Hothouse blooms at Ashgate cost less and pay less for a while. You kept the smile. It is the only thing you kept.

EV78_TITLE | pool event title | The board shows two gaps
EV78_BODY | pool event text | You read two price boards and see a gap on each. You can whisper one gap to one buyer. Whoever hears it first pays more for a while, and the other gap closes by itself. The board at Tillam is longer. Ashgate's is louder.
EV78_TILLAM_BTN | button | Tell the Tillam buyer
EV78_TILLAM_EFF | effect line | Musk at Tillam costs more and pays more for a while.
EV78_TILLAM_TITLE | popup title | The Tillam buyer nods
EV78_TILLAM | popup | The Tillam buyer nodded and said nothing. Musk at Tillam costs more and pays more for a while. Prices moved by the next bell, and nobody said by whose hand.
EV78_ASHGATE_BTN | button | Tell the Ashgate buyer
EV78_ASHGATE_EFF | effect line | Hothouse blooms at Ashgate cost more and pay more for a while.
EV78_ASHGATE_TITLE | popup title | The Ashgate buyer writes
EV78_ASHGATE | popup | The Ashgate buyer wrote it on a napkin and left a large tip for lunch. Hothouse blooms at Ashgate cost more and pay more for a while.

EV79_TITLE | pool event title | A gift from a grateful buyer
EV79_BODY | pool event text | A buyer you once let win a deal sends a crate with a note. The note says it is a gift, not payment. Gifts are polite to accept. Credits are lighter to carry. The crate is hothouse blooms, waiting at Ashgate.
EV79_CASH_BTN | button | Take the credits
EV79_CASH_EFF | effect line | You gain a small sum.
EV79_CASH_TITLE | popup title | Credits and a smile
EV79_CASH | popup | The buyer sent credits instead, and a second note thanking you for understanding. You gain a small sum.
EV79_GOODS_BTN | button | Take the blooms
EV79_GOODS_EFF | effect line | Some hothouse blooms are added to your Company storage at Ashgate.
EV79_GOODS_TITLE | popup title | A crate of blooms
EV79_GOODS | popup | The crate reached Ashgate with a ribbon on it. Some hothouse blooms are added to your Company storage there. The ribbon was the buyer's. It stayed on the crate.

EV80_TITLE | pool event title | Mossfell has seen the smile
EV80_BODY | pool event text | A broker's smile has been seen too often at Mossfell. Buyers now wait for his price to drop before they pay. Hothouse blooms at Mossfell cost less and pay less. The broker takes it as a compliment.

EV94_TITLE | pool event title | The gala sends a bill
EV94_BODY | pool event text | The house that held last season's gala sends your crew a bill for the sleeves they borrowed. The sum is small and the tone is warm. The house keeps a long memory for sleeves. Pay now, or let the house tell the story at Brannock's looms.
EV94_PAY_BTN | button | Pay the bill
EV94_PAY_EFF | effect line | Pay a small sum.
EV94_PAY_TITLE | popup title | The bill is paid
EV94_PAY | popup | You paid a small sum. The house wrote a receipt in violet ink and sent the sleeves back, pressed. Nobody in your crew will say who wore which.
EV94_TELL_BTN | button | Let the house talk
EV94_TELL_EFF | effect line | Silk at Brannock costs less and pays less for a while.
EV94_TELL_TITLE | popup title | The story gets round
EV94_TELL | popup | The house told the story at Brannock's looms, with gestures. Weavers laughed into their sleeves, and silk at Brannock costs less and pays less for a while. The bill is still on file.

EV95_TITLE | pool event title | Brannock's dyers run dry
EV95_BODY | pool event text | Brannock's dye vats ran dry mid-batch, and the dyers asked for musk to fix the colour. Nobody will say what musk has to do with colour. Musk at Brannock costs more and pays more. The cloth came out the same shade, only warmer.

EV96_TITLE | pool event title | Two orders at the counter
EV96_BODY | pool event text | Two orders reach the Voltara counter in one hour, and the case has room for one display. One buyer wants attar, one wants gems. Whichever is set out first draws the crowd. The other buyer will wait, and watch the case.
EV96_ATTAR_BTN | button | Set out the attar
EV96_ATTAR_EFF | effect line | Attar at Voltara costs more and pays more for a while.
EV96_ATTAR_TITLE | popup title | The attar is shown
EV96_ATTAR | popup | The attar went under the lamp and the crowd leaned in. Attar at Voltara costs more and pays more for a while. The buyer of gems studied the empty velvet beside it.
EV96_GEMS_BTN | button | Set out the gems
EV96_GEMS_EFF | effect line | Gems at Voltara cost more and pay more for a while.
EV96_GEMS_TITLE | popup title | The gems are shown
EV96_GEMS | popup | The gems went under the lamp and the crowd went still. Gems at Voltara cost more and pay more for a while. The buyer of attar left a scented card in the case.

## Minerals pool

EV48_TITLE | pool event title | Plate runs short at Quillon
EV48_BODY | pool event text | Quillon's builders wanted plate for a hall that has no plan, and every sheet in the yard was spoken for by noon. Plate at Quillon costs more and pays more. The hall is drawn on a wall and not on paper. Someone keeps adding rooms.

EV70_TITLE | pool event title | A note from the old yard
EV70_BODY | pool event text | A man you once paid for spare parts sends a note. Cinderrest wants dross before the next shift, and he gives no reason. Dross at Cinderrest costs more and pays more for a while. The note is signed twice, in two hands that do not match.

EV71_TITLE | pool event title | The count is off by a crate
EV71_BODY | pool event text | The yard counts your spare parts and finds one crate more than the page says. You will not keep what is not written down. The yard pays you for it, in credits or in ore left at Voltara.
EV71_CASH_BTN | button | Take the credits
EV71_CASH_EFF | effect line | You gain a small sum.
EV71_CASH_TITLE | popup title | Credits, counted twice
EV71_CASH | popup | The clerk counted the credits out twice, and so did you. The page and the crate now agree. You gain a small sum.
EV71_ORE_BTN | button | Take the ore
EV71_ORE_EFF | effect line | Some ore is added to your Company storage at Voltara.
EV71_ORE_TITLE | popup title | Ore, on the shelf
EV71_ORE | popup | The crate was swapped for sacks of ore. Some ore is added to your Company storage at Voltara. You checked every seal before you signed.

EV72_TITLE | pool event title | A clerk wants every bolt
EV72_BODY | pool event text | A Bureau clerk at Ashgate wants to check every part aboard. Your books are in order and you say so. The check takes days either way. A fee hurries it. Or the line grows at the dock.
EV72_PAY_BTN | button | Pay to hurry it
EV72_PAY_EFF | effect line | Pay a small sum. The check ends today.
EV72_PAY_TITLE | popup title | The clerk is quick
EV72_PAY | popup | The clerk stamped the last page and did not look up. You paid a small sum, and filed the receipt first.
EV72_WAIT_BTN | button | Let the line grow
EV72_WAIT_EFF | effect line | Lanes that touch Ashgate cost more per trip for a few cycles.
EV72_WAIT_TITLE | popup title | The dock is full
EV72_WAIT | popup | Ships stacked up outside Ashgate. Nobody left, and nobody was told when. Lanes that touch Ashgate cost more per trip for a few cycles.

EV73_TITLE | pool event title | One crew, two docks
EV73_BODY | pool event text | You can lend a work crew to one dock for a short time. Cindrel's yard would run hot. Quillon's would run light. Both owe you a favour. The dock that gets the crew sees trade pick up for a while.
EV73_CINDREL_BTN | button | Send them to Cindrel
EV73_CINDREL_EFF | effect line | Ore at Cindrel costs more and pays more for a while.
EV73_CINDREL_TITLE | popup title | Cindrel's yard is busy
EV73_CINDREL | popup | The crew worked two shifts at Cindrel. Ore there costs more and pays more for a while. The yard master wrote the favour in a small book.
EV73_QUILLON_BTN | button | Send them to Quillon
EV73_QUILLON_EFF | effect line | Ore at Quillon costs more and pays more for a while.
EV73_QUILLON_TITLE | popup title | Quillon's yard is busy
EV73_QUILLON | popup | The crew worked easy hours at Quillon. Ore there costs more and pays more for a while. The yard master paid back in goodwill, which you also count.

EV74_TITLE | pool event title | Luck pays Ashgate once
EV74_BODY | pool event text | A shipment of dross reaches Ashgate by a mistake nobody owns. Dross at Ashgate costs less and pays less for a while. You call it luck, and do not trust it. The second page of the manifest is blank.

EV_FLT04_TITLE | pool event title | Dust across the lane
EV_FLT04_BODY | pool event text | Fine dust crosses the lane to Flintmoor and rattles on the hull like rain on a tin roof. The pilot slows, then asks if she may ask what rain is. Nobody on board is sure. Ships can slow with her, or push through and pay for the hull.
EV_FLT04_SLOW_BTN | button | Slow down
EV_FLT04_SLOW_EFF | effect line | Lanes that touch Flintmoor cost more per trip for a few cycles.
EV_FLT04_SLOW_TITLE | popup title | The dust passes
EV_FLT04_SLOW | popup | The ships slowed and the dust went over like a long shift change. Lanes that touch Flintmoor cost more per trip for a few cycles. The hull rang once, low, and then did not ring again.
EV_FLT04_PUSH_BTN | button | Push through
EV_FLT04_PUSH_EFF | effect line | Pay a small sum for hull repairs.
EV_FLT04_PUSH_TITLE | popup title | The hull takes the dust
EV_FLT04_PUSH | popup | The ships pushed through at speed. You paid a small sum for hull repairs at the next port. The pilot stood the rest of the shift at the glass, trying to remember what rain was for.

EV_PLT01_TITLE | pool event title | Who works the dark
EV_PLT01_BODY | pool event text | A crew from the Bureau's labour desk reaches the new platform on Cinderrest. They came for the pay and stay for the quiet. The foreman asks what to call a shift that never ends. No one has a form for it.
EV_PLT01_NIGHT_BTN | button | Hire the night crew
EV_PLT01_NIGHT_EFF | effect line | Some dross is added to your Company storage at Cinderrest.
EV_PLT01_NIGHT_TITLE | popup title | The night crew signs on
EV_PLT01_NIGHT | popup | The night crew signed on without reading. By morning some dross lay in your storage at Cinderrest, stacked with great care. The foreman named the shift Always. It stuck.
EV_PLT01_DAY_BTN | button | Send the crew home
EV_PLT01_DAY_EFF | effect line | You gain a small sum, the labour desk's refund.
EV_PLT01_DAY_TITLE | popup title | The crew goes home
EV_PLT01_DAY | popup | You sent the crew back to the labour desk, which refunded the hire with a small sum. You gain a small sum. At change of shift the foreman counted the lamps going out and the lamps coming on, and got two different answers.

EV_PLT02_TITLE | pool event title | The roof sings
EV_PLT02_BODY | pool event text | A gallery at Cinderrest sings before it fails, a low note, held. The crew is out and the rock is still. Props cost credits. Sealing the gallery costs time. The note has not stopped.
EV_PLT02_PROP_BTN | button | Pay for props
EV_PLT02_PROP_EFF | effect line | Pay a small sum. Routes from Cinderrest keep running.
EV_PLT02_PROP_TITLE | popup title | The props go in
EV_PLT02_PROP | popup | The props went in under the sound and the sound let them. You paid a small sum. Routes from Cinderrest keep running. The note dropped a step, the way a voice does when it has been understood.
EV_PLT02_SEAL_BTN | button | Seal the gallery
EV_PLT02_SEAL_EFF | effect line | Cinderrest closes for a while. Routes touching it are blocked.
EV_PLT02_SEAL_TITLE | popup title | The gallery is sealed
EV_PLT02_SEAL | popup | The crew sealed the gallery with slabs and tape. Cinderrest is closed for a while, and routes touching it are blocked. Behind the slabs the note went on, patient, like a tenant.

EV_PLT03_TITLE | pool event title | A seam no one logged
EV_PLT03_BODY | pool event text | The drill at Greywake broke into a seam the old surveys never entered, as if they had looked away. It is bright, cold and heavier than it should be. The Bureau has not been told yet.
EV_PLT03_LOG_BTN | button | Log the find
EV_PLT03_LOG_EFF | effect line | You gain a small sum as a finder's share.
EV_PLT03_LOG_TITLE | popup title | The find is logged
EV_PLT03_LOG | popup | The Bureau stamped the find within the hour, which no one had ever seen. You gain a small sum as a finder's share. The seam now has a number, and the number, quietly, has a seam.
EV_PLT03_HIDE_BTN | button | Keep it off the books
EV_PLT03_HIDE_EFF | effect line | Some nullglass is added to your Company storage at Greywake.
EV_PLT03_HIDE_TITLE | popup title | The find stays quiet
EV_PLT03_HIDE | popup | The crew filled the carts before the shift bell and told no one. Some nullglass is added to your Company storage at Greywake. The seam is still bright in the dark, and still cold on the hand.

EV_PLT04_TITLE | pool event title | The hum under the floor
EV_PLT04_BODY | pool event text | The floor of the platform on Greywake hums while the crew sleeps, a steady note, the same each night. Two buyers want the next lot of nullglass, one at Cindrel and one at Quillon. The shift lead says the hum changes with the lot's road. She does not say how.
EV_PLT04_CINDREL_BTN | button | Send the lot to Cindrel
EV_PLT04_CINDREL_EFF | effect line | Nullglass at Cindrel costs more and pays more for a while.
EV_PLT04_CINDREL_TITLE | popup title | The lot goes to Cindrel
EV_PLT04_CINDREL | popup | The lot left for Cindrel and the hum thinned, then stopped. Nullglass at Cindrel costs more and pays more for a while. The shift lead slept well.
EV_PLT04_QUILLON_BTN | button | Send the lot to Quillon
EV_PLT04_QUILLON_EFF | effect line | Nullglass at Quillon costs more and pays more for a while.
EV_PLT04_QUILLON_TITLE | popup title | The lot goes to Quillon
EV_PLT04_QUILLON | popup | The lot left for Quillon and the hum rose a note. Nullglass at Quillon costs more and pays more for a while. The engineers wrote down that it was not louder.

## Biotech pool

EV51_TITLE | pool event title | Seed stock sells out at Brannock
EV51_BODY | pool event text | A planting season came early at Brannock, and every grower wanted seed stock before the frost. Seed stock at Brannock costs more and pays more. The growers say the frost will not come. They keep one eye on the sky and one on the lock.

EV88_TITLE | pool event title | Two clerks ask a favour
EV88_BODY | pool event text | A clerk at Tillam and a clerk at Ashgate both ask you to put in a word for their dock. You know them both by name. You can do it for one this cycle. The other will understand, and remember.
EV88_TILLAM_BTN | button | Speak for Tillam
EV88_TILLAM_EFF | effect line | Spores at Tillam cost more and pay more for a while.
EV88_TILLAM_TITLE | popup title | Tillam is pleased
EV88_TILLAM | popup | The Tillam clerk bowed twice. Spores at Tillam cost more and pay more for a while. A queue of buyers formed by the next bell.
EV88_ASHGATE_BTN | button | Speak for Ashgate
EV88_ASHGATE_EFF | effect line | Spores at Ashgate cost more and pay more for a while.
EV88_ASHGATE_TITLE | popup title | Ashgate is pleased
EV88_ASHGATE | popup | The Ashgate clerk sent a card and a plate of something sweet. Spores at Ashgate cost more and pay more for a while.

## Minerals pool, one more (EV75)

EV75_TITLE | pool event title | Quillon stops paying for ore
EV75_BODY | pool event text | Quillon's builders found a stack of ore in a closed yard and stopped buying. Ore at Quillon costs less and pays less for a while. The yard's gate was sealed with a form that no one remembers signing. The ore is warm.

## Production charter events (T370, 2026-11-12; pool choice events, mechanics in data/chains.json by the gameplay agent, once per run)

EV97_TITLE | pool event title | The depot wants a yard
EV97_BODY | pool event text | The Bureau's depot office will name one of your worlds a supply yard. A yard buys more each shift, and the stamp costs. The clerk has the form filled in except for the world. He taps the blank line and waits.
EV97_SIGN_BTN | button | Sign the requisition
EV97_SIGN_EFF | effect line | You gain a production charter and pay a small fee.
EV97_SIGN_TITLE | popup title | The form is signed
EV97_SIGN | popup | You signed, and the clerk stamped the page before the ink was dry. You gain a production charter and pay a small fee. Open a world's card to name the yard. The clerk will check the blank line.
EV97_LAPSE_BTN | button | Let the form lapse
EV97_LAPSE_EFF | effect line | You gain a small sum.
EV97_LAPSE_TITLE | popup title | The form lapses
EV97_LAPSE | popup | You left the line blank. The clerk sighed, filed the form under lapsed, and paid out a small sum for the trouble. You gain a small sum. He wrote the date on the folder, in case.

EV98_TITLE | pool event title | A patron picks a house
EV98_BODY | pool event text | A patron wants one world to carry her name, and every buyer there to stock for her. She pays nothing. She asks only that her rivals be told. Somewhere a broker is already drafting the list.
EV98_ACCEPT_BTN | button | Accept the patronage
EV98_ACCEPT_EFF | effect line | You gain a production charter. A home Luxury good costs less and pays less for a while.
EV98_ACCEPT_TITLE | popup title | The patron is pleased
EV98_ACCEPT | popup | The patron nodded once. You gain a production charter, and a Luxury good at your home world costs less and pays less for a while. Her rivals were told by evening. They sent no reply.
EV98_DECLINE_BTN | button | Decline politely
EV98_DECLINE_EFF | effect line | You gain a small sum.
EV98_DECLINE_TITLE | popup title | The offer is declined
EV98_DECLINE | popup | You declined, and she took it well, which was worse. A small sum arrived the next day, with a card. You gain a small sum. The card has no name on it.
