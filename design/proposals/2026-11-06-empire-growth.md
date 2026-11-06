# Star Bazaar: EMPIRE GROWTH (2026-11-06)

Author: feature-designer. Proposal only. Nothing is approved; the owner decides. No balance numbers (economy-designer sets all), no story text (story-designer), no code. Built on: design/proposals/2026-11-06-mechanics-review.md, gdd.md, gdd-skills.md, and checks in game/ and data/ (planets.json has 10 planets in 2 systems; goods.json has 21 goods; availability.json already evaluates "good visible when ..." rules through game/conditions.gd; planet_banners.gd, planet_hint.gd, cash_forecast.gd, storage.gd, storage_link.gd, workshops.gd, pathfinder.gd all exist).

Working name for the new spine: **Prosperity**. Tier names (Outpost, Settlement, Town, City, Metropolis or other) are story-designer's.

---

## 1. The pitch

### The new core loop in 5 lines
1. A world you supply **grows**: each Prosperity tier has a short list of needs (goods). Meet them for a few cycles and the planet levels up: bigger model, more night lights, more traffic, and a new, longer needs list.
2. New needs name goods you do not make yet, so the empire's own appetite pulls you to the next planet, the next workshop, the next system.
3. Every level you lift a world, you hand the old work to automation and get a bigger toy: trade -> route -> **hub** (a grown world feeds its neighbours by itself) -> **system** (set a stance and it runs as one unit).
4. Rivals stop being a score. They become **market weather**: three houses whose moves cause price storms, shortages and one-cycle windfalls you can ride or dodge.
5. You win by building a **thriving empire** (worlds grown, systems linked, chains completed), and the ending says what kind of empire you built. A "next thing" is always on screen.

### A great 30-minute session (1 cycle = about 1 minute today)
- **0:00-2:00** Voltara, alone, dim. Planet card: "Voltara needs: food." Buy food at the one open source, send it. The planet blinks, a small supply ship idles in orbit. Fast, clear first win.
- **2:00-4:00** Voltara hits tier 2 (about cycle 3): the dark side lights up, a second ship appears in orbit, a new need shows (powder). A fresh skill point pops. The Next Up bar now says "Ashgate has what Voltara wants: fly the Pathfinder there". The scout survey reveals Ashgate's needs and what it sells.
- **4:00-8:00** Three planets alive, two lanes. Each planet has a progress ring around it. One planet is "one good short" and pulses. The player fixes it, a chime rises, the tier-up plays. Market weather arrives (Harrow dumps ore: a price dip for 3 cycles); the player redirects one lane for a windfall.
- **8:00-14:00** First hub: Voltara (tier 3) is flagged "Hub-ready". The player turns it on; four manual lanes dissolve into one glowing catchment ring that keeps itself fed. The player's hands are free for the next thing: the first workshop, because a tier-3 need (rounds) cannot be bought raw.
- **14:00-20:00** Home system is lit: all five planets tier 3+. A "System Charter" moment: the system gets a glowing arc on the galaxy view and a stance choice. Permit for system 2 is the next visible goal, one step from affordable.
- **20:00-26:00** System 2 is dark and hungry. A trunk line (Storage Link) joins the two systems. Dross from Cinderrest is needed for tier-4 alloy; the dead world is dangerous, and raiders appear. The player picks an extraction intensity.
- **26:00-30:00** Two systems glow in the galaxy view. A dead world is *reclaimed* and turns green: the first planet the player brought back to life. Milestones tick: 3 of 4 empire goals. One more, and the run knows it is a win. The player does not want to stop.

---

## 2. The four pillars

### Pillar 1: Growth changes the world you see (the needs ladder)

**Design.**
- Every living planet has a **Prosperity tier**. Each tier has a **needs list** (2 to 4 goods). If the planet's storage holds its needs for N cycles in a row (N is a number for economy-designer), it levels up. It consumes a small amount of those goods each cycle (a new, steady sink, so price pressure becomes real).
- The ladder follows the goods already built: tier 1 food and energy (the only goods visible at start today), then the basic raws (powder, blooms), then crafted goods (rounds, medicine, silk, ingot), then luxuries and high crafts (gems, attar, alloy, plate, seed). Planet type and role (data/planet_types.json) change the list, so Voltara hungers differently from Tillam. Branch-exclusive goods (T239) become one personal need each per planet type.
- **Unmet need = price pull.** A need that is not met pushes that planet's buy price up until it is filled. This is the fix for "the best lane stays best forever": the best lane moves as planets grow and fill. It replaces price pressure/drift ideas 7A/7B with something the player understands (cause: a planet is hungry). economy-designer sets curves.
- **Needs are revealed by the Pathfinder survey.** Unsurveyed planets show "needs unknown". Survey is no longer a fee-and-wait; it is the way to learn what to ship. This also gives exploration a use for all 10 planets.
- **Disclosure link (hard rule).** Each need-good enters the player's view by an Availability rule. A tier-up is the unlock event: "Settlement reached" makes the next goods visible (rule atom `planet_tier_at_least:<planet>:<n>` added to game/conditions.gd and its header). No hidden good is named in a need before its rule is true; a locked tier shows "?" slots, never names. The availability test (`_test_availability`) gets a per-tier case.
- Tier gives rewards beyond looks: a steady **tax income** (growth pays, separate from margin, economy-designer sets), skill points at first tier-ups, a higher storage cap, new options (hub slot at tier 3, workshop slot at tier 4).
- Gentle, never punishing: planets do not shrink. Neglect only stalls ("restless"), and shows as a pulsing amber ring.

**Reuses.** Availability rules and conditions.gd; planet types and roles; storage.gd per-planet stock; the `post_built:<planet>` flag becomes tier 1 (trading post = founding the Outpost: one system, not two; closes the "post is a toll" weakness); cash_forecast.gd pattern for a "needs forecast"; planet_banners.gd / planet_hint.gd for the card.

**On screen.**
- A **progress ring** around each planet in the map, filling as needs are met; the missing good icon hangs on it ("1 good short").
- Planet card: tier name, needs rows (met/short), next tier preview shown as locked silhouettes.
- Planet visuals per tier: size step, night-side light density, ring of orbital traffic (idle ships, shuttles), a halo at tier 4-5. Uses existing galaxy/ planet models plus fx-programmer shaders. T223 (resource icons below each planet) becomes the need icons.

### Pillar 2: The scale of play shifts (trade -> route -> hub -> system)

Each layer is built from a part that exists, and each **automates the layer below** instead of adding UI.

| Scale | What the player does | Automates | Built from |
|---|---|---|---|
| 1 Trade | Fill a planet's first need by hand (Buy, Send) | nothing | buy/sell toggles, Send |
| 2 Route | A standing lane that earns | the single trade | routes, ships, level 2 |
| 3 **Hub** | Turn a tier-3 planet into a hub and give it a **basket** (its own needs plus what its neighbours need). The hub pulls from open planets in its **catchment** by itself, using free ships, and feeds neighbours | the routes inside the catchment (shown as a glowing web, still editable) | Space Storage plumbing, route engine, workshops live at hubs |
| 4 **System** | A thriving system (hub plus all planets at least tier 3) gets a **stance** (Growth, Export, Industry) and one panel. It runs itself; the player only sets stance and links | the hubs | Storage Link becomes the **trunk line** between systems; permit becomes the System Charter |
| 5 Galaxy | Choose which system to light next; manage trunks and reclaim dead worlds | systems | galaxy view, permits, Pathfinder |

- The old manual panels never disappear; a hub's lanes can be opened and edited. Automation is a promotion, not a lock-out. Decision T190 should be answered "yes": storage can be a route source, because hubs need it.
- Ships stop being a CEO fixed multiplier and become a **choice per hub** (Dart for short hops, Bulkhead for bulk): ship types finally mean something (review 20A). One S-M item.
- Overhead from spreading wide (today's squared market overhead) is replaced by **hub load**: a hub can serve a limited number of neighbours until it is upgraded. Economy-designer sets.

**On screen.** A hub ring and glowing feeder lines on the map; one "Hub" panel (basket, catchment, health); a system overview card in the galaxy view with a stance dial. Zoom out = see system health at a glance; zoom in = still the trade you started with.

### Pillar 3: Growth is the goal, not beating someone

**New win condition: the Charter of Plenty (working name).** The player holds the empire to four **milestone tracks**; all four reach their line and the empire "ascends":
1. **Worlds**: a count of planets at or above a Prosperity tier (the tier and count are economy-designer's; count is across systems).
2. **Reach**: systems lit and linked by a running trunk line.
3. **Industry**: finished chains (workshop chains and the old per-market 7-step event chains both count).
4. **Renewal**: dead worlds reclaimed (see Pillar 3b and section on raw sources).

Each track is visible at all times (see pillar 4). There is no race to lose and no outplaying an opponent: the only opponent is your own appetite.

**What happens to what is built.**
- **Market share, share graph, share panel, "share milestones for skill points"**: dropped as a win and as a currency. The graph is replaced by the Empire panel (milestone tracks plus a prosperity timeline for each system). Skill points from share milestones are replaced by points from tier-ups, hubs, first trunk, chain finishes (still never credits).
- **Win rule "over 50% for five cycles"**: dropped. Replaced by the four tracks.
- **Rival bots (bots.gd)**: the volume curves stop mattering. They stay as three named **trade houses** that generate **market weather** (below). `bot_*` strength/growth keys are retired or reused as weather intensity (economy-designer).
- **Rival ships (rival_ships.gd)**: finally matter as telegraphs. A house ship arriving at a planet *is* the weather warning: arrival -> a price pulse or a one-cycle contract at that planet (clickable, reuses the event icon/notice). Fixes "decoration only"; makes T189/T221 obsolete in current form.
- **Four-market split**: keep four *sectors* as the language of goods, workshops, skill trees, chains and endings, but they are no longer arenas with an opponent. A world needs goods of several sectors to grow, so breadth is required for the ladder; focus survives in **specialisation**: a sector's skill tree and workshop make that sector's chains cheaper and faster, and the ending is named after the sector you lean on most (see section 4). This reverses the "spreading penalty" pillar and must be an owner decision (question 2).
- **Loss "swept"**: dropped (no share). **Bankrupt**: kept. **Outcompeted** becomes the soft "Quiet Estate".

**Market weather.** Three houses with personalities (story-designer names the temperament, economy-designer the effect size):
- one **floods** a good in a system (prices dip for a few cycles),
- one **hoards** (prices spike, a shortage need appears at a planet),
- one **offers contracts** (a one-shot: "deliver X to Y within N cycles for a bonus and a tier boost").
Weather is forecast by a ship arrival and by skills (FND_RIVAL_WATCH becomes the Forecast node). The player reacts or rides it. Never a loss, always a chance. Events (EV list) keep the same pipeline; many price events are re-voiced as weather.

### Pillar 4: There is always a next thing

A top-bar **Next Up** strip with three live slots (never empty, each one click to focus the map):
1. **Closest buy**: the cheapest thing in the player's list that is not yet affordable, with a bar showing the credits gap and an ETA from the forecast (cash_forecast.gd already projects cash).
2. **Closest growth**: the planet nearest its tier-up, name, ring, and the one missing good.
3. **Missing link**: a chain or hub short one piece ("Munitions Line stalls: no powder"; "Hub-ready: Tillam").

Plus a pinned **Empire panel** with the four milestone tracks, each showing "next step" text. The tutorial card is retired after the first cycles because Next Up is the tutorial. Mid-run dead zones (cycles 15-30 in the review) are filled because there is always a planet one good short.

---

## 2b. Raw sources (T253 made to fit)

Merge mining and dead worlds into **Raw Sources** (one mechanic, one panel). A source is a finite or perilous place that gives a raw good the ladder demands from tier 3-4 up (ore, dross, nullglass): late needs literally push the player to the frontier.
- One **richness** meter (runs out; asteroid fields) and, for dead worlds, one **danger** meter (rises with intensity). The player picks an **intensity** per source (slow and safe, or fast and dangerous): this is mining's missing choice (review 11B) and dead worlds' missing control (8A) in one lever. Show remaining stock, time left, and next event odds on the route.
- Dangerous sources attract raiders (T250 pirates re-scoped as a hazard of raw sources): raiders steal cargo and cut a lane for some cycles. The Null Core and later **reclamation** protect against them, so the Null Core finally protects against something real.
- **Reclaim a dead world (capstone, Renewal track):** feed it a chain of goods over several cycles; it turns green and becomes an Outpost at tier 1. It stops being a source, so the empire trades a risky supply for a new living world. A strong beat, a good decision (reclaim now or keep mining), and the visible "the empire makes life" moment.
- Prospecting, Cold Survey, Deep Cut skills stay as unlocks. The unused `ore_refill_units` and `ore_survey_fee` keys are cleaned in T255.
- gameplay-programmer builds from the T253 spec; this document is the spec direction. economy-designer sets all numbers.

---

## 2c. Skills, events, chains, endings, first hour, juice

**Skills.** Still fit: points stay finite and never bought with credits (pillar kept). Changes:
- Points now come from growth: first tier-ups, first hub, first trunk, chain finish, reclaim.
- Market trees become **sector guilds**: they speed that sector's chains and lower its upkeep; they stop being about share.
- Nodes that only affect share (weight, window) or cut rivals (Embargo Desk, Guild Seal) are **re-voiced**: weather nodes (Forecast, Shelter, Hedge a flood). A full node-by-node audit is needed from economy-designer and gameplay-programmer (owner starts it, per the QA/economy gate). Hold T208 until then. T244, T247, T249 (screen and order) are unaffected.

**Events and chains.** Chains keep seven steps and two neutral choices; triggers move from share levels to **tier events** ("first Town needs rounds"). The hit "on a rival" becomes an effect on a planet's mood or on weather. The hidden lean becomes **visible through the worlds**: each planet carries a mood toward you (a face, not a number); dark sales sour moods, which slows that planet's growth. This is the readable lean the review asked for and a design-fit, since growth is what the player cares about (question 5). Finish the TH01-TH10 thread (T243) on tier triggers.

**Endings.** Section 4.

**First hour.** The ladder is the tutorial. Cycle 1: one need on one planet. Every unlock comes with a one-line hint card at the moment of first use (story-designer, S). The first hour has about eight level-ups, a first hub, a first workshop, and the second system visible as a goal.

**Juice of growth moments (juice-programmer, fx-programmer; T251 folds in).**
- *Tier-up*: a 0.4 s time-slow, a pulse ring, the camera eases onto the planet, the night side blooms into a city grid, orbital traffic spawns, rising chime per tier, skill-point pop, a notice-board line.
- *Hub on*: feeder lines draw themselves outward from the hub in a ripple.
- *System lit*: the whole system flashes, an arc draws across the galaxy view, the system label changes color.
- *Reclaim*: a green wave travels across the dead world's surface.
- *Ambient*: traffic density follows empire size, so the screen gets busier as you grow (ships trails T246 and T221 reused).
- *Ending*: a time-lapse of the empire growing (a snapshot at each tier-up), played behind the ending text.

---

## 3. Keep / change / drop (20 mechanics from the review)

| # | Mechanic | Verdict | One-line reason |
|---|---|---|---|
| 1 | Market share and win | **Drop** (win) / replace | Replaced by the four milestone tracks; the Empire panel takes its place |
| 2 | Routes and ships | **Keep + promote** | Routes are layer 2; hubs automate them; route-why breakdown is still useful |
| 3 | Skills | **Change** | Same finite points, new sources (growth), rival nodes re-voiced as weather |
| 4 | Events and chains | **Change** | Triggers become tier events; lean becomes visible via planet mood |
| 5 | Pathfinder exploration | **Change** | Survey reveals needs; exploration mode keeps its role for outposts |
| 6 | Workshops and fabric | **Keep + grow** | Tier 3-4 needs require crafted goods; workshops live at hubs |
| 7 | Core trading | **Change** | Unmet needs move prices; best lane moves as planets grow |
| 8 | Dead worlds | **Change** (merge) | Into Raw Sources; reclaimable as the capstone |
| 9 | Rivals and ships | **Change** | Become market weather and telegraph ships; no opponent |
| 10 | Cycle timer | **Keep** + a 2x speed toggle | Next Up fills the waiting gaps; speed lets the player skip them |
| 11 | Mining | **Change** (merge) | Into Raw Sources with an intensity choice |
| 12 | Availability | **Keep, central** | The per-tier unlock backbone and the first-hour teacher |
| 13 | Permits and systems | **Change** | Permit becomes the System Charter; system 2 trades differently from 1; systems 3+ designed per phase 4 |
| 14 | Endings | **Change** | Win by empire; ending named by leading sector and visible mood |
| 15 | Storage / Link | **Keep + promote** | Space Storage is the hub core; Link becomes the trunk line; storage as route source yes |
| 16 | Loss conditions | **Change** | Swept dropped; bankrupt kept; outcompeted becomes the soft Quiet Estate |
| 17 | CEO choice | **Keep, decouple** | Picks the starting sector and a growth trait; no longer fixes ship type |
| 18 | Tutorial | **Change** | Replaced by the ladder, Next Up and first-use hint cards |
| 19 | Trading posts | **Drop as a mechanic** | The post is the tier-1 Outpost; same fee, one system |
| 20 | Ship types | **Change** | Chosen per hub, mixed fleets; finally a decision |

Not built but planned: **Gigs (T218)** are **kept**, re-cast as planet **contracts** from the weather houses and local planets (owner has 3 open questions). **Pirates (T250)** are kept as a Raw Sources hazard.

---

## 4. The win condition and endings

**Win.** All four empire tracks reach their lines (Worlds, Reach, Industry, Renewal). The early win can fire as soon as they are all met after a minimum cycle; the late path is a "Charter term" end (the last cycle) with a soft ending if not met. After the win the player may **continue** in free play (no more endings, the Empire panel keeps counting). Recommended in question 3.

**Endings.** Same 8 win endings, new trigger:
- The **leading sector** (most thriving worlds fed by that sector's goods and chains) picks one of MIL / LUX / MIN / BIO.
- GOOD / BAD is chosen from the **planet moods** and chain choices (visible: the ending recap names the three decisive moments).
- A ninth ending for a balanced empire (all four sectors even) is optional (story-designer, S) and rewards breadth, the new fantasy.
- Loss: END_BANKRUPT stays. END_SWEPT dropped. END_OUTCOMPETED renamed to a quiet estate (a soft, kind ending when the term runs out with the tracks unfinished).
- Epilogue lines now speak of worlds you grew, systems you linked, the dead world you revived, and a weather house you befriended or ignored.

---

## 5. Phased plan

Every phase is playable on its own and better than the one before. Sizes: S small, M medium, L large. Numbers always by economy-designer (never invented here).

### Phase 1: Living planets and Next Up (growth is visible, share still ends the game)
Builds:
- Prosperity tiers per planet, needs lists, tier-up, tax income, price pull from unmet needs. gameplay-programmer **L**; numbers and ladder tables economy-designer **M**; tier and need text story-designer **M**.
- Availability atoms for tier (`planet_tier_at_least`), per-tier test. gameplay-programmer **S**.
- Planet visuals per tier (size, light density, traffic) and the progress ring. fx-programmer **M**, ui-programmer **S**.
- Planet card with needs rows; the Next Up strip (three slots). ui-programmer **M**.
- Survey reveals needs; post becomes tier 1. gameplay-programmer **S-M**.
- Tier-up juice v1 (pulse, light bloom, chime). juice-programmer **M**.
Owner plays: a world that grows, a bar that always says what is next, prices that move with need. The old share win is still there, but now the owner feels growth first.
Replaces/obsoletes: T178 (post cost numbers; now tier 1), T223 (becomes need icons), T220 (feedback reused). Tutorial card work retires.

### Phase 2: Growth is the goal (win, rivals as weather, skills, endings)
Builds:
- Four milestone tracks and the Empire panel; remove the share panel, graph and share-driven skill points. gameplay-programmer **M**, ui-programmer **M**.
- Rivals to market weather: flood, hoard, contract; rival ships as telegraphs; weather news. gameplay-programmer **M**, story-designer **M** (house voices), economy-designer numbers **M**, juice-programmer **S**.
- Skills audit and retag; points from growth. economy-designer **M** (owner starts), gameplay-programmer **M**, story-designer **S**.
- Win/loss/ending rewrite, quiet-estate ending, planet moods as lean; end recap. gameplay-programmer **M**, story-designer **M**, ui-programmer **S**.
- Chain triggers move to tier events. gameplay-programmer **S**.
Owner plays: a full run that is won by growing, with weather that is a chance not a threat. The game now answers the owner's "not about competition".
Replaces/obsoletes: T189 (rival ships playtest), T221 (rival ship rough edges, rework), T208 (hold until retag), T209 (becomes the audit), T243 (retarget triggers).

### Phase 3: Hubs and Raw Sources (the bigger toy)
Builds:
- Hub: basket, catchment, auto-feed using free ships, storage as route source (decide T190 as yes). gameplay-programmer **L**, ui-programmer **M**, numbers economy-designer **M**.
- Choose ship type per hub; mixed fleet; CEO decoupled from ship type. gameplay-programmer **M**.
- Raw Sources merge (T253 spec, T254 build): intensity, one meter, hazard; pirates (T250) as hazard. gameplay-programmer **L**, ui-programmer **S**, story-designer **S**.
- Hub juice (ripple feeders) and ambient traffic. juice-programmer **M**, fx-programmer **S**.
Owner plays: the first moment a hub takes over his lanes and he moves on; raw sources that push to the frontier.
Replaces: T253 becomes the spec in this document; T254 and T250 are kept inside this phase; T255 stays (S).

### Phase 4: Systems as one unit and Renewal
Builds:
- System stance and panel; trunk line (Storage Link) between systems; permit as System Charter. gameplay-programmer **L**, ui-programmer **M**.
- Reclaim a dead world capstone. gameplay-programmer **M**, fx-programmer **M**, story-designer **S**.
- Design system 3 (and decide which placeholders stay): role mix that differs from system 1-2, so trunks carry real surplus. economy-designer **L**, story-designer **M** (content volume).
- Galaxy view glow by prosperity; system-lit juice. juice-programmer **M**, fx-programmer **M**. T05 and T193 ride along.
Owner plays: a galaxy that lights up, a revived dead world, a run that feels like an empire.
Replaces: the old permit-and-system placeholders (3-10) work; T166/T190 closed.

### Phase 5: Spectacle and endgame polish (optional)
Builds: the ending timelapse, 2x speed, continue-after-win free play, balanced-empire ending, gigs as contracts (T218), a full tier-up pass of juice (T251). juice-programmer **M**, gameplay-programmer **S**, story-designer **S**.
Owner plays: the finished fantasy.

Not scheduled: any QA or bot run (owner only, per the project gate). T182 stays with the owner.

---

## 6. Risks and questions

### Risks
- **Content volume**: needs ladders for 10 planets and new systems cost economy and story effort; phase 4 is the heavy one.
- **Pillar reversal**: breadth now helps; "focus wins" is gone. Sector guilds must keep specialisation meaningful or play flattens.
- **Automation vs agency**: hubs may feel like the game plays itself. Mitigation: automation is a promotion, edits stay possible, and each automation opens a bigger decision.
- **Balance**: the unmet-need price pull could create runaway loops or dead markets; economy-designer needs a guarded ladder and a clamp.
- **Disclosure leaks**: needs list names goods; the availability test must cover tier text (hard rule).
- **Scope**: this is a rebuild of the win layer; Phase 2 is the high-risk cut. Phase 1 can ship alone if the owner stops there.
- **Skills**: the 68 nodes need a real audit; many lean on share.

### Questions for the owner (recommended answers)
1. Drop the share win, graph and rival share entirely? **Yes**, the owner asked for it; keep rivals as weather only.
2. Reverse the "spreading penalty" pillar (breadth is needed to grow planets) and keep focus through sector guilds? **Yes.**
3. Time pressure: keep a 40-cycle term? **Keep a Charter term, but make the win milestone-based, with a kind soft ending and a continue-in-free-play option after the win.**
4. Can a planet ever lose a tier? **No.** Neglect stalls growth and shows amber; no collapse (it matches the current gentle design).
5. Relax "the lean is never shown" and show it as planet moods? **Yes**, a face on the planet, never a number.
6. Should the three houses stay named (Harrow, Velvet, Ostrel) with temperaments? **Yes**, and let the player earn standing with a house through contracts (small, optional).
7. Do hubs sit on top of manual routes (editable) or replace them? **On top.** Routes stay editable; the hub owns the lanes it creates.
8. Can dead worlds be reclaimed into living planets? **Yes**, as the capstone of the Renewal track; it is the strongest growth image in the plan.
