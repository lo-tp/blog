# 中文版本 / The Chinese edition

The Chinese version of this blog lives in the same Hugo site, under `/zh/`. English stays
at `/` and is the source of record. Why it is built this way:
[ADR 0001](./adr/0001-hugo-i18n-with-zh-language-key.md). The vocabulary this feature uses
(original, translation pair, drift, orphan) is in [CONTEXT.md](../CONTEXT.md).

Scope of the tooling: it makes a Chinese edition possible and keeps it honest. **Every
translation is written by the author.** Nothing here translates article text. The scripts in
detail: [scripts.md](./scripts.md).

## Add a Chinese version of a post

```sh
scripts/new-zh-post.sh I-Let-My-Coding-Agent-Manage-My-Notion-Tasks
# → content/posts/I-Let-My-Coding-Agent-Manage-My-Notion-Tasks.zh.md
./hugo server          # http://localhost:1313/zh/
```

The script copies the English front matter, ensures the `translationKey` that pairs the two
files exists **on both of them** (adding it to the English original when it is missing — pairing
is read from both sides), sets `draft: true`, and pastes the English body inside a `<!-- 原文 … -->`
comment to translate against. Then:

1. Translate `title` and `description`.
2. Replace `tags` with Chinese tags (see the list below).
3. Translate the body, delete the 原文 comment.
4. Remove `draft: true` when it reads like your own writing.

Keep unchanged: the filename (`<same-slug>.zh.md`), `translationKey`, `date`, `images` paths.

**Without a `translationKey` on both files the two files are not a pair.** Hugo will happily
build both, and a key on the translation alone will even make the English page show `中文` — but
the Chinese page renders no switch back and no `hreflang="en"`, because Hugo resolves
`.Translations` from both sides. This is the single easiest way to get it wrong, and nothing in
the repo catches it for you: the build is clean and the English half looks fine. Check both files'
front matter when a switch is missing in one direction.

## What Hugo does for free

Once the language and the pair exist: `lang="zh"` on the HTML, Chinese dates (`2026年3月1日`),
the theme's own Chinese pagination strings (上一页 / 下一页 — the reason `hugo-paper` is still
installed), `/zh/index.xml`, a sitemap listing both languages, `hreflang` alternates on paired
pages, and a language switch in the header — `中文` on English
pages, `English` on Chinese ones. The header's control row therefore reads: profile links →
language switch → dark-mode dial, at every width including a phone. There is no menu to open,
so the dark-mode dial is one tap on a phone. On an inner page the row is unlabelled and the
language control appears only where a twin exists; the night dial is always there.

The switch renders **only where a counterpart exists**: an untranslated post shows no `中文`
link at all. Reach the Chinese edition from such a post through `/zh/`.

Site chrome for Chinese is authored in `hugo.toml` under `[languages.zh]`: `title`,
`params.bio` and `params.description` are the Chinese edition's own wording, drafted for the
author's approval. It is site chrome, not a translation of any article — replace any line you
would not write yourself. Without those keys, Chinese pages inherit the English values.

## Tags

Chinese posts use Chinese tags, and their tag links point at `/zh/tags/…`. That only works
because every tag link in this site's own templates is built with `absLangURL "tags/"` —
`layouts/_default/single.html`, `layouts/partials/record-row.html`,
`layouts/partials/index-rail.html`. With `absURL`, a Chinese post's tags would point at the
English tag pages and 404.

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

## Nothing checks this for you

There is no build check, no pairing report and no render measurement in this repo: the CI job
builds and publishes, and `scripts/new-zh-post.sh` is the only helper left. Everything below is a
list of things that break **without a build error or a failing check** — the price of removing the
checks is that reading the pages is what catches them.

- a `translationKey` on one side only (see above): the switch works in one direction.
- a ledger row that prints two titles, or a record page that prints its twin beside its own: the
  one-title-per-row and one-edition-at-a-time rules broken.
- a header whose controls overlap, wrap out of order, or a dial that does nothing when clicked.
- Chinese pages that lost `lang="zh"`, Chinese dates, or `/zh/` tag links.

## The templates and the stylesheet (what the design is made of)

No template from `hugo-paper` renders any more. The markup and the whole visual world are the
site's own:

| File | What it owns |
| --- | --- |
| `layouts/_default/baseof.html` | the shell: pre-paint edition script, header, `<main class="sheet page">`, colophon |
| `layouts/partials/head.html` | requests **one** stylesheet, `assets/custom.css`, concatenated to `main.css` and fingerprinted |
| `layouts/partials/header.html` | the header: the masthead band — masthead or part title, then the profile links → language switch → dark-mode dial — sticky on every page, then the script that publishes its height and wires the dial |
| `layouts/partials/edition-controls.html` | the reader's two edition controls, labelled on the title page and plain on inner pages |
| `layouts/_default/list.html`, `layouts/partials/{records,ledger,record-row,index-rail}.html` | the title page, the contents ledger, the technique index, pagination |
| `layouts/_default/single.html` | a record: meta rule, body, edition switch, earlier/later |
| `layouts/partials/record-row.html` | one ledger row: date, title, tags. Nothing about the other language |
| `layouts/404.html` | the page printed when a record is not there |
| `assets/custom.css` | every colour, rule, measure, spacing rhythm, state and movement. Nothing else styles this site |

`hugo-paper` stays installed for two things only: its i18n files (`prev_page` / `next_page`
and the rest of the Chinese chrome strings Hugo looks up by language key) and its static
assets (the social icon set, favicon). A theme update that rewrites `themes/hugo-paper/layouts/`
cannot change what this site renders, so the old ritual — diff each vendored copy before
updating the theme, re-apply the intended changes by hand — is gone. What has to stay correct is
the wiring in this project's own files: `absLangURL` tag links, the language switch only where a
twin exists, the one-title-per-row ledger, and the control order in `header.html`. No check
enforces them.

One trap worth knowing: in a content template such as `single.html`, **nothing may render
outside the `define` blocks**. A plain HTML comment at the top of the file makes Hugo drop
every post page silently — 15 articles vanish, zero errors. Use a Hugo comment
(`{{- /* … */ -}}`) inside the template instead, or put notes here.

A second trap lives in `header.html`: the inline `<script>` that wires the dark-mode dial looks
the control up by selector, so it must appear **after** it in document order. That script sits
at the bottom of the header band for that reason. Move it above the controls and the dial
stops working, with nothing in the build log to tell you. The same script measures the band and
publishes the result as `--band-h`, which is what the sticky index rail and the `#y####` anchors
offset from — the band's height is its own content, so nothing hardcodes it. (`baseof.html` also runs a script
before paint, which applies the stored edition so a night reader never sees a flash of paper
first. Both are worth re-reading after any edit to the header.)

## Header spacing

The controls in the header band (profile links, language switch, dark-mode dial) are spaced by
one value in `assets/custom.css`:

```css
:root { --nav-gap: 0.75rem; }
```

`assets/custom.css` is the site's only stylesheet: `layouts/partials/head.html` asks for it and
nothing else, so the theme's compiled Tailwind is not loaded by any page and there is no
utility class to fight. Change `--nav-gap` and nothing else. If `assets/custom.css` stops being
in the pipeline the token stops shipping and the header spacing is the first thing that shows it.

## Known warnings

`hugo` reports none. The one this site used to carry —

```
WARN deprecated: .Site.LanguageCode was deprecated in Hugo v0.158.0 … Use .Site.Language.Locale instead.
```

came from the theme's `layouts/_default/baseof.html`, which stopped rendering when the shell
became `layouts/_default/baseof.html` in this repo. If a theme-template deprecation ever comes
back to `hugo`'s output, the first thing to check is whether a theme template is being rendered
again.

## Two things that are not what they look like

- Hugo also emits English pages under `/en/…` (aliases of `/…`). They are redirects with a
  canonical link; leave them alone.
- There is no subscribe UI. RSS is not enabled in `hugo.toml`, but `/index.xml` and
  `/zh/index.xml` are generated and can be subscribed directly. If a subscribe control is ever
  added to the header band or the colophon, its feed link must be built with
  `absLangURL "index.xml"`: written as `absURL`, it points Chinese readers at the English feed.

## Adding Traditional Chinese later

`zh` here means Simplified Chinese, deliberately: Hugo looks up theme translation files by
exact language key and does not fall back from `zh-cn` to the theme's `zh.yaml`. A
Traditional edition would be a separate `zh-hant` language with its own `i18n/zh-hant.yaml`
copied from the theme's `zh.yaml`, its own `[languages.zh-hant]` block, and `.zh-hant.md`
content files. Nothing in this layout blocks it.
