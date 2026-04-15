# release-macos — Documentation

## Overview

A two-phase release workflow for macOS apps using Sparkle + EdDSA signing.

**Phase 1** — bump version, update CHANGELOG, open a PR.
**Phase 2** — build a signed/notarized DMG, generate appcast item, publish to GitHub Pages.

## Prerequisites

| Requirement | Notes |
|---|---|
| `just` ≥ 1.14 | Needs `home_directory()` function |
| `xcodebuild` | Xcode CLI tools |
| `codesign`, `hdiutil`, `xcrun` | macOS system tools |
| `gh` CLI | Installed + authenticated (`gh auth login`) |
| Developer ID certificate | In keychain |
| Python 3 | For release notes generation |

## Required Environment Variables

Set in `.env` (loaded via `set dotenv-load := true` in justfile):

| Variable | Required | Description |
|---|---|---|
| `SPARKLE_EDDSA_KEY` | Yes | EdDSA private key (base64) for signing the DMG |
| `NOTARIZATION_KEY_PATH` | No | Path to `.p8` API key file — skips notarization if absent |
| `NOTARIZATION_KEY_ID` | No | App Store Connect API key ID |
| `NOTARIZATION_ISSUER` | No | App Store Connect issuer UUID |

## Onboarding a New Project

Add three config vars and an import to the project's `justfile`:

```justfile
# Release config
app_name      := "MyApp"
releases_repo := "owner/myapp-releases"
sign_identity := "Developer ID Application: Your Name (TEAMID)"

import '{{home_directory()}}/.claude/skills/release-macos/release.justfile'
```

Ensure the project also has:
- `.env` with `SPARKLE_EDDSA_KEY` (and optionally notarization vars)
- `project.yml` with `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION`
- `ExportOptions.plist` at the project root

Run `just -l` to confirm the three release recipes appear.

## Recipes

| Recipe | Description |
|---|---|
| `just prepare-release` | Build signed + notarized DMG into `build/` |
| `just release-notes` | Generate appcast item XML + release notes HTML into `build/appcast/` |
| `just publish` | Tag, create GitHub Release, update appcast on gh-pages |

## Manual Script Usage

To run scripts without `just`, export the required vars and source `.env`:

```bash
set -a; source .env; set +a

# Build DMG
DMG_ASSETS_DIR=~/.claude/skills/release-macos/dmg \
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
~/.claude/skills/release-macos/bin/release MyApp

# Generate appcast item
APP_NAME=MyApp RELEASES_REPO=owner/myapp-releases \
~/.claude/skills/release-macos/bin/generate-appcast-item

# Publish
APP_NAME=MyApp RELEASES_REPO=owner/myapp-releases \
~/.claude/skills/release-macos/bin/publish
```

## Release Repos

The `RELEASES_REPO` GitHub repo is expected to have a `gh-pages` branch serving:

- `appcast.xml` — Sparkle feed
- `notes/v{VERSION}.html` — per-version release notes

The `publish` script creates/updates these on first run.
