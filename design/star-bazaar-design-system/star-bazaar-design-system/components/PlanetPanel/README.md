# PlanetPanel

The side panel that opens when the player clicks a planet. It answers three questions: what this planet makes and needs, how full its stock is, and which routes touch it.

Order, top to bottom:
1. **Name** (`panel-title`) with "System · World type", and a close button.
2. **Hero**: the planet render over its own small starfield.
3. **Production**: Makes and Needs rows with a commodity icon and a per-cycle number.
4. **Stock**: one bar per commodity in its colour, with "140 / 200". A full stock turns the number `signal-warn` and prefixes "Full", because that is what causes "Waiting for room." upstream.
5. **Connections**: each route is a row (To / From planet, income after costs, coloured by sign) followed by one row per ship: "Ship k of N", its status and its own **Remove** button. Clicking a route row opens the RoutePanel.
6. **Actions**: **Send to…** (primary) starts a route from this planet; **Buy ship** opens the ship panel. The hint under them says how many ships are free and the upkeep per ship.

Left edge, 20px in, under the top bar, 320px wide. It shares its slot with the RoutePanel.
