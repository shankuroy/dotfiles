#!/usr/bin/env bash

set -euo pipefail

CMD_NAME='alpine'
BUILD_DIR="$HOME/repo/personal/dotfiles/scripts/alpine-toolbox"
IMAGE_NAME="alpine-toolbox:latest"
CPUS="${CPUS:-4}"
MEMORY="${MEMORY:-8g}"

if [[ "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage: $CMD_NAME [--rebuild] <command> [args...]
       $CMD_NAME --help

Run a containerized command (yt-dlp, ffmpeg, imagemagick, ...) against the
current directory, as if it were installed locally.

Options:
  --rebuild     Force a cache-busted rebuild of the image (picks up updates).
  --help        Show this help and exit.

Env vars:
  CPUS, MEMORY  Container resource limits (default: 4, 8g).

Setup:
  Nothing to do - the first invocation builds the image automatically. Put
  $CMD_NAME on your \$PATH to use it from anywhere. Run it from the directory
  you want output written to - it bind-mounts \$PWD and runs as your host
  UID/GID.

Examples:
  $CMD_NAME yt-dlp '<link>'
  $CMD_NAME yt-dlp -x --audio-format mp3 '<link>'    audio only
  $CMD_NAME yt-dlp --downloader aria2c '<link>'      faster, multi-connection
  $CMD_NAME ffmpeg -i in.mp4 out.mkv
  $CMD_NAME ffprobe -show_format -show_streams in.mp4
  $CMD_NAME mediainfo in.mp4
  $CMD_NAME magick cover.jpg -resize 500x500 cover-small.jpg
EOF
  exit 0
fi

rebuild=false
if [[ "${1:-}" == "--rebuild" ]]; then
  rebuild=true
  shift
fi

if $rebuild || ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  if [[ ! -f "$BUILD_DIR/Dockerfile" ]]; then
    echo "$CMD_NAME: ERROR: could not find $BUILD_DIR/Dockerfile" >&2
    exit 1
  fi
  echo "$CMD_NAME: building '$IMAGE_NAME'..."
  if $rebuild; then
    docker build --no-cache -t "$IMAGE_NAME" "$BUILD_DIR"
  else
    docker build -t "$IMAGE_NAME" "$BUILD_DIR"
  fi
fi

tty_flags=(-i)
if [ -t 0 ] && [ -t 1 ]; then
  tty_flags+=(-t)
fi

exec docker run --rm "${tty_flags[@]}" \
  --cpus "$CPUS" \
  --memory "$MEMORY" \
  --user "$(id -u):$(id -g)" \
  -v "$PWD:/data" \
  "$IMAGE_NAME" "$@"
