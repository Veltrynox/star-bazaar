# Endings (draft 3, T75: two sides, three tiers)

When cash meets the cash goal at the end of a cycle, the game shows the choice screen (CHOICE_* in screens.md). The player picks a side once: Release (the company leaves the Common Ledger, END_* and END_REL_*) or Corporation (the company stays on it, END_CORP_*). The run then ends with exactly one ending. The tension: escaped, or kept and needed. Loss is separate.

## Tiers (same logic on both sides)
Reward is only the quality of the text: no badge, no trophy, no extra item. Richer tiers are longer, specific, and end on an epilogue line.
- Bare: only system 1 reached AND no skill learned other than A1 (or none). Plain, short, generic, no named consequences. Max 350.
- Partial: anything between Bare and Full. Max 700. Names the dominant branch's mood, no places beyond the player's own company.
- Full: every open system reached (a first route or storage in each; the game already counts this for expansion points) AND at least one branch fully learned. Max 1000, names Voltara, Tillam and Ashgate, and has a separate epilogue line (id ending in _EPI, max 140). Key branch = the fully learned branch; two or more fully learned = the "whole" variant.
Note: systems 2 and 3 are on hold, so Full cannot be reached in the current build. The texts say "every system on the chart" and stay valid.
Note: Full texts do not name specific events. The game does not store which events were seen (see ideas.md 1).

## Inputs the game already knows
learned skill ids; count of learned skills per branch (L = Logistics, R = Research, E = Expansion); dominant branch (the branch with the strictly largest count; none if tied); cycle the goal was reached; final cash.
A1 counts as a normal learned skill in L. "the last cycle of the window" is the final cycle before the loss.

## Selection rule (first match wins)
## Release side, selection rule (first match wins)
| Order | Tier | Ending | Condition |
|---|---|---|---|
| 1 | Bare | END_BARE_HANDS | Bare condition (see Tiers). |
| 2 | Full | END_REL_FULL_X | Full condition AND two or more branches fully learned. |
| 3 | Full | END_REL_FULL_L / _R / _E | Full condition AND exactly one fully learned branch: Logistics / Research / Expansion. |
| 4 | Partial | END_LAST_LIGHT | Goal reached on the last cycle of the window. |
| 5 | Partial | END_COLD_LEDGER | Dominant branch is Research AND B4 learned. |
| 6 | Partial | END_OWN_HORIZON | Dominant branch is Expansion. |
| 7 | Partial | END_SLOW_HARBOR | Dominant branch is Logistics. |
| 8 | Partial | END_ENOUGH (default) | Anything else (ties, Research without B4, mixed paths). |
Every Release run gets exactly one. Bare first (clearest cautionary case); Full before the last-cycle mood so full play is always rewarded.
Optional: final cash shown as END_STAT_LINE on every win screen, not used for selection.

## Release endings (Bare max 350, Partial max 700, Full max 1000; shown on the end screen)

END_BARE_HANDS | Mood: plain, ironic | Name: The Cheapest Road | Bare, max 350
You did it the plain way: buy, sell, repeat. The Release came through stamped, and the Bureau did not look up. The planet is yours, uncounted and quiet. The Commons will list you as a clerical error. You can live with that. The door is open. Walk through it.

END_LAST_LIGHT | Mood: bittersweet | Name: The Last Light
The Plan was almost closed. In the final cycle the numbers lined up and the goal was met with nothing to spare. The clerk stamped your Release as the lights in the office went down for the night. You earned the planet, and the memory of every cycle you spent counting. Standing on it now you feel more relief than joy, then a little more joy than you expected. Some things only count when they nearly do not.

END_COLD_LEDGER | Mood: cold, unsettling | Name: The Quiet Ledger
You knew each price before it moved and each event before it arrived. The goal fell to you like a sum on a page, and the Release was a formality. The planet is yours, exact and silent. You look at the horizon and see a column of figures. It balances. It always balances. The Bureau has sent a kind letter, offering you a desk. You are not sure when you stopped being the one who escaped, and became the one who counts.

END_OWN_HORIZON | Mood: triumphant | Name: Own Horizon
You reached further than the rest, and it paid. Every permit, every beacon and every distant pair of planets added to the map until the map had a gap in it, and the gap was yours. The Release is filed. The planet sits at the edge of what anyone has charted, beyond the reach of any form. Behind you the company hums on without you, and the Plan does not know your name. Ahead, nothing at all, which is exactly what you came for.

END_SLOW_HARBOR | Mood: quiet, comforting, a little uneasy | Name: The Slow Harbor
You built a company that holds. Well-kept hulls, deep holds, goods moving on time. The cash goal came the way tides do. The Release came with a note: the Commons thanks you for your service and asks that the supply line stay open. You put down a small dock, a bench and a light on your own ground. A ship arrives every few days with exactly what you ordered. It is escape, mostly. You have never been anywhere you were so little in a hurry to leave.

END_ENOUGH | Mood: reflective, balanced | Name: Enough
You learned a little of everything and bet on nothing in particular. The goal came anyway, and with it the Release, and a planet no ledger has yet counted. Standing on it you notice the question the whole voyage was built to postpone: what is the amount that is enough? You have it now. You are not sure it was the amount you named at the start. The Commons would say enough is shared. The sky has no opinion. You sit down, and for a while decide not to count.

END_STAT_LINE | 110 | End screen, under the ending text (every win, both sides; shown before any _EPI line)
Goal reached in cycle {cycle} with {cash} credits.

## Release endings, Full tier (max 1000; epilogue max 140)

END_REL_FULL_L | Mood: warm, uneasy | Name: The Long Supply Line | Condition: Full, only Logistics fully learned
You built the lines first, and everything else stood on them. Deep holds at Voltara, Tillam and Ashgate, hulls that ran to time, and then the same pattern in every system on the chart. The goal came the way tides do. The Release was filed in order, and the Bureau, polite to the end, asked only that the supply stay open. You said it would. You put down a dock on your own ground, a bench and a light. A ship came in that evening with exactly what you had ordered, and the hold hummed like something asleep. Along the way you learned which shelf fills first at Tillam, which hull sulks at Ashgate, and how long Voltara can run on a full hold. None of it is written in any ledger. All of it is why the thing works. You have escaped. It is strange to be so well supplied by the thing you left.
END_REL_FULL_L_EPI | 140 | End screen, after the ending text
Every few days a ship arrives on time. You have stopped minding.

END_REL_FULL_R | Mood: cold, exact | Name: The Exact Distance | Condition: Full, only Research fully learned
You read the sky the way others read a form. Prices at Voltara, Tillam and Ashgate, and then at every market beyond, were known to you before they moved. The goal fell the way a sum falls. The Release was filed and returned by morning, stamped, and the planet is yours. Nothing there surprises you. You check the forecast from habit, and the habit finds nothing to forecast. You remember the first cycles, when a price rise was news and not arithmetic. You miss them a little. Nobody warned you that certainty is also a kind of quiet, and that the quiet has a hum of its own. That is the cost of knowing: the horizon arrives already counted. The Bureau's letter, offering you a desk, lies unopened on the table. You have not decided what that says about you.
END_REL_FULL_R_EPI | 140 | End screen, after the ending text
The letter stays unopened. The figures keep adding up anyway.

END_REL_FULL_E | Mood: triumphant, lonely | Name: The Far Edge | Condition: Full, only Expansion fully learned
Every permit, every beacon, every distant pair of planets: you charted them all, and the map ended where you wanted it to. The Release was filed from the last system anyone has a name for. The planet you bought lies beyond it, a pale rock under a patient sun, uncounted by any ledger. Behind you the company runs on, and the Plan does not know your name. Ahead there is one ridge. You put a light on it yourself. You remember Voltara as a small bright place with a loud reactor, and Tillam and Ashgate as the first two names you learned. They look very close from here, like pins on a table. You came a long way to be this alone, and you are exactly as alone as you hoped.
END_REL_FULL_E_EPI | 140 | End screen, after the ending text
Out here the sky is wider than the Plan. You leave the light on anyway.

END_REL_FULL_X | Mood: reflective, earned | Name: Everything Learned | Condition: Full, two or more branches fully learned
You learned more than one trade and kept every one. The lines ran, the forecasts held, the map grew past Ashgate and past the last beacon. The goal came when you were ready for it. The Release was filed without a single correction, which the clerk remarked on, politely, as unusual. The planet is yours, uncounted, with a dock, a window and a long view. Nothing in the company is a mystery to you. You could name every hold at Voltara, Tillam and Ashgate from memory, and every beacon after them. This is rarer than it sounds, and you earned it one cycle at a time. You know what enough is now, and it is not the amount you named at the start. You sit down. The sky has no opinion. For once you are glad of it.
END_REL_FULL_X_EPI | 140 | End screen, after the ending text
You count nothing tonight. The Commons will have to manage without you.

## Corporation path (the company stays on the Common Ledger)
Chosen with CHOICE_CORP. The company does not escape. Mood: the same dry humour, mirrored. The player becomes the thing the Commons feared, or the thing it quietly needs.

### Corporation side, selection rule (first match wins)
| Order | Tier | Ending | Condition |
|---|---|---|---|
| 1 | Bare | END_CORP_BARE | Bare condition (see Tiers). |
| 2 | Full | END_CORP_FULL_X | Full condition AND two or more branches fully learned. |
| 3 | Full | END_CORP_FULL_L / _R / _E | Full condition AND exactly one fully learned branch: Logistics / Research / Expansion. |
| 4 | Partial | END_CORP_LOGI | Dominant branch is Logistics. |
| 5 | Partial | END_CORP_RES | Dominant branch is Research. |
| 6 | Partial | END_CORP_EXP | Dominant branch is Expansion. |
| 7 | Partial | END_CORP_MIX (default) | Anything else (ties, mixed paths). |
Every Corporation run gets exactly one. Final cash and cycle are shown by END_STAT_LINE only. The last-cycle rule is not used here.

### Corporation endings (Bare max 350, Partial max 700, Full max 1000; epilogue max 140)

END_CORP_BARE | Mood: plain, dry | Name: The Same Desk | Bare, max 350
You stayed. The company stays on the Common Ledger, and the work goes on as before: buy, sell, repeat. The Bureau thanks you for your continued contribution. Nothing changes much, and that is the whole ending. The ships still run. The numbers still move. It is a living.

END_CORP_LOGI | Mood: quiet, needed | Name: The Steady Contract | Partial, dominant Logistics
You stayed, and the company became part of how the Commons eats. Your holds keep the shelves full and your ships keep the dock times. The Bureau enters you in the Common Ledger as a service, with a small line of thanks. Nobody forgets what you carry, and nobody thanks you twice. The goal is behind you. The work is still in front. It is a quiet kind of power. You are needed, which is a way of belonging the forms do not mention.

END_CORP_RES | Mood: cool, watchful | Name: The Useful Forecast | Partial, dominant Research
You stayed, and the company became what the Commons feared and, in quiet hours, consulted. You knew the prices before the Bureau did. Now the Bureau asks. A committee sits, a polite clerk takes notes, and your forecast becomes the Plan's. You are not in charge. You are only never wrong, which in a society that shares everything is the more awkward thing to be. The Common Ledger gives you a column of your own. It is the longest column.

END_CORP_EXP | Mood: expansive, wry | Name: The Wider Charter | Partial, dominant Expansion
You stayed, and the company kept growing. Permits, beacons and far routes made a map that now includes you. The Bureau drafts a new form to describe what you have become, and then a second form, because the first did not fit. You are a corporation: a small Commons of your own, with ships, holds and a long view. The sky is as large as it was. You have only built a bigger door into it.

END_CORP_MIX | Mood: dry, settled | Name: The Going Concern | Partial, default
You stayed, and the company carries on as a bit of everything: some lines, some forecasts, some reach. The Bureau enters it in the Common Ledger as a going concern, which sounds like a compliment and is a classification. The ships run. The accounts balance. The Commons neither fears you nor needs you very much, and that is its own sort of freedom. Tomorrow there is a cycle, and then another.

END_CORP_FULL_L | Mood: warm, load-bearing | Name: The Common Table | Full, only Logistics fully learned
You stayed, and the company grew into the thing the Commons lives on. Holds at Voltara, Tillam and Ashgate and in every system after them, ships on time, shelves full. When a harvest failed or a reactor sulked, your stock covered it, and no one wrote that down. The Bureau gave you a seat on the supply committee, and you arrived early. Nobody calls you a corporation now. They call you the line. Once, at Tillam, a clerk asked what you were for. You said you were not sure. The clerk wrote it down as an answer. You did not escape, and you were not absorbed. You are load-bearing. In the dark the holds hum, and the lights stay on in a great many kitchens.
END_CORP_FULL_L_EPI | 140 | End screen, after the ending text
A great many kitchens are warm tonight. None of them know your name. That is the job.

END_CORP_FULL_R | Mood: cold, quietly total | Name: The Unwritten Plan | Full, only Research fully learned
You stayed, and the company became the thing the Commons feared: a firm that is never surprised. You read Voltara, Tillam and Ashgate, and then every market beyond, and the forecasts came true so often that the Bureau stopped checking them. The next Plan was drafted from your figures. The one after was drafted by you, with the clerks taking notes. Voltara's reactors are scheduled by your numbers. Ashgate's harvests are sold by your numbers. Tillam's committee has stopped meeting on the days you are quiet. Nobody was forced. It was simply easier to ask. The Common Ledger lists the company as a corporation and the Plan as its client. In the cold the screens glow, and the numbers behind them are yours.
END_CORP_FULL_R_EPI | 140 | End screen, after the ending text
The next five-cycle plan arrives with your figures in it. No one remembers asking.

END_CORP_FULL_E | Mood: expansive, a little giddy | Name: The Second Commons | Full, only Expansion fully learned
You stayed, and the company walked outward until it had a sky of its own. Permits in every system, beacons on every ridge, routes across distances the Plan only drew in pencil. The Bureau has a form for a company this large. It is called a Commons. You are not quite one and not quite the other, and a few systems now call you when something breaks. At the far edge of the chart a light burns that you did not install. The ships you started with are the smallest thing on the books now. You keep one Skerrit in a bay, out of habit, with the lamp on. You did not build an escape. You built somewhere to escape to, with a ledger of your own.
END_CORP_FULL_E_EPI | 140 | End screen, after the ending text
At the far edge of the chart, someone files a form with your name at the top.

END_CORP_FULL_X | Mood: grand, ambiguous | Name: The Whole Machine | Full, two or more branches fully learned
You stayed, and the company is all of it: the holds, the forecasts, the reach. The lines run through Voltara, Tillam and Ashgate and out into every system on the chart. The Bureau is unsure whether to fear you or thank you, and has settled on a form that does both. You are the thing the Commons feared and the thing it quietly needs, and the two turn out to be one company. You began with a few hulls and an empty ledger on Voltara. Tillam and Ashgate were the whole world then. Now they are the first two lines on a very long page, and you know the page by heart. The ships come and go. The ledger is long. Outside the glass the hull creaks, as if turning over in its sleep, and goes on.
END_CORP_FULL_X_EPI | 140 | End screen, after the ending text
The Commons runs on you, and fears you, and files both under thanks.

## Recording ids
Every ending id above is stable and may be stored with the side chosen: side RELEASE for END_BARE_HANDS, END_LAST_LIGHT, END_COLD_LEDGER, END_OWN_HORIZON, END_SLOW_HARBOR, END_ENOUGH and END_REL_*; side CORP for END_CORP_*. The _EPI and _STAT ids are text only, never recorded.

## Loss ending (max 600)

END_LOSS | Mood: sober, gently absorbed | Name: The Plan Closes
The Plan closed before the goal was met. The Release was never filed. The Bureau is very kind about it. Your company is entered in the Common Ledger, your ships assigned to the common good, and your name given a quota that is fair and equal and exactly the size of everyone else's. No one is cruel. The sky is as large as it was, and it did not notice. A different company, a different run, might read the prices sooner. Count what you have. It is more than you started with, and less than you needed.

END_LOSS_STAT | 110 | End screen, under the loss text
Cash reached: {cash}. Cash goal: {goal}.

## End screen structure (T77s, both sides; the run ends here, play never continues)
Top to bottom, win screens (Release and Corporation use the same layout):
1. END_TITLE_REL or END_TITLE_CORP (heading, by side chosen).
2. Ending text (END_* for Release, END_CORP_* for Corporation, by tier).
3. Epilogue line (_EPI), Full tier only.
4. Sign-off: END_SIGN_REL or END_SIGN_CORP.
5. Stats block, four rows, label then value: END_STAT_CYCLES {cycle}, END_STAT_CASH {cash}, END_STAT_BRANCHES {branches}, END_STAT_SYSTEMS {systems}.
6. END_RUN_OVER (plain line, so the player knows play does not continue).
7. Buttons: END_BTN_NEW, END_BTN_MENU, END_BTN_QUIT.
Loss screen: END_LOSS, END_LOSS_STAT, END_RUN_OVER, buttons. No title block, no stats block, no sign-off.
Duplication: the stats block already shows cycle and credits. On win screens, do not also show END_STAT_LINE (kept only as a fallback). Values: {cycle} cycle the goal was met; {cash} final credits; {branches} number of branches with at least one skill learned; {systems} number of systems reached (the count the game already uses for expansion points). Show plain numbers.

END_TITLE_REL | 40 | End screen heading, Release side
The Release is filed

END_TITLE_CORP | 40 | End screen heading, Corporation side
Entered in the Common Ledger

END_SIGN_REL | 140 | End screen, after the ending text and any epilogue, Release side
The Bureau stamps the form and reaches for the next one. You are no longer on the ledger.

END_SIGN_CORP | 140 | End screen, after the ending text and any epilogue, Corporation side
The Bureau stamps the entry. The company stays on the ledger and the work goes on, somewhere past this page.

END_STAT_CYCLES | 24 | End screen stats label (value {cycle})
Cycles taken

END_STAT_CASH | 24 | End screen stats label (value {cash})
Final credits

END_STAT_BRANCHES | 24 | End screen stats label (value {branches})
Branches learned

END_STAT_SYSTEMS | 24 | End screen stats label (value {systems})
Systems reached

END_RUN_OVER | 110 | End screen, above the buttons, every ending including loss
This run is over. Start a new game or go to the main menu.

## End screen buttons
END_BTN_NEW | 24 | New game
END_BTN_MENU | 24 | Main menu
END_BTN_QUIT | 24 | Quit game

## Rescue notice (not an ending)
Uses NOT_DEAD_RESCUE in screens.md. The game continues.
