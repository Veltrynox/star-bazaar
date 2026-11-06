# Skills board: team work to fill the skill tree

Owner request 2026-11-05: feature-designer, economy-designer, story-designer and qa-analyst fill the empty skill slots together, cross-examine every skill, and only skills ALL FOUR agree on get built. Owner explicitly called economy-designer and qa-analyst for this (CLAUDE.md gate satisfied). No bot runs, no tools/sim.py: paper review and reading data/code only.

## The bar for every skill
- Impactful: it changes what the player does, not a +2% number nobody feels.
- Its own place: a distinct role, not a copy of a sibling with another target; it competes with something for points.
- Not a trap, not a must-take, not an auto-win when stacked.
- Fits progressive disclosure (no hidden goods named; Availability rule) and the tree's branch identity.
- Money never buys skill points.

## Slots
35 empty slots: 3 Foundations (FND), 8 each for Military (MIL_8..15), Luxury (LUX_8..15), Minerals (MIN_8..15), Biotech (BIO_8..15). Ids may change; a proposal may use fewer than 35 if a slot cannot be argued for (say which and why). Read: data/skills.json, game/skills.gd, game/skill_screen.gd, gdd-skills.md, design/proposals/2026-11-05-skills-fill.md (feature seed, may be rejected), design/proposals/2026-11-05-more-skills*.md, story/skills.md.

## Files (each agent writes ONLY its own files, so nothing collides)
- round1-<agent>.md: your own proposal for all slots. Per skill: id, name, branch, prereqs, cost class (S 1 point, M 2, L 3, T tech), effect, why impactful, what it competes with, risks. Economy gives concrete numbers (placeholders for data/balance.json); story gives names and one plain line; QA gives the player-experience check and exploits.
- round2-<agent>.md: after reading ALL round1 files, a verdict per candidate skill: AGREE, CHANGE (say exactly what), or REJECT (reason). Merge duplicates across agents into one candidate id.
- consensus.md (written by the main session, only from round2 verdicts): skills with four AGREE (after accepted CHANGEs), plus the list of slots left empty and why.

Rounds run in order; a round starts only when the previous round's files from all four agents exist.

## Round 2 rules (key = slot id)
Round 1 proposals differ per slot. In round 2, for EVERY slot id (FND_1..3 in the order each agent listed them, MIL_8..15, LUX_8..15, MIN_8..15, BIO_8..15), write one line block in round2-<agent>.md: which round-1 variant you back (name the agent(s)), your verdict AGREE / CHANGE (exact change, incl. number or cost class) / REJECT-leave-empty (reason), and your final one-line version of the skill (name, prereq, cost class, effect). Also list: (a) QA's binding code findings E1..E14 that each backed skill must respect, (b) stack and auto-win risks you accept or want capped, (c) skills you want cut if the set is too big. Be willing to move toward another agent's variant: the goal is ONE skill per slot that all four sign. Cross-examine hard but converge.
