# Star Bazaar: project state (under 40 lines; workflow gdd-process.md; updated 2026-11-03)

## Current goal: Four Markets (design pack design/proposals/2026-11-03-four-markets*.md; endings story/endings.md)
- Win: over 50% of one market (Military, Luxury, Minerals, Biotech) vs three rivals; 40 cycles; early win from cycle 22 (hold 5), gate win_gate_cycle 38. Old cash goal and Release/Corporation endings retired.
- Built on branch next: market foundation, chains (28 steps), skill trees, endings, Competitors menu, QA bot (commit 16c4a05). balance.json data_version 39 (interim retune, bot_scale 0.22).
- GDD updated 2026-11-03 (gdd.md, gdd-skills.md draft 2, gdd-log.md). Queue counts (schedule.json) were last recorded 2026-11-02 and are UNKNOWN now; producer to refresh.
- Still on hold: system 3 (not built, tuned or tested). Space Storage: sell orders draw from its stock (owner 2026-11-01, T139/T64); built status UNKNOWN.

## Standing rules
- Money never buys skill points. Choices are neutral (no good or bad labels); the hidden chain direction picks the ending. Price skills have no share effect. Old saves dropped.
- Retired: shield and EV18, Minerals events EV29-37, old event stances, cash goal, Release/Corporation.

## Open questions for owner (Four Markets, judged in play)
1. Names of rivals (Harrow Combine, Velvet Concord, Ostrel Syndicate), goods and endings: working names until judged in play.
2. END_SWEPT fires early on weak play (a swept run at cycle 27 was seen with bot_scale 0.85): is that acceptable, or move sweep_earliest_cycle?
3. Do workshops matter for share? UNKNOWN until played (they add tech and crafted goods; the v39 retune was measured with a bot that does no crafting).
4. ship_cap 5 and what it costs to feed five ships (trip cost, maintenance, overhead): is the cap right? UNKNOWN until played.
5. Do the Military chains read right in play (neutral options, hidden direction)? Luxury, Minerals, Biotech chain texts follow after this check.
6. Carried over: is system 3 needed; is the asteroid research point a skill point; does "money never buys skill points" cover all spending; nomads and planet types (T104, T111, T113, T115).

## Open data and design gaps (not owner questions)
- Pace targets in balance.json "targets" are from the cash goal; re-base UNKNOWN.
- data/events.json still has an EV18 row and has no EV40-51 rows; chains.json holds them (pool_new). Draw status UNKNOWN.
- Default permit-2 bot and spread bot still collapse in QA (code gaps in the QA handoff).
- Human win rate for a focused market: UNKNOWN (paper model and bots only).

## Goals and reports
- skill-tree-progression: done 2026-10-31 (goals/skill-tree-progression/report.md); superseded by the market trees.
- feature-exploration-2026-11-02: partial (goals/feature-exploration-2026-11-02/report.md).
- trade-goods-asteroid-mining: built, QA pacing failed (goals/trade-goods-asteroid-mining/report.md).
- Four Markets goals 2 to 6: see git log on next and qa/reports/2026-11-03-market-foundation-bug_report.json.

## Latest handoff per agent
- general-purpose: handoffs/general-purpose/2026-11-03-gdd-market-goal.json
- Other agents: latest files are in handoffs/<agent>/ (list not refreshed this pass; producer to update).
