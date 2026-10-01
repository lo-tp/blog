# Using the scripts

Three helpers for the Chinese edition. They scaffold files, report state, and check the
wiring — **none of them translate anything**. Why the edition is built this way:
[ADR 0001](./adr/0001-hugo-i18n-with-zh-language-key.md). The writing workflow around these
scripts is in [zh.md](./zh.md).

| Script | What it does | Writes to the repo? | Exit codes |
| --- | --- | --- | --- |
| `scripts/new-zh-post.sh` | create the `<slug>.zh.md` file to translate into | yes, one new file | 0 created · 1 error · 2 bad usage |
| `scripts/i18n-status.sh` | report untranslated / orphan / unpaired / drifted | no | always 0 |
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

Then it prints the next steps: translate `title` and `description`, swap `tags` for Chinese
ones, translate the body and delete the 原文 comment, keep the filename / `translationKey` /
`date` / `images` paths unchanged, and remove `draft: true` when the Chinese reads like your
own writing.

### Rules it enforces

- **Refuses to overwrite.** If `<slug>.zh.md` exists it stops instead of clobbering your work.
- **Needs front matter.** A post with no opening `---` block is an error, not a silent guess.
- **`translationKey` is only added if absent.** If you already set your own key it is kept.
- **`draft: true` is only added if you said nothing about draft.** If the original declares
  `draft: false`, that is respected.
- The English body is pasted inside an HTML comment, with any `-->` escaped to `--&gt;` so
  the comment cannot close early. It cannot leak into the published page.

### It will not

write Chinese, pick tags, rename files, touch the English original, or publish anything.

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
PASS  header order: social icons -> language switch -> dark-mode toggle, then the script that wires it
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
| `chinese tag links stay under /zh/` | the vendored `layouts/_default/single.html` lost its `absLangURL`, or the theme copy overwrote it |
| `a paired … post shows the language switch` | `translationKey` gone from the fixture, or the header no longer calls the partial |
| `header order: …` | the switch or the dark-mode toggle moved, or the header `<script>` moved back above the nav |
| `hugo.toml uses no deprecated keys` | a `languageCode` / `languageName` came back in the config |

The `NOTE` line is not a failure: it is the theme's own `.Site.LanguageCode` usage,
explained in [zh.md → Known warnings](./zh.md#known-warnings).

---

## What none of them do

- No machine translation, anywhere. Article text is written by you.
- No rewriting of existing posts. `new-zh-post.sh` only ever creates a new file.
- No publishing decisions. `draft: true` is a starting point, not a policy.
- No automatic CI for `i18n-status.sh` — it is a report you run when you want one. Only
  `i18n-smoke.sh` runs in CI.
