#!/usr/bin/env bash
#
# i18n-smoke.sh — check that the Chinese edition is still wired up correctly.
#
#   scripts/i18n-smoke.sh
#   HUGO_BIN=./hugo scripts/i18n-smoke.sh      # in CI, where ./hugo is the downloaded binary
#
# It builds the site (drafts included, so the test fixture pair renders) into a throwaway
# directory and asserts the behaviour the Chinese edition depends on. Nothing is written to
# the real output directory. Failures mean the wiring broke — most often because a vendored
# layout drifted from the theme copy, or the fixture pair was deleted.
set -uo pipefail

cd "$(dirname "$0")/.."

posts_dir="content/posts"
fixture_slug="i18n-smoke-test"
fixture_date="2026年3月1日"     # what `:date_medium` must render for the fixture's 2026-03-01
out=".i18n-smoke.tmp"
hugo_bin="${HUGO_BIN:-}"

if [ -z "$hugo_bin" ]; then
  if command -v hugo >/dev/null 2>&1; then
    hugo_bin="hugo"
  else
    echo "FAIL  no hugo found. Install it (brew install hugo) or set HUGO_BIN."
    exit 1
  fi
fi

failures=0
pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }

contains() { # contains <file> <pattern> <description>
  if [ -f "$1" ] && grep -q -- "$2" "$1"; then pass "$3"; else fail "$3  (missing: $2 in $1)"; fi
}

absent() { # absent <file> <pattern> <description>
  if [ ! -f "$1" ]; then fail "$3  (page not built: $1)"; return; fi
  if grep -q -- "$2" "$1"; then fail "$3  (found $2 in $1)"; else pass "$3"; fi
}

rm -rf "$out"
build_log=$(mktemp); trap 'rm -f "$build_log"' EXIT

if ! "$hugo_bin" --buildDrafts --destination "$out" >"$build_log" 2>&1; then
  fail "site builds with both languages (see output above)"
  cat "$build_log"
  exit 1
fi
pass "site builds with both languages"

if [ ! -f "$posts_dir/$fixture_slug.md" ] || [ ! -f "$posts_dir/$fixture_slug.zh.md" ]; then
  fail "test fixture pair exists ($posts_dir/$fixture_slug.md + .zh.md) — restore it or remove the CI step"
  rm -rf "$out"
  exit 1
fi

en_fixture="$out/posts/$fixture_slug/index.html"
zh_fixture="$out/zh/posts/$fixture_slug/index.html"

contains "$out/zh/index.html" 'lang="zh"'                       'chinese pages declare lang="zh"'
contains "$out/zh/index.xml"  'blog.lotp.xyz/zh/posts'         'chinese feed is generated'
[ -f "$out/zh/index.html" ] && pass "chinese home page is built" || fail "chinese home page is built"

contains "$en_fixture" 'data-lang-switch'                                  'a paired english post shows the language switch'
if awk '/<\/header>/{ exit } { s = s $0 "\n" } END {
    sw = index(s, "data-lang-switch");
    dark = index(s, "class=\"btn-dark");
    js = index(s, "btnDark = document.querySelector");
    if (sw && dark && dark > sw && js && js > dark) print "ok"; else print "no"
  }' "$en_fixture" | grep -q ok; then
  pass "header order: language switch -> dark-mode toggle, then the script that wires it"
else
  fail "header order: language switch -> dark-mode toggle, then the script that wires it"
fi
contains "$en_fixture" "blog.lotp.xyz/zh/posts/$fixture_slug/"           'the switch links to the chinese twin'
contains "$zh_fixture" 'data-lang-switch'                                 'the chinese post shows the language switch back'
contains "$zh_fixture" "blog.lotp.xyz/posts/$fixture_slug/"              'the switch links back to the english original'
contains "$zh_fixture" '/zh/tags/'                                       'chinese tag links stay under /zh/ (absLangURL override intact)'
contains "$zh_fixture" "$fixture_date"                                   'dates render in Chinese'
contains "$out/zh/index.html" '生活中的每一天'                            'the chinese edition prints its own chrome, not the english values'

unpaired=""
for src in "$posts_dir"/*.md; do
  case "$src" in *.zh.md) continue ;; esac
  [ -f "${src%.md}.zh.md" ] && continue
  unpaired="$out/posts/$(basename "${src%.md}" | tr 'A-Z' 'a-z')/index.html"
  break
done
if [ -n "$unpaired" ]; then
  absent "$unpaired" 'data-lang-switch' 'an untranslated post shows no language switch'
else
  pass "an untranslated post shows no language switch (no untranslated post to check)"
fi

# Pairing on every real pair, not just the fixture. The fixture has its key on both files by
# construction, so it can never catch the one-sided case: a key on the .zh.md only. That build
# is clean, the English page shows 中文, and the Chinese page shows nothing — no switch back, no
# hreflang="en". The fixture would pass while a real post was broken.
pairs_checked=0
pairs_ok=0
for src in "$posts_dir"/*.md; do
  case "$src" in *.zh.md) continue ;; esac
  dst="${src%.md}.zh.md"
  [ -f "$dst" ] || continue
  slug=$(basename "${src%.md}" | tr 'A-Z' 'a-z')
  en_page="$out/posts/$slug/index.html"; zh_page="$out/zh/posts/$slug/index.html"
  pairs_checked=$((pairs_checked + 1))
  if grep -q 'data-lang-switch' "$en_page" 2>/dev/null && grep -q 'data-lang-switch' "$zh_page" 2>/dev/null; then
    pairs_ok=$((pairs_ok + 1))
  else
    fail "every real pair renders the switch in BOTH directions ($slug: en=$(grep -qc 'data-lang-switch' "$en_page" 2>/dev/null || echo 0) zh=$(grep -qc 'data-lang-switch' "$zh_page" 2>/dev/null || echo 0)). Check translationKey on BOTH files; scripts/new-zh-post.sh adds it to the original when missing."
  fi
done
if [ "$pairs_checked" -eq 0 ]; then
  pass "every real pair renders the switch in BOTH directions (no real pairs to check)"
elif [ "$pairs_ok" -eq "$pairs_checked" ]; then
  pass "every real pair renders the switch in BOTH directions ($pairs_checked pair(s))"
fi

if grep -rq -- '--nav-gap' "$out"/main.min.*.css 2>/dev/null; then
  pass "the header spacing rule ships in the built css (assets/custom.css is in the pipeline)"
else
  fail "the header spacing rule ships in the built css (assets/custom.css is in the pipeline)"
fi

if grep -q 'deprecated: project config key' "$build_log"; then
  fail "hugo.toml uses no deprecated keys"
  grep 'deprecated:' "$build_log" | sed 's/^/      /'
else
  pass "hugo.toml uses no deprecated keys"
fi
if grep -q 'deprecated:' "$build_log"; then
  printf 'NOTE  deprecation coming from theme templates, not from this site config:\n'
  grep 'deprecated:' "$build_log" | sed 's/^/      /'
  printf '      See "Known warnings" in docs/zh.md.\n'
fi

rm -rf "$out"

if [ "$failures" -gt 0 ]; then
  printf '\n%s check(s) failed.\n' "$failures"
  exit 1
fi
printf '\nAll checks passed.\n'
