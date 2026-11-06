# Events, system 1 (draft 2, tone rework)

Format: ID | title (max 32) | tag | kind, then text (max 280). Appears in the event popup under "News from the sky" (NOT_EVENT_PREFIX), with an OK button (BTN_OK).
Tags are from the brief only: [price up: planet, commodity], [price down: ...], [planet closed: planet]. Effect size and duration are the Economy Designer's. Planet closed means closed for a while; routes touching it are blocked. The Plan, quotas and the Bureau are story only and change nothing.
Kind: P = plain price news, Q = quiet musing, I = ironic. Dread = one small odd detail.

## Chain placeholders (market chains, ids EV_<step>_..., text in story/screens.md; added 2026-11-03)

The game fills these in chain text. No text contains a digit; every number comes from a placeholder.

| Placeholder | Filled with | Used in |
|---|---|---|
| {bot1}, {bot2}, {bot3} | Display names of the three rivals (bot_1 Harrow Combine, bot_2 Velvet Concord, bot_3 Ostrel Syndicate), from STD_BOT1_NAME to STD_BOT3_NAME. Never hard-coded in chain text, so a rename needs no text edit. | bodies, effect lines, results, rival lines |
| {bot} | The marked bot of the option just chosen (R7: biggest CUT, boosts never count, tier cut counts as clearly, strength and growth count the same, a tie goes to the lower bot number). Table below. In a result text it always names a bot the option cut. In a step 2+ body of Military B4 it names the marked bot of the previous Military step. | results, MIL_B4 bodies |
| {cash_in}, {cash_out} | Credits gained or paid by the option, number only (150, 300 or 600 from economy 8.1). | effect lines |
| {n} | Units of tech progress the option gives, number only (3 or 4). | effect lines |
| {cut} | In an effect line: "drops a tier", or "loses strength clearly" when that rival is at the lowest tier. Sentence shape: "<Bot> {cut} in <Market>." | effect lines |
| {cut_std} | In a rival line: "moved down a tier", or "strength down clearly" at the lowest tier. | rival lines (_STD) |
| {market} | Market display name. | EV_EFF_NO_RIVALS, pool rivals lines, log lines, epilogue lines |
| {get}, {cost}, {rivals} | Phrases for the template CH_EFFECT_LINE (Get / Cost / Rivals, 200 characters). Same size words as the written effect lines. Only for lines the game builds itself; the written EV_<step>_OP?_EFF lines are final and need no template. | CH_EFFECT_LINE |
| {workshop}, {share}, {bots} | As in story/voice.md. | endings |

Size words (fixed): volume, price and upkeep up or down 5 or 8 or 20 percent or one trip cost of a third = "a little"; 10 or 15 or 40 percent = "clearly". Rival strength 5 percent or growth 10 percent = "a little"; strength 10 percent or growth 20 percent = "clearly"; strength 18 percent or growth 30 percent = "sharply". A tier cut is only ever {cut} or {cut_std}. A boost to a rival is a Cost and reads "gains a little <Market> strength" or "grows a little faster in <Market>"; the matching rival line says "strength up a little" or "growth up a little". Durations: 2 to 3 cycles "for a few cycles", 4 to 8 cycles "for a while", to cycle 40 "for the rest of the run". A timed rival hit says "for a few cycles".

Rival effect is visible in every step three ways: the effect line (Rivals part), the result text (the marked bot as {bot}, other changed rivals by {bot1} to {bot3}) and one or two rival lines (_STD, _STD2) shown under the result and written into the Competitors log (LBL_COMP_MOVE_*). Cuts come before boosts in the rival lines. The tier result text says "cut back", which is true at any tier; the rival line carries {cut_std}.

Marked bot per option (R7), computed by hand from economy 8.2; the game computes it itself and must agree:

| Step | opt_a {bot} | opt_b {bot} |
|---|---|---|
| MIL_A1 | Harrow Combine | Harrow Combine |
| MIL_A2 | Ostrel Syndicate | Harrow Combine |
| MIL_A3 | Harrow Combine | Harrow Combine |
| MIL_B1 | Harrow Combine | Ostrel Syndicate |
| MIL_B2 | Velvet Concord | Harrow Combine |
| MIL_B3 | Ostrel Syndicate | Harrow Combine |
| MIL_B4 | Harrow Combine | Harrow Combine |
| LUX_A1 | Velvet Concord | Ostrel Syndicate |
| LUX_A2 | Velvet Concord | Velvet Concord |
| LUX_A3 | Velvet Concord | Ostrel Syndicate |
| LUX_B1 | Velvet Concord | Velvet Concord |
| LUX_B2 | Ostrel Syndicate | Velvet Concord |
| LUX_B3 | Velvet Concord | Harrow Combine |
| LUX_B4 | Velvet Concord | Velvet Concord |
| MIN_A1 | Harrow Combine | Harrow Combine |
| MIN_A2 | Ostrel Syndicate | Harrow Combine |
| MIN_A3 | Harrow Combine | Harrow Combine |
| MIN_B1 | Harrow Combine | Harrow Combine |
| MIN_B2 | Ostrel Syndicate | Harrow Combine |
| MIN_B3 | Harrow Combine | Harrow Combine |
| MIN_B4 | Harrow Combine | Harrow Combine |
| BIO_A1 | Velvet Concord | Velvet Concord |
| BIO_A2 | Ostrel Syndicate | Velvet Concord |
| BIO_A3 | Velvet Concord | Velvet Concord |
| BIO_B1 | Velvet Concord | Ostrel Syndicate |
| BIO_B2 | Velvet Concord | Ostrel Syndicate |
| BIO_B3 | Velvet Concord | Velvet Concord |
| BIO_B4 | Velvet Concord | Velvet Concord |

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
EV21 | Tillam's weavers down tools | [price up: Tillam, silk] | I
Tillam's silk weavers downed tools over a form that counted their hours twice. Silk at Tillam costs more and pays more. An old weaver says to watch the cricket in the vat, which changes shape when it sees another. Fine Finishing makes a Luxury price rise pay clearly more.

EV22 | Voltara holds a gala | [price up: Voltara, silk] | I
Voltara's crews hold a gala to celebrate a quota met on paper. Silk at Voltara costs more and pays more. Everyone borrows a sleeve and a mask, and by the second hour the crews look alike. Patron's List counts sales here as clearly more Luxury share.

EV24 | Fire in Voltara's foundry | [price up: Voltara, spyware] | P
A fire swept Voltara's core foundry and left the casting floor black. Logic cores at Voltara cost more and pay more. The report calls it a gentle step toward a better line. Ash settled on the walls in neat rows. Nobody has dared to read them.

EV25 | Ashgate recalls its tractors | [price up: Ashgate, spyware] | Q
Ashgate recalled its farm tractors to be retrained as safe. Logic cores at Ashgate cost more and pay more. The retrained ones freeze when two foremen give opposite orders. The old ones were told to keep quiet and keep going, and they do. They do not look at you.

EV26 | A rich seam is logged twice | [price down: Voltara, ore] | Q
A survey crew found a rich seam and logged it in two offices, so it is counted twice and sold twice. Ore at Voltara costs less and pays less while the news is fresh. With Smelting, ore orders ignore the size cap, so a cheap week can be a big one.

EV28 | Voltara's foundry wants rock | [price up: Voltara, ore] | P
Voltara's foundry ordered more rock than the Plan had dreamed of. Ore at Voltara costs more and pays more. Every shortcut the founders took lies under the furnace floor, and the furnace wants more. Prospecting lets routes start at asteroid clusters, where the rock is free.

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

## Solar shield [shield built: affects only planets the player can buy later; residents unhappy]
EV18_TITLE | choice title | Shade the sun
EV18_BODY | choice body | Chief engineer Ilya Sorn wants to shade part of the sun. The residents wrote to say no, at length. The shield would change markets on planets you can buy later: some goods get cheaper, profit and energy rise. Planets you own stay as they are.
EV18_BUILD_BTN | button | Build the shield
EV18_BUILD_EFF | effect line | Planets you can buy later change: some resources drop, profit and energy rise.
EV18_SKIP_BTN | button | Leave the sun alone
EV18_SKIP_EFF | effect line | Nothing changes. The sun keeps its full light.
EV18_BUILT_TITLE | popup title | The shield is up
EV18_BUILT | popup | The shield is up and the sky is dim. Residents filed their anger in triplicate, by lamp. On planets you can buy later, some goods get cheaper while profit and energy climb. Planets you own are untouched. Sorn will not look up.
EV18_SKIPPED_TITLE | popup title | The shield stays on paper
EV18_SKIPPED | popup | The plans went back in a drawer. Residents are relieved and sent no thanks. Nothing changes in any market. Sorn asked what the rush had been. No one answered, and the drawer stayed shut.

## Nomads and pirates [choice: evict nomads or let them stay; pirates reduce trade volume; hire to clear pirates, at a cost]
EV19_TITLE | choice title | Nomads on the asteroids
EV19_BODY | choice body | Nomad families live on the asteroids you could mine. They are not on the Common Ledger, so to the Bureau they do not exist. They count their people by who shares the meal. Evict them and the rock is yours. Or let them stay.
EV19_EVICT_BTN | button | Evict the nomads
EV19_EVICT_EFF | effect line | The asteroids open for mining. Some nomads turn to piracy, and pirates rise.
EV19_STAY_BTN | button | Let them stay
EV19_STAY_EFF | effect line | The asteroids stay closed to mining. No pirates come of it.
EV19_EVICTED_TITLE | popup title | The asteroids are cleared
EV19_EVICTED | popup | The nomads left on the next tide and said nothing. The rock is yours to mine. Some did not go far. They keep ships now, and a grudge. Pirates rise. Their tables were left set.
EV19_STAYED_TITLE | popup title | The nomads stay
EV19_STAYED | popup | You let the nomads stay. Their lamps burn on the rock, small and steady. A woman brought the first crew to dock a bowl of something hot. The asteroids stay closed to mining.
EV19_PIRATES_TITLE | popup title | Pirates reduce trade
EV19_PIRATES | popup | Pirates now work the lanes and fewer cargoes get through. Trade volume falls while they stay. The Bureau opened a file on them. It is thin, like the fleet behind it. Every late ship now has a reason.
EV19_HIRE_BTN | button | Hire a clearance crew
EV19_HIRE_EFF | effect line | Pay to have the pirates cleared. It costs credits and removes their effect on trade.

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

# Choice events (branching) (draft 1, 2026-11-02)

Three story events with 2 or 3 choices. Each choice fires one tag the code already applies now (price up, price down, planet closed; size and duration from balance). Each choice also queues a short follow-up event, which needs one NEW mechanism (request R1 below). Limits as the choice screen: title 40, body 280, button 28, effect line 90; popups: title 32, text 280. No numbers. Tags are the engine tags, copied in the form events.gd parses.
Gates (requests R2, R3): BE01 and BE03 are system 1 only, from cycle 9. BE02 needs system 2 reached and uses silk (system 2 only). Follow-up ids end in A, B, C and are never picked at random (R1).

Requests for the gameplay programmer (new, not in the code today):
R1. Follow-up: a choice may carry "follow_id" and "follow_after" (suggest 4 cycles, economy designer sets the key). When that many cycles pass, the follow-up fires as a plain event (existing popup, its own tag, OK button). Follow-ups have "random": false and stay out of random_id(). Save pending follow-ups in the events state (id, cycle due).
R2. "min_cycle" 9 on BE01 and BE03 (already supported by the json key).
R3. "requires_system": 2 on BE02: not picked until the player has system 2. Not supported today.
R4. Choice events with 3 choices: the choice screen must show three buttons (EV17 to EV20 have two).

## BE01 Tillam's sealed granary [3 choices, system 1]
BE01_TITLE | choice title | Tillam's sealed granary
BE01_BODY | choice body | Tillam keeps grain behind a lock only the committee can open. Winter is close and the stores outside are thin. The committee will open it for a company that carries the grain out, and wants an answer today. The queue has not moved since dawn.
BE01_OPEN_BTN | button | Open it to the crowd
BE01_OPEN_EFF | effect line | Food at Tillam costs less and pays less for a while. Tillam remembers.
BE01_SHUT_BTN | button | Keep the lock shut
BE01_SHUT_EFF | effect line | Food at Tillam costs more and pays more for a while. Tillam remembers.
BE01_SEND_BTN | button | Send it to Ashgate
BE01_SEND_EFF | effect line | Food at Ashgate costs less and pays less for a while. Ashgate remembers.
BE01_OPEN_TITLE | popup title | The granary opens
BE01_OPEN | popup | The lock gave way. The grain went out by hand, sack to sack, and no one in the line spoke. Food at Tillam costs less and pays less while stores are full. The committee recorded a loan. Nobody asked who owes whom.
BE01_SHUT_TITLE | popup title | The lock stays shut
BE01_SHUT | popup | You said no. The lock stayed on and the queue grew in the cold. Food at Tillam costs more and pays more while it is scarce. A child at the front sat on her bag and watched your ship. Inside the granary, something shifted.
BE01_SEND_TITLE | popup title | Grain goes to Ashgate
BE01_SEND | popup | The grain left Tillam by night. The loaders worked without lamps and did not look at you. Food at Ashgate costs less and pays less for a while. The committee at Tillam found the empty shelf and wrote a short, cold note.

[follow-up of BE01_OPEN, tag: price up: Tillam, energy]
BE01A_TITLE | popup title | Tillam burns bright for you
BE01A | popup | Tillam remembered the grain. Heaters on every terrace run high, and the committee calls it a gift. Energy at Tillam costs more and pays more for a while. The frost in the ducts has gone quiet, as if it was fed.

[follow-up of BE01_SHUT, tag: planet closed: Tillam]
BE01B_TITLE | popup title | Tillam closes its port
BE01B | popup | The queue that waited in the cold came down to the docks. Tillam's port is closed for a while, and routes touching Tillam are blocked. No one shouts. They stand in rows and watch your ships sit still.

[follow-up of BE01_SEND, tag: price up: Ashgate, energy]
BE01C_TITLE | popup title | Ashgate returns the favour
BE01C | popup | Ashgate remembered the grain. The foundries run hot in thanks and the smoke leans toward your ships. Energy at Ashgate costs more and pays more for a while. A foreman left a loaf at the dock. It was still warm.

## BE02 The beacon over Dunmere Reach [2 choices, system 2, silk]
BE02_TITLE | choice title | A beacon over Dunmere Reach
BE02_BODY | choice body | A beacon pulses over Dunmere Reach, from a rock no chart lists. Its pattern repeats, then changes, as if it heard the dock talk. The Bureau office at Quillon wants it logged and silenced. Your crews want to answer. Your ships pass it every cycle.
BE02_ANSWER_BTN | button | Answer the beacon
BE02_ANSWER_EFF | effect line | Silk at Quillon costs more and pays more for a while. Something answers back.
BE02_REPORT_BTN | button | Report it to the Bureau
BE02_REPORT_EFF | effect line | Quillon closes its port to check the sky. Routes touching Quillon are blocked for a while.
BE02_ANSWER_TITLE | popup title | The beacon is answered
BE02_ANSWER | popup | A crew sent a few pulses back. The beacon went dark, then lit again in the same order. Quillon's buyers heard, and bought silk as if a festival had been called. Silk there costs more and pays more. No one will say what the festival is for.
BE02_REPORT_TITLE | popup title | Quillon checks the sky
BE02_REPORT | popup | The Bureau filed the beacon as a fault and closed Quillon's port to inspect the sky. Routes touching Quillon are blocked for a while. The inspectors were polite. The beacon pulsed once, as if it had read the form.

[follow-up of BE02_ANSWER, tag: price up: Mossfell, food]
BE02A_TITLE | popup title | Visitors reach Mossfell
BE02A | popup | Small ships came in from the quiet rock and docked at Mossfell without papers. They want food and pay in odd, heavy coins. Food at Mossfell costs more and pays more for a while. They gave no names. They counted every crate twice, and watched your crew do it.

[follow-up of BE02_REPORT, tag: price down: Quillon, silk]
BE02B_TITLE | popup title | The inspection finds nothing
BE02B | popup | The inspectors found no fault and Quillon's port reopened. Stock held back for the check came out all at once. Silk at Quillon costs less and pays less for a while. The beacon is still up there. The report says it is not.

## BE03 A family offers cover [3 choices, system 1, Ashgate]
BE03_TITLE | choice title | A family offers cover
BE03_BODY | choice body | The family that bought Ashgate's food contracts sends a polite note. For a share, they will keep the docks quiet and the other traders out. They also mention how fragile a dock can be. Your crew read the note over your shoulder. No one spoke.
BE03_ACCEPT_BTN | button | Accept their cover
BE03_ACCEPT_EFF | effect line | Food at Ashgate costs more and pays more for a while. The family will call in the favour.
BE03_REFUSE_BTN | button | Refuse politely
BE03_REFUSE_EFF | effect line | Food at Ashgate costs less and pays less for a while. The family will wait.
BE03_REPORT_BTN | button | Report to the Bureau
BE03_REPORT_EFF | effect line | Ashgate closes its port for an audit. Routes touching Ashgate are blocked for a while.
BE03_ACCEPT_TITLE | popup title | The family keeps the docks
BE03_ACCEPT | popup | The family's people took the docks at dawn, in clean coats. Food at Ashgate costs more and pays more, since their prices came with them. The docks are quiet. Your crew lower their voices there. A quiet dock has an owner.
BE03_REFUSE_TITLE | popup title | The note is declined
BE03_REFUSE | popup | You sent back a polite no. The family sent back a polite nod. Food at Ashgate costs less and pays less as their buyers step back to watch. No one was threatened. Your crew check the locks twice each night.
BE03_REPORT_TITLE | popup title | The Bureau opens a file
BE03_REPORT | popup | The Bureau thanked you in writing and closed Ashgate's port for an audit. Routes touching Ashgate are blocked for a while. The audit will take its own time. The family has been told who filed.

[follow-up of BE03_ACCEPT, tag: planet closed: Ashgate]
BE03A_TITLE | popup title | The family calls its favour
BE03A | popup | The family closed Ashgate's docks to every ship but its own, and sent you the bill for the quiet. Routes touching Ashgate are blocked for a while. The note was courteous. A favour is a debt that keeps its place.

[follow-up of BE03_REFUSE, tag: price down: Ashgate, energy]
BE03B_TITLE | popup title | The family waits
BE03B | popup | The family did nothing, which was its answer. Its buyers stayed away from the furnaces, and energy at Ashgate costs less and pays less for a while. A courier sits in a booth on the dock, reading, never turning a page. He is there every shift.

[follow-up of BE03_REPORT, tag: price up: Ashgate, spyware]
BE03C_TITLE | popup title | The audit ends, parts are short
BE03C | popup | The audit ended and Ashgate's port is open. The family's contracts were frozen and the repair shops cannot get spares. Logic cores at Ashgate cost more and pay more for a while. The Bureau stamped the file closed. The family kept its copy.

# Events, dead worlds: retired (2026-11-03)

The old Minerals events EV29 to EV37 (three dead-world choice events and six follow-ups) are retired. Minerals chain A (MIN_A1 to MIN_A3) replaced them. Their text, banners and data entries are removed; ids EV29 to EV37 are not reused. See data/chains.json pool_retired.

# Events, shared pool EV40 to EV51 (added 2026-11-03)

Twelve one-time pool events for the new goods and workshops, three per market (Military EV40 to EV42, Luxury EV43 to EV45, Minerals EV46 to EV48, Biotech EV49 to EV51). Each fires once per run. They are NOT rows in data/events.json yet: the build writes only text ids (EV<nn>_TITLE max 32, EV<nn>_BODY max 280, EV<nn>_EFF max 90, the rivals line). The tag and kind sit in the table below for the economy and gameplay tasks that add the rows and the art. Planets are suggestions; the economy designer maps them to the planets that trade the good.
Tags updated 2026-11-04 to match data/chains.json pool_new (planets and goods as the game applies them). Pool events do carry a small bot effect there; the game builds the Rivals line itself (Chains.pool_rivals_line), so the EV<nn>_EFF lines below are not shown. Older note: pool events carry no bot effect (core 4.4), so every rivals line says that no rival changes. If a pool event ever gets a bot effect, rewrite its EV<nn>_EFF line first.

| Id | Tag | Kind |
|---|---|---|
| EV40 | [price down: Voltara, rivets] | P |
| EV41 | [price up: Ashgate, rounds] | Q |
| EV42 | [price up: Tillam, arms] | I |
| EV43 | [price down: Tillam, musk] | I |
| EV44 | [price up: Ashgate, gems] | Q |
| EV45 | [price down: Ashgate, attar] | P |
| EV46 | [price up: Voltara, ingot] | P |
| EV47 | [price down: Voltara, alloy] | I |
| EV48 | [price up: Ashgate, plate] | P |
| EV49 | [planet closed: Ashgate] | I |
| EV50 | [price down: Tillam, spores] | Q |
| EV51 | [price up: Tillam, seed] | Q |

EV40_TITLE | pool event title | Rivet guns pile up at Voltara
EV40_BODY | pool event text | Voltara's foundry kept casting rivet guns after the Admiralty's order was filled, since its last line reads until victory. Stacks reach the roof. Rivet guns at Voltara cost less and pay less. A clerk asked if victory knew. Contract Doctrine softens Military price events.
EV40_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV41_TITLE | pool event title | Pulse cells are recalled
EV41_BODY | pool event text | A batch of pulse cells ran hot, and the maker pulled the lot. An engineer read the recall on each dock and begged every crate's pardon. Pulse cells at Ashgate cost more and pay more while the shelves stay bare. The notice says no one was harmed. It says so twice.
EV41_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV42_TITLE | pool event title | Hull armour is requisitioned
EV42_BODY | pool event text | The Admiralty wills every slab of hull armour to the front, by order of a clerk who has never seen a hull. Hull armour at Tillam costs more and pays more while shelves are bare. The Bureau entered the slabs as sanctified. They wait cold in a corridor. The crew bow in passing.
EV42_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV43_TITLE | pool event title | A glut of sunmusk
EV43_BODY | pool event text | A convoy of sunmusk reached Tillam on one tide, and nobody had ordered it. Sunmusk at Tillam costs less and pays less. The scent hangs in the corridors, and no two buyers agree what it smells of. The Bureau calls that variety. One dockhand calls it a headache.
EV43_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV44_TITLE | pool event title | Gem cutters are booked solid
EV44_BODY | pool event text | Ashgate's gem cutters are booked solid after a wedding season, and the queue has a queue. Cut glimmers at Ashgate cost more and pay more while the cutters catch up. In one shop a stone hums softly and is not for sale. Fine Finishing makes this pay clearly more.
EV44_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV45_TITLE | pool event title | Cask stock overflows the cellars
EV45_BODY | pool event text | Ashgate's cellars filled with a record vintage, and nobody has the room to drink it. Vintage casks at Ashgate cost less and pay less. The cellar master has begun to give the casks names, and talks to them at closing. Cask Cellar keeps Luxury stock safe from asteroid cuts.
EV45_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV46_TITLE | pool event title | The smelter goes cold
EV46_BODY | pool event text | Voltara's smelter lost its heat to a cracked line, and the casting stopped. Ingot at Voltara costs more and pays more until the furnace is lit again. The crew stand by the dead furnace with their hands out. The metal inside still ticks as it shrinks.
EV46_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV47_TITLE | pool event title | Alloy rolls off the line early
EV47_BODY | pool event text | Voltara's line turned out seam alloy a week early, before the builders had placed an order. Seam alloy at Voltara costs less and pays less. The bales are stacked to the lamps, and a clerk is counting them for the third time. The count has not improved.
EV47_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV48_TITLE | pool event title | Fabric plate runs short
EV48_BODY | pool event text | Ashgate's builders drew a new ring of homes in a single week, and every wall wants plate. Lattice plate at Ashgate costs more and pays more. The draughtsmen call the plan final. The plates on the dock ring faintly when the wind turns, though no wind blows here.
EV48_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV49_TITLE | pool event title | Quarantine at the culture lab
EV49_BODY | pool event text | A culture in Ashgate's lab grew a colour it was not meant to, and the doctors sealed the port. Routes touching Ashgate are blocked for a while. The notice says contained. The night shift counts heads each hour. One is short. Hardy Strains reopens a closed planet a cycle sooner.
EV49_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV50_TITLE | pool event title | Spores come in cheap
EV50_BODY | pool event text | A damp season at Tillam raised spore cultures in every crate, more than anyone could sell. Spore cultures at Tillam cost less and pay less. The manager says the crates are fine. The crates sweat in rows, and the ones in the corner have grown a lid of their own.
EV50_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV51_TITLE | pool event title | Seed stock is bought up
EV51_BODY | pool event text | Tillam's clinics bought every crate of gene seed after one failed batch. Gene seed at Tillam costs more and pays more. The ward manager wrote that the failed batch is fine, and moved the ward to another floor. Culture Banks grow stored Biotech stock.
EV51_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

# PENDING (T181, 2026-11-05): post, platform and flight events. TEXT ONLY, no mechanics row

These blocks are text rows (3 fields), so build_story.py writes them to data/story_text.json and writes NO row to data/events.json. They are inert until the gameplay-programmer wires them in T179 (see handoffs/story-designer/2026-11-05-T181.json). Text ids are final; the effect lines are written for the effects in the Tag line below, and must be edited if economy-designer sets a different effect. No digits: sizes are words ("a small sum", "a little", "clearly"). {planet} is the planet just built or the flight's target; {bot3} is Ostrel Syndicate (name filled by the game). No good is named. Planet names never appear: the events fire after the post exists, and the text works for any planet.
Row ids: EV_<kind><nn>_TITLE (32), _BODY (280), then per option <KEY>: _<KEY>_BTN (28), _<KEY>_EFF (90), _<KEY>_TITLE (32), _<KEY> (popup, 280).
Choices are neutral: two buttons of similar length, no good or bad label, no hidden catastrophe, no loss of the Pathfinder or the fleet (design default, owner Q5 not yet answered). New effect kinds the programmer needs: [post bonus] (next post cheaper or builds faster) and [flight delay] (a little, up to half a cycle).

## EV_PST01 post: arrival [pending]
Tag: post_built:<planet> just built; tags A [post bonus: next post cheaper], B none
EV_PST01_TITLE | pending event title | A dock that keeps a book
EV_PST01_BODY | pending event text | The dock at {planet} keeps a visitors' book. The clerk wants your name in it before the first crate moves. The cover is cold to the touch. Nobody can say who opened it.
EV_PST01_SIGN_BTN | button | Sign the book
EV_PST01_SIGN_EFF | effect line | The next post you build costs less.
EV_PST01_SIGN_TITLE | popup title | The book is signed
EV_PST01_SIGN | popup | The clerk blotted your name and nodded, as if it had always been there. The next post you build costs less. On the page beside yours, someone else's handwriting changed.
EV_PST01_LEAVE_BTN | button | Leave without signing
EV_PST01_LEAVE_EFF | effect line | Nothing changes.
EV_PST01_LEAVE_TITLE | popup title | The book stays shut
EV_PST01_LEAVE | popup | You left the clerk waiting, pen raised. Nothing changes. The clerk wrote a line anyway, in a hand that was not the clerk's.

## EV_PST02 post: local officials [pending]
Tag: post_built:<planet>; A [cash: pay small sum] + [post bonus: next post builds faster]; B [price lean: planet, direction hidden, a few cycles]
EV_PST02_TITLE | pending event title | The Port Warden's stamp
EV_PST02_BODY | pending event text | Warden Ilsa Dorne must inspect the new post at {planet} before she can stamp its lease. She inspects slowly. Your crew wait on the dock with the crates unopened. A gift would hurry her. Waiting would work, in time.
EV_PST02_GIFT_BTN | button | Send a gift
EV_PST02_GIFT_EFF | effect line | Pay a small sum. The next post builds faster.
EV_PST02_GIFT_TITLE | popup title | The Warden is hurried
EV_PST02_GIFT | popup | The gift went up the stairs and the stamp came down, still wet. You paid a small sum. The next post builds faster. The Warden did not smile. Your crew took that for thanks.
EV_PST02_WAIT_BTN | button | Wait for the stamp
EV_PST02_WAIT_EFF | effect line | Nothing is paid. Prices at {planet} move a little for a while.
EV_PST02_WAIT_TITLE | popup title | The stamp takes its time
EV_PST02_WAIT | popup | You waited. The Warden checked every rivet, then the shadows between them. Nothing was paid. Prices at {planet} move a little for a while, and the Warden will not say which way.

## EV_PST03 post: a snag [pending]
Tag: post_built:<planet>; A [cash: pay small sum] + [post bonus: next post builds faster]; B none
EV_PST03_TITLE | pending event title | The beam will not hold
EV_PST03_BODY | pending event text | The survey beam at {planet} will not hold a line. The foreman blames the weather, which is indoors. A part can be bought from a passing hauler. Or your crew can wait for the next shift to have an idea.
EV_PST03_PART_BTN | button | Buy the part
EV_PST03_PART_EFF | effect line | Pay a small sum. The next post builds faster.
EV_PST03_PART_TITLE | popup title | The part is fitted
EV_PST03_PART | popup | The hauler's mate named a price and you paid a small sum. By evening the beam held its line. The next post builds faster, since the crew now knows where the weather comes from.
EV_PST03_SHIFT_BTN | button | Wait for the next shift
EV_PST03_SHIFT_EFF | effect line | Nothing changes.
EV_PST03_SHIFT_TITLE | popup title | The shift has an idea
EV_PST03_SHIFT | popup | The next shift had an idea, and it was to wait for the one after. Nothing changes. The beam flickered once, toward nothing anyone had aimed at.

## EV_PST04 post: a bargain [pending]
Tag: post_built:<planet>; A [cash: pay small sum] + [post bonus: next post cheaper]; B none
EV_PST04_TITLE | pending event title | A broker with spare fittings
EV_PST04_BODY | pending event text | A broker named Odo Pell meets your ship at {planet} with a tray of seals and a lease. A neighbouring post closed, and its fittings are cheap. He talks as if the sale were already done. It might be.
EV_PST04_BUY_BTN | button | Buy the fittings
EV_PST04_BUY_EFF | effect line | Pay a small sum. The next post costs less.
EV_PST04_BUY_TITLE | popup title | The fittings change hands
EV_PST04_BUY | popup | Pell counted the seals twice and gave you one extra, as a courtesy. You paid a small sum. The next post costs less. The fittings are warm, as if someone had only just let go of them.
EV_PST04_PASS_BTN | button | Pass on the offer
EV_PST04_PASS_EFF | effect line | Nothing changes.
EV_PST04_PASS_TITLE | popup title | Pell packs his tray
EV_PST04_PASS | popup | Pell shrugged and packed his tray. Nothing changes. He said the fittings would find a buyer, and looked at the sky as if the buyer were already on the way.

## EV_PST05 post: a rival is already there [pending]
Tag: post_built:<planet>; uses {bot3}; A [price lean: planet, direction hidden]; B [cash: pay small sum] + [price lean: planet, clearly]
EV_PST05_TITLE | pending event title | A desk already stands here
EV_PST05_BODY | pending event text | A desk with the seal of {bot3} already stands on the dock at {planet}. It has a kettle, a stool and a long record of waiting. The agent offers you the next stool. He does not offer to move.
EV_PST05_SHARE_BTN | button | Share the dock
EV_PST05_SHARE_EFF | effect line | Nothing is paid. Prices at {planet} move a little for a while.
EV_PST05_SHARE_TITLE | popup title | The dock is shared
EV_PST05_SHARE | popup | You took the next stool. The agent poured two cups and drank both. Nothing was paid. Prices at {planet} move a little for a while, and the agent keeps the direction to himself.
EV_PST05_SEAL_BTN | button | Hang your own seal
EV_PST05_SEAL_EFF | effect line | Pay a small sum. Prices at {planet} move clearly for a while.
EV_PST05_SEAL_TITLE | popup title | Two seals on one wall
EV_PST05_SEAL | popup | You paid a small sum and hung your seal beside the other. The agent studied it as if it were a price. Prices at {planet} move clearly for a while. The kettle went cold between the seals.

## EV_PST06 post: the dock crowd [pending]
Tag: post_built:<planet>; A [cash: pay small sum] + [post bonus: next post builds faster]; B [cash: gain small sum]
EV_PST06_TITLE | pending event title | Residents come to look
EV_PST06_BODY | pending event text | Residents of {planet} gather at the new post and stand in rows. A child asks if it will stay. The clerk says that is a question for the Plan. No one leaves until someone speaks.
EV_PST06_OPEN_BTN | button | Hold an open dock
EV_PST06_OPEN_EFF | effect line | Pay a small sum. The next post builds faster.
EV_PST06_OPEN_TITLE | popup title | The dock stays open
EV_PST06_OPEN | popup | You set out chairs and a schedule, and the rows turned into a queue. You paid a small sum. The next post builds faster, since this crowd now knows the work. The child left with a bolt in her pocket.
EV_PST06_WORK_BTN | button | Keep to the work
EV_PST06_WORK_EFF | effect line | You gain a small sum from early trade.
EV_PST06_WORK_TITLE | popup title | The rows thin out
EV_PST06_WORK | popup | You kept to the work and the rows thinned by dusk. You gain a small sum from early trade. The child watched until the last crate was stamped. Then she walked home alone.

## EV_PLT01 platform: crew [pending]
Tag: platform_built:<planet>; A [cash: pay small sum] + [stock: gain some mined goods]; B none
EV_PLT01_TITLE | pending event title | Who works the dark
EV_PLT01_BODY | pending event text | A crew from the Bureau's labour desk reaches the new platform on {planet}. They came for the pay and stay for the quiet. The foreman asks what to call a shift that never ends. No one has a form for it.
EV_PLT01_NIGHT_BTN | button | Hire the night crew
EV_PLT01_NIGHT_EFF | effect line | Pay a small sum. Some mined goods are added to your stock.
EV_PLT01_NIGHT_TITLE | popup title | The night crew signs on
EV_PLT01_NIGHT | popup | The night crew signed on without reading. You paid a small sum, and by morning some mined goods lay in your stock, stacked with great care. The foreman named the shift Always. It stuck.
EV_PLT01_DAY_BTN | button | Keep the day crew
EV_PLT01_DAY_EFF | effect line | Nothing changes.
EV_PLT01_DAY_TITLE | popup title | The day crew stays
EV_PLT01_DAY | popup | You kept the day crew. Nothing changes. At change of shift the foreman counted the lamps going out and the lamps coming on, and got two different answers.

## EV_PLT02 platform: collapse [pending]
Tag: platform_built:<planet>; A [cash: pay small sum]; B [planet closed: planet]
EV_PLT02_TITLE | pending event title | The roof sings
EV_PLT02_BODY | pending event text | A gallery at {planet} sings before it fails, a low note, held. The crew is out and the rock is still. Props cost credits. Sealing the gallery costs time. The note has not stopped.
EV_PLT02_PROP_BTN | button | Pay for props
EV_PLT02_PROP_EFF | effect line | Pay a small sum. Routes from {planet} keep running.
EV_PLT02_PROP_TITLE | popup title | The props go in
EV_PLT02_PROP | popup | The props went in under the sound and the sound let them. You paid a small sum. Routes from {planet} keep running. The note dropped a step, the way a voice does when it has been understood.
EV_PLT02_SEAL_BTN | button | Seal the gallery
EV_PLT02_SEAL_EFF | effect line | Nothing is paid. Routes touching {planet} are blocked for a while.
EV_PLT02_SEAL_TITLE | popup title | The gallery is sealed
EV_PLT02_SEAL | popup | The crew sealed the gallery with slabs and tape. Nothing was paid. Routes touching {planet} are blocked for a while. Behind the slabs the note went on, patient, like a tenant.

## EV_PLT03 platform: a find [pending]
Tag: platform_built:<planet>; A [cash: gain small sum]; B [stock: gain some mined goods]
EV_PLT03_TITLE | pending event title | A seam no one logged
EV_PLT03_BODY | pending event text | The drill at {planet} broke into a seam the old surveys never entered, as if they had looked away. It is bright, cold and heavier than it should be. The Bureau has not been told yet.
EV_PLT03_LOG_BTN | button | Log the find
EV_PLT03_LOG_EFF | effect line | You gain a small sum as a finder's share.
EV_PLT03_LOG_TITLE | popup title | The find is logged
EV_PLT03_LOG | popup | The Bureau stamped the find within the hour, which no one had ever seen. You gain a small sum as a finder's share. The seam now has a number, and the number, quietly, has a seam.
EV_PLT03_HIDE_BTN | button | Keep it off the books
EV_PLT03_HIDE_EFF | effect line | Some mined goods are added to your stock.
EV_PLT03_HIDE_TITLE | popup title | The find stays quiet
EV_PLT03_HIDE | popup | The crew filled three carts before the shift bell and told no one. Some mined goods are added to your stock. The seam is still bright in the dark, and still cold on the hand.

## EV_PLT04 platform: the hum [pending]
Tag: platform_built:<planet>; A [price lean: planet, direction hidden, a few cycles]; B none
EV_PLT04_TITLE | pending event title | The hum under the floor
EV_PLT04_BODY | pending event text | The floor of the platform on {planet} hums while the crew sleeps. Engineers measure a steady note, the same each night. The shift lead asks to switch off the lamps. She does not say why.
EV_PLT04_DARK_BTN | button | Switch off the lamps
EV_PLT04_DARK_EFF | effect line | Prices at {planet} move a little for a while.
EV_PLT04_DARK_TITLE | popup title | The lamps go out
EV_PLT04_DARK | popup | The lamps went out and the hum thinned, then stopped, as if it only wanted company. Prices at {planet} move a little for a while, and the shift lead will not say which way. She slept well.
EV_PLT04_LIGHT_BTN | button | Keep the lamps on
EV_PLT04_LIGHT_EFF | effect line | Nothing changes.
EV_PLT04_LIGHT_TITLE | popup title | The lamps stay lit
EV_PLT04_LIGHT | popup | You kept the lamps on. Nothing changes. The hum went on all night. In the morning the engineers found it a little louder, and wrote down that it was not.

## EV_FLT01 flight: drifting wreck [pending]
Tag: flight longer than 1 cycle, outside home orbit; A [flight delay: a little] + [cash: gain small sum]; B none
EV_FLT01_TITLE | pending event title | A wreck on the lane
EV_FLT01_BODY | pending event text | A hull drifts across the lane, cold, its name scraped off. The Pathfinder's scanner counts no one aboard, then counts again. A tow would delay the flight. Salvage is salvage, if no one comes to claim it.
EV_FLT01_TOW_BTN | button | Tow it clear
EV_FLT01_TOW_EFF | effect line | The flight is delayed a little. You gain a small sum for the salvage.
EV_FLT01_TOW_TITLE | popup title | The wreck is cleared
EV_FLT01_TOW | popup | The Pathfinder dragged the hull out of the lane and the flight lost a little time. You gain a small sum for the salvage. The scanner counted one aboard as the hull went. It did not count again.
EV_FLT01_FLY_BTN | button | Fly on
EV_FLT01_FLY_EFF | effect line | Nothing changes.
EV_FLT01_FLY_TITLE | popup title | The wreck falls behind
EV_FLT01_FLY | popup | The Pathfinder flew on. Nothing changes. In the rear glass the hull turned slowly, showing its scraped patch, then its other side.

## EV_FLT02 flight: distress call [pending]
Tag: same conditions; A [cash: pay small sum]; B none
EV_FLT02_TITLE | pending event title | A call on an old band
EV_FLT02_BODY | pending event text | A distress call comes in on an old band, the voice polite and unhurried. By the time the Pathfinder turns, the call has become a recipe. A relay fee would let you check it from here.
EV_FLT02_RELAY_BTN | button | Pay the relay fee
EV_FLT02_RELAY_EFF | effect line | Pay a small sum. The flight is not delayed.
EV_FLT02_RELAY_TITLE | popup title | The relay answers
EV_FLT02_RELAY | popup | You paid a small sum, and the relay checked the band without a turn. The flight is not delayed. The relay reported a pot, a stove and a very long wait. It filed the call as cooked.
EV_FLT02_HOLD_BTN | button | Hold the course
EV_FLT02_HOLD_EFF | effect line | Nothing changes.
EV_FLT02_HOLD_TITLE | popup title | The call fades
EV_FLT02_HOLD | popup | You held the course. Nothing changes. The voice went on a while with the recipe, then said the last step twice, very slowly, and was gone.

## EV_FLT03 flight: toll patrol [pending]
Tag: same conditions; A [cash: pay small sum]; B [flight delay: a little]
EV_FLT03_TITLE | pending event title | A toll on the lane
EV_FLT03_BODY | pending event text | A patrol cutter hails the Pathfinder. It says the lane is private and has been since the cutter was painted. A toll is asked, politely. The cutter's gun looks at the toll, not at you.
EV_FLT03_PAY_BTN | button | Pay the toll
EV_FLT03_PAY_EFF | effect line | Pay a small sum. The flight goes on.
EV_FLT03_PAY_TITLE | popup title | The toll is paid
EV_FLT03_PAY | popup | You paid a small sum and the cutter blinked twice, which is how it says thank you. The flight goes on. The gun turned away last, like someone leaving a room backwards.
EV_FLT03_AROUND_BTN | button | Take the long way round
EV_FLT03_AROUND_EFF | effect line | The flight is delayed a little.
EV_FLT03_AROUND_TITLE | popup title | The long way
EV_FLT03_AROUND | popup | The Pathfinder swung wide around a lane that was private by decree. The flight is delayed a little. The cutter followed for a while, to see that the sky was not borrowed.

## EV_FLT04 flight: asteroid dust [pending]
Tag: same conditions; A [flight delay: a little]; B [cash: pay small sum]
EV_FLT04_TITLE | pending event title | Dust across the lane
EV_FLT04_BODY | pending event text | Fine dust crosses the lane and rattles on the hull like rain on a tin roof. The pilot slows, then asks if she may ask what rain is. Nobody on board is sure. The hull is sure only of the dust.
EV_FLT04_SLOW_BTN | button | Slow down
EV_FLT04_SLOW_EFF | effect line | The flight is delayed a little.
EV_FLT04_SLOW_TITLE | popup title | The dust passes
EV_FLT04_SLOW | popup | The Pathfinder slowed and the dust went over like a long shift change. The flight is delayed a little. The hull rang once, low, and then did not ring again.
EV_FLT04_PUSH_BTN | button | Push through
EV_FLT04_PUSH_EFF | effect line | Pay a small sum for hull repairs at the next port.
EV_FLT04_PUSH_TITLE | popup title | The hull takes the dust
EV_FLT04_PUSH | popup | The Pathfinder pushed through at speed. A small sum goes to hull repairs at the next port. The pilot stood the rest of the shift at the glass, trying to remember what rain was for.

# Early branch events, one per market, EV52 to EV55 (added 2026-11-06, T233)

Four one-time pool events, one per market (Military EV52, Luxury EV53, Minerals EV54, Biotech EV55). They fire early, in the first cycles. TEXT ONLY: no row in data/events.json, no tag; T234 adds the mechanics. Each has a title, a body, a rivals line (EVnn_EFF, as the other pool events) and two options, A (the dark-market buyer) and B (the public market). Ids per option: EVnn_A_BTN (28), EVnn_A_EFF (90), EVnn_A_TITLE (32), EVnn_A (result, 280); the same with B.
Placeholder: {cash_in} is the credits the chosen option pays, number only. T234 fills it per option (A more than B). {market} is filled by the game in the EVnn_EFF line.
No text names a good, a planet or a number: the goods of the early cycles are only energy and food, so each event speaks of crates, sets, cases and trays. The effect lines say only "pays more now" or "pays less now". No text hints at being seen, a risk or a later cost.

EV52_TITLE | pool event title | A Fleet Office rush order
EV52_BODY | pool event text | The Fleet Office gave you a rush order, and three larger crews want it if you slip. At the depot's back gate, Bosk Two-Stamps offers ready cash for some crates. His thumbs are blue from stamping forms nobody wrote. Sell fast, or sell at the counter.
EV52_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.
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
EV53_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.
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
EV54_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.
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
EV55_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.
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
