# FEATURES.md — Slowmode Repository Ledger

Ledger for the **skill artifact** distributed from this repo (not an application codebase).
Your **application projects** should use [templates/FEATURES.md](./templates/FEATURES.md) instead.

---

## hardcore-dev-harness (added 2026-05-23, supersedes: none)
- Location:        skills/hardcore-dev-harness/
- Public API:      Agent Skill `hardcore-dev-harness`; drop-ins `CLAUDE.md`, `.cursor/rules/hardcore-dev-harness.mdc`
- Inputs/Outputs:  User declares `Mode:` + task → gated workflow artifacts (MVP doc, skeleton, tests, evidence, ledger block)
- Edge cases tested:
  - Trivial Fast Path (≤30 LOC single-file edit) documented in EXAMPLES.md §8
  - Sub-agent delegation 5-field brief + compact return (EXAMPLES.md §5)
  - Append-only FEATURES.md supersede pattern (EXAMPLES.md §3)
- Verified by:     Manual review against EXAMPLES.md canonical shapes; install via `scripts/install.sh --help`
- Notes:           Version tracked in `SKILL.md` frontmatter. Keep SKILL.md, CLAUDE.md, and .mdc in sync per CONTRIBUTING.md.

## hardcore-dev-harness-lite  (added 2026-05-25, supersedes: hardcore-dev-harness)
- Location:        skills/hardcore-dev-harness/, CLAUDE.md, .cursor/rules/hardcore-dev-harness.mdc
- Public API:      Agent Skill `hardcore-dev-harness`; drop-ins `CLAUDE.md`, `.cursor/rules/hardcore-dev-harness.mdc`, `USER-RULE.txt`
- Inputs/Outputs:  Implementation/debug/refactor task → continuity check, `REUSE`/`EXTEND`/`NEW`/`REPLACE`, success criteria, evidence, state-file updates, worktree handoff
- Edge cases tested:
  - Question-only chats skip the full flow unless past decisions are relevant
  - Spec-complete tasks bypass redundant discovery and restate ≤3 acceptance bullets
  - Mature repos do not get forced Gate 1/2 skeletons or mandatory tradeoff tables
  - `handoff_commit: true` is repo-scoped; global default remains no commit unless asked
  - Data-pipeline profile requires visible sample review rather than narrative-only checks
- Verified by:     `./scripts/install.sh --help`; `python3 -c 'from pathlib import Path; fence=chr(96)*3; files=["skills/hardcore-dev-harness/SKILL.md","CLAUDE.md",".cursor/rules/hardcore-dev-harness.mdc","README.md","README.zh.md","EXAMPLES.md","FEATURES.md"]; bad=[p for p in files if Path(p).read_text().count(fence)%2]; assert not bad, bad; text=Path("skills/hardcore-dev-harness/SKILL.md").read_text(); assert text.startswith("---\n") and "\n---\n" in text[4:]; print("markdown/frontmatter validation OK")'`
- Notes:           Lite replaces per-message gate footers with final `Plan / Evidence / Commit / Risks / Next`. `FEATURES.md` is shipped behavior, `PROGRESS.md` is mutable current work, `DECISIONS.md` is durable tradeoffs, and `tasks/lessons.md` is bounded behavior correction.
