#!/usr/bin/env bash
#
# mt (media toolbox) - run a containerized command (yt-dlp, ffmpeg, ffprobe, ...)
# against the current directory, as if it were installed locally.
#
#   mt yt-dlp '<link>'
#   mt ffmpeg -i in.mp4 out.mkv

set -euo pipefail

CMD_NAME='mt'
BUILD_DIR="$HOME/repo/personal/dotfiles/scripts/media-toolbox"
IMAGE_NAME="media-toolbox:latest"
CPUS="${CPUS:-4}"
MEMORY="${MEMORY:-8g}"

if [[ "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: mt [--rebuild] <command> [args...]
       mt --help

Run a containerized command (yt-dlp, ffmpeg, imagemagick, ...) against the
current directory, as if it were installed locally.

Options:
  --rebuild     Force a cache-busted rebuild of the image (picks up updates).
  --help        Show this help and exit.

Env vars:
  CPUS, MEMORY  Container resource limits (default: 4, 8g).

Setup:
  Nothing to do - the first invocation builds the image automatically. Put
  mt on your $PATH to use it from anywhere. Run it from the directory you
  want output written to - it bind-mounts $PWD and runs as your host UID/GID.

Examples:
  mt yt-dlp '<link>'
  mt yt-dlp -x --audio-format mp3 '<link>'    audio only
  mt yt-dlp --downloader aria2c '<link>'      faster, multi-connection
  mt ffmpeg -i in.mp4 out.mkv
  mt ffprobe -show_format -show_streams in.mp4
  mt mediainfo in.mp4
  mt magick cover.jpg -resize 500x500 cover-small.jpg
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
  build_flags=()
  $rebuild && build_flags+=(--no-cache)
  docker build "${build_flags[@]}" -t "$IMAGE_NAME" "$BUILD_DIR"
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
