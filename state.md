# Star Bazaar: project state (under 40 lines; workflow gdd-process.md; updated 2026-11-01)

## Queue (schedule.json, 78 tasks)
- Done 52, queued 11, partial 6, blocked 5, stopped 4, running 0.
- Partial: T5, T17, T94, T62, T117, T131. Blocked: T104, T111, T113, T115, T125.
- Next (start by main session): T137 pacing, T138 GDD route income, T139 Space Storage sells. T64 unstopped, gated by T63.

## Owner answers 2026-11-01
- (a) Route income: the code is right. GDD fixed to match: routes earn through destination sell orders (T138).
- (b) Pacing: retune. Permit path must not end at cycles 29-30 of 30. Decent reaches the goal in more runs (T137).
- (c) System 3: is it needed? Art director: a later addition. OPEN, pending owner confirmation.
- (d) Space Storage: sell orders draw from its stock. T64 unstopped (T139, T64).

## Owner decisions 2026-10-28 and standing rules
- Shield flag hidden, read only by the ending picker (T121 done); no shield wording in endings. Asteroid paid option: one research point, no skill point or reputation.
- Money never buys skill points. Debris lowers route efficiency; paying clears it. Shield affects only buyable planets; pirates cut trade volume; zoom opens after system 2 (T119).

## Open questions for owner
1. Is system 3 needed (on hold; art director: later addition)? UNKNOWN until owner confirms.
2. Is the asteroid research point a skill point? The 2026-10-28 answer says no. UNKNOWN.
3. Does "money never buys skill points" cover all spending? (T97, T99, T107, T111)
4. Nomads: field link and clearing (skill or paid); planet types (T104, T111, T113, T115).

## Goals and reports
- skill-tree-progression: done 2026-10-31 (goals/skill-tree-progression/report.md). Owner points open. Art director 2026-11-01: qa/reports/2026-11-01-art-director.md.
- feature-exploration-2026-11-02: partial; agreed P1, P2, N3; P2 done, P1 partial, N3 needs owner keys, N1 not built; 574 pass (goals/feature-exploration-2026-11-02/log.md, report.md; blackboard finished 2026-11-02).

## Latest handoff per agent
- gameplay-programmer: handoffs/gameplay-programmer/2026-11-02-N2.json (also P2, P3)
- economy-designer: handoffs/economy-designer/2026-10-31-skill-tree-r2.json
- story-designer: handoffs/story-designer/2026-10-31-T124.json
- ui-programmer: handoffs/ui-programmer/2026-11-02-P1.json
- artist: handoffs/artist/2026-11-01-T110.json
- fx-programmer: handoffs/fx-programmer/2026-11-01-edge-blur-lens-glare.json
- galaxy-builder: handoffs/galaxy-builder/2026-11-01-star-brightness.json
- juice-programmer: handoffs/juice-programmer/2026-11-01-points-and-cycle-beats.json
- qa-analyst: handoffs/qa-analyst/2026-11-01-T94.json
- general-purpose: handoffs/general-purpose/2026-10-31-T62.json
- producer: handoffs/producer/2026-11-02.json
