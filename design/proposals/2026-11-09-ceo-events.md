# Star Bazaar: CEO events, five per CEO (2026-11-09)

Author: story-designer. PROPOSAL ONLY. Nothing here is built; no story/*.md, data/ or game/ file was touched. Numbers are never given: every amount is marked UNKNOWN for the economy owner. English only.
Read: CLAUDE.md, story/voice.md, data/ceos.json, game/events.gd (rotation, tag parser), game/conditions.gd (atoms), data/events.json (shape), story/events.md (format).

## 1. How events rotate today (facts from game/events.gd)

- An event is due every `event_interval` cycles (4 now), not in cycle 1. One random pick per due cycle.
- `random_id` draws uniformly from the shared pool: kept events (`Chains.pool_kept`), EV40-EV51 (`pool_new`) and weather rows. Each id fires at most once per run (`_fired`), so within a run nothing repeats. Repeats are across runs: every CEO draws from the same small pool (about 35 rows, many gated by goods the player cannot see yet).
- A row may carry `visible_when` (any tree of conditions.gd atoms) and `min_cycle`. `available()` checks both, plus good visibility (Availability) and open planets.
- Choice rows of the generic pool use one tag per choice (`choice_effects` returns the first effect only). Effect kinds the parser knows: price up, price down, planet closed, shortage, congestion, cash, stock, debris, asteroid.

## 2. How CEO events plug in (no new atom needed)

- The branch atom `branch_is:<market>` already means the CEO: each market is one CEO (min = Marek Voss, lux = Idris Kane, mil = Sela Oru, bio = Tamsin Hale; data/ceos.json). Each CEO event gets `visible_when: "branch_is:<market>"`. Only that CEO's run can draw it. Side effect to accept: an old save with no branch sees all four sets (the atom is true then). Harmless.
- Pool entry: each id is added to the pool like EV40-EV51 (`pool_new` row in chains.json, or the kept list). Once per run falls out of `_fired`. No chain, no schedule, no follow-up.
- Weight: uniform draw means a CEO gets 5 of about 40 rows, so about one event in eight is theirs. That is thin for a run of about 19 events. Option A (default, no code): accept it. Option B (small code, owner call): a `weight` key on the row (CEO events weight 2) in `random_id`. Option C: draw a CEO event first whenever one is available and the last event was not a CEO event (guarantees about one in three). Recommendation: B.
- Spacing: nothing can repeat inside a run. To stop two CEO events back to back, add the rule in C ("not twice in a row"), or leave it to chance.
- Gate: `min_cycle` 5 so the first draw (cycle 5, the first event after the tutorial) is a generic one. UNKNOWN for the owner: first cycle and any extra gap.
- Progressive disclosure: every text names only energy and food and the three System 1 planets, all open from the start. No market good, workshop, Space Storage or hidden feature is named. Planet and good are in the tag, so `good_available` and `known_planets` gate them as for any pool row.

## 3. Rules used

- Kinds: P plain news (no choice), Q quiet musing, I ironic, C choice. Each CEO has one plain price event, one plain or shortage event, and three choices of different shapes:
  - pay or bear: pay credits now, or take a timed cost (congestion or lower price). Same shape as EV17 debris.
  - pick a world: two price-up effects, you choose where. Both help, only where you have stock.
  - goods or credits: a gift paid in credits or in goods in Company storage. UNKNOWN: amounts must be worth the same to the player.
- A choice never has a free win: every option either costs or is a gain the other option replaces.
- Limits (voice.md): title 32, body 280, button 24, effect line 90, outcome title 32, outcome text 280. No digits, no dashes, no exclamation marks.
- Plain news ends with the price effect in words first, then the musing, as the voice asks.
- Outcome (popup) texts are listed for each choice so the programmer can paste them; choice popups follow EV17 (title, text, shown under NOT_EVENT_PREFIX with BTN_OK).

## 4. Marek Voss (Minerals, Tramp, Thrift, Old Contacts)

Personality: counts every bolt, distrusts luck, has contacts everywhere. Condition for all five: `branch_is:min`, min_cycle UNKNOWN (suggest 5).

### EV70 | P/Q | plain | [price up: Tillam, food]
EV70_TITLE | A note from the old yard
EV70_BODY | A man Marek once paid for spare parts sends a note. Tillam will want food soon. He gives no reason and Marek asks for none. Food at Tillam sells for more for a few cycles.

### EV71 | C | goods or credits | cash vs stock
EV71_TITLE | The count is off by a crate
EV71_BODY | The yard counts your spare parts and finds one crate more than the page says. Marek will not keep what is not written down. The yard pays you for it, in credits or in energy at Voltara.
- EV71_CASH_BTN | Take the credits | EV71_CASH_EFF | Get: a small sum in credits. | tag [cash: +N] (N UNKNOWN) | EV71_CASH_TITLE | Credits, counted twice | EV71_CASH | The clerk counts the credits out twice and so does Marek. The page and the crate now agree.
- EV71_GOODS_BTN | Take the energy | EV71_GOODS_EFF | Get: energy in Company storage at Voltara. | tag [stock: Voltara, energy, +N] (N UNKNOWN) | EV71_GOODS_TITLE | Energy, on the shelf | EV71_GOODS | The crate is swapped for sealed energy cells. Marek checks every seal before he signs.

### EV72 | C | pay or bear | cash vs congestion
EV72_TITLE | A clerk wants every bolt
EV72_BODY | A Bureau clerk at Ashgate wants to check every part aboard. Marek's books are in order and he says so. The check takes days either way. A fee hurries it. Or the line grows at the dock.
- EV72_PAY_BTN | Pay to hurry it | EV72_PAY_EFF | Cost: a small sum in credits. | tag [cash: -N] (N UNKNOWN) | EV72_PAID_TITLE | The clerk is quick | EV72_PAID | The clerk stamps the last page and does not look up. Marek files the receipt first.
- EV72_WAIT_BTN | Let the line grow | EV72_WAIT_EFF | Cost: lanes that touch Ashgate cost more per trip for a few cycles. | tag [congestion: Ashgate] | EV72_WAITED_TITLE | The dock is full | EV72_WAITED | Ships stack up outside Ashgate. Nobody leaves, and nobody is told when.

### EV73 | C | pick a world | price up vs price up
EV73_TITLE | One crew, two docks
EV73_BODY | Marek can lend a work crew to one dock for a short time. Voltara's yard would run hot. Tillam's would run light. Both owe him a favour. The dock that gets the crew sees trade pick up for a few cycles.
- EV73_VOLT_BTN | Send them to Voltara | EV73_VOLT_EFF | Get: energy at Voltara sells for more for a few cycles. | tag [price up: Voltara, energy] | EV73_VOLT_TITLE | Voltara's yard is busy | EV73_VOLT | The crew works two shifts at Voltara. The yard master writes the favour in a small book.
- EV73_TIL_BTN | Send them to Tillam | EV73_TIL_EFF | Get: food at Tillam sells for more for a few cycles. | tag [price up: Tillam, food] | EV73_TIL_TITLE | Tillam's yard is busy | EV73_TIL | The crew works easy hours at Tillam. The yard master pays back in goodwill, which Marek also counts.

### EV74 | Q | plain | [price down: Ashgate, energy]
EV74_TITLE | Luck pays Ashgate once
EV74_BODY | A shipment of cells reaches Ashgate by a mistake nobody owns. Energy at Ashgate sells for less for a few cycles. Marek calls it luck, and does not trust it. He is right to check the second page.

## 5. Idris Kane (Luxury, Dart, Haggling, Quick Read)

Personality: broker with a famous smile, buys lunch for rivals, reads boards, spends freely. Condition for all five: `branch_is:lux`, min_cycle UNKNOWN (suggest 5).

### EV76 | I | plain | [price up: Voltara, food]
EV76_TITLE | Lunch at a buyer's table
EV76_BODY | Idris buys lunch for a buyer from Voltara and leaves with the buyer's order in his head. Voltara wants food. Food at Voltara sells for more for a few cycles. The buyer thinks it was a coincidence.

### EV77 | C | pay or bear | cash vs price down
EV77_TITLE | An old broker wants thanks
EV77_BODY | A broker who says he taught Idris everything wants to be thanked. Idris smiles. The broker's friends sit at Tillam's dock, and they are patient. Thank him in credits, or let them sell low at Tillam for a while.
- EV77_PAY_BTN | Thank him | EV77_PAY_EFF | Cost: a small sum in credits. | tag [cash: -N] (N UNKNOWN) | EV77_PAID_TITLE | A warm farewell | EV77_PAID | The broker takes the credits and the credit, and tells everyone at Tillam what a fine pupil he had.
- EV77_SKIP_BTN | Smile and go | EV77_SKIP_EFF | Cost: food at Tillam sells for less for a few cycles. | tag [price down: Tillam, food] | EV77_SKIPPED_TITLE | The friends sell low | EV77_SKIPPED | The broker's friends sell food at Tillam for what it fetches. Idris keeps the smile. It is the only thing he keeps.

### EV78 | C | pick a world | price up vs price up
EV78_TITLE | The board shows two gaps
EV78_BODY | Idris reads Tillam's price board and sees two gaps. He can whisper one of them to one buyer. Whoever hears it first pays more for a few cycles, and the other gap closes by itself.
- EV78_TIL_BTN | Tell the Tillam buyer | EV78_TIL_EFF | Get: energy at Tillam sells for more for a few cycles. | tag [price up: Tillam, energy] | EV78_TIL_TITLE | Tillam buyer is pleased | EV78_TIL | The Tillam buyer nods and says nothing. Prices move by the next bell.
- EV78_ASH_BTN | Tell the Ashgate buyer | EV78_ASH_EFF | Get: energy at Ashgate sells for more for a few cycles. | tag [price up: Ashgate, energy] | EV78_ASH_TITLE | Ashgate buyer is pleased | EV78_ASH | The Ashgate buyer writes it on a napkin and leaves a large tip for lunch.

### EV79 | C | goods or credits | cash vs stock
EV79_TITLE | A gift from a grateful buyer
EV79_BODY | A buyer Idris once let win a deal sends a crate with a note. The note says it is a gift, not payment. Gifts are polite to accept. Credits are lighter to carry. The crate is food.
- EV79_CASH_BTN | Take the credits | EV79_CASH_EFF | Get: a small sum in credits. | tag [cash: +N] (N UNKNOWN) | EV79_CASH_TITLE | Credits and a smile | EV79_CASH | The buyer sends credits instead and a second note, thanking you for understanding.
- EV79_GOODS_BTN | Take the food | EV79_GOODS_EFF | Get: food in Company storage at Ashgate. | tag [stock: Ashgate, food, +N] (N UNKNOWN) | EV79_GOODS_TITLE | A crate of food | EV79_GOODS | The crate reaches Ashgate with a ribbon on it. Idris takes the ribbon.

### EV80 | Q | plain | [price down: Voltara, food]
EV80_TITLE | Voltara has seen the smile
EV80_BODY | Idris's smile has been seen too often at Voltara. Buyers now wait for his price to drop before they pay. Food sells for less at Voltara for a few cycles. Idris takes it as a compliment.

## 6. Sela Oru (Military, Bulkhead, Nerve, Hard Lanes)

Personality: flew the worst lanes, fears only an idle ship, backup plans for backup plans. Condition for all five: `branch_is:mil`, min_cycle UNKNOWN (suggest 5).

### EV81 | Q | plain | [shortage: Voltara, energy]
EV81_TITLE | A relay runs dry at Voltara
EV81_BODY | Voltara needs more energy than it has. Sela reads the call twice. She has a plan for a night like this, and a plan for the plan. Voltara pays more for energy for a few cycles.

### EV82 | C | pay or bear | cash vs congestion
EV82_TITLE | A hull sits idle at Tillam
EV82_BODY | A ship sits at Tillam waiting for a clearance stamp. Sela hates an idle ship more than a bad forecast. A clerk will stamp it today for a payment. Or it waits its turn, and the dock fills behind it.
- EV82_PAY_BTN | Pay for the stamp | EV82_PAY_EFF | Cost: a small sum in credits. | tag [cash: -N] (N UNKNOWN) | EV82_PAID_TITLE | The hull moves | EV82_PAID | The stamp lands and the hull is gone by the next bell. Sela does not watch it go.
- EV82_WAIT_BTN | Wait its turn | EV82_WAIT_EFF | Cost: lanes that touch Tillam cost more per trip for a few cycles. | tag [congestion: Tillam] | EV82_WAITED_TITLE | The dock fills up | EV82_WAITED | One hull waits and others stack behind it. The rim taught Sela to wait. She never learned to like it.

### EV83 | C | pick a world | price up vs price up
EV83_TITLE | One patrol, two ends
EV83_BODY | Sela can post a patrol on one end of a lane for a while. Traders go where the line is watched. Voltara or Ashgate gets it. The other keeps its own luck.
- EV83_VOLT_BTN | Watch Voltara | EV83_VOLT_EFF | Get: energy at Voltara sells for more for a few cycles. | tag [price up: Voltara, energy] | EV83_VOLT_TITLE | A watched dock | EV83_VOLT | Traders at Voltara see the patrol light and stay late.
- EV83_ASH_BTN | Watch Ashgate | EV83_ASH_EFF | Get: food at Ashgate sells for more for a few cycles. | tag [price up: Ashgate, food] | EV83_ASH_TITLE | A watched dock | EV83_ASH | Traders at Ashgate see the patrol light and unload without checking the door twice.

### EV84 | C | goods or credits | cash vs stock
EV84_TITLE | A rim crew pays a debt
EV84_BODY | A crew Sela once carried home pays what they owe. They offer credits, or a hold of energy at Voltara. They do not ask which she prefers. They only ask that it be taken.
- EV84_CASH_BTN | Take the credits | EV84_CASH_EFF | Get: a small sum in credits. | tag [cash: +N] (N UNKNOWN) | EV84_CASH_TITLE | The debt is paid | EV84_CASH | The credits come in a worn bag. Sela counts them once and nods once.
- EV84_GOODS_BTN | Take the energy | EV84_GOODS_EFF | Get: energy in Company storage at Voltara. | tag [stock: Voltara, energy, +N] (N UNKNOWN) | EV84_GOODS_TITLE | The debt is paid | EV84_GOODS | The crew loads the cells themselves. Sela walks the shelf twice afterwards.

### EV85 | Q | plain | [price down: Tillam, food]
EV85_TITLE | A convoy arrives all at once
EV85_BODY | A convoy that was late comes in all at once at Tillam. Food at Tillam sells for less for a few cycles. Sela notes the lanes and keeps moving. Bad news is only news.

## 7. Tamsin Hale (Biotech, Skerrit, order size, Station Born)

Personality: raised in the docking rings, knows every clerk, friendly paperwork, proud of the old place. Condition for all five: `branch_is:bio`, min_cycle UNKNOWN (suggest 5).

### EV86 | P/Q | plain | [price up: Ashgate, food]
EV86_TITLE | A form on top of the pile
EV86_BODY | A clerk Tamsin knows by name leaves one form on top of the pile. It lists a large order of food at Ashgate. Food at Ashgate sells for more for a few cycles. Tamsin sends a card in thanks.

### EV87 | C | pay or bear | cash vs price down
EV87_TITLE | The friendly form has a flaw
EV87_BODY | A kind clerk sends your paperwork with a small error in it. A payment fixes it today. Left alone, the error goes up on Tillam's market board, and buyers read boards. Tamsin will not blame the clerk.
- EV87_PAY_BTN | Pay to fix it | EV87_PAY_EFF | Cost: a small sum in credits. | tag [cash: -N] (N UNKNOWN) | EV87_PAID_TITLE | The form is clean | EV87_PAID | The new form is stamped before the tea is cold. The clerk apologises twice.
- EV87_LEAVE_BTN | Leave it on the board | EV87_LEAVE_EFF | Cost: food at Tillam sells for less for a few cycles. | tag [price down: Tillam, food] | EV87_LEFT_TITLE | The board shows it | EV87_LEFT | Buyers at Tillam read the error and offer less. Nobody is unkind about it.

### EV88 | C | pick a world | price up vs price up
EV88_TITLE | Two clerks ask a favour
EV88_BODY | A clerk at Tillam and a clerk at Ashgate both ask Tamsin to put in a word for their dock. She knows them both by name. She can do it for one this cycle. The other will understand, and remember.
- EV88_TIL_BTN | Speak for Tillam | EV88_TIL_EFF | Get: food at Tillam sells for more for a few cycles. | tag [price up: Tillam, food] | EV88_TIL_TITLE | Tillam is pleased | EV88_TIL | The Tillam clerk bows twice. A queue of buyers forms by the next bell.
- EV88_ASH_BTN | Speak for Ashgate | EV88_ASH_EFF | Get: energy at Ashgate sells for more for a few cycles. | tag [price up: Ashgate, energy] | EV88_ASH_TITLE | Ashgate is pleased | EV88_ASH | The Ashgate clerk sends a card and a plate of something sweet.

### EV89 | C | goods or credits | cash vs stock
EV89_TITLE | The old ring sends a parcel
EV89_BODY | The docking ring where Tamsin grew up sends a parcel with a stamp from every clerk. Inside is a note and a choice: a small sum in credits, or a crate of food held for you at Tillam.
- EV89_CASH_BTN | Take the credits | EV89_CASH_EFF | Get: a small sum in credits. | tag [cash: +N] (N UNKNOWN) | EV89_CASH_TITLE | The ring remembers | EV89_CASH | The credits come folded in a card with a name from every clerk. Tamsin reads every name.
- EV89_GOODS_BTN | Take the food | EV89_GOODS_EFF | Get: food in Company storage at Tillam. | tag [stock: Tillam, food, +N] (N UNKNOWN) | EV89_GOODS_TITLE | The ring remembers | EV89_GOODS | The crate is already at Tillam, tied with a ribbon from the old ring. Tamsin leaves the ribbon on.

### EV90 | Q | plain | [shortage: Tillam, food]
EV90_TITLE | The ring runs low
EV90_BODY | Tillam needs more food than it has. Tamsin hears it first from a clerk, and then from three more. Tillam pays more for food for a few cycles. The old rings always shared. They also always counted.

## 8. Authoritative event table

Marek EV70 to EV74, Idris EV76 to EV80, Sela EV81 to EV85, Tamsin EV86 to EV90. EV75 is left free on purpose (no gap logic depends on it; renumber if the owner likes).

| CEO | id | shape | tag(s) | existing code/data | new code | effort |
|---|---|---|---|---|---|---|
| Marek | EV70 | plain price up | price up Tillam food | full | none | XS |
| Marek | EV71 | goods or credits | cash +N, stock +N | tag parser knows both | N from a balance key for a pool choice (see 9) | S |
| Marek | EV72 | pay or bear | cash -N, congestion Ashgate | both tags exist | same N key; apply a timed tag from a choice (check) | S |
| Marek | EV73 | pick a world | price up x2 | tags exist | timed tag from a choice (check) | S |
| Marek | EV74 | plain price down | price down Ashgate energy | full | none | XS |
| Idris | EV76 | plain price up | price up Voltara food | full | none | XS |
| Idris | EV77 | pay or bear | cash -N, price down Tillam food | exist | as EV72 | S |
| Idris | EV78 | pick a world | price up x2 | exist | as EV73 | S |
| Idris | EV79 | goods or credits | cash +N, stock +N | exist | as EV71 | S |
| Idris | EV80 | plain price down | price down Voltara food | full | none | XS |
| Sela | EV81 | plain shortage | shortage Voltara energy | full (need gate) | none | XS |
| Sela | EV82 | pay or bear | cash -N, congestion Tillam | exist | as EV72 | S |
| Sela | EV83 | pick a world | price up x2 | exist | as EV73 | S |
| Sela | EV84 | goods or credits | cash +N, stock +N | exist | as EV71 | S |
| Sela | EV85 | plain price down | price down Tillam food | full | none | XS |
| Tamsin | EV86 | plain price up | price up Ashgate food | full | none | XS |
| Tamsin | EV87 | pay or bear | cash -N, price down Tillam food | exist | as EV72 | S |
| Tamsin | EV88 | pick a world | price up x2 | exist | as EV73 | S |
| Tamsin | EV89 | goods or credits | cash +N, stock +N | exist | as EV71 | S |
| Tamsin | EV90 | plain shortage | shortage Tillam food | full (need gate) | none | XS |

Totals: 8 plain rows (extra tags, no code), 12 choice rows. Rotation: `visible_when: branch_is:<market>` on every row, plus `min_cycle`. No new condition atom.

## 9. Code and data needs (for the gameplay-programmer, after approval)

1. Pool membership: add the 20 ids to chains.json `pool_new` (or `pool_kept`) with `visible_when`. Plain rows can follow the EV40 shape with the effect in `pool_new.effect`.
2. Choice rows in the pool: EV17 and EV20 are special-cased debris and asteroid code. The generic pool has no row with two cash/price choices, except the branch pattern EV52-EV55 (cash by `cash_key`). Two small changes: (a) let a pool choice read `cash_key` (the cash amount from a balance key, not a literal in a tag) and the same for stock amounts; (b) make sure applying a choice with a price, shortage or congestion tag starts the timed effect like a random event does (`start_timed`). I did not read main.gd's apply code; the programmer must confirm (b) is already true.
3. Optional weight (section 2, option B): a `weight` key on rows, read in `random_id`.
4. Balance keys (UNKNOWN, economy owner): `ceo_event_cash_s` (small sum, gain), `ceo_event_cost_s` (small sum, cost), `ceo_event_stock_s` (units). Suggest the gain sum equals the stock value at the home market so the player is indifferent; suggest the cost sum is below one cycle of typical income. Price swing and duration reuse `event_price_pct` and `event_price_cycles`.
5. Build: `python3 tools/build_story.py` once the text lives in story/events.md (and ru later by Haiku agents, not now).

## 10. Self-check

- Glossary: Company storage, credits, lanes, trip, cycles used. No synonym for upkeep appears. "Fee" is used once as a payment word in the EV72 body, as EV17 already does; I did not use it for ship upkeep.
- Hidden goods: only energy and food; only Voltara, Tillam, Ashgate.
- No numbers in texts (EV89_CASH was reworded to avoid a counted number).
- Mechanics promises: "sells for more" means the price tag only; "needs more" is the shortage tag; nothing promises a win.
- No real names, films or books.
- Character counts: every title, body, button, effect line and outcome text was checked against the voice.md limits; none is over.

## 11. Open questions for the owner

1. Weight: accept about one event in eight being CEO-specific (option A), or add a weight or "first pick" rule (B or C)? This decides how fresh a run feels.
2. Choice rows need a small change (cash by balance key in a pool choice; timed tags from a choice). Approve as part of the build, or restrict to the 8 plain rows first (XS effort, no code at all)?
3. Should I later add a "not twice in a row" rule for CEO events (option C), or leave spacing to chance?
