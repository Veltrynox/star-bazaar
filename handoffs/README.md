# Handoffs

Every agent session ends with a handoff. A handoff is the only thing the next session gets from this one, so it must be complete on its own.

## Where it goes

- File: `handoffs/<agent>/<YYYY-MM-DD>-<task-id>.json`
- The Producer writes `handoffs/producer/<YYYY-MM-DD>.json`, because it has no task id of its own.
- Start from `handoffs/_template.json`. Copy it, then fill in every field. Do not add or rename fields.

## Fields

| Field | Rule |
|---|---|
| `schema_version` | Always `1` until the template changes. |
| `agent` | The agent folder name, for example `economy-designer`. |
| `date` | `YYYY-MM-DD`. |
| `task` | One line, copied from the task `title` in `schedule.json`. |
| `status` | `done`, `partial` or `blocked`. |
| `files_changed` | Paths relative to the project root. Empty list if none. |
| `usage_note` | Rough percent of the meter used this session, for example `"~15%"`. |
| `open_questions` | Maximum 3 strings. Use `"UNKNOWN"` for anything not known, and list it here. Empty list if none. |
| `handoff` | Maximum 150 words. What the next session needs, and nothing else. |
| `details` | Agent-specific data. See below. Keep the keys listed for that agent. |

Prose is limited to 200 words, except `handoff`, which is limited to 150.

## `details` by agent

- **gameplay-programmer**
  - `playable`: what the player can now do, as a short string.
  - `how_to_try`: steps to try it in under a minute.
- **economy-designer**
  - `changes`: list of `{ "key", "old", "new", "reason" }`. One entry per changed key in `balance.json`.
  - `sim_results`: list of `{ "strategy", "final_cash", "win_cycle" }`. Use `null` for `win_cycle` on a loss.
- **galaxy-builder**
  - `seed`, `point_count`, `grid_size`, `bake_time_s`, `frame_time_ms`, `screenshot` (path).
  - `parameters`: object of exposed parameters and their values.
- **qa-analyst**
  - `results`: list of `{ "strategy", "final_cash", "cycle_reached", "outcome" }`. `outcome` is `win`, `loss`, `crash` or `softlock`.
- **producer**
  - `started`, `stopped`: lists of `task_id`.
  - `blocked`: list of `{ "task_id", "reason" }`.
  - `meter_reported`: the figure the owner gave at the start of the window.

## Example

```json
{
  "schema_version": 1,
  "agent": "economy-designer",
  "date": "2026-10-26",
  "task": "Retune food margin to hit win window",
  "status": "done",
  "files_changed": ["data/balance.json"],
  "usage_note": "~8%",
  "open_questions": ["UNKNOWN: whether saturation applies per route or per system"],
  "handoff": "food_sell raised to 21. Bot sims now win at cycles 26 to 28. Next: check the always-expand strategy still loses.",
  "details": {
    "changes": [
      { "key": "food_sell", "old": 20, "new": 21, "reason": "Early wins were coming before cycle 25." }
    ],
    "sim_results": [
      { "strategy": "optimal", "final_cash": 52000, "win_cycle": 27 },
      { "strategy": "always_expand", "final_cash": 9000, "win_cycle": null }
    ]
  }
}
```

The numbers in the example are made up to show the format. They are not game values.
