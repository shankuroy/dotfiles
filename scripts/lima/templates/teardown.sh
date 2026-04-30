#!/usr/bin/env bash

NAME="${1:-ubuntu-lts}"
CLONE="$NAME-clone"

GREEN='\033[32m'
DEFAULT='\033[0m'

info() {
  printf "${GREEN}[INFO]${DEFAULT} %s\n" "$1"
}

TIMEFORMAT="[TIME] real %lR, user %lU, sys %lS"

time {

  info "tearing down $NAME (and clone $CLONE)"

  info "stopping $NAME"
  time limactl stop -f "$NAME"

  info "deleting $NAME"
  time limactl delete -f "$NAME"

  info "stopping $CLONE"
  time limactl stop -f "$CLONE"

  info "deleting $CLONE"
  time limactl delete -f "$CLONE"

  info "listing lima instances"
  limactl list

  info "DONE!"

}

