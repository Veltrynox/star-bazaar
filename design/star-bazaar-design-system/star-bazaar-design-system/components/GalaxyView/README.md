# GalaxyView

The zoomed-out screen (planned in the game): every system the player knows about, the links between them, what each planet makes, and the player's own routes. It opens once system 2 (Dunmere Reach) is open, and a three-line tutorial introduces it the first time.

Layout at 1672×941 uses the same frame as the system screen: TopBar, left panel, NotificationBoard on the right, KeyHints, legend and run state along the bottom.

**Map**
- **Open systems** are soft territory outlines (`#ffffff08` fill, `line-200` edge, `line-300` when selected), as in the galaxy concept art. Inside each: its sun, faint orbits, and planets as 12px spheres.
- **Resource icons**: a 13px commodity icon sits up and to the right of each planet that makes something. A planet that only buys has no icon.
- **Your routes** keep their system-screen look at a smaller scale: commodity-coloured curves, with ship dots and short trails. A waiting route is dashed `signal-warn`.
- **Links** between open systems are solid `line-300`. Links to uncharted systems are dashed `line-200`.
- **Uncharted systems** are small dim stars labelled "Uncharted" in `ink-subtle`. They have no outline and show no planets.
- **Labels**: under each open system, its name (wide-tracked) and a mono summary: "3 planets · 3 routes · +348 / cycle". Planet names appear only inside the selected system, set on the side away from the sun.

**Left panel (system)**
- Name, "System N · how it opened", and three tiles: Routes, Ships, Per cycle (income after costs, signed and coloured).
- **Planets** with what each makes per cycle, or "Buys goods". **Your routes here**, each with its net income or "Waiting". **Space Storage** status.
- **Open system** (primary) zooms into the system screen; scrolling in on a system does the same.
- An uncharted system shows what is known (planets "?", links count) and a disabled Open system with the reason: "Systems open with a permit or a skill."

**Tutorial (shown once)**
- In the NotificationBoard under "Galaxy view", with three progress bars and the lines numbered 1–3. The current line is `ink` with a `signal-info` number; earlier ones fade.
- The lines: what the view is, what the icons mean, and the player's own routes. While line 2 is up, the resource icons pulse in `signal-info`; while line 3 is up, the routes do.
- Next / Got it (primary) and Skip (ghost). Once done, it leaves a single "Galaxy view tutorial done." note and does not come back.

Sample data: Dunmere Reach's goods and all numbers are placeholders, and the five uncharted systems are invented to show the state.
