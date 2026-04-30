#!/usr/bin/env bash

NAME="${1:-ubuntu-lts}"
CLONE="$NAME-clone"
TEMPLATE="./$NAME.yml"

GREEN='\e[32m'
DEFAULT='\e[39m'

info() {
  echo -e "$GREEN[INFO]$DEFAULT $1"
}

TIMEFORMAT="[TIME] real %lR, user %lU, sys %lS"

time {

  info "rebuilding $NAME (and clone $CLONE) from template: $TEMPLATE"

  info "stopping $NAME"
  time limactl stop -f "$NAME"

  info "deleting $NAME"
  time limactl delete -f "$NAME"

  info "creating $NAME from template $TEMPLATE"
  time limactl create -y --name "$NAME" "$TEMPLATE"

  info "starting $NAME"
  time limactl start "$NAME" --mount-none

  info "stopping $NAME"
  time limactl stop -f "$NAME"

  info "stopping $CLONE"
  time limactl stop -f "$CLONE"

  info "deleting $CLONE"
  time limactl delete -f "$CLONE"

  info "cloning $NAME to $CLONE"
  time limactl clone "$NAME" "$CLONE" --start --mount-none

  info "listing lima instances"
  limactl list

  info "DONE!"

}

