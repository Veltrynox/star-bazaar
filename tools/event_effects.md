# Event effect values (proposal, 2026-10-27, economy-designer)
data/events.json is generated from story/, so these are NOT in it. Gameplay-programmer wires them; the values live in data/balance.json.

| Tag in events.json | Effect | Value (balance.json key) | Duration |
|---|---|---|---|
| [price up: P, C] (EV02, 04, 05, 06, 12, 13, 15) | Buy price AND sell price of commodity C at planet P x (1 + pct) | event_price_pct = 0.20 | event_price_cycles = 3 |
| [price down: P, C] (EV01, 03, 10, 11, 14, 16) | Both prices x (1 - pct) | event_price_pct = 0.20 | event_price_cycles = 3 |
| [planet closed: P] (EV07, 08, 09) | Orders and routes touching P idle (pay 0, cost 0) | none | event_close_cycles = 3 |

Cadence: one random event every event_interval = 4 cycles. Old key event_effect (pct 0.1-0.2) is removed; use the fixed event_price_pct.
Space Storage (A1) bridges the first closed cycle, Deep Holds (A2) the second, Event Forecast (B4) the third (sim model; code rule: a route/order touching a closed planet still runs for N cycles of the closure, N = number of those skills learned).
