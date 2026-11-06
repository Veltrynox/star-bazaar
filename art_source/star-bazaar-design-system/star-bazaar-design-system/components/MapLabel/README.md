# MapLabel

Text on the 3D map: planet labels, route tags, locked places and system names.

- **Planet label**: sits `space-3` to the right of the planet. It shows the name (`map-label`, `ink`), the world type (`ink-muted`, 11px), and what the planet makes per cycle with commodity icons. A planet that only buys says so ("Buys energy and food").
- **Selected planet**: a `.ds-reticle` ring with four `star-warm` ticks, 22px wider than the planet, and its orbit lifts to `line-300`.
- **Route tag** (`.ds-routetag`): a small pill at the middle of the route line. It shows the commodity icon, ship count and income after costs (2 ships · +286). A blocked or waiting route shows its status instead, in `signal-warn`. Clicking it opens the RoutePanel.
- **Route line**: one line per lane in the commodity's colour at 50% opacity, with a small chevron for direction. The selected route goes to full opacity and 2.4px. Waiting routes are dashed `signal-warn`.
- **Ships**: a dot moving along the line with a short fading trail. Loaded ships (outbound) are `ink`; returning ships are `ink-muted`; a waiting ship is a still `signal-warn` dot.
- **Locked places** (Dunmere Reach, Space Storage): `ink-subtle` with a lock or storage icon and how to unlock them ("permit or skill").
- **System name**: wide-tracked uppercase `ink-muted`, centred above the map.
