# Star Bazaar: text rules for the Generator, Evaluator and Refiner loop

Owner-facing summary: every text the loop writes or fixes is checked against these rules. H rules are checked by a script (`python3 tools/text_lint.py`). J rules are judged by the Evaluator agent, which must quote the text and name the rule. `story/voice.md` stays the voice and glossary source; this file adds the owner's corrections as checkable rules and keeps the precedents (rejected text, then the accepted fix) that show the direction.

Order of priority when rules pull apart: **clear > true > voice**. A line that is moody but unclear fails, however good it sounds. That ordering is the single strongest pattern in the owner's corrections (T338 to T345, T368, GIG02, GIG03, GIG04, MIL_5).

Loop: `.claude/workflows/text-loop.js` (launch by `scriptPath`, see the header of that file).

## H rules (script, `tools/text_lint.py`; a "fail" blocks the text)

| Id | Rule | Source |
|----|------|--------|
| H1 | Length within the id's max (same limit as `tools/build_story.py`; Russian: warning only, soft target) | voice.md, Length limits |
| H2 | No sentence over 20 words | voice.md, Simple words |
| H3 | No exclamation mark | voice.md, Do not |
| H4 | No digit in a story text (events, gigs, endings, preface, skill flavour, chain texts); numbers come from {placeholders} | voice.md, Do not |
| H5 | No long dash (English); use a comma or a full stop | voice.md, Punctuation |
| H6 | No retired or banned word: rival(s), competitor(s), standings, bot, AI, market share, game over, comrade, waypoint, bundle, warehouse, money, colony, real-world names (Nasdaq and the like), beat/weaken/hurt a house. Russian: «затоваривание», конкуренты, боты | voice.md glossary; T287; T341; owner 2026-11-14 |
| H7 | No emoji | voice.md, Do not |
| H8 | A rewrite keeps exactly the placeholders of the text it replaces | build and runtime fill |
| H9 | No designer note inside a text (the build skips it) | build_story.py |
| H10 | Chain effect lines read "Get: ... Cost: ... Weather: ..." and use no "but", "however", "at least" | voice.md, Market chains |
| H11 | No verdict word in a chain text (fail on buttons, warning elsewhere) | voice.md, Market chains |
| H12 | Buttons: sentence case, no full stop ("Send to..." keeps its dots) | voice.md, Capitalisation |
| H13 | The two option buttons of one choice within 5 characters of each other (warning) | voice.md, Market chains |

## J rules (Evaluator judges; each finding quotes the words and names the rule)

**J1 Plain first, literal beats image.** A player who never read a manual understands the line in one read: what it is, what happened, what they can do. When a line must explain something (a goal, a building, a mechanic), a literal sentence beats a picture. Source: T338, T341, T345, T346 (the owner rejected "the exchange where the whole sky trades" three times until it said "one market hall all worlds trade in").

**J2 No unintroduced terms.** Every game word in the text is one the player has already seen on screen at that point. Otherwise say what it is in plain words, then name the concrete effect. Watch for: house, desk, hub, weather, charter, quota, Plan, ledger, posts and ids like MIN_5. Source: owner 2026-11-14 ("what house? we never introduced houses"), GIG03 and GIG04 ("what desk? what is going on?"), hub panel T360, owner report "wtf is MIN_5".

**J3 True to the game.** The text never asks for an action the game does not take, and never promises an effect the code does not do. Tutorial and tip lines name the exact control and the exact click ("the lit Energy button", not "Buy"). Source: T343 (tutorial said press "Buy", the action is the resource button), T335/T344 (asked for a right-click that does nothing), T330 ("Watch stored/capacity" named no action), T377 (profit lands at the cycle end, say so). The Evaluator checks these against the code or data the line describes (grep `game/` for the id, read the matching rule in `data/`).

**J4 A story, not a riddle.** Story texts (gig hooks, events, endings) say who, what happened, and why it matters, so the reader can follow cause and effect. One concrete human detail makes it pull. No coded hints the player cannot decode. Source: T368 ("replace this haiku with something more storytelling"), GIG02 ("rewritten so it makes sense"), GIG03 and GIG04 (2026-11-14).

**J5 Not dry.** Story texts carry stakes and a concrete, named loss: a person, a debt, a bunk, a shift. One odd sensory detail at most. Source: T130 ("event texts are dull"), T230 ("less dry"), T242 (skills with emotional weight per branch).

**J6 Deadpan irony, small and never in the way.** About one line in six. Dry, understated, no slapstick, no memes. It never hides what the player must know. Source: T326 (welcome button "Sign here, and here"), owner 2026-11-13 ("keep it ironic... keep the tone of the game").

**J7 Register by place.** Buttons, labels, notices, tutorial and tip lines are plain and carry no flavour. Feeling lives in story texts only. Skill lines: the plain line first, starts with a verb and names the real change; flavour second. Source: voice.md; owner 2026-11-04 (skill panel: "the first line should explain straight what this skill does, the second line is an engagement part").

**J8 Neutral choices.** Both options give something and cost something. No text says which is right or what the choice says about the player. Source: voice.md, Do not and Market chains.

**J9 Paired texts agree without repeating.** Texts that explain the same thing in two places (preface and last tutorial card, a tip and its why line, hook and arrival) say the same facts in different words. A hook never gives away its arrival scene or choices. Source: T345 with T346; story/gigs.md header.

**J10 Nothing hidden is named.** A text never names a good, workshop or storage feature before its `visible_when` in `data/availability.json` is true. Source: CLAUDE.md, Availability rule.

**J11 Russian reads as Russian.** Natural sentences, not clipped labels ("Интервал выбора, циклов: 7" fails). Terms exactly as in `story/ru/GLOSSARY.md`. Written by hand by an agent, never by a script. Source: owner 2026-11-14; CLAUDE.md, Translation.

## Precedents (rejected, then accepted; newest last)

**Goal card, TUT_G10_DONE (J1)**
- Rejected: "The Star Bazaar is where the sky trades. Build it." / "The Star Bazaar: the great market you raise on one world." / "The Star Bazaar: the exchange where the whole sky trades."
- Accepted (T345): "The Star Bazaar is one market hall all worlds trade in." + "You build it, stage by stage, in the Space Storage of one system. Finishing it wins the game."

**Storage card, TUT_G7_STORAGE (J3)**
- Rejected: "Watch stored/capacity on the resource button." (no action) / "Right-click the lit resource button, then let a cycle end." (the right-click does nothing)
- Accepted (T344, then 0fde49f): an explanation card with Next: "The lit text shows the stock in Company storage."

**Gig hook, GIG03 (J4, J2)**
- Rejected (riddle): "A tapping on the open band. Always eleven taps, then a gap."
- Rejected (unintroduced term): "A Bureau pod calls for a desk that no longer exists. Clerk Edrin signed its last receipt..."
- Accepted (2026-11-14): "An automatic Bureau signal comes from a missing courier pod. Courier Lio's last message says a rescue ship took her crew after debris broke the pod's drive. She left an unused production charter sealed inside. Her coat is tied around its case so the finder will see it."

**Gig hook, GIG04 (J4, J1)**
- Rejected: "A voice gives her name as Sella and offers your crew a berth. The station lies off every lane. Her call leaves no gap for an answer..." (eerie, but what is happening?)
- Accepted (2026-11-14): "A station sends a closure call. Sella says she is its last caretaker. The workers left when the route moved, but their companies never collected the stock. The Bureau has ordered her to clear the rooms and leave. She asks one passing crew to witness the closing."

**Skill plain line, SK_MIL_5_PLAIN (J2)**
- Rejected: "Every {m} cycles pick a house: its weather on your worlds and lanes is {pct} weaker for {n} cycles."
- Accepted (2026-11-14): "Every {m} cycles, pick one of the three trading houses whose convoys fly across your map. For {n} cycles, its market shocks (price drops, demand jumps, jammed lanes) hit you {pct} softer."

**Welcome button, SCR_PREFACE_BTN (J6)**
- Accepted (T326): "Sign here, and here" (deadpan, fits the Bureau, 19 characters).

## Adding a rule

When the owner corrects a text: add the rejected and the accepted text as a precedent above, under the rule it shows. If the correction is a new kind, add a J rule with its source (date, task id, the owner's words). If it can be checked by pattern without false hits, add it to `tools/text_lint.py` as an H rule too. Keep rules plain; the Evaluator reads this file on every round.
