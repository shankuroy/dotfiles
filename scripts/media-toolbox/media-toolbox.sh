#!/usr/bin/env bash

print_usage() {
  cat <<EOF
===============================================================================
MEDIA TOOLBOX (mt)
===============================================================================
A containerized environment for media processing.

USAGE:
  mt < -h | --help >        Show this help message
  mt --rebuild              Rebuild the image
  mt yt-dlp [args] '<url>'  Download video from URL using yt-dlp
  mt <command> [args]       Run other commands in the Alpine base, e.g.:
  mt ffmpeg [args]          Run ffmpeg

===============================================================================
EOF
}

IMAGE_NAME="media-toolbox"
CPU_LIMIT="4"
MEM_LIMIT="8g"

# Show usage if no args or -h/--help
if [ $# -eq 0 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

# Detect container engine
if docker info >/dev/null 2>&1; then
    ENGINE="docker"
elif podman info >/dev/null 2>&1; then
    ENGINE="podman"
else
    echo "ERROR: requires docker or podman to be running"
    exit 1
fi

# Handle rebuild flag
if [[ "$1" == "--rebuild" ]]; then
  echo "🚧 Rebuilding $IMAGE_NAME image with $ENGINE..."
  cat <<EOF | $ENGINE build -t $IMAGE_NAME -f - .
FROM alpine:latest
LABEL app="$IMAGE_NAME"
RUN apk add --no-cache \
    ca-certificates \
    dumb-init \
    yt-dlp \
    deno
WORKDIR /work
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
EOF

  BUILD_STATUS="$?"
  if [[ "$BUILD_STATUS" -eq 0 ]]; then
    echo "Build successful. Pruning old layers..."
    $ENGINE image prune -f --filter "label=app=$IMAGE_NAME"
  else
    echo "Build failed. Check the output above."
  fi
  exit $BUILD_STATUS
fi

# Run container, passing through arguments
$ENGINE run --rm -it \
  --cpus="$CPU_LIMIT" --memory="$MEM_LIMIT" \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd):/work" \
  $IMAGE_NAME "$@"

