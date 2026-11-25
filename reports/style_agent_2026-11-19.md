# Star Bazaar: five style and narrative fixes

Applied 2026-11-19 using `tools/style_agent/SKILL.md`. Five issues fixed across eight English strings. No gameplay, balance or art changes.

## Findings and corrections

1. **Win explanation:** The goal tutorial implied finishing construction wins. It now explains the Flagship charter delivery. Evidence: `gdd.md` Win; `game/bazaar.gd` end_cycle/open; `game/gigs.gd` on_arrived_storage. Rule J3/S1.
2. **Removed mining control:** The tip instructed the player to set Mining intensity. It now describes the per-cycle cap, inexhaustible stock and routes. Evidence: `game/dead_worlds.gd` stock_max/exhausted/take; `gdd.md` Dead worlds and Retired. Rule J3.
3. **Storage skill register and scope:** The plain line advertised claiming space and crafting unique resources, although this skill only unlocks storage. It now states the storage unlock; the separate flavour line gives a concrete crew stake. Evidence: `data/skills.json` FND_STORAGE; `data/availability.json` storage and workshop rules; `game/main.gd` _ensure_posts. Rules J3/J5/J7/H3.
4. **House ship explanation:** The tips used unexplained weather jargon and promised upcoming-event details on a card that only shows house name and temperament. They now explain market effects and the actual click result. Evidence: `game/rival_card.gd` describe; `game/rival_ships.gd`; `gdd.md` Houses. Rules J2/J3/H6. This resolves the stale forecast-convoy description in the older glossary in favour of current code.
5. **Income and upkeep guidance:** The route tutorial omitted settlement timing and called credits money. It now specifies cycle-end income and credits; upkeep explicitly includes idle ships. Evidence: `game/route_engine.gd` settle/idle_ship_cost; `game/main.gd` engine.settle and cash update. Rules J3/H6.

## Evaluation history

Round 1 audited the current copy. Round 2 evaluated the autonomous refinements against implementation, paired text and lint. Scores are same-session editorial judgements, not independent-agent results. Each applicable dimension is scored 0–5; the total is out of 100. Visual fidelity is inapplicable. Acceptance requires 90, every dimension at least 4, and no blocking findings.

| Text id | Before score | After score | Before | After |
|---|---:|---:|---|---|
| TUT_G10_DONE_WHY | 80 | 100 | You grow it, stage by stage, on the Space Storage of one system. Finishing it wins the game. | Build it in stages in Space Storage. Fly the charter cargo to the Bazaar with the Flagship to win. |
| TIP_DEAD_WHY | 60 | 100 | Hard mining gives more and draws more raids. Set Mining intensity on its card. | Mining is limited each cycle. The stock never runs out. Use routes to move what you mine. |
| SK_FND_STORAGE_PLAIN | 40 | 100 | You may now claim your own piece of space! Keep resources there and craft unique ones. | Unlock a Space Storage in each open system. Send goods there and store them. |
| SK_FND_STORAGE_FLAVOUR | 75 | 100 | But keep an eye on it. It's valuable. | The crew checks each seal twice. Those crates hold the next shift's pay. |
| TIP_WEATHER | 70 | 100 | A tinted ship is a house convoy. It flies to a world before that house's weather lands. | A tinted ship belongs to a trading house. Houses cause price drops, shortages or higher trip costs. |
| TIP_WEATHER_WHY | 55 | 100 | The houses send weather, not rivals. Click a convoy to see what is due and where. | Click a tinted ship to see its house's name and the kind of market change it brings. |
| TUT_G4_ROUTE_PAY_WHY | 75 | 100 | The route earns when it sells there. That is where your money comes from. | The route's sales add credits at cycle end. Let the cycle finish to see what it earned. |
| TUT_G5_UPKEEP_WHY | 90 | 100 | A ship costs money every cycle, so a route must earn more than it costs. | Each ship costs credits every cycle, even while idle. Its route needs to earn more than it costs. |

Full dimension scores, reasons and evidence: `logs/style_agent/2026-11-19-five-fixes/evaluation_1.json` and `evaluation_2.json`. Source precedence and conflicts: `sources.json` in that folder. Original snapshots, drafts and lint reports are retained there.

## Verification and scope

- `python3 tools/build_story.py` succeeded: 3,172 strings, 25 events, zero skipped entries.
- The eight revised strings passed deterministic lint, length checks and placeholder-multiset checks. The paired-text check is recorded in `lint_final.json`.
- Rebuilt runtime data matches all eight replacements. Comparing to the pre-run working-tree snapshot proves exactly those eight generated entries changed. Events and Russian generated output are byte-for-byte unchanged. Existing unrelated edits were preserved.
- No game window, visual inspection, economy run or broad game test suite was used for this text-only revision.
- English only, as the invoked skill defaults. Russian translations retain the previous wording; this run does not claim to repair those translations. Other unrelated lint findings remain outside these five issues.
