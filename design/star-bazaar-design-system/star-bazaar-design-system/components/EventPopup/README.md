# EventPopup

A centred dialog for "News from the sky" events. Events fire every few cycles; the first cycle is skipped so the tutorial isn't interrupted.

- **Kicker**: "News from the sky", uppercase in `star-warm` with the event icon.
- **Title** (22px), then two or three sentences of text in the game's voice: dry and a little wry.
- **Effect line**: one plain sentence on a `panel-200` strip in mono, with the commodity icon when one is affected. This is the part players actually read, so it never jokes.
- **OK** (primary) closes it, and the event goes into the Event feed.
- **Choice events (planned)**: two equal buttons, each with its one-line effect under it, and no OK. The same layout serves the end-of-run **Choice screen** (Release / Stay as a Corporation), which also has no close button.
