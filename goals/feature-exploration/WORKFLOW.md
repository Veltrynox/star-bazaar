# Feature exploration workflow

Goal: find three improvements to existing mechanics and three new mechanics that add real impact to trade, then build only the ones the design council agrees on.

Owner of the workflow: main session (starts agents, checks handoffs). Producer records the goal in schedule.json.

## How to run

The workflow is a saved Claude Code workflow script: `goals/feature-exploration/feature-exploration.js`. It runs the steps below as `agent()` calls, with the phases Propose, Review, Revise, Vote, Build, Test and Finish.

Install it as a command:

```
! mkdir -p .claude/workflows && cp goals/feature-exploration/feature-exploration.js .claude/workflows/
```

Then run `/reload-skills` and `/feature-exploration`. Approve the plan when Claude Code asks. Nothing is built unless all three designers agree on the final vote.

## Steps

1. **Set the goal.** Copy `goals/_template/` to `goals/<slug>/`. Write the goal in `blackboard.json`.
2. **Propose.** feature-designer writes six proposals into the council blackboard (`council.json`): three IMPROVE (changes to an existing mechanic) and three NEW (added mechanics). Each proposal gives the player's new choice, what it changes in the main loop, the risk, and which agent builds it. Nothing already in `design/proposals/` may repeat.
3. **Review.** economy-designer and story-designer read every proposal and add a review entry with a vote: agree, agree-with-change (with the change as an amend), or disagree. Each review tests the proposal against the council checklist in `council.json`. Reviews run in parallel.
4. **Revise once.** feature-designer answers each change request with an amend entry. Proposals that were disagreed with are either amended or dropped.
5. **Final vote.** All three designers vote on each remaining proposal. A proposal is built only when the latest vote from each of feature-designer, economy-designer and story-designer is agree.
6. **Build agreed ideas only.** Work goes to the owner agent named in the proposal, on branch `new-features-test`. Each build task is queued in `schedule.json` with a claim in `blackboard.json`, and each ends with a handoff. Balance numbers come from economy-designer, text from story-designer, code from gameplay-programmer, UI from ui-programmer.
7. **Test.** Run `sh tools/tests/run.sh`. Run qa-analyst bot playthroughs for any idea that changes balance, to check no strategy becomes dominant and the win still lands near cycles 25–28.
8. **Finish.** Write `log.md` and `report.md`, set `finished`, link the result from `state.md`.

## Rules

- Ideas that take a choice away from the main loop, force a new step, or depend on system 3 are dropped.
- Nothing is built from a proposal that fewer than three designers agreed to.
- Each agent writes only its own council entries.
- The owner can stop any step; the main session reports disagreements in its summary.
