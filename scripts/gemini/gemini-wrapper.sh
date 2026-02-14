#!/usr/bin/env bash

# --- Config ---
IMAGE_NAME="my-gemini-cli"
GEMINI_HOME="$HOME/.local/share/$IMAGE_NAME"
CACHE_DIR="$HOME/.cache/$IMAGE_NAME"
ENV_FILE="$GEMINI_HOME/.env"
GLOBAL_RULES="$GEMINI_HOME/GEMINI.md"
LOCAL_RULES="$(pwd)/GEMINI.md"
HASH_FILE="$CACHE_DIR/hash"
DOCKERFILE="$CACHE_DIR/Dockerfile"
UPDATE_CHECK_FILE="$CACHE_DIR/last_update_check"
UPDATE_INTERVAL_DAYS=7
CPU_LIMIT="4"
MEM_LIMIT="8g"
BASE_IMAGE="tgagor/gemini-cli:latest"

# --- Help Menu ---
print_usage() {
  cat << EOF
Usage: gemini [options] [prompt]

Options:
  -m <model>    Specify model (default: gemini-2.5-flash)
  --setup       Save API key to $ENV_FILE
  --cleanup     Wipe chat history and cache
  --update      Force update image
  -h, --help    Show this message

Context:
  Rules are read from $GLOBAL_RULES
  and $(pwd)/GEMINI.md (if present).
EOF
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then print_usage; exit 0; fi

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
mkdir -p "$GEMINI_HOME"
mkdir -p "$CACHE_DIR"

if [[ "$1" == "--setup" ]]; then
  read -sp "Enter Gemini API Key: " USER_KEY
  echo "GEMINI_API_KEY=$USER_KEY" > "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  echo -e "\n🔑 Key saved to $ENV_FILE"
  exit 0
fi

if [[ "$1" == "--cleanup" ]]; then
  rm -rf "$GEMINI_HOME/history.json" "$GEMINI_HOME/cache"
  echo "🧹 Cleaned history."
  exit 0
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Error: Missing $ENV_FILE"
  echo "Run 'gemini --setup' first to configure your API key."
  exit 1
fi

# Determine if we should check for a new base image
FORCE_UPDATE=false
if [[ "$1" == "--update" ]]; then
    FORCE_UPDATE=true
    shift # remove --update from the arguments
fi

# Define the Dockerfile
DOCKER_CONTENT=$(cat <<EOF
FROM $BASE_IMAGE
USER root
RUN apk add --no-cache dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/local/sbin/docker-entrypoint.sh", "gemini"]
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
    echo "🔄 Rebuilding $IMAGE_NAME (upstream update or script change detected)..."
    $ENGINE build -q -t "$IMAGE_NAME" -f "$DOCKERFILE" "$CACHE_DIR" --label "app=$IMAGE_NAME"
    $ENGINE image prune -f --filter "label=app=$IMAGE_NAME" >/dev/null 2>&1
fi

# Handle Model Selection
MODEL="gemini-2.5-flash"
if [[ "$1" == "-m" ]]; then
  MODEL="$2"
  shift 2
fi

# Mounts
MOUNTS="-v $GEMINI_HOME:/home/gemini/.gemini"
if [ -f "$LOCAL_RULES" ]; then
  MOUNTS="$MOUNTS -v $LOCAL_RULES:/home/gemini/workspace/.gemini/PROJECT.md"
fi

# Determine if we need -it for interactive session
INTERACTIVE_FLAG=""
[ -t 0 ] && INTERACTIVE_FLAG="--tty"

# Run the container
docker run -i $INTERACTIVE_FLAG --rm \
  --cpus="$CPU_LIMIT" --memory="$MEM_LIMIT" \
  --env-file "$ENV_FILE" \
  $MOUNTS \
  $IMAGE_NAME --model "$MODEL" "$@"

