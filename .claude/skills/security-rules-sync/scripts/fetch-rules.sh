#!/usr/bin/env bash
#
# Download secure-coding rule files from TikiTribe/claude-secure-coding-rules at a
# pinned commit and place them under .claude/security-rules/ with a provenance
# header. Also (re)writes .claude/security-rules/SOURCES.md. Fails safe: a bad
# fetch leaves any existing copy untouched and is reported.
#
# Usage:
#   fetch-rules.sh [--ref <sha>] <rule-path> [<rule-path> ...]
#   printf '%s\n' rules/_core/owasp-2025.md ... | fetch-rules.sh [--ref <sha>] -
#
# <rule-path> is repo-relative in the upstream repo, e.g.
#   rules/_core/owasp-2025.md      -> .claude/security-rules/_core/owasp-2025.md
#   rules/languages/python/CLAUDE.md -> .claude/security-rules/languages/python/CLAUDE.md
set -euo pipefail

REPO="TikiTribe/claude-secure-coding-rules"
# Pinned upstream commit for reproducible downloads. Override with --ref to refresh.
DEFAULT_REF="f644d862f89f926537591d64439c067b1e066ffe"
ref="$DEFAULT_REF"

paths=()
while [ $# -gt 0 ]; do
  case "$1" in
    --ref) ref="${2:?--ref needs a value}"; shift 2 ;;
    -)     while IFS= read -r line; do [ -n "$line" ] && paths+=("$line"); done; shift ;;
    -*)    echo "Unknown flag: $1" >&2; exit 2 ;;
    *)     paths+=("$1"); shift ;;
  esac
done
[ ${#paths[@]} -gt 0 ] || { echo "No rule paths given." >&2; exit 2; }

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
dest_base="$root/.claude/security-rules"
sources="$dest_base/SOURCES.md"
mkdir -p "$dest_base"

{
  echo "# Security rule sources"
  echo
  echo "Downloaded by the \`security-rules-sync\` skill from [$REPO](https://github.com/$REPO) (MIT license),"
  echo "pinned at commit \`$ref\`. Do not hand-edit rule files — re-run the skill to refresh."
  echo
  echo "| Local file | Upstream path |"
  echo "| --- | --- |"
} > "$sources"

failed=0
for path in "${paths[@]}"; do
  rel="${path#rules/}"
  dest="$dest_base/$rel"
  url="https://raw.githubusercontent.com/$REPO/$ref/$path"
  tmp="$(mktemp)"

  echo "Fetching $path ..."
  if ! curl --fail --show-error --silent --location "$url" -o "$tmp"; then
    echo "ERROR: fetch failed for $url — existing copy (if any) left intact." >&2
    rm -f "$tmp"; failed=$((failed + 1)); continue
  fi
  if [ ! -s "$tmp" ]; then
    echo "ERROR: empty body for $url — skipping." >&2
    rm -f "$tmp"; failed=$((failed + 1)); continue
  fi

  mkdir -p "$(dirname "$dest")"
  {
    printf '<!-- Source: %s @ %s (MIT). Do not edit by hand; refresh via the security-rules-sync skill. -->\n\n' "$path" "$ref"
    cat "$tmp"
  } > "$dest"
  rm -f "$tmp"
  echo "| \`.claude/security-rules/$rel\` | \`$path\` |" >> "$sources"
  echo "Wrote $dest"
done

echo "Recorded provenance in $sources"
if [ "$failed" -gt 0 ]; then
  echo "$failed file(s) failed to download." >&2
  exit 1
fi
