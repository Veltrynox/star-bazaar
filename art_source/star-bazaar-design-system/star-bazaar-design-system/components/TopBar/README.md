# TopBar

The strip across the top of the game screen: goal line, Expenses, Skill points, the Skills button, and the cycle with its run state.

- **Goal line** uses the in-game template exactly: "Goal: {goal} by cycle {cycle}. Now: {cash}." The three values are `readout` mono in `cash`; the words are `ink-muted`. A 3px progress track under it fills with `cash` as Now approaches Goal.
- **Expenses** is the total per cycle (ship upkeep + trip cost), with the unit "/ cycle" in `ink-subtle`. No sign: the label already says it's a cost.
- **Skill points** is the unspent count. The **Skills** button shows its key, K.
- **Cycle** sits right-aligned, with "Running." in `signal-good` or "Paused." in `signal-warn` under it.
- Numbers use thousands separators (6,840), never abbreviations; the reader should never have to guess.
- The bar has no fill of its own. It fades from `void-100` to transparent so the map shows through.
