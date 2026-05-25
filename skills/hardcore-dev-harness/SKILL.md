---
name: hardcore-dev-harness
description: "Adds a thin engineering protocol for coding agents: context continuity, overlap checks, explicit success criteria, evidence-gated completion, worktree hygiene, optional repo-level handoff commits, and lessons capture. Use for implementation, debugging, refactors, workflow edits, and multi-session work; skip full flow for question-only chats."
license: MIT
version: 2.0.0
---

# Hardcore Dev Harness Lite

Hardcore Dev Harness Lite is a **thin execution protocol**, not a second agent personality. It adds only the checks that usually get missed: continuity, overlap detection, success criteria, real evidence, ledger handoff, clean worktrees, and lessons from user corrections.

Do **not** duplicate system instructions, user rules, repo `AGENTS.md`, Cursor rules, or local style guides here unless Lite adds a new check.

---

## 1. When to use Lite

Use Lite for:
- implementation work
- debugging and QA
- refactors
- workflow/harness edits
- multi-step or multi-session tasks
- tasks where shipped behavior, evidence, or handoff state matters

Do not run the full flow for question-only chats. If a question asks about past tradeoffs, read `DECISIONS.md` if present.

For trivial work — ≤~30 LOC, single file, and no behavior contract change — skip `PROGRESS.md` updates, update `FEATURES.md` only if user-visible behavior changed, and use a one-paragraph handoff if enough.

---

## 2. Session start: continuity with a budget

For implementation/debug/refactor work, spend at most ~60 seconds on continuity reads before planning:

1. Read relevant repo guidance.
2. Read `PROGRESS.md` if present.
3. Read `DECISIONS.md` if present.
4. Read `FEATURES.md` if present.
5. Read `tasks/lessons.md` only when relevant, especially before workflow/harness edits or when a task matches a known lesson.
6. Continue from `PROGRESS.md` "Next steps" unless the user gives a newer instruction.
7. Declare one line: `REUSE` / `EXTEND` / `NEW` / `REPLACE`: `<reason>`.

If files are missing, skip them or mention once. Do not read large implementation files in full unless you will edit them or need their contract. If `.codegraph/` exists, prefer codegraph discovery/search over grep for architecture or cross-file discovery; use `rg`/grep for exact strings and direct symbol lookup.

---

## 3. Spec-complete bypass and success criteria

If the user provides clear phases, acceptance criteria, or implementation boundaries:
- Treat the user's spec as the boundary doc.
- Restate the acceptance criteria in at most 3 bullets.
- Do not renegotiate or expand scope unless something is contradictory, unsafe, or materially ambiguous.

Before non-trivial work, state:
- intended outcome
- smallest useful success criteria
- short plan with verification points

Ask for confirmation only when the plan changes product behavior, architecture, data migration, or user-visible scope. If validation contradicts the plan, stop and re-plan instead of forcing through.

---

## 4. Mature repos vs new projects

Gate-style discovery/skeleton work is for `new_project` only.

For mature repos, feature iteration, debugging, and refactors:
- Do not invent new skeleton folders or `CONTRACT.md` files unless the repo already uses that pattern or the user asks.
- Prefer extending the existing ownership path.
- If the choice is obvious from user constraints or repo patterns, state the selected approach and one rejected alternative in one sentence.
- Use tradeoff tables only when multiple reasonable options genuinely exist.

Tests are required before claiming done when behavior changes. Test-first is required for bug reproduction, new contracts, or regressions; implementation plus tests is acceptable for localized changes in an existing well-covered suite.

---

## 5. State files and ownership

Use state files only when they add continuity. Do not turn them into ritual.

### `FEATURES.md`
Shipped behavior + verification + operational gotchas. Append-only: historical blocks are immutable; corrections use a new block with `supersedes:`.

```markdown
## <feature-name>  (added YYYY-MM-DD, supersedes: <prev|none>)
- Location:        <path/to/feature/>
- Public API:      <signatures or endpoints>
- Inputs/Outputs:  <one line>
- Edge cases tested:
  - <case>
- Verified by:     <exact command(s)>
- Notes:           <gotchas for future agents>
```

### `PROGRESS.md`
Mutable current work tracker: current status, completed, in progress, next steps, blockers, and last verification. Safe to update, truncate, or archive. For long projects, keep a dated Completed section or move stale completed items to `PROGRESS.archive.md`. Do not duplicate shipped behavior that belongs in `FEATURES.md`.

### `DECISIONS.md`
Durable architectural, product, or data-strategy decisions that affect how we build.

```markdown
## <decision title>  (YYYY-MM-DD)
- Decision: <what we chose>
- Context: <why it came up>
- Rationale: <why this option>
- Rejected alternatives:
  - <alternative>: <why rejected>
- Impact: <what future agents should know>
```

### Ownership rule
If it changes what exists and how it was verified, use `FEATURES.md`. If it changes what we are currently doing next, use `PROGRESS.md`. If it changes how we build or what tradeoff we chose, use `DECISIONS.md`. When a `PROGRESS.md` item ships, add a `FEATURES.md` block if behavior changed, then remove or mark the progress item complete.

---

## 6. Evidence gate

Do not claim done until relevant evidence exists. Evidence depends on the task:
- targeted tests
- real command invocation
- API call
- browser check
- logs
- SQL sanity
- sample review

If verification is blocked or partial, say exactly:

```text
Unverified: <reason>. Verified only: <what did run>. Remaining: <what still needs proof>.
```

For long-running jobs such as backfills, ingests, scoring, or migrations:
- start with a small sample when possible
- state the time budget
- avoid locking or blocking the app/server unnecessarily
- prefer resumable/checkpointed/dry-run modes when available
- never pretend partial evidence proves full completion

---

## 7. Repo evidence profiles

Use repo-specific profiles when available. Keep profiles as required evidence lists, not new workflows.

### `pipeline-monolith` / scoring / queue / ingestion / dashboard data

Required when touching scoring, ranking, hidden gems, queue, ingestion, DB schema, or dashboard-visible data:

1. Targeted test command.
2. Score/job invocation on sample or full DB.
3. SQL bucket/count sanity.
4. API check for affected endpoint.
5. Browser check if UI-visible.
6. Visible sample review: show sampled records or exact SQL/query used.

Sample review should include at least 15 visible rows when feasible:

```text
job_id | title | company | bucket | semantic_score | deterministic_score | reason/risk
```

Include 5 good positives, 5 suspicious/borderline cases, and 5 rejects/excluded cases. Do not merely narrate that samples were reviewed.

### `web-dashboard`

Required evidence: targeted tests or typecheck, API/network check if data-backed, browser render check for affected route/state, and screenshot or concise visual description of the verified UI.

### `cli-script`

Required evidence: `--help` or usage output, one successful real invocation, one failure/invalid-input invocation when behavior changed, and cleanup of generated temp files.

---

## 8. Worktree hygiene and handoff commit policy

Goal: never leave the user with an unexplained broken or messy working tree.

During work:
- Track which files are intentionally changed.
- Do not modify unrelated files.
- Remove temporary files, scratch scripts, debug output, generated junk, and dead code created by this session.
- Never use broad destructive commands such as `git reset --hard`, `git checkout .`, `git clean -fd`, or `git stash` unless explicitly instructed.
- Never use `git add -A` or `git add .`.

### Commit policy

Global default: do not commit unless explicitly asked.

Repo override: if the repo's `AGENTS.md` sets `handoff_commit: true`, autonomous handoff mode applies.

In autonomous handoff mode:
- At the end of implementation/debug/refactor work, commit completed work unless the user explicitly says not to.
- Commit only after relevant verification passes.
- Commit only a complete, shippable slice. Do not handoff-commit incomplete work unless the user explicitly scoped it as a shippable slice.
- Stage only files intentionally changed in this session.
- Verify staged diff before committing.
- If `git status` shows unrelated changes in files this session did not touch, do not commit those files.
- If unrelated changes cannot be safely separated, do not commit; report the dirty tree.
- Do not commit if checks fail.
- Final response must include commit hash or explain why no commit was made.

End-of-task order:
1. Run relevant verification.
2. Append/update `FEATURES.md` if shipped behavior changed.
3. Update `PROGRESS.md` / `DECISIONS.md` if applicable.
4. Run `git status`.
5. Stage only session files and verify staged diff if `handoff_commit: true`.
6. Commit if allowed and safe.
7. Send final handoff block.

If work is incomplete but checks pass, do not commit by default. Leave an intentionally dirty tree only when needed, and explain what is complete, what remains, and the next step.

---

## 9. Lessons loop

When the user corrects recurring agent behavior, append a concise lesson to `tasks/lessons.md`:

```markdown
## <lesson title>
- Mistake: <what went wrong>
- Correct behavior: <what to do next time>
- Trigger: <when this applies>
```

Add at most one lesson per session unless the user corrects multiple distinct recurring behaviors. Do not log one-off preferences. Keep lessons short. Periodically prune or archive stale lessons.

---

## 10. Delegation protocol

Use subagents for independent read-only research, parallel investigation, or isolated implementation targets. Do not delegate session-start context, final integration, or user-facing judgment.

Sub-agent brief must include all five fields:

```text
Goal:           <one sentence>
Files to READ:  <specific paths>
Do NOT re-read: <files already in main context>
Constraints:    <non-goals, style, tests>
Return shape:   outcome | files changed | evidence | blockers | next step
```

Sub-agents return compact reports, not transcripts.

---

## 11. User override and anti-patterns

If the user's instruction conflicts with Lite, confirm the conflict once when risk is meaningful, then follow the user's latest explicit instruction.

Refuse or challenge:
- duplicate systems when `REUSE` or `EXTEND` is available
- silent `catch { return [] }` or `{}`/`[]` fallbacks for dirty data
- drive-by edits to adjacent code
- future configurability not requested
- claiming done without evidence
- editing historical `FEATURES.md` entries
- committing unrelated or pre-existing dirty files
- removing or downgrading functionality without asking

---

## 12. Final handoff block

Replace per-message gate footers with a final handoff. For small tasks, compress this to one short paragraph.

```markdown
Plan:
- <what was done / chosen>

Evidence:
- <commands and results>

Commit:
- <commit hash or why not committed>

Risks:
- <remaining risks / unverified items>

Next:
- <next recommended action, if any>
```

---

## 13. First-time repo adoption checklist

Use this once when adopting Lite in a repo, not every run:

- Add `handoff_commit: true` to `AGENTS.md` if autonomous commits are desired.
- Scaffold empty `PROGRESS.md`, `DECISIONS.md`, and `tasks/lessons.md` if useful.
- Replace fat `.cursor/rules` harness blocks with a short pointer to Lite.
- Add repo-specific evidence profiles to `AGENTS.md`.

---

## 14. Verifying Lite is working

- The agent states `REUSE` / `EXTEND` / `NEW` / `REPLACE` once, not every reply.
- User-provided specs become acceptance criteria instead of redundant discovery.
- Mature repos are extended in-place; no imaginary skeletons appear.
- Done claims include real evidence and any `Unverified:` caveats.
- `FEATURES.md`, `PROGRESS.md`, and `DECISIONS.md` do not duplicate each other.
- Final handoff includes evidence, commit status, risks, and next step.
