---
status: accepted
---

# Hugo i18n with the `zh` language key, English kept canonical

The blog needs a Chinese edition. We decided to serve it from the same Hugo site and the
same domain under `/zh/`, using Hugo's built-in i18n: `[languages.en]` and `[languages.zh]`
in `hugo.toml`, `DefaultContentLanguage = "en"`, `defaultContentLanguageInSubdir = false`,
and Chinese articles as `content/posts/<english-slug>.zh.md` beside their English original.
A subdomain (`zh.blog.lotp.xyz`) and a second blog were rejected: both split the theme,
the deploy pipeline and the writing workflow in two, and neither can link an article to its
translation. English stays at `/` so every existing URL, bookmark and inbound link keeps
working; there is no Accept-Language redirect, only an explicit language switch.

## Considered Options

- **Same site under `/zh/`** — chosen: one build, one deploy, native cross-language linking, and the `hugo-paper` theme already ships `i18n/zh.yaml`.
- **Subdomain `zh.blog.lotp.xyz`** — extra DNS and Pages custom-domain handling, two base URLs, no `translationKey` pairing across them.
- **A second repository/blog for Chinese** — duplicated maintenance, no way to move a reader between a pair.

## Why the language key is `zh` and not `zh-cn`

Hugo looks up theme translation files by exact language key and does **not** fall back from
`zh-cn` to `zh.yaml` (verified on v0.166.0). Keying the language `zh` is what makes the
theme's shipped `上一页` / `下一页` apply, and what makes `locale = "zh"` localize Hugo's
named date formats (`2026年1月2日`). Keying it `zh-cn` would silently lose both. The
consequence is deliberate: `zh` means **Simplified Chinese only**. A Traditional edition
would later be a separate language (`zh-hant`) with its own copied `i18n/zh-hant.yaml`;
nothing in this layout blocks it.

## Consequences

- **Pairing is explicit, not incidental.** `.Translations` returns nothing for
  `slug.md` + `slug.zh.md` unless one of them declares `translationKey`. Every Chinese
  article carries `translationKey: <slug>`, and keeps its English slug so the URL stays
  stable if a title is reworded.
- **The theme's tag links are wrong for a second language.** `hugo-paper`'s
  `single.html` builds tag URLs with `absURL "tags/"`, which points a Chinese post's tags
  at the English tag pages. We own a vendored `layouts/_default/single.html` that uses
  `absLangURL "tags/"` instead, so `/zh/tags/…` is reachable. That vendored copy is a
  standing merge cost on every theme update — deliberate, not an oversight. `list.html` and
  `partials/header.html` are vendored too (the language switch and the dark-mode toggle
  belong at the end of the header nav, and the header `<script>` must come after them, since
  it does `document.querySelector('.btn-dark')`), so three theme files are ours to diff
  before an upgrade. The same class of bug as the tag links
  exists for the theme's RSS icon; RSS stays off because no subscribe UI was asked for.
  (Consequence, added later: the i18n smoke check that used to catch a quiet regression here
  was removed. Nothing in the repo catches it now.)
- **Translations are written by the author, never generated.** No article body is produced
  by tooling; the scripts only scaffold a paired file. Drift (a translation whose English
  original changed afterwards) is expected and tolerated; it is no longer reported by a script.
