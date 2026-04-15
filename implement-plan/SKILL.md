---
  name: implement-plan
  description: Implements a plan end-to-end: creates a branch, builds with Karpathy guidelines, optionally opens a PR, and notifies with links.
  argument-hint: <github-issue-url> | "current plan"
  ---

  # Implement Plan

  ## Usage

  /implement-plan
  /implement-plan current plan

  ## Workflow

  ### 1. Load the plan

  - **If GitHub URL**: extract `owner/repo` and issue number, then run:
    ```bash
    gh issue view <number> --repo <owner/repo>
    Use the issue body as the plan. Note the URL for the PR.

  - If "current plan": use the plan already present in the conversation. Ask user to confirm which plan if ambiguous.

  2. Create branch

  Skip if already on a suitable branch.

  - Derive a short kebab-case name from the issue title or plan summary (max 5 words).
  - git checkout -b duncan/<kebab-name>

  3. Implement
  
   Follow @karparthy.md guidelines throughout.

  4. Confirm next steps

  Print exactly:

  ▎ Completed! Want a report, a PR, both, or neither?

  Wait for user response before continuing.

  - Report: create CHANGES.md at the repo root summarising: what changed, why, and any follow-up notes.
  - PR: run:
  gh pr create --title "<concise summary>" --body "$(cat <<'EOF'
  ## Summary
  <bullet points from plan>

  ## Changes
  <what was built>

  Closes <issue-url>
  EOF
  )"
  - Omit the Closes line if there is no issue URL.

  5. Notify

  Output:
  Done.
  PR:    <pr-url>      # omit if no PR
  Issue: <issue-url>   # omit if no issue
