# More skills, round 2 (T173, feature-designer sign-off, 2026-11-05)

Status: PROPOSAL. Nothing is approved. Values belong to the economy-designer; all numbers below are ideas only.

## (a) The 3 kept nodes
- LUX_5B (reveal and warning 2 cycles, cost 2): interesting and felt, but only once code reads `cycles`. Until then it is a dead purchase (economy flagged this). Gate it: do not ship the node before gameplay-programmer reads `cycles` for both effects.
- MIN_5B (debris immunity + event cut 0.3, cost 2): felt only when a debris lane hits. It is insurance, not a play change. Acceptable, but weakest of the three; it is felt best in dead-world runs.
- BIO_5B (route capacity 0.125, cost 2): the most felt: more units per trip every cycle. Check it against BIO_5 (share window) so the second is not obviously the pick.
Verdict: accept all three; LUX_5B conditional on code.

## (b) The 11 rejected
Accepted rejections: FND_RELAY (global capacity beats market nodes), MIN_LUX, LUX_BIO, MIL_MIN (bridges undercut spreading, need new UI and code), MIL_6B (duplicates MIL_3 and BIO_6), MIN_6B (see rescue 3: only one rival tool is added, not two).
Rescued with changes: MIL_5B, FND_BULK, BIO_6B, LUX_6B (below).

## (c) Rescued nodes (4)

### 1. MIL_5B "Supply Depot" (tier 3, cost 2, prereq MIL_3)
Problem: Military has no stock identity; the old version leaked storage to all markets.
Effect: `stock_growth_pct` target mil, where planet_storage, with its own cap key (idea: about half the BIO_2 rate and cap), plus `stock_protect` mil. No `storage_cap_pct`, so no stacking with BIO_3, and no bleed into other markets.
Choice: a Military player can hoard cells and armour for a big share check, at the price of 2 points. Biotech keeps the strong version through BIO_2 and BIO_3.
Risk: free stock is share. Cap it low. Cost: data and balance (economy-designer, S), story text (S), code none (effect exists for bio; gameplay-programmer confirms it takes target mil, S).

### 2. FND_BULK "Bulk Orders" (Foundation, cost 2, no prereq)
Problem: first points only buy unlocks.
Effect: `order_size_pct` all, small (idea: +25 percent at most). Cost raised from 1 to 2 so it is no longer a free no-brainer: the three Foundations plus this cost 5, so the first market opens later. It is a loan against the run: strong in the first cycles, dead later when the order cap stops binding.
Choice: speed now or a market earlier. Out of about 21 points it takes 10 percent.
Risk: easier early cash; QA checks the first 10 cycles. If the owner sees any cash risk, drop it. Cost: S data, S UI (a block beside the Foundations; ui-programmer), S economy.

### 3. BIO_6B "Quarantine Order" (tier 4, cost 3, prereq BIO_5), with a shared cap
Problem: the chosen-bot hit is the best decision in the tree and only Military and Luxury have it. Economy rejected two more because three or four hits suppress every rival.
Effect: `bot_strength_pct` bio, chosen_bot, a smaller hit than MIL_5. New rule: all chosen-bot hits share one cooldown ("one pressure action per window"). Extra tools then add flexibility (which rival, which market), not extra power. Only Biotech is added, not Minerals, so the strong blanket MIN_7 stays Minerals' answer.
Choice: which rival gets the single hit this window.
Risk: shared cooldown is a rule change. Cost: gameplay-programmer (shared cooldown in `activate_bot_skill`, M), economy-designer (S), story (S), ui-programmer (list shows the shared timer, S).
Question: owner, is a shared cooldown acceptable?

### 4. LUX_6B "Fair Weather Patrons" (tier 4, cost 2, prereq LUX_5B)
Problem: LUX_5B ends in a dead end; economy rejected LUX_6B as a cost 3 tier 4 trap with thin Luxury events.
Effect: `event_cut_pct` lux (idea: 0.3, the same as MIN_5B). Cost 2, and the prerequisite is LUX_5B, not LUX_5, so it continues the information branch: foresee events, then soften them. Players who take LUX_5 (volume) cannot reach it without also paying LUX_5B.
Choice: volume branch (LUX_5, LUX_6) versus an information-and-safety branch. The full branch costs 2+2+2 versus 3.
Risk: Luxury may lack negative events; UNKNOWN until economy counts them. If so, reduce to cost 1 or drop. Cost: S data, S story, no code.

## Point supply
About 21 points per run, 3 Foundations, a market chain 9. With FND_BULK (2) and two sides (4 to 5), a focused run uses 18 to 19. A second market (10) still does not fit. Spreading stays punished.
Tree grows from 34 to 38 nodes if all four are kept.

## Open questions
- UNKNOWN: does Luxury have enough negative events for LUX_6B (economy-designer)?
- UNKNOWN: is stock growth on mil felt at a low cap (QA)?
- Owner: shared cooldown for chosen-bot hits, yes or no?
