Game Design Document - Third Draft
Date: 16 October 2026

GIT: https://github.com/Veltrynox/star-bazaar/blob/main/gdd.md

========================================
1. EXECUTIVE SUMMARY / GAME SPECIFICITY
========================================

Oneliner: Star Bazaar is a single-player space trading game

Name: Star Bazaar
Genre: Space trading game
Engine: Godot 4 (GDScript)
Platforms: macOS

Core loop: Check prices, buy where a commodity is cheap, fly, sell where it is in
demand, and reinvest in ships and permits. Each new ship runs the same
loop as an automated route.

Win: 
  - The first company to reach X cr net worth wins. Net worth =
cash + 50% of ship purchase prices + cargo at base price. On day 30 the highest net worth wins
  - Note: X is a placeholder. The best value will be found during playtests.
 
Loss:
  - Cash stays below 0 for X in-game days in a row. Will determine the amount by balancing the settings. Purchases are blocked when unaffordable, so only upkeep can push cash negative, and the player is warned the moment it does.
  - A rival reaches X cr first.

========================================
2. GAME MECHANICS / PLAYER EXPERIENCE
========================================
The one rule: everything in the game is stock. Every planet holds a
stock of each commodity it trades, and the price is calculated from
that stock. The player, the rivals and the events all do only one
thing: they change stock. No other system sets a price.

The fun part: reading an event, spotting the price spike it causes,
and getting a ship there before the rivals drain the stock.

Content is data: planets, commodities, ships, rivals and events are
all rows in data tables or procedural generators. Adding more of them
costs no new code.

2.2 CORE LOOP

[Check prices] -> [Buy cheap] -> (fly) -> [Sell dear] -> [Reinvest in ships] -> back to Check prices (next trip)
 
    Buy cheap --(stock -)--> [ PLANET STOCK: price = f(stock) ] <--(stock +)-- Sell dear
    Events --(stock + recovery target)--> [ PLANET STOCK ] <--(trade)-- Rivals
 
[ PLANET STOCK ] --(reads)--> expectedProfit(ship, route)
    expectedProfit --> Route card
    expectedProfit --> Automated routes
    expectedProfit --> Rival route choice (picks routes)
 
Buying, selling, events and rivals all change planet stock, and price
comes only from stock. The route card, automated routes and rivals all
read the same expectedProfit function.

2.3 GALAXY, PLANETS AND PRICES
 
The galaxy is generated from a seed, and play happens inside one
system of 10 planets (planet count is a parameter).
 
Planets: each planet produces one commodity and consumes another, and
trades nothing else. The generator guarantees at least one profitable
pair between the two starting planets. The default seed reproduces the
v1 set:
 
  Planet    Produces        Consumes        Access
  --------  --------------  --------------  -------------
  Kessa     Energy          Food            Start
  Doran     Food            Energy          Start
  Vell      Technology      Food            Permit
  Ossa      Energy          Technology      Permit
  Marrow    Science         Energy          Permit
  Tiber     Food            Science         Permit
  Quill     Technology      Science         Permit
  Brask     Science         Technology      Permit
  Aurel     Luxury goods    Technology      Final permit
  Sable     Science         Luxury goods    Final permit

Commodities:
 
  Commodity             Base price (cr)   Reference stock
  ---------------------  ----------------  ---------------
  Food                   100               1,000
  Energy                 120               1,000
  Technology modules     300               500
  Science modules        400               500
  Luxury goods           1,000             150
 
The market panel shows buy price, sell price, stock and a trend arrow
for each commodity the planet trades.

2.4 SHIPS, AUTOMATED ROUTES AND UPKEEP
 
The player starts with one Light Hauler and 20,000 cr on Kessa and
Doran. More ships are bought at the Star Bazaar from day 8. A leg is
one flight between two planets.
 
  Class           Price(cr)  Hold  Leg time(days)  Fuel/leg(cr)  Upkeep/week(cr)
  --------------  ---------  ----  ---------------  ------------  ----------------
  Courier         15,000     20    0.25             100           1,500
  Light Hauler    25,000     50    0.5              300           3,000
  Bulk Freighter  60,000     200   1                1,000         8,000
 
Crew wages are included in upkeep. Each ship beyond the third adds 10%
to the whole fleet's weekly upkeep. Upkeep is charged once per week (7
in-game days).
 
Manual trade: select a ship, a buy planet, a commodity and a sell
planet. The ship flies, buys a full hold it can afford, flies, sells,
and docks.
 
Automated route: the same order, set to repeat, with a maximum buy
price. Before each loop the ship checks two things:
  - Is the buy price at or below the limit?
  - Can the company afford the load?
 
If both are yes, it flies the loop. If not, it waits docked and
re-checks every few in-game hours. A waiting ship still pays upkeep.
 
Route status: each automated route shows Running or Waiting, plus the
reason (price above limit, or not enough cash). The route card shows
expectedProfit: a full load at current prices, including the price
movement the load causes, minus fuel and the ship's share of upkeep.
An active event on either planet adds a warning icon.

2.5 EVENTS, RIVALS AND PERMITS
 
Events are generated from templates. Each event picks a planet, a
commodity it trades, a direction (shortage or surplus), a size
(30-50% price move) and a duration (3-7 days), then adds one line of
flavour text from a pool.
 
  - An event multiplies current stock and the daily recovery target by
    k for its duration. The price formula always uses the planet's
    fixed reference stock. When the event ends, the recovery target
    returns to reference and normal recovery applies.
    k = 1/(1+size)^2 for a shortage, 1/(1-size)^2 for a surplus.
  - Saturation, recovery and rivals therefore keep working during an
    event with no special cases.
  - Roughly one event every 2-3 days; the first is scripted on day 5
    to hit Kessa or Doran.
 
Rivals are the automated-route bot with a wallet. Each day, every idle
rival ship takes the route with the highest expectedProfit that it can
afford.
 
  - Both start with 20,000 cr and one ship, and start growing on day 8.
  - A rival buys a ship when cash covers its price + 1.5 weeks of
    upkeep + 5,000 cr, up to 5 ships.
  - A rival buys up to 4 survey permits.
  - Rivals buy from the same stock as the player, so they move the
    same prices.
 
Rival personality is parameters, not code:
 
  Rival                           Preferred ship              Event bonus                                      Personality
  ------------------------------  ---------------------------  ------------------------------------------------  --------------------------------
  Vexari Consortium               Courier                      High: weights routes touching an active event    Boastful alien hagglers
  Halvorsen-Krane Interstellar    Light Hauler, then Bulk Fr.   None: prefers long, stable routes                Cold megacorp, speaks in memos
 
Each rival has a portrait and about 10 lines triggered by key moments
(buys a ship, wins a contested market, falls behind).
 
Survey permits unlock one more planet each. The first costs 12,000 cr
and each next one costs x1.3: 12,000 / 15,600 / 20,280 / 26,364 /
34,273 / 44,555 cr. The luxury planets, Aurel and Sable, are the final
permit at 60,000 cr.

2.6 TIME, WIN AND LOSS
 
The game runs in pausable real time at pause, 1x and 2x. One in-game
day lasts 2 real minutes at 1x, so a 30-day campaign takes about an
hour. A hidden 10x speed exists for testing and balancing.
 
Win: the first company to reach X cr net worth wins. Net worth =
cash + 50% of ship purchase prices + cargo at base price.
 
Loss:
  - Cash stays below 0 for 3 in-game days in a row. Purchases are
    blocked when unaffordable, so only upkeep can push cash negative,
    and the player is warned the moment it does.
  - A rival reaches X cr first.
 
First minute: three hints guide the player: buy energy on Kessa, sell
it on Doran, buy a second ship. The Kessa-Doran trade is profitable
from the first tap.
 
HUD: cash, day and speed, plus the player's net worth beside both
rivals' as a race bar to X cr.

2.7 PLATFORMS AND CAMERA
 
macOS. Every screen is usable with mouse. The camera is a tilted top-down map with three zoom
levels (planet, system, galaxy) and +/-45 degree rotation on the
vertical axis.

2.10 Player experience
Day 5. A news line slides onto the HUD: *Food shortage on Doran.* The Doran food price arrow flips red, climbing past the normal band.

The player taps the market panel to confirm the spike, then opens Kessa's route card. It already reads +6,200 cr expected, a warning icon pulsing next to it — the price won't hold once a ship lands. No time to admire it: the player assigns the idle Light Hauler and sends it.

The Light Hauler docks a few in-game hours later. The card recalculates live: still green, just smaller than promised. The player sells anyway, banks the cr, and glances at the race bar — Vexari's net worth ticked up too.

Rival ships don’t appear on the galaxy map, and the player never watches a rival fly a route. Rivals act during the same tick the player’s automated routes resolve, off-screen, and their effect only surfaces afterward. Price and stock, after the fact. If a rival bought or sold on a planet since the player last checked, the market panel’s trend arrow and stock number simply reflect it — a price that was low an hour ago can read high now, with no animation or event tag explaining why. The player has to notice the shift themselves.

2.11 Screens

- **Market panel** — opens from any planet. Lists each commodity it trades with buy price, sell price, current stock, and a trend arrow. An active event on that planet shows its flavor-text line at the top.

- **Route card** — one per manual or automated route. Shows the ship assigned, the buy and sell planets, and live expectedProfit for a full load at current prices (net of fuel and the ship's upkeep share). Automated routes add a status line: Running, or Waiting with a reason (price above limit / insufficient cash). A warning icon appears if an event is active on either planet.

- **Fleet list** — every owned ship, its class, current route or idle status, and upkeep cost. This is where the player assigns an idle ship to a new manual trade or automated route.

- **HUD race bar** — always visible: cash, day, speed control, and a bar comparing the player's net worth against both rivals', all racing toward the X cr win line.

========================================
3. AI ARCHITECTURE
========================================
I'll find models and sounds myself in open libraries.

Agents:
Lead Designer
  Role: decides which proposed features survive by whether they create a story the player will repeat, cutting the rest before they cost build time.
  Input: feature proposal, the "fun part" sentence
  Output: decision (keep / cut), one-line reason
  Effect: keeps the game to features that create stories players
  repeat, instead of busywork
 
Producer
  Role: turns the GDD’s unlock schedule into an ordered, owned task queue so the second ship, first permit and first event land on the days promised.
  Input: task list, unlock schedule (day -> feature)
  Output: build_queue.json - ordered tasks, day, owner, status
  Effect: lands the second ship, first permit and first event on the
  days the GDD promises
 
Economy Designer
  Role: tunes prices, stock levels and thresholds so every trade stays profitable but never trivial from day 1 through day 30.
  Input: planet list, commodity list, ship/permit prices, last sim results
  Output: prices.json (base_price, reference_stock, role per
  planet-commodity), updated thresholds
  Effect: keeps every trade profitable but never trivial, from day 1
  through day 30
 
Rival AI Designer
  Role: encodes each rival’s ship preference, event bonus and growth pace as parameters, so Vexari and Halvorsen-Krane read as distinct traders on the map.
  Input: rival roster, ship classes, event list
  Output: rival_rules.json - per rival: preferred_ship, event_bonus,
  growth_thresholds, ship_cap
  Effect: gives Vexari and Halvorsen-Krane distinct, readable trading
  behavior on the map
 
Events Writer
  Role: turns the Economy Designer’s approved price-effect range into one-line event stories the player can act on.
  Input: approved price-effect range (from Economy Designer),
  planet/commodity list
  Output: events.json - planet, commodity, direction, size, duration,
  flavor_text (max ~40 words)
  Effect: turns every price spike into a one-line story the player
  remembers and can act on
 
UI Designer
  Role: maps the live route, ship and market data onto panel fields and status icons so the player can see why a ship is idle and fix it in one tap.
  Input: route/ship/market data shape, screen list
  Output: UI spec - panel_id -> field bindings, status_icon map
  Effect: lets the player see why a ship is idle and fix it in one tap
 
Galaxy Artist
  Role: bakes the seed into a lit, readable galaxy once at scene load, so producer planets, rival ships and events stand out at a glance.
  Input: seed, planet_count
  Output: galaxy_seed.json (seed, sun_indices, point_count, density-grid
  params); lighting/camera presets
  Effect: makes the galaxy read at a glance - producer planets, rival
  ships and events stand out
 
Gameplay Programmer
  Role: is the sole path from every agent’s JSON output into Godot scenes and scripts, making the live game match the balance the sim predicted.
  Input: prices.json, rival_rules.json, events.json, galaxy_seed.json
  Output: Godot scenes and scripts - markets, ships, routes, upkeep, win/loss,
  matching the sim
  Effect: makes the live economy behave exactly like the balance the
  sim predicted
 
Platform Engineer
  Role: configures the build and input mapping so the same game runs smoothly on both target platforms.
  Input: build_target macOS, frame_time_budget
  Output: platform build config, controller input map
  Effect: keeps the same game smooth on mouse
 
QA Tester
  Role: runs nightly bot playthroughs and flags broken or unwinnable runs before they reach a human playtester.
  Input: nightly build, bot script
  Output: bug_report.json - run_id, issue_type, severity
  Effect: keeps unwinnable or broken runs out of what the player ever
  sees
 
Per-agent weekly token budget, with model assigned per agent:

AGENT                    MODEL              TOKENS/WEEK   BASIS
Gameplay Programmer      Claude Sonnet 5    1,800,000     Re-reads full GDD, all four JSON files and the
                                                           current codebase each session; needs stronger
                                                           reasoning to turn data into correct Godot
                                                           systems, not just extraction - the 1M context
                                                           window covers the full reload
UI Designer              Claude Haiku 5.5     150,000     Full route/ship/market data shape plus screen
                                                           specs, each session
Galaxy Artist             Claude Haiku 5.5     100,000     Seed params, lighting/camera presets, iterative
                                                           art review
Platform Engineer         Claude Haiku 5.5      80,000     Build config and input map, checked weekly
                                                           against the current build
QA Tester                 Claude Haiku 5.5      55,000     ~7 nightly bot runs/week, one bug_report.json
                                                           each
Producer                  Claude Haiku 5.5      20,000     build_queue.json regenerated against updated
                                                           task list + unlock schedule
Economy Designer          Claude Haiku 5.5      15,000     ~6 reruns/week at ~2,500 tokens each
Rival AI Designer         Claude Haiku 5.5      15,000     rival_rules.json updates against current
                                                           roster/events
Events Writer             Claude Haiku 5.5      10,000     ~11 events/week at ~900 tokens each
Lead Designer              Claude Haiku 5.5       5,000     2-3 keep/cut reviews, short input/output
--------------------------------------------------------------------------------------------------
TOTAL                                        2,250,000     matches the GDD's weekly baseline

Asset Scraper (optional)  Claude Haiku 5.5     +40,000     only on weeks a missing asset is requested


Cost, recalculated with the mixed models (70/30 input/output split; Sonnet 5:
$2 / $10 per MTok input/output; Haiku 5.5: $0.10 / $0.50 per MTok, under-100K-
prompt tier):

                               TOKENS/WEEK   COST/WEEK
Gameplay Programmer (Sonnet 5)   1,800,000   ~$7.92
Other 9 agents (Haiku 5.5)         450,000   ~$0.10
--------------------------------------------------------
TOTAL                            2,250,000   ~$8.02/week

14-week semester: ~$112, or ~$179 with the 60% rework buffer.



========================================
4. PROMPT CONSTRAINTS
========================================

Every agent's prompt carries the same four global constraints, so
outputs stay consistent and repeatable whichever model runs it:
 
  1. Output only valid content matching that agent's current schema
     version - JSON for data-producing agents, no prose outside the
     schema's fields.
  2. Never invent a planet, commodity, ship class or rival name that
     isn't already in the GDD's data tables.
  3. Never write a number outside its defined range (event size
     30-50%, duration 3-7 days, permit multiplier x1.3, and so on).
  4. Never leave a required field empty or placeholder - a field the
     agent can't fill is a reason to flag the run, not to guess.
 
Per-agent constraints, on top of the global four:
 
  - Economy Designer: every price, cost or threshold change must come
    with a rerun of the 40-run sim and the five headline numbers (day
    of first permit, second ship, restricted/final permit, first win,
    rival win rate).
  - Events Writer: flavor_text <= 40 words, no real-world brands or
    politics, must name the affected planet and commodity by their
    canonical names, direction must be exactly "shortage" or
    "surplus".
  - Rival AI Designer: a rule change may not contradict an
    established personality - Vexari stays Courier-first and
    event-chasing, Halvorsen-Krane stays Light-Hauler-then-Bulk-
    Freighter.
  - Every screen spec must be fully usable with mouse alone, matching the macOS-only platform target
  - Galaxy Artist: may never require the density grid to recompute at runtime
    - generation happens once, at scene load, full stop.
 
A run that breaks any constraint fails schema validation and never
reaches Godot.

========================================
5. ENGINE INTEGRATION
========================================

Each JSON file has exactly one Godot node or Resource that owns reading it, so
a creative change (a new planet, a tuned price) has one clear
technical landing spot:
 
  File                Godot object                         When it's read
  -------------------  -----------------------------------  ---------------------------------------
  prices.json          Economy autoload (singleton), a Resource  Once, in _ready()
                        (one row per planet-commodity pair)
  events.json           Event Manager node                   Once at load, then ticked against the
                                                               in-game day count to fire events
  rival_rules.json      A Rival node per                     Once in _ready(); never re-read
                         rival, reading its own custom Resource    mid-run
  galaxy_seed.json      The scene's Galaxy Generator node    Once in _ready(), runs the
                                                               point-cloud/density-grid bake and never again
 
Validation sits at the boundary, not inside gameplay code: a file that
fails schema validation blocks the editor run with an error
naming the bad field, rather than reaching a script and failing at
runtime. This is what keeps a bad agent output from becoming a silent
in-game bug - it becomes a visible build-time error instead.
 
The Gameplay Programmer owns every reader above; no other agent's
output reaches Godot through any other path.

Galaxy generation: scatter a dense point cloud, bake a low-res 3D density grid
from it, pick the sun points, and propagate light from the suns
through the volume, dimmed by density. This runs once at scene
generation, so distant and occluded stars darken.

The one function: expectedProfit(ship, route) estimates what a full
load would earn on a route. The route card shows it, automated routes
use it to decide whether to fly, and rivals use it to choose their
routes. Write it once, use it three times.

Price rule (the only pricing logic):
 
  1. Role: producers price at 0.6x base, consumers at 1.4x base.
  2. Stock: multiply by (reference stock / current stock)^0.5,
     clamped to 0.5x-2x.
  3. Spread: buy = mid x 1.05, sell = mid x 0.95.
  4. Each unit bought removes one unit of stock; each unit sold adds
     one.
  5. Recovery: each day, stock closes 30% of the gap to its recovery
     target. The recovery target equals reference stock unless an
     event is active.

========================================
6. TECHNICAL STRATEGY
========================================


PILLAR 1: THE AI DEV PIPELINE
No agent writes directly into Godot: every agent's output is
translated into a fixed, versioned JSON schema, and only that JSON
crosses into the engine. A mismatched schema fails the build loudly
at load time instead of breaking the game silently.

PILLAR 2: TECHNICAL REQUIREMENTS & CONSTRAINTS
API rate limits stage the agents work instead of running it in
parallel, context window size caps how much of the GDD, sim and
codebase one session can safely hold before it needs a fresh, trimmed
brief, and processing latency means the Producer's unlock schedule
has to budget real wall-clock time per agent turn.

  - Rate limit: the Start tier allows 1,000 requests/min, 2M input
    tokens/min and 400K output tokens/min per model - the weekly
    2.25M-token budget sits far under every per-minute cap, so staging
    agents by dependency is about build order, not throughput.
  - Context window: Sonnet 5 has a 1M-token context window,
    so the full GDD, economy sim and current codebase fit in one
    session without pagination at this project's scope.
 
Sources:
  - Claude pricing: https://platform.claude.com/docs/en/about-claude/pricing
  - Claude models overview: https://platform.claude.com/docs/en/about-claude/models/overview
  - Claude API rate limits: https://platform.claude.com/docs/en/api/rate-limits

A fourth constraint is my own available time outside the course, which caps how many build iterations a week can realistically absorb.

Biggest technical constraint: AI hallucination — an agent confidently producing a planet, number, or field that doesn’t exist or doesn’t fit its range, which breaks the game silently if it reaches Godot unvalidated. Handled with schema validation at the one boundary every agent’s output crosses: a bad file fails loudly at load time and blocks the editor run, rather than shipping broken.

PILLAR 3: TOKEN BUDGETS & PROJECTIONS
At roughly 2.27M tokens/week across 10 agents, a
14-week semester costs about 32M tokens, or about 51M with a 60%
buffer for context reloads, failed builds and rework.

All agent output here is generated during the 14-week build and baked
into the JSON files above - the shipped game never calls the API at
runtime (see the AI Dev Pipeline), so this is a development-time
budget, not a per-player-session cost.
 
  - Per event generation (Events Writer): ~900 tokens
  - Per economy rerun (Economy Designer): ~2,500 tokens
  - Weekly total across the 10 core agents: ~2.25M tokens (Gameplay
    Programmer on Claude Sonnet 5, the other 9 on Claude Haiku 5.5 -
    see the per-agent table in Section 3)
  - Cost at mixed pricing (Sonnet 5: $2 / $10 per MTok input/output;
    Haiku 5.5: $0.10 / $0.50 per MTok, under-100K-prompt tier,
    70/30 input/output split): ~$8.02/week
  - 14-week semester: ~$112, or ~$179 with the 60% rework buffer
    (~51M tokens)
 
The agent roles, token budget and API constraints are fully specified
above; this section is what to actually do with them week to week.
 
  - Weekly budget check-in. Compare actual tokens spent against the
    ~2.27M/week baseline every Friday. A week that runs noticeably
    over is a signal to re-check Prompt Constraints first - a chatty
    or under-constrained agent is the most likely cause, not a
    cost-model surprise.
 
  - Schema changes are scheduled, not ad hoc. A prices.json,
    events.json, rival_rules.json or galaxy_seed.json version bump
    goes through the Producer, who confirms the Gameplay Programmer
    and every agent that writes that file are updated in the same
    work session - never a silent field rename.
 
  - Headroom, not a hard wall. At Start-tier rate limits (API
    Constraints, above), the semester's actual usage sits far under
    every per-minute cap, so the real constraint is staging by
    dependency, not throughput - revisit this only if the team moves
    to a higher-volume workflow than the current plan.
 
  - Cost is not the risk. At ~$112-$179 for the full semester, budget
    overrun isn't the failure mode to plan around; AI hallucination
    reaching Godot unvalidated is (Prompt Constraints -> Engine
    Integration's schema validation is the one line of defense).
 
