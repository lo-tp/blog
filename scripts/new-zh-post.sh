#!/usr/bin/env bash
#
# new-zh-post.sh — scaffold the Chinese counterpart of an English post.
#
#   scripts/new-zh-post.sh <slug>          # slug = content/posts/<slug>.md, without .md
#
# It copies the English frontmatter, adds the `translationKey` that pairs the two files,
# marks the new file `draft: true`, and pastes the English body inside an HTML comment so
# you have something to translate against. It writes no Chinese itself: the translation is
# yours. See docs/zh.md.
set -euo pipefail

cd "$(dirname "$0")/.."
content_dir="content/posts"

usage() {
  echo "usage: scripts/new-zh-post.sh <slug>" >&2
  echo "       slug is a file in $content_dir, without the .md suffix" >&2
  exit 2
}

[ "$#" -eq 1 ] || usage

slug="$1"
src="$content_dir/$slug.md"
dst="$content_dir/$slug.zh.md"

if [ ! -f "$src" ]; then
  echo "error: no such post: $src" >&2
  echo "nearby slugs:" >&2
  ls "$content_dir" 2>/dev/null | sed 's/\.md$//' | grep -i "$slug" | sed 's/^/  /' | head -10 >&2 || true
  exit 1
fi

if [ -f "$dst" ]; then
  echo "error: $dst already exists — refusing to overwrite it" >&2
  exit 1
fi

if ! head -n 1 "$src" | grep -q '^---[[:space:]]*$'; then
  echo "error: $src has no YAML front matter" >&2
  exit 1
fi

fm_end=$(awk 'NR > 1 && /^---[[:space:]]*$/ { print NR; exit }' "$src")
if [ -z "$fm_end" ]; then
  echo "error: front matter in $src is not closed" >&2
  exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Front matter, with translationKey added when the original does not declare one.
if head -n "$fm_end" "$src" | grep -q '^translationKey:'; then
  sed -n "1,$((fm_end - 1))p" "$src" > "$tmp"
else
  {
    head -n 1 "$src"
    echo "translationKey: $slug"
    sed -n "2,$((fm_end - 1))p" "$src"
  } > "$tmp"
fi

# Draft unless the original declares a draft value: an untranslated page should not go live.
if ! grep -q '^draft:' "$tmp"; then
  printf 'draft: true\n' >> "$tmp"
fi
printf -- '---\n' >> "$tmp"

cp "$tmp" "$dst"

# The original body, quoted as a comment to translate against. `-->` inside the original
# would close the comment early, so it is escaped.
{
  printf '\n<!-- 原文（翻译完成后删除这一段）\n\n'
  tail -n +"$((fm_end + 1))" "$src" | sed 's/-->/--\&gt;/g'
  printf '\n-->\n'
} >> "$dst"

echo "created $dst"
echo
echo "next steps:"
echo "  1. translate title and description"
echo "  2. replace tags with Chinese ones (docs/zh.md has the agreed tag list)"
echo "  3. translate the body, then delete the 原文 comment block"
echo "  4. keep unchanged: the filename, translationKey, date, images paths"
echo "  5. when it reads like your own writing, remove the draft: true line"
