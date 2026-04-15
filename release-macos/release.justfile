# release-macos recipes — imported by project justfiles
# Requires: app_name, releases_repo, sign_identity defined in the importing justfile

# Build a signed DMG ready for notarization
prepare-release: generate
    DMG_ASSETS_DIR=~/.claude/skills/release-macos/dmg \
    SIGN_IDENTITY="{{sign_identity}}" \
    ~/.claude/skills/release-macos/bin/release {{app_name}}

# Generate release notes HTML and appcast item XML into build/appcast/
release-notes:
    APP_NAME={{app_name}} RELEASES_REPO={{releases_repo}} \
    ~/.claude/skills/release-macos/bin/generate-appcast-item

# Publish a release (run after PR merge)
publish:
    APP_NAME={{app_name}} RELEASES_REPO={{releases_repo}} \
    ~/.claude/skills/release-macos/bin/publish
