# Hardcore Dev Harness Lite — Worked Examples

Concrete examples of the output shapes Lite expects. Scenario examples use a mature jobs/scoring repo and a UI repo to show that Lite is not a heavy gate system.

---

## 1. Continuity opener

Good first implementation reply:

```text
Read within continuity budget:
- FEATURES.md: existing scoring-v1 and queue dashboard entries
- DECISIONS.md: lexical scoring preferred over embeddings for deterministic cost control
- PROGRESS.md: next step says inspect hidden-gem false positives

EXTEND: existing scoring pipeline. The user asked to improve hidden-gem recall, and the current ownership path is job_agent.py + SQLite score_job flow.

Success criteria:
- Improve scoring logic without changing human-submit boundaries.
- Verify with targeted tests, score run, SQL bucket sanity, API/browser check.
- Show visible sample review for positives, suspicious cases, and rejects.
```

Why it works: the agent declares continuity, overlap, and success criteria once. It does not emit per-message gate footers.

---

## 2. Spec-complete bypass

User gives a four-phase spec with acceptance criteria.

Good response:

```text
EXTEND: queue/scoring path. Your phases are clear enough to use as the boundary doc.

Acceptance criteria:
- Implement phases 1–4 as specified.
- Preserve the existing human-submit boundary and DB patterns.
- Verify with tests, score invocation, SQL sanity, API/browser checks, and sample review.

I won't add embeddings, auto-learning weights, or broad LLM reclassification unless you ask.
```

Why it works: the agent does not re-run discovery when the user already wrote the boundary.

---

## 3. State-file ownership

Use the right file for the right kind of knowledge:

```markdown
FEATURES.md
## hidden-gems-scoring-v2  (added 2026-05-25, supersedes: hidden-gems-scoring-v1)
- Location:        job_agent.py, dashboard hidden gems endpoint
- Public API:      /api/hidden-gems response bucket semantics unchanged
- Inputs/Outputs:  scored jobs → bucketed queue/hidden-gem results
- Edge cases tested:
  - ambiguous sales/design roles do not dominate hidden gems
  - senior technical roles can still surface without exact keyword matches
- Verified by:     `python -m unittest tests/test_job_agent_flows.py`; score run on sample DB; SQL bucket sanity
- Notes:           For scoring changes, show 5 positives, 5 suspicious cases, and 5 rejects in final handoff.

DECISIONS.md
## deterministic lexical scoring over embeddings  (2026-05-25)
- Decision: Use deterministic lexical/role-family scoring, not embeddings.
- Context: Hidden-gem recall needed to improve without slow or costly inference.
- Rationale: Cheap, explainable, testable, and avoids feedback-loop learning.
- Rejected alternatives:
  - embeddings: harder to debug and unnecessary for current constraints
- Impact: Future scoring work should first extend lexical families and evidence checks.

PROGRESS.md
## Next steps
- Inspect remaining hidden-gem false positives after the next backfill.
```

Rule: if it changes what exists and how it was verified, use `FEATURES.md`; if it changes how we build, use `DECISIONS.md`; if it changes what to do next, use `PROGRESS.md`.

---

## 4. Evidence block

Bad:

> Tests pass and I checked the UI.

Good:

````markdown
Evidence:
- Tests:
  ```text
  $ python -m unittest tests/test_job_agent_flows.py
  ..............................................
  ----------------------------------------------------------------------
  Ran 46 tests in 3.218s

  OK
  ```
- Score invocation:
  ```text
  $ python job_agent.py score --limit 500
  scored=500 updated=500 errors=0 elapsed=42.1s
  ```
- API:
  ```text
  $ curl -s http://localhost:8000/api/hidden-gems | jq '.jobs | length'
  25
  ```
- Browser: hidden-gems page renders 25 rows; top cards show technical roles, no visible sales/design false positives in first screen.
````

If a check is blocked:

```text
Unverified: full backfill exceeded the 5-minute budget. Verified only: 500-row sample score run. Remaining: full DB score run and post-backfill SQL distribution.
```

---

## 5. Data-pipeline sample review

Do not merely say "I sampled rows." Show rows or the exact query.

```sql
SELECT id, title, company, bucket, semantic_score, deterministic_score, score_reason
FROM jobs
WHERE bucket IN ('hidden_gem', 'reject')
ORDER BY updated_at DESC
LIMIT 15;
```

Final handoff excerpt:

```text
Sample review:
good positives:
- 1832 | Staff Backend Engineer | Acme | hidden_gem | 0.86 | 0.78 | backend infra role, low applicant count
- 1991 | ML Platform Engineer | Northstar | hidden_gem | 0.82 | 0.74 | platform + seniority match

suspicious/borderline:
- 2044 | Solutions Architect | VendorCo | hidden_gem | 0.71 | 0.52 | customer-facing title; acceptable only with infra keywords

rejects/excluded:
- 1888 | Account Executive | Salesly | reject | 0.12 | 0.05 | sales family hard reject
```

---

## 6. Handoff commit

If `AGENTS.md` does **not** set `handoff_commit: true`:

```markdown
Commit:
- Not committed: repo does not enable `handoff_commit`, and the user did not explicitly ask for a commit.
```

If `handoff_commit: true` and checks pass:

```markdown
Commit:
- `abc1234` — update hidden-gem scoring evidence profile
```

If unrelated dirty files exist:

```markdown
Commit:
- Not committed: `git status` shows unrelated changes in `README.md` and `scripts/install.sh` that this session did not own. I left only intentional task diffs and did not stage unrelated files.
```

---

## 7. Final handoff block

```markdown
Plan:
- Converted the old gate-heavy harness into Lite: continuity, overlap, success criteria, evidence, worktree hygiene, optional handoff commit, lessons.

Evidence:
- `./scripts/install.sh --help` prints the updated install helper usage.
- Markdown links and frontmatter reviewed in `SKILL.md`, `CLAUDE.md`, and `.mdc`.

Commit:
- Not committed: current repo policy requires explicit user commit request.

Risks:
- README examples are intentionally shorter; old gate-specific examples were removed.

Next:
- Try installing into a test repo and confirm the Cursor rule stays concise.
```

---

## 8. Delegation brief

```text
Goal:           Review whether README and README.zh describe the same Lite behavior.
Files to READ:  README.md, README.zh.md, skills/hardcore-dev-harness/SKILL.md
Do NOT re-read: git history or install script
Constraints:    read-only; report inconsistencies only
Return shape:   outcome | files inspected | evidence | blockers | next step
```

---

## 9. Lessons capture

When the user corrects a recurring behavior:

```markdown
## Harness should stay thin
- Mistake: Repeating gate labels and duplicating repo/user rules creates ceremony.
- Correct behavior: Use Lite as overlap + evidence + ledger + handoff protocol, not a second workflow personality.
- Trigger: When editing AGENTS.md, Cursor rules, or harness docs.
```

Add at most one lesson per session unless the user corrects multiple distinct recurring behaviors.
