#!/usr/bin/env bash
#
# Sync USDR policy docs from policies.usdigitalresponse.org into .claude/usdr/.
#
# Fetches each published doc as raw markdown, strips GitBook-only markup, and
# writes the cleaned copy to its local path. The local files are auto-loaded
# into every Claude Code session via @ imports in .claude/CLAUDE.md, so we keep
# them as real files on disk and refresh them here instead of fetching at
# runtime. Safe to run repeatedly. See README.md ("Keeping the USDR docs
# current").
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest_dir="$repo_root/.claude/usdr"

# local-filename|source-url
# Note: the source basename for the guidelines differs from the local name
# (data-and-software vs data-software); the local names must stay stable so the
# @usdr/... imports in CLAUDE.md keep resolving.
docs=(
  "community-oath.md|https://policies.usdigitalresponse.org/community-oath.md?displayAgentInstructions=false"
  "data-software-guidelines.md|https://policies.usdigitalresponse.org/data-and-software-guidelines.md?displayAgentInstructions=false"
  "security-protocol.md|https://policies.usdigitalresponse.org/volunteer-security-protocol.md?displayAgentInstructions=false"
)

# Strip GitBook-only markup from stdin -> stdout. sed -E (extended regex) is used
# throughout for portability across BSD sed (macOS) and GNU sed (CI runners).
clean() {
  # 1. {% hint %} ... {% endhint %} fences -> plain blockquote (drop fences,
  #    prefix inner lines with "> "). The only stateful/multi-line transform.
  awk '
    /^[[:space:]]*\{%[[:space:]]*hint/    { inhint=1; next }
    /^[[:space:]]*\{%[[:space:]]*endhint/ { inhint=0; next }
    {
      if (inhint) {
        if ($0 ~ /^[[:space:]]*$/) print ">"
        else print "> " $0
      } else print $0
    }
  ' \
  | sed -E 's/\\?[[:space:]]*<img[^>]*>//g' \
  | sed -E 's/!\[\]\([^)]*\)//g' \
  | sed -E 's#<br[[:space:]]*/?>##g' \
  | sed 's/&#x20;//g' \
  | sed -E 's/\[ \]\([^)]*\)//g' \
  | sed -E 's/[[:space:]]+$//' \
  | sed -E '/^[[:space:]]*\\[[:space:]]*$/d' \
  | cat -s
}

mkdir -p "$dest_dir"

for entry in "${docs[@]}"; do
  name="${entry%%|*}"
  url="${entry##*|}"
  dest="$dest_dir/$name"
  tmp="$(mktemp)"

  echo "Fetching $name ..."
  if ! curl --fail --show-error --silent --location "$url" -o "$tmp"; then
    echo "ERROR: fetch failed for $url — leaving $name unchanged." >&2
    rm -f "$tmp"
    exit 1
  fi
  if [ ! -s "$tmp" ]; then
    echo "ERROR: empty body for $url — leaving $name unchanged." >&2
    rm -f "$tmp"
    exit 1
  fi
  # GitBook answers unknown paths with a 200 "soft 404", so curl --fail can't
  # catch a renamed/removed source. Detect the sentinel page and bail before it
  # overwrites a good doc.
  if head -1 "$tmp" | grep -qxF '# Page Not Found' \
     && grep -qF 'This page may have been moved, renamed, or deleted.' "$tmp"; then
    echo "ERROR: source returned a 'Page Not Found' page for $url — leaving $name unchanged." >&2
    rm -f "$tmp"
    exit 1
  fi

  {
    printf '<!-- Synced from %s — do not edit by hand; run scripts/sync-usdr-docs.sh. -->\n\n' "$url"
    clean < "$tmp"
  } > "$dest"

  rm -f "$tmp"
  echo "Wrote $dest"
done

echo "Done."
