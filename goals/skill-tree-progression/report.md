**Goal:** Skill tree: every skill matters, A1 and C1 untouched, text in game voice, two QA rounds.
**Result:** done. QA ran two rounds; no crashes or softlocks; suite at 406 passing. Skills in scope now change a number, a gate or a choice; C4 and the cost-only skills are still weak (see Open).
**Changed:** data/balance.json v17 (A4, A5, B3); game/route_engine.gd, game/main.gd, game/planet_panel.gd, game/skill_screen.gd, game/skill_tree.gd (B1, B3, B4, C2, C4); story/skills.md, story/screens.md; tools/sim.py.
**Open:** owner decides a point sink after permit 2, B2 and C4 usefulness, and the C3 slowdown (balance or bot greed).
**Handoffs:** handoffs/economy-designer/2026-10-31-skill-tree-r1.json, handoffs/gameplay-programmer/2026-10-31-skill-tree-r1.json, handoffs/story-designer/2026-10-31-skill-tree-r1.json, handoffs/qa-analyst/2026-10-31-skill-tree-r1.json, handoffs/qa-analyst/2026-10-31-skill-tree-r2.json (round 2 and r1b/r2 handoffs in handoffs/)
