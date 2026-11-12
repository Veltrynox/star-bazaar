# Guiding the player to the Star Bazaar: analysis and proposal

Owner question 2026-11-12: at the Town stage the Star Bazaar panel says blasting powder is needed, but not where, how, or what to do next. Owner asks that the information is explained several times, that the Bazaar panel itself suggests what to do, and that the player is reminded, gently and constantly, of the next main-line goal.

Proposal only. Nothing is built until the owner approves.

## 1. What the game does today (verified in code)

The win path (gdd.md, game/bazaar.gd): a world at the capital tier can host the Bazaar; it is raised in stages; a stage completes at cycle end when three things hold at once:

1. the stage bill: a number of units of the run branch's goods of a given tier HELD IN THE CAPITAL'S OWN PLANET STORAGE (`bill_status` reads `storage.amount(planet_key(capital), good)`; Space Storage does not count);
2. the quorum: N other worlds at a tier;
3. from stage 3, one world in another system.

The owner's screenshots (Military branch, capital Voltara, stage 2 "Halls"): tier-2 bill met (Spyware / Rivets 40 / 40), quorum met (3 of 2 worlds at Outpost), tier-1 bill short: blasting powder 0 / 50. So the ONLY thing between the player and the next stage is 50 powder in Voltara's storage.

How powder gets there (data/goods.json planet_prices, tutorial text TUT_G2_BUY_WHY):
- Flintmoor (planet_4, same system) sells it at 12 cr; Voltara sells it at 30 cr; s2_p3 only buys it.
- A Buy order at Voltara fills Voltara's storage each cycle (30 cr a unit, no ship needed).
- Cheaper: Buy at Flintmoor (12 cr) and a Send to route Flintmoor -> Voltara.
- The route engine never sells bill stock to a world's need (`bill_need_of`), so once there it stays, unless the player has Sell on for powder at Voltara.

Where the bill is shown today: the Bazaar panel (BAZ_BILL_ROW "{amount} more {commodity}"), the always-visible Bazaar card in the right column (same row), the Next Up strip slot 2 (NEXTUP_BAZAAR_BILL "Bazaar: 50 more Blasting powder", click focuses the capital). Three places say WHAT is short; none says WHERE it must be held, WHERE to get it, or HOW. The capital's planet card shows nothing about the bill at all, and its Send-to prompt ("Send: blasting powder from Voltara, click a destination") even points the wrong way.

Explained once, and only once: TIP_FOUNDED ("Each stage needs goods in the capital's storage and other worlds at a tier") shows at founding; TIP_FOUNDED_WHY says "The Bazaar panel shows what is short". Nothing after that says how to meet it. The guided tutorial ends (TUT_G10_DONE) by opening the Bazaar panel once.

Town / Городок: Voltara's tier bar (Needs 25 / 32, Restless) is the prosperity ladder and is a separate system. It is NOT what blocks the stage here; the quorum is already met. Later stages do ask for worlds at higher tiers (stage 3: one world at tier 2; stage 4: two), so the ladder matters again then.

Root cause: the game states the goal as a number but never as an instruction, and it states it in the same three passive places every cycle. There is no "main line" voice that says "your next step is X, do it like this, here is the button".

## 2. Design principle: one main-line step, said in five voices

Keep ONE source of truth: `Bazaar.next_step()` returns the single current main-line step as data:
`{kind: "grow_capital" | "found" | "bill" | "quorum" | "reach" | "opening", planet, good, amount, source_planet, source_price, local_price, fed: bool}`.
`fed` = something already feeds the bill (a Buy order for that good at the capital, or a route delivering it there). Every surface below renders this one record, so the texts never disagree and nothing nags once the player has acted.

Steps and their instruction lines (all through StoryText ids, English only, Russian later by the Haiku agents):

| kind | line (fallback English) |
|---|---|
| grow_capital | Grow {planet} to {tier} to host the Bazaar: meet its needs every cycle. |
| found | {planet} can host the Bazaar. Open its card and press Found the Bazaar here. |
| bill | {stage} needs {amount} {good} held in {capital}'s storage. Buy it at {source} ({price} cr) and send it to {capital}, or Buy it at {capital} ({local} cr). |
| bill, fed | {stage}: {amount} {good} still to arrive at {capital}. Your Buy / route is on; wait for the cycles. |
| quorum | {stage} needs {n} more worlds at {tier}. Meet their needs each cycle: see Closest growth. |
| reach | {stage} needs a world in another system. Buy a permit (Skills) and establish a post there. |
| opening | The Opening: dock the Flagship with the charter cargo at {capital}. |

## 3. The surfaces (where it is said), in priority order

A. Bazaar panel (must). Under the title an always-visible paragraph BAZ_HOW: "The Bazaar is raised in stages. Each stage needs goods held in the capital's own storage, other worlds grown to a tier, and must finish before the term ends." Under each short bill row the instruction line from section 2 (muted, autowrap) and one button: "Buy at {source}" (opens the source world's card with that good's Buy button lit, as the tutorial lights buttons) and "Send to {capital}" (starts the existing Send-to flow with the capital preselected as the destination). When fed, the row says so and the buttons hide. Size S-M.

B. Capital planet card (must). A "Star Bazaar" block under the goods grid of the capital world only: stage name, the short bill rows with the instruction line, and a lit Buy button for the good when it is sold there. This is where the player already looks, and it fixes the Send-to prompt pointing the wrong way (the prompt stays, but the block above it says the opposite in plain words). Size S.

C. Bazaar card, right column (should). The bill row gets a second muted line "from {source}" and the whole card is clickable: opens the Bazaar panel (today it is display only). Size XS.

D. Next Up slot 2 (should). Keep the text; the click opens the Bazaar panel at the short row instead of only focusing the capital; the tooltip carries the instruction line. Size XS.

E. Main-line reminder, gentle (must). Two rules, no new UI:
- A notice at cycle end while a bill item is short and NOT fed, at most once every `bazaar_remind_cycles` (placeholder 4) cycles: the instruction line. Silent as soon as a Buy or route feeds the bill. Silent for quorum and reach steps unless nothing grew for `bazaar_remind_cycles` cycles.
- A one-time tip card TIP_BILL the first time a bill item is short after founding, with the instruction line and the source world named; and TIP_FOUNDED_WHY rewritten to say the how ("Goods go to the capital's storage: set Buy there, or send them from a cheaper world").
Size S. Numbers in balance.json.

F. Stage-done moment (should). The BAZ_STAGE_DONE banner and the wing popup end with the NEXT step's line ("Next: Towers needs 50 Rivets at Voltara, from Ashgate"), so the player leaves the celebration knowing what to do. Size XS.

G. Main-line card (later, owner to decide). A small persistent card where the tutorial card sits, titled "Main line", showing the current step line and its one button; collapsible to one line; reappears when the step changes. This is the strongest "guide gently through the game" tool but it is a new always-on UI element next to Next Up, so it is a separate decision. Size M.

## 4. What this does not change

No balance numbers (bills, quorums, prices) move. No new mechanics. The Bazaar rules stay as in gdd.md; only how they are explained changes. Russian text is not written here.

## 5. Suggested tasks (after approval)

- T361 gameplay-programmer: `Bazaar.next_step()` + `fed` detection + the reminder rule (E, notices) + balance key, headless tests.
- T362 ui-programmer: Bazaar panel (A), capital card block (B), card and Next Up clicks (C, D), stage-done line (F); story ids in story/screens.md, build_story.
- T363 (only if G is approved) ui-programmer: the Main line card.
- story-designer pass on the final wording of the seven lines (voice), after T362 shows them in place.

## 6. Open questions for the owner

1. Approve A, B, E as the must set? C, D, F are small and included unless vetoed.
2. G (persistent Main line card): yes, later, or no?
3. Reminder cadence: every 4 cycles while unfed (placeholder), or a different feel?
4. Should the capital's Send-to popup hide bill goods (so the player cannot send the bill away by accident), or just warn?
