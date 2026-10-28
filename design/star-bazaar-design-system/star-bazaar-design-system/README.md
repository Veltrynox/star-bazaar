# Star Bazaar

The interface of Star Bazaar, a single-player space trading game for macOS (Godot 4). The player runs a small trading company: routes, storage and ships work by themselves, and the player decides where they go, grows the company with skills, and tries to reach a cash goal by a set cycle.

The look comes from the galaxy-view concept art: quiet glass panels over a dark, warm-lit sky. The screens follow the game's interface reference and use its in-game labels word for word.

## Principles

1. **The routes are the show.** The map is the main view. Panels sit at the edges (left for the planet or route, right for the notification board), and the sun and routes stay visible between them.
2. **No hidden costs.** Income is always shown gross, then ship upkeep and trip cost, then net. A number on screen never needs guessing.
3. **One warm accent.** `star-warm` marks the selected thing, the primary button and focus. Everything else is warm-white ink on near-black.
4. **Colour means goods or state.** Energy is amber, Food is green, cash is a warmer ink. Good, warn, bad and info are signals. None of them are decoration.
5. **Numbers are mono.** Cash, income, stock and cycles use the mono readouts, so columns line up and changes show turn to turn.

## Content fundamentals

- **Voice**: dry, practical, a little wry. A small company in a large indifferent sky. Event text may smile; effect lines and numbers never do.
- **Use the game's own lines exactly**: "Goal: {goal} by cycle {cycle}. Now: {cash}.", "Paused. Nothing earns while paused.", "Running.", "Waiting for room.", "Route made: {planet A} to {planet B}.", "Ship added to the route.", "Not enough skill points.", "Continue needs a saved game."
- **Terms**: Route, Send to…, Ship k of N, Ship upkeep, Trip cost, Income before costs, Income after costs, Company storage, Space Storage, permits, cycles, Skill points, expansion points, and the skill branches Logistics, Research, Expansion.
- Notices and labels end with a full stop when they are sentences ("Game saved."), but not when they are names ("Expansion points earned").
- Numbers: thousands separators (50,000), a real minus sign (−80), a plus on positive net (+286), and "/ cycle" for rates.
- Confirmations are plain questions with **Yes** and **No**: "Start a new game?", "Save and quit the game?", "Learn {skill}?"
- A disabled control always says why, underneath it.

## Visual foundations

**Colour.** One theme, Deep Space:
- **Background**: `void-000` → `void-100` with faint `nebula-dust`.
- **Panels**: `panel-100` glass, `panel-200` rows, `panel-300` selected.
- **Lines**: `line-100` dividers, `line-200` borders and orbits, `line-300` selection and locked markers.
- **Text**: `ink`, `ink-muted`, `ink-subtle`. All three pass 4.5:1 on void and panels at their stated sizes.
- **Goods**: `commodity-energy`, `commodity-food`, plus `cash` for money.
- **Signals**: `signal-good`, `signal-warn`, `signal-bad`, `signal-info`. Food green and good teal differ in hue, so the good signal always comes with a sign or a word.

**Type.** Jost for words (light and wide-tracked for system names) and JetBrains Mono for numbers, both from Google Fonts. In Godot, import the same two families as DynamicFonts.

**Space and shape.** A 4px base: 4 · 8 · 12 · 16 · 24 · 40. Radii stay small (3 / 6 / 10), so panels read as instruments, not cards. Planets, ships and pills are round.

**Light.** The sun is the only light source. The glows are `glow-star` on selection, `glow-atmo` on terran worlds, and `panel-lift` under floating panels.

**Motion.** Ships move along routes with a short trail (planned in game). Pause stops all of it at once. That stillness is the pause state.

## Screen layout (game screen)

| Where | What |
| --- | --- |
| Top | TopBar: goal line + progress, Expenses, Skill points, Skills (K), Cycle + Running/Paused |
| Left | PlanetPanel or RoutePanel (320px), for the selected planet or route |
| Centre | 3D system map: sun with hex ring, orbits, planets, routes, ships, locked places |
| Right | NotificationBoard (320px): Mission, Event feed, Notices |
| Bottom | KeyHints (left) · route legend (centre) · run state with Space (right) |

The other screens (title, preface, game menu, skill screen, choice and end screens) reuse the same panels, buttons and confirmations. The EventPopup's two-choice layout is the template for the Choice screen.

## Iconography

Line icons on a 24px grid with a 1.5px stroke and round caps, drawn in `currentColor`. They are `ink-muted` at rest, `ink` when active, and take the commodity colour for Energy and Food. Set: energy, food, cash, expenses, skills, ship, route, storage, planet, research, expansion, notice, event, lock, pause, play, chevron, back, close, plus, mark. The set is available from `StarBazaar.icon(name)` in bundle.js and as SVG files in the Icons group.

The mark in the top-left is a **placeholder**. Replace it with the real Star Bazaar logo.

## Using it

- Load `tokens.css`, then `components/bundle.css` (it imports both fonts), then `components/bundle.js`. Call `StarBazaar.hydrate()` to fill `[data-icon]` elements and paint `canvas.ds-stars`. Format numbers with `StarBazaar.num(n, signed)`.
- Selected: a reticle on the planet or a full-strength route line, the `line-300` orbit, and a `star-warm` primary action. There is only one selection at a time.
- Planned features ([NOT BUILT] in the game) are drawn here so they can be designed: ship dots with trails, the hex ring, event choice buttons, per-type planet textures.
