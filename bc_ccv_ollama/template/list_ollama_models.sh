#!/usr/bin/env bash
set -euo pipefail

# Use either the passed directory or the default if nothing passed in
MANIFESTS_DIR="${1:-/opt/apps/models/ollama-slim/manifests}"

# Convert to full path rather than relative
MANIFESTS_DIR="$(realpath "$MANIFESTS_DIR")"

if [[ ! -d "$MANIFESTS_DIR" ]]; then
  echo ""
  exit 0
fi

find "$MANIFESTS_DIR" -type f | while read -r file; do
  file=$(realpath "$file")
  rel="${file#"$MANIFESTS_DIR"/}"
  rel="${rel#*/}"               # Remove registry prefix
  tag="${rel##*/}"              # Tag (last part)
  without_tag="${rel%/*}"       # Remainder
  model="${without_tag##*/}"    # Model name
  namespace="${without_tag%/*}" # Namespace
  if [[ "$namespace" == "library" ]]; then
    echo "${model}:${tag}"
  else
    echo "${namespace}/${model}:${tag}"
  fi
done | sort -u | paste -sd, -   # take standard input, join with comma delim and output as a single line.
