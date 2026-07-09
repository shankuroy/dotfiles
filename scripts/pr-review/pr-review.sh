#!/usr/bin/env bash

# pr: lightweight pull request review helper
# - Review mode: creates/reuses a worktree under ../pr-review/<repo>, then opens a diff
# - Cleanup mode: uses fzf to remove one or all review worktrees in that folder

# Exit immediately if a command exits with a non-zero status
set -e

# Initialize variables
USE_GIT=0
POSITIONAL_ARGS=()

# Parse arguments
for arg in "$@"; do
  case $arg in
    --git)
      USE_GIT=1
      ;;
    -h|--help)
      echo "Usage:"
      echo "  pr [--git] <source_branch> [dest_branch]"
      echo "  pr cleanup"
      echo "Defaults: dest_branch = develop"
      exit 0
      ;;
    *)
      POSITIONAL_ARGS+=("$arg")
      ;;
  esac
done

# Ensure we are inside a Git repository and get the root path
if ! GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "Error: This command must be run from inside a Git repository."
  exit 1
fi

REPO_NAME=$(basename "$GIT_ROOT")
PARENT_DIR=$(dirname "$GIT_ROOT")
PR_REVIEW_DIR="$PARENT_DIR/pr-review/$REPO_NAME"

COMMAND="${POSITIONAL_ARGS[0]}"

if [[ "$COMMAND" == "cleanup" ]]; then
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is required for 'pr cleanup'."
    exit 1
  fi

  ALL_WORKTREES=()
  while IFS= read -r line; do
    ALL_WORKTREES+=("$line")
  done < <(git worktree list --porcelain | awk '/^worktree / { print substr($0, 10) }')

  PR_REVIEW_WORKTREES=()
  for worktree in "${ALL_WORKTREES[@]}"; do
    if [[ "$worktree" == "$PR_REVIEW_DIR" || "$worktree" == "$PR_REVIEW_DIR/"* ]]; then
      PR_REVIEW_WORKTREES+=("$worktree")
    fi
  done

  if [[ ${#PR_REVIEW_WORKTREES[@]} -eq 0 ]]; then
    echo "No worktrees found under $PR_REVIEW_DIR."
    exit 0
  fi

  selected_worktree=$(
    {
      echo "All"
      printf '%s\n' "${PR_REVIEW_WORKTREES[@]}"
    } | fzf --prompt="Select worktree to clean up: " --height=40% --reverse || true
  )

  if [[ -z "$selected_worktree" ]]; then
    echo "Cleanup cancelled."
    exit 0
  fi

  if [[ "$selected_worktree" == "All" ]]; then
    TARGET_WORKTREES=("${PR_REVIEW_WORKTREES[@]}")
  else
    TARGET_WORKTREES=("$selected_worktree")
  fi

  echo "The following worktree(s) will be removed:"
  printf '  - %s\n' "${TARGET_WORKTREES[@]}"
  read -r -p "Continue? [Y/n] " response
  case "$response" in
    [nN][oO]|[nN])
      echo "Cleanup cancelled."
      exit 0
      ;;
  esac

  for worktree in "${TARGET_WORKTREES[@]}"; do
    echo "Removing $worktree..."
    git worktree remove -f "$worktree"
  done

  echo "Cleanup complete."
  exit 0
fi

SOURCE_BRANCH="${POSITIONAL_ARGS[0]}"
DEST_BRANCH="${POSITIONAL_ARGS[1]:-develop}"

# Ensure source branch is provided
if [[ -z "$SOURCE_BRANCH" ]]; then
  echo "Error: Missing source_branch."
  echo "Usage:"
  echo "  pr [--git] <source_branch> [dest_branch]"
  echo "  pr cleanup"
  exit 1
fi

WORKTREE_DIR="$PR_REVIEW_DIR"

echo "Fetching branches from origin..."
git fetch origin "$SOURCE_BRANCH" "$DEST_BRANCH" 2>/dev/null || git fetch origin "$SOURCE_BRANCH" || true

# Handle existing worktree directory
RECREATE=1
if [[ -d "$WORKTREE_DIR" ]]; then
  # Prompt the user. Default to y (Switch to existing) if they press Enter.
  read -r -p "Existing worktree found for $SOURCE_BRANCH. Switch to existing (y) or recreate (n)? [Y/n] " response
  case "$response" in
    [nN][oO]|[nN])
      RECREATE=1
      ;;
    *)
      RECREATE=0
      ;;
  esac
fi

if [[ $RECREATE -eq 1 ]]; then
  if [[ -d "$WORKTREE_DIR" ]]; then
    echo "Cleaning up existing worktree..."
    git worktree remove -f "$WORKTREE_DIR"
  fi
  echo "Creating worktree at $WORKTREE_DIR..."
  # Using --detach prevents creating local branch conflicts during reviews
  git worktree add --detach "$WORKTREE_DIR" "origin/$SOURCE_BRANCH"
else
  echo "Switching to existing worktree..."
fi

# Navigate into the worktree
cd "$WORKTREE_DIR"

# Determine which diff tool to use
if [[ $USE_GIT -eq 0 ]] && command -v hunk >/dev/null 2>&1; then
  DIFF_CMD="hunk diff"
  echo "Opening diff with Hunk..."
else
  DIFF_CMD="git diff"
  if [[ $USE_GIT -eq 0 ]]; then
    echo "Hunk not found in PATH. Falling back to Git..."
  else
    echo "Using Git for diff..."
  fi
fi

# Execute the diff using the three-dot merge-base syntax
$DIFF_CMD "$DEST_BRANCH"..."origin/$SOURCE_BRANCH"
