#!/usr/bin/env bash

# Container Dispatch
#
# Dispatches a command to a container, building that container if needed.
#
# Create a wrapper script like below, ensuring the following:
# - this script is in $PATH as container_dispatch
# - required environment variables are defined
#
#-------------------------------------------------------------------------------
# #!/usr/bin/env bash
#
# # Define IMAGE_NAME
# IMAGE_NAME="media-toolbox"
#
# # Define APP_HELP_CUSTOM
# read -r -d '' APP_HELP_CUSTOM << 'EOF'
#   mt yt-dlp [args] '<url>'  Download video from URL using yt-dlp
#   mt <command> [args]       Run other commands in the Alpine base, e.g.:
#   mt ffmpeg [args]          Run ffmpeg
# EOF
#
# # Define and ensure DOCKERFILE_CONTENT contains: LABEL app="${IMAGE_NAME}"
# # That label is used for pruning images when rebuilding.
# read -r -d '' DOCKERFILE_CONTENT << EOF
# FROM alpine:latest
# LABEL app="${IMAGE_NAME}"
# RUN apk add --no-cache ca-certificates dumb-init yt-dlp
# WORKDIR /work
# ENTRYPOINT ["/usr/bin/dumb-init", "--"]
# EOF
#
# # Pass variables to container_dispatch
# APP_NAME="MEDIA TOOLBOX (mt)" \
# APP_DESC="A containerized environment for media processing." \
# CPU_LIMIT="4" \
# MEM_LIMIT="8g" \
# IMAGE_NAME="$IMAGE_NAME" \
# APP_HELP_CUSTOM="$APP_HELP_CUSTOM" \
# DOCKERFILE_CONTENT="$DOCKERFILE_CONTENT" \
# exec container_dispatch "$@"
#
# ------------------------------------------------------------------------------

# Validate that required variables are provided by the wrapper script
if [[ -z "$IMAGE_NAME" ]] || [[ -z "$DOCKERFILE_CONTENT" ]]; then
  echo "ERROR: IMAGE_NAME and DOCKERFILE_CONTENT must be defined by the wrapper script."
  exit 1
fi

# Set default values for optional variables if not provided
APP_NAME="${APP_NAME:-$IMAGE_NAME}"
APP_DESC="${APP_DESC:-A containerized environment.}"
CPU_LIMIT="${CPU_LIMIT:-4}"
MEM_LIMIT="${MEM_LIMIT:-8g}"
CALLING_CMD="$(basename "$0")"

# Show usage if no args or -h/--help
if [ $# -eq 0 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  cat <<EOF
===============================================================================
${APP_NAME}
===============================================================================
${APP_DESC}

${APP_HELP_CUSTOM}

BASE COMMANDS:
  ${CALLING_CMD} < -h | --help >        Show this help message
  ${CALLING_CMD} --rebuild              Rebuild the image

===============================================================================
EOF
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

# Handle rebuild flag (or rebuild if the image is missing)
if [[ "$1" == "--rebuild" ]] || [[ -z $($ENGINE images -q "$IMAGE_NAME" 2>/dev/null) ]]; then
  echo "🚧 Rebuilding $IMAGE_NAME image with $ENGINE..."
  
  # Feed the DOCKERFILE_CONTENT environment variable into the build command
  echo "$DOCKERFILE_CONTENT" | $ENGINE build -t "$IMAGE_NAME" -f - .

  BUILD_STATUS="$?"
  if [[ "$BUILD_STATUS" -eq 0 ]]; then
    echo "Build successful. Pruning old layers..."
    $ENGINE image prune -f --filter "label=app=$IMAGE_NAME"
  else
    echo "Build failed. Check the output above."
  fi

  if [[ "$1" == "--rebuild" ]]; then
    exit $BUILD_STATUS
  fi
fi

# Run container, passing through arguments
$ENGINE run --rm -it \
  --cpus="$CPU_LIMIT" --memory="$MEM_LIMIT" \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd):/work:rw" \
  "$IMAGE_NAME" "$@"

