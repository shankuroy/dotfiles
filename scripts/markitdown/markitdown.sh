#!/usr/bin/env bash

# convert files to markdown
# https://github.com/microsoft/markitdown
#
# git clone git@github.com:microsoft/markitdown.git

INPUT_FILE="${1}"
OUTPUT_FILE="${2}"
IMAGE_TAG="microsoft/markitdown:v0.1.7"

if [[ -z "${INPUT_FILE}" || -z "${OUTPUT_FILE}" ]]; then
  echo "Usage: $0 <input_file> <output_file>" >&2
  exit 1
fi

docker run --rm -i "$IMAGE_TAG" < "$INPUT_FILE" > "$OUTPUT_FILE"

