# Art director report, 2026-11-01

Run per tools/art_director/ART_DIRECTOR.md (first run on the new brief). Inputs: gdd.md (sections 1 and 2, gdd-skills.md sections 3 to 6), gdd-log.md (latest 10), state.md (owner answers a to d), schedule.json (78 tasks, not-done set), latest handoffs per agent, qa/reports/2026-11-01-summary.json, git log to 97123b1. Owner answers 2026-11-01 are in state.md.

## A. Feature proposals (ranked by value per effort)

Checked against schedule.json: none of these is already queued. Where a proposal sits next to a queued task, the note says how they differ.

| # | Feature: what it is and why it adds | Builder | Effort | Risk to balance or final state |
|---|---|---|---|---|
| 1 | Space Storage stock meter and transfer flow in the system view. Shows each post's stock and the moves in and out. Makes the T139 sell rule visible to the player. | ui-programmer (after T139) | small | None to numbers. Needs T139 first. |
| 2 | Milestone toasts: first route, first ship, first planet bought, first system opened, first event choice. Short notices by story id. | juice-programmer, story-designer for ids | small | None. Must grant no money or skill points. |
| 3 | Market ticker in the top bar: the biggest price moves of the last cycle. Read-only. | ui-programmer | small | None. Reads prices only. |
| 4 | Run recap after the ending screen: cash curve, best route, ships bought, events seen. Adds a closing moment to every run. | ui-programmer | medium | None to numbers. Does not change the ending picker. Any new text goes to story-designer. |
| 5 | Statistics screen in the reserved game-menu slot (T71): wins, losses, tiers and endings reached, from user://stats.json (T93). | ui-programmer | small to medium | None. Reads the existing file. |
| 6 | Sound set: UI click, cycle chime, win and loss stings. Large gain in feel. | juice-programmer; owner approves the set | medium | None to balance. Needs audio files and an export size check. Owner decides whether sound is in the release. |
| 7 | Company letters: a short Bureau letter every five cycles, shown as a notice. Gives the story a steady voice. | story-designer, then ui-programmer | medium | Text only. Must not become a choice event or touch endings. |
| 8 | Named planet cards with one flavour line per planet for systems 1 and 2 (names from T86). | story-designer, then ui-programmer | medium | Text only. Owner approves the lines. |
| 9 | Event card art: one framed card per event category, shown in the notice. | artist | medium | No balance effect. Art budget. |
| 10 | Help screen in the reserved menu slot: icon legend, route ratings, ship types, how a route earns. | story-designer, then ui-programmer | medium | Needs text ids. Keep T106 for map labels only; this is a separate screen. |
| 11 | Colour-blind safe route ratings and status colours: shape or pattern in addition to colour. | ui-programmer | small | None. Check the theme tokens. |
| 12 | Ship type silhouettes and a colour per type on the lanes (small and large from T58). | artist, then gameplay-programmer | small | None. Visual only. |
| 13 | Hover hints on icons and rating bars. | ui-programmer | small to medium | Text load. Overlaps item 10 in part. |
| 14 | Space Storage post model (a station) in the system view. | artist (after T139 and T64) | medium | Art and frame budget. |
| 15 | Teaser for system 3 on the galaxy map (a locked star). Only if the owner says system 3 is wanted. | gameplay-programmer | small | Scope creep. System 3 is on hold. No numbers. |

## B. Owner questions (top three, ranked by blocking)

1. Nomads and fields: how do they work? Options: (a) nomad mining without fields, pirates still rise; (b) move T113 before T104; (c) fields cleared by money only. Blocks T104, T111, T113 and the QA run T116.
2. Is system 3 needed for the release? Options: (a) later addition after the release state (art director recommends this); (b) drop it from scope; (c) build now. Blocks the final-state gate that every task is done or dropped, and proposal 15.
3. Does "money never buys skill points" cover all spending, and is the asteroid research point a skill point? Options: (a) research points are separate, money never buys skill points; (b) research point is a skill point; (c) money buys nothing but the goal. Blocks T111, T125 and the money rule in the GDD (T117, second pass).

## C. Plan toward final state (one line per phase)

- Phase 1, now: T137 pacing, T138 GDD route income and T139 Space Storage sells start by the main session; owner plays T61 (ready, T58 done).
- Phase 2, after Phase 1: T63 economy numbers after T61, then T64 (unstopped, gated by T63); QA re-run T17 and T94 on the new build; T62 and T117 finish the GDD.
- Phase 3, after owner questions 1 to 3: unblock T104, T111, T113, T115 and T125; then QA run T116 on the idea builds.
- Phase 4, release gates: no queued task yet for the macOS release export or for the dominance fix (always_expand equals decent in 55 of 55 paired seeds). The producer proposes two tasks after owner question 2.
- Phase 5, owner: one full run of the release-candidate build and sign-off.

## D. Final-state checklist (status from the 2026-11-01 files)

- Release export runs and the zip starts on the owner's Mac: OPEN. Export blocked in the sandbox (QA summary, not covered).
- Every queue task done or dropped with a note: OPEN (11 queued, 6 partial, 5 blocked, 4 stopped).
- Every owner question answered or deferred: OPEN (answers a to d recorded; three open in state.md).
- QA gates on the release-candidate build: PARTIAL. 371 playthroughs, 0 crashes, 0 softlocks, win and loss checks 371 of 371. 19 of 19 endings reached with the force-goal control, not the natural flow.
- Dominance check: OPEN. decent and always_expand are identical in 55 of 55 paired seeds; sloppy and never_expand never win.
- GDD matches code on routes, Space Storage and the win condition: OPEN (T138 for routes; T139 and T64 for Space Storage).
- Owner has played a full run and signed off: OPEN (T61).
