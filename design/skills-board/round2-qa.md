# Round 2, qa-analyst: verdicts on every slot

Author: qa-analyst (owner-called). Date: 2026-11-05. Paper review only: no bots, no qa/bots/*, no tools/sim.py. Code read to settle questions: game/skills.gd (_hits, bot_strength_mult, bot_growth_mult, grow_stock), game/markets.gd (add_sale, share, bot_share, end_cycle gap), game/route_engine.gd (_note_sale, cross-load, mixed_bonus), game/storage.gd (capacity_mult), game/main.gd (_end_cycle order), data/skills.json, data/balance.json. Read only round1-economy, round1-feature, round1-qa, round1-story and the README. No other round2 file was read.

Convention: slot FND_1 is the first new Foundation each agent lists (Route Ledger for feature, economy, story; QA lists Bulk Orders first, which I reject below). FND_2 and FND_3 follow the same rule (see each block). Costs: S 1, M 2, L 3, T tech. "Tech goal" follows economy's 8/10/12/14 by slot.

## 0. Settled and corrected facts (these change round 1 readings)

- **E11 settled (grown stock).** grow_stock only ticks keys starting with "planet:" (skills.gd, grow_stock). Grown units sit in planet storage like bought stock. When sold (route_engine _note_sale, then main.gd:1995 Markets.add_sale) they count toward share and sell at the normal price. Growth is capped cumulatively at cap x stored amount, and the counter is erased only when stock is zero at cycle end, which yields no growth. So sell-and-restock does not farm growth (BIO_2 alone is safe). The real exposure is a new stock path or a higher cap (see BIO_10, BIO_12).
- **E3 is latent, not live.** bot_growth_mult (skills.gd:167) checks neither permanent nor pick. Today only MIL_7 uses it (all_bots, permanent), so it is correct now. It bites only when a temporary or chosen growth node is added.
- **E5 and E6 numbers are current.** MIL_5 hit 0.5, every 7, lasts 5 (about 71 percent uptime on one rival). LUX_7 hit 0.4, lasts 8, every 9 (about 89 percent). The shared cooldown key no longer exists, so any node that "shares the cooldown" (feature Dragnet) is invalid.
- **E4 numbers are current.** event_cut today: MIL_6 0.5, BIO_6 0.4, MIN_5B 0.3, no LUX cut. Each market total is far under 0.9 unless a new node lands in MIL, BIO or MIN.
- **Share windows are symmetric.** Markets.bot_share uses window_for(m), the same window as the player. A longer window helps whoever held share in older cycles (a leader that surged early) and hurts a climber. It does not favour the player against bots.
- **Bundle bonus is single-market only.** mixed_bonus returns 0 when the load crosses markets (route_engine.gd:1029). Story's LUX_13 wording "mixed load bonus larger when Luxury is in the mix" cannot be built as written. It must be a Luxury-only bundle.
- **Cross-load is a 1.5x trip surcharge** (cross_load_trip_mult 1.5, route_engine.gd:210). Feature's Boutique Hold removes it for Luxury.
- **LUX_5B is not a route node.** It gives reveal_prices 2 and event_warning 2 (info branch). Luxury has no route capacity node today, so economy's Press Room is not a duplicate. My round-1 note that it was is wrong.
- **Existing free volume tech:** LUX_2 (volume lux 0.08). Other tech effects were not all checked. UNKNOWN whether MIL_4, MIN_2, MIN_4 or BIO_4 add volume; the owner should count before MIN_14 lands.
- **Storage:** storage.gd:34 says capacity_mult covers planet containers only, so FND_DEPOT would not touch Space Storage. Not needed for this round.

## 1. Foundations

**FND_1 Route Ledger.** Backs: feature (also economy, story; QA second).
Verdict: AGREE with CHANGE. The readout must reuse the RouteEngine net figure, not a second calculation, and show a warning when the net is negative. It gates nothing. New feature id needs an Availability rule.
Final: Route Ledger (S, no prereq). Unlock feature route_ledger; each route row shows net per cycle after trip cost and upkeep.
Respects: E9 (no reopen), E12 (one point).

**FND_2 Survey Drive.** Backs: feature (SURVEY). Rejects: economy and story RIVAL_WATCH, story PATHFINDER.
Verdict: CHANGE. Keep S, flight time only. Drop the post and platform build-cost part: post and platform build time is already 0.025 cycles (T200), so the time part is a no-op and the cost part overlaps route-cost nodes. UNKNOWN whether a Pathfinder flight-time key exists; gameplay-programmer confirms.
REJECT RIVAL_WATCH: information only (economy's own dead-risk flag) and a copy of LUX_8 Rival Whisper, which already shows rival projections. REJECT PATHFINDER: the same flight-time idea at M.
Final: Survey Drive (S, no prereq). Pathfinder flight time down by a balance key; no effect on rivals or markets.
Respects: E12.

**FND_3 Lane Refit.** Backs: feature (REFIT). Rejects: economy DOCKS, QA BULK, QA DEPOT.
Verdict: CHANGE. One refit per lane, a steep fee (economy sets), and the level-3 margin gain must be below level 2's. A refit needs a level-2 lane first.
REJECT DOCKS: a route cost cut with no decision, the same shape as MIL_8's cost cut. REJECT BULK: "all" order size (E1), and FND_BULK keys were dropped in v54. REJECT DEPOT: planet storage is a weak lever without stock play.
Final: Lane Refit (M, prereq FND_PERMIT). A level-2 lane may take one refit to level 3 for a fee; margin gain below level 2.
Respects: E1 (no "all"), E10 (level-3 lanes cost upkeep as normal).

## 2. Military

**MIL_8.** Backs: economy Quartermaster, story Surplus Hulls, QA Quartermaster (3 of 4). Rejects: feature Leased Hulls.
Verdict: AGREE with CHANGE. Price is ship_price_pct on purchase only, and the cash reserve still binds. Leasing spams ships, adds upkeep that interacts with the floor (E10), and needs a new cap. Always-expand gets a cheaper ship; owner ablation must confirm it still loses.
Final: Quartermaster (M, prereq MIL_1). New ship price x0.85 (ship_price_pct 0.15). No second ship-price node.
Respects: E10 (not upkeep), E12.

**MIL_9.** Backs: economy and story Cell Press (T). Rejects: feature Convoy Escort (M, MIL_3).
Verdict: AGREE. Convoy Escort is a multi-ship lane discount; it is a good idea only if the owner wants stacked lanes, which I do not know. Ask the owner, not a slot decision.
Final: Cell Press (T, prereq MIL_2, tech goal 8). Military volume x(1 + 0.05).
Respects: E15. It is the only new free volume tech in Military.

**MIL_10.** Backs: none. Verdict: REJECT, leave empty.
Reasons: Hardened Stores (story, QA) is a boolean for asteroid storage cuts that rarely fire (E8, dead). Scrap Rights (economy) needs a new salvage type and is thin. Watch Posts (feature) softens the absence tax: markets.gd end_cycle adds bot gap growth when the player's share is under bot_gap_share_pct. Removing that tax makes focus cheaper and weakens the spreading pillar. Owner decision (feature Q2). Reopen Watch Posts only if the owner says the tax should not bite.
Respects: E8.

**MIL_11.** Backs: feature Yard Kits (T, MIL_4). Rejects: economy and story Proof Range (cash price tech, called thin by two agents).
Verdict: AGREE with CHANGE. Armour pays a fixed fraction of a new ship price, capped per ship (economy sets; QA suggests at most 0.3). The loop is bounded because ship_cap is 6.
Final: Yard Kits (T, prereq MIL_4, tech goal 12). Armour units pay up to a capped fraction of a new ship's price.
Respects: Availability (armour visible), "money never buys points": armour is goods, not money.

**MIL_12.** Backs: economy, story, QA Open Arsenal (3 of 4). Rejects: feature Dragnet.
Verdict: AGREE with CHANGE. The longer window helps a leader who held share before and hurts a climber. It applies to rivals too (bot_share uses the same window), so it is not a rival cut. Test: share_window("mil") returns 12; a second share window node changes nothing. Dragnet is invalid: it needs the removed shared cooldown, and a second chosen-bot node multiplies hits (E5).
Final: Open Arsenal (M, prereq MIL_4). Military share window 12 cycles (was 8).
Respects: E7 (max, one window per market), E5 (no second chosen-bot node).

**MIL_13.** Backs: none. Verdict: REJECT, leave empty.
Economy Pressure Doctrine (hit 0.5 to 0.6), story Pressure Doctrine (recharge sooner) and QA Second Embargo are the same pressure on the same MIL_5 node. A bigger hit or shorter cooldown on one rival is a number, not a role (fails the bar). Stacked, it breaks E5 and E6, and economy calls the Military pressure stack the highest risk. Feature also left it empty for this reason.
Respects: E5, E6.

**MIL_14.** Backs: economy War Economy, story Spare Casings (2 of 4). Rejects: feature Salvage Yard (target "all" is E1; a sale-price-like salvage rate above the sell cap); QA Escort Contracts (a second free volume tech in Military, E15).
Verdict: AGREE. Owner ablation must check the Military output stack (MIL_2 + MIL_14).
Final: War Economy (T, prereq MIL_6, tech goal 14). Military units per batch +1 (batch_yield mil 1).
Respects: E1, E15.

**MIL_15.** Backs: feature Full Mobilisation (L, prereq MIL_7). Rejects: economy Last Line and story Long Shadow (permanent all-rival Military strength cut, the same shape as MIL_7 and MIN_7, and it stacks on MIL_7's growth halving); QA Armada Rates (upkeep floor, E10).
Verdict: CHANGE. Once per run; N cycles (economy sets; QA guard at most 5). Upkeep is zero during the surge and the floor returns after it. Route events are ignored only on lanes carrying Military goods. No effect on share or rivals.
Final: Full Mobilisation (L, prereq MIL_7). Once per run, for N cycles, Military lanes pay no upkeep and ignore route events.
Respects: E10 (explicit exception to the floor, reset after), E1 (lane filter, not "all").

## 3. Luxury

**LUX_8.** Backs: feature Rival Whisper (M, prereq LUX_1). Rejects: story and QA Salon Circle window (a second share window copy of MIL_12's shape, and a climber trap); economy Salon Circle order size (needs a per-market order-size filter, E1).
Verdict: AGREE with CHANGE. The three-cycle projection must use the same model as the bots, and a test must show the projected tier cycle matches the real one. No hidden goods named.
Final: Rival Whisper (M, prereq LUX_1). Competitors screen shows each rival's next tier-up cycle and its projected share three cycles ahead; read-only.
Respects: Availability (feature unlock needs a rule), no new effect.

**LUX_9.** Backs: feature Pattern Books (T, prereq LUX_2). Rejects: economy, story and QA Second Loom (+1 batch). Second Loom is a copy of the batch shape (MIL_2, MIN_4 already exist) and doubles with LUX_6's yield.
Verdict: AGREE with CHANGE. Only inputs already visible may be alternatives (Availability). A craft still yields the batch count, not more.
Final: Pattern Books (T, prereq LUX_2, tech goal 10). Atelier recipes accept either of two visible inputs.
Respects: Availability, E11 (no new goods).

**LUX_10.** Backs: economy, story, QA Trend Desk (3 of 4). Rejects: feature Forward Contract (price lock: unclear interaction with share and cash, one lock per N cycles, and too safe next to LUX_5B's warning).
Verdict: AGREE. Lux has no event cut today, so 0.35 passes the guard.
Final: Trend Desk (M, prereq LUX_3). Events that cut Luxury prices hit 35 percent less (event_cut_pct lux 0.35).
Respects: E4 (lux total 0.35 against the 0.9 guard).

**LUX_11.** Backs: none. Verdict: REJECT, leave empty.
Economy and story Collector's Eye is a pure cash price tech that changes no share (economy and QA both flag it). Feature Showcase (player-placed planet counts as price-up for share, then cooldown) is a free LUX_5 share bonus on a chosen planet: it turns event chasing into a free planned lever and makes LUX_5 optional. Reopen only if the owner wants a placement choice with a cooldown at least twice its duration and no LUX_5 overlap.
Respects: E7, E15.

**LUX_12.** Backs: feature Boutique Hold (M, prereq LUX_5B). Rejects: economy, story and QA Press Room (generic route capacity; Luxury gets a route node only as a pattern, not a decision). This rejection is a judgement call; economy may push back.
Verdict: CHANGE. The cross-load surcharge (1.5x) is removed for Luxury goods only on a load of exactly two markets (Luxury plus one other). Three or more markets still pay. Otherwise Luxury becomes the free rider on every lane.
Final: Boutique Hold (M, prereq LUX_5B). A Luxury good on a two-market load pays no cross-load trip surcharge.
Respects: E1, the single-market bundle rule (unchanged).

**LUX_13.** Backs: feature and economy Patron's Purse (3 of 4 on the mechanic). Rejects: QA event payout (duplicates LUX_5's event bonus, E4-style sum on the same node).
Verdict: CHANGE. Cost L (feature, story): it changes a plan and the diversify choice is real. Wording: "Luxury-only bundle at one planet pays more" (not "mixed load", which the code forbids). Economy sets the value (0.15 and cap 300 suggested); the cap must bind, not the percentage.
Final: Patron's Purse (L, prereq LUX_5). Luxury-only bundles at one planet earn a bigger bundle bonus (bundle_bonus_pct and cap up; economy sets).
Respects: single-market rule (route_engine.gd:1029), E8-style: no change to LUX_5 event bonus.

**LUX_14.** Backs: feature Auction Floor (T, prereq LUX_6). Rejects: economy, story and QA Auction House (free lux volume, a second free volume tech on top of LUX_2, E15).
Verdict: AGREE with CHANGE. Conditional sell only for Luxury Sell orders. Held stock counts against storage room. Hold limit: the order sells anyway after N cycles (economy sets; QA suggests 4), so stock cannot become an infinite share bank.
Final: Auction Floor (T, prereq LUX_6, tech goal 14). A Luxury Sell order may wait for a price-up planet; after N cycles it sells anyway.
Respects: E15, Availability (lux visible), E11 (no new goods).

**LUX_15.** Backs: feature Hand on the Scales (L, prereqs LUX_7 and LUX_14). Rejects: economy, story, QA Grand Salon (permanent all-rival Luxury growth cut: a copy of MIL_7's shape and stacks on LUX_7 and bot 2's growth; E3 is fragile).
Verdict: CHANGE. Cooldown at least 6 cycles (economy sets). Only announced price-up events, same good. The target planet must be one the player can sell at. Chain steps must still be valid after a redirect (chains.gd: QA check). It is a capstone, not a must-take, and it is the first cut if the set is too big.
Final: Hand on the Scales (L, prereqs LUX_7 and LUX_14). Once every N cycles (N at least 6), move one announced price-up event of a good to another planet; no effect on rivals.
Respects: E1 (no "all"), E3 (no bot effect), chain validity (new QA check).

## 4. Minerals

**MIN_8.** Backs: feature Strip Mining (M, prereq MIN_1). Rejects: economy and story Deep Hold (storage room is dead unless ore fills storage, which is UNKNOWN; economy flags it); QA cluster yield (pure more-of, no trade).
Verdict: AGREE with CHANGE. Yield per cycle rises; cluster total stays the same, so clusters empty sooner. This pairs with MIN_15 Motherlode (total) as the tempo-versus-total fork. A cluster route on an empty cluster must show empty and let the player reroute (core rule, not this skill; QA test for softlock).
Final: Strip Mining (M, prereq MIN_1). Cluster yield per cycle up by a balance key; cluster total unchanged.
Respects: E4 (min cluster yield total at most 0.6: MIN_3 0.25 plus this node), E1.

**MIN_9.** Backs: economy and story Slag Reclaim (2 of 4). Rejects: feature byproduct loop (dross returns to craft, a new goods faucet like E11).
Verdict: AGREE. Crafting pays back in ore; no new goods.
Final: Slag Reclaim (T, prereq MIN_2, tech goal 10). The smelter uses one less ore per batch (minimum one).
Respects: E11 (no creation), output stack with MIN_4 (owner ablation).

**MIN_10.** Backs: economy Safe Passage and story Steady Hands (dead-world ore loss; 2 of 4). Rejects: QA Safe Passage as an event cut (duplicates MIN_5B's event cut, E4); feature Gleaning (a thin trickle on empty clusters undercuts MIN_8's tempo cost). Empty-cluster softlock is handled as a core rule.
Verdict: AGREE.
Final: Safe Passage (M, prereq MIN_3). Dead-world ore loss chance halved (dead_ore_loss_chance 0.5 to 0.25).
Respects: E8 and E4 (no event cut added).

**MIN_11.** Backs: feature Pit-head Smelter (T, prereq MIN_4). Rejects: economy, story and QA Hot Foundry (pure cash ingot price, which economy and QA call harmless and thin).
Verdict: AGREE with CHANGE. A smelter may be built at a mining platform. Availability: platform and smelter visible. Ingots still need a sale, so no trip cost is skipped on goods. Goal 12.
Final: Pit-head Smelter (T, prereq MIN_4, tech goal 12). A smelter may be built at a mining platform, so ore is smelted at source.
Respects: Availability (workshop rule), E11.

**MIN_12.** Backs: economy, story and QA Ore Brokers (3 of 4). Rejects: feature Salvage Hands (debris pays ore: a new ore faucet per event; farming risk).
Verdict: AGREE. Minerals price-up events only.
Final: Ore Brokers (M, prereq MIN_5B). Minerals price-up events pay 25 percent more of their percent (event_bonus_pct min 0.25).
Respects: E2 (target is the market id "min"), E4 (no cut).

**MIN_13.** Backs: none. Verdict: REJECT, leave empty.
Economy Null Core Tuning raises null_core_max to 3, which breaks the owner rule of one core per run (balance v31). Feature Twin Cores breaks the same rule. QA Long Haul is a route capacity copy of MIN_5B's route units (fails the bar). Story's trip-cost-only version respects the rule, but economy puts it at about 15 a trip, a 3-point trap for one ship on one line. Reopen only if the owner raises the trip cut to a value economy confirms.
Respects: owner rule one-per-run (null_core_max 1).

**MIN_14.** Backs: economy, story, QA Mass Smelting (3 of 4). Rejects: feature Dead-World Run (overlaps MIN_10's dead-loss key; two nodes on one number).
Verdict: AGREE with CHANGE. Minerals gets its first new free volume tech only if the owner accepts a cap of one new free volume tech per market (E15). Owner decides; QA recommends yes.
Final: Mass Smelting (T, prereq MIN_6, tech goal 14). Minerals volume x(1 + 0.06).
Respects: E15, owner pacing check (no win before cycle 23).

**MIN_15.** Backs: economy Motherlode (richness). Rejects: story and QA Motherlode yield step (a second copy of MIN_8's tempo axis, which I just placed on MIN_8); feature Catch and Claim (depends on an asteroid event, so a run may wait on luck).
Verdict: CHANGE. Richness only: cluster total up 120 to 180. Drop economy's survey-fee part (a new type nobody needs). Richness is a total, so it does not stack with yield.
Final: Motherlode (L, prereqs MIN_7 and MIN_14). Cluster richness 120 to 180 (total ore per cluster up; rate unchanged).
Respects: E4 (no yield stack), owner ablation for Minerals win cycle.

## 5. Biotech

**BIO_8.** Backs: economy, story, QA Gel Cooperatives (3 of 4). Rejects: feature Cold Holds (Space Storage growth; moved to BIO_10 so the same effect is in one slot).
Verdict: AGREE. Biotech has no route node today, so this completes the set (MIN_5B and MIL_3 have one).
Final: Gel Cooperatives (M, prereq BIO_1). Biotech route units x1.125 (route_capacity_pct bio 0.125).
Respects: E7 (no other route node in bio).

**BIO_9.** Backs: feature Spore Bank (slow mode, T, prereq BIO_2). Rejects: economy, story, QA +1 batch (third batch copy after MIL_2 and MIN_4; output stack with BIO_11).
Verdict: AGREE with CHANGE. A slow batch returns more units by a fixed ratio (economy sets), inputs unchanged. A slow batch still pending when the run ends is shown as pending and not silently lost (QA test).
Final: Spore Bank (T, prereq BIO_2, tech goal 10). A Culture Lab batch may be set to slow: it arrives later with more units.
Respects: E11 (units per batch are not stock growth; tests separate them), output stack cap.

**BIO_10.** Backs: story Deep Shelf (Space Storage growth; the same effect feature puts in BIO_8). Rejects: economy Cold Chain (debris immunity is a copy of MIL_3 and MIN_5B; the bio event cut 0.2 gives a second bio event cut on top of BIO_6's 0.4, E4 pattern). Rejects: feature Standing Stock (counts unsold stock toward share: share is sold volume only, so this breaks the definition).
Verdict: CHANGE. Space Storage growth at half the BIO_2 rate and cap 0.1 of the stored amount (cap, not rate, bounds free units). Space stock can be large, so the cap must be low. Available only after Space Storage is earned (Availability space_storage).
Final: Deep Shelf (M, prereq BIO_3). Biotech stored in Space Storage grows at half the BIO_2 rate, cap 0.1 of the stored amount.
Respects: E11 (new where: test that growth counts only Space Storage keys and stays under cap), Availability.

**BIO_11.** Backs: economy, story, QA Graft Lines (3 of 4). Feature left it empty.
Verdict: AGREE. Owner ablation checks the Biotech output stack (BIO_9 slow plus this).
Final: Graft Lines (T, prereq BIO_4, tech goal 14). Biotech units per batch +1 (batch_yield bio 1).
Respects: output stack cap (units per cycle at most 2x base).

**BIO_12.** Backs: feature Patient Orchard (rate, pause after sale), story and QA (rate). Economy's rate-plus-cap version rejected.
Verdict: CHANGE. Cost M, not L: a rate change is a timing edge, not a plan change. Rate 0.02 to 0.03 a cycle (QA sum guard 0.03). Cap unchanged (economy's cap raise to 0.45 is free goods). Growth pauses one cycle after any sale from that storage, which blocks sell-then-grow timing.
Final: Patient Orchard (M, prereq BIO_5). Biotech stock grows 0.03 a cycle (was 0.02); no growth in the cycle after any sale from that storage; cap unchanged.
Respects: E11 (cap bounds free units; test grown at most cap x stored), BIO_5 window is existing.

**BIO_13.** Backs: economy, story, QA Market Days (3 of 4). Feature left it empty.
Verdict: REJECT, leave empty. It copies LUX_5's price-up volume bonus in another market. It also sits next to BIO_5's window, so two timing nodes on one market. Reopen only with a role that is not price-up timing.
Respects: E7.

**BIO_14.** Backs: feature Standing Contract (T, prereq BIO_6). Rejects: economy, story, QA Living Contracts (pure cash, which economy and QA call harmless and weak).
Verdict: AGREE with CHANGE. Fixed price below the good's recent average at one planet (economy sets). Immune to price events for that sale (no upside). Sales still count as volume.
Final: Standing Contract (T, prereq BIO_6, tech goal 14). One planet and one Biotech good sell at a fixed price below its average, immune to price events.
Respects: E2 (target bio), Availability (bio visible), E4 (no cut added).

**BIO_15.** Backs: none. Verdict: REJECT, leave empty.
Economy, story and QA Evergreen is a third copy of the all-bot capstone shape (MIL_7 growth, MIN_7 and BIO_7 strength), and it stacks on BIO_7's cut in the weakest market. Feature Living Link needs the Storage Link, which has not been played, and it adds growth in transit: grow_stock ticks only planet keys today, so this is a new free-goods path (E11). Reopen Living Link after a Storage Link playtest.
Respects: E3, E11.

## 6. Answers to cross-examination points

(a) Binding code findings each backed skill respects (per block above):
- E1 "all": no new sum node uses "all" (FND_3, MIL_15, LUX_15 all lane-filtered).
- E2 sale price: no new sale-price node; Standing Contract and Ore Brokers target market ids.
- E3: latent only; no accepted slot adds bot growth or a chosen-bot node. Fix it before any growth node is reopened (Grand Salon, Evergreen).
- E4 event cut per market (current totals, all under 0.9): MIL 0.5 (no new), LUX 0.35 (LUX_10), MIN 0.3 (no new), BIO 0.4 (no new).
- E5 and E6: one chosen-bot node only (MIL_5, LUX_7). No new hits.
- E7 and E8: one window per market (MIL_12 only new window), no duplicate max or boolean nodes.
- E9: no new reopen node.
- E10: upkeep floor 0.5 holds; MIL_15 surge is an explicit, bounded exception.
- E11: stock growth raised only on Patient Orchard rate (cap unchanged) and Deep Shelf (cap 0.1, Space Storage only). Growth tests separate batch output from stock growth.
- E12: all new Foundations and market nodes compete with permits and with each other.
- E13: UNKNOWN. Needs a run (no change from round 1).
- E14: pacing. No new node is a must-take; the win gate is 23 cycles.
- E15: new free volume techs: Cell Press (MIL, 1), Mass Smelting (MIN, 1). Lux adds none. The owner rule is one new free volume tech per market.

(b) Stack and auto-win risks.
- Accepted, owner ablation required: Military output (MIL_2 and MIL_14); Minerals ore (MIN_4, MIN_9, MIN_8 Strip Mining); Biotech output (BIO_9 slow and BIO_11 on top of BIO_4). Cap: units per cycle at most 2x base in each market.
- Capped: Space Storage growth (BIO_10) at 0.1; planet growth (BIO_2 cap 0.2 and BIO_3 cap 0.3 unchanged; BIO_12 raises the rate to 0.03 only).
- Capped: min cluster yield total at most 0.6 (MIN_3 plus MIN_8).
- Capped: Military window at 12 (MIL_12) and max-based; no double window.
- Removed (auto-win risk): every rival-cut node (MIL_13, MIL_15, LUX_15, BIO_15, Dragnet). The rival pressure stack is the existing MIL_5, LUX_7, MIN_7, BIO_7, MIL_7 only.
- Watch: Hand on the Scales (LUX_15) redirects events; Full Mobilisation (MIL_15) zeroes upkeep for N cycles. Both are bounded by once-per-run or cooldown.

(c) Cut order if the set is too big (first cut first): LUX_15 Hand on the Scales (capstone, new redirect hook); MIL_11 Yard Kits (new ship-pay type); BIO_10 Deep Shelf (new growth path); FND_3 Lane Refit (new route level, largest code change); LUX_13 Patron's Purse (new bundle rule, L). Then MIN_11 Pit-head Smelter (workshop site).

## 7. Count and empty slots

Filled: 29 of 35 (FND_1, FND_2, FND_3, MIL_8, MIL_9, MIL_11, MIL_12, MIL_14, MIL_15, LUX_8, LUX_9, LUX_10, LUX_12, LUX_13, LUX_14, LUX_15, MIN_8, MIN_9, MIN_10, MIN_11, MIN_12, MIN_14, MIN_15, BIO_8, BIO_9, BIO_10, BIO_11, BIO_12, BIO_14).
Empty (6): MIL_10, MIL_13, LUX_11, MIN_13, BIO_13, BIO_15. Each has a reason above.

## 8. Open questions (UNKNOWN from paper)

- E13: how often players reach 20 and 35 percent share in several markets. Needs a run.
- Does Pathfinder have a flight-time key (FND_2)? UNKNOWN, gameplay-programmer to confirm.
- Do MIL_4, MIN_2, MIN_4 or BIO_4 add free volume? Needed for the E15 count before MIN_14 lands.
- Owner: does a stacked-lane ship rule (MIL_9 Convoy Escort) exist? If yes, Convoy Escort can come back.
- Owner: should the absence tax bite (MIL_10 Watch Posts)?
- Owner: is the one-core-per-run rule fixed? It decides MIN_13.
