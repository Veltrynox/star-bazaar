# Production boost (proposal, waits for the owner)

2026-11-12, feature-designer. Status: PROPOSAL, nothing built.

## 1. What the boost does

"Production" here means the Buy order amount. Planet stock never grows (route_engine.gd: stock changes only through orders and routes), so what a world produces for the player is what a Buy order takes there each cycle, `local_amount()`. It also caps every lane out of that world (`lane_full` feed), so the player feels it. Other readings do not fit: `stock_growth_pct` grows company stock, workshop batches belong to a workshop, dead-world mining is a finite stock.

Boost: at one world, every Buy order takes `order_amount x (1 + boost_order_pct)` a cycle, until the end of the run (Continue included), saved. Sell orders are unchanged; order-size skills multiply on top.
- New key `boost_order_pct`, suggested placeholder 0.5 (PLACEHOLDER).
- Planet storage room still caps a Buy; a boosted world with no lane draining it fills fast (see question 3).
- Its `lane_full` feed uses the boosted amount, so one more ship on its lane is worth buying.

## 2. The button

- Where: planet card, right under the goods grid (BuyGrid), above the Bazaar and growth blocks: it changes the Buy rows above it.
- Text: "Boost production". Tooltip: "Spend your charter here. Every Buy order at {planet} takes more each cycle, for the rest of the run. One charter, one world."
- Click: a confirm window (it is final). Title: "Boost {planet}?". Body: "This cannot be moved or undone." Buttons: Boost / Cancel.
- Shows when: an unused charge is held; the world has a trading post (living or reclaimed, never a platform); it is open; it is not boosted yet; it sells at least one visible good.
- After use: the charge is spent and the button disappears from every card. The world keeps a small "Boosted" tag by its name (tooltip: "Buy orders here take more each cycle, for the rest of the run.").
- Stacking: recommended yes. One charge per source, one world per charge, one boost per world. A run has one branch, so at most two charges (branch source plus gig): still earned.

## 3. Sources of a charge

The run sees only its own branch's source, plus the gig.

### Skills: Minerals and Biotech
The making branches: Minerals is yield and stock, Biotech is growth. "Make a world give more" is already their verb.
- Minerals: replace MIN_13 Core Tuning (tier 4 of 6, cost 3, prereq MIN_5 at tier 3, a leaf). It only helps a Null Core ship, rare in play.
- Biotech: replace BIO_12 Patient Orchard (tier 4 of 6, cost 3, prereq BIO_5 at tier 3, a leaf). It repeats BIO_2's stock growth.
- Both are mid-tree, off the tech spine, with no dependants; replacing keeps node counts and the skill-screen layout. Same id, new name, icon and effect type `boost_charge` (target `feature`, learning grants one charge).
- Alternative: add MIN_16 / BIO_16 at tier 4, same prereqs (layout change, new icons).

### Events: Military and Luxury
Orders and favours: the charge is a deal offered, not research. Once-only pool choice events, visible_when `{"all": ["branch_is:mil", "any_tier:2"]}` (lux for EV98).

EV97 The depot wants a yard [Military]
Body: "The Bureau's depot office will name one of your worlds a supply yard. Yard stamps buy more per shift, and the stamp costs. The clerk has the form filled in except for the world. He taps the blank line and waits."
- Sign the requisition: gain the charter, pay a fee (`boost_event_fee`, a negative cash key).
- Let the form lapse: gain a small sum (`event_cash_gain_small`).

EV98 A patron picks a house [Luxury]
Body: "A patron wants one world to carry her name, and every buyer there to stock for her. She pays nothing. She asks only that her rivals be told. Somewhere a broker is already drafting the list."
- Accept the patronage: gain the charter. The patron's rivals sell low: one of your Luxury goods at your home world costs less and pays less for a while (existing price_pct down).
- Decline politely: gain a small sum.

A choice with a gain and a cost needs an `extra` effects list on event choices (gameplay-programmer, S). Draw risk: recommend forcing the event as the next one if not drawn `boost_event_due_cycles` after it is eligible.

### The gig for everyone: GIG03 The quota drum replaces its lot reward
GIG03 is a drum "stamped with a five-cycle plan nobody finished": a production quota is already its story. Its option A gives the generic branch goods lot that GIG01, 02 and 04 also give. Change:
- Option A "Take up the quota": gives `boost_charge`. It costs Flagship idle time, long (it was short), because it is worth more.
- Option B "Copy the ledger": unchanged, a small sum.
- Story-designer rewrites ARRIVE, A_BTN and the four A_OUT lines: the quota is signed over to one of your worlds.
- Once per run; if it expires the charge is gone. Suggest its own weight key `gig_weight_boost` (placeholder) so most runs see it.

## 4. Save, atoms, availability, text, tests

- Save: `run.boost = {"grants": ["skill:MIN_13" | "event:EV97" | "gig:GIG03" ...], "planets": [planet ids]}`; charges = grants minus planets. Old save: no key, nothing granted.
- New atoms in game/conditions.gd: `boost_charge` (true while a charge is unused) and `boost_used:<planet>` (true once that world is boosted).
- Availability (data/availability.json): `{"kind": "feature", "id": "production_boost", "visible_when": {"any": ["boost_charge", "boost_used_any"]}}`. Or drop `boost_used_any` and keep the tag outside the rule.
- Text ids (story_text via story/*.md): PB_BTN, PB_TIP, PB_CONFIRM_TITLE, PB_CONFIRM_BODY, PB_CONFIRM_OK, PB_TAG, PB_TAG_TIP, PB_NOTICE_GAINED ("You hold a production charter. Open a world's card to spend it."), PB_NOTICE_USED. Also SK_MIN_13_* and SK_BIO_12_* (name, flavour, plain), EV97_* and EV98_* (full choice set), and the GIG03 rewrites.
- Tests (run only when the owner asks): boosted local_amount at that world only; each source grants one charge; using it hides the button on every card; two charges boost two worlds, never one world twice; dead, closed or unposted worlds never show it; save round trip and old save; both atoms; availability start state hides it; data lint accepts `boost_charge` in skills, events and gigs.

## 5. Build split

1. story-designer (S): two skill nodes, EV97 and EV98, the GIG03 rewrite, PB_* strings.
2. gameplay-programmer (M): boost state, save, atoms, `boost_charge` effect in skills, event choices and gigs, `extra` choice effects, forced event draw, the data rows (skills.json, chains.json pool_new, gigs.json, availability.json), placeholder keys marked PLACEHOLDER, tests.
3. ui-programmer (S): button, confirm window, Boosted tag, boosted amount in the Buy rows, notice. Depends on 2.
4. juice-programmer (S, optional): a short pulse on the planet when it is boosted.
5. doc-manager (S): gdd.md (mechanics and gigs) and gdd-skills.md (MIN_13 and BIO_12).
The economy-designer tunes the placeholders only when the owner calls them.

## Open questions for the owner

1. Replace MIN_13 and BIO_12, or add new tier-4 nodes?
2. Should charges stack (recommended: yes, one world per charge)?
3. Is a Buy-order boost the meaning you want, or should the boost also raise that world's storage room?
4. Should the boost gig and events be near-guaranteed (forced draw, own weight), or left to chance?
