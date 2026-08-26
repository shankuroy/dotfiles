#!/usr/bin/env bash

LAST_RUN_FILE='.last_run_epoch'

if [[ -f "${LAST_RUN_FILE}" ]]; then
  printf 'Last run: '
  date -r "$(cat $LAST_RUN_FILE)"
else
  echo "ERROR: missing file: $LAST_RUN_FILE" >&2
  return 1
fi

