#!/usr/bin/env bash

# Wrapper for apfel skills (https://github.com/Arthur-Ficial/apfel/tree/main/demo)
# Caches the 'demo' directory from the repo and makes them available as the first argument to apfel.

CACHE_DIR="${HOME}/.cache/apfel-wrapper"
REPO_URL="https://github.com/Arthur-Ficial/apfel.git"
REPO_DIR="${CACHE_DIR}/repo"
DEMO_DIR="${REPO_DIR}/demo"

if [ "$1" == "--refresh-skills" ]; then
  mkdir -p "${CACHE_DIR}"

  if [ ! -d "${REPO_DIR}/.git" ]; then
    git clone -b main --single-branch --depth 1 --filter=blob:none --sparse "${REPO_URL}" "${REPO_DIR}"
    cd "${REPO_DIR}" || exit 1
    git sparse-checkout set demo
  else
    cd "${REPO_DIR}" || exit 1
    git pull
  fi

  exit 0
fi

if [ "$1" == "--list-skills" ]; then
  find "${DEMO_DIR}" -maxdepth 1 -mindepth 1 -perm -111 -exec sh -c '"$1" --help | head -1' _ {} \;
  exit 0
fi

# execute skills by setting $1 as the skill name
if [ -n "$1" ] && [ -x "${DEMO_DIR}/$1" ]; then
  EXE_NAME="$1"
  shift
  exec "${DEMO_DIR}/${EXE_NAME}" "$@"
  exit $?
fi

# fallback/passthrough
/opt/homebrew/bin/apfel "$@"

