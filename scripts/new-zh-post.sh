#!/usr/bin/env bash
#
# new-zh-post.sh — scaffold the Chinese counterpart of an English post.
#
#   scripts/new-zh-post.sh <slug>          # slug = content/posts/<slug>.md, without .md
#
# It ensures the pairing `translationKey` exists on BOTH files, copies the English
# frontmatter into the new one, marks it `draft: true`, and pastes the English body inside an
# HTML comment so you have something to translate against. It writes no Chinese itself: the
# translation is yours. See docs/zh.md.
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

fm=$(mktemp)
tmp=$(mktemp)
trap 'rm -f "$tmp" "$fm"' EXIT

# --- translationKey on the English original -------------------------------------------
# Pairing is read from the key, and Hugo resolves .Translations from BOTH sides. A key on
# the .zh.md alone still renders the original's page, but the original never links back: no
# `中文`-side twin, no hreflang="en", and i18n-status.sh's `unpaired` counter cannot see it,
# because that check looks for a key on the translation only. So the key is ensured here.
# The value used is whatever the original already declares; nothing else in the original is
# touched (the file is rewritten only when the key is genuinely absent).
if head -n "$fm_end" "$src" | grep -q '^translationKey:[[:space:]]*[^[:space:]]'; then
  key=$(sed -n "s/^translationKey:[[:space:]]*//p" "$src" | head -n 1 | sed 's/[[:space:]]*$//')
  key=${key#\"}; key=${key#\'}; key=${key%\"}; key=${key%\'}
else
  key="$slug"
  # The key goes INSIDE the front matter: before the closing `---` at line fm_end. Appending
  # it after that line leaves it as body text, which Hugo ignores and which then shows up in
  # the scaffold's 原文 comment instead of in the front matter.
  {
    sed -n "1,$((fm_end - 1))p" "$src"
    printf 'translationKey: %s\n' "$key"
    sed -n "${fm_end},\$p" "$src"
  } > "$fm"
  # Preserve the original's mtime: a commit date for the original later than the translation
  # is exactly what i18n-status.sh reports as drift, and a tool that scaffolds a translation
  # should not manufacture it. `touch -t` takes [[CC]YY]MMDDHHMM[.SS], not an epoch, so the
  # epoch from stat is converted with date -r first.
  mepoch=$(stat -f %m "$src" 2>/dev/null || stat -c %Y "$src")
  mv "$fm" "$src"
  touch -t "$(date -r "$mepoch" '+%Y%m%d%H%M.%S')" "$src"
  echo "added translationKey: $key to $src (pairing needs it on both files)"
  # The front matter is one line longer now, so every later line-based slice must shift.
  fm_end=$((fm_end + 1))
fi

# --- front matter of the new file, carrying that key ---------------------------------
# After the block above, $src always declares the key, so this is a straight copy of its
# front matter (line 1 is the opening `---`, line fm_end is the closing one).
sed -n "1,$((fm_end - 1))p" "$src" > "$tmp"

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
echo "  4. keep unchanged: the filename, translationKey ($key), date, images paths"
echo "  5. when it reads like your own writing, remove the draft: true line"
