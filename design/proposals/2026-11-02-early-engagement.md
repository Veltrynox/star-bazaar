# Early engagement: busy start, quiet finish (2026-11-02)

Owner question: what mechanic keeps the player busier at the start but matters less near the end?
Status: proposals only. Nothing approved. No numbers, text or code here.
Not repeated: saturation, full contracts, chains, route upgrade, tier text (see depth-and-interest, trade-mechanics, first-pass, simpler-trade-text). Proposal 2 is the early slice of the open contracts idea.

## What I found
- Start: 2100 cash, one ship, ship price 900, ship cap 5, 3 planets with 2 goods in system 1.
- First event slot is cycle 5 (event_interval 4, slots 5, 9, 13), and most events are plain price or closure notes with no choice. Cycles 1 to 4 have zero outside input.
- Skill points come from first visits, first pairs, first systems. These run out by about cycle 8, so cycles 1 to 10 are setup, then wait.
- A fixed-size reward fades by itself: income grows from a few hundred per cycle to several thousand, so a flat early bonus is large at cycle 3 and noise at cycle 20.

## Proposals (ranked by value against cost)

### 1. Early event front-load (events come sooner, then back to normal)
Problem: nothing happens in cycles 1 to 4, and later events are not shaped to teach.
Idea: for the first cycles, events fire more often than event_interval says, and the early pool is weighted to events with a choice (a few already exist, e.g. EV17, EV18, EV20) and to price events on system 1 lanes. The rate falls back to the normal interval by a set cycle.
Player decision: a price swing or a closure early forces "re-point my one ship now, or ride it out". A choice event asks "spend cash now or keep it for ship 2".
Curve: peak at cycles 1 to 8, normal by about cycle 12, so late play is unchanged.
Cost: gameplay-programmer S (a ramp on the interval in events.gd); economy-designer S (start length and early weights); story-designer S only if new choice texts are wanted. No UI.
Risk: pacing (a swing early can win or lose the run; test win cycle spread); too many pauses for a new player; an event at cycle 1 before the first route reads as noise.
QA: sim sweep of 100 seeds, decent median must stay 22 to 26; count pauses in cycles 1 to 10 (aim at a short, set number); first-play check that the first event does not hit before the first route notice.

### 2. Opening orders (small, optional delivery jobs, big early, none late)
Problem: with one ship and one lane there is nothing to choose between.
Idea: during the first cycles a planet posts a small optional delivery job (one good, one amount, a deadline, a cash premium). Accept or skip in the existing notification. The premium is a fixed amount, so it matters at cycle 3 and is trivial at cycle 20. Posting stops after a set cycle. Cash only; no skill points (money never buys skill points still holds, and a job pays no points).
Player decision: send the ship to the job lane or hold the steady lane; do I leave a Buy order running to have stock ready.
Curve: 1 job in play at a time, cycles 2 to about 14, none after. Needs no new currency or screen.
Cost: gameplay-programmer M (job state, deadline check, pay-out); ui-programmer S (notice buttons); story-designer S (job lines); economy-designer S (size, premium, window).
Risk: a premium too big makes it the dominant opening and pulls wins earlier than 22; deadline fails look like a punishment (missing must cost nothing); it overlaps full contracts, so the owner should treat it as the test for them.
QA: bots "always accept", "never accept", "decent"; win cycle may move by no more than a small, owner-set margin; a job missed must change nothing but the missed premium; a job after the stop cycle must not appear.

### 3. Lane debut bonus (first delivery on each new lane pays extra)
Problem: building the first lanes feels flat; points for first pairs arrive silently.
Idea: the first completed delivery on each new pair of planets pays a one-off cash bonus and shows it in the cash line. Lanes are finite in system 1, so the bonus ends by itself; system 2 adds a few more.
Player decision: open many cheap lanes early to collect, or deepen the one good lane. Fits "first pair" points already tracked in main.gd (pts_pairs).
Curve: most value in cycles 2 to 10, none once all pairs are used.
Cost: gameplay-programmer S (hook on the first-pair event); economy-designer S (amount); story-designer S (one line); ui-programmer S (one notice).
Risk: opening many lanes starves cash (route fixed costs are real; note v24: N routes x fixed cost starves buys), so the bonus must not push always_expand above the dominant line; first-cycle confusion if the bonus appears with no explanation.
QA: always_expand bot win rate must not rise above decent; check bonus is paid once per pair, not per ship, and not on load of a save.

## Recommendation
Try 1 first. It is the cheapest (S, no UI, one ramp), it needs no new rule, and it tests the question "do early decisions change the run" before any bigger build. If the pause count feels right but the choices feel thin, add 2 next, because it gives the player a real target. 3 is a good small add-on, not a main fix.

## Owner decisions needed
1. Is a shorter wait for the first event acceptable, given each early event can shift the win cycle?
2. Should Opening orders (2) become the first slice of full contracts, or stay separate?
3. May early jobs or bonuses pay cash only (no points)? I assume yes.

## Open questions (UNKNOWN)
- UNKNOWN: how many choice events can be shown before cycle 10 without repeats (event pool size, story-designer / economy-designer).
- UNKNOWN: the cycle at which early help should stop (about 15 to 20 is the owner's target; economy-designer to set).
