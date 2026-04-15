---
name: release-macos
description: Release a macOS app — bump versions, open a PR, then build and publish.
---

# release-macos Skill

Triggered by: `/release-macos <type>` where type is `major`, `minor`, `patch`, or `build`.

## Phase 0 — Preflight

Run all checks before any work. Fail fast with a specific fix hint for each.

1. `just --version` — must be ≥ 1.14 (needs `home_directory()`)
2. `project.yml` exists
3. `justfile` defines `app_name`, `releases_repo`, `sign_identity`
4. `CHANGELOG.md` exists
5. `.env` exists and contains `SPARKLE_EDDSA_KEY`
6. `ExportOptions.plist` exists
7. `gh auth status` succeeds
8. Working tree is clean (`git status --porcelain` is empty)

## Phase 1 — Version Bump PR

1. Parse bump type from `/release-macos <type>`; ask if missing or ambiguous
   - `major` → increment first component, reset rest (1.2.3 → 2.0.0)
   - `minor` → increment second, reset patch (1.1.4 → 1.2.0)
   - `patch` → increment third, adding if absent (1.2 → 1.2.1)
   - `build` → `MARKETING_VERSION` unchanged, bump build only
2. Read current versions from `project.yml`:
   - `MARKETING_VERSION`
   - `CURRENT_PROJECT_VERSION`
3. Confirm proposed version + build number with user before proceeding
4. Create branch `duncan/release-v{VERSION}-{BUILD}`
5. Bump `MARKETING_VERSION` + `CURRENT_PROJECT_VERSION` in `project.yml`
6. Run `just generate`
7. Update `CHANGELOG.md` — insert new `## [VERSION] - DATE` section; pull changes from `git log` since last tag; present draft to user and prompt if section is empty
8. Commit: `chore: bump version to {VERSION} (build {BUILD})`
9. Push branch + open PR targeting main
10. **Pause** — print exactly: "PR ready at [URL]. Merge it, then reply `merged` to continue."

## Phase 2 — Build & Publish

Resume when user replies `merged`.

11. `git checkout main && git pull`
12. `just prepare-release` — warn user this takes ~5 min (notarization included)
13. `just release-notes`
14. `just publish`
15. Report the GitHub release URL and appcast URL

## Notes

- Edit `project.yml` only — never `*.xcodeproj/project.pbxproj` directly.
- `build/` is gitignored — release assets live there until published.
- Secrets (`SPARKLE_EDDSA_KEY`, `NOTARIZATION_*`) are in `.env`, loaded by `set dotenv-load := true`.
