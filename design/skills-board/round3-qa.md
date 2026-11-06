# Round 3, qa-analyst: ballot (paper review, owner-called)

Format per slot: FIRST x; ACCEPTABLE y,z; reason and guard. Guards are conditions the build must include. Settled facts from consensus.md are taken as given.

1. FND_2 Pathfinder: FIRST a; ACCEPTABLE none. Flight time only at S; the trading post and platform cost part overlaps the route-cost nodes, so (b) is out. Guard: confirm a Pathfinder flight-time key exists (round2 open question).

2. FND_3: FIRST b (empty); ACCEPTABLE a. The "CHANGE Lane Refit" in round2-qa is the per-lane level-2 to level-3 refit with a steep fee, not on this ballot, so this vote does not back it. Lane Yards is a route cost cut with no decision, close to the rejected DOCKS shape, so I can live with it only with a guard: no "all" lanes (E1), applies to the upgrade step only, and does not stack with any other route cost node.

3. MIL_10: FIRST c; ACCEPTABLE none. Convoy Escort depends on an owner answer about stacked lanes, and Scrap Rights needs a new salvage type that is thin; leave empty.

4. MIL_11: FIRST b; ACCEPTABLE none. Yard Kits is a real decision (armour pays part of a ship price). Guard: capped fraction per ship (0.3 suggested), ship_cap 6 bounds the loop, armour stays goods, not money.

5. MIL_12: FIRST c; ACCEPTABLE none. Open Arsenal (share window 12) is the only new Military window (E7). Dragnet is invalid: it needs the removed shared cooldown and adds a second chosen-bot hit (E5). Guard: share_window("mil") returns 12 and a second window node changes nothing.

6. MIL_13: FIRST a (empty); ACCEPTABLE none. Pressure Doctrine stacks on MIL_5 and breaks E5 and E6, and a bigger hit is a number, not a role.

7. MIL_15 Full Mobilisation: FIRST a; ACCEPTABLE b. Lane-filtered (not "all", E1), once per run, at most 5 cycles, and the upkeep floor returns after the surge (E10). Story's (b) (no upkeep only) is acceptable on the same guards.

8. LUX_9: FIRST b (Pattern Books); ACCEPTABLE a. I prefer alternative visible inputs, but Second Loom is tolerable. Guard: Luxury units per cycle at most 2x base including LUX_6, owner ablation of the output stack, and no new goods (Availability).

9. LUX_11: FIRST c; ACCEPTABLE a. Collector's Eye is cash price only and changes no share, so it is harmless; accept only if it stays cash-only with no share or volume effect. Showcase (b) stays out (free planned LUX_5 bonus, optional LUX_5).

10. LUX_12: FIRST b (Boutique Hold); ACCEPTABLE a. Courier Pool is the Luxury route node, as I accepted Gel Cooperatives for Biotech (BIO_8), so I now accept it, which reverses my round2 Press Room rejection. Guard: +0.10 applies to Luxury only, one route node in Luxury (E7), no "all".

11. LUX_13 Patron's Purse: FIRST b (L); ACCEPTABLE a (M). Luxury-only, single-market bundle (mixed load is impossible in code). Guard: the cap binds, not the percentage; economy sets the value; no change to LUX_5's event bonus.

12. LUX_14: FIRST b (Auction Floor); ACCEPTABLE a. This corrects my round2 rejection: E15 allows one new free volume tech per market, and Luxury has none new (LUX_2 is existing). Guard: total Luxury free volume at most 0.20 (LUX_2 0.08 + 0.06 = 0.14). Auction Floor is kept first because its wait rule is a decision.

13. LUX_15 Grand Salon vs Hand on the Scales: FIRST b (Hand on the Scales); ACCEPTABLE a. Grand Salon is a permanent rival cut, which needs E3 fixed in code first (bot_growth_mult must honour permanent and pick). Accept only if BIO_15 stays empty, so there is one rival-cut capstone overall. Hand on the Scales has no rival effect and remains my first choice.

14. MIN_8 Strip Mining: FIRST a; ACCEPTABLE none. Guard: min cluster yield total at most 0.6 (E4); an empty cluster route shows empty and lets the player reroute (softlock test).

15. MIN_11: FIRST a (Pit-head Smelter); ACCEPTABLE b. Hot Foundry is cash-only and thin, so acceptable only on the cash-only guard (no volume, no share, ingots still need a sale). Guard for (a): Availability on platform and smelter.

16. MIN_13 Null Core: FIRST c (empty); ACCEPTABLE b. Option (a) raises null_core_max from 1 to 2 and breaks the owner rule (balance v31), so it is out. Option (b) keeps one core and is acceptable if economy sets a trip value that is not a trap (about 15 per trip is the trap). Owner should confirm the one-core-per-run rule is fixed.

17. MIN_15 Motherlode: FIRST a; ACCEPTABLE b. Richness only, 120 to 180, no yield stack (E4). Guard for (b): drop the survey-fee part entirely; no new fee type.

18. BIO_9: FIRST b (slow mode); ACCEPTABLE a. Slow mode is a real timing decision, while +1 batch is a flat third batch copy. Guard for (a): Biotech units per cycle at most 2x base including BIO_11, and owner ablation on the Biotech output stack.

19. BIO_10 Deep Shelf: FIRST a; ACCEPTABLE none. Guard: growth ticks only Space Storage keys (E11), cap 0.1 of stored, Availability space_storage.

20. BIO_12 Patient Orchard: FIRST a; ACCEPTABLE none. Rate 0.02 to 0.03, cap unchanged, no growth the cycle after a sale. Economy's cap raise to 0.45 (b) adds free goods and is out (E11).

21. BIO_13 Market Days: FIRST b (empty); ACCEPTABLE none. Stock-fed sales copies LUX_5's price-up timing in another market and sits next to BIO_5's window.

22. BIO_14: FIRST b (Standing Contract); ACCEPTABLE a. Living Contracts is cash-only and weak, so acceptable only as cash-only (Biotech, +0.06, no volume, no share). Guard for (b): one planet, one Biotech good, sales still count as volume, immune to price events for that sale.

23. BIO_15 Evergreen: FIRST b (empty); ACCEPTABLE none. It is a second rival-cut capstone next to LUX_15 (a) and needs E3; it also adds growth in a market already cut by BIO_7. Reopen only after a Storage Link playtest.
