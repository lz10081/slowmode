# Hardcore Dev Harness — Worked Examples

Concrete, copy-pastable examples of what the skill produces. Read this once and you (or any new agent loading the skill) will know the exact shape of each artifact.

Scenario throughout: **building a "swipe-to-delete ledger card" component** for a personal finance app.

---

## 1. Ideal Gate 0 Opener

What the agent should say in the **first reply** of every new chat:

```
[Gate 0 — Context Load]

Read:
- FEATURES.md (3 existing features: auth, ledger-list, currency-format)
- AGENTS.md (project: React Native + TypeScript, Vitest, Reanimated 3)
- README.md (data flow: Zustand store → ledger screens)

Grep "swipe" / "card" / "delete":
- features/ledger-list/index.tsx — uses static list, no swipe handler
- No existing swipe gesture utility

Existing relevant: ledger-list (consumer that will host the new card).
Plan: NEW: ledger-card-swipe-delete (no overlap; will be consumed by ledger-list via its current row-render prop).

[Gate 0 mapped] Mode = feature_iter. Plan = NEW. Proceeding to Gate 3.
```

**Why this works:** the agent declares what it read, what already exists, what the relationship is, and what plan it picked — all before writing a single line of code. The user can correct it in 10 seconds if the plan is wrong.

---

## 2. Filled `CONTRACT.md` (Gate 2 output)

Lives at `features/ledger-card-swipe-delete/CONTRACT.md`:

```markdown
Inputs:        { entry: LedgerEntry, onDelete: (id: string) => void }
Outputs:       JSX.Element (a swipeable row that calls onDelete on full swipe-left)
Side-effects:  none (pure presentational; parent owns mutation)
Deps:          react-native-reanimated@3, react-native-gesture-handler@2
Replaces:      none
```

**Why exactly 5 lines:** any consumer or future agent reads this in 5 seconds. A pivot = drop this folder and create a new one whose `Inputs` / `Outputs` / `Side-effects` lines match — no consumer change needed.

---

## 3. Filled `FEATURES.md` Block (Gate 5 output)

After Gate 5 completes, the agent appends this block to `FEATURES.md` (append-only — never edit past blocks):

```markdown
## ledger-card-swipe-delete  (added 2026-05-23, supersedes: none)
- Location:        features/ledger-card-swipe-delete/
- Public API:      <LedgerCardSwipeDelete entry={…} onDelete={…} />
- Inputs/Outputs:  { entry, onDelete } → swipeable row JSX
- Edge cases tested:
  - empty entry.note renders without crash
  - swipe < threshold (60% of width) does NOT trigger onDelete
  - rapid double-swipe only fires onDelete once
- Verified by:     `pnpm vitest features/ledger-card-swipe-delete`
- Notes:           Reanimated worklet runs on UI thread; do NOT pass non-shareable callbacks in. onDelete is wrapped with runOnJS internally.
```

**Why this matters:** the *next* agent (or you, 3 weeks later) opens `FEATURES.md`, sees this block in Gate 0, and instantly knows: where it lives, how to call it, what was tested, what gotcha exists, how to re-verify. Zero re-discovery cost.

---

## 4. Evidence Block (Gate 5 — the "tests pass" claim)

Bad (rejected by the skill):
> "I implemented the component and all tests pass. You can use it now."

Good (required by the skill):
````
Tests:
```
$ pnpm vitest features/ledger-card-swipe-delete

 ✓ renders entry note (8ms)
 ✓ does not call onDelete on partial swipe (24ms)
 ✓ calls onDelete exactly once on full swipe (31ms)
 ✓ handles empty note without crash (5ms)

 Test Files  1 passed (1)
      Tests  4 passed (4)
```

Real invocation (rendered in Storybook, swiped manually via tmux + adb):
```
$ adb shell input swipe 800 400 100 400 300
[ledger-card] swipe distance: 700px / threshold: 240px → onDelete('entry-42') called
```
````

If you can't run it, say so explicitly — never imply success:
> `Unverified: host has no React Native simulator. Test suite passes (output above); manual swipe invocation deferred to user.`

---

## 5. Delegation Brief (main agent → sub-agent)

When the main agent needs a sub-agent (e.g., investigate the Reanimated 3 worklet rules in parallel), the brief MUST contain all five fields:

```
Goal:           Confirm whether `runOnJS` is required to call `onDelete` from inside a worklet, per Reanimated 3 official docs.

Files to READ:  - docs/external/reanimated-v3-runOnJS.md (just downloaded)
                - features/ledger-card-swipe-delete/CONTRACT.md

Do NOT re-read: - FEATURES.md (already in main context)
                - AGENTS.md (already in main context)

Constraints:    - Only confirm/deny + cite official-doc URL.
                - Do NOT write or modify any source files.
                - Do NOT run the test suite.

Return shape:
  outcome:    yes / no + one-line reason
  files:      (none expected)
  evidence:   cited URL + relevant quote
  blockers:   (none expected)
  next step:  (none expected)
```

The sub-agent returns a **compact report** in exactly that shape — no transcript, no "I read the file then I thought about it then…".

```
outcome:   YES — runOnJS is required to call JS-thread callbacks from a worklet.
files:     (none)
evidence:  https://docs.swmansion.com/react-native-reanimated/docs/guides/worklets#calling-javascript-functions-from-worklets — "To call a regular JavaScript function from a worklet you must wrap it with runOnJS."
blockers:  (none)
next step: (none)
```

---

## 6. "Agree / Disagree" Response Pattern

User: *"I think you should just use `try { onDelete(id) } catch {}` so swipe never fails."*

Bad (silently complies, violates Fail-Fast):
> "Sure, done. I've wrapped onDelete in a try/catch."

Good (explicit stance first, then action — or refusal):
> **disagree.** Silent `catch {}` here hides bugs in the parent's mutation logic — the user swipes, sees the row disappear, but the backend delete actually failed. Per Fail-Fast §5 we let it throw so the parent shows a real error toast. If you want UX softness, that belongs in the parent's `onDelete`, not inside the swipe component.
>
> Not making the change. Want me to instead surface a callback like `onError?: (e: Error) => void` so the parent can decide?

---

## 7. Before / After (same task, with vs. without the skill)

### Without the skill
Agent gets "build a swipe-to-delete row" and immediately writes 180 lines: a new gesture util, a new animation hook, a styled component, a `try { ... } catch { return null }` wrapper, no tests, no docs. Output: "Done, let me know if you need changes!" The next chat re-asks because nothing is documented; the parent breaks because the wrapper swallowed an error.

### With the skill
- **Gate 0 (15 sec):** declares `NEW`, names which existing feature will consume it.
- **Gate 3 (1 min):** notes Reanimated 3 is the project's existing animation lib (no new dep). One sentence: "Alternative would be `react-native-swipeable-row` but adds a dep — worse."
- **Gate 4 (2 min):** lists 3 edge tests (partial swipe, empty note, double-swipe).
- **Gate 5 (5 min):** ~60 lines, no silent catches, tests pasted, ledger appended.

Same outcome, **third the code, zero hidden bugs, fully discoverable next session.**

---

## 8. Trivial Fast Path — example

User: *"There's a typo in the placeholder text on the amount input — it says 'Amout'."*

The agent does NOT run Gate 1/2/3/4. It runs:

1. **Gate 0:** grep `Amout` → one match in `features/ledger-entry-form/index.tsx`. Plan = `EXTEND: ledger-entry-form` (cosmetic). [Gate 0 mapped] Mode = feature_iter. Fast path.
2. **Gate 5:** 1-line fix, paste the diff, paste the snapshot test output, append a 3-line note to `FEATURES.md` under the existing `ledger-entry-form` block (or supersede with a corrected block if there's prior contradicting info).

Total time: 30 seconds. Zero bureaucracy. Fast path exists for exactly this.

---

## How to use this file

- **For users:** Read once to know what you should be seeing in your chats. If your agent doesn't produce something in this shape, push back.
- **For agents loading the skill:** Treat the snippets above as the **canonical output format**. Don't reinvent the shape.
