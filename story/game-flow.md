# Game flow reference for the story designer (owner/main session, 2026-10-27)

Read-only for you. This is how the player acts today. Source: owner direction and tasks T55 to T70; if a tutorial line disagrees with this file, this file wins.

## Player actions
1. Click a planet. The planet panel lists its resource rows (energy, food). Each row shows the Buy price, the Sell price and a vertical 5-line bar: how full the company storage is for that good (5 = full).
2. Buy and Sell on a row are standing local orders, each toggled on or off. No ship is needed. Each cycle a Buy order buys a set amount at the Buy price and adds it to the company storage on that planet; a Sell order sells stock from that storage at the Sell price. A full storage makes a Buy idle with the status "storage full" (not an error).
3. A route is optional and only moves stock between company storages. On a storage row the player presses "Send to..." and clicks the destination planet. This makes a one-way route with one ship, assigned automatically from the ships the company owns. If no ship is free, the screen says so. Routes are NOT made by clicking Buy here and Sell there.
4. Empty source: the route stalls and waits. Full destination with a Sell order or onward route there: the route waits for room (neutral). Full destination and nothing will ever make room: the route is blocked (red line, one notification) until the player acts.
5. Each planet panel lists its routes, each with a Remove button. Ship upkeep is shown plainly (revenue, goods cost, upkeep, trip cost, net) and the cash forecast lists Expenses.
6. Cycles end on a timer; the game starts paused after the preface; P pauses. Cash goal is reached at the end of a cycle, or the player loses at the end of the last cycle. Stranded (no ships, cash below a ship price) gives a one-time rescue payment, not a loss.
7. Skills are bought with expansion points (first planet visit, first route between a new pair, first route or storage in a new system). The Skills screen does not pause the game. Space Storage and permits are skills. System 2 (Dunmere Reach) is open to buy with the Permit Charter (C1) and is in the Alpha; system 3 is planned but on hold, so keep story room for it (a line or two that points beyond system 2 is welcome, nothing the player can already act on).

## Events (planned, T12)
An event pauses the game and shows a notification with its text and an OK / Continue button. Some events offer two or three choices instead. Each choice has a short label and a plain effect line. The gameplay-programmer picks the effect from this vocabulary (no others): price up or down for one planet's commodity for a while; one planet closed for a while; a one-off cash gain or loss; a one-off change to storage stock of one good at one planet. Magnitudes are abstract and set later by the economy designer.
