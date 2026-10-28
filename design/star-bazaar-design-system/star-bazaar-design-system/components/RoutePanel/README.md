# RoutePanel

The side panel for one route. It shows exactly where the money goes, so there are no hidden costs.

- **Header**: "{Planet A} to {Planet B}", with "Route · Commodity · N ships" under it. Back returns to the source planet's panel.
- **Status**: a dot and a word. "Running." (`signal-good`), "Waiting for room." (`signal-warn`, with one line on why), or a blocked notice (`signal-bad`: closed planet, destination full, source empty).
- **This cycle** ledger, in this order and with these labels: Income before costs, Ship upkeep, Trip cost, then a rule and **Income after costs**. Costs carry a real minus sign; the net is signed and coloured.
- **Last cycle** line in `ink-subtle` mono, as a sum: "Last cycle: 498 − 160 − 74 = +264".
- **Ships on this route**: "Ship k of N", status, and a Remove button each.
- **Actions**: Add ship (primary) and Remove route (danger, asks first). The hint explains that Send to… with the same source, destination and commodity also adds a ship here.
