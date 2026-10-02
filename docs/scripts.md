# Using the scripts

Three helpers for the Chinese edition. They scaffold files, report state, and check the
wiring — **none of them translate anything**. Why the edition is built this way:
[ADR 0001](./adr/0001-hugo-i18n-with-zh-language-key.md). The writing workflow around these
scripts is in [zh.md](./zh.md).

| Script | What it does | Writes to the repo? | Exit codes |
| --- | --- | --- | --- |
| `scripts/new-zh-post.sh` | create the `<slug>.zh.md` file to translate into | yes, one new file | 0 created · 1 error · 2 bad usage |
| `scripts/i18n-status.sh` | report untranslated / orphan / unpaired / one-sided key / drifted | no | always 0 |
| `scripts/i18n-smoke.sh` | assert the Chinese wiring still works | no (builds into `.i18n-smoke.tmp`, gitignored) | 0 all pass · 1 something failed |

All three work from any directory: they `cd` to the repo root first.

---

## `scripts/new-zh-post.sh` — start a translation

```sh
scripts/new-zh-post.sh <slug>
```

`<slug>` is a filename in `content/posts/` **without** the `.md` suffix. To list them:

```sh
ls content/posts | sed -E 's/\.(zh\.)?md$//' | sort -u
```

### What it produces

Given `content/posts/LeetCode-887-Super-Egg-Drop.md`, it writes
`content/posts/LeetCode-887-Super-Egg-Drop.zh.md`:

```markdown
---
translationKey: LeetCode-887-Super-Egg-Drop   # added: this is what pairs the two files
title: "An Articulation of the O(KN) Solution to 'Leetcode 887: Super Egg Drop'"
date: 2021-01-01T20:00:00
tags: [LeetCode, DP]
draft: true                                   # added: nothing goes live untranslated
---

<!-- 原文（翻译完成后删除这一段）

…the English body, verbatim, so you have something to translate against…

-->
```

If the English original has no `translationKey`, the script adds one to **it too**, on its own
line inside the front matter, and prints `added translationKey: <key> to …`. That write is the
one exception to "it will not touch the English original" (see below), and it is the fix for a
failure that otherwise looks like a healthy build: Hugo resolves a page's `.Translations` from
both sides, so a key on the `.zh.md` alone still builds two pages and still shows `中文` on the
English one — but the Chinese page renders **no** switch back and no `hreflang="en"`. Your own
key, quoted or not, is always kept; it is copied into the `.zh.md` verbatim and no second key
is written.

Then it prints the next steps: translate `title` and `description`, swap `tags` for Chinese
ones, translate the body and delete the 原文 comment, keep the filename / `translationKey` /
`date` / `images` paths unchanged, and remove `draft: true` when the Chinese reads like your
own writing.

### Rules it enforces

- **Refuses to overwrite.** If `<slug>.zh.md` exists it stops instead of clobbering your work.
- **Needs front matter.** A post with no opening `---` block is an error, not a silent guess.
- **`translationKey` is ensured on both files, and only added if absent.** If you already set
  your own key it is kept, in both files, and the English original is not rewritten at all —
  not a byte, not its mtime.
- **When it does write the original, it preserves that original's mtime.** A commit date for
  the original later than the translation is exactly what `i18n-status.sh` reports as **drift**;
  a tool whose job is to *start* a translation must not manufacture drift at the moment of
  scaffolding.
- **`draft: true` is only added if you said nothing about draft.** If the original declares
  `draft: false`, that is respected.
- The English body is pasted inside an HTML comment, with any `-->` escaped to `--&gt;` so
  the comment cannot close early. It cannot leak into the published page.

### It will not

write Chinese, pick tags, rename files, or publish anything. It edits the English original in
exactly one way: inserting a missing `translationKey` inside its front matter. Nothing else in
that file moves.

---

## `scripts/i18n-status.sh` — see what is left to do

```sh
scripts/i18n-status.sh
```

Read-only, always exits 0. Current output shape:

```
Chinese edition status
======================
originals:            16
chinese translations: 1
untranslated:         15
orphans:              0
unpaired:             0
one-sided keys:       0
drifted:              0

Untranslated originals (no .zh.md):
  - A-Simple-But-Effective-Spaced-Repitition-Algorithm-MS.md
  …
```

What each line means:

- **untranslated** — an English post with no `.zh.md`. A legal, permanent state: not every
  article needs to be bilingual. This list is your backlog, nothing more.
- **orphans** — a `.zh.md` with no English original. Treated as a mistake: either the name
  is wrong or the original was deleted.
- **unpaired** — a `.zh.md` with no `translationKey`. The page builds fine, but the language
  switch and `hreflang` cannot find its twin. Fix by adding `translationKey: <slug>`.
- **one-sided keys** — the mirror case, which `unpaired` cannot see: the `.zh.md` has the key,
  the English original does not. Hugo resolves `.Translations` from both sides, so the build is
  clean and the English page even shows `中文` — but the Chinese page renders no switch back and
  no `hreflang="en"`. This is the most common way to half-pair a post, because scaffolding with
  `new-zh-post.sh` used to add the key to the translation only. Fix by adding the same key to
  the original; the script now does it for you.
- **drifted** — the English original was committed *after* the translation. Expected over
  time; the point is that you see it rather than assume the Chinese is current.
- **drift unknown** — the pair isn't committed yet, so there are no commit timestamps to
  compare. Not an error.

Drift is measured from `git log` commit times, so it only works for committed files, and it
compares commits — not whether the change actually affected the text you translated.

---

## `scripts/i18n-smoke.sh` — prove the wiring still works

```sh
scripts/i18n-smoke.sh                                  # local
HUGO_BIN=./hugo bash scripts/i18n-smoke.sh            # how CI runs it
```

It builds with `--buildDrafts` into a throwaway `.i18n-smoke.tmp` directory (removed
afterwards; nothing reaches `public/`), then reports `PASS` / `FAIL` per check:

```
PASS  site builds with both languages
PASS  chinese pages declare lang="zh"
PASS  chinese feed is generated
PASS  chinese home page is built
PASS  a paired english post shows the language switch
PASS  header order: profile links -> language switch -> dark-mode toggle, then the script that wires it
PASS  the switch links to the chinese twin
PASS  the chinese post shows the language switch back
PASS  the switch links back to the english original
PASS  chinese tag links stay under /zh/ (absLangURL override intact)
PASS  dates render in Chinese
PASS  an untranslated post shows no language switch
PASS  hugo.toml uses no deprecated keys
NOTE  deprecation coming from theme templates, not from this site config: …
```

GitHub Actions runs it after the build and before pushing to Pages, so a broken wiring fails
the deploy instead of appearing to a reader as a 404.

### Choosing the Hugo binary

`HUGO_BIN=<path>` wins. Otherwise the script uses `hugo` from `PATH` and stops with a clear
message if there is none. In CI, `./hugo` is the binary the workflow downloads, which is why
CI passes `HUGO_BIN=./hugo`.

### The fixture it depends on

`content/posts/i18n-smoke-test.md` and `.i18n-smoke-test.zh.md` are a **draft** pair, so
they never render in a production build. The check uses them as a known-paired post: one to
prove the switch appears and links both ways, and one real untranslated post to prove it
doesn't appear when there is nothing to link. If you delete the fixture, delete the
`i18n smoke check` step in `.github/workflows/deploy.yml` too — the script will tell you
exactly that:

```
FAIL  test fixture pair exists (content/posts/i18n-smoke-test.md + .zh.md) — restore it or remove the CI step
```

### When a check fails

| Check | Usual cause |
| --- | --- |
| `chinese pages declare lang="zh"`, dates not Chinese | `[languages.zh] locale` missing or renamed in `hugo.toml` |
| `chinese tag links stay under /zh/` | a `tags/` link in one of this site's templates was built with `absURL` instead of `absLangURL` |
| `a paired … post shows the language switch` | `translationKey` gone from the fixture, or the header no longer calls the partial |
| `every real pair renders the switch in BOTH directions` | `translationKey` missing from the English original of a real post (the fixture cannot catch this: it has its key on both files) |
| `header order: …` | the switch or the dark-mode toggle moved, or the header `<script>` moved back above the nav |
| `hugo.toml uses no deprecated keys` | a `languageCode` / `languageName` came back in the config |

The `NOTE` line is not a failure: it reports a deprecation coming from theme templates rather
than from this site's config. The build currently reports none — see
[zh.md → Known warnings](./zh.md#known-warnings) for what it means if one comes back.

---

## What none of them do

- No machine translation, anywhere. Article text is written by you.
- No rewriting of existing posts. `new-zh-post.sh` only ever creates a new file.
- No publishing decisions. `draft: true` is a starting point, not a policy.
- No automatic CI for `i18n-status.sh` — it is a report you run when you want one. Only
  `i18n-smoke.sh` runs in CI.
