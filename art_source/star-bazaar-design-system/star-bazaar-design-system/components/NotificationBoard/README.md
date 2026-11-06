# NotificationBoard

The right-hand panel that holds everything the game tells the player, in three groups.

1. **Mission**: the current goal hint and tutorial lines, with `signal-info` icons. Four small bars show progress through the four tutorial cycles; the galaxy-view tutorial uses the same pattern with three.
2. **Event feed**: "News from the sky" items, each with its plain effect line and the cycle it happened. Icon in `star-warm`.
3. **Notices**: the short game notices, newest first, with the cycle under each. Text is the in-game line, word for word ("Game saved.", "Route made: Voltara to Ashgate.", "Ship added to the route.").
   - Problems (Waiting for room, blocked routes, Paused) are `signal-warn` text and icon.
   - Gains (Skill learned, Ship added) get a `signal-good` icon only; the text stays `ink`.
   - Older notices fade to `ink-muted`. Keep the last five and let the rest scroll.

Esc closes a pending notice before it opens the game menu.
