# More skills sign-off, round 3 (T173 re-run)

Reviewer: qa-analyst. Build: working tree, `data/skills.json` v7 (36 nodes; FND_BULK and MIL_5B dropped), `data/balance.json` data_version 53, forecast drawn 2 cycles ahead for every run (code change, `game/main.gd`). Nothing in game code or data was edited, nothing committed or stashed. The owner's uncommitted asset work was not touched. No processes left running.

Raw records: `qa/reports/2026-11-05-more-skills-signoff-r3-runs.jsonl` (92 runs). Bugs: `qa/reports/2026-11-05-bug_report-more-skills-signoff-r3.json` (10 entries: 8 medium, 2 low). Driver: `qa/bots/more_skills_signoff_r3.sh` (new, same method as round 2). Analyser: `qa/bots/more_skills_signoff_r3_analyse.py` (new). Per-run wrapper: `qa/bots/skill_signoff_one.sh` (unchanged). Batch output and logs are in the scratchpad (`r3/`).

Seeds 1 to 4, decent unless stated. Focus runs and ablations use `--skip-tutorial --keep-running=38`. `dom_*` runs stop at the win, as in earlier rounds.

## Headline

- No crash, softlock or freeze in 92 runs. Every run printed RESULT.
- The "always_expand must be 0 of 4" target holds: 0 of 4 (round 2 had 1 of 4, at cycle 39). The round 2 win came in a run that learned FND_BULK at cycle 2. That node is gone and the run no longer wins.
- Sloppy 0 of 4, never_expand 0 of 4, unchanged.
- Default decent wins at 27 in 4 of 4, unchanged.
- The main regression is BIO_5B. Round 2 KEEP does not hold on this data. With BIO_5B, bio focus wins at 40, 27, 38, 40 (round 2: 30, 27, 31, 27). Without it, the same bot runs reproduce round 2 exactly (30, 27, 31, 27). In the whitelist arm BIO_5B alone collapses bio seed 4 (no win, cash 492), where the base arm wins at 27.
- LUX_5B is now event-neutral in the controlled arm: realised events, win, cash and share are identical with and without it in 4 of 4 seeds. The natural arms still differ (section 2).
- Verdicts: LUX_5B KEEP; MIN_5B CHANGE; LUX_6B CHANGE; BIO_5B CHANGE (drop if no retune); BIO_6B DROP.

## 1. Verdicts per remaining node

Rules as in rounds 1 and 2 (REACHED in 3 of 4 on-arm seeds; FELT when one measure moves one way in 3 of 4 seeds past its limit: win 1 cycle, cash 5 pct, share 0.02, route capacity 10 pct, down events 1, stock 10 pct). Natural arm = focus run with and without the node. Branch arm = fixed whitelist with and without the node.

| node | reached | measured effect (on vs off) | verdict |
|---|---|---|---|
| LUX_5B | 4 of 4 | Branch arm: win 27/27, 28/28, none/none, 27/27 (identical, seeds 1 to 4); cash, share, route and events identical in 4 of 4. Natural arm: win 27/27, 33/none, none/27, 29/31 (on/off); cash mixed, sign split 2 and 2. Reveal price line UNTESTABLE (no bot reads prices). | KEEP (information only; no measured outcome effect now) |
| MIN_5B | 4 of 4 | Route capacity +10 pct exact in 4 of 4 (2464 vs 2240 units, both arms). Win 27 in every arm; share unchanged. Cash: branch +455 to +629 in 4 of 4 (1 to 2 pct); natural +1.6k, +0.5k, +0.4k, -5.9k. Debris immunity UNTESTABLE: EV17 started 0 times in 92 runs. | CHANGE (capacity real, no outcome effect; the min focus already sits at the cycle-27 floor, so it cannot show a win effect; debris half untested) |
| LUX_6B | 4 of 4 | Branch: route capacity +22, +15, +34, -28 pct; win 27/27, 28/28, 31/none, 35/27 (seed 4 later by 8); cash +2.8k, -2.6k, +2.2k, -21.0k. Natural: win 27/27, 33/39, none/none, 29/27 (on/off); cash -0.2k, +1.4k, -7.6k, -11.0k. | CHANGE (no consistent direction in win or cash) |
| BIO_5B | 4 of 4 | Natural: win 40/30, 27/27, 38/31, 40/27 (on/off); cash lower with it in 4 of 4 (-15.7k, -2.7k, -14.5k, -31.9k); share lower in 3 of 4 (-0.098, +0.088, -0.094, -0.151). Branch: win 27/27, 27/27, 27/27, none/27; cash lower in 4 of 4 (-3.7k, -4.0k, -2.2k, -38.4k); seed 4 share 0.235 vs 0.728. Route capacity change mixed (route sets differ). | CHANGE (FELT, negative as built: slows bio focus, cuts cash, collapses seed 4 in the whitelist arm; drop if the node cannot be retuned) |
| BIO_6B | 1 of 4 natural (seed 1 only); 4 of 4 whitelisted | Natural: learned in 1 of 4 seeds, so the bio focus does not pick it. Branch: 3 to 4 successful hits per run (0 without); bio share +0.007, +0.010, +0.007, +0.008 (below 0.02 in 4 of 4). Hit 0.25 to 0.35 moved share by about 0.003. Win 27 both arms. Cash identical to the unit in all 4 seeds (open question, section 6). | DROP (not reached naturally; not felt when whitelisted, even with the larger hit) |

Verdict count: KEEP 1 (LUX_5B), CHANGE 3 (MIN_5B, LUX_6B, BIO_5B), DROP 1 (BIO_6B).

## 2. LUX_5B: realised event sequence

Controlled arm (branch whitelist, node on vs off, same seeds): identical in 4 of 4 seeds. Starts and the full `event_rows` (every cycle, every active event) are the same. This confirms the round 3 code change: the forecast no longer changes the events.

Natural arm: not identical in 4 of 4 seeds. First differences at cycles 13 to 17 (for example seed 3: 7 starts with the node, 3 without). The natural arms differ in their decisions (the points go elsewhere when LUX_5B is not learned), so the event pool, which reads state, can diverge after a different route or planet choice. UNKNOWN whether the event pool conditions read player state. This is not caused by the forecast, since the branch arm with the same rng path is identical.

So LUX_5B's natural-arm outcome differences (for example seed 3: no win with the node, win 27 without) come from a different path, not from a different event stream caused by the forecast.

## 3. Regression: this round vs round 2 vs last round

Round 2 = `qa/reports/2026-11-05-more-skills-signoff.md` (skills v6, balance v52). Last round = `qa/reports/2026-11-05-skill-signoff-qa.md` (balance v50), as quoted in round 2.

| arm (decent, seeds 1 to 4) | last round | round 2 | round 3 (now) | reading |
|---|---|---|---|---|
| default | 27 x4 | 27 x4 | 27 x4 | same, in band |
| mil focus | 27, 27, 32, 27 | 27, loss at 27 (END_SWEPT), 27, 27 | 30, 27, 27, 27 | fixed (seed 2 back to 27); seed 1 at 30 is in band; cash lower |
| lux focus | 27, 27, 29, none | 27, 27, 27, 32 | 27, 33, none, 29 | **regression**: seed 3 no win (cash 1.2k); seed 2 win at 33 (pacing); seeds 1 and 2 are "won, then outcompeted at 40" in kept runs (section 5) |
| min focus | 27 x4 | 27 x4 | 27 x4 | same, in band |
| bio focus | 30, 27, 31, 27 | 27, 27, 27, soft | 40, 27, 38, 40 | **regression**: 3 of 4 wins after cycle 30; all from BIO_5B (nat_BIO_5B arm = 30, 27, 31, 27) |
| sloppy | 0 of 4 | 0 of 4 | 0 of 4 | same |
| never_expand | 0 of 4 | 0 of 4 | 0 of 4 | same |
| always_expand | 0 of 4 | 1 of 4 (seed 3, cycle 39) | 0 of 4 | target met (section 4) |

Pacing (decent player win 22 to 30 is the band): bio seeds 1, 3, 4 (40, 38, 40) and lux seed 2 (33) are after 30. Mil seed 1 (30) is at the edge but inside the band. Medium, in the bug JSON.

Dominance: sloppy, never_expand and always_expand: 0 of 12 wins.

Points spent / left by focus run (to cycle 39): default 19, 21, 19, 21 spent (left 1, 0, 1, 1); mil 16 to 17 (left 0); bio 16 to 18 (left 0 to 1); lux 20 to 24 (left 0 to 1); min 26 to 30 (left 0 to 1). The FND_BULK removal leaves default and bio spending about the same as round 2.

## 4. always_expand

Still 0 of 4. Now 6 ships in every seed and no win by cycle 40 (soft, cash 20.7k to 29.6k). It learns a similar skill set by cycle 6 to 9 but no longer wins. The round 2 win (seed 3, cycle 39) had FND_BULK, learned at cycle 2, which is now gone. That attribution is by comparison of the two runs, not an ablation.

## 5. Harness caveats (not game bugs)

- `end_cycle_ok` is false in 65 of 80 kept runs. Kept runs end at cycle 39, not 40. The round 2 kept runs show the same flag.
- A kept run keeps its first win but then ends on the final cycle with whatever state it has. Lux seeds 1 and 2 are "win at 27 and 33, then END_OUTCOMPETED at 40". A real player stops at the first win, so the win stands. The bot's kept-run limit (events, chains and closures do not run after a win) is documented in `qa/bots/bot_run.gd`.
- `END_BIO_BAD` is a win ending with a bad outcome text (`story/endings.md`), so the bio win at 38 and 40 with that ending is the intended pairing, not a mismatch.

## 6. Open questions

- UNKNOWN: whether BIO_6B's share change should move cash. Cash is identical with and without BIO_6B in all 4 whitelist seeds while share differs by +0.007 to +0.010 (bug JSON, low, gameplay-programmer).
- UNKNOWN: whether event pool conditions read player state (section 2). A natural-arm difference in the event sequence is seen; the branch arm is clean.
- UNKNOWN: release binary check. Static check only: `export_presets.cfg` excludes `game/debug_menu.gd`, `qa/*`, `tools/*`, and `game/main.gd` `debug_tools_allowed()` returns `OS.is_debug_build()`. No export was built.

## 7. Method and limits

- Four seeds, deterministic (round 2 repeats matched exactly). Four seeds are a small sample; one win cycle or 0.02 share is at the noise edge.
- Natural arms are path-dependent (section 2). The branch arms fix the whitelist and are the cleaner test.
- Route capacity (`route_units_by_market`) is capacity, not volume, and route sets differ between arms. Route verdicts lean on share, cash and win.
- The lock arm (`lock_mil5_bio6b`, `lock_lux7_bio6b`) was run again because BIO_6B changed. Successful hits are 6 cycles apart between different skills in every seed where both fire, and the own cooldowns held. One run (`lock_mil5_bio6b` seed 3) has no win by 40 (low, bug JSON).
- Not run: UI (skill screen, planet panel, reveal price line). Those are the owner's visual checks.
