#!/usr/bin/env bash
#
# i18n-status.sh — report the state of the Chinese edition. Informational only: it
# changes nothing and always exits 0.
#
#   scripts/i18n-status.sh
#
# Reports:
#   untranslated  — English posts with no .zh.md counterpart (a legal, permanent state)
#   orphans       — .zh.md files with no English original
#   unpaired      — .zh.md files missing `translationKey` (the switch cannot find them)
#   one-sided     — key on the .zh.md but not on the original (switch renders one way only)
#   drifted       — translations whose English original was committed later than they were
set -euo pipefail

cd "$(dirname "$0")/.."
posts_dir="content/posts"

if [ ! -d "$posts_dir" ]; then
  echo "error: $posts_dir not found" >&2
  exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "note: not a git repository — drift cannot be measured, only pairing" >&2
fi

commit_time() { # epoch seconds of the last commit touching $1; empty if untracked
  git log -1 --format=%ct -- "$1" 2>/dev/null | head -n 1 || true
}

fmt_time() { [ -n "$1" ] && date -r "$1" '+%Y-%m-%d' || printf 'uncommitted'; }

originals=0
translations=0
untranslated=""
orphans=""
unpaired=""
one_sided=""
drifted=""
drift_unknown=""

for src in "$posts_dir"/*.md; do
  [ -f "$src" ] || continue
  case "$src" in *.zh.md) continue ;; esac

  originals=$((originals + 1))
  dst="${src%.md}.zh.md"
  if [ ! -f "$dst" ]; then
    untranslated="$untranslated  - ${src#$posts_dir/}\n"
  fi
done

for dst in "$posts_dir"/*.zh.md; do
  [ -f "$dst" ] || continue
  translations=$((translations + 1))
  src="${dst%.zh.md}.md"

  if [ ! -f "$src" ]; then
    orphans="$orphans  - ${dst#$posts_dir/}\n"
    continue
  fi

  if ! sed -n '2,/^---[[:space:]]*$/p' "$dst" | grep -q '^translationKey:'; then
    unpaired="$unpaired  - ${dst#$posts_dir/}  (no translationKey)\n"
  elif ! sed -n '2,/^---[[:space:]]*$/p' "$src" | grep -q '^translationKey:'; then
    # The reverse case, which `unpaired` cannot see and which builds with no visible error:
    # the translation declares a key, the original does not. Hugo resolves .Translations from
    # both sides, so the English page shows 中文 and the Chinese page shows nothing — no switch
    # back, no hreflang="en". new-zh-post.sh now ensures the key on both files.
    one_sided="$one_sided  - ${src#$posts_dir/}  <-> ${dst#$posts_dir/}  (key on the translation only)\n"
  fi

  src_t=$(commit_time "$src")
  dst_t=$(commit_time "$dst")
  if [ -z "$src_t" ] || [ -z "$dst_t" ]; then
    drift_unknown="$drift_unknown  - ${dst#$posts_dir/}  (not committed yet)\n"
  elif [ "$src_t" -gt "$dst_t" ]; then
    drifted="$drifted  - ${dst#$posts_dir/}  (original $(fmt_time "$src_t") > translation $(fmt_time "$dst_t"))\n"
  fi
done

count_items() {
  if [ -z "$1" ]; then
    printf '0'
  else
    printf '%b' "$1" | grep -c '^  - ' || true
  fi
}

printf 'Chinese edition status\n'
printf '======================\n'
printf 'originals:            %s\n' "$originals"
printf 'chinese translations: %s\n' "$translations"
printf 'untranslated:         %s\n' "$(count_items "$untranslated")"
printf 'orphans:              %s\n' "$(count_items "$orphans")"
printf 'unpaired:             %s\n' "$(count_items "$unpaired")"
printf 'one-sided keys:       %s\n' "$(count_items "$one_sided")"
printf 'drifted:              %s\n' "$(count_items "$drifted")"
printf '\n'

if [ -n "$untranslated" ]; then printf 'Untranslated originals (no .zh.md):\n%b\n' "$untranslated"; fi
if [ -n "$orphans" ]; then printf 'Orphan translations (no English original):\n%b\n' "$orphans"; fi
if [ -n "$unpaired" ]; then printf 'Missing translationKey (language switch cannot pair them):\n%b\n' "$unpaired"; fi
if [ -n "$one_sided" ]; then printf 'One-sided translationKey (switch renders one way only; add the key to the English original):\n%b\n' "$one_sided"; fi
if [ -n "$drifted" ]; then printf 'Drifted (original changed after the translation):\n%b\n' "$drifted"; fi
if [ -n "$drift_unknown" ]; then printf 'Drift unknown (new files, not committed yet):\n%b\n' "$drift_unknown"; fi
if [ -z "$untranslated$orphans$unpaired$one_sided$drifted$drift_unknown" ]; then
  printf 'Nothing to report.\n'
fi
