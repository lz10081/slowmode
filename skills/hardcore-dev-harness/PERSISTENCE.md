# Keeping Lite active without re-bloating rules

`/hardcore-dev-harness` or explicit skill invocation may only affect the current turn, depending on the agent. Use a persistent project rule or user rule when you need Lite across a full session.

| Mechanism | Persists whole chat? | Scope |
|-----------|----------------------|-------|
| `/hardcore-dev-harness` / attach skill | Agent-dependent; often one turn | Current chat |
| Project `.cursor/rules/*.mdc` + `alwaysApply: true` | Yes | One repo |
| Cursor Settings → Rules → User Rules | Yes | All repos |

Recommended shape:
- Keep the full spec in `skills/hardcore-dev-harness/SKILL.md`.
- Keep `.cursor/rules/hardcore-dev-harness.mdc` short and pointed at the skill.
- Put repo-specific overrides such as `handoff_commit: true` and evidence profiles in `AGENTS.md`.

Do not require per-message gate footers. Use the final `Plan / Evidence / Commit / Risks / Next` handoff block instead.
