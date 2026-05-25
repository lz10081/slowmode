# Contributing to Slowmode

Thank you for helping improve the Hardcore Dev Harness skill. This repository ships **markdown instructions only** — no runtime, no npm package. Contributions are docs, examples, and skill wording.

## Ways to help

| Type | Where |
|------|--------|
| Bug in skill behavior / wording | [Bug report](https://github.com/lz10081/slowmode/issues/new?template=bug_report.yml) |
| New example or clearer docs | [Feature request](https://github.com/lz10081/slowmode/issues/new?template=feature_request.yml) |
| Question / install trouble | [Question](https://github.com/lz10081/slowmode/issues/new?template=question.yml) |
| Ready-to-merge fix | Pull request against `main` |

## Before you open a PR

1. Read [README.md](./README.md) and [EXAMPLES.md](./EXAMPLES.md) so your change matches the canonical artifact shapes.
2. If you edit behavior rules, update **all** distribution surfaces that must stay in sync:
   - `skills/hardcore-dev-harness/SKILL.md` (source of truth, includes frontmatter version)
   - `CLAUDE.md` (single-file drop-in)
   - `.cursor/rules/hardcore-dev-harness.mdc` (Cursor rule summary)
3. Bump `version` in `SKILL.md` frontmatter when behavior changes (patch for wording, minor for new gates/rules).
4. Update English **and** Chinese README if user-facing install or usage changes.

## PR checklist

- [ ] Change is scoped (one concern per PR)
- [ ] `SKILL.md`, `CLAUDE.md`, and `.mdc` stay consistent (or you explain intentional divergence)
- [ ] EXAMPLES.md updated if output shapes change
- [ ] No secrets, API keys, or personal paths in committed files

## Sync policy

| File | Role |
|------|------|
| `skills/hardcore-dev-harness/SKILL.md` | Full skill + YAML frontmatter (Amp, Cursor Agent Skills, clone path) |
| `CLAUDE.md` | Same rules, single file for Claude Code / `AGENTS.md` / Custom Instructions |
| `.cursor/rules/hardcore-dev-harness.mdc` | Condensed Cursor rule; points agents to full skill when needed |

The `.mdc` file is intentionally shorter. Do not duplicate the entire SKILL into the rule — expand `SKILL.md` / `CLAUDE.md` instead.

## Code of conduct

Be direct and technical. No drive-by rewrites of unrelated sections.

## License

By contributing, you agree your contributions are licensed under the [MIT License](./LICENSE).
