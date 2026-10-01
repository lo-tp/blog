# 中文版本 / The Chinese edition

The Chinese version of this blog lives in the same Hugo site, under `/zh/`. English stays
at `/` and is the source of record. Why it is built this way:
[ADR 0001](./adr/0001-hugo-i18n-with-zh-language-key.md). The vocabulary this feature uses
(original, translation pair, drift, orphan) is in [CONTEXT.md](../CONTEXT.md).

Scope of the tooling: it makes a Chinese edition possible and keeps it honest. **Every
translation is written by the author.** Nothing here translates article text.

## Add a Chinese version of a post

```sh
scripts/new-zh-post.sh I-Let-My-Coding-Agent-Manage-My-Notion-Tasks
# → content/posts/I-Let-My-Coding-Agent-Manage-My-Notion-Tasks.zh.md
./hugo server          # http://localhost:1313/zh/
```

The script copies the English front matter, adds the `translationKey` that pairs the two
files, sets `draft: true`, and pastes the English body inside a `<!-- 原文 … -->` comment
to translate against. Then:

1. Translate `title` and `description`.
2. Replace `tags` with Chinese tags (see the list below).
3. Translate the body, delete the 原文 comment.
4. Remove `draft: true` when it reads like your own writing.

Keep unchanged: the filename (`<same-slug>.zh.md`), `translationKey`, `date`, `images` paths.

**Without a `translationKey` the two files are not a pair.** Hugo will happily build both,
but neither page links to the other and no `hreflang` is emitted. This is the single easiest
way to get it wrong.

## What Hugo does for free

Once the language and the pair exist: `lang="zh"` on the HTML, Chinese dates (`2026年3月1日`),
the theme's own Chinese pagination strings (上一页 / 下一页), `/zh/index.xml`, a sitemap listing
both languages, `hreflang` alternates on paired pages, and a language switch in the header
nav, after the social icons — `中文` on English pages, `English` on Chinese ones. The
header row therefore reads: social icons → language switch → dark-mode toggle. On mobile all
of them live in the menu overlay, so the dark-mode toggle now takes two taps on a phone.

The switch renders **only where a counterpart exists**: an untranslated post shows no `中文`
link at all. Reach the Chinese edition from such a post through `/zh/`.

Site chrome for Chinese is yours to write: `title` and `params` placeholders for `/zh/` are
commented out in `hugo.toml` under `[languages.zh]`. Until you fill them, Chinese pages
inherit the English values.

## Tags

Chinese posts use Chinese tags, and their tag links point at `/zh/tags/…`. That only works
because `layouts/_default/single.html` is a vendored copy of the theme's with
`absURL "tags/"` changed to `absLangURL "tags/"` — upstream, a Chinese post's tags would
point at the English tag pages and 404.

Proposed tag names (the author owns this list; keep it short and consistent — every new
spelling of a tag creates a second tag page):

| English tag | Chinese tag |
| --- | --- |
| LeetCode, DP, DFS, BFS, TDD, LLM, ES7, UX, React, Redux, Notion, Mocha, Meteor, Linux, iframe, postmessage | keep as-is |
| Algorithm | 算法 |
| Bit Operation | 位运算 |
| Functional Programming | 函数式编程 |
| Greedy | 贪心 |
| Test | 测试 |
| Reading Notes | 读书笔记 |
| Coding Agent | 编程代理 |
| Skill | your call — 技能 reads oddly; keeping `Skill` is defensible |
| Learn | drop it; it carries no meaning as a tag |

Code, commands, file paths, library and product names stay English inside Chinese prose. The
proposed terminology for article text is in [CONTEXT.md](../CONTEXT.md).

## Checking the state of the Chinese edition

```sh
scripts/i18n-status.sh
```

Informational, always exits 0. Reports originals with no Chinese counterpart, orphan
translations, translations missing a `translationKey`, and **drift** — a translation whose
English original was committed later than the translation itself. Drift is expected; the
point is that it is visible rather than assumed away.

## The smoke check

```sh
scripts/i18n-smoke.sh                                    # locally
HUGO_BIN=./hugo bash scripts/i18n-smoke.sh              # as CI runs it
```

Builds into a throwaway `.i18n-smoke.tmp` directory with drafts included and asserts: both
languages build, Chinese pages declare `lang="zh"`, the Chinese feed exists, a paired post
links to its twin in both directions, the header renders social icons → language switch →
dark-mode toggle with the script after them, an unpaired post
shows no switch, Chinese tag links
stay under `/zh/`, dates render in Chinese, and `hugo.toml` uses no deprecated keys.

CI runs it after the build and **before** pushing to GitHub Pages, so a broken wiring fails
the deploy instead of surfacing as a 404 for a reader.

It depends on a draft fixture pair, `content/posts/i18n-smoke-test.md` and
`.i18n-smoke-test.zh.md`. Drafts are never published. If you delete the fixture, delete the
`i18n smoke check` step in `.github/workflows/deploy.yml` too.

## Vendored layout files (the maintenance cost of this design)

Two layout files are copies of the theme's, with deliberate changes:

| File | Why it is vendored |
| --- | --- |
| `layouts/_default/list.html` | predates the Chinese edition (post list layout) |
| `layouts/_default/single.html` | `absLangURL` tag links |
| `layouts/partials/header.html` | language switch after the social icons, dark-mode toggle after that, and the header `<script>` moved below them |

Before updating `hugo-paper`, diff them and re-apply the intended changes by hand:

```sh
diff themes/hugo-paper/layouts/_default/single.html layouts/_default/single.html
diff themes/hugo-paper/layouts/_default/list.html  layouts/_default/list.html
diff themes/hugo-paper/layouts/partials/header.html layouts/partials/header.html
```

The smoke check exists because this is the fragile part of the design: a theme update that
reintroduces `absURL "tags/"`, or a vendored copy that quietly loses a change, otherwise
looks like a healthy build.

One trap worth knowing: in a content template such as `single.html`, **nothing may render
outside the `define` blocks**. A plain HTML comment at the top of the file makes Hugo drop
every post page silently — 15 articles vanish, zero errors. Use a Hugo comment
(`{{- /* … */ -}}`) inside the template instead, or put notes here.

A second trap lives in the vendored `header.html`: its inline `<script>` does
`document.querySelector('.btn-dark')`, so it must appear **after** the dark-mode toggle in
document order. That script sits at the bottom of `<header>` for that reason. Move it back
above the nav and the dark-mode button stops working, with nothing in the build log to tell
you.

## Known warnings

`hugo` reports one deprecation this site does not control:

```
WARN deprecated: .Site.LanguageCode was deprecated in Hugo v0.158.0 … Use .Site.Language.Locale instead.
```

It comes from the theme's `layouts/_default/baseof.html`, not from `hugo.toml`. It is
harmless today. Silencing it means vendoring `baseof.html` too, which this design
deliberately avoids; the smoke check reports it as a note and fails only on
config-level deprecations.

## Two things that are not what they look like

- Hugo also emits English pages under `/en/…` (aliases of `/…`). They are redirects with a
  canonical link; leave them alone.
- There is no subscribe UI. RSS is not enabled in `hugo.toml`, but `/zh/index.xml` exists
  and can be subscribed directly. If you ever enable the theme's RSS icon, change its
  `index.xml | absURL` to `absLangURL` in the vendored header first — as written it points
  Chinese readers at the English feed.

## Adding Traditional Chinese later

`zh` here means Simplified Chinese, deliberately: Hugo looks up theme translation files by
exact language key and does not fall back from `zh-cn` to the theme's `zh.yaml`. A
Traditional edition would be a separate `zh-hant` language with its own `i18n/zh-hant.yaml`
copied from the theme's `zh.yaml`, its own `[languages.zh-hant]` block, and `.zh-hant.md`
content files. Nothing in this layout blocks it.
