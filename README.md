# Slowmode — Hardcore Dev Harness Lite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/skill-2.0.0-blue)](./skills/hardcore-dev-harness/SKILL.md)

[English](./README.md) | [简体中文](./README.zh.md)

> A portable **Agent Skill** that adds a thin engineering protocol to coding agents: context continuity, overlap checks, success criteria, evidence-gated completion, worktree hygiene, optional repo-level handoff commits, and lessons capture.

Slowmode is no longer a heavy gate/persona system. It keeps the useful checks and removes the ceremony.

---

## Quick start

**Install as a Cursor skill and print a User Rule:**

```bash
git clone https://github.com/lz10081/slowmode.git
cd slowmode && ./scripts/install.sh global
```

Paste the printed text into **Cursor Settings → Rules → User Rules**, then start a new agent session. The user rule points agents to Lite without requiring per-message gate footers.

**Install in one project:**

```bash
./scripts/install.sh cursor-rule /path/to/your-app
# or
./scripts/install.sh claude-md /path/to/your-app
```

**Optional first-time repo adoption:**

```markdown
# AGENTS.md

Use Hardcore Dev Harness Lite for implementation/debug/refactor tasks.

Repo overrides:
- handoff_commit: true  # only if autonomous verified commits are desired
- Use repo-specific evidence profiles where applicable.
```

Scaffold `FEATURES.md`, `PROGRESS.md`, `DECISIONS.md`, and `tasks/lessons.md` only when they add continuity for your repo.

---

## What this is

Slowmode is markdown instructions, not an app or npm package.

| Artifact | Use |
|----------|-----|
| `skills/hardcore-dev-harness/SKILL.md` | Full Lite skill (source of truth) |
| `CLAUDE.md` | Single-file drop-in for Claude Code, `AGENTS.md`, or custom instructions |
| `.cursor/rules/hardcore-dev-harness.mdc` | Short Cursor/Windsurf project rule pointing to the skill |
| `skills/hardcore-dev-harness/USER-RULE.txt` | Short global Cursor User Rule text |
| `skills/hardcore-dev-harness/PERSISTENCE.md` | Notes on keeping Lite active without re-bloating rules |

---

## What it fixes

| Failure mode | Lite response |
|--------------|---------------|
| Rebuilds features that already exist | Declare `REUSE` / `EXTEND` / `NEW` / `REPLACE` once after continuity reads |
| User gives a full spec but agent asks boilerplate questions | Treat spec as boundary doc and restate acceptance criteria in ≤3 bullets |
| Mature repo gets imaginary skeleton folders | Gate-style skeletons are `new_project` only; mature repos extend existing paths |
| "Tests pass" but product/data is wrong | Evidence gate requires real invocation and task-specific checks |
| Data pipeline quality is rubber-stamped | Pipeline profile requires SQL sanity and visible sample review |
| Long jobs get killed and agent claims done | Long-job rule requires sample/time budget and explicit `Unverified:` caveats |
| Working tree is left messy | Worktree hygiene + optional verified handoff commits |
| Lessons are forgotten | Recurring user corrections can be recorded in `tasks/lessons.md` |

---

## Lite protocol

For implementation/debug/refactor work:

1. Read continuity files with a ~60s budget: `PROGRESS.md`, `DECISIONS.md`, `FEATURES.md`, and relevant lessons if present.
2. Declare `REUSE` / `EXTEND` / `NEW` / `REPLACE` once.
3. Convert the task into success criteria. If the user already provided acceptance criteria, restate them in ≤3 bullets.
4. Make the smallest change on the existing ownership path.
5. Verify with evidence appropriate to the task.
6. Update ledgers/state files only by ownership:
   - `FEATURES.md` = shipped behavior + verification + operational gotchas.
   - `PROGRESS.md` = mutable current work and next steps.
   - `DECISIONS.md` = durable architectural/product/data decisions.
   - `tasks/lessons.md` = recurring agent-behavior corrections.
7. Clean up the worktree.
8. If `AGENTS.md` sets `handoff_commit: true`, commit only a verified, complete, shippable slice and only session-owned files.

For question-only chats, do not run the full flow. If the question is about past tradeoffs, read `DECISIONS.md` if present.

---

## Evidence profiles

Lite includes small profiles that list required evidence only:

- `pipeline-monolith`: targeted tests, score/job invocation, SQL bucket/count sanity, API check, browser check if UI-visible, and visible sample review.
- `web-dashboard`: tests/typecheck, API/network check if data-backed, browser render check, screenshot or concise visual description.
- `cli-script`: `--help`, successful invocation, failure/invalid-input invocation when behavior changed, and generated-file cleanup.

Add repo-specific profiles in `AGENTS.md` instead of expanding the global skill.

---

## Handoff commit policy

Global default: **do not commit unless explicitly asked**.

Repo override: if the repo's `AGENTS.md` sets `handoff_commit: true`, autonomous handoff mode applies.

In autonomous handoff mode, the agent commits only after verification passes, only for a complete shippable slice, and only files intentionally changed in the current session. If unrelated dirty files cannot be safely separated, it reports the dirty tree instead of committing.

End-of-task order:

```text
verify
→ update FEATURES / PROGRESS / DECISIONS if applicable
→ git status
→ stage only session files
→ verify staged diff
→ commit if allowed and safe
→ final Plan / Evidence / Commit / Risks / Next handoff
```

---

## Final handoff shape

Per-message gate footers are gone. Final responses use or compress:

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

## Install targets

```bash
./scripts/install.sh --help
```

Common targets:

| Target | Effect |
|--------|--------|
| `global` | Install Cursor skill and print User Rule text |
| `user-rule` | Print text for Cursor Settings → Rules → User Rules |
| `cursor-rule [path]` | Copy short `.mdc` project rule |
| `cursor-skill` | Copy skill to `~/.cursor/skills/hardcore-dev-harness/` |
| `project-skill [path]` | Copy skill to `.cursor/skills/` in a repo |
| `claude-md [path]` | Copy `CLAUDE.md` drop-in |
| `amp-skill` | Symlink skill into Amp skills |
| `templates` | Copy legacy `FEATURES.md` + `CONTRACT.md` templates |

---

## Repository layout

```text
slowmode/
├── README.md / README.zh.md
├── CLAUDE.md
├── EXAMPLES.md
├── FEATURES.md
├── templates/
├── scripts/install.sh
├── .cursor/rules/hardcore-dev-harness.mdc
└── skills/hardcore-dev-harness/
    ├── SKILL.md
    ├── PERSISTENCE.md
    └── USER-RULE.txt
```

---

## Examples

See [EXAMPLES.md](./EXAMPLES.md) for canonical output shapes: continuity opener, success criteria, evidence, pipeline sample review, handoff commit, delegation brief, and lessons capture.

---

## Contributing

Behavior-rule changes should keep these surfaces aligned:

- `skills/hardcore-dev-harness/SKILL.md`
- `CLAUDE.md`
- `.cursor/rules/hardcore-dev-harness.mdc`
- `EXAMPLES.md` if output shapes changed
- README files if user-facing usage changed

See [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## License

[MIT](./LICENSE) — use, fork, and ship in your own projects freely.
