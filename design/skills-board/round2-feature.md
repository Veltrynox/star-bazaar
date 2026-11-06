# Skills board, round 2: feature-designer

Date: 2026-11-05. Read all four round1 files. Cost classes: S 1 point, M 2, L 3, T tech. Numbers are economy's; I give none. "Back" names the round-1 variant I sign. I moved toward the other three wherever two or more agents agreed and the skill still changes a decision; I held my line only where the other variants were dead by economy's or QA's own finding. Sale-price techs are cash only and target the market id (E2).

## Foundations (order: LEDGER, PATHFINDER, DOCKS)

FND_1: back all four (feature, economy, story, QA). AGREE. **Route Ledger**, no prereq, S. Each route row shows income after trip cost and upkeep per cycle, with a warning when negative. Must not gate anything.

FND_2: back story (Pathfinder Tuning) and my Survey Drive. CHANGE: merge them. **Pathfinder Tuning**, prereq FND_PROSPECT, S. The Pathfinder flies faster and a trading post or platform costs less. Reject FND_RIVAL_WATCH here (economy calls it dead; it moves to LUX_8). Reject QA's Bulk Orders: "all" wildcard (E1), a first-hour loan.

FND_3: back economy (FND_DOCKS) and my Lane Refit. CHANGE: **Lane Yards**, prereq FND_PERMIT, M. Route upgrade costs about a third less (economy's x0.7). Drop my route level 3. Story has no fiction for it and must write one (refit yard). Dead for a one-lane player on purpose. QA's Spare Bays: REJECT, dead without stock play.

## Military

MIL_8: back economy, story, QA (price) over my Leased Hulls. AGREE. **Quartermaster**, MIL_1, M. A new ship costs less (economy's 0.85 ceiling). Re-check always-expand loses.

MIL_9: back economy and QA. AGREE. **Cell Press**, MIL_2, T. Military unconditional volume up a little (+0.05 placeholder). Counts against the per-market volume cap.

MIL_10: back my Convoy Escort over Hardened Stores (economy and I call it dead: asteroid cuts are rare) and Scrap Rights (thin). CHANGE to **Convoy Escort**, MIL_3, M. Each extra ship on a shared lane pays less trip cost, capped. It is the stack-on-one-lane choice against MIL_3 spreading. Fallback if economy cannot cap it: Scrap Rights. UNKNOWN whether the trip cut interacts with the upkeep floor (E10); QA to say.

MIL_11: back economy and story (Proof Range), drop my Yard Kits (loop plus visibility rules) and QA's Armoured Lanes (E4). CHANGE: **Proof Range**, MIL_4, T. Military sells for more cash, market wide, share unchanged, counted under the +0.30 sale-price cap. Armour-only needs a new good filter; skip it.

MIL_12: back my Dragnet and QA's Second Embargo (same family); REJECT Open Arsenal (economy and I see a climber trap: a longer window averages in weak cycles; only valid if code proves it helps a leader). CHANGE to **Dragnet**, MIL_5, M. A mode of the Embargo Desk, not an extra hit: hit two rivals at a weaker amount each instead of one at full, sharing MIL_5's timing. No stack with MIL_5 (E5, E6).

MIL_13: REJECT-leave-empty. Pressure Doctrine and Second Embargo only stack hits on the same lever (E5), and economy's own stack flag shows 20 of 21 points. Revisit only if QA's code check shows Open Arsenal helps a leader.

MIL_14: back economy and story (batch yield +1), drop my Salvage Yard. AGREE. **War Economy**, MIL_6, T, batch yield +1. Free but crafting-time gated (goal 14). Counts in the workshop output stack.

MIL_15: back my Full Mobilisation; REJECT Last Line, Long Shadow (third copy of the rival-cut capstone, QA's Armada Rates is dead at the floor). CHANGE: **Full Mobilisation**, MIL_7 and MIL_14, L. Once per run, for a set number of cycles: no upkeep and ignores route events. It is a timing choice, not a rival cut. Economy to size so it is not the win by itself. If it is too heavy to build, leave the slot empty rather than copy MIL_7.

## Luxury

LUX_8: back my Rival Whisper; REJECT Salon Circle (share window is a climber trap, order size is a plain throughput number). CHANGE: **Rival Watch** (story's name, my effect), LUX_1, M. Competitors screen shows each rival's expected share and tier-up a few cycles ahead. Competes with LUX_3. Needs a UI line and a story line, no balance number.

LUX_9: back all four. AGREE. **Second Loom**, LUX_2, T. The atelier makes one more batch a cycle if you haul the inputs.

LUX_10: back economy, story, QA over my Forward Contract. AGREE. **Trend Desk**, LUX_3, M. Price-down events cut Luxury prices less (about 0.35). Market event_cut total at or under 0.9 (E4).

LUX_11: back economy, story, QA over my Showcase. AGREE with CHANGE. **Collector's Eye**, LUX_4, T. Luxury sells for more cash, market target, share unchanged (E2). Harmless; first to cut if the set is big.

LUX_12: back economy, story, QA (route capacity) over Boutique Hold. CHANGE name to **Courier Pool** (story's alternative, fixes the weak fiction), LUX_5B, M. Luxury lanes carry a bit more.

LUX_13: back economy, story, mine. AGREE with cost M. **Patron's Purse**, LUX_5, M. Mixed load pays more when Luxury is in the mix; existing per-planet cap stays. Reject QA's event_bonus variant (duplicate of MIN_12).

LUX_14: back economy, story, QA over my Auction Floor. AGREE. **Auction House**, LUX_6, T. Luxury volume up a little (+0.06). Luxury unconditional volume total stays at or under 0.14.

LUX_15: back all three others. AGREE. **Grand Salon**, LUX_7 and LUX_14, L. Luxury rivals grow slower for the run (about x0.75). Needs E3 fixed first. I drop Hand on the Scales (strongest skill in my set, riskiest).

## Minerals

MIN_8: back my Strip Mining; Deep Hold is dead if ore never fills storage (economy), Deep Drill is a trap (finite clusters). CHANGE: **Strip Mining**, MIN_1, M. A cluster yields more per cycle at the same total richness, so it empties sooner. Tempo against total; economy confirms the total is unchanged. Fallback: Deep Hold.

MIN_9: back all four. AGREE. **Slag Reclaim**, MIN_2, T. The smelter needs fewer inputs per batch.

MIN_10: back economy, story, QA-ish (Safe Passage and Steady Hands) over my Gleaning. CHANGE: **Safe Passage**, MIN_3, M. Dead-world lanes lose less cargo (chance halved in economy's draft). Gleaning dropped. Name story's Steady Hands only if story prefers; either is fine.

MIN_11: back economy, story, QA. AGREE. **Hot Foundry**, MIN_4, T. Minerals sell for more cash, market target, share unchanged.

MIN_12: back economy, story, QA over my Salvage Hands. AGREE. **Ore Brokers**, MIN_5B, M. Price-up events pay more for Minerals. This gives the safe branch its upside.

MIN_13: back economy (Null Core Tuning at M with max fitted raised) and my Twin Cores. AGREE economy's version, M. **Null Core Tuning**, MIN_5, M. More Null Cores allowed and a lower trip multiplier. The seed version (multiplier alone) is a 3 point trap. Availability rule for Null Core. Reject QA's Long Haul (copy of BIO_8 and LUX_12 shape).

MIN_14: back economy, story, QA over my Dead-World Run (overlaps MIN_10). AGREE. **Mass Smelting**, MIN_6, T. Minerals volume up a little (+0.06).

MIN_15: back economy (richness) and story/QA Motherlode, over my Catch and Claim. CHANGE: **Motherlode**, MIN_7 and MIN_14, L. Clusters hold more total (richness +0.5) and the survey fee halves. It pairs with Strip Mining: rate plus total. Economy may drop to M. Reject a second yield step (traps, floods ore).

## Biotech

BIO_8: back economy, story, QA over my Cold Holds. AGREE. **Gel Cooperatives**, BIO_1, M. Biotech lanes carry more (about 0.1 to 0.125). Competes with BIO_3.

BIO_9: back all four. AGREE. **Spore Bank**, BIO_2, T. Culture Lab makes one more batch a cycle. Drop my slow-mode idea.

BIO_10: back story and my Cold Holds. CHANGE: **Deep Shelf**, BIO_3, M. Biotech in Space Storage also grows. Gives Space Storage a Biotech role. Blocked by the E11 check (do grown units count for share, at what price). Reject Cold Chain (debris immunity is dead; economy's event cut copies BIO_6).

BIO_11: back economy, story, QA; I concede my empty slot. AGREE. **Graft Lines**, BIO_4, T. Biotech batch yield +1. Watch the output stack with Spore Bank.

BIO_12: back economy (rate and cap) over QA (rate alone is dead). CHANGE: **Patient Orchard**, BIO_5, L. Stock grows faster and the cap rises. Add my one-cycle growth pause after a sale from that storage if QA finds sell and restock farming. Blocked by E11.

BIO_13: back economy, story, QA (Market Days) with economy's own condition. CHANGE: **Market Days**, BIO_5, M. Biotech volume up at price-up planets, stock-fed sales only. If the code cannot tell stock-fed sales, REJECT-leave-empty (copy of LUX_5).

BIO_14: back economy, story, QA over my Standing Contract. AGREE. **Living Contracts**, BIO_6, T. Biotech sells for more cash, market target, share unchanged.

BIO_15: back economy, story (Evergreen), QA. CHANGE: **Evergreen**, BIO_7 and BIO_14, L. Biotech rivals grow slower. Only two growth-cut capstones may exist (LUX_15 and this one); MIL_15 is the surge instead. Cap BIO_7 plus Evergreen at about 0.4 effective (economy). My Living Link waits until the Storage Link has been played.

## (a) QA code findings each backed skill must respect

- E1/E2: only reveal, warning, order-size nodes use "all"; every sale-price node targets a market id. Applies to FND_2, MIL_11, LUX_11, MIN_11, BIO_14 and all volume techs.
- E3: fix `bot_strength_mult` and `bot_growth_mult` (pick, permanent) before LUX_15, BIO_15.
- E4: market event_cut at or under 0.9 (MIL_6 0.5, BIO_6 0.4, MIN_5B 0.3 exist). Hits LUX_10.
- E5/E6: Dragnet shares MIL_5 timing; no second chosen-bot hit; rival strength_mult at least 0.2.
- E7/E8: no max-based or boolean duplicate (that is why Open Arsenal, Salon Circle, Hardened Stores are out).
- E9: no new reopen_sooner node in this set.
- E10: Convoy Escort and Full Mobilisation must be checked against the 0.5 upkeep floor.
- E11: blocks BIO_10 and BIO_12 until answered.
- E12: Foundations cost points that compete with permits; keep S/M.
- E13/E14: share thresholds and the unreachable full-tree band are the owner's call; no skill here changes them.
- E15: free volume techs per market are limited to +0.20 sum (economy cap).

## (b) Stack and auto-win risks

Accept: workshop output stack (MIL_2+MIL_14, MIN_4+MIN_6, LUX_9, BIO_9+BIO_11), since techs are time-gated by goals 8 to 14 units. Accept the price cap +0.30 per market. Want capped: Military pressure (MIL_5, MIL_7, Dragnet, Mobilisation, no win before cycle 23); Biotech rival cuts; Strip Mining plus Motherlode plus MIN_3 (ore flood must hit storage and sale limits); Convoy Escort with MIL_3.

## (c) Cut first if the set is too big

In order: MIL_15, BIO_15 (needs unplayed Storage Link? no, Evergreen only needs E3), BIO_13, BIO_12 (blocked by E11), BIO_10 (same), LUX_11, MIN_11, MIL_11, FND_3. This leaves about 26 filled slots, and the eight gaps stay honest. New code hooks I add over the others: Convoy Escort, Dragnet, Full Mobilisation, Strip Mining, Rival Watch; if build cost is a problem, those five are the first to fall back to economy's or QA's simpler variants.
