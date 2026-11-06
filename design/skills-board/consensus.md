# Skills board: consensus after round 2 (written by the main session from the four round2 files)

Strict reading of the owner's rule ("only skills all four agree on"): after round 2, 12 skills have four AGREE. 23 slots still have two or more different variants, so round 3 is a ballot (see bottom). Nothing is built yet.

## Tier A: all four agree (build these)
- FND_1 Route Ledger (S, no prereq): each route row shows net income per cycle after costs, marks a loss. Unlock only, gates nothing.
- MIL_8 Quartermaster / Surplus Hulls (M, MIL_1): new ship price x0.85, purchase only; cash reserve still binds. Owner ablation: always-expand must still lose.
- MIL_9 Cell Press (T goal 8, MIL_2): Military volume +0.05.
- MIL_14 War Economy (T goal 14, MIL_6): Military batch yield +1.
- LUX_8 Rival Whisper (LUX_1; cost M, economy asked S): Competitors screen shows each rival's next tier-up cycle and projected share 3 cycles ahead, same model as the bots; read-only.
- LUX_10 Trend Desk (M, LUX_3): events that cut Luxury prices hit 0.30-0.35 softer (economy sets within that band); event cut per market at most 0.9.
- MIN_9 Slag Reclaim (T goal 10, MIN_2): smelter uses 1 less ore per batch (min 1).
- MIN_10 Safe Passage (M, MIN_3): dead-world ore loss chance 0.5 -> 0.25.
- MIN_12 Ore Brokers (M, MIN_5B): Minerals price-up events pay +0.25.
- MIN_14 Mass Smelting (T goal 14, MIN_6): Minerals volume +0.06 (QA condition: at most one new free volume tech per market; owner confirms).
- BIO_8 Gel Cooperatives (M, BIO_1): Biotech route units x1.125.
- BIO_11 Graft Lines (T goal 14, BIO_4): Biotech batch yield +1.

Caps that bind all (economy + QA): free volume per market at most +0.20; sale-price bonus at most +0.30; event cut per market at most 0.9; QA findings E1..E15 in round2-qa.md. E3 (bot_strength_mult/bot_growth_mult ignore permanent/pick flags) must be fixed in code before any rival-cut node.

## Settled facts from round 2 (change earlier readings)
- E11: grown stock counts toward share and sells at the normal price; growth is capped cumulatively at cap x stored, so sell-and-restock does not farm. BIO_10/BIO_12 are no longer blocked.
- The bundle bonus is single-market only: "mixed load" wording for LUX_13 is impossible.
- LUX_5B is a reveal and warning, not a route node.
- Owner rule: null_core_max is 1 per run (balance v31). MIN_13 as drafted by economy raises it.
- Dragnet needs the removed shared embargo cooldown (QA); economy says E5 multiplies hits.

## Round 3 ballot (open slots)
Each agent writes round3-<agent>.md: for EVERY slot below pick FIRST choice (one option letter) and list ACCEPTABLE options (letters you can live with, may be none). Rule: an option that every agent marked first or acceptable wins; if several, the one with most FIRST votes; if none, the slot stays empty and goes to the owner. Option "empty" is always valid. Take the settled facts above into account; do not re-argue, vote.

1. FND_2 Pathfinder: (a) flight time x0.7 only, S [economy, QA, story]; (b) flight time plus cheaper trading posts/platforms [feature]; (c) empty.
2. FND_3: (a) Lane Yards, M, route upgrade cost x0.75, prereq FND_PERMIT [economy, feature]; (b) empty [story]; QA said "CHANGE Lane Refit" without a version: say which.
3. MIL_10: (a) Convoy Escort [feature]; (b) Scrap Rights [economy, story]; (c) empty [QA].
4. MIL_11: (a) Proof Range, T goal 12, cash price tech [feature, story]; (b) Yard Kits, T goal 12, armour pays part of a ship price [economy, QA]; (c) empty.
5. MIL_12: (a) Dragnet [feature, story]; (b) Convoy Escort [economy]; (c) Open Arsenal share window 12 [QA]; (d) empty.
6. MIL_13: (a) empty [feature, story, QA]; (b) Pressure Doctrine, embargo hit 0.5 -> 0.6, L [economy].
7. MIL_15 Full Mobilisation (L, prereq MIL_7), once per run, at most 5 cycles: (a) Military lanes pay no upkeep and ignore route events [QA, feature, economy]; (b) no upkeep only [story]; (c) empty.
8. LUX_9: (a) Second Loom, T goal 10, atelier +1 batch [economy, story, feature]; (b) Pattern Books, alternative inputs [QA]; (c) empty.
9. LUX_11: (a) Collector's Eye, T goal 12, cash price [feature, story]; (b) Showcase, planet counts as price-up for 3 cycles then cooldown 8 [economy]; (c) empty [QA].
10. LUX_12: (a) Courier Pool, M, Luxury route capacity +0.10 [feature, economy, story]; (b) Boutique Hold [QA]; (c) empty.
11. LUX_13 Patron's Purse (LUX_5), Luxury-only bundle at one planet pays more, cap binds: (a) cost M; (b) cost L; (c) empty.
12. LUX_14: (a) Auction House, T goal 14, Luxury volume +0.06 [economy, story, feature]; (b) Auction Floor, sell order may wait N cycles [QA]; (c) empty.
13. LUX_15: (a) Grand Salon, all rivals' Luxury growth x0.85 permanent, L, needs E3 [economy, story, feature]; (b) Hand on the Scales, redirect an announced event every N>=6 cycles [QA]; (c) empty. At most one rival-cut capstone overall.
14. MIN_8: (a) Strip Mining, M, cluster yield per cycle up, total unchanged [feature, economy, QA]; (b) Deep Hold [story]; (c) empty.
15. MIN_11: (a) Pit-head Smelter, T goal 12, smelter on a mining platform [economy, QA]; (b) Hot Foundry, cash price [feature, story]; (c) empty.
16. MIN_13: (a) Null Core Tuning, M, max cores 1 -> 2, trip mult 0.4 [economy, feature, story]; (b) trip multiplier only (keeps one core), M [story's earlier]; (c) empty [QA: owner rule]. Mark if you want the owner to decide.
17. MIN_15 Motherlode (MIN_7 + MIN_14), cluster richness 120 -> 180: (a) cost L, richness only [QA, feature]; (b) cost M, richness + survey fee x0.5 [economy]; (c) empty.
18. BIO_9: (a) Spore Bank, T goal 10, +1 batch [economy, story, feature]; (b) slow mode [QA]; (c) empty.
19. BIO_10: (a) Deep Shelf, M, Space Storage growth half rate, cap 0.1 [feature, economy, QA]; (b) Cold Chain, debris immunity + bio event cut 0.2 [story]; (c) empty.
20. BIO_12 Patient Orchard (BIO_5): (a) M, rate 0.02 -> 0.03, no growth the cycle after a sale, cap unchanged [QA]; (b) L, rate and cap 0.30 -> 0.45, pause after sale [economy, story]; (c) empty.
21. BIO_13 Market Days: (a) M, stock-fed sales only, only if code can filter; (b) empty [QA].
22. BIO_14: (a) Living Contracts, T goal 14, Biotech cash price +0.06 [economy, story, feature]; (b) Standing Contract [QA]; (c) empty.
23. BIO_15: (a) Evergreen, rivals' Biotech growth x0.85, needs E3 [feature, story]; (b) empty [economy, QA]. Only two growth-cut capstones may exist.

---
# FINAL after round 3 (rule applied: an option wins if all four marked it first or acceptable; most FIRST votes breaks a tie; a tie stays open)

## Build list: 29 skills (12 tier A above, plus 17 from the ballot)
Numbers and details: the "FIRST" line of round3-economy.md for each slot; guards from round3-qa.md and round2-qa.md; names and plain lines from round3-story.md / round2-story.md (QA/economy changes win over story on effect).
- FND_2 Pathfinder (S, FND_PROSPECT): flight time x0.7 only.
- FND_3 Lane Yards (M, FND_PERMIT): route upgrade cost x0.75. Guard: no "all", upgrade step only.
- MIL_11 Yard Kits (T goal 12, MIL_4): armour pays part of a new ship price (economy: 10 percent, QA: at most 0.3 of price per ship); purchase only.
- MIL_12 Open Arsenal (M, MIL_4): Military share window 12 cycles (was 8). Won by "acceptable" votes (QA first; feature, economy, story acceptable). Economy asked for a code proof that it helps a leader, QA says share_window("mil") returns 12 and the window is symmetric for bots: test it.
- MIL_15 Full Mobilisation (L, MIL_7): once per run, 5 cycles, Military lanes pay no upkeep and ignore route events; upkeep floor returns after.
- LUX_9 Second Loom (T goal 10, LUX_2): atelier +1 batch a cycle. Guard: Luxury units at most 2x base.
- LUX_12 Courier Pool (M, LUX_5B): Luxury route capacity +0.10.
- LUX_13 Patron's Purse (LUX_5): Luxury-only single-planet bundle pays more, cap must bind. Skill agreed; COST TIED (M: feature, story; L: economy, QA).
- LUX_14 Auction House (T goal 14, LUX_6): Luxury volume +0.06; Luxury total free volume at most 0.20.
- LUX_15 Grand Salon (L, LUX_7 + LUX_14): all rivals' Luxury growth x0.85 permanent. Needs E3 fixed first; the only rival-cut capstone (BIO_15 stays empty).
- MIN_8 Strip Mining (M, MIN_1): cluster yield per cycle up (+25 percent), total richness unchanged.
- MIN_11 Pit-head Smelter (T goal 12, MIN_4): a smelter may be built at a mining platform.
- MIN_15 Motherlode (L, MIN_7 + MIN_14): cluster richness 120 -> 180, richness only.
- BIO_9 Spore Bank (T goal 10, BIO_2): culture lab +1 batch a cycle. Guard: Biotech output at most 2x base.
- BIO_10 Deep Shelf (M, BIO_3): Biotech in Space Storage grows at half the BIO_2 rate, cap 0.1 of stored.
- BIO_12 Patient Orchard (M, BIO_5): growth rate 0.02 -> 0.03, no growth the cycle after a sale, cap unchanged.
- BIO_14 Living Contracts (T goal 14, BIO_6): Biotech cash price +0.06, market target.

## Left empty (owner may reopen)
- MIL_10 (Convoy Escort, Scrap Rights: only empty satisfied everyone), MIL_13 (all four), BIO_13 (all four), BIO_15 (all four), MIN_13 (empty 3 first votes; the trip-multiplier-only version was acceptable to all, so an owner may allow it; two-core version needs an owner decision on the one-core rule).
- LUX_11: TIE (Collector's Eye 2 first, empty 2 first). Open for the owner.

## Owner questions
1. LUX_13 cost: M or L (tie).
2. LUX_11: Collector's Eye (cash price tech, weak but harmless) or empty.
3. MIN_13: keep empty, or allow the trip-multiplier-only version (one core).
4. MIL_12 Open Arsenal: accepted although economy first called it a climber trap; test required.
5. Does the Pathfinder have a flight-time key? (QA: confirm in code; builder checks.)
