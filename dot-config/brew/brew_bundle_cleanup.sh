#!/usr/bin/env sh

# Brewfile Profile Builder
# ------------------------
# This script generates a Homebrew Brewfile by concatenating a required
# Brewfile-core with one or more profile-specific Brewfiles.
#
# Profiles are passed as command-line arguments (e.g. "personal", "work").
# Each profile corresponds to a file named:
#
#   Brewfile-<profile>
#
# located in the configured BASE_DIR.
#
# Before doing anything, the script validates that all requested profile
# files exist. If any are missing, it aborts without modifying the output.
#
# On success, the concatenated Brewfile is written to OUTPUT_FILE and then
# used to sync Homebrew packages via `brew bundle`.
#
# Usage:
#   ./brew_bundle_cleanup.sh <profile> [profile ...]
#

# Configurable base directory
BASE_DIR="${HOME}/.config/brew"

# Files
CORE_FILE="${BASE_DIR}/Brewfile-core"
OUTPUT_FILE="${BASE_DIR}/Brewfile"

# Require at least one profile
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <profile> [profile ...]" >&2
    echo >&2
    echo "Available profiles:" >&2
    ls -1 "${BASE_DIR}"/Brewfile-* 2>/dev/null \
        | sed 's#.*/Brewfile-##' \
        | grep -v '^core$' >&2
    exit 1
fi


# Check that core Brewfile exists
if [ ! -f "$CORE_FILE" ]; then
    echo "Warning: missing required file: $CORE_FILE" >&2
    exit 1
fi

# Validate all profile files first
MISSING=0
for profile in "$@"; do
    PROFILE_FILE="${BASE_DIR}/Brewfile-${profile}"
    if [ ! -f "$PROFILE_FILE" ]; then
        echo "Warning: missing profile file: $PROFILE_FILE" >&2
        MISSING=1
    fi
done

# Abort if any profile was missing
if [ "$MISSING" -ne 0 ]; then
    echo "Aborting: one or more profiles not found." >&2
    exit 1
fi

# All checks passed — generate Brewfile
{
    cat "$CORE_FILE"
    for profile in "$@"; do
        cat "${BASE_DIR}/Brewfile-${profile}"
    done
} > "$OUTPUT_FILE"

echo "Brewfile generated successfully at ${OUTPUT_FILE}."

echo "Syncing brew packages with ${OUTPUT_FILE}"

brew update
brew bundle install --file="${OUTPUT_FILE}"
brew bundle cleanup --force --file="${OUTPUT_FILE}"
brew upgrade
brew cleanup
brew autoremove

echo "⭐️ DONE!"

