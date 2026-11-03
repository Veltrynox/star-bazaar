# Dead planets: mining rock worlds with danger (decided by the main session, 2026-11-02)

Status: decided for build. Names and numbers are placeholders for owner review. The owner asked us to decide the paywalls ourselves; the choices are in section 4.

## 1. The planets

| Id | System | Name (placeholder) | Texture | Role |
|---|---|---|---|---|
| dead_1 | 1 (Hollin Reach) | Cinderrest | art/textures/planets/planet_toxic_beauty.png | dead world, mining base |
| dead_2 | 2 (Dunmere Reach) | Greywake | same texture, second variant | dead world, mining base |

- They are planet nodes like the others: they can be routed from and sold to, but they have no food or energy market.
- They carry only the two new dead-world resources (section 2), as abundant goods, in planets data format.
- Visual: the planet uses the texture above, plus an inverse fresnel: a dark rim that absorbs light (the edge darkens and the limb does not glow). Done in an fx shader, no collision change.
- Dead planets open with their system. Dead_1 is in system 1, so it is available from the start. Its mining is gated by skills (section 3), so the planet is visible but not yet useful.

## 2. Resources

| Id | Name (placeholder) | Mined on | Used for |
|---|---|---|---|
| dross | Dross Salt | Cinderrest (dead_1) | sold at the trading post, and fabric input |
| nullglass | Nullglass | Greywake (dead_2) | sold at the trading post, and fabric input |

Resources use the same commodity pattern as silk, chips and ore (`<good>_buy`, `<good>_sell`, `GOOD_*_NAME` ids).

## 3. Skills (Research branch, after B1 Prospecting)

- **M1 Cold Survey** (cost 2 points): allows mining Dross Salt on Cinderrest. Requires B1.
- **M2 Deep Cut** (cost 3 points): allows mining Nullglass on Greywake. Requires M1.
- **F1 Fabrication Licence** (cost 3 points): unlocks the fabric at the trading post. Requires M1 and M2.

Points come from the existing sources only (planets, routes, systems). Money never buys skill points (owner rule, 2026-10-28).

## 4. Paywalls (decided)

1. **Skill paywall:** mining each dead world needs its skill (M1, M2). A route from a dead world with no skill is refused, with a line saying which skill it needs.
2. **Fabric paywall:** the fabric needs F1 learned, and then a one-time build cost of **1500 credits** paid at the trading post. Credits are allowed here because the rule is about skill points, not building costs.
3. **Danger paywall:** each dead world has a danger meter that rises while mining it. Clearing a danger is a choice in the connected events (section 5), not a payment.

## 5. Danger events: 3 connected pairs

Each pair is two events. Part 1 fires when the player starts a route that mines the dead world for the first time. Part 2 fires a fixed number of cycles later (proposal: 4), and its text and effect depend on the choice made in part 1. The game needs one new mechanic for this: a choice can schedule a follow-up (this is the scheduled follow-up requested earlier, R1; accepted here by the main session for this goal).

- Pair A (Cinderrest): a crew sickens from the salt dust. Part 1 choice: keep mining (price up for Dross, danger +1) or pull out (route closes 3 cycles). Part 2: the consequence.
- Pair B (Greywake): the glass shifts and a cut wall falls. Part 1 choice: shore it up (cost in credits) or carry on (ore loss chance). Part 2: the consequence.
- Pair C (both): a rival warns about the dead worlds. Part 1 choice: share the lane (income cut) or race (danger up, income up). Part 2: the consequence.

Story rules: the three pairs use the existing story voice (story/voice.md). Keep every text within the length limits in tools/build_story.py.

## 6. Build order

1. Story: the six events and the choice table (story-designer). Needs no code for the text.
2. Data: planets (dead_1, dead_2), resources, skill rows, fabric, pair ids. (gameplay-programmer)
3. Mechanic: scheduled follow-up events (R1) and the danger meter. (gameplay-programmer)
4. Visual: planet texture with the inverse fresnel, placed on both maps. (fx-programmer)
5. Fabric at the trading post, its build cost and the sell line. (gameplay-programmer, then ui-programmer)
6. Balance: economy-designer sets prices, the danger rise and the build cost, and the sim checks decent is not hurt.
7. QA: three strategies end to end with a dead-world route, then fixes (at most three rounds).

## Open for the owner

- Names of the two resources and the two planets (placeholders).
- Whether the fabric product is named now or after the first run.
