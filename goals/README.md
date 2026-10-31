# Goals

One folder per `/goal` run: `goals/<goal-slug>/`. Start each folder from `goals/_template/`.

| File | Who writes it | Purpose |
|---|---|---|
| `blackboard.json` | Agents, while the goal runs | Shared working memory: facts, decisions, open questions, claims and artifacts. |
| `log.md` | Producer or main session, when the goal finishes | Human-readable step log, one plain-sentence entry per agent step, in order. |
| `report.md` | Producer or main session, when the goal finishes | Five lines or fewer: what the goal was, the result, what changed, what is open, where the handoffs are. |

## Blackboard rules

- Append-only. Add entries; never delete or rewrite another agent's entry.
- Each agent writes only its own entries, marked with its `agent` name.
- A status change is a new entry. The latest entry for an id wins.
- Ids are short and unique within the file: `F1` facts, `D1` decisions, `Q1` questions, `C1` claims, `A1` artifacts.
- Keep each text to one sentence. Put long material in a handoff or a project file and link it in `artifacts`.
- Unknowns are written as `UNKNOWN` in `open_questions`, never guessed.

## Claims

An agent adds a claim before it starts a task (`status: running`) and a second claim entry when it ends (`status: done`, `partial` or `blocked`). A claim counts as done only when the agent's handoff file exists, as in `gdd-process.md`.

## When the goal finishes

1. Read `blackboard.json`.
2. Write `log.md` from the agent steps, in order.
3. Write `report.md`, five lines or fewer.
4. Link the result from `state.md`, and list the goal's handoffs in `state.md`'s "Latest handoff per agent" section.
5. Set `finished` in `blackboard.json`.

Nothing in these files is a usage or budget figure.
