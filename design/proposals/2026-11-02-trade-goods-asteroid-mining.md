# Proposal: three new goods, asteroid mining, and the mining skill (T152)

Date: 2026-11-02. Author: feature-designer. Goal: trade-goods-asteroid-mining.
Status: all items WAIT FOR OWNER. Names are working names (names are owner-approved only). No numbers here: economy-designer sets them in T153.

## What exists today (checked in code and data)
- Goods are energy and food only (planets.json `base_prices`, keys `<good>_buy` / `<good>_sell`; trade.gd reads them per commodity).
- Asteroid today is one event, EV20: pay `asteroid_deflect_cost` (+1 expansion point) or decline and roll `asteroid_decline_bad_odds`; a bad roll cuts one established planet's storage by `asteroid_storage_loss_pct` (main.gd `asteroid_pay` / `asteroid_decline`, events.gd `asteroid_roll`). There is no asteroid on the map and no mining.
- B1 Market Ledger = price trend in planet_panel.gd, best partner and low-margin warning in route_engine.gd.

## Proposal 1 (rank 1): Three goods
Problem: two goods, three planets; every route is the same food/energy swap.
Idea: add one good per role. Each has a clear home and a clear buyer, so the pairing is a choice, not a copy of food/energy.

| Id | Working name | Role | Made at (cheap to buy) | Wanted at (pays most) |
|---|---|---|---|---|
| silk | Starsilk | Luxury | Tillam (lush) | Voltara (crews with credits, nothing soft), Ashgate pays a little |
| chips | Logic Cores | Tech | Voltara (volcanic foundry, runs on cheap energy) | Ashgate (farms automate), Tillam pays a little |
| ore | Rock Ore | Mining | Asteroid clusters (not bought at a planet) | Voltara (foundry) pays most; Ashgate low; Tillam none |

Why they fit:
- Luxury: small volume of high value, price swings hard with events; rewards timing, punishes carrying it into a closed planet. A low-bulk good also tests the cargo cap (value per unit, not units).
- Tech: mid price, steady, and needs energy to make, so a Voltara energy lane plus a chips lane compete for the same ships. Choice: haul cheap bulk or thin-margin tech.
- Ore: free to take, so its cost is ship time and a skill, not credits (see Proposal 2).

Player's new choice: which good fills a lane's cargo; mixed loads become real (N3 bundle bonus still applies).
Risk: more goods raise the sim and UI load; luxury could dominate (pillar: profitable, never trivial).
Cost: data = economy-designer (S, with T153); code = gameplay-programmer (M, T155: goods list beyond two keys); UI = ui-programmer (S, T159).
Questions: see Q1, Q2 at end.

## Proposal 2 (rank 2): Asteroid mining
Problem: the sky has one dead event and the map has nothing to do between planets.
Idea: spherical packs of asteroids ("clusters", GPU-instanced in T157) sit between planets in system 1 (suggest 2 in system 1, more in system 2; count is T157/T153). A cluster is a source of ore, not a market.
- Harvest: needs skill B1 (Prospecting, below). The player draws a route from a cluster to any planet (same route drawing as today, cluster is the start node). The ship loads ore free on arrival at the cluster and sells it at the destination. The lane costs `trip_cost` and upkeep like any lane.
- Yield: each cluster has a finite richness (units). Every trip removes up to the ship's load from it. The cluster visibly thins (fewer instances drawn) and goes dark at zero. Richness is a number for economy-designer.
- Depletion, not respawn: when empty it is gone. This keeps ore a limited windfall and keeps trading profitable but not trivial. New clusters appear only through EV20 (below).
- Contest: ore routes are "open space" lanes. The existing debris and pirate keys already cover lane risk (`debris_route_penalty`, `pirate_volume_penalty`); ore lanes use them as is, no new risk system.
- Link to EV20: the strike event stays as is. Two additions:
  1. Paying `asteroid_deflect_cost` also leaves a fresh small cluster near the hit planet (the rock is pulled apart for mining). Decline plus a bad roll: `asteroid_storage_loss_pct` applies to a planet as today, and also to ore parked at a planet, nothing new.
  2. If the player has no mining skill the event plays as today (no regression).
- No duplicate: the deflect cost and loss pct keys are reused, no new keys for the event.

Player's new choice: spend a ship on a free but finite good, or on a lasting food/energy/tech lane; mine early, or save the cluster for a good ore price.
Risk: a free good can break the cash target (win_cash, win_cycle); deplete-only limits it. Needs the sim check (T160). Map clutter in 3D/2D (open Q4 in blackboard).
Cost: gameplay-programmer L (T156: cluster nodes, lane start from cluster, depletion, save/load), galaxy-builder M (T157: instancing), economy-designer S (richness, ore price).
Questions: Q3, Q4.

## Proposal 3 (rank 3): Replace B1 Market Ledger with Prospecting
Problem: B1 is a Research skill that only adds readouts, and mining needs an unlock.
Idea: B1 becomes **Prospecting** (Research branch, same slot, same cost key `skill_cost_B1`, no prerequisite, so the tree shape and T72 are untouched).
- Plain effect (draft): Lets you draw routes from asteroid clusters and shows each cluster's remaining ore. Ore loads take no order space.
- Price trend and route warning: **keep them for everyone**, not behind a skill. Move to the base game: they are information the player needs to see that a lane loses money (friction in early cycles). The "best partner" marker stays gated: it moves to B3 Price Whisper (already the price-knowledge skill). Decision D5.
- Flavour and plain text: story-designer (T154). Code: gameplay-programmer in T158 (removes `has_skill("B1")` checks in planet_panel.gd and route_engine.gd).
Player's new choice: spend 1 point on mining vs the other Research nodes.
Risk: ungating the warning removes a reason to take B1; that is intended, since B1 is replaced. Early game gets slightly easier; sim T160 to confirm cycles stay in target.
Cost: S design, S code, S text. Questions: Q2.

## Proposal 4 (rank 4): Events for the goods
Problem: new goods need the same weather as food and energy, plus mining stories.
Idea (ids placeholder, producer sets final; text is story-designer, T154; EV19 is unused, new ids start at EV21):
| Id | Good | Intent |
|---|---|---|
| EV21 | silk | Tillam silk guild strike: silk price up at Tillam |
| EV22 | silk | Voltara gala: silk pays more at Voltara for a few cycles (follow-up to EV21: the guild settles, glut drops price) |
| EV23 | silk | Silk glut at Tillam after the settlement: price down (follow-up of EV21, 3 cycles later) |
| EV24 | chips | Foundry fire at Voltara: chips price up, supply short |
| EV25 | chips | Ashgate tractor recall: Ashgate buys chips for more (follow-up of EV24 if chips lane exists) |
| EV26 | ore | Rich seam found: one cluster refills a little (choice: pay a survey fee for it, or ignore) |
| EV27 | ore | Rockfall in the cluster: ore lane is closed for a few cycles (reuses planet-closed style tag) |
| EV28 | ore | Foundry demand spike at Voltara: ore pays more (follow-up of EV26) |
Rule: each good has two events and at least one follow-up (EV22 after EV21; EV25 after EV24; EV28 after EV26). Tags reuse existing `[price up|down: ...]` / `[planet closed]`; EV26 and EV27 need two new tags (`cluster refill`, `lane closed`), gameplay-programmer S.
Cost: story-designer M, gameplay-programmer S, economy-designer S (frequency inside `event_interval`).

## Decisions (made by me, open for owner review)
- D1: Three goods: silk (luxury), chips (tech), ore (mining). Working names only.
- D2: Silk made at Tillam, wanted at Voltara; chips made at Voltara, wanted at Ashgate; ore from clusters, wanted at Voltara.
- D3: Ore is free at the source; cost is a ship lane and a skill. Clusters deplete and do not respawn.
- D4: Clusters start a route (like a planet node); no separate mining order or harvest action.
- D5: B1 becomes Prospecting. Price trend and low-margin warning become base-game; best-partner marker moves to B3.
- D6: Luxury exists in system 1 and also system 2 (answers goal Q3 by default; prices set by economy-designer).
- D7: EV20 stays and gains a cluster as a pay reward; no new balance keys for the event.
- D8: Goods part of T149 is absorbed here; its planets and follow-up events stay queued.

## Open questions for the owner
- Q1: Are the names Starsilk, Logic Cores and Rock Ore acceptable, or do you want others?
- Q2: Is moving the trend and warning into the base game fine, or should they stay behind a skill?
- Q3: Should a depleted cluster ever return (timer), or only through EV20?
- Q4: UNKNOWN: is the trade map 2D or 3D? Cluster rendering (T157) depends on it.
- Q5: Should ore be sellable at all three planets, or only at Voltara (a single buyer makes ore a decision about route length)?
