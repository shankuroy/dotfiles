#!/usr/bin/env bash
set -e

# This script is designed to be run as "mt". If it is saved under a different
# filename, you should create a symlink to a location in your PATH. For example:
#
#   ln -s ~/scripts/media-toolbox/media-toolbox.sh ~/scripts/bin/mt
#
# Make sure "~/scripts/bin" is in your PATH so you can call it simply as "mt".

print_usage() {
  cat <<EOF
===============================================================================
MEDIA TOOLBOX (mt)
===============================================================================
A containerized environment for media processing.

CORE COMPONENTS:
  - Base Image: ghcr.io/jauderho/yt-dlp (Alpine-based, includes Deno & Python)
  - yt-dlp:     Latest version with JavaScript support (Deno) and Python.
  - ffmpeg:     Hardware-aware media conversion (from base image).
  - aria2c:     Added for parallel download support when needed.

KEY FEATURES:
  - Smart Updates: Checks for upstream image updates every 7 days (configurable).
  - Auto-Metadata: Automatically embeds thumbnails, metadata, and subtitles.
  - Offline Mode: ffmpeg runs with --network=none for privacy and safety.
  - Instant Start: Skips network checks on non-update days for speed.
  - Signal Handling: Uses dumb-init to handle Ctrl+C gracefully.

USAGE:
  mt yt-dlp [args] <url>    Download video with auto-metadata.
  mt ffmpeg [args]          Run ffmpeg commands offline on local files.
  mt --update [command]     Force a check for a newer base image immediately.
  mt <tool> [args]          Run any tool available in the Alpine base (sh, aria2c).

EXAMPLES:
  # Download and embed everything
  mt yt-dlp "https://youtu.be/xxxx"

  # Convert video to webm offline
  mt ffmpeg -i input.mp4 output.webm

  # Force update the toolbox and then download
  mt --update yt-dlp "https://youtu.be/xxxx"

===============================================================================
EOF
}

IMAGE="media-toolbox"
CACHE_DIR="$HOME/.cache/$IMAGE"
HASH_FILE="$CACHE_DIR/hash"
DOCKERFILE="$CACHE_DIR/Dockerfile"
UPDATE_CHECK_FILE="$CACHE_DIR/last_update_check"

# CONFIGURATION
UPDATE_INTERVAL_DAYS=7
CPU_LIMIT="4"
MEM_LIMIT="8g"
BASE_IMAGE="ghcr.io/jauderho/yt-dlp:latest"
CONCURRENT_FRAGMENTS=4

# Show usage if no args or -h/--help
if [ $# -eq 0 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

# Determine if we should check for a new base image
FORCE_UPDATE=false
if [[ "$1" == "--update" ]]; then
    FORCE_UPDATE=true
    shift # remove --update from the arguments
fi

# Detect container engine
if command -v docker >/dev/null 2>&1; then
    ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
    ENGINE="podman"
else
    echo "ERROR: requires docker or podman"
    exit 1
fi

# Create cache directory if missing
mkdir -p "$CACHE_DIR"

# Define the Toolbox Dockerfile
BASE_IMAGE="ghcr.io/jauderho/yt-dlp:latest"
DOCKER_CONTENT=$(cat <<EOF
FROM $BASE_IMAGE
USER root
# Install additional tools
RUN apk add --no-cache aria2
# Override the fixed ENTRYPOINT to allow running any command
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
WORKDIR /work
EOF
)

SHOULD_CHECK_UPSTREAM=false
if [ ! -f "$UPDATE_CHECK_FILE" ] || [ "$FORCE_UPDATE" = true ]; then
    SHOULD_CHECK_UPSTREAM=true
else
    LAST_CHECK_DAY=$(cat "$UPDATE_CHECK_FILE")
    DAYS_SINCE=$(( CURRENT_DAY_COUNT - LAST_CHECK_DAY ))
    if [ "$DAYS_SINCE" -ge "$UPDATE_INTERVAL_DAYS" ]; then
        SHOULD_CHECK_UPSTREAM=true
    fi
fi

if [ "$SHOULD_CHECK_UPSTREAM" = true ]; then
    echo "🔍 Checking for upstream updates..."
    if $ENGINE pull -q $BASE_IMAGE > /dev/null 2>&1; then
        IMAGE_DIGEST=$($ENGINE inspect --format='{{.Id}}' $BASE_IMAGE)
        CURRENT_DAY_COUNT=$(( $(date +%s) / 86400 ))
        echo "$CURRENT_DAY_COUNT" > "$UPDATE_CHECK_FILE"
        COMBINED_HASH=$(printf "%s\n%s" "$IMAGE_DIGEST" "$DOCKER_CONTENT" | sha256sum | awk '{print $1}')
    else
        echo "⚠️ Network unreachable. Using cached version."
        [ -f "$HASH_FILE" ] && COMBINED_HASH=$(cat "$HASH_FILE")
    fi
else
    # use the last known hash
    COMBINED_HASH=$(cat "$HASH_FILE" 2>/dev/null || echo "init")
fi

# Rebuild logic
REBUILD=false
if [ ! -f "$HASH_FILE" ] || [ "$(cat "$HASH_FILE")" != "$COMBINED_HASH" ]; then
    REBUILD=true
    echo "$COMBINED_HASH" > "$HASH_FILE"
    echo "$DOCKER_CONTENT" > "$DOCKERFILE"
fi

if [ "$REBUILD" = true ]; then
    echo "🔄 Rebuilding Toolbox (Upstream update or script change detected)..."
    $ENGINE build -q -t "$IMAGE" -f "$DOCKERFILE" "$CACHE_DIR" --label "media-toolbox=yes"
    $ENGINE image prune -f --filter "label=media-toolbox=yes" >/dev/null 2>&1
fi

# Execution logic
CMD="$1"
shift || true

# Network: yt-dlp/aria2c are online, everything else is offline
case "$CMD" in
    yt-dlp|aria2c) NETWORK="bridge" ;;
    *)             NETWORK="none"   ;;
esac

if [ "$CMD" = "yt-dlp" ]; then
    exec $ENGINE run --rm -it \
        --cpus="$CPU_LIMIT" --memory="$MEM_LIMIT" --network="$NETWORK" \
        -v "$PWD":/work -w /work \
        "$IMAGE" yt-dlp \
        --concurrent-fragments $CONCURRENT_FRAGMENTS \
        --embed-metadata \
        --embed-thumbnail \
        --embed-subs \
        "$@"
else
    exec $ENGINE run --rm -it \
        --cpus="$CPU_LIMIT" --memory="$MEM_LIMIT" --network="$NETWORK" \
        -v "$PWD":/work -w /work \
        "$IMAGE" "$CMD" "$@"
fi

