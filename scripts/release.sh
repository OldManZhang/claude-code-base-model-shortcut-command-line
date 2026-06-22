#!/bin/bash
#
# scripts/release.sh — bump VERSION + CHANGELOG + git tag in one shot.
#
# Usage: ./scripts/release.sh <new-version>
# Example: ./scripts/release.sh 0.2.4
#
# Validates:
#   - new-version matches X.Y.Z
#   - working tree is clean
#   - currently on main branch
#   - new-version > current VERSION
#   - CHANGELOG.md exists and contains `## [Unreleased]`
#
# Does:
#   - moves [Unreleased] section content into `## [vNEW] - <today>`
#   - resets [Unreleased] to empty template
#   - writes new VERSION
#   - commits VERSION + CHANGELOG.md
#   - creates annotated git tag v<NEW>
#
# Does NOT:
#   - git push (user must do this manually)

set -euo pipefail

# --- Args & paths ----------------------------------------------------------

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new-version>" >&2
    echo "Example: $0 0.2.4" >&2
    exit 2
fi

NEW_VERSION="$1"
# Resolve script's directory (handles `./script`, `../script`, and absolute paths).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$REPO_ROOT/VERSION"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"

# --- Helpers ---------------------------------------------------------------

die() { echo "ERROR: $*" >&2; exit 1; }

ver_gt() {
    # $1 > $2 ?  (X.Y.Z strict compare, zero-pad-safe)
    local IFS=.
    local -a a=($1) b=($2)
    for i in 0 1 2; do
        local ai="${a[$i]:-0}" bi="${b[$i]:-0}"
        if [ "$ai" -gt "$bi" ]; then return 0; fi
        if [ "$ai" -lt "$bi" ]; then return 1; fi
    done
    return 1  # equal -> not greater
}

# --- Pre-flight checks -----------------------------------------------------

[[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] \
    || die "new-version '$NEW_VERSION' is not in X.Y.Z format"

cd "$REPO_ROOT"

command -v git >/dev/null \
    || die "git not found in PATH"

[ -f "$VERSION_FILE" ] \
    || die "VERSION file not found at $VERSION_FILE"

[ -f "$CHANGELOG_FILE" ] \
    || die "CHANGELOG.md not found at $CHANGELOG_FILE"

CURRENT_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
[ -n "$CURRENT_VERSION" ] \
    || die "VERSION file is empty"

ver_gt "$NEW_VERSION" "$CURRENT_VERSION" \
    || die "new version ($NEW_VERSION) must be greater than current ($CURRENT_VERSION)"

# Reject if new version already tagged (avoid silent overwrite)
if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
    die "tag v$NEW_VERSION already exists locally"
fi

# Working tree must be clean (ignoring VERSION / CHANGELOG.md which we are about to touch).
if ! git diff --quiet -- VERSION CHANGELOG.md 2>/dev/null \
   || ! git diff --cached --quiet -- VERSION CHANGELOG.md 2>/dev/null \
   || [ -n "$(git status --porcelain -- ':!VERSION' ':!CHANGELOG.md')" ]; then
    die "working tree has uncommitted changes outside VERSION/CHANGELOG.md. Commit or stash first."
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[ "$CURRENT_BRANCH" = "main" ] \
    || die "must be on 'main' branch (currently on '$CURRENT_BRANCH')"

grep -q '^## \[Unreleased\]' "$CHANGELOG_FILE" \
    || die "CHANGELOG.md missing '## [Unreleased]' section"

# --- Mutate CHANGELOG.md ---------------------------------------------------

TODAY="$(date +%Y-%m-%d)"

# awk script: capture [Unreleased] body, reset to empty template, insert new version section.
NEW_VERSION="$NEW_VERSION" TODAY="$TODAY" awk '
    BEGIN { state = "before"; captured = "" }

    /^## \[Unreleased\]/ {
        print
        state = "in_unreleased"
        next
    }

    state == "in_unreleased" {
        if (/^## \[/) {
            # End of [Unreleased]. Emit empty template + new version section.
            print ""
            print "### Added"
            print ""
            print "### Changed"
            print ""
            print "### Fixed"
            print ""
            print "## [v" ENVIRON["NEW_VERSION"] "] - " ENVIRON["TODAY"]
            print ""
            # Strip leading blank lines that came from the line right after
            # the [Unreleased] header, so the new section starts cleanly.
            sub(/^[[:space:]]+/, "", captured)
            printf "%s", captured
            print
            state = "after"
            next
        }
        captured = captured $0 "\n"
        next
    }

    { print }
' "$CHANGELOG_FILE" > "$CHANGELOG_FILE.tmp"

mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"

# --- Write VERSION ---------------------------------------------------------

echo "$NEW_VERSION" > "$VERSION_FILE"

# --- Commit + tag ----------------------------------------------------------

git add VERSION CHANGELOG.md
git commit -m "release: v${NEW_VERSION}"
git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}"

cat <<EOF

✓ Released v${NEW_VERSION}
  - VERSION        → $NEW_VERSION
  - CHANGELOG.md   → [v${NEW_VERSION}] section created from [Unreleased]
  - commit + tag   → v${NEW_VERSION}

Next steps (run manually):
  git push origin main --tags

After push, users running:
  curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh
will pick up v${NEW_VERSION} automatically.
EOF
