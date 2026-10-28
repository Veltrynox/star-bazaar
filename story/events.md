# Events, system 1 (draft 2, tone rework)

Format: ID | title (max 32) | tag | kind, then text (max 280). Appears in the event popup under "News from the sky" (NOT_EVENT_PREFIX), with an OK button (BTN_OK).
Tags are from the brief only: [price up: planet, commodity], [price down: ...], [planet closed: planet]. Effect size and duration are the Economy Designer's. Planet closed means closed for a while; routes touching it are blocked. The Plan, quotas and the Bureau are story only and change nothing.
Kind: P = plain price news, Q = quiet musing, I = ironic. Dread = one small odd detail.

EV01 | Energy glut at Voltara | [price down: Voltara, energy] | P
Voltara's reactors beat their quota by a wide margin, and nobody asked for the surplus. Energy there costs less to buy and pays less to sell. The Plan calls it a triumph. The reactors hum a little louder, as if pleased.

EV02 | Blight on Tillam's terraces | [price up: Tillam, food] | P
A blight went through the Tillam terraces, grey and fast, and the leaves came away like paper. Food there costs more and pays more. The committee will study it. The terraces will not wait for the study.

EV03 | A good harvest at Ashgate | [price down: Ashgate, food] | P
Ashgate's harvest came in above the Plan. Food there costs less to buy and pays less to sell. A surplus is a fine thing to share, and a poor thing to sell. The Bureau has issued a form for gratitude.

EV04 | Voltara goes hungry | [price up: Voltara, food] | P
The crews on Voltara work long shifts and eat what arrives. Less arrived. Food there costs more and pays more. Rations were reduced equally for everyone, which is what makes it fair and not what makes it better.

EV05 | Cold season on Tillam | [price up: Tillam, energy] | P
A cold season on Tillam. The heaters run day and night, so energy there costs more and pays more. Frost forms on the inside of the ducts, in patterns no one has agreed to explain.

EV06 | Ashgate lights its furnaces | [price up: Ashgate, energy] | P
Ashgate's foundries restarted all at once to meet the new plan. Energy there costs more and pays more. The furnaces are very bright. Nobody asked where the energy would come from. That is where a small company comes in.

EV07 | Tillam stops work | [planet closed: Tillam] | P
Tillam's dock workers stopped work over a dispute the committee calls a misunderstanding. The port is closed for a while. Routes touching Tillam are blocked until it reopens. The ships do not take sides.

EV08 | Ashgate seals its port | [planet closed: Ashgate] | P
Ashgate sealed its port after something unnamed was found in the lower docks, and the doctors say little. It reopens when they say so. Routes touching Ashgate are blocked until then. Caution is shared equally, including by you.

EV09 | Voltara's grid fails | [planet closed: Voltara] | I
A fault in Voltara's grid took the port with it. The planet that powers everyone cannot keep its own lights on. Closed for a while. Routes touching Voltara are blocked until it reopens. The Plan will be revised, backwards.

EV10 | The lender walks the market | [price down: Tillam, energy] | Q
A lender's agent walked Tillam's market, and everyone sold what they had to settle. Energy there costs less and pays less for now. Even in a society that owns everything together, someone has found a way to owe.

EV11 | A foreman says enough | [price down: Ashgate, energy] | Q
An Ashgate foreman declared that the shift had made enough and sent everyone home. Energy there costs less and pays less. Enough is a number the Plan does not print. It spread through the docks faster than the form to stop it.

EV12 | Good news travels slowly | [price up: Voltara, energy] | Q
Word from other systems arrives late, and Voltara's buyers stopped waiting for it. They bought, so energy there costs more and pays more. Out past the beacons the dark is patient. It has always been the one thing nobody has to share.

EV13 | A family buys the table | [price up: Ashgate, food] | Q
A family with old credits bought Ashgate's food contracts, all of them, quietly. Food there costs more and pays more. The Commons owns everything together, and a family has found the part that is still for sale. You are in no position to judge.

EV14 | The inspector's count | [price down: Voltara, food] | I
An inspector counted Voltara's food stores and found them sufficient, on a form. The market believed the form, so food there costs less and pays less. The crews are still hungry, but correctly accounted for.

EV15 | A festival of founders | [price up: Tillam, food] | I
Tillam declared a festival to honour its founding, though three committees claim to be the founders. Food there costs more and pays more. Everyone agrees on the feast. Nobody agrees on who is hosting, so everyone is.

EV16 | A half-empty ship departs | [price down: Tillam, food] | Q
A ship left Tillam half empty, bound for a rock no one has charted. Those who stayed sold spare food to afford staying. Food there costs less and pays less. The departure form was filed in advance. The return form was not.

# Events, choice events (draft 1, T96 T100 T103 T108, 2026-10-28)

Format: ID | place | tag, then text. Choice events use the choice screen limits: title max 40, body max 280, button max 28, effect line max 90. Outcome texts are event popups: title max 32, text max 280, shown under NOT_EVENT_PREFIX with BTN_OK. No numbers: the game inserts any amount through a placeholder. Tags name the effect in words as the owner described it; the Economy Designer sets size and duration. Planet = {planet}.

## Debris in orbit [route efficiency down: {planet}, while the debris stays]
EV17_TITLE | choice title | Debris over {planet}
EV17_BODY | choice body | A cloud of broken hull and spent tanks has settled into orbit over {planet}. A contractor offers to clear it for a fee. The Bureau has filed the debris as "unowned", which is how it stayed.
EV17_PAY_BTN | button | Pay the fee
EV17_PAY_EFF | effect line | Pay the fee. The debris is cleared and routes from {planet} run as before.
EV17_LEAVE_BTN | button | Leave the debris
EV17_LEAVE_EFF | effect line | Routes from {planet} carry less while the debris stays. It does not clear itself.
EV17_PAID_TITLE | popup title | Orbit over {planet} is clear
EV17_PAID | popup | The contractor swept the orbit and signed the form. Routes from {planet} carry their full load again. The debris went somewhere. The form does not say where.
EV17_LEFT_TITLE | popup title | Debris stays over {planet}
EV17_LEFT | popup | You left the debris. Ships from {planet} thread around it and carry less. The offer stays open. The debris turns slowly, in no hurry.

## Solar shield [shield built: affects only planets the player can buy later; residents unhappy]
EV18_TITLE | choice title | A shield for the sun
EV18_BODY | choice body | Engineers propose a partial shield over the sun. Residents dislike it. It would change the resource mix on planets you can buy later: some resources fall, and you earn more profit and energy there. Planets you already own are not affected.
EV18_BUILD_BTN | button | Build the shield
EV18_BUILD_EFF | effect line | Planets you can buy later change: some resources drop, profit and energy rise.
EV18_SKIP_BTN | button | Do not build
EV18_SKIP_EFF | effect line | Nothing changes. The sun keeps its full light.
EV18_BUILT_TITLE | popup title | The shield is up
EV18_BUILT | popup | The shield is in place. Residents are unhappy and say so, in writing. On planets you can buy later, some resources fall, and profit and energy rise. Planets you own are unchanged. The sky is a little dimmer.
EV18_SKIPPED_TITLE | popup title | The shield stays on paper
EV18_SKIPPED | popup | The plans go back into the cabinet. Residents are relieved and file no thanks. Nothing changes in any market.

## Nomads and pirates [choice: evict nomads or let them stay; pirates reduce trade volume; hire to clear pirates, at a cost]
EV19_TITLE | choice title | Nomads on the asteroids
EV19_BODY | choice body | Nomad families live on the asteroids you could mine. They have no entry on the Common Ledger, which the Bureau regards as a personal failing. You can evict them and mine the rock, or let them stay.
EV19_EVICT_BTN | button | Evict the nomads
EV19_EVICT_EFF | effect line | The asteroids open for mining. Some nomads turn to piracy, and pirates rise.
EV19_STAY_BTN | button | Let them stay
EV19_STAY_EFF | effect line | The asteroids stay closed to mining. No pirates come of it.
EV19_EVICTED_TITLE | popup title | The asteroids are cleared
EV19_EVICTED | popup | The nomads left on the next tide, quietly. The rock is yours to mine. Some of them did not go far, and they now keep ships and a grudge. Pirates rise.
EV19_STAYED_TITLE | popup title | The nomads stay
EV19_STAYED | popup | You let the nomads stay. Their lamps burn on the rock, small and steady. The asteroids remain closed to mining.
EV19_PIRATES_TITLE | popup title | Pirates reduce trade
EV19_PIRATES | popup | Pirates now work the lanes, and fewer cargoes get through. Trade volume falls while they stay. The Bureau has opened a file on them. It is a thin file.
EV19_HIRE_BTN | button | Hire a clearance crew
EV19_HIRE_EFF | effect line | Pay to have the pirates cleared. It costs credits and removes their effect on trade.

## Asteroid approach [warning; pay the state: no skill point, no reputation; decline: 50/50 bad outcome or nothing; bad outcome is storage destroyed or storage capacity cut]
EV20_TITLE | choice title | An asteroid is approaching
EV20_BODY | choice body | The Bureau reports an asteroid on a slow path toward the system. The state can deflect it for a payment. The form for refusing is shorter than the form for paying. The dark outside has begun to look closer.
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
