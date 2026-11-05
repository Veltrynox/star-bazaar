# Storage Link: a goods-priced bridge between two Space Storages (T169)

Feature designer, 2026-11-05. Proposal only; owner decides. Replaces the open design in T165 (drop or merge it). All numbers are PLACEHOLDERS for the economy-designer (marked P).

## Facts read
- Space Storage is one container per system, key `system:<n>`, capacity `space_storage_capacity` 500 per good (game/storage.gd). It exists once FND_STORAGE is learned and a ship first sends goods there (main.gd 522-591). View: game/space_storage_view.gd.
- Space Storage fills only by ship (`planet_to_space_rate` unused). Moving goods between systems today costs a ship trip (trip_cost, permit, cycles).
- rivets is the one argued sale-only orphan (resource-final); visible only after `system_open:2`. Energy is visible from start.
- ship-flight-discovery.md did not exist when this was written (see section 9).

## 1. Problem
Goods made in one system (Fabric, workshops) sit in that system's storage. Moving them to the other system needs ship slots, which already carry the profit lanes. Rivets has no use at all.

## 2. Idea
A **Storage Link** joins the Space Storage of two open systems. It costs goods, never credits. Once built, the player sets standing **link orders** ("move up to N of good G from A to B each cycle"). Transfers run at cycle settle, without a ship. The link eats a little energy every cycle.

## 3. Rules (exact)
- **Endpoints:** two established Space Storages in different systems. One link per pair. Each storage may hold at most `link_max_per_storage` (P: 2) links. With two systems this is one link; more systems add more pairs.
- **Build cost (goods only):** `link_build_rivets` (P: 120) plus `link_build_energy` (P: 200). Taken from the two storages, in any mix the player picks in the build dialog; build is refused if the two stocks together fall short. Rivets finally has a sink: one-time, about 3 full system-2 rivets loads.
- **Upkeep per cycle:** `link_upkeep_energy` (P: 20), taken at settle, first from the storage with more energy. Energy is a common raw, so this is a steady sink that new players can always feed.
- **Transfer rate:** `link_rate` (P: 60 units per cycle, total over all goods, per link, both directions together). Orders run in the order the player lists them. Capped by stock at the source and free space at the target (existing `Storage.space`). Nothing is lost in transit. No transit time (arrives at settle).
- **Orders:** one standing order = good, direction, amount per cycle (or "keep target at X"). Max `link_orders_max` (P: 4) per link. Orders for hidden goods cannot be created.
- **Upkeep stock runs out:** the link goes **Dormant**: no transfers, orders and stock kept, upkeep is not charged. It wakes in the next settle where both storages together hold the upkeep energy. If it stays dormant `link_dormant_limit` (P: 4) cycles in a row, it **collapses**: orders are lost and the player must pay the build cost again. Warning notice at the first dormant cycle and again one cycle before collapse.
- **Not a trade tool:** the link moves stock only. It cannot buy, sell, or touch planet storage, ships or events (no pirate loss, no price effect).

## 4. Player's new choice
Spend a mid-game stock of rivets and energy to free ship slots, versus keeping those goods for sale or crafting. Decide which goods ride the limited rate (finished plate and armour up, or inputs down). Keep or drop a link when energy is tight.

## 5. Dominance check (pillar: trading profitable, never trivial)
- Rate 60 per cycle is under 2 ship loads (cargo 40), so a link replaces about 1.5 ship trips, not a fleet.
- It earns nothing by itself; ships still do all buying and selling. Value is time and slots saved.
- Build cost plus upkeep (about 1,000 credits of goods if all energy were sold) must pay back in roughly 8 to 12 cycles. Economy-designer to check with `tools/sim.py` and the QA bots.
- Money never buys skill points: unaffected.

## 6. Unlock rule (data/availability.json)
New feature `storage_link`, `visible_when`: `{"all": ["skill_learned:FND_STORAGE", "system_open:2", "good_visible:rivets"]}`. Needs a note and a hidden-feature entry in `start_state`. The link UI, build button, order rows and every text about it stay hidden until true. Story texts must not name rivets before `good_visible:rivets`; the rule already includes it. The build dialog lists only visible goods.

## 7. Sinks created
- rivets: one-time build cost (first real use).
- energy: build part and per-cycle upkeep, the common raw sink.
- Nothing else; no new good, no recipe change (bot FEED_SHIPS unaffected).

## 8. UI sketch (ui-programmer)
In the Space Storage view, under the capacity line:
```
Storage Link          [Build link...]
 Voltara <-> Greywake   Active   upkeep 20 energy/cycle
  Rate used 48 / 60
  > plate   Voltara -> Greywake   20 /cycle  [x]
  > ore     Greywake -> Voltara   28 /cycle  [x]
  [Add order]
```
Build dialog: partner system, cost lines for rivets and energy with "have / need" per storage. A dormant link shows a red "Dormant: needs 20 energy" and a cycles-to-collapse count. Row tooltips reuse GoodInfo.block. Map: a thin line between the two station icons, dim when dormant. Texts by story-designer (SS_LINK_* ids, English only on main).

## 9. Flight and discovery
ship-flight-discovery.md was not available. Assumptions, to re-check when it lands: (a) if flight adds travel time or danger between systems, the link is the safe instant option and its rate/cost must stay below ship value; (b) a newly discovered system gets a Space Storage only through the existing rule, and links to it need that storage first; (c) the link never moves ships or discovers anything.

## 10. Tests (tools/tests/run_tests.gd, `sh tools/tests/run.sh`)
- Start state: no link UI, no link text, no `storage_link` feature visible; true only after FND_STORAGE + system 2 + rivets visible.
- Build: refused with too little rivets or energy; accepted deducts exactly cost; credits unchanged.
- Transfer: respects rate cap, source stock, target capacity; totals conserved; order list order honoured.
- Upkeep: charged each settle; short stock goes Dormant with no transfer and no charge; wakes when energy returns; collapses after the limit; notices fire once.
- Limits: one link per pair, per-storage max, orders max.
- Save/load round trip of links, orders and dormant counter; old saves load with none.
- Text scan: no hidden good named; availability lint passes.
- Bot: QA bot with no link behaves as today (no regression in 4/4 wins, cycle 27).

## 11. Cost and owners
- gameplay-programmer: link state, settle step, save, M.
- ui-programmer: link block in space storage view, build dialog, map line, M.
- economy-designer: 5 balance keys, sim payback check, S.
- story-designer: about 10 text ids, S.
- QA: tests and a bot ablation, S.
Total: M to L.

## 12. Questions for the owner
1. Collapse after 4 dormant cycles, or never collapse (only dormant)?
2. Standing orders (as above) or one-off "transfer now" button only? Standing orders are less clicking but add a settle step.
3. Should the link also let ships in one system sell to the other storage's stock? (Not proposed.)
