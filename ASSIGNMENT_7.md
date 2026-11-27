# Assignment #7: Complete AI Dev Pipeline

## ▶ Play now: https://star-bazaar-beta.vercel.app

No install and no account needed.

1. Open the link in a desktop browser (Chrome, Edge, Firefox or Safari with WebGL 2). The first load downloads about 90 MB and takes 10 to 30 seconds.
2. On the main menu click **New Game**. Type a company name (or press **Random**), pick one of the four CEO portraits and press **Start**.
3. Read the short preface. The game then starts paused and a guided tutorial walks you through the first steps: pick a world, place a **Buy** order, **Send to...** another world, run a cycle.
4. Controls are mouse only. **P** pauses. The speed buttons (1x, 2x, 6x, 12x) set how fast cycles run.

Saves are kept in your browser.

---

## Student & game overview

| | |
|---|---|
| **Student name** | Ivan Larinin |
| **Capstone game title** | Star Bazaar |
| **Game concept brief** | A single-player space trading game made in Godot 4. You run a trading company, not a single freighter. Ships fly automated routes between worlds; you decide where to invest (routes, ships, workshops, permits for new solar systems, skills). Worlds you supply grow through Prosperity tiers. The goal is to found the Star Bazaar in a system's Space Storage, build it stage by stage and open it with a final charter delivery before the term ends. Three trading houses act as "weather" (floods, shortages, congestion), not rivals. |

## Deliverable 1: Playable link

**Playable game link:** https://star-bazaar-beta.vercel.app

The web build is a Godot 4.7.2 HTML5 export hosted on Vercel. Its source is the `web-build` branch, folder `web/`.

## Deliverable 2: Pipeline source code & engine integration

**Pipeline repository:** https://github.com/Veltrynox/star-bazaar

**Pipeline run video:** https://youtu.be/YBdCzB4Mqtw

### Integration breakdown

**Target game engine:** Godot 4.7 (GDScript), exported to WebGL 2 / WebAssembly for the browser.

**Automated flow description:**

The pipeline is a team of Claude Code role agents, each defined in `.claude/agents/*.md`: gameplay, UI, FX, juice and galaxy programmers, a story designer, an economy designer and a feature designer. Work is queued as tasks in `schedule.json`. Agents hand work to each other through files: `handoffs/`, `blackboard.md` and `design/proposals/`.

Agent output lands in the engine through fixed file formats, so nothing is reformatted by hand:

- **Story and UI text.** The story-designer agent writes plain Markdown blocks in `story/*.md` (`ID | max length | place`, then the text). `tools/build_story.py` is the only writer of `data/story_text.json`, `data/events.json` and `data/story_text_ru.json`. It checks for duplicate ids and length limits and stamps each file with a `generated` marker. The game loads these JSON files at runtime (`game/story_text.gd`, `game/events.gd`, `game/lang.gd`), so a new event or line shows up in the game with no code change.
- **Translation.** Haiku agents write `story/ru/*.json` (`{"ID": "text"}`) under `story/ru/GLOSSARY.md`. The same build step merges them into `data/story_text_ru.json`, and the in-game language switch picks them up.
- **Game data.** The economy-designer agent edits `data/*.json` (balance, goods, ships, skills, chains, gigs). Game code reads numbers only from these files. The design document `gdd.md` holds no numbers.
- **Code.** Programmer agents write GDScript in `game/` directly. A commit hook (`tools/gdd_sync.py`) blocks any commit that changes `game/`, `data/` or `story/` without updating `gdd.md`, so the design document stays in step with the build.
- **Generated art and audio.** Tool scripts produce engine-ready files: texture atlases (`tools/make_*_atlas.gd`, run in headless Godot), planet textures (`tools/planet_texture_gen.gd`), icons and UI (`tools/make_icons.py`, `tools/make_skill_icons.py`, `tools/make_ui.py`) and the looping space ambience (`tools/make_ambient.py`). Godot imports them like any other asset.
- **Unattended runs.** `tools/orchestrator.py run` picks ready tasks from `schedule.json`, starts one headless `claude -p "/overnight-worker <id>"` per task in its own git worktree, then rebases, runs the test suite and fast-forward merges each finished task. It records the result on `blackboard.md`. Rebase conflicts go to a `merge-resolver` agent.
- **Build.** A headless Godot export (`--export-release "Web" web/index.html`) produces the browser build, and `vercel --prod` publishes it.

## Deliverable 3: Pipeline audit & cost analysis

### Pipeline production & functionality

**What did the pipeline produce?** Everything below is in the playable build.

- **Text:** 3,172 English text ids in `data/story_text.json` and 2,961 Russian ones in `data/story_text_ru.json`. They cover event titles and bodies, choice buttons and effect lines, gig stories, endings, skill names and descriptions, the tutorial, tips and all UI labels.
- **Narrative content:** 25 base events plus 63 new chain events and 40 chain steps (`data/chains.json`), 7 gigs (story missions, `data/gigs.json`), a 70-node skill tree (`data/skills.json`), and end-of-run scenes told as a story (`game/end_story.gd`, ending scene kits in `story/endings.md`).
- **Economy:** 22 goods and 5 workshops (`data/goods.json`), plus the balance tables for prices, upkeep, Prosperity growth and the Star Bazaar stage bills (`data/balance.json`, `data/prosperity.json`, `data/bazaar.json`).
- **Game code:** 89 GDScript files with about 32,000 lines in `game/`. They cover the trading loop, automated routes, Prosperity, the Star Bazaar, events, the tutorial, the UI panels, planet shaders and FX, and juice animations.
- **Generated assets:** planet surface banner, portrait and skill icon atlases, UI icons and the space ambience audio track.
- **Process output:** 264 scheduled tasks, 261 of them done. Over the course there were 1,014 commits, and 84 tasks went through the unattended orchestrator (73 merged automatically, 11 blocked for a human).

**What manual steps remain?**

1. **Owner approval of designs.** By project rule, design and proposal tasks produce a proposal only. The owner approves it before any agent builds it.
2. **Visual review.** The owner looks at every visual result in the running game. Agents only take a single screenshot for objective breakage, such as a blank or clipped screen.
3. **QA and balance runs are started by hand.** The QA bots (`qa/check`) and the economy designer's retunes are started only by the owner.
4. **Blocked merges.** 11 of the 84 orchestrator tasks stopped on a test failure or a rebase conflict the resolver could not settle, and needed a human.
5. **Release.** Committing, pushing, the web export and the Vercel deploy are still started by hand.

**What would it take to eliminate them?**

- **Approvals and visual review:** a scored acceptance gate in place of a person. For example, an evaluator agent with a written rubric plus screenshot diff checks against approved reference images. The owner would sample results instead of reviewing every one.
- **QA and balance:** run `qa/check` in CI on every merge to `main`, with fixed thresholds for win time, dominant strategy and softlocks. A threshold breach would open a task for the economy designer automatically.
- **Blocked merges:** smaller tasks with non-overlapping `touches` globs, and a retry loop that rebuilds the task on fresh `main` before handing it to a human.
- **Release:** a CI job (for example GitHub Actions with Godot headless) that exports the web build and deploys it to Vercel on every push to `main`.

### Architectural reflection

**Current architectural decision to change:** most work ran from one long-lived interactive main session on a large model. That session read files, briefed role agents, checked their output and committed. Its context grew for hours and was rewritten into the prompt cache again and again. Interactive sessions and the subagents they started cost $799 of the $841 total (95%). The unattended orchestrator workers did 84 tasks for $41.78, about $0.50 per task.

**Specific alternative:** make the orchestrator the default path, not the exception.

- `schedule.json` becomes the only way work enters the pipeline.
- `tools/orchestrator.py` starts a fresh, short-lived headless worker per task on Sonnet (Haiku for translation and text checks), with only that task's brief and the files its `touches` globs name.
- The interactive session is kept for owner conversations and for writing task briefs. It never does the build work itself.
- Each worker ends with a structured result line and a handoff file, so no session needs a growing context.

### Cost analysis

How the cost was measured: from the token counts in every Claude Code session log of this project (27,674 model calls, 2026-10-24 to 2026-11-25), priced at Anthropic API list rates per model. Input, output, cache writes and cache reads are each priced at their own rate. Work done in Codex (some Russian drafts and the text style-agent run) is not included.

| | |
|---|---|
| **Out-of-pocket cost** | **$200.** Claude subscription, paid per year. It covered all the usage below. |
| **Total actual run cost (API-equivalent)** | **$841.07** for the whole project (about $26 per day over 32 days). |
| By model | Sonnet 5.5 $433.35 · Opus 5.5 $260.33 · Fable 5.1 $84.17 · Fable 5.2 $49.90 · Haiku 5.5 $13.32 |
| By kind of token | cache writes ≈ $333 (40%) · cache reads ≈ $282 (34%) · output ≈ $225 (27%) |
| By part of the pipeline | interactive main sessions $480.85 · role agents started from them $318.46 · orchestrator workers $41.78 |

**Most expensive pipeline step:** the interactive main session that orchestrated agents cost $480.85 (57%). Most of that was re-sending and re-caching its long context, not producing output. Among the role agents, the **gameplay-programmer** cost the most: $109.81 over 248 runs on Sonnet 5.5. The ui-programmer ($46.57) and the story-designer ($41.04) came next.

**Solo/small-team sustainability:** **yes, on a subscription.** A $200 flat fee covered work that would have cost $841 at API rates. That's about 260 finished tasks and a playable game in about a month. On pay-as-you-go API billing, about $800 a month is still affordable for a small team. But 95% of it went to the expensive interactive style of work. The orchestrator path cost about $0.50 per task, and the Haiku translation path cost a few cents per batch. Moving the build work to short headless workers (see Architectural reflection) would bring the API cost down to the low hundreds per month.

### Mid-project cost-reduction change

On 2026-11-09 the owner made a rule: all translation is done by agents on the Haiku model, each working from one shared brief and glossary. Before that, translation ran on the story-designer agent with Sonnet. The same job, translating the four market event chains (Military, Luxury, Minerals, Biotech) into Russian, was run both ways.

| | Before (2026-11-04) | After (2026-11-14) |
|---|---|---|
| **Strategy / prompting approach** | One Sonnet 5.5 story-designer agent per chain (4 runs). Each run re-read `CLAUDE.md`, `story/voice.md` and the full glossary before translating. | Haiku 5.5 agents, two chains per run (2 runs), with one hand-written-translation brief plus `story/ru/GLOSSARY.md`. Scripts may only look things up, never write text. |
| **Output tokens** | 71,431 | 72,089 (same amount of text) |
| **Token / API cost** | **$1.205** | **$0.074** (−94%) |

Across the whole Russian localisation, the 2026-11-10 pass used 25 Haiku agents (translate, repair and verify chunks) for $0.84 in total, each costing under $0.07. Each Sonnet group run it replaced cost $0.31 to $0.61.
