# Star Bazaar: project state
Keep under 40 lines. Workflow: gdd-process.md. Detail in handoffs.

## Meter
- 2026-10-26 (owner): session 67% (resets 1pm America/Toronto); weekly 9% (resets Nov 1).
- 2026-10-28: owner has not reported a figure. UNKNOWN. Start nothing at about 80% of a window. UNKNOWN: whether the 68% cap uses per-agent 24h (36%) or weekly (9%).

## Queue (detail: schedule.json)
- Done 2026-10-28: T90, T92, T93, T97.
- Running, handoff file MISSING (stay running): T96, T99, T100, T102, T103, T107, T108.
- Next build: T79 (tests; deps met). Then T71, T69+T70, T87, T58, T12.
- Ready now (queued, deps met): T79, T53 (QA), T119 (story), T117 (doc), T59 (owner).
- Scope: System 1 Hollin Reach; System 2 Dunmere Reach in scope; System 3 ON HOLD.
- Idea chain: 1 debris (T96-T98), 2 shield (T99-T101; flag T121), 3 pirates (T102-T104), 4 zoom (T119, T106, T118, T105), 5 asteroid (T107-T110; reward T120), 6 fields (T111-T113), 7 dots and textures (T114-T115).
- Blocked: T104, T105, T111, T113, T115. Deferred (owner: wait): effect-wording check, not scheduled. Stopped: T11, T14, T54, T60, T64.

## Owner decisions 2026-10-28
- Shield: hidden "shield built" flag for the ending picker (T121, queued, NOT ready).
- No shield wording in any ending (note in T100). T100's habitability ending line is not to be written.
- Asteroid paid option: one research point as an event reward, not bought with money (T108, T109, T120).

## Standing rules
- Money never buys skill points; idea 5 paid option grants no skill point or reputation.
- Debris lowers route efficiency while it stays; paying clears it (fee T97).
- Shield affects only planets buyable later. Pirates cut trade volume; hired clearing costs money.
- Zoom opens only after system 2 is opened; introduced via tutorial (T119, T15).

## Open questions for owner
1. Is the idea 5 research point a skill point? Conflicts with "no skill point" unless Research is separate. UNKNOWN.
2. Does "money never buys skill points" cover all spending? (T97, T99, T107, T111)
3. Nomads: mine a field without a clearing skill, or move T113 before T104? Field clearing skill or paid only? Planet types (T115).
4. Build the shield flag now (T121)?

## Latest handoff per agent
- gameplay-programmer: handoffs/gameplay-programmer/2026-10-28-T93.json
- economy-designer: handoffs/economy-designer/2026-10-28-ideas.json (T97)
- story-designer: handoffs/story-designer/2026-10-28-T92.json
- producer: handoffs/producer/2026-10-28-batch.json
- qa-analyst, galaxy-builder, general-purpose, artist: none yet
