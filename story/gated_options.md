# Skill-gated options (proposal, 2026-11-04)


Flavour pass 2026-11-04 (Military and Biotech): the Military and Biotech rows carry a Story hook, the line that explains the gate in the world's voice. MIL_A3 button changed from 'cells' to 'notes' because pulse cells are hidden when MIL_2 is first learned. Russian stays on hold: RU cells of changed rows are stale. No numbers here; the economy designer sets them.
Status: SPEC ONLY. Not built, not in data. Texts are ready to paste once the economy designer sets the numbers and the gameplay programmer builds the gate. Button limit: EN 28, RU 39. Effect line keeps the shape "Get: ... Cost: ... Rivals: ...". Result text: reuse the result of the base option, plus one added line from the story designer on request.

Rule for every row: the option appears (or is cheaper) only if the player has learned the node. Without the skill the player sees two options, as today. "Base" is the option the gated one improves; "better" means a smaller cost or a larger payoff, the size is the economy designer's.

| Step | New option id | Node (id, name) | Button EN | Button RU | What the skill changes | Suggested effect |
|---|---|---|---|---|---|---|
| MIL_A1 | opt_c | MIL_1 Drydock Deals | Sign on your drydock record | Подписать по записи доков | Option appears only with the skill. Story: Sulo takes your drydock record in place of the deposit. | As opt_a, deposit waived |
| MIL_A2 | opt_c | MIL_3 Quick Loading | Load one hauler for both | Один рейс для обоих флотов | Option appears only with the skill. Story: Brask loads one hauler for both fleets, and the Admiralty gets its wish. | As opt_a, no Ship upkeep rise |
| MIL_A3 | opt_c | MIL_2 Cell Casting | Check it against your notes | (Russian on hold) | Option appears only with the skill. Story: Brask checks the ledger against your own casting rites, so Sulo's thumb goes unpaid. | As opt_b, no credits to the quartermaster |
| MIL_B1 | opt_c | MIL_1 Drydock Deals | Use your drydock contacts | Использовать связи в доках | Option appears only with the skill. Story: Your drydock friends fit the sensors at cost, and the cousin's firm sees nothing. | Cheap workaround: small cost, Military volume up a little for a while, no rival change |
| MIL_B2 | opt_c | MIL_4 Armour Plating | Swap from your own stock | Заменить из своего запаса | Option appears only with the skill. Story: Your armourers hold a spare relay with a living serial, so no ship idles. | As opt_b, no volume dip |
| MIL_B3 | opt_c | MIL_5 Embargo Desk | Fill the hall by the Desk | Заполнить зал через Desk | Option appears only with the skill. Story: The Embargo Desk fills the hall with buyers Vaux never invited. | As opt_a, cost halved |
| MIL_B4 | opt_c | MIL_6 Contract Doctrine | Write your own doctrine | Написать свою доктрину | Option appears only with the skill. Story: Your doctrine writes the roster, so the estimate finally gets a last page. | As opt_a, no volume dip |
| LUX_A1 | opt_c | LUX_1 Price Whisper | Quote her next price | Назвать ей цену следующего цикла | Option appears only with the skill | As opt_a, no volume dip |
| LUX_A2 | opt_c | LUX_2 Fine Finishing | Hire him on your finish | Нанять его под вашу отделку | Cheaper | As opt_a, fees halved |
| LUX_A3 | opt_c | LUX_3 Event Forecast | Time the order to the news | Подгадать заказ под новости | Option appears only with the skill | As opt_a, no hallmark cost |
| LUX_B1 | opt_c | LUX_1 Price Whisper | Show the evening's prices | Показать цены вечера | Cheaper | As opt_b, stall cost halved |
| LUX_B2 | opt_c | LUX_2 Fine Finishing | Let the atelier read it fast | Дать ателье быстро прочесть | Extra payoff | As opt_a, no price dip |
| LUX_B3 | opt_c | LUX_5 Patron's List | Fix it from your own list | Зафиксировать по своему списку | Option appears only with the skill | As opt_a, no volume loss |
| LUX_B4 | opt_c | LUX_6 Hallmark | Take the desk on your hallmark | Занять стол по вашему клейму | Cheaper | As opt_a, no dues |
| MIN_A1 | opt_c | MIN_1 Fabrication Licence | Cast the cable at the Fabric | Отлить трос на Fabric | Cheaper | As opt_b, cable cost halved |
| MIN_A2 | opt_c | MIN_2 Smelting | Brace with your own ingot | Укрепить своим ingot | Cheaper | As opt_a, no credits |
| MIN_A3 | opt_c | FND_PROSPECT Prospecting | Run it by your own survey | Пройти по своей разведке | Option appears only with the skill | As opt_a, no chart cost, no gain for the rival |
| MIN_B1 | opt_c | MIN_3 Cold Survey | Survey it in-house | Разведать своими силами | Cheaper | As opt_b, survey cost halved |
| MIN_B2 | opt_c | MIN_4 Alloying | Rotate the crews | Сменять бригады по кругу | Cheaper | As opt_b, no shift pay |
| MIN_B3 | opt_c | MIN_6 Lattice Works | Sell the extra yield | Продать лишний выход | Extra payoff | As opt_a, smaller volume dip |
| MIN_B4 | opt_c | MIN_5 Deep Cut | File from your own survey | Подать по своей разведке | Cheaper | As opt_a, no filing cost |
| BIO_A1 | opt_c | BIO_1 Standing Orders | Test it on standing orders | Испытать по постоянным заказам | Cheaper. Story: Standing Orders let Fenn test on forms already filed, with no new fee. | As opt_a, test cost halved |
| BIO_A2 | opt_c | BIO_3 Seed Bank | Hold the batch in your bank | Держать партию в своём банке | Option appears only with the skill. Story: Marrow tests a sample from your own bank, so no funding is needed. | As opt_a, no funding cost |
| BIO_A3 | opt_c | BIO_6 Hardy Strains | Check seals while running | Проверять уплотнения на ходу | Option appears only with the skill. Story: Hardy Strains let Fenn check the seals with the lab still running. | As opt_a, no idle cycles |
| BIO_B1 | opt_c | BIO_2 Culture Banks | Draw from your culture banks | Взять из своих банков культур | Cheaper. Story: A reserve strain comes out of your own culture bank, with no purchase. | As opt_a, no purchase cost |
| BIO_B2 | opt_c | BIO_4 Gene Splicing | Splice the new trait | Закрепить новую черту | Extra payoff. Story: Gene Splicing fixes the change before it spreads, so no stock stays back. | As opt_a, no volume dip |
| BIO_B3 | opt_c | BIO_5 Clinic Contracts | Take the slot by contract | Взять ячейку по контракту | Cheaper. Story: A clinic contract is your credential at the call, and the slot costs less. | As opt_b, slot cost halved |
| BIO_B4 | opt_c | BIO_3 Seed Bank | Use your own racks | Использовать свои стеллажи | Option appears only with the skill. Story: Your own racks hold the stock, and the derelict hull stays sealed. | As opt_a, no volume dip |
| EV17 | third button | MIL_1 Drydock Deals | Call your drydock tugs | Вызвать буксиры доков | Cheaper | Debris cleared, fee halved |
| EV18 | third button | FND_PERMIT Permit Charter | File the permit terms first | Сначала подать условия допуска | Extra payoff | As build, smaller drop in resources |
| EV20 | third button | MIL_4 Armour Plating | Plate the storage | Обшить склад бронёй | Option appears only with the skill | As decline, no hit chance |

Optional, no gate (owner's example for MIL_B1): opt_d "Disobey" / "Неподчинение": Sell price on one planet down for a set number of cycles, no cost now. Needs a new effect type; see ideas.md item 6.

Structural requests (all rows above): one added option per step (opt_c), shown only when the node is learned; the Get/Cost/Rivals line is generated by the same template. EV17, EV18, EV20 need a third button on the choice screen (events.md R4).
