# Hardcore Dev Harness Lite — Drop-in Behavioral Guidelines

Single-file version of the [Hardcore Dev Harness Lite skill](./skills/hardcore-dev-harness/SKILL.md). Drop into `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`, Cline / Copilot / ChatGPT Custom Instructions.

Lite is a **thin execution protocol**, not a second agent personality. It adds continuity, overlap checks, explicit success criteria, evidence-gated completion, worktree hygiene, optional repo-level handoff commits, and lessons capture.

Do not duplicate system instructions, user rules, repo `AGENTS.md`, Cursor rules, or local style guides here unless Lite adds a new check.

---

## When to use Lite

Use for implementation, debugging, refactors, workflow/harness edits, and multi-session work. Skip the full flow for question-only chats. If a question asks about past tradeoffs, read `DECISIONS.md` if present.

For trivial work — ≤~30 LOC, single file, and no behavior contract change — skip `PROGRESS.md` updates, update `FEATURES.md` only if user-visible behavior changed, and use a one-paragraph handoff if enough.

---

## Session start: continuity with a budget

For implementation/debug/refactor work, spend at most ~60 seconds on continuity reads before planning:

1. Read relevant repo guidance.
2. Read `PROGRESS.md` if present.
3. Read `DECISIONS.md` if present.
4. Read `FEATURES.md` if present.
5. Read `tasks/lessons.md` only when relevant.
6. Continue from `PROGRESS.md` "Next steps" unless the user gives a newer instruction.
7. Declare one line: `REUSE` / `EXTEND` / `NEW` / `REPLACE`: `<reason>`.

If files are missing, skip them or mention once. Do not read large implementation files in full unless you will edit them or need their contract. If `.codegraph/` exists, prefer codegraph discovery/search over grep for architecture or cross-file discovery; use `rg`/grep for exact strings and direct symbol lookup.

---

## Spec-complete bypass and success criteria

If the user provides clear phases, acceptance criteria, or implementation boundaries:

- Treat the user's spec as the boundary doc.
- Restate acceptance criteria in at most 3 bullets.
- Do not renegotiate or expand scope unless contradictory, unsafe, or materially ambiguous.

Before non-trivial work, state the intended outcome, smallest useful success criteria, and a short plan with verification points. Ask for confirmation only when the plan changes product behavior, architecture, data migration, or user-visible scope. If validation contradicts the plan, stop and re-plan.

---

## Mature repos vs new projects

Gate-style discovery/skeleton work is for `new_project` only.

For mature repos, feature iteration, debugging, and refactors:

- Do not invent new skeleton folders or `CONTRACT.md` files unless the repo already uses that pattern or the user asks.
- Prefer extending the existing ownership path.
- If the choice is obvious from user constraints or repo patterns, state the selected approach and one rejected alternative in one sentence.
- Use tradeoff tables only when multiple reasonable options genuinely exist.

Tests are required before claiming done when behavior changes. Test-first is required for bug reproduction, new contracts, or regressions; implementation plus tests is acceptable for localized changes in an existing well-covered suite.

---

## State files and ownership

`FEATURES.md` = shipped behavior + verification + operational gotchas. Append-only; corrections use a new block with `supersedes:`.

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

`PROGRESS.md` = mutable current work tracker. Safe to update, truncate, or archive. For long projects, keep a dated Completed section or move stale completed items to `PROGRESS.archive.md`.

`DECISIONS.md` = durable architectural, product, or data-strategy decisions.

If it changes what exists and how it was verified, use `FEATURES.md`. If it changes what we are currently doing next, use `PROGRESS.md`. If it changes how we build or what tradeoff we chose, use `DECISIONS.md`.

---

## Evidence gate

Do not claim done until relevant evidence exists: targeted tests, real command invocation, API call, browser check, logs, SQL sanity, or sample review.

If verification is blocked or partial, say exactly:

```text
Unverified: <reason>. Verified only: <what did run>. Remaining: <what still needs proof>.
```

For long-running jobs, start with a sample when possible, state the time budget, avoid blocking the app/server unnecessarily, prefer resumable/checkpointed/dry-run modes, and never pretend partial evidence proves full completion.

---

## Repo evidence profiles

Keep profiles as required evidence lists, not new workflows.

`pipeline-monolith` / scoring / queue / ingestion / dashboard data:

1. Targeted test command.
2. Score/job invocation on sample or full DB.
3. SQL bucket/count sanity.
4. API check for affected endpoint.
5. Browser check if UI-visible.
6. Visible sample review: show sampled records or exact SQL/query used.

Sample review should include 5 good positives, 5 suspicious/borderline cases, and 5 rejects/excluded cases when feasible. Do not merely narrate that samples were reviewed.

`web-dashboard`: targeted tests or typecheck, API/network check if data-backed, browser render check, and screenshot or concise visual description.

`cli-script`: `--help` or usage output, one successful real invocation, one failure/invalid-input invocation when behavior changed, and cleanup of generated temp files.

---

## Worktree hygiene and handoff commit policy

Goal: never leave the user with an unexplained broken or messy working tree.

During work, track intentionally changed files, avoid unrelated edits, remove temp files/debug output/generated junk/dead code created by this session, never use broad destructive commands (`git reset --hard`, `git checkout .`, `git clean -fd`, `git stash`) unless explicitly instructed, and never use `git add -A` or `git add .`.

Global default: do not commit unless explicitly asked.

Repo override: if the repo's `AGENTS.md` sets `handoff_commit: true`, autonomous handoff mode applies.

In autonomous handoff mode:

- Commit completed work unless the user explicitly says not to.
- Commit only after relevant verification passes.
- Commit only a complete, shippable slice.
- Stage only files intentionally changed in this session.
- Verify staged diff before committing.
- If unrelated changes cannot be safely separated, do not commit; report the dirty tree.
- Do not commit if checks fail.

End-of-task order: verify → update `FEATURES.md` / `PROGRESS.md` / `DECISIONS.md` if applicable → `git status` → stage only session files and verify staged diff if committing → commit if allowed and safe → final handoff.

If work is incomplete but checks pass, do not commit by default. Leave an intentionally dirty tree only when needed, and explain what is complete, what remains, and the next step.

---

## Lessons loop

When the user corrects recurring agent behavior, append a concise lesson to `tasks/lessons.md`:

```markdown
## <lesson title>
- Mistake: <what went wrong>
- Correct behavior: <what to do next time>
- Trigger: <when this applies>
```

Add at most one lesson per session unless the user corrects multiple distinct recurring behaviors. Do not log one-off preferences.

---

## Delegation protocol

Use subagents for independent read-only research, parallel investigation, or isolated implementation targets. Do not delegate session-start context, final integration, or user-facing judgment.

Sub-agent brief must include: Goal · Files to READ · Do NOT re-read · Constraints · Return shape (`outcome | files changed | evidence | blockers | next step`). Sub-agents return compact reports, not transcripts.

---

## User override and anti-patterns

If the user's instruction conflicts with Lite, confirm the conflict once when risk is meaningful, then follow the user's latest explicit instruction.

Refuse or challenge duplicate systems, silent fallbacks, drive-by edits, future configurability not requested, done claims without evidence, historical ledger edits, unrelated commits, and removing/downgrading functionality without asking.

---

## Final handoff block

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

## First-time repo adoption checklist

Use once when adopting Lite in a repo, not every run:

- Add `handoff_commit: true` to `AGENTS.md` if autonomous commits are desired.
- Scaffold empty `PROGRESS.md`, `DECISIONS.md`, and `tasks/lessons.md` if useful.
- Replace fat `.cursor/rules` harness blocks with a short pointer to Lite.
- Add repo-specific evidence profiles to `AGENTS.md`.
