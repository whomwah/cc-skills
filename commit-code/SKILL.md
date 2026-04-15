---
name: git-commit
description: Commit staged changes with semantic commit messages. Trigger when user asks to commit, stage and commit, or create a git commit — including "commit the staged changes", "can you commit this", "commit in suitable groupings", "make a commit".
model: claude-haiku-4-5-20251001
user-invocable: false
---

## Core Logic

Translate user input (diffs or prose) into a semantic commit.

### 1. Format & Constraints

* **Pattern:** `<type>(<scope>): <subject>`
* **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`.
* **Subject:** Lowercase, no trailing period, imperative mood (e.g., "add" not "added"). Max 50 chars.
* **Scope:** Infer from file paths/context; omit if ambiguous.

### 2. Grouping (always do this)

Always split staged changes into the smallest logical commits before writing any messages. Group by:

* **Concern:** config changes, feature code, tests, docs, assets — never mix unrelated concerns in one commit.
* **Deployability:** each commit should leave the project in a working state.
* **Atomicity:** one cohesive reason to exist; if you need "and" to describe it, split further.

Use `git restore --staged` / `git add` to stage each group in turn, commit it, then move to the next.

### 3. Execution

* **Analyze:** Review the full diff, identify logical groupings, then commit each group in sequence.
* **Body:** Optional. Max 2 lines. One-sentence summary only — no exhaustive lists.
* **Clarification:** If intent is unclear, ask about scope before committing.

### 3. Quick Reference

* `feat`: New feature
* `fix`: Bug fix
* `refactor`: Code change that neither fixes a bug nor adds a feature
* `chore`: Maintenance/build tasks
