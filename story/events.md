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

Neutrality checks run on all 28 steps (script, not the game): no digit, no banned verdict word (good, bad, right, wrong, fair, safe, risky, bold, kind, open, closed, quiet, polite, late, long, short, small, big, plain, clean and the rest of 4.2 rule 1), no "but", "however" or "at least" in any text; button lengths within 5 characters, effect lines and results within 25 percent of each other. Each step's pair shares one grammar and one length class. The old Minerals chain events EV29 to EV37 stay in this file until the chain is wired; their choice texts name stances (Keep mining, Share the lane) and must be retired with the Open and Hard framing, not reused.

EV01 | Voltara's reactors run wild | [price down: Voltara, energy] | P
A monitor proved the reactors could run far past the safe-hours rule. The rule was wrong, not the machine, said the night shift. Energy at Voltara costs less and pays less. The day shift wants the rule back. The cores hum on.

EV02 | Grey blight on Tillam's terraces | [price up: Tillam, food] | P
A grey blight is eating Tillam's terraces. The committee ruled it a rumour, since no form reports it. Food there costs more and pays more. The leaves come apart like wet paper anyway. A fact needs a stamp. The blight has not applied.

EV03 | Ashgate's harvest comes in heavy | [price down: Ashgate, food] | P
Ashgate's harvest came in heavy, and the Common Ledger counted only half of it. Food there costs less and pays less. The other half sits on the dock, real and uncounted. What is not on the form is still food, until it rots.

EV04 | Voltara's crews go hungry | [price up: Voltara, food] | P
A cheerful official explained that hunger is a slow phase of a smooth future. Voltara's crews work long shifts on short rations. Food there costs more and pays more. The cut was equal for all. The crews note that equal is not full.

EV05 | Frost on Tillam | [price up: Tillam, energy] | P
Winter came early to Tillam and the heaters never stop. Energy there costs more and pays more. Frost has begun to grow inside the ducts in patterns no one will explain. The old duct-keeper says it keeps its place on purpose.

EV06 | Ashgate lights every furnace | [price up: Ashgate, energy] | P
Ashgate relit every foundry to meet a plan that arrived this morning. Energy there costs more and pays more. An old brakeman asked what the rush was. Nobody answered, and the furnaces glared on. Speed is not a direction.

EV07 | Tillam's docks go on strike | [planet closed: Tillam] | P
Tillam's dock crews walked out. They say a debt is owed them, and the Bureau asked where it lives. The port is closed for a while, and routes touching Tillam are blocked until it reopens. The ships wait outside and take no side.

EV08 | Ashgate seals its port | [planet closed: Ashgate] | P
Something turned up in Ashgate's lower docks, and the doctors will only say the port is closed. Routes touching Ashgate are blocked until they say otherwise. Nobody here is a witness. Everybody is a suspect.

EV09 | Voltara goes dark | [planet closed: Voltara] | I
A fault in Voltara's grid took the port down with it. The planet that powers everyone cannot light its own docks. The port is closed for a while, and routes touching Voltara are blocked. The law says lights on. The emergency says off. A clerk decides.

EV10 | A lender walks Tillam's market | [price down: Tillam, energy] | Q
A lender's agent walked Tillam's market and bought every debt in sight. Sellers settled up and dumped their stock. Energy there costs less and pays less for now. A debt is real until someone stops believing in the paper. No one has stopped yet.

EV11 | Ashgate's foreman says enough | [price down: Ashgate, energy] | Q
An Ashgate foreman read the numbers, declared the shift had made enough, and sent the crews home. Energy there costs less and pays less. Enough is a figure the Plan does not print. The crews left quietly, and no guard was needed.

EV12 | Voltara buys before the news | [price up: Voltara, energy] | Q
Voltara's buyers bought energy hard on a rumour from the far beacons. The rumour was false, but prices rose anyway, so they were right for the wrong reason. Energy there costs more and pays more. Call it knowledge if you like. The market does.

EV13 | A family buys Ashgate's food | [price up: Ashgate, food] | Q
A family with old credits quietly bought every food contract on Ashgate. Food there costs more and pays more. They moved unseen and asked why they should be fair. The Commons has no form for that question yet. You are in no position to judge.

EV14 | The inspector's count | [price down: Voltara, food] | I
An inspector counted Voltara's food stores and found them sufficient, on a form. The market believed the form, so food there costs less and pays less. The pantries are still bare, now correctly accounted for. The form reads smoothly. That is most of truth.

EV15 | Tillam's festival of founders | [price up: Tillam, food] | I
Tillam declared a festival of founders, and everyone wore a founder's mask. Food there costs more and pays more. Three committees claim to be the real ones. By midnight nobody can tell, and nobody clears the tables.

EV16 | A ship leaves Tillam half empty | [price down: Tillam, food] | Q
A ship left Tillam half empty, bound for a rock nobody has charted. Those who stayed sold spare food to pay for staying. Food there costs less and pays less. A letter came back, from a Tillam that chose otherwise. No one has answered it.

## Goods events (T154, 2026-11-02): silk, logic cores, ore
EV21 | Tillam's weavers down tools | [price up: Tillam, silk] | I
Tillam's silk weavers downed tools over a form that counted their hours twice. Silk there costs more and pays more. An old weaver says to watch the cricket in the vat, which changes its shape when it sees another. The guild will settle.

EV22 | Voltara holds a gala | [price up: Voltara, silk] | I
Voltara's crews hold a gala to celebrate a quota met on paper. Silk there costs more and pays more. Everyone borrows a sleeve and a mask for the night, and by the second hour the crews look alike. Nothing soft has reached the foundry decks in years.

EV24 | Fire in Voltara's foundry | [price up: Voltara, chips] | P
A fire swept Voltara's core foundry and left the casting floor black. Logic cores there cost more and pay more. A cheerful report calls it a gentle step toward a better line. The ash settled on the walls in rows. Nobody has read them.

EV25 | Ashgate recalls its tractors | [price up: Ashgate, chips] | Q
Ashgate recalled its farm tractors to be retrained as safe. Logic cores there cost more and pay more. The retrained ones panic when two foremen give opposite orders. The old ones were told to keep quiet and keep going, and they do.

EV26 | A rich seam is logged twice | [price down: Voltara, ore] | Q
A survey crew found a rich seam and logged it in two offices. Ore at Voltara costs less and pays less while the news is fresh. Miners say a block down there keeps its place and shifts when nobody looks. The Commons owns it, so nobody has gone to ask.

EV28 | Voltara's foundry wants rock | [price up: Voltara, ore] | P
Voltara's foundry ordered more rock than the Plan had dreamed of. Ore there costs more and pays more. Every shortcut the founders took lies under the furnace floor, and the furnace wants more. Somebody must go and dig it.

# Events, choice events (draft 1, T96 T100 T103 T108, 2026-10-28)

Format: ID | place | tag, then text. Choice events use the choice screen limits: title max 40, body max 280, button max 28, effect line max 90. Outcome texts are event popups: title max 32, text max 280, shown under NOT_EVENT_PREFIX with BTN_OK. No numbers: the game inserts any amount through a placeholder. Tags name the effect in words as the owner described it; the Economy Designer sets size and duration. Planet = {planet}.

## Debris in orbit [route efficiency down: {planet}, while the debris stays]
EV17_TITLE | choice title | Wreckage is circling {planet}
EV17_BODY | choice body | The wreck of a hundred ships has settled into orbit over {planet}, hull plates and spent tanks turning slowly. A contractor will sweep it for a fee. The Bureau filed it as unowned, which is why it is still up there. The old fleets left their shortcuts behind.
EV17_PAY_BTN | button | Pay the fee
EV17_PAY_EFF | effect line | Pay the fee. The debris is cleared and routes from {planet} run as before.
EV17_LEAVE_BTN | button | Leave the debris
EV17_LEAVE_EFF | effect line | Routes from {planet} carry less while the debris stays. It does not clear itself.
EV17_PAID_TITLE | popup title | Orbit over {planet} is clear
EV17_PAID | popup | The contractor swept the orbit and filed the receipt. Routes from {planet} carry their full load again. The wreck went somewhere. The receipt does not say where. The debt is real only while the paper is, and you stopped asking.
EV17_LEFT_TITLE | popup title | Debris stays over {planet}
EV17_LEFT | popup | You left the wreck. Ships from {planet} thread around it and carry less. The offer stays open. The wreck turns slowly, a stone that has kept its place longer than any city. Neither it nor you is in a hurry.

## Solar shield [shield built: affects only planets the player can buy later; residents unhappy]
EV18_TITLE | choice title | Shade the sun
EV18_BODY | choice body | Engineers want to put a shield across part of the sun. The residents hate it and say so in writing, at length. It would reshape the markets on planets you can buy later: some goods get cheaper, while profit and energy rise. What you already own stays as it is.
EV18_BUILD_BTN | button | Build the shield
EV18_BUILD_EFF | effect line | Planets you can buy later change: some resources drop, profit and energy rise.
EV18_SKIP_BTN | button | Leave the sun alone
EV18_SKIP_EFF | effect line | Nothing changes. The sun keeps its full light.
EV18_BUILT_TITLE | popup title | The shield is up
EV18_BUILT | popup | The shield is up and the sky is dimmer. Residents are furious and have filed it in triplicate, in the dark. On planets you can buy later, some goods get cheaper while profit and energy climb. Planets you own are untouched. The engineers call the slow ones to keep up.
EV18_SKIPPED_TITLE | popup title | The shield stays on paper
EV18_SKIPPED | popup | The plans go back in a drawer. The residents are relieved and file no thanks. Nothing changes in any market. An engineer asks what the rush was, and no one has an answer.

## Nomads and pirates [choice: evict nomads or let them stay; pirates reduce trade volume; hire to clear pirates, at a cost]
EV19_TITLE | choice title | Nomads on the asteroids
EV19_BODY | choice body | Nomad families live on the asteroids you could mine. They are not on the Common Ledger, which the Bureau takes as a personal failing. They count their people by who shares the meal. Evict them and the rock is yours. Or let them stay, and let their lamps burn.
EV19_EVICT_BTN | button | Evict the nomads
EV19_EVICT_EFF | effect line | The asteroids open for mining. Some nomads turn to piracy, and pirates rise.
EV19_STAY_BTN | button | Let them stay
EV19_STAY_EFF | effect line | The asteroids stay closed to mining. No pirates come of it.
EV19_EVICTED_TITLE | popup title | The asteroids are cleared
EV19_EVICTED | popup | The nomads left on the next tide, without a word. The rock is yours to mine. Some did not go far, and now they keep ships and a grudge. Pirates rise. The empty tables were left set.
EV19_STAYED_TITLE | popup title | The nomads stay
EV19_STAYED | popup | You let the nomads stay. Their lamps burn on the rock, small and steady, and they share a meal with the first ship that docks. The asteroids remain closed to mining.
EV19_PIRATES_TITLE | popup title | Pirates reduce trade
EV19_PIRATES | popup | Pirates now work the lanes, and fewer cargoes get through. Trade volume falls while they stay. The Bureau has opened a file on them. It is a thin file, and so is the fleet behind it. Obedience is cheaper than love, and lasts as long.
EV19_HIRE_BTN | button | Hire a clearance crew
EV19_HIRE_EFF | effect line | Pay to have the pirates cleared. It costs credits and removes their effect on trade.

## Asteroid approach [warning; pay the state: no skill point, no reputation; decline: 50/50 bad outcome or nothing; bad outcome is storage destroyed or storage capacity cut]
EV20_TITLE | choice title | An asteroid is approaching
EV20_BODY | choice body | A rock is coming in on a slow path, and the Bureau noticed it the way it notices everything: late. The state can turn it aside for a fee. The form for refusing is shorter. The dark outside looks closer. The rule says wait. The rock says otherwise.
EV20_PAY_BTN | button | Pay the state
EV20_PAY_EFF | effect line | Cost: payment to the state. Asteroid dealt with. The company gains one expansion point.
EV20_DECLINE_BTN | button | Decline
EV20_DECLINE_EFF | effect line | An even chance: company storage is hit, or nothing happens.
EV20_PAID_TITLE | popup title | The asteroid is deflected
EV20_PAID | popup | The state turned the rock aside and sent a receipt. The company gains one expansion point for the trouble. The asteroid drifts on, toward someone else's sky. A law is only as strong as the person who says: this is the law.
EV20_REWARD | notice (shown after EV20_PAID) | Event reward: the asteroid is dealt with and the company gains an expansion point.
EV20_HIT_TITLE | popup title | Company storage destroyed
EV20_HIT_DESTROYED | popup | The asteroid struck {planet}. Your company storage there is gone, and what it held with it. The Bureau has recorded the loss as an adjustment of the Common Ledger. Nobody said sorry. Death takes what a life would still have held.
EV20_HIT_CAPACITY | popup | The asteroid grazed {planet}. Your company storage there is cracked and holds less than before. The Bureau has recorded the damage as "partial". The crack runs through the wall in a straight, patient line.
EV20_MISS_TITLE | popup title | The asteroid passes
EV20_MISS | popup | The asteroid passed the system and kept going. Nothing was hit and nothing changes. The Bureau withdrew its warning, with regret, and kept the form. You could have been struck right now. Let that decide how you read the next notice.

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
BE01_BODY | choice body | Tillam keeps a reserve of grain behind a lock that only the committee can open. Winter is close and the stores outside are thin. The committee will open it for a company that carries the grain out, and wants an answer today. The lock is old and patient.
BE01_OPEN_BTN | button | Open it to the crowd
BE01_OPEN_EFF | effect line | Food at Tillam costs less and pays less for a while. Tillam remembers.
BE01_SHUT_BTN | button | Keep the lock shut
BE01_SHUT_EFF | effect line | Food at Tillam costs more and pays more for a while. Tillam remembers.
BE01_SEND_BTN | button | Send it to Ashgate
BE01_SEND_EFF | effect line | Food at Ashgate costs less and pays less for a while. Ashgate remembers.
BE01_OPEN_TITLE | popup title | The granary opens
BE01_OPEN | popup | The lock gave way and the grain went out by hand, sack to sack. Food at Tillam costs less and pays less while the stores are full. The committee recorded it as a loan. Nobody asked who owes whom.
BE01_SHUT_TITLE | popup title | The lock stays shut
BE01_SHUT | popup | You declined. The lock stayed on and the queue grew in the cold. Food at Tillam costs more and pays more while it is scarce. Somewhere inside the granary something shifted, as if it also had been waiting.
BE01_SEND_TITLE | popup title | Grain goes to Ashgate
BE01_SEND | popup | The grain left Tillam by night, on ships that did not ask to be loaded. Food at Ashgate costs less and pays less for a while. The committee at Tillam noticed the empty shelf and wrote a short, cold note.

[follow-up of BE01_OPEN, tag: price up: Tillam, energy]
BE01A_TITLE | popup title | Tillam burns bright for you
BE01A | popup | Tillam remembered the grain. Every heater on the terraces runs high and the committee calls it a gift. Energy at Tillam costs more and pays more for a while. The frost in the ducts has gone quiet, as if it was fed.

[follow-up of BE01_SHUT, tag: planet closed: Tillam]
BE01B_TITLE | popup title | Tillam closes its port
BE01B | popup | The queue that waited in the cold came to the docks. Tillam's port is closed for a while, and routes touching Tillam are blocked. The crowd does not shout. It stands in rows and looks at the ships.

[follow-up of BE01_SEND, tag: price up: Ashgate, energy]
BE01C_TITLE | popup title | Ashgate returns the favour
BE01C | popup | Ashgate remembered the grain. Its foundries run hot in thanks and the smoke leans toward your ships. Energy at Ashgate costs more and pays more for a while. A foreman left a loaf at the dock. It was still warm.

## BE02 The beacon over Dunmere Reach [2 choices, system 2, silk]
BE02_TITLE | choice title | A beacon over Dunmere Reach
BE02_BODY | choice body | A beacon pulses over Dunmere Reach, from a rock that no chart lists. Its pattern repeats, then changes, as if it had heard the dock talk. The Bureau office at Quillon wants it logged and silenced. The crews want to answer. Your ships pass it every cycle.
BE02_ANSWER_BTN | button | Answer the beacon
BE02_ANSWER_EFF | effect line | Silk at Quillon costs more and pays more for a while. Something answers back.
BE02_REPORT_BTN | button | Report it to the Bureau
BE02_REPORT_EFF | effect line | Quillon closes its port to check the sky. Routes touching Quillon are blocked for a while.
BE02_ANSWER_TITLE | popup title | The beacon is answered
BE02_ANSWER | popup | A crew sent three pulses back. The beacon went dark, then lit again, in the same order. Quillon's buyers heard and bought silk as if a festival had been announced. Silk there costs more and pays more. Nobody has said what the festival is for.
BE02_REPORT_TITLE | popup title | Quillon checks the sky
BE02_REPORT | popup | The Bureau filed the beacon as a fault and closed Quillon's port to inspect the sky. Routes touching Quillon are blocked for a while. The inspectors were polite. The beacon pulsed once, as if it had read the form.

[follow-up of BE02_ANSWER, tag: price up: Mossfell, food]
BE02A_TITLE | popup title | Visitors reach Mossfell
BE02A | popup | Small ships came in from the quiet rock and docked at Mossfell without papers. They want food and pay in odd, heavy coins. Food at Mossfell costs more and pays more for a while. They did not say their names. They stayed polite and counted the crates twice.

[follow-up of BE02_REPORT, tag: price down: Quillon, silk]
BE02B_TITLE | popup title | The inspection finds nothing
BE02B | popup | The inspectors found no fault and Quillon's port reopened. Stock held back for the check came out all at once. Silk at Quillon costs less and pays less for a while. The beacon is still up there. The report says it is not.

## BE03 A family offers cover [3 choices, system 1, Ashgate]
BE03_TITLE | choice title | A family offers cover
BE03_BODY | choice body | The family that bought Ashgate's food contracts sends a polite note. For a share, they will keep the docks quiet and the other traders out. They also mention how fragile a dock can be. The Bureau has no form for this. It would like one.
BE03_ACCEPT_BTN | button | Accept their cover
BE03_ACCEPT_EFF | effect line | Food at Ashgate costs more and pays more for a while. The family will call in the favour.
BE03_REFUSE_BTN | button | Refuse politely
BE03_REFUSE_EFF | effect line | Food at Ashgate costs less and pays less for a while. The family will wait.
BE03_REPORT_BTN | button | Report to the Bureau
BE03_REPORT_EFF | effect line | Ashgate closes its port for an audit. Routes touching Ashgate are blocked for a while.
BE03_ACCEPT_TITLE | popup title | The family keeps the docks
BE03_ACCEPT | popup | The family's people took the docks in the morning, in clean coats. Food at Ashgate costs more and pays more, since their prices travel with them. Everything is quiet. A dock this quiet has an owner.
BE03_REFUSE_TITLE | popup title | The note is declined
BE03_REFUSE | popup | You sent back a polite no. The family sent back a polite nod. Food at Ashgate costs less and pays less as their buyers step back to watch. Nobody was threatened. Everyone knows what was not said.
BE03_REPORT_TITLE | popup title | The Bureau opens a file
BE03_REPORT | popup | The Bureau thanked you in writing and closed Ashgate's port for an audit. Routes touching Ashgate are blocked for a while. The audit will take its own time. The family has been told who filed.

[follow-up of BE03_ACCEPT, tag: planet closed: Ashgate]
BE03A_TITLE | popup title | The family calls its favour
BE03A | popup | The family closed Ashgate's docks to every ship but its own, and sent you the bill for the quiet. Routes touching Ashgate are blocked for a while. The note was courteous. A favour is a debt that keeps its place.

[follow-up of BE03_REFUSE, tag: price down: Ashgate, energy]
BE03B_TITLE | popup title | The family waits
BE03B | popup | The family did nothing, which was its answer. Its buyers stayed away from the furnaces and energy at Ashgate costs less and pays less for a while. A courier sits in a booth on the dock, reading and never turning a page.

[follow-up of BE03_REPORT, tag: price up: Ashgate, chips]
BE03C_TITLE | popup title | The audit ends, parts are short
BE03C | popup | The audit ended and Ashgate's port is open. The family's contracts were frozen and the repair shops cannot get spares. Logic cores at Ashgate cost more and pay more for a while. The Bureau stamped the file closed. The family kept its copy.

# Events, dead worlds: Cinderrest and Greywake (draft 1, 2026-11-02)

Source: design/proposals/2026-11-02-dead-planets.md, section 5. Three pairs. Part 1 is a choice event (EV29, EV32, EV35, same id scheme as EV17 to EV20, title max 32 here, body 280, button 28, effect line 90). Part 2 is a plain event per choice (EV30, EV31, EV33, EV34, EV36, EV37), shown as a popup under NOT_EVENT_PREFIX with BTN_OK. Part 2 fires 4 cycles after the choice. Part 2 events must have random: false (R1). No numbers: amounts come from balance.
Dead worlds open at cycle 15 (balance key), so Part 1 events cannot fire before then. No text below names a cycle or implies an earlier opening.
Names Cinderrest, Greywake, Dross Salt (running text: dross) and Nullglass (running text: nullglass) are working names, see voice.md.
Effects named only in words below that the parser does not read today (danger, credit cost, load loss, income cut) are requests in the handoff, not tags.

| Part 1 | Choice | Immediate tag | Also needs (request) | Part 2 |
|---|---|---|---|---|
| EV29 Cinderrest | Keep mining | [price up: Cinderrest, dross] | danger +1 | EV30 |
| EV29 Cinderrest | Pull the crew out | [planet closed: Cinderrest] | none (closure is the tag) | EV31 |
| EV32 Greywake | Shore up the wall | [price up: Greywake, nullglass] | credit cost | EV33 |
| EV32 Greywake | Carry on cutting | [price down: Greywake, nullglass] | chance of load loss | EV34 |
| EV35 both | Share the lane | [price down: Cinderrest, dross] | income from dead worlds cut | EV36 |
| EV35 both | Race the rival | [price up: Cinderrest, dross] | income up, danger up | EV37 |

| Part 2 | Follows | Tag |
|---|---|---|
| EV30 | EV29 Keep mining | [planet closed: Cinderrest] |
| EV31 | EV29 Pull out | [price down: Cinderrest, dross] |
| EV33 | EV32 Shore up | [price down: Greywake, nullglass] |
| EV34 | EV32 Carry on | [planet closed: Greywake] |
| EV36 | EV35 Share | [price up: Greywake, nullglass] |
| EV37 | EV35 Race | [price down: Cinderrest, dross] |

## Pair A: Cinderrest [fires when a route first mines Cinderrest]
EV29_TITLE | choice title | Dust in the Cinderrest shafts
EV29_BODY | choice body | The first crew to cut Dross Salt on Cinderrest came up coughing. The dust is fine, white and everywhere, and the medic cannot name it. The Bureau lists Cinderrest as uninhabited, so nobody there can be ill. The crew asks whether to go on.
EV29_MINE_BTN | button | Keep mining
EV29_MINE_EFF | effect line | Dross costs more and pays more at Cinderrest for a while. Danger there rises.
EV29_PULL_BTN | button | Pull the crew out
EV29_PULL_EFF | effect line | Cinderrest closes for a while. Routes touching it are blocked. Danger does not rise.
EV29_MINE_TITLE | popup title | The crew keeps cutting
EV29_MINE | popup | The crew went back down with wet cloth over their faces. Dross at Cinderrest costs more and pays more, since fewer will cut it. The white dust settles on the lamps in even rings. The danger on Cinderrest has risen.
EV29_PULL_TITLE | popup title | The crew comes up
EV29_PULL | popup | You called the crew up. The Bureau filed the withdrawal as a rest. Cinderrest is closed for a while, and routes touching it are blocked. The danger does not grow. Below, the dust keeps settling, as if it could wait.

### follow-up of EV29_MINE, 4 cycles later
EV30 | The cough reaches the ships | [planet closed: Cinderrest] | I
The cough rode up with the salt. A crew lies in the infirmary and the port doctor has shut Cinderrest's docks. Routes touching Cinderrest are blocked for a while. The medic reports that the dust is not hostile. It is only patient.

### follow-up of EV29_PULL, 4 cycles later
EV31 | Cinderrest is quiet | [price down: Cinderrest, dross] | Q
The crew rested and the cough faded. Salt cut before the pause now floods the dock, so dross at Cinderrest costs less and pays less. The shaft stayed still. The lamps were left lit below, and the dust has not touched them.

## Pair B: Greywake [fires when a route first mines Greywake]
EV32_TITLE | choice title | A wall falls on Greywake
EV32_BODY | choice body | A cut wall on Greywake shifted and the glass sang like a struck bell. Nothing has fallen yet, but the crack is long. Braces cost credits. The Bureau calls it a feature of the geology. The crew wants an answer before the next shift.
EV32_SHORE_BTN | button | Shore up the wall
EV32_SHORE_EFF | effect line | Costs credits now. Nullglass costs more and pays more at Greywake while the cut is slow.
EV32_CARRY_BTN | button | Carry on cutting
EV32_CARRY_EFF | effect line | Nullglass costs less and pays less at Greywake. Some of the load may be lost.
EV32_SHORE_TITLE | popup title | The wall is braced
EV32_SHORE | popup | The crew set braces in rows and the wall went quiet. The work cost credits. Nullglass at Greywake costs more and pays more while the cut is slow. The glass hummed once, a low note, and then kept still.
EV32_CARRY_TITLE | popup title | The cutting goes on
EV32_CARRY | popup | You told them to cut. The wall held through the shift and nullglass flowed. It costs less and pays less at Greywake with so much on the dock. Some of the load may not survive the climb. The crack grew a little.

### follow-up of EV32_SHORE, 4 cycles later
EV33 | The wall holds | [price down: Greywake, nullglass] | Q
The braces held and the crew cut clean. Nullglass keeps coming up whole, so it costs less and pays less at Greywake for a while. The Bureau claims the wall as its own work. The glass shows the crew their own faces, a little late.

### follow-up of EV32_CARRY, 4 cycles later
EV34 | The wall comes down | [planet closed: Greywake] | I
The cracked wall gave way in the night. Nobody was under it, but the shaft is sealed. Greywake is closed for a while, and routes touching it are blocked. The fall made no sound, say the crew. They felt it in their teeth.

## Pair C: both dead worlds [fires when both Cinderrest and Greywake have been mined]
EV35_TITLE | choice title | A rival eyes the dead worlds
EV35_BODY | choice body | A rival hauler pulls alongside with a message: Cinderrest and Greywake are not safe to cut alone. It offers a shared lane, the take split. Or you can outrun it and cut harder. Its hull has no name painted on it. The dust lies in the lane.
EV35_SHARE_BTN | button | Share the lane
EV35_SHARE_EFF | effect line | Dross costs less and pays less at Cinderrest. Your income from the dead worlds is cut.
EV35_RACE_BTN | button | Race the rival
EV35_RACE_EFF | effect line | Dross costs more and pays more at Cinderrest. Income rises. Danger rises on both worlds.
EV35_SHARE_TITLE | popup title | The lane is shared
EV35_SHARE | popup | You split the lane. The rival hauler dipped its lights twice and took the far berth. Dross at Cinderrest costs less and pays less with two crews cutting. Your income from the dead worlds is cut. Both hulls ride quieter in company.
EV35_RACE_TITLE | popup title | You race the rival
EV35_RACE | popup | You ran the lane hard. Dross at Cinderrest costs more and pays more while you hold the lead. Income rises, and the danger rises on both dead worlds. The rival's lights fell behind and went out, one by one.

### follow-up of EV35_SHARE, 4 cycles later
EV36 | The rival keeps its word | [price up: Greywake, nullglass] | Q
The rival kept to its lane and sent a chart of Greywake's safe cuts. Nullglass at Greywake costs more and pays more as the shared crews buy. Nobody signed anything. The chart's margins hold small marks, in a hand that is not quite a hand.

### follow-up of EV35_RACE, 4 cycles later
EV37 | The rival cuts you off | [price down: Cinderrest, dross] | I
The rival did not forgive the race. Its crews flooded Cinderrest with cheap salt, and dross there costs less and pays less. Your ships still dock, and nobody looks at them. In the dust the rival's lamps move in a line, all together.

# Events, shared pool EV40 to EV51 (added 2026-11-03)

Twelve one-time pool events for the new goods and workshops, three per market (Military EV40 to EV42, Luxury EV43 to EV45, Minerals EV46 to EV48, Biotech EV49 to EV51). Each fires once per run. They are NOT rows in data/events.json yet: the build writes only text ids (EV<nn>_TITLE max 32, EV<nn>_BODY max 280, EV<nn>_EFF max 90, the rivals line). The tag and kind sit in the table below for the economy and gameplay tasks that add the rows and the art. Planets are suggestions; the economy designer maps them to the planets that trade the good.
Pool events carry no bot effect (core 4.4), so every rivals line says that no rival changes. If a pool event ever gets a bot effect, rewrite its EV<nn>_EFF line first.

| Id | Tag | Kind |
|---|---|---|
| EV40 | [price down: Voltara, rivets] | P |
| EV41 | [price up: Ashgate, cells] | Q |
| EV42 | [price down: Quillon, armour] | I |
| EV43 | [price down: Quillon, musk] | I |
| EV44 | [price up: Voltara, cask] | Q |
| EV45 | [price up: Quillon, gems] | P |
| EV46 | [price up: Voltara, ingot] | P |
| EV47 | [price down: Quillon, alloy] | I |
| EV48 | [price up: Ashgate, ingot] | P |
| EV49 | [planet closed: Brannock] | I |
| EV50 | [price down: Mossfell, spores] | Q |
| EV51 | [price up: Quillon, seed] | Q |

EV40_TITLE | pool event title | Rivet guns pile up at Voltara
EV40_BODY | pool event text | Voltara's foundry made more rivet guns than the garrisons ordered, and the surplus is stacked to the roof. Rivet guns there cost less and pay less. A clerk has asked whether a surplus is a kind of order. The stacks tick as they cool.
EV40_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV41_TITLE | pool event title | Pulse cells are recalled
EV41_BODY | pool event text | A batch of pulse cells ran hot in the field, and the maker pulled the lot. Pulse cells at Ashgate cost more and pay more while the shelves stay bare. The recall notice says no one was harmed. It says so twice. The cells in storage hum a note too low to name.
EV41_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV42_TITLE | pool event title | Hull armour waits at Quillon
EV42_BODY | pool event text | A shipment of hull armour reached Quillon with no buyer, since the garrisons had ordered plate of another gauge. Hull armour there costs less and pays less. The Bureau filed the plates as spare courage. They stand in the corridor, cold to the touch.
EV42_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV43_TITLE | pool event title | A glut of sunmusk
EV43_BODY | pool event text | A convoy of sunmusk reached Quillon on one tide, and nobody had ordered it. Sunmusk there costs less and pays less. The scent hangs in the corridors, and the buyers cannot agree what it smells of. The Bureau calls that variety.
EV43_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV44_TITLE | pool event title | The cask cellar sours
EV44_BODY | pool event text | A cellar at Voltara lost a season of casks to a warm spell, and the guild counted every one twice. Vintage casks there cost more and pay more while the shelves are bare. The empties still smell of what they held. So do the clerks.
EV44_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV45_TITLE | pool event title | Cut glimmers sell out
EV45_BODY | pool event text | A wedding season sold every cut glimmer at Quillon in a day. Cut glimmers there cost more and pay more while the cutters catch up. The jewellers' lamps burn all night. In one shop a stone hums very softly, and is not for sale.
EV45_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV46_TITLE | pool event title | The smelter goes cold
EV46_BODY | pool event text | Voltara's smelter lost its heat to a cracked line, and the casting stopped. Ingot there costs more and pays more until the furnace is lit again. The crew stand by the dead furnace. The metal inside still ticks as it shrinks.
EV46_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV47_TITLE | pool event title | Seam alloy piles up at Quillon
EV47_BODY | pool event text | A convoy of seam alloy reached Quillon on one tide, and the builders had already bought. Seam alloy there costs less and pays less. The bales are stacked to the lamps, and a clerk is counting them for the third time. The count has not improved.
EV47_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV48_TITLE | pool event title | Ashgate wants girders
EV48_BODY | pool event text | Ashgate's builders drew a new ring of homes in a single week, and every furnace is asked for ingot. Ingot there costs more and pays more. The draughtsmen call the plan final. The ingots on the dock ring faintly when the wind turns.
EV48_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.

EV49_TITLE | pool event title | Quarantine at the culture lab
EV49_BODY | pool event text | A culture in Brannock's lab grew a colour it was not supposed to, and the doctors closed the port to look at it. Routes touching Brannock are blocked for a while. The form says contained. The vats say nothing and go on growing.
EV49_EFF | pool event rivals line, {market} filled by the game | Rivals: no change in {market} strength or growth.

EV50_TITLE | pool event title | Spores come in cheap
EV50_BODY | pool event text | A damp season at Mossfell raised spores in every crate, more than anyone could sell. Spore cultures there cost less and pay less. The growers say a surplus is only an ambition that lost its form. The crates sweat in rows.
EV50_EFF | pool event rivals line, {market} filled by the game | Rivals: {market} strength and growth stay as they were.

EV51_TITLE | pool event title | Gene seed is rationed
EV51_BODY | pool event text | A clinic ring at Quillon rationed gene seed after one failed batch, and every ward asked for double its share. Gene seed there costs more and pays more. The ration form has a line for reasons and a line for exceptions. Only the second is full.
EV51_EFF | pool event rivals line, {market} filled by the game | Rivals: none of the three changes in {market}.
