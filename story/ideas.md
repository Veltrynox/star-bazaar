# Ideas (owner decides; none built)

1. Events seen: the game keeps the set of event ids seen this run, so Full endings can name the real events (the blight, the glut) instead of staying general. Needs: a list of seen event ids saved with the run, passed to the ending picker.
2. Title line from the last run: the main menu shows one line naming the side and ending of the previous run ("Last run: stayed as a corporation, The Common Table"). Needs: the recorder from T78 read at start, plus a label on the title screen.
3. Bureau bulletins: a one-line, joke-only "Plan notice" in the news feed every fifth cycle, no effect on numbers. Needs: a list of lines in data and a hook on every fifth cycle.
4. Completion ending line for the solar shield (T100): one habitability line per ending tier, only if the shield was built. Needs: a "shield built" flag passed to the ending picker; owner approval of the wording, since story/endings.md has none today.

## Session 2026-11-04 (events rewrite)
5. Skill-aware bodies: an event body that adds one line only when the player knows a named skill (for example "Your drydock friends are already on the line."). Needs: an optional {skill_line} slot in chain and pool events, filled from a text id per learned node.
6. Disobey option (owner example, MIL_B1): a third, skill-free choice with a timed Sell price penalty on one planet until the next election. Needs: a new effect type, planet Sell price down for a number of cycles, in chains.json.
7. Pool events in Russian: EV01 to EV28 get StoryText ids (EV<nn>_TITLE, EV<nn>) so the Russian layer can serve them. Needs: ids in the build, scope change in tools/build_story.py, events.gd reading text by id.

## Session 2026-11-04 (Military and Biotech flavour pass)
8. Cast page: a "People" tab in Competitors listing the recurring names (Sulo, Brask, Voss, Fenn, Marrow, Ryke) with one line each, filled as they appear. Needs: a seen-names list saved with the run and one UI page.
9. Biotech dread tint: Biotech and Military chain popups get a cold green or a brass frame. Needs: two frame colours in the event popup, art only, no mechanic.


## Session 2026-11-04 (name for the Space Storage portal)
10. Name for the building that moves goods between Space Storage of two systems. It shows only inside the Space Storage window, so it stays hidden until FND_STORAGE is learned (availability rule). Needs nothing new. Shortlist (limit 24, next to Munitions Line, Atelier, Culture Lab, Smelter, Fabric, Null Core):
- Ledger Fold: the Common Ledger writes the goods off in one system and the entry is honoured in the other. Two plain words like Null Core; the Bureau joke sits in "Ledger", the physics in "Fold".
- Seam Office: a clerk's desk at a thin place in space where stock is passed through. Sounds like a post office; a little domestic next to Smelter.
- Common Chute: the Commons shares everything, so goods simply drop into someone else's storage. Funniest, but "chute" reads small and low.
- Transfer Aperture: the form's own title for the opening. Accurate and dry, but long and the most clerical of the six.
- Stamp Arch: goods pass under it and come out stamped in another system. Light, visual, a bit toy-like beside Null Core.
- Fold Registry: the office that records each fold. Fits Bureau tone, but sounds like a place that files, not a thing that moves goods.
Recommendation: Ledger Fold (11 characters). It is short enough for any button, ties to the Common Ledger already in the glossary, and promises only a transfer. No real franchise term, no goods named.
Draft rows (not in screens.md yet; ids are proposals; limits in characters):
SS_LEDGER_FOLD_NAME | 24 | Building name in the Space Storage window | Ledger Fold
SS_LEDGER_FOLD_DESC | 110 | Space Storage window, one-line description | Moves goods from the Space Storage of one system to another. Built once, in a Space Storage.
SS_LEDGER_FOLD_BUILD | 28 | Build button; {name} and {cost} filled by the game | Build {name} ({cost} cr)
SS_LEDGER_FOLD_BUILT | 110 | Space Storage window, built state | {name} is built. Goods can now move between systems.
SS_LEDGER_FOLD_SENT | 110 | Notice after a transfer; {amount}, {commodity}, {system_a}, {system_b} filled by the game | Moved {amount} {commodity} from {system_a} to {system_b}.
Notes: the build button as the owner asked is 19 characters plus {name} and cost; with "Ledger Fold" and a 4-digit cost it is 29 characters, over the 24 button limit in voice.md. Either allow 30 for this button, or use the shorter "Build Ledger Fold: {cost}" (the Null Core pattern, 25 plus digits). {system_a} and {system_b} are new placeholders; the existing ones are {planet_a} and {planet_b}, so the programmer must add them or the notice must name planets. "Built once" in the description is an assumption; remove it if more than one can be built.
