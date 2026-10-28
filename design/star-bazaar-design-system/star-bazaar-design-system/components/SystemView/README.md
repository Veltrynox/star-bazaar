# SystemView

The main game screen at system level, shown here for Hollin Reach (System 1: Voltara, Tillam, Ashgate). The player watches routes run and opens panels to change them.

Layout at 1672×941:
- **TopBar** across the top. **PlanetPanel / RoutePanel** on the left, 320px. **NotificationBoard** on the right, 320px. **Run state** (Space) bottom-right, **KeyHints** bottom-left, and a route **legend** bottom-centre.
- **Map**: the sun sits in the centre between the two panels, with the planned **hex ring** around it. Orbits are tilted ellipses (0.36 height-to-width) to match the 3D camera. Planets on the far side of the sun draw beneath its halo.
- **Routes**: one curved line per lane in the commodity colour, with a direction chevron and a route tag at the midpoint. **Ships** are dots with short trails moving along the line: out loaded (`ink`), back empty (`ink-muted`), and a still `signal-warn` dot when waiting.
- **Locked things** stay visible so the player knows what's next: Space Storage on a dashed outer orbit, and the exit to Dunmere Reach (System 2), each saying how to unlock it.

Interaction: clicking a planet opens its PlanetPanel; clicking a route line, route tag or connection row opens the RoutePanel. **Space** toggles pause: the run state switches to "Paused." with "Nothing earns while paused.", a `signal-warn` banner appears under the system name, ships stop, and the notice is logged.

Sample data (cash, prices, stock, upkeep 80 per ship) is illustrative; wire in real values from the game.
