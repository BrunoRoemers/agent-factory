#!/usr/bin/env zsh
# Downloads Docker AI Sandboxes docs from docs.docker.com.
# Starts from /ai/sandboxes.md, follows all relative links under /ai/sandboxes/, saves .md files locally.

set -euo pipefail

PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

BASE_URL="https://docs.docker.com"
START_PATH="/ai/sandboxes.md"
DOCS_DIR="$(cd "$(dirname "$0")" && pwd)"

declare -A visited

download() {
  local doc_path="$1"
  [[ "${visited[$doc_path]+_}" ]] && return
  visited[$doc_path]=1

  local url="${BASE_URL}${doc_path}"
  # Convert URL path to a local filename, preserving directory structure
  local rel="${doc_path#/}"       # strip leading slash
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
