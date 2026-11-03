# Star Bazaar: the planets of the three solar systems

Written 2026-11-02 from data/planets.json, data/systems.json and the world texts in data/story_text.json. Prices are the current base prices, not the event prices.

## System 1: Hollin Reach (open from the start)

"Three planets, two goods. Voltara burns, Tillam and Ashgate eat."

### Voltara (planet_1)
- Type: volcanic. Abundant: energy. Scarce: food.
- Role: the reactor world. It buys energy cheap and pays well for food.
- Trades now: energy buy 10, energy sell 8, food buy 30, food sell 26, ore sell 11 (ore comes from the asteroid clusters and is sold here).
- Story: "Voltara burns." Its reactors run hot, and its crews work long shifts on short rations.

### Tillam (planet_2)
- Type: lush. Abundant: food. Scarce: energy.
- Role: the food world. It sells food cheap and pays well for energy.
- Trades now: food buy 12, food sell 10, energy buy 28, energy sell 24.
- Story: "Tillam eats." Its terraces are the committee's pride, and its winters run the heaters without a stop.

### Ashgate (planet_3)
- Type: agrarian. Abundant: food. Scarce: energy.
- Role: a second food world, with its own harvest and its own furnaces.
- Trades now: food buy 11, food sell 9, energy buy 31, energy sell 27.
- Story: "Ashgate eats." Its harvests come in heavy, and the Common Ledger counts only half of them.

## System 2: Dunmere Reach (opened with the Permit Charter and a permit payment)

"Four planets, farther out. Fields and reactors on one side, a hungry market on the other."

### Brannock (s2_p1)
- Type: ocean. Abundant: food. Scarce: energy. Role: food-rich hub.
- Trades now: food buy 11, food sell 9, energy buy 32, energy sell 31.
- Story: "Grain terraces and a busy dock. Brannock has food to spare and a permanent shortage of power."

### Cindrel (s2_p2)
- Type: desert. Abundant: energy. Scarce: food. Role: energy-rich.
- Trades now: energy buy 9, energy sell 8, food buy 33, food sell 33.
- Story: "A planet of reactors that hum all night. Cindrel has energy to spare and kitchens that want filling."

### Mossfell (s2_p3)
- Type: agrarian. Abundant: food. Scarce: energy. Role: food-rich outpost.
- Trades now: food buy 12, food sell 10, energy buy 34, energy sell 33.
- Story: "A damp outpost of vats and sheds. Mossfell grows food and counts its power in candles."

### Quillon (s2_p4)
- Type: urban. Abundant: none. Scarce: both. Role: consumer market.
- Trades now: energy buy 35, energy sell 34, food buy 35, food sell 34.
- Story: "A market world that makes nothing and wants both goods. Quillon pays on time, in forms."

Note: in data/systems.json the system 2 planets have no silk rows yet. Silk is therefore not tradable in this system until the owner decides (see the open tier question).

## System 3: not built

The owner has put system 3 on hold (gdd.md). There are no planets, prices or story texts for it yet. When it is opened, it needs its own planet list, a permit, and a decision on which goods it adds (chips is currently unassigned).

## Goods at a glance

| Good | Role | Where it is made or sold now |
|---|---|---|
| Energy | basic | Voltara, Tillam, Ashgate, and all four system 2 planets |
| Food | basic | Voltara, Tillam, Ashgate, and all four system 2 planets |
| Ore (Rock Ore) | mining, from clusters | Sold at Voltara; clusters in systems 1 and 2 |
| Silk (Starsilk) | luxury | Not in the data for either system right now |
| Chips (Logic Cores) | tech | Not in the data for either system right now |
