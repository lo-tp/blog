# Using the scripts

One helper for the Chinese edition. It scaffolds a file — **it does not translate anything**.
Why the edition is built this way: [ADR 0001](./adr/0001-hugo-i18n-with-zh-language-key.md).
The writing workflow around it is in [zh.md](./zh.md).

| Script | What it does | Writes to the repo? | Exit codes |
| --- | --- | --- | --- |
| `scripts/new-zh-post.sh` | create the `<slug>.zh.md` file to translate into | yes, one new file | 0 created · 1 error · 2 bad usage |

It works from any directory: it `cd`s to the repo root first.

Nothing in this repo checks the site for you. There is no build check, no pairing report and no
render measurement; what the bilingual wiring depends on is asserted in [zh.md](./zh.md) and
caught, if it breaks, by reading the pages.

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
- **When it does write the original, it preserves that original's mtime.** A commit date for the
  original later than the translation is **drift** ([CONTEXT.md](../CONTEXT.md)); a tool whose job
  is to *start* a translation must not manufacture drift at the moment of scaffolding.
- **`draft: true` is only added if you said nothing about draft.** If the original declares
  `draft: false`, that is respected.
- The English body is pasted inside an HTML comment, with any `-->` escaped to `--&gt;` so
  the comment cannot close early. It cannot leak into the published page.

### It will not

write Chinese, pick tags, rename files, or publish anything. It edits the English original in
exactly one way: inserting a missing `translationKey` inside its front matter. Nothing else in
that file moves.

---

## What it does not do

- Translate. Article text is written by you.
- Rewrite an existing post, except for inserting a missing `translationKey`.
- Make publishing decisions. `draft: true` is a starting point, not a policy.
- Check the site. The deploy builds and publishes without running any check of the bilingual
  wiring or the rendered page; that is the author's read.
