#!/usr/bin/env bash
# Measure the vertical rhythm of the edition in headless Chromium.
#
# Why this exists: the rhythm of a page is decided by several rules at once — the
# running head's min-height, the front matter's padding, `.contents` top padding,
# `.year` margins, `.records` gap, and the media queries that change all of them
# below 1000px. Reading assets/custom.css cannot tell you the rendered distance
# between two of them; only measuring it can. This script measures it, and fails
# when the render disagrees with the tokens it is supposed to be producing.
#
# What it asserts (exit 1 on any failure):
#   - a stylesheet actually loaded, and the self-hosted display face actually loaded;
#   - the header controls appear in the contract order: profile links → language
#     switch → dark-mode dial, and none of them overlap;
#   - the header band is sticky, it clears --header-h, it publishes its measured
#     height as --band-h, and the sticky index rail sits at --band-h + 1rem rather
#     than overlapping it (this is what --band-h exists for);
#   - the title page's rhythm: masthead rule → contents → year marker → first row,
#     and that rows inside one year group are --row-gap apart;
#   - on a phone the index plan travels with the ledger (it stays sticky and on
#     screen while the ledger is being read);
#   - a record page sets its text block inside the reading measure and centres it;
#   - nothing overflows the viewport horizontally at 1280px or 390px.
#
# Usage:
#   scripts/measure-home-gap.sh                 # starts its own hugo server on :1314, measures, stops it
#   scripts/measure-home-gap.sh http://localhost:1313   # measure a server you already have running
#   POST_PATH=/posts/some-post/ scripts/measure-home-gap.sh   # also probe that record page
#
# CRITICAL, and the reason early measurements here were wrong: hugo.toml sets
# baseURL = "https://blog.lotp.xyz/", so every asset URL in the served page is absolute and
# points at the published site. `hugo server -b …` rewrites them (the long --baseURL form is
# a build flag and is ignored by the server). Without that, Chromium ORB-blocks the
# cross-origin stylesheet and the page renders with NO CSS — which looks like "my change had
# no effect" when it is really "no CSS was loaded". So this script serves with a local
# baseURL override and asserts, in the browser, that a stylesheet and the display face loaded
# before it reports any number.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-1314}"

find_playwright() {
  for dir in "$ROOT" "$PWD" "${PLAYWRIGHT_DIR:-}" /tmp/pwq /tmp/pw "${HOME}/.cache/pw"; do
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
const fails = [];

// Node-side helper: the page reports tokens as strings; compare them in px.
const px = (value) => {
  const n = parseFloat(value);
  if (!Number.isFinite(n)) return null;
  return String(value).includes('rem') ? Math.round(n * 16) : Math.round(n);
};

const fail = (label, what) => {
  fails.push(`${label}: ${what}`);
};

const PROBE = () => {
  const el = (sel) => document.querySelector(sel);
  const box = (sel) => {
    const node = el(sel);
    if (!node) return null;
    const b = node.getBoundingClientRect();
    const round = (n) => +n.toFixed(0);
    return { x: round(b.x), y: round(b.y), w: round(b.width), h: round(b.height), bottom: round(b.bottom), right: round(b.right) };
  };
  const gap = (a, b) => (a && b ? +(b.y - a.bottom).toFixed(0) : null);
  const overlaps = (a, b) =>
    !!a && !!b && !(a.right <= b.x || b.right <= a.x) && !(a.bottom <= b.y || b.bottom <= a.y);

  const token = (name) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();
  const px = (value) => {
    // Only the values this script compares: rem (against the root font size) and px.
    const n = parseFloat(value);
    if (!Number.isFinite(n)) return null;
    return value.includes('rem') ? Math.round(n * 16) : Math.round(n);
  };

  const social = [...document.querySelectorAll('.frontmatter-controls .social a')].map((a) => a.getBoundingClientRect());
  const socialBoxes = social.map((b) => ({ x: +b.x.toFixed(0), right: +b.right.toFixed(0), y: +b.y.toFixed(0) }));
  const lang = box('.lang-switch a') || box('.lang-switch');
  const dial = box('.btn-dark');
  const head = box('.masthead-band');
  const band = box('.masthead-band .frontmatter');
  const sticky = (() => {
    const e = document.querySelector('.masthead-band');
    const i = document.querySelector('.index');
    return {
      header: e ? getComputedStyle(e).position : null,
      headerTop: e ? getComputedStyle(e).top : null,
      index: i ? getComputedStyle(i).position : null,
      indexTop: i ? getComputedStyle(i).top : null,
    };
  })();
  const masthead = box('.masthead');
  const frontmatter = box('.frontmatter');
  const contents = box('.contents');
  const yearMark = box('.year__mark');
  const rows = [...document.querySelectorAll('.rec')].map((r) => r.getBoundingClientRect());
  const rowGaps = rows.slice(1).map((r, i) => +(r.y - rows[i].bottom).toFixed(0));
  const record = box('.record');

  const controlOrder = [
    socialBoxes.length ? Math.max(...socialBoxes.map((b) => b.right)) : null,
    lang ? lang.x : null,
    dial ? dial.x : null,
  ];
  const ascending = controlOrder.every((v, i) => v === null || i === 0 || controlOrder[i - 1] === null || v >= controlOrder[i - 1]);

  return {
    cssSheetsLoaded: document.styleSheets.length,
    displayFaceLoaded: document.fonts.check('700 16px "Archivo Narrow"'),
    tokens: { headerH: token('--header-h'), rowGap: token('--row-gap'), measure: token('--measure-read') },
    headerBand: head,
    band,
    sticky,
    bandVar: getComputedStyle(document.documentElement).getPropertyValue('--band-h').trim(),
    controls: {
      social: socialBoxes.length,
      socialRightMost: socialBoxes.length ? Math.max(...socialBoxes.map((b) => b.right)) : null,
      socialLabelSpill: socialBoxes.length < social.length ? 'n/a' : [...document.querySelectorAll('.frontmatter-controls .social a')].filter((a) => a.scrollWidth > a.clientWidth + 1).length,
      lang,
      dial,
      orderIsProfileThenLangThenDial: ascending,
      anyPairOverlaps:
        overlaps(lang, dial) ||
        (socialBoxes.length > 1 && overlaps(socialBoxes[0], socialBoxes[1])),
    },
    rhythm: {
      mastheadToContents: gap(masthead || frontmatter, contents),
      mastheadToFirstYear: gap(masthead || frontmatter, yearMark),
      yearToFirstRow:
        yearMark && rows.length ? +(rows[0].top - yearMark.bottom).toFixed(0) : null,
      rowGaps,
    },
    record: record
      ? {
          width: record.w,
          centred: Math.abs(record.x + record.w / 2 - document.documentElement.clientWidth / 2) <= 24,
        }
      : null,
    horizontalOverflow: document.documentElement.scrollWidth > document.documentElement.clientWidth + 1,
    overflowing: [...document.querySelectorAll('body *')]
      .filter((e) => e.getBoundingClientRect().right > document.documentElement.clientWidth + 1)
      .slice(0, 4)
      .map((e) => `${e.tagName}.${(e.className || '').toString().slice(0, 24)}`),
  };
};

const homeViewports = [['title page 1280px', 1280, 900], ['title page 390px (phone)', 390, 844]];
for (const [label, width, height] of homeViewports) {
  const page = await browser.newPage({ viewport: { width, height } });
  const blocked = [];
  page.on('requestfailed', (r) => blocked.push(`${r.url()} ${(r.failure() || {}).errorText}`));
  await page.goto(base + '/', { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  // header.html publishes the band's measured height as --band-h on load and on
  // resize. Wait for that number instead of racing it.
  await page.waitForFunction(
    () => {
      const v = getComputedStyle(document.documentElement).getPropertyValue('--band-h').trim();
      return v && !/undefined|NaN/.test(v) && parseFloat(v) > 0;
    },
    { timeout: 5000 },
  );
  const r = await page.evaluate(PROBE);

  if (r.cssSheetsLoaded === 0) fail(label, 'NO CSS LOADED — is the page referencing a cross-origin baseURL? Serve with a local baseURL override.');
  if (!r.displayFaceLoaded) fail(label, 'the self-hosted display face did not load (static/fonts/ or the @font-face url)');
  if (r.controls.social === 0) fail(label, 'no profile links in the header band');
  if (!r.controls.orderIsProfileThenLangThenDial) fail(label, 'header control order broken: must be profile links → language switch → dark-mode dial');
  if (r.controls.anyPairOverlaps) fail(label, 'header controls overlap each other');
  if (r.controls.socialLabelSpill > 0) fail(label, `${r.controls.socialLabelSpill} profile link(s) paint their label over the neighbouring control`);
  // The header band is sticky and its height is its own content: it must clear
  // --header-h (a floor), publish that height as --band-h, and the index rail
  // must stick below it. --header-h is deliberately NOT a fixed header height.
  if (r.sticky.header !== 'sticky' || r.sticky.headerTop !== '0px')
    fail(label, `the header band is ${r.sticky.header} / top ${r.sticky.headerTop} — the masthead band must be sticky at top 0`);
  if (r.tokens.headerH && r.band && r.band.h < px(r.tokens.headerH))
    fail(label, `header band is ${r.band.h}px, below the --header-h floor of ${r.tokens.headerH}`);
  if (r.band && px(r.bandVar) !== r.band.h)
    fail(label, `--band-h is ${r.bandVar} but the band measures ${r.band.h}px — the sticky offsets below it are wrong`);
  if (r.sticky.index === 'sticky') {
    const want = px(r.bandVar) + 16;
    const got = px(r.sticky.indexTop);
    if (label.includes('phone')) {
      // Below 1000px the plan is a strip that sticks directly under the band.
      if (got !== px(r.bandVar)) fail(label, `the index strip sticks at ${r.sticky.indexTop}, must sit at --band-h (${px(r.bandVar)}px)`);
    } else if (Math.abs(got - want) > 2) {
      fail(label, `the index rail sticks at ${r.sticky.indexTop}, must sit at --band-h + 1rem (${want}px)`);
    }
  }
  if (r.rhythm.yearToFirstRow !== null && r.rhythm.yearToFirstRow < 8)
    fail(label, `a year marker sits ${r.rhythm.yearToFirstRow}px above its first row`);
  if (r.rhythm.mastheadToContents !== null && r.rhythm.mastheadToContents < 24)
    fail(label, `masthead rule sits ${r.rhythm.mastheadToContents}px above the contents plan — the title page has no breathing room`);
  const rowGapPx = px(r.tokens.rowGap);
  const tooTight = r.rhythm.rowGaps.filter((g) => rowGapPx && g < rowGapPx - 2 && g > 0);
  if (tooTight.length) fail(label, `${tooTight.length} ledger row gap(s) below --row-gap (${r.tokens.rowGap}): ${tooTight.join(', ')}px`);
  if (r.horizontalOverflow) fail(label, `page overflows its viewport horizontally: ${r.overflowing.join(', ')}`);

  if (label.includes('phone')) {
    await page.evaluate(() => window.scrollTo(0, 1400));
    await page.evaluate(() => new Promise((res) => setTimeout(res, 350)));
    const sticky = await page.evaluate(() => {
      const idx = document.querySelector('.index');
      if (!idx) return { present: false };
      const b = idx.getBoundingClientRect();
      return {
        present: true,
        position: getComputedStyle(idx).position,
        onScreen: b.top >= 0 && b.top < window.innerHeight,
        ledgerOnScreen: !!document.querySelector('.rec'),
      };
    });
    if (!sticky.present || !sticky.onScreen || sticky.position !== 'sticky')
      fail(label, 'the index plan does not travel with the ledger on a phone');
  }

  console.log(label, JSON.stringify(r));
  await page.close();
}

if (postPath) {
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto(base + postPath, { waitUntil: 'load' });
  await page.evaluate(() => document.fonts.ready);
  const r = await page.evaluate(PROBE);
  if (!r.record) fail('record page', 'no .record on the page — single.html changed shape');
  else {
    if (r.record.width > 640) fail('record page', `text block is ${r.record.width}px wide — over the reading measure`);
    if (!r.record.centred) fail('record page', 'the text block is not centred between the sheet margins');
  }
  if (r.horizontalOverflow) fail('record page', `page overflows its viewport horizontally: ${r.overflowing.join(', ')}`);
  console.log('record page', JSON.stringify(r));
  await page.close();
}

await browser.close();
if (fails.length) {
  console.log('\nFAILED:');
  for (const f of fails) console.log('  - ' + f);
  process.exit(1);
}
console.log('\nall render assertions passed');
JS

node "$TMP/measure.mjs" "$BASE" "${POST_PATH:-}"
