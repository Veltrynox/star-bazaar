# Events, system 1 (draft 2, tone rework)

Format: ID | title (max 32) | tag | kind, then text (max 280). Appears in the event popup under "News from the sky" (NOT_EVENT_PREFIX), with an OK button (BTN_OK).
Tags are from the brief only: [price up: planet, commodity], [price down: ...], [planet closed: planet]. Effect size and duration are the Economy Designer's. Planet closed means closed for a while; routes touching it are blocked. The Plan, quotas and the Bureau are story only and change nothing.
Kind: P = plain price news, Q = quiet musing, I = ironic. Dread = one small odd detail.

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
