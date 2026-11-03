# Split control: two options (2026-11-03)

Status: waiting for owner. Nothing approved.

Problem: the split takes two buttons, then two blind clicks on the map. The player cannot see what is set, which lane is "first", or change it later.

Rules kept: share is fixed per lane; a split needs a ship on both lanes; the split only caps each lane's draw from the stock pile.

## Option A: Split bar on the storage row (drag or +/- steps)

Panel (storage row of Ore, two lanes with ships, to Vega and Kora):

    Ore  12/40
    [Split] Vega 60% |=======o====| 40% Kora     [-][+]
            (lane colours match the route rows below)

- A "Split" toggle appears on the row when two lanes with ships exist. Pressing it opens the bar at 50/50, both destinations named by default (the two lanes, no map clicks).
- Player drags the handle, or presses [-]/[+] (steps of 10%, set by economy-designer). Each end shows the destination name and percent. Unsplit = bar hidden, "Split" toggle off.
- If three or more lanes qualify, two small drop-downs pick the pair first.
- Route rows: each split lane shows a tag "Split 60%" in its lane colour. Hovering a tag highlights the partner lane and the bar.
- Desktop size: bar is about 260 px wide, fits the panel; text is readable at normal size.
- Cost: ui-programmer M (bar control, colours, tags); gameplay-programmer S (set_split already takes any share; remove begin_split/_on_split_click and the pending "split" state). No economy change.
- Risk: a free percentage invites micro-tuning every cycle; share values need a floor (economy-designer sets step and min). Panel gets taller.

## Option B: Split per route row (share shown on each lane)

Panel (route rows, each with a ship):

    Ore -> Vega   [x] Split   [-] 60% [+]
    Ore -> Kora   [x] Split   (auto 40%)  [lock]

- The player ticks "Split" on one lane; the panel offers its partner choices on that row only if another lane with a ship exists. Setting +/- on one lane sets the partner to the rest, shown live on both rows.
- Presets via a click on the percent: 25 / 50 / 75.
- Storage row only shows a small read-only note "Ore split: Vega 60 / Kora 40".
- Desktop size: fits inside existing route rows, no new widget; but numbers are small and the link between two rows is less visible than a single bar.
- Cost: ui-programmer S-M (checkbox, steppers, note); gameplay-programmer S (same cleanup).
- Risk: players edit the wrong row; the shared share is harder to see than one bar. Less "very interactive".

## Recommendation: Option A

One bar shows both destinations and both shares at once; dragging is the most obvious control. It removes the blind map clicks, so the split cannot be half-done. Add the lane-colour tags on the route rows from Option B for feedback.

## Questions for the owner
1. Free drag, or snap steps (10%, 25%)? Economy-designer sets the step and the min share.
2. Should the split stay if one lane loses its ship (today it falls back to all stock open)? Show a warning tag?
3. UNKNOWN: story-designer text for the toggle, tags and the missing-ship warning.
