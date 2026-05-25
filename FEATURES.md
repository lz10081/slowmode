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
