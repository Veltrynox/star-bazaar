# Mechanics audit and skill ablation, 2026-10-28

Sources: `qa/bots/audit_mechanics.py` (static, stdlib), skill ablation in `qa/reports/2026-10-28-skill-ablation-runs.jsonl` (decent, seeds 1-4, fast clock, 13 single-skip runs plus all-skills). Coverage: the bot drives the real game through its functions (main.gd and route/skill calls), not screen clicks, so UI bugs are not covered.

Caveat on all skill numbers: skipping skill X changes the bot's learned path (the bot buys another skill instead), so each effect is the value of the bot's path with X against without X, not X's standalone value. Four seeds per skill: one seed is 25 win-rate points.

## (a) Mechanics that affect neither the story nor the win path

- No game code or data reader (static audit): `upgrade_cost`, `upgrade_margin_bonus` (no upgrade feature in game/), `pirate_volume_penalty`, `pirate_hire_cost`, `pirate_nomads_per_eviction` (no pirate event in events.json), `permit_margin_bonus`, `permit_3_cost`, `permit_points_3` (systems.json defines only system 2), `skill_B3_margin` (B3 has no effect hook), `full_ref_points_per_cycle`.
- Skill A3 (Second Hull): no effect hook; skipping it gives identical cash and outcome on every seed. It is also never bought by decent.
- Skill C2: no effect hook; skipping it changed nothing on seeds 1-4. Decent buys it, so it counts as measured zero.
- `targets.*` in balance.json are QA and sim targets, not game reads. Not a defect.
- Event EV19 is missing from events.json and from code (EV01-EV20 sequence gap). Confirm whether intended.

## (b) What to improve

1. Event RNG: `events.gd` calls `rng.randomize()` in setup, so the same bot seed gave different runs (seed 1 gave 8575 and 7966 on two invocations). The bot now seeds it after setup (qa/bots/bot_run.gd). Earlier batch results are not reproducible by seed.
2. Decent buys only 6 of 13 skills (A1, A2, B1, B2, C1, C2) in all 2400 decent runs; A3, A4, A5, B3, B4, C3, C4 are never bought. Their effects are untested, not zero. Fix the bot's skill policy or the costs before reading balance from them.
3. A1 (Space Storage) lowers decent's result in this sample: learning A1 vs skipping gives -673 cash and -50 win points on 4 seeds (all-skills wins 2 of 4; skip-A1 wins 4 of 4). Check against the owner's Space Storage decision of 2026-10-27.
4. Wire or delete the dead keys listed in (a).
5. Bot coverage gaps: it never buys large (hauler) ships, never buys permits (permits_bought null), and never reaches a pirate. These mechanics have no automated test.
6. Open from the earlier report: 269 softlock flags in never_expand and sloppy runs (cycle-5 idle state).

## (c) What not to change

- Do not change B1 or B2 without a re-run: they carry decent's win in this sample (+1625 cash each, +50 win points).
- Do not remove A3 on this test alone. It has no effect in play, but it is story text, so the story owner decides.
- Do not tune balance from the 4-seed ablation. Rerun with at least 8 seeds first.
- Do not compare results from before the event-RNG seeding fix with results after it.
- Do not read the bot's win rates as UI coverage.
