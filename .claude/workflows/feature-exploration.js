export const meta = {
  name: 'feature-exploration',
  description: 'Design council for Star Bazaar: 3 improvements and 3 new trade mechanics, reviewed by feature, economy and story designers. Only ideas all three agree on are built, on branch new-features-test.',
  phases: ['Propose', 'Review', 'Revise', 'Vote', 'Build', 'Test', 'Finish'],
}

const ROOT = '/Volumes/Work/Gamedev/Projects/AgentCourse/star-bazaar'
const GOAL = 'goals/feature-exploration-2026-11-02'
const COUNCIL = `${GOAL}/council.json`
const BOARD = `${GOAL}/blackboard.json`
const BRANCH = 'new-features-test'

const COMMON = `Project: Star Bazaar (Godot 4), at ${ROOT}. First read ${COUNCIL}: its rules and test checklist. Append entries only, and never edit or delete another agent's entry. Each entry needs id, agent, date "2026-11-02", kind, and a one-sentence text. Do not commit or push.`

const proposalSchema = {
  type: 'object',
  required: ['proposals'],
  properties: {
    proposals: {
      type: 'array',
      items: {
        type: 'object',
        required: ['id', 'tag', 'title', 'text', 'owner_agent', 'size'],
        properties: {
          id: { type: 'string' },
          tag: { type: 'string', enum: ['IMPROVE', 'NEW'] },
          title: { type: 'string' },
          text: { type: 'string' },
          owner_agent: { type: 'string' },
          size: { type: 'string', enum: ['S', 'M', 'L'] },
          needs_new_keys: { type: 'string' },
          needs_text: { type: 'string' },
        },
      },
    },
  },
}

const voteSchema = {
  type: 'object',
  required: ['votes'],
  properties: {
    votes: {
      type: 'array',
      items: {
        type: 'object',
        required: ['id', 'vote', 'reason'],
        properties: {
          id: { type: 'string' },
          vote: { type: 'string', enum: ['agree', 'agree-with-change', 'disagree'] },
          reason: { type: 'string' },
          change: { type: 'string' },
        },
      },
    },
  },
}

const buildSchema = {
  type: 'object',
  required: ['id', 'status', 'files', 'tests'],
  properties: {
    id: { type: 'string' },
    status: { type: 'string', enum: ['done', 'partial', 'blocked', 'needs-owner'] },
    files: { type: 'array', items: { type: 'string' } },
    tests: { type: 'string' },
  },
}

const qaSchema = {
  type: 'object',
  required: ['passed', 'failed', 'notes'],
  properties: {
    passed: { type: 'integer' },
    failed: { type: 'integer' },
    notes: { type: 'string' },
  },
}

// Round-1 IMPROVE ideas the council already accepted (see council.json: P1, P2 with AM-P2). P3 (buy order sizes) was dropped by the owner.
// They go straight to the final vote with their amended text; they are not re-proposed.
const CARRIED = [
  {
    id: 'P1', tag: 'IMPROVE', owner_agent: 'ui-programmer', size: 'S',
    title: 'Price rows show the event and when it ends',
    text: 'A planet row whose price is moved by an event shows an arrow and the number of cycles left, and the Send to... picker shows each destination\'s margin now and after the event ends.',
  },
  {
    id: 'P2', tag: 'IMPROVE', owner_agent: 'gameplay-programmer', size: 'M',
    title: 'Closed planet offers an optional reroute',
    text: 'When an event closes a planet, the blocked route row shows an optional \'Move ship\' button with the line \'Best open route: +N per cycle\' (N live and net of the ship\'s travel_cycles_per_leg idle cycles in transit, \'Setup lost\' shown only if a setup is really lost); it never moves a ship automatically.',
  },
]

// Status of every idea decided so far, so the proposer does not repeat or re-agree them. Keep this current after each run.
const PRIOR = `Already decided, do not propose again or re-agree these:
- Built: P1 (price event rows, partial), P2 (closed planet reroute), N2 (route split).
- Approved and being built: N5 (salvage sale for stuck stock).
- Waiting for owner balance approval: N4 (pay on sale premium).
- Rejected by owner: P3 (buy order size steps), N6 (price lock fee at Buy).
- Not agreed by all three: N1 and N3.
- Rejected in round 1: P4 (supplier standing), P5 (route insurance), P6 (bulk hauler ship class).
Use ids that do not already appear in council.json (the next free N number).`

// Optional focus from the caller (Workflow args: {focus: "..."}). When set, it replaces the default trade-mechanics brief.
const FOCUS = (args && typeof args === 'object' && args.focus) ? args.focus : ''

// Version stamp: every run logs this first, so a run on an old copy is visible in the log.
const SCRIPT_VERSION = 'sonnet, focus argument, prior-decisions list (2026-11-03)'
log(`feature-exploration ${SCRIPT_VERSION}; model sonnet on every agent`)

// ---- Propose -------------------------------------------------------------
phase('Propose')
const proposed = await agent(
  `You are the Feature Designer. Follow .claude/agents/feature-designer.md. ${COMMON}
${PRIOR}
${FOCUS || 'Propose three NEW ideas, tag NEW: added trade mechanics that give the player a new decision inside buy, optional send and sell.'} Each must not take a choice away from the main loop, force a new step, or depend on system 3. Do not repeat anything in design/proposals/ or anything listed above. Read the reviews in council.json first and avoid their failure reasons: a steady single supplier dominates, a near-mandatory cash sink, a second hull that blurs the shipyard. Append each as kind "proposal" with its tag, player choice, main-loop effect, risk, owner agent, size, and whether it needs new balance keys or new text. Return the three in the schema.`,
  { label: 'propose', schema: proposalSchema, model: 'sonnet' },
)
const ideas = proposed?.proposals ?? []
if (ideas.length === 0) throw new Error('Feature designer returned no NEW proposals; stopping before review.')
const ideaList = ideas.map(p => `${p.id} (${p.tag}) ${p.title}: ${p.text}`).join('\n')

// ---- Review (parallel) ---------------------------------------------------
phase('Review')
// Run one after another, not in parallel: each agent appends to council.json,
// so parallel writes would overwrite each other or corrupt the JSON.
const econ = await agent(
    `You are the Economy Designer. Follow .claude/agents/economy-designer.md. ${COMMON}
Review each proposal:\n${ideaList}
Do not change data/balance.json or any game code. For each, append a kind "review" entry R-E<n> with a vote (agree, agree-with-change or disagree). For agree-with-change, also append an amend entry A-E<n> with the exact change. Return the votes in the schema. Say which proposals need new balance keys and whether they would move the win cycle.`,
    { label: 'economy-review', schema: voteSchema, model: 'sonnet' },
)
const story = await agent(
    `You are the Story Designer. Follow .claude/agents/story-designer.md. ${COMMON}
Review each proposal:\n${ideaList}
Judge whether each enriches the game in story terms and keeps the main loop clear. Give a one-line draft for any text it needs. Do not change game code or balance. For each, append a kind "review" entry R-S<n> with a vote (agree, agree-with-change or disagree). For agree-with-change, also append an amend entry A-S<n> with the exact change. Return the votes in the schema.`,
    { label: 'story-review', schema: voteSchema, model: 'sonnet' },
)

// ---- Revise (only when someone asked for a change or disagreed) -----------
phase('Revise')
const requests = [...(econ?.votes ?? []), ...(story?.votes ?? [])].filter(v => v.vote !== 'agree')
let finalIdeas = ideas
if (requests.length > 0) {
  const revised = await agent(
    `You are the Feature Designer. Follow .claude/agents/feature-designer.md. ${COMMON}
Answer each review request below. Append a kind "response" entry RS-<id> with accept or decline and a one-sentence reason. For each accepted change, append an amended entry AM-<id> with the final text. Where a designer disagreed and you cannot answer the objection, decline it and say why. Return the final list of proposals in the schema, using the final text.
Requests:\n${JSON.stringify(requests)}`,
    { label: 'revise', schema: proposalSchema, model: 'sonnet' },
  )
  if (revised?.proposals?.length) finalIdeas = revised.proposals
}

// ---- Vote (final, all three) ----------------------------------------------
phase('Vote')
const allIdeas = [...CARRIED, ...finalIdeas]
const finalList = allIdeas.map(p => `${p.id} (${p.tag}) ${p.title}: ${p.text}`).join('\n')
// Sequential, for the same reason as Review: each agent appends to council.json.
const fVotes = await agent(
    `You are the Feature Designer. ${COMMON}
Final vote on the revised proposals:\n${finalList}
Append a kind "vote" entry per proposal (V-F-<id>) and return the votes in the schema. "agree" means you accept the idea exactly as written.`,
    { label: 'final-feature-vote', schema: voteSchema, model: 'sonnet' },
)
const eVotes = await agent(
    `You are the Economy Designer. Follow .claude/agents/economy-designer.md. ${COMMON}
Final vote on the revised proposals:\n${finalList}
Append a kind "vote" entry per proposal (V-E-<id>) and return the votes in the schema. "agree" means you accept the idea exactly as written.`,
    { label: 'final-economy-vote', schema: voteSchema, model: 'sonnet' },
)
const sVotes = await agent(
    `You are the Story Designer. Follow .claude/agents/story-designer.md. ${COMMON}
Final vote on the revised proposals:\n${finalList}
Append a kind "vote" entry per proposal (V-S-<id>) and return the votes in the schema. "agree" means you accept the idea exactly as written.`,
    { label: 'final-story-vote', schema: voteSchema, model: 'sonnet' },
)

const agreed = allIdeas.filter(p =>
  [fVotes, eVotes, sVotes].every(r => r?.votes?.find(v => v.id === p.id)?.vote === 'agree'),
)
const notAgreed = allIdeas.filter(p => !agreed.includes(p)).map(p => p.id)
log(`Agreed by all three: ${agreed.map(p => p.id).join(', ') || 'none'}. Not built: ${notAgreed.join(', ') || 'none'}.`)

// ---- Build (agreed ideas only, one at a time to avoid edit conflicts) ----
phase('Build')
const built = []
for (const p of agreed) {
  const r = await agent(
    `You are the ${p.owner_agent} agent. Follow .claude/agents/${p.owner_agent}.md. ${COMMON}
Build council idea ${p.id}: ${p.title}. ${p.text}
Work on branch ${BRANCH}, which is already checked out. Do not switch branches or commit.
First append a kind "claim" entry to ${BOARD} with status running. If this idea needs new balance keys, do not add them: stop and return status needs-owner. Otherwise implement it, reuse existing StoryText ids, and flag any new text id for the story-designer without inventing text. Add a headless test for the change. Run sh tools/tests/run.sh and it must pass. Write handoffs/${p.owner_agent}/2026-11-02-${p.id}.json from handoffs/_template.json. Append a claim entry to ${BOARD} with status done, partial or blocked. Return the result in the schema.`,
    { label: p.id, schema: buildSchema, model: 'sonnet' },
  )
  built.push({ id: p.id, result: r })
}

// ---- Test ------------------------------------------------------------------
phase('Test')
const qa = await agent(
  `Run only the plain test suite: sh tools/tests/run.sh in ${ROOT} on branch ${BRANCH}, and report the pass and fail counts with any error lines. This is not QA: do NOT run tools/sim.py, qa/bots or any balance check, and do not act as qa-analyst (owner approval required, see CLAUDE.md). Do not change code or balance. Return the result in the schema.,
  { label: 'qa', schema: qaSchema, model: 'sonnet' },
)

// ---- Finish ----------------------------------------------------------------
phase('Finish')
await agent(
  `You are the Producer. Follow .claude/agents/producer.md. Read ${BOARD} and ${COUNCIL}. Write ${GOAL}/log.md with one plain sentence per agent step, in order, and ${GOAL}/report.md in five lines or fewer. Set finished to "2026-11-02" in blackboard.json. Add a line linking the result to state.md. Results to record: agreed ${JSON.stringify(agreed.map(p => p.id))}; not built ${JSON.stringify(notAgreed)}; builds ${JSON.stringify(built)}; tests ${JSON.stringify(qa)}. Do not commit.`,
  { label: 'finish', model: 'sonnet' },
)

return { agreed: agreed.map(p => p.id), notAgreed, built, qa }
