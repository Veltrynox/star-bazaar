# Systems against cycles (T311)

Status: PROPOSAL. No data, game or story file was changed. Date 2026-11-07, economy-designer, owner run by hand.

**Method.** Hand arithmetic from `data/balance.json` (data_version 80), `data/systems.json`, `data/systems_placeholder.json`, `data/planets.json`, `data/bazaar.json` and `data/prosperity.json`. No sim and no QA bot was run: `tools/sim.py` does not model prosperity or the Bazaar bill, and the QA harness cannot detect a Bazaar win. Every finish cycle below is an ESTIMATE, roughly +-4 cycles. It needs one owner hand run to confirm.

## 1. Inputs (from the data)

| Item | Value | Key |
|---|---|---|
| Term (last cycle) | 40 | `win_cycle_markets` (also the cycle counter) |
| Chain win gate | 38 | `win_gate_cycle` |
| Start cash, ship | 2100, 900 | `starting_credits`, `ship_price` |
| Lane ship | cargo 40, 2-cycle round trip = 20 units/cycle | `cargo` |
| Net per lane-ship cycle | 20 x ~14 margin - trip 60 - upkeep 40/3 = ~210 | `trip_cost`, `maintenance` |
| Post, system 2 | 0.4 x 900 x 1.5 = 540; platform x2 | `post_cost_ship_fraction`, `post_cost_system2_mult` |
| Permits | system 2: 600 + 2 points; systems 3-5 reuse the same keys | `permit_2_cost`, `permit_points_2` |
| Unused escalation | 1500 + 2 points, already in balance | `permit_3_cost`, `permit_points_3` |
| Ship cap | 10 | `ship_cap` |
| Prosperity | T1: 2 needs x 16, 3 steps. T2: 3 x 24, 5 steps | `prosperity_*` |
| Bazaar | capital tier 2, 4 stages, bills 60 / 90 / 80 / 60 (290), quorums 1xT1, 2xT1, 1xT2, 2xT2, other-system world from stage 3 | `bazaar_*` |
| Points | planet 1, route 1, system 2, permit costs 2, tier first time T2 1, T3 2 | `skill_points_*`, `prosperity_points_*` |

Worlds: system 1 has 4 living worlds plus Cinderrest (dead). System 2 has 4 living plus Greywake (dead). Systems 3-5 are placeholders with 3 worlds each (ocean, desert, urban, identical prices). Systems 6-10 are off.

## 2. What the win actually needs

- Capital at T2 (about 8 met cycles after first sales; about 32 units/cycle, then 72).
- Two more T2 worlds for stage 4, and one quorum world in another system from stage 3. That is the only hard system requirement: **at least 2 systems**, so a never-expand run cannot win and ends Unfinished at stage 2.
- Feed volume: ~1370 units of tier feed (3 T2 worlds, ~456 each) plus 290 bill plus ~25 percent decay losses = about 2000 units. A mid-game fleet of ~7 ships moves ~140 units/cycle, so about 14 full-fleet cycles after the fleet exists (about cycle 9).
- Fleet at about 1450 credits/cycle (7 ships x 210). Capital T2 about cycle 11-14. Goods tiers 3-4 (stage 3-4 bills) wait on the market skills and workshops: UNKNOWN timing, the largest error source.

**Focused run:** one capital, two quorum worlds, one cross-system world in system 2. Estimated Opening at cycle **~34** (range 30-38). This is later than the old `targets` block (win 22-30) and matches T268's c37 estimate; the old targets are stale for a Bazaar win and should be retired by the owner.

**Spread run** (opens every live system, grows every world to T1): about +3 cycles for in-system worlds, plus ~4 cycles per extra system. Each extra system costs permit + 3 posts + ~192 units of T1 feed, and adds nothing the quorum needs.
- Permit 1500 + 3 posts 1620 = 3120 = 2.2 fleet-cycles.
- Feed 192 units = 1.4 cycles.
- Flight and attention = ~0.5 cycle.
- Total about 4 cycles with lost compounding.

**Slow run** (half income): capital about cycle 20, stage 2 by the term. Idle routes cost nothing and two stipends of 1000 exist, so the run ends Unfinished (soft), not Bankrupt.

## 3. Per system count

| Systems live | Permit cost against income | Quorum worlds on offer | Points over a run (est.) | Capital tier | Spread finish |
|---|---|---|---|---|---|
| 2 | 600 = 0.4 fleet-cycle; cheap, one world there (1140 with post) is enough | 3 + 4 living = 7 (need 3) | ~19 (planets 10, routes 6, system 2, tiers 3, permit -2): barely one tree | c11-14 | ~37, nothing to over-expand |
| 3 | 1500 = 1 fleet-cycle | 10 | ~24: fits one tree plus Foundations, a little spare | same | ~41 |
| 4 | second 1500 | 13 | ~29: fits two trees | same | ~45 |
| 5 (today) | third 1500 | 16 | ~34: tree saturates (68 nodes), points stop mattering | same | ~49 |

Capital tier time does not depend on system count: the capital and its feeders are in system 1. Worlds are never the constraint. More systems lengthen only the spread run and raise points. Points beyond about 29 buy nothing the player can use.

## 4. Alternatives (systems x term). Focused / spread finish, margin to term

| | Term 40 | Term 42 | Term 45 |
|---|---|---|---|
| 2 systems (F 34, S 37) | focused +6, spread +3 wins (dominant) | +8, +5 wins | +11, +8 wins |
| 3 systems (F 34, S 41) | +6, spread -1 coin flip | +8, spread +1 wins narrowly | +11, +4 wins |
| **4 systems (F 34, S 45)** | +6, -5 short | **+8, -3 short** | +11, 0 coin flip |
| 5 systems (F 34, S 49) | +6, -9 short | +8, -7 short | +11, -4 short |

2 systems: spread cannot fall short, so there is no reason to choose. 5 systems: spread does fall short, but it needs four designed systems, and the points saturate. 3 systems at term 40 works only by luck (margin -1).

## 5. Recommendation: 4 systems, 42 cycles

- Focused margin 8 cycles (range 4-12). Spread falls short by about 3 and ends Unfinished at stage 3. Never-expand and slow end Unfinished.
- Keeps today's temporary systems 3 and 4 and switches off 5. The owner designs two new systems, not three.
- Points (~29) fill two market trees without saturating.
- Fallback: 3 systems, term 40 (no change to the term) if two designed systems is too much content. Then accept that a spread run is a coin flip.

### Exact keys to change (all existing keys; none new)

| File | Key | Old | New | Why |
|---|---|---|---|---|
| `data/balance.json` values | `win_cycle_markets` | 40 | 42 | term. Needs the pinned test in `tools/tests/run_tests.gd` changed (T268 note). |
| `data/balance.json` values | `win_gate_cycle` | 38 | 40 | keep the gate two cycles under the term |
| `data/systems_placeholder.json` system 5 | `on` | true | false | 4 systems live |
| `data/systems_placeholder.json` systems 3 and 4 | `permit_cost_key` | `permit_2_cost` | `permit_3_cost` | 1500 each, so every extra system costs more than system 2 |
| `data/systems_placeholder.json` systems 3 and 4 | `permit_points_key` | `permit_points_2` | `permit_points_3` | same 2 points |

Left alone: `bazaar_*`, `prosperity_*`, `win_earliest_cycle` (23, no longer binding), `dead_unlock_cycle`, `raid_first_cycle`. A separate `permit_4_cost` would be a new key and needs owner approval; it is not proposed.

## 6. Risks and open points

- Post cost for systems 3-5 is UNKNOWN: only a system-2 multiplier is documented. I assumed x1.5.
- Goods tier 3-4 timing (stage 3-4 bills) is UNKNOWN and could add 3-6 cycles. If it does, raise the term by 3 and keep 4 systems.
- `targets` (win 22-30 cycles) in `data/balance.json` is stale against a ~34 Bazaar finish. The owner should retire or retune it.
- A hand run by the owner (focused and a four-system spread) is the only real check. T312 can only check the arithmetic, not the finish cycles.
