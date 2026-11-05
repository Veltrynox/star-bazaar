# More skills for the tree (T172, feature-designer, 2026-11-05)

Status: PROPOSAL. Nothing is approved. Every node waits for the owner, and for the economy-designer and qa-analyst round run by the main session. No values here: each "key" is a new balance.json value the economy-designer sets.

## The gaps (31 nodes now)
- Every market is one straight chain with a single fork at tier 2/3 (MKT_2 and MKT_3, then 4 and 5 join at 6). Tiers 3 and 4 have no second skill, so there is nothing to choose between at the point where a run commits.
- Military has no storage, stock or cluster identity. It is upkeep, one route buff, two rival hits.
- Luxury information stops at tier 2 (LUX_1 reveal, LUX_3 forecast, both one cycle).
- Minerals has no event protection and no ship effect. Biotech has no route effect.
- Unused vocabulary: `order_size_pct` (nothing uses it since BIO_1 changed), `storage_cap_pct` (BIO_3 only), `route_capacity_pct` (MIL_3 only), `event_immune` (MIL_3 only), `event_cut_pct` (not in Luxury or Minerals), `stock_protect` (BIO_5 only), `reopen_sooner` (BIO_6 only).
- The three Foundations are pure unlocks. A player with 1 spare point early has nothing to buy that helps the first cycles.
- Points: about 21 a run; a market costs 10, the Foundations 3. New nodes must stay optional side nodes, so a focused run still cannot afford everything. All nodes below are skills (cost points), none are techs. Costs are suggestions for the economy-designer.

Ranked by value over cost.

## 1. Side skills at tier 3: a second choice in each market (4 nodes)
Problem: tier 3 has one skill per market, so the paths are all the same.
Idea: one extra skill per market, branching from the tier-2 skill (MKT_3), cost 2 each. Existing effect types only. It is a fork, not a requirement for MKT_6.

| node | name idea | effect | prereq | gap |
|---|---|---|---|---|
| MIL_5B | Supply Depot | `storage_cap_pct` planet_storage + `stock_protect` mil | MIL_3 | military has no stock identity; hoard cells for a share check |
| LUX_5B | Long Ledger | `reveal_prices` and `event_warning` to 2 cycles | LUX_3 | information stops at tier 2; deeper planning |
| MIN_5B | Hard Hats | `event_immune` debris on min + `event_cut_pct` min | MIN_3 | miners run the debris lanes with no cover |
| BIO_5B | Cold Chain | `route_capacity_pct` bio | BIO_3 | biotech has no route buff; the stock grows, now it can also ship in bulk |

Player's choice: tier 3 has two skills in a market, 3 points for the big one or 2 for the support one; with ~21 points the player cannot take all.
Risk: LUX_5B may be strong with BIO_2-style holding; MIL_5B stacks with BIO_3 storage. Cost: data, balance keys, story texts. economy-designer (values, S), story-designer (4 texts, S), gameplay-programmer (none expected; hooks exist, check `reveal_prices` with 2 cycles, S). Total M.
Questions: should side skills count toward the ending epilogue? Is a 2-point fork right, or 3?

## 2. Two Foundation-tier skills for the first hour (FND_BULK, FND_RELAY)
Problem: the first points can only buy unlocks; there is no cheap felt gain.
Idea: FND_BULK "Bulk Orders": `order_size_pct` all, cost 1, prereq none. FND_RELAY "Relay Network": `route_capacity_pct` all (small), cost 2, prereq FND_PERMIT. Neither opens a market; they sit beside the Foundations and do not block the "all three Foundations" gate.
Player's choice: take a first-hour speed-up or save points for a market. Uses two idle vocabulary types.
Risk: speeds the slow stretch for everyone and may make trading trivial; the economy-designer must size it small and QA must check early cash.
Cost: S data, S UI (a second block in the Foundation row), S economy. Owner: economy-designer + ui-programmer.
Questions: should these unlock before the three Foundations are learned? How big is "small"?

## 3. Cross-market bridge skills (3 nodes)
Problem: the tree punishes spreading, so nobody tries two half-markets, and strategy is one-dimensional.
Idea: tier-4 skills (cost 3) that need a node from two markets. The reward is a hybrid: it must be worth less than finishing one market.
- MIL_MIN "Forge Pact" (needs MIL_4 and MIN_4): `batch_yield` +1 on mil and min workshops; armour and alloy get a doubled batch.
- LUX_BIO "Perfumer's Guild" (needs LUX_4 and BIO_4): `volume_pct` lux and bio, only for sales at a price-up planet (reuse the LUX_5 condition).
- MIN_LUX "Jeweller's Contract" (needs MIN_5 and LUX_4): `sale_price_pct` target good gems, share_effect true (gems count in share, not just cash).
Player's choice: a two-market build with a payoff, not just a focused one.
Risk: dominant hybrid if the value is high; the existing four-way tree already needs QA ablation tooling. The `target: good` price form already exists in the vocabulary. Cost: M data and balance, S code (need the cross prereq check in `SkillTree` and `target good` sale price in `Skills.sale_price_mult`; gameplay-programmer to confirm), story S, UI S (the tree screen layout has only market columns: ui-programmer, M).
Questions: should the hybrid be allowed at all, as the owner's pillar says the tree punishes spreading?

## 4. Rival tools beyond the capstone (Military and Biotech only)
Problem: Military and Luxury have a "pick a rival" skill (MIL_5, LUX_7); Minerals and Biotech only have a blanket cut. The chosen-bot choice is the most interesting decision in the tree.
Idea: MIN_6B "Claim Marker" and BIO_6B "Quarantine Order", `bot_strength_pct` chosen_bot, each a smaller hit with a short cooldown, cost 3, prereqs MIN_5 and BIO_5. The strong blanket cut (MIN_7, BIO_7) stays at tier 5.
Player's choice: harass one rival now, or invest in the permanent cut later.
Risk: stacks with MIL_5 and LUX_7 so a player may suppress all rivals early; a cap on total cut may be needed. Cost: data and balance (economy-designer, S), story (S), code none (reuses `activate_bot_skill`). The skill screen must list four "Use on..." skills (ui-programmer, S).
Questions: is a hit needed in every market, or is the Military-Luxury asymmetry good?

## 5. Reactive skills for events (Military and Luxury)
Problem: events matter but only Military (MIL_6) and Biotech (BIO_6) cut them, and Luxury only profits from price-ups.
Idea: LUX_6B "Fair Weather Patrons": `event_cut_pct` lux (damage and price-down events) at tier 4, cost 3, prereq LUX_5. MIL_6B "Hardened Convoys": `reopen_sooner` (cycles 1) and `event_immune` debris on all routes with military cargo, tier 4, cost 3, prereq MIL_5. The second also gives MIL_3 a successor.
Player's choice: insure a stock or run a risky lane for a profit.
Risk: low; the effect only protects, never gives cash. Cost: S economy, S story, none for code (types exist). If `event_immune` is extended to `pirate`, it has no live source (see MIL_3 note), so only debris.
Questions: UNKNOWN whether Luxury has enough negative events for the cut to be felt (economy-designer).

## Not proposed
- Pure cash skills (flat sale-price percent): they do not help share, the win condition. The tree already has six `sale_price_pct` extras.
- A new effect type: none argued. If the owner wants exclusive picks (choose A or B), `exclusive_with` would be a new prereq rule, argued only if the owner asks.
