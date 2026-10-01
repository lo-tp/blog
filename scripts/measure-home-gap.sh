#!/usr/bin/env bash
# Measure the vertical gaps on the home page in headless Chromium.
#
# Why this exists: the top-bar → profile spacing comes from three places at once — hugo-paper's
# `pt-14` on <main> (themes/hugo-paper/layouts/_default/baseof.html), `-mt-2 mb-12` on the avatar
# block (vendored layouts/_default/list.html), and the overrides in assets/custom.css. Tailwind
# compiles all of those utilities, and .pt-14 lands at specificity (0,5,0), so reading the CSS
# cannot tell you the rendered gap. Only measuring it can.
#
# Usage:
#   scripts/measure-home-gap.sh                 # starts its own hugo server on :1314, measures, stops it
#   scripts/measure-home-gap.sh http://localhost:1313   # measure a server you already have running
#   POST_PATH=/posts/some-post/ scripts/measure-home-gap.sh   # also probe that post page
#
# CRITICAL, and the reason early measurements here were wrong: hugo.toml sets
# baseURL = "https://blog.lotp.xyz/", so every asset URL in the served page is absolute and
# points at the published site. `hugo server -b …` rewrites them (the long --baseURL form is
# a build flag and is ignored by the server). Without that, Chromium ORB-blocks the
# cross-origin stylesheet and the page
# renders with NO CSS — which looks like "my override had no effect" when it is really "no CSS
# was loaded". So this script serves with a local override config and asserts, in the browser,
# that a stylesheet actually loaded before it reports any number.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-1314}"

find_playwright() {
  for dir in "$ROOT" "$PWD" "${PLAYWRIGHT_DIR:-}" /tmp/pw /tmp/pwq "${HOME}/.cache/pw"; do
    [ -n "$dir" ] && [ -d "$dir/node_modules/playwright" ] && { printf '%s' "$dir"; return 0; }
  done
  return 1
}

PW_DIR="$(find_playwright)" || {
  echo "playwright not found. Install it once in a scratch dir:" >&2
  echo "  mkdir -p /tmp/pw && cd /tmp/pw && npm init -y && npm i playwright@1.58.0" >&2
  echo "1.58.0 matches the chromium-1208 build already in ~/Library/Caches/ms-playwright." >&2
  exit 1
}

TMP="$(mktemp -d)"
cleanup() {
  [ -n "${SERVER_PID:-}" ] && kill "$SERVER_PID" 2>/dev/null || true
  rm -rf "$TMP"
}
trap cleanup EXIT
# Symlink, not copy: `cp -T` of a node_modules tree is slow and, if it half-fails, Node
# silently resolves `playwright` from a parent directory — which can pick up a stale copy of
# the probe and report numbers for CSS you already changed.
ln -s "$PW_DIR/node_modules" "$TMP/node_modules"

BASE="${1:-}"
if [ -z "$BASE" ]; then
  # -b is the server's own baseURL flag and DOES rewrite asset URLs. The long form
  # --baseURL is a `hugo build` flag; passing it to `hugo server` is ignored, which is how
  # an earlier version of this script ended up measuring a page with no CSS at all.
  ( cd "$ROOT" && exec hugo server -b "http://127.0.0.1:${PORT}/" \
      --port "$PORT" --bind 127.0.0.1 --disableFastRender --noHTTPCache ) >"$TMP/server.log" 2>&1 &
  SERVER_PID=$!
  BASE="http://127.0.0.1:${PORT}"
  for _ in {1..40}; do
    curl -fsS -o /dev/null "$BASE/" && break
    sleep 0.25
  done
  curl -fsS -o /dev/null "$BASE/" || { echo "server did not come up on $BASE"; cat "$TMP/server.log" >&2; exit 1; }
fi

cat > "$TMP/measure.mjs" <<'JS'
import { chromium } from 'playwright';

const base = process.argv[2];
const postPath = process.argv[3] || '';
const browser = await chromium.launch();

const PROBE = () => {
  const box = (sel) => {
    const el = document.querySelector(sel);
    if (!el) return null;
    const b = el.getBoundingClientRect();
    return { x: +b.x.toFixed(0), y: +b.y.toFixed(0), w: +b.width.toFixed(0), h: +b.height.toFixed(0), bottom: +b.bottom.toFixed(0) };
  };
  const cs = (sel) => {
    const el = document.querySelector(sel);
    if (!el) return null;
    const c = getComputedStyle(el);
    return { paddingTop: c.paddingTop, marginTop: c.marginTop, marginBottom: c.marginBottom };
  };
  const PROFILE = 'main > div:first-of-type';
  const header = box('header'), main = box('main'), profile = box(PROFILE), post = box('main > section');
  const mainEl = document.querySelector('main');
  // The home-only rule is `main:has(> div:first-of-type img[alt])`. If it stops matching —
  // hugo-paper renamed the avatar block, a template added a wrapper, params.avatar removed —
  // the home page silently falls back to the article gap and the change looks inert.
  const homeGapApplied = !!mainEl && mainEl.matches('main:has(> div:first-of-type img[alt])');
  const title = box('header > div > a'), avatar = box(PROFILE + ' > div:first-child');
  const collides = !!(avatar && title) &&
    !(avatar.bottom <= title.y || title.bottom <= avatar.y) &&
    !(avatar.x + avatar.w <= title.x || title.x + title.w <= avatar.x);
  return {
    cssSheetsLoaded: document.styleSheets.length,
    mainCss: cs('main'),
    profileCss: cs(PROFILE),
    headerToProfile: header && profile ? +(profile.y - header.bottom).toFixed(0) : null,
    profileToPost: profile && post ? +(post.y - profile.bottom).toFixed(0) : null,
    headerToFirstPost: header && post ? +(post.y - header.bottom).toFixed(0) : null,
    titleBox: title,
    avatarTop: avatar ? avatar.y : null,
    avatarCollidesWithTitle: collides,
    homeGapApplied,
  };
};

const viewports = [['home 1100px', 1100, 900], ['home 390px (mobile)', 390, 844]];
let failed = false;
for (const [label, width, height] of viewports) {
  const page = await browser.newPage({ viewport: { width, height } });
  const blocked = [];
  page.on('requestfailed', (r) => blocked.push(`${r.url()} ${(r.failure() || {}).errorText}`));
  await page.goto(base + '/', { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  const r = await page.evaluate(PROBE);
  r.blockedRequests = blocked;
  if (label.startsWith('home') && r.homeGapApplied === false) {
    failed = true;
    console.log(label, 'HOME GAP NOT APPLIED — main:has(> div:first-of-type img[alt]) did not match. The avatar block in the list template has changed shape; assets/custom.css selects it by structure, so update the selector.');
  }
  if (r.cssSheetsLoaded === 0) {
    failed = true;
    console.log(label, 'NO CSS LOADED — the stylesheet was not applied. blocked:', blocked);
    console.log('  Is the page referencing a cross-origin baseURL (hugo.toml baseURL)? Serve with a local baseURL override.');
  } else {
    console.log(label, JSON.stringify(r));
  }
  await page.close();
}

if (postPath) {
  const page = await browser.newPage({ viewport: { width: 1100, height: 900 } });
  await page.goto(base + postPath, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  console.log('post page', JSON.stringify(await page.evaluate(PROBE)));
  await page.close();
}

await browser.close();
process.exit(failed ? 1 : 0);
JS

node "$TMP/measure.mjs" "$BASE" "${POST_PATH:-}"
