#!/usr/bin/env bash
# Downloads Docker AI Sandboxes docs from docs.docker.com.
# Starts from /ai/sandboxes.md, follows all relative links under /ai/sandboxes/, saves .md files locally.

set -euo pipefail

BASE_URL="https://docs.docker.com"
START_PATH="/ai/sandboxes.md"
DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A visited

download() {
  local path="$1"
  [[ "${visited[$path]+_}" ]] && return
  visited[$path]=1

  local url="${BASE_URL}${path}"
  # Convert URL path to a local filename, preserving directory structure
  local rel="${path#/}"           # strip leading slash
  local local_file="${DOCS_DIR}/${rel}"
  local local_dir
  local_dir="$(dirname "$local_file")"

  mkdir -p "$local_dir"

  echo "Downloading: $url"
  if ! curl -sf "$url" -o "$local_file"; then
    echo "  WARN: failed to download $url" >&2
    return
  fi

  # Extract links that point to /ai/sandboxes paths
  # Matches markdown links like [text](/ai/sandboxes/foo) or [text](/ai/sandboxes/foo.md)
  while IFS= read -r link; do
    # Normalize: ensure it ends with .md
    local normalized="$link"
    [[ "$normalized" != *.md ]] && normalized="${normalized%.md}.md"
    # Skip if already visited
    [[ "${visited[$normalized]+_}" ]] && continue
    download "$normalized"
  done < <(grep -oE '\(/ai/sandboxes[^)]*\)' "$local_file" \
             | tr -d '()' \
             | grep -v '^$' \
             | sort -u)
}

download "$START_PATH"
echo "Done. Files saved to: $DOCS_DIR"
