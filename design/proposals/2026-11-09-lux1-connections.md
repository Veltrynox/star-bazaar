# LUX_1 rework: from Price Whisper to Dressing the Stars (2026-11-09)

Author: feature-designer. PROPOSAL ONLY, waits for the owner. Nothing is built; no data/, game/, story/, gdd or test file was touched. Numbers are UNKNOWN for economy-designer; only shapes and ranges are given. English only (Russian waits for the owner, then a Haiku pass).

Read: data/skills.json (LUX_1, LUX_3, LUX_5B, MIL_8, vocabulary), game/skills.gd (`reveal_cycles`, `ship_price_mult`, `weather_warning_extra`), game/ships.gd `price`, game/main.gd (ship buy, `best_partner_line`), game/planet_panel.gd 592-614, game/route_engine.gd `_note_sale` and `best_partner`, game/events.gd `price_factor`, story/skills.md, story/gated_options.md, story/events.md EV12, story/screens.md, story/voice.md, tools/tests/run_tests.gd, qa/bots.

Note: the in-game name of LUX_1 today is "The Whisper Circle" (story/skills.md). "Price Whisper" lives on only in code comments, gdd-skills.md, gated_options.md, EV12 and screens.md place notes.

## 1. The proposal (ranked 1 of 1)

- **Problem:** LUX_1 shows next cycle's prices. That is a reading aid, not a Luxury identity, and it overlaps LUX_3 and LUX_5B.
- **Idea:** LUX_1 becomes a connections skill. You ship gowns for screen stars, the gossip spreads world to world, and new ships cost less. The cut starts small at once and grows by one step for each new world that has bought enough of your Luxury goods, up to a cap.
- **Player's new choice:** where to sell Luxury. Selling a little into many worlds grows the cut; selling a lot into one world does not. It pulls the Luxury player outward and ties Luxury to fleet growth.
- **Risk:** stacks with MIL_8 Yard Account (also a ship cut); a cheap fleet may make the win easier. Cap and step must be set with that in mind. Lowers the salvage credit (salvage is a share of the ship price), as MIL_8 already does.
- **Cost:** gameplay-programmer M, economy-designer S, story-designer S, ui-programmer S, doc-manager S. Total M.
- **Questions:** see section 7.

## 2. Name and text (story-designer finalises; limits from story/voice.md)

| Id | Limit | Draft |
|---|---|---|
| SK_LUX_1_NAME | 24 | Dressing the Stars (18) |
| SK_LUX_1_PLAIN | 110 | Cuts the price of new ships. The cut grows with each world you sell Luxury to. Unlocks Luxury crafting. (103) |
| SK_LUX_1_FLAVOUR | 90 | A star wears your gown on the screen. By morning the whole dock says your name. (77) |
| Flavour alt. | 90 | You dress the stars of the screen. They talk. Every door they open stays open. (79) |
| Name alts. | 24 | Gossip Circle; Stars in Your Gowns; Word of the Gowns |

"Screen stars", not "film stars" or "movie stars": the voice rules ban real-world terms and the word "star" alone would be read as a sun. Plain line starts with a verb, names the real change, no numbers (voice rule).

New labels (plain, no flavour; ids are suggestions):
- `LBL_LUX1_WORLDS` (60), skill detail live line: "Worlds that know you: {n} of {max}. Ships {pct}% cheaper."
- `NOT_LUX1_WORLD` (110), notice once per new world until the cap: "Word reaches {planet}. Ships now cost {pct}% less."

## 3. Mechanic

**Counter (recommended): worlds that know you.** A world joins the set once it has bought at least K units of Luxury-market goods from the company, summed over the run. Any sale counts: route delivery, sell order, Pathfinder sale. All three already pass through one hook, `RouteEngine._note_sale(c, n, planet)`; the counter adds `if Markets.market_of(c) == "lux"`.

Why this counter:
- Readable: one whole number, tied to place names the player knows. It fits the flavour (gossip goes world to world).
- Hard to farm: each world counts once, ever. The number of worlds is fixed, and K stops a one-unit drip.
- It rewards reach, not grind. Rejected: "cycles with a Luxury lane running" (a one-unit lane farms it and it grows by itself over 80 cycles); "units sold" (unbounded, rewards one fat lane); "ships bought" (snowball, no Luxury play).

**Formula (shape only):** `cut = min(cap, base + step x W)`, applied as `price x (1 - cut)`, multiplied with MIL_8 the same way `ship_price_mult` already stacks `ship_price_pct` effects. W = worlds in the set.

| Key (balance.json, economy-designer) | Suggested range | Why |
|---|---|---|
| `skill_LUX_1_ship_base` | 0.05 to 0.10 | Value on the turn you learn it (attar is not crafted yet, W = 0) |
| `skill_LUX_1_ship_step` | 0.02 to 0.05 per world | Each world is felt on the buy button (about 20 to 45 cr at ship_price 900) |
| `skill_LUX_1_ship_cap` | 0.20 to 0.30 | Reached in the second or third system, not in system 1 |
| `skill_LUX_1_world_units` (K) | 5 to 20 units | Stops a one-unit drip; a normal lane passes it in a cycle or two |

UNKNOWN: combined floor with MIL_8 (0.15 now). Suggest economy-designer sets a total ship-cut ceiling or accepts the product.

**Data shape:** new effect type in the vocabulary, e.g. `ship_price_growth: {base_key, step_key, cap_key, count_key}`; `Skills.ship_price_mult()` reads it next to `ship_price_pct`. LUX_1 `effect` becomes this; `extra` (Atelier workshop, attar good) stays as is.

**When counting starts (owner choice):** recommended, track from the start of the run and apply only once LUX_1 is learned. It is simpler to save and test, and earlier Luxury play pays off on learn. Alternative: count only after learning (feels more caused by the skill, slower).

**Saved state:** `lux_units_by_world` {planet: units} until K is reached and `lux_worlds` [planet ids], in `Skills.to_dict` / `from_dict` (already holds `bot_used`, `stock_grown`).

**UI:**
- Buy ship button (ship_panel.gd 190-207) already shows `Ships.price`, which already applies `Skills.ship_price_mult()`. No layout change, the price drops by itself.
- Skill detail: one live line (`LBL_LUX1_WORLDS`) under the plain line while LUX_1 is learned (ui-programmer).
- Notice on a new world (`NOT_LUX1_WORLD`), silent after the cap (gameplay-programmer).
- Optional (owner): show the cut on the buy button tooltip ("Your connections: -{pct}%").

**Availability:** the line names only a count and planets that already took a sale (so they are open and drawn). It never names a good. "Luxury" is already named by the LUX_1 node itself. No new good, workshop or storage, so no new Availability rule.

## 4. What LUX_1 keeps

- `extra`: unlock Atelier workshop and attar good. Unchanged.
- Id `LUX_1`, tier 1, cost 1, prereqs (FND_STORAGE, FND_PERMIT, FND_PROSPECT). Unchanged.
- Gate for the rest of the Luxury tree (LUX_2, LUX_3, LUX_8 prereqs; chain triggers `skill_learned:LUX_1` in data/chains.json; availability.json rules for the atelier and its good). Unchanged.

## 5. Where the price reveal goes (it must not vanish)

Today: LUX_1 `reveal_prices` 1 cycle shows two lines per good on the planet panel: best route partner (`LBL_BEST_PARTNER`) and next-cycle prices (`LBL_NEXT_PRICE`). LUX_5B (prereq LUX_3) shows 2 cycles ahead and 2-cycle event warning.

**Recommended (A): move `reveal_prices` cycles 1 to LUX_3 as an `extra`.** LUX_3 "Early Invitation" already warns one cycle before an event; it becomes "the information skill": next-cycle prices plus event warning. LUX_5B then reads as its upgrade (2 cycles of both), which is the path it already sits on. No code change in planet_panel.gd: it reads `reveal_cycles()`, which reads data.
- New SK_LUX_3_PLAIN draft (110): "Shows next cycle's prices and warns you one cycle before an event, in all four markets." (87)
- Cost: LUX_3 gets stronger for the same 2 points. Economy-designer checks cost (UNKNOWN).

Alternatives for the owner:
- (B) Give the reveal to LUX_5B only. LUX_5B already shows both next-cycle and 2-cycle lines on its own. Fewer points spent on information; reveal moves to tier 3. LUX_3 unchanged.
- (C) Move the best-partner line to the base game (it is a planning hint, not a Luxury power) and give next-cycle prices to LUX_3 as in A. ui-programmer S.

## 6. Ripple list (every reader of reveal_cycles or Price Whisper)

| # | Place | What it does today | Handling (recommended, option A) | Owner |
|---|---|---|---|---|
| 1 | data/skills.json LUX_1 | `reveal_prices` cycles 1 | New effect type; extra unchanged; add type to `vocabulary` | gameplay-programmer |
| 2 | data/skills.json LUX_3 | `event_warning` 1 | Add `extra` `reveal_prices` cycles 1 | gameplay-programmer |
| 3 | data/skills.json LUX_5B | reveal 2 + warning 2, prereq LUX_3 | No change; now a clean upgrade of LUX_3 | none |
| 4 | data/balance.json | none | Four new keys (section 3) | economy-designer |
| 5 | game/skills.gd `ship_price_mult` | product of `ship_price_pct` | Also multiply the growth cut; add counter state to `to_dict`/`from_dict` | gameplay-programmer |
| 6 | game/skills.gd `reveal_cycles` | max of reveal effects + `weather_warning_extra()` | No code change. See quirk in row 18 | gameplay-programmer |
| 7 | game/route_engine.gd `_note_sale` | fills needs, counts units | Add Luxury per-world count | gameplay-programmer |
| 8 | game/planet_panel.gd 592-614 | best partner + next price at reveal>0, 2-cycle line at >=2 | No logic change; fix comments "LUX_1 Price Whisper" to "price reveal (LUX_3)" | gameplay-programmer |
| 9 | game/main.gd `best_partner_line`, game/route_engine.gd `best_partner`, game/events.gd `price_factor` | comments name LUX_1 | Comment fix only | gameplay-programmer |
| 10 | game/ships.gd `price`, ship_panel.gd buy button | applies `ship_price_mult` | No change; discount shows by itself | none |
| 11 | game/main.gd salvage (about line 2661), stranded/rescue checks (2249, 2267), next_up.gd need cash | use `Ships.price` | Lower salvage with the cut, as with MIL_8 today; lower rescue line is fine. Owner: keep salvage on the base price? | economy-designer decides |
| 12 | story/skills.md SK_LUX_1_*, SK_LUX_3_PLAIN | old texts | Section 2 and 5 drafts | story-designer |
| 13 | story/events.md EV12 body | ends "Price Whisper shows next cycle's prices, rumour or not." | Rewrite the last sentence (name LUX_3's new name, or drop the skill mention) | story-designer |
| 14 | story/screens.md place notes of LBL_BEST_PARTNER, LBL_NEXT_PRICE, section title | say "Price Whisper" | Place column to "price reveal (LUX_3)"; texts unchanged | story-designer |
| 15 | story/gated_options.md LUX_A1 opt_c, LUX_B1 opt_c | SPEC ONLY, not built, gated on LUX_1 prices | Keep the LUX_1 gate, rewrite the hook to connections: A1 "Ask a star to wear it" (as opt_a, no volume dip); B1 "Let a star be seen there" (as opt_b, stall cost halved). Effects unchanged. Alternative: re-gate to LUX_3 (but LUX_A3 already uses LUX_3) | story-designer |
| 16 | gdd-skills.md lines 74 (LUX_1) and the LUX_3 line | old effects | Update after approval | doc-manager |
| 17 | tools/make_skill_icons.py LUX_1 "eye: next prices", art_source/ui_glyph_skill_atlas.svg | eye glyph | New glyph for LUX_1 (gown or ripple); the eye could move to LUX_3. Regenerate with the tool, never by hand | ui-programmer (optional) |
| 18 | Quirk found: `reveal_cycles` adds `weather_warning_extra()` | MIL_7 and LUX_15 (weather warning) also turn on the price lines today, without LUX_1 | Not part of this change. Owner: intended or a bug? If a bug, a one-line fix (gameplay-programmer S) | owner |
| 19 | data/ceos.json ceo_man_02 perk `reveal_prices` (home, first cycle) | own source | No change | none |
| 20 | game/save_game.gd LEGACY B3 to LUX_1 | old-save mapping | No change (id stays) | none |
| 21 | tools/tests/run_tests.gd 2989-2991 | expects `reveal_cycles() == 1` after LUX_1 | Change to LUX_3 or move the check after LUX_3 is learned | gameplay-programmer |
| 22 | tools/tests/run_tests.gd 4427 block | comment "LUX_1 Price Whisper" (tests `trade.price` next-cycle, no skill) | Comment only | gameplay-programmer |
| 23 | tools/tests/run_tests.gd 9278-9284 | "LUX_1 and LUX_3 alone reveal 1" | Passes under A (LUX_3 now reveals); fails under B; adjust label | gameplay-programmer |
| 24 | tools/tests/run_tests.gd 9360, 2734, 3075 | atelier with LUX_1, branch screen, migration | No change | none |
| 25 | New tests | none | Counter: K threshold, one count per world, cap, save round-trip, stacking with MIL_8 | gameplay-programmer (run only when the owner asks) |
| 26 | qa/bots/bot_run.gd 265 lux skill order, qa/bots/skill_final_review.sh `abl_LUX_1`, qa/bots/metrics.py | learn order and ablation | No code change; the ablation now measures the ship cut. Owner-run QA only | owner |
| 27 | data/story_text_ru.json, story/ru | Russian of SK_LUX_1, SK_LUX_3_PLAIN, EV12 | Goes stale; Haiku pass when the owner asks | owner |

## 7. Save compatibility

- Id `LUX_1` stays, so `learned_skills` loads unchanged and the new effect applies at once.
- New keys `lux_worlds`, `lux_units_by_world` default to empty when missing. The base cut applies right away; the step grows from the next qualifying sales. Optional backfill from past sales is not possible today: `sales_units` is per good, not per world. UNKNOWN whether Prosperity fill keeps enough per-world history to seed it.
- An old save with LUX_1 and without LUX_3 loses the price lines on load (option A). No refund: points cannot be bought and there is no respec. Owner may accept this (dev saves only) or ask for a one-time skill point refund on load.

## 8. Effort

| Agent | Work | Size |
|---|---|---|
| economy-designer | Four LUX_1 keys; LUX_3 cost check; MIL_8 stacking ceiling; salvage base | S |
| gameplay-programmer | New effect type, counter in `_note_sale`, save state, notice, LUX_3 extra, comment fixes, test updates and new tests | M |
| story-designer | LUX_1 name/plain/flavour, LUX_3 plain, two labels, EV12 line, screens.md places, gated option hooks A1/B1 | S |
| ui-programmer | Live line in skill detail; optional tooltip; optional new glyph | S |
| doc-manager | gdd-skills.md LUX_1 and LUX_3 lines | S |

## 9. Open questions for the owner

1. Counter: "worlds that took K Luxury units" (recommended), or another (cycles with a Luxury lane, units sold, ships bought)? Count from run start or only after learning LUX_1?
2. Price reveal goes to LUX_3 (A, recommended), LUX_5B only (B), or LUX_3 plus best-partner line in the base game (C)?
3. Name: "Dressing the Stars", "Gossip Circle", or other? Keep the LUX_A1/B1 gated options on LUX_1 with connection hooks (recommended), or re-gate them?
4. Should the ship cut also lower the salvage credit, as MIL_8 does now?
5. Is the MIL_7 / LUX_15 weather warning meant to switch on the price lines (row 18)?
