# Proposal: simpler trade text (2026-11-02)

Owner question: "The logic gets pretty complex. With more resources it gets worse. Can we simplify the text? How?"
Status: waiting for the owner. Nothing here is approved.

## What I found (game/planet_panel.gd, _row at line 154)
Every planet shows a row for all 5 goods, even where the good is not traded
(Ashgate has no ore price; the buttons are only disabled, tip "Not traded here").
One row can carry up to 9 text items: price pair, event line, history line, B3 best-partner
line, B3 next-price line, "Storage empty" line, salvage line, order-state line,
mixed-load line, plus 3 to 5 buttons. The panel also adds an Abundant/Shortage line
(describes energy and food only), cluster notes, then Connections (per lane: row, "pays" line,
one row per ship, upgrade line, detail). Route legend has 7 entries (one colour per good).
Cost grows per good x per planet x per state: 8 goods would roughly double the panel.

## 1. What the player must see at a planet (always)
- Name, system, one description line.
- Per good THIS planet trades: icon, name, Buy price, Sell price, one trend arrow. One line.
- Storage amount per good (already in Company storage).
- Buttons: see section 3.
- Anything else appears only when it is true and matters (event, stuck stock), as a small badge
  on the same line, not a new line.

Goods the planet does not trade are hidden. A footer says "Also: 2 goods not traded here" with a tooltip.

## 2. Tiers (basic, advanced, rare)
UNKNOWN: there is no tier field in the data. Today system 1 = basic goods (energy, food),
systems 2 and 3 = advanced, ore = raw. Owner decides the tier of each good; a one-word
"tier" field per good is needed (economy-designer, data; no balance values change).
Panel shows one collapsible header per tier: "Basic (2)", "Advanced (2)", "Raw/Rare (1)".
- Header line shows the best sell price in the tier and a "best trade" hint.
- Opened by default: the tier of the current system. Others stay closed until clicked.
- A closed tier costs 1 line. Three tiers = 3 lines minimum, however many goods.
- Tooltip on a row: history list, B3 lines, event detail, order state. Detail leaves the panel.

## 3. What can be removed or merged
Needed to keep the game honest (the player must be able to see these):
- Buy and Sell price (the only data the profit depends on).
- A visible warning when a route runs at a loss (route_margin_notice already posts a notice
  at setup; that is the one warning to keep).
- Lock reason when trade is closed (one tooltip, one place).
- Event direction and cycles left (a badge: arrow + number).
Explanation only (can move to tooltip or be cut):
- Price history line (keep only the arrow; full list in tooltip).
- "Storage empty. Send to... will wait" (a dimmed Send button plus tooltip says the same).
- "Buy order: on" lines (the toggle state already shows it).
- Abundant/Shortage sentence (the price pair already shows it; keep as tooltip on the name).
- Salvage text (keep the button, move the sentence to its tooltip).
- Mixed-load line (one small "+5%" badge on the Sell button).
- "To / From" ship rows: show one row per lane with ship count ("x2"), not one row per ship; ship detail in the route detail view.
Merge buttons: Buy and Sell are toggles of standing orders; Stop buying duplicates the Buy toggle, remove it.
Keep Send and Sell visible, put Buy, Salvage and Split into a "..." menu or show only when usable.
Route legend: 7 entries -> 3 (line colour = tier or good icon on the line, Waiting, Ship).

## 4. Scaling 5 -> 8 goods
Rows are generated from data, so text per good is zero: name, icon, tier come from the good record.
Cost of a new good is one icon, one name and one tier tag. Hidden-if-not-traded keeps rows per
planet at about 3 to 4 even with 8 goods. Legend uses tier colours, not one colour per good.

## 5. Cost and risk
| Change | Owner | Size | Risk for pending system 2 and 3 decisions |
|---|---|---|---|
| A. Hide goods the planet does not trade | ui-programmer | S | none; tests count rows (717 tests, update row counts) |
| B. History to arrow + tooltip; merge event/mixed-load into badges | ui-programmer | S | none; text ids reused |
| C. Cut "Storage empty", order-state, Stop buying duplicates | ui-programmer | S | tests that look up StorageEmpty_ and Stop labels change |
| D. Tier groups with collapse | ui-programmer + economy-designer (tier tag) | M | Needs tier assignment; if the owner changes which goods live in system 2 or 3, the tier map changes (data only) |
| E. One row per lane with ship count; legend by tier | ui-programmer | M | none for rules; touches route_line.gd colours |
| F. Story ids for tier names and tooltips | story-designer | S | none |
No rule, price, or event is changed. Old saves are not affected (display only).

## 6. Recommendation
Do A + B + C first (S+S+S, one UI task, one day). It removes about half of the lines
with no new concept and no data decision. Hold D and E until the owner decides tiers
and system 2/3 goods; they do not block on A to C.
Do not invent tiers before the owner answers.

### Ten-minute playtest checklist
1. Open Voltara, Tillam, Ashgate: count lines per planet (before: note; after: aim at half).
2. Can you tell the best sell price for each good in 5 seconds without scrolling?
3. Find a good the planet does not trade: is it clear why it is missing?
4. Start a route; trigger a price event: still see arrow and cycles left?
5. Set a route that loses money: is the warning still shown once, clearly?
6. Hover a good: do history and Abundant/Shortage appear in the tooltip?
7. Open a planet with 2 ships on one lane: is it one row with a count?
8. Ask: did any button seem missing when you wanted it? Write down which.
9. Compare time to start the first route against the previous build.
10. Rate 1 to 5: "text is calm / I know what to do". Below 4: do not proceed to D.

## Questions for the owner
1. Hide untraded goods, or keep them greyed in a short footer?
2. Tiers: which good is basic, advanced, rare? Is ore "raw" or "rare"?
3. Remove the history list from the panel (arrow only, list in tooltip)?
