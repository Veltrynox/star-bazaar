# Pacing retune, 2026-11-01

Change: data/balance.json ship_price 1000 to 900 (data_version 18). Nothing else.

Method: qa/bots/run_batch.sh, strategy decent, in an isolated copy of the repo at commit 87fc76e (the live working tree had other agents' uncommitted game edits, which made runs drift). Private TMPDIR. Permit group: `--permit=2 --skill-order=C1,C2,C4,A1,C3`. Closure group: `--close-at=10`.

| Group | Seeds | Before | After |
|---|---|---|---|
| natural | 1-30 | 28/30, cycles 19-30 | 29/30, cycles 20-29, median 22 (loss: seed 7) |
| permit 2 | 1-20 | 14/15, cycles 29-30 | 20/20, cycles 23-28, median 26 |
| closure at cycle 10 | 1-20 | 9/10 | 19/20 (loss: seed 7) |

Caveat: the gain is a cliff. Start cash 1800 buys two ships at 900 on cycle 1. At ship_price 910, 950 or starting_credits 1799 the permit path goes back to 29-30. tools/tests/run_tests.gd (_test_energy_then_food) sets cash to ship_price - 1 so the "second ship not affordable" check still tests its intent. Tests: pass=513 fail=0.

Rejected trials (6-8 seeds each): ship_price 800 (natural 20-23, too early), trip_cost 70 (permit path unchanged), permit_2_cost 300 or 150 (no gain over 600 at 20 seeds), permit_points_2 2 (bot lost all).

Open: seed 7 still loses natural and closure. Re-run after the route income change lands. Sloppy, never_expand and always_expand were not re-run.
