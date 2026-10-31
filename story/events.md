# Events, system 1 (draft 2, tone rework)

Format: ID | title (max 32) | tag | kind, then text (max 280). Appears in the event popup under "News from the sky" (NOT_EVENT_PREFIX), with an OK button (BTN_OK).
Tags are from the brief only: [price up: planet, commodity], [price down: ...], [planet closed: planet]. Effect size and duration are the Economy Designer's. Planet closed means closed for a while; routes touching it are blocked. The Plan, quotas and the Bureau are story only and change nothing.
Kind: P = plain price news, Q = quiet musing, I = ironic. Dread = one small odd detail.

EV01 | Voltara's reactors overflow | [price down: Voltara, energy] | P
Voltara's reactors ran past quota and kept running. Nobody ordered the surplus, so energy there is cheap now, and the reactors hum louder, pleased with themselves. Buy while the Plan argues about it.

EV02 | Grey blight on Tillam's terraces | [price up: Tillam, food] | P
A grey blight is eating Tillam's terraces. Leaves come apart like wet paper. Food there is dear now and pays well. The committee will study the blight. The blight will not wait for the committee.

EV03 | Ashgate's harvest comes in heavy | [price down: Ashgate, food] | P
Ashgate brought in more than the Plan allowed for. Food there is cheap to buy and pays little to sell. A surplus is a gift to the Commons. A surplus that nobody moves is a loss, and someone has to move it.

EV04 | Voltara's crews go hungry | [price up: Voltara, food] | P
Voltara's crews are on long shifts and short rations. Less food arrived than was counted. Food there costs more and pays more. The Bureau cut every ration by the same amount, which it calls fair. Hungry people call it hunger.

EV05 | Frost on Tillam | [price up: Tillam, energy] | P
Winter came early to Tillam. The heaters run day and night, so energy there costs more and pays more. Frost has begun to grow inside the ducts, in patterns no one has agreed to explain. Someone must keep the lights on.

EV06 | Ashgate lights every furnace | [price up: Ashgate, energy] | P
Ashgate restarted every foundry at once to meet a plan that arrived this morning. Energy there costs more and pays more. The furnaces glare through the smoke. Nobody asked where the energy comes from. Someone with a ship will carry it.

EV07 | Tillam's docks go on strike | [planet closed: Tillam] | P
The dock crews of Tillam walked out, and the committee calls it a misunderstanding. The port is closed for a while. Routes touching Tillam are blocked until it reopens. The ships wait outside, and they do not take sides.

EV08 | Ashgate seals its port | [planet closed: Ashgate] | P
Something was found in Ashgate's lower docks, and the doctors will say only that the port is closed. It reopens when they say so. Routes touching Ashgate are blocked until then. Caution is shared equally, and so is the fear.

EV09 | Voltara goes dark | [planet closed: Voltara] | I
A fault in Voltara's grid took the port down with it. The planet that powers everyone cannot keep its own lights on. Closed for a while. Routes touching Voltara are blocked until it reopens. The Plan will be revised, backwards.

EV10 | A lender walks Tillam's market | [price down: Tillam, energy] | Q
A lender's agent walked Tillam's market and bought up every debt in sight. Sellers settled what they owed and sold what they had. Energy there costs less and pays less for now. Even a society that owns everything together can find a way to owe.

EV11 | Ashgate's foreman says enough | [price down: Ashgate, energy] | Q
An Ashgate foreman looked at the numbers, declared the shift had made enough, and sent the crews home. Energy there costs less and pays less. Enough is a figure the Plan does not print. The word moved through the docks faster than any form.

EV12 | Voltara buys before the news | [price up: Voltara, energy] | Q
Word from the other systems arrives late, and Voltara's buyers would not wait for it. They bought, so energy there costs more and pays more. Out past the beacons the dark is patient. It is the one thing nobody has been asked to share.

EV13 | A family buys Ashgate's food | [price up: Ashgate, food] | Q
A family with old credits quietly bought up Ashgate's food contracts, all of them. Food there costs more and pays more. The Commons owns everything together, and here is a part still for sale. You are in no position to judge.

EV14 | The inspector's count | [price down: Voltara, food] | I
An inspector counted Voltara's food stores and found them sufficient, on a form. The market believed the form, so food there costs less and pays less. The crews are still hungry, now correctly accounted for.

EV15 | Tillam's festival of founders | [price up: Tillam, food] | I
Tillam declared a festival to honour its founders. Three committees claim to be them. Food there costs more and pays more. Everyone agrees on the feast. Nobody agrees who is hosting, so everyone is, and nobody is clearing the tables.

EV16 | A ship leaves Tillam half empty | [price down: Tillam, food] | Q
A ship left Tillam half empty, bound for a rock nobody has charted. The people who stayed sold their spare food to pay for staying. Food there costs less and pays less. The departure form was filed in advance. The return form was not.

# Events, choice events (draft 1, T96 T100 T103 T108, 2026-10-28)

Format: ID | place | tag, then text. Choice events use the choice screen limits: title max 40, body max 280, button max 28, effect line max 90. Outcome texts are event popups: title max 32, text max 280, shown under NOT_EVENT_PREFIX with BTN_OK. No numbers: the game inserts any amount through a placeholder. Tags name the effect in words as the owner described it; the Economy Designer sets size and duration. Planet = {planet}.

## Debris in orbit [route efficiency down: {planet}, while the debris stays]
EV17_TITLE | choice title | Wreckage is circling {planet}
EV17_BODY | choice body | The wreck of a hundred ships has settled into orbit over {planet}, hull plates and spent tanks turning slowly. A contractor will sweep it for a fee. The Bureau filed the wreck as unowned, which is how it stayed up there.
EV17_PAY_BTN | button | Pay the fee
EV17_PAY_EFF | effect line | Pay the fee. The debris is cleared and routes from {planet} run as before.
EV17_LEAVE_BTN | button | Leave the debris
EV17_LEAVE_EFF | effect line | Routes from {planet} carry less while the debris stays. It does not clear itself.
EV17_PAID_TITLE | popup title | Orbit over {planet} is clear
EV17_PAID | popup | The contractor swept the orbit and filed the receipt. Routes from {planet} carry their full load again. The wreck went somewhere. The receipt does not say where.
EV17_LEFT_TITLE | popup title | Debris stays over {planet}
EV17_LEFT | popup | You left the wreck. Ships from {planet} thread around it and carry less. The offer stays open. The wreck turns slowly, in no hurry to leave.

## Solar shield [shield built: affects only planets the player can buy later; residents unhappy]
EV18_TITLE | choice title | Shade the sun
EV18_BODY | choice body | Engineers want to shade part of the sun with a shield. The residents hate it and say so in writing. It would reshape the markets on planets you can buy later: some goods get cheaper, while profit and energy rise. What you already own stays as it is.
EV18_BUILD_BTN | button | Build the shield
EV18_BUILD_EFF | effect line | Planets you can buy later change: some resources drop, profit and energy rise.
EV18_SKIP_BTN | button | Leave the sun alone
EV18_SKIP_EFF | effect line | Nothing changes. The sun keeps its full light.
EV18_BUILT_TITLE | popup title | The shield is up
EV18_BUILT | popup | The shield is up and the sky is dimmer. Residents are furious and have filed it in triplicate. On planets you can buy later, some goods get cheaper while profit and energy climb. Planets you own are untouched.
EV18_SKIPPED_TITLE | popup title | The shield stays on paper
EV18_SKIPPED | popup | The plans go back in a drawer. The residents are relieved and file no thanks. Nothing changes in any market.

## Nomads and pirates [choice: evict nomads or let them stay; pirates reduce trade volume; hire to clear pirates, at a cost]
EV19_TITLE | choice title | Nomads on the asteroids
EV19_BODY | choice body | Nomad families live on the asteroids you could mine. They are not on the Common Ledger, which the Bureau takes as a personal failing. Evict them and the rock is yours. Or let them stay and keep their lamps burning.
EV19_EVICT_BTN | button | Evict the nomads
EV19_EVICT_EFF | effect line | The asteroids open for mining. Some nomads turn to piracy, and pirates rise.
EV19_STAY_BTN | button | Let them stay
EV19_STAY_EFF | effect line | The asteroids stay closed to mining. No pirates come of it.
EV19_EVICTED_TITLE | popup title | The asteroids are cleared
EV19_EVICTED | popup | The nomads left on the next tide, quietly. The rock is yours to mine. Some did not go far, and they now keep ships and a grudge. Pirates rise.
EV19_STAYED_TITLE | popup title | The nomads stay
EV19_STAYED | popup | You let the nomads stay. Their lamps burn on the rock, small and steady. The asteroids remain closed to mining.
EV19_PIRATES_TITLE | popup title | Pirates reduce trade
EV19_PIRATES | popup | Pirates now work the lanes, and fewer cargoes get through. Trade volume falls while they stay. The Bureau has opened a file on them. It is a thin file.
EV19_HIRE_BTN | button | Hire a clearance crew
EV19_HIRE_EFF | effect line | Pay to have the pirates cleared. It costs credits and removes their effect on trade.

## Asteroid approach [warning; pay the state: no skill point, no reputation; decline: 50/50 bad outcome or nothing; bad outcome is storage destroyed or storage capacity cut]
EV20_TITLE | choice title | An asteroid is approaching
EV20_BODY | choice body | A rock is coming in on a slow path, and the Bureau has noticed it the way it notices everything: late. The state can turn it aside for a fee. The form for refusing is shorter. The dark outside has started to look closer.
EV20_PAY_BTN | button | Pay the state
EV20_PAY_EFF | effect line | Cost: payment to the state. Asteroid dealt with. The company gains one expansion point.
EV20_DECLINE_BTN | button | Decline
EV20_DECLINE_EFF | effect line | An even chance: company storage is hit, or nothing happens.
EV20_PAID_TITLE | popup title | The asteroid is deflected
EV20_PAID | popup | The state turned the rock aside and sent a receipt. The company gains one expansion point for the trouble. The asteroid drifts on, toward someone else's sky.
EV20_REWARD | notice (shown after EV20_PAID) | Event reward: the asteroid is dealt with and the company gains an expansion point.
EV20_HIT_TITLE | popup title | Company storage destroyed
EV20_HIT_DESTROYED | popup | The asteroid struck {planet}. Your company storage there is gone, and what it held with it. The Bureau has recorded the loss as an adjustment of the Common Ledger.
EV20_HIT_CAPACITY | popup | The asteroid grazed {planet}. Your company storage there is cracked and holds less than before. The Bureau has recorded the damage as "partial".
EV20_MISS_TITLE | popup title | The asteroid passes
EV20_MISS | popup | The asteroid passed the system and kept going. Nothing was hit and nothing changes. The Bureau has withdrawn its warning, with regret.
