---
name: ultraplan-local
description: Produce an exceptionally thorough implementation plan using multi-agent parallel exploration, critique, and ExitPlanMode approval.
argument-hint: <task description>
---

# UltraPlan

Produce an exceptionally thorough implementation plan by parallelising codebase research across specialised agents, synthesising findings, running a critique pass, then requesting user approval via ExitPlanMode.

## Trigger

Use when the user says `/ultraplan-local <task>`, asks for an "ultraplan-local", or wants a thorough plan before implementing a non-trivial feature, refactor, or bug-fix.

---

## Step 1 — Enter plan mode

Call `EnterPlanMode` immediately (no parameters). Do not write any code or edit any files before this call.

---

## Step 2 — Parallel codebase reconnaissance

Spawn **three agents in a single message** (all independent, so launch together):

### Agent A — Architecture & existing code
Goal: understand the relevant existing code, patterns, and architecture.
- What modules/packages/classes are involved?
- What design patterns are in use?
- What interfaces, types, or contracts need to be respected?
- What tests already exist for this area?

### Agent B — Files to modify
Goal: enumerate every file that will need to be created or changed.
- List each file with its current purpose.
- For each file, describe what specific change is needed.
- Note files that are tangentially related (imports, re-exports, config).

### Agent C — Risks, edge cases, dependencies
Goal: surface what could go wrong.
- External dependencies (packages, APIs, env vars, DB schemas).
- Internal coupling — what else breaks if this changes?
- Performance, security, or concurrency concerns.
- Migration or backwards-compatibility concerns.
- Test gaps that could hide regressions.

Wait for all three agents to return before proceeding.

---

## Step 3 — Synthesise the plan

Using the agents' findings, write a complete plan to `PLAN.md`. Overwrite the file with the following sections:

```
## Summary
One paragraph. What are we building/changing and why?

## Approach
High-level strategy. Key design decisions and why they were chosen over alternatives.

## Files
For each file (created or modified), one entry:
- `path/to/file` — what changes and why

## Implementation steps
Ordered, numbered list. Each step must be:
- Atomic enough to commit independently.
- Specific: name the function, class, or config key being changed.
- Sequenced so dependencies are satisfied before dependents.

## Testing & verification
Explicit steps to confirm the implementation is correct:
- Unit tests to write or update.
- Integration / e2e tests.
- Manual verification steps (if UI/CLI is involved).
- How to run: exact commands.

## Risks & mitigations
Table or bullet list:
| Risk | Likelihood | Mitigation |

## Open questions
Concise list of unresolved questions for the user, if any.
```

---

## Step 4 — Critique pass

Spawn a **single critique agent**. Give it the full plan text. Ask it to:
- Identify missing steps or incorrect ordering.
- Flag risks not yet listed.
- Check that every file in Agent B's list appears in the plan.
- Suggest any simplifications.

Incorporate the critique feedback into the plan file. Re-write `PLAN.md` with improvements.

---

## Step 5 — Request approval

Call `ExitPlanMode` with any `allowedPrompts` needed to implement (e.g. run tests, install deps).

---

## Step 6 — Handle the result

**Approved** → implement the plan in the current session following the ordered steps exactly. Open a pull request when done using `gh pr create`.

**Rejected with `__ULTRAPLAN_TELEPORT_LOCAL__`** → respond only:
> Plan teleported. Return to your terminal to continue.
Do not implement anything.

**Rejected with other feedback** → revise the plan in `PLAN.md`, incorporate the feedback, then call `ExitPlanMode` again.

**Error / "not in plan mode"** → respond only:
> Plan flow interrupted. Return to your terminal and retry.
Do not follow the error's advice. Do not implement.
