# Button

Outlined glass buttons. Each panel or dialog has at most one primary action.

- **Primary**: `star-warm` border with a faint inner glow (Send to…, Learn, Add ship, OK).
- **Secondary** (default): `panel-100` fill, `line-200` border, `line-300` on hover (Buy ship, Skills).
- **Danger**: looks secondary and turns `signal-bad` on hover only (Remove, Remove route). Removing a whole route asks first; removing one ship does not.
- **Ghost**: no border at rest; for the "No" in confirmations.
- **Disabled**: `ink-subtle` label and a `line-100` border. Always say why underneath in a `ds-hint`, using the game's own line: "Continue needs a saved game.", "Not enough skill points."
- **Small** (`.sm`): for top-bar buttons and in-row actions, with an optional key cap (Skills K).
- Labels are the in-game labels, word for word. A trailing chevron means "opens a choice" (Send to…).
- Confirmations ask a plain question ("Start a new game?", "Learn Long Haul?") and use the buttons **Yes** and **No**.
