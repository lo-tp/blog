# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Primary — engineers who build projects and write code.** They arrive mid-work: a LeetCode problem they are stuck on, a tooling or architecture choice they have to make, a workflow (coding agents, TDD with async code, spaced repetition, Notion automation) they want to try. They want the answer and the working code, quickly, without wading through filler.

**Co-primary — recruiters and prospective collaborators**, served by the blog's second purpose as a **personal brand site**. They arrive knowing nothing about the author and leave with a read on him: what he has actually built, how he reasons about a problem, how he writes about a decision, whether he is someone worth working with. They read the site end-to-end — home page, the author's own identity block, one representative article — rather than arriving with a specific problem.

**The author himself.** The site is a durable public record of what he thinks, spanning 2016 to now, that he returns to and that keeps explaining its own decisions years later.

**Chinese-speaking engineers** read `/zh/` as a complete site in its own right, doing the same jobs.

## Product Purpose

A personal engineering blog of first-hand technical notes: problems the author actually solved, written up with the code, scripts and gotchas that came out of doing them. English at `/` is the canonical edition; a hand-authored Simplified-Chinese edition runs as a full parallel site under `/zh/`.

It has two purposes, both named by the author. For the visitor: **the reader gets what they want from the blog efficiently.** For the author: **a durable public record of what he thinks, which doubles as his personal brand site** — the place a recruiter, a collaborator or a future employer forms a read on him.

These are one mechanism, not two products: the brand is carried by the record. The site makes no claim about the author that a reader cannot verify by reading an article, running a script, or looking at a linked profile. The first is measured by the reader's task ending quickly; the second by an article still being worth reading, and still explainable, years after it was written.

## Positioning

Every article is something the author personally did, published with the artifact and the failure intact — the actual script, the measured number, the trap that silently dropped 15 pages from a build. The blog is written to be reused by someone mid-project, not browsed for inspiration.

The second language is authored, not generated. Each Chinese article is hand-translated and explicitly paired with its Original; the tooling only makes the pairing possible and reports its state honestly (drift is surfaced, never assumed away). No article body is ever produced automatically.

Its decisions are written down as durable artifacts: `CONTEXT.md` owns the vocabulary, `docs/adr/` owns the architecture calls, `docs/zh.md` and `docs/scripts.md` own the maintenance cost, and a CI smoke check fails the deploy when the bilingual wiring quietly breaks.

A search-farm article, a machine-mirrored bilingual site, or agent-hype commentary could not truthfully copy any of those three — and the personal-brand impression the site produces depends on all three at once: a decade of the same person's decisions, in his own handwriting, in two languages, with the tooling and the reasoning left visible.

Deliberately **not**: an SEO content farm, a marketing-style personal-brand page assembled from claims, or commentary on AI hype. The brand here is the work and the writing, never copy written to sound impressive.

## Operating Context

- Articles are Markdown in `content/posts/`, one file per language, paired by `translationKey` on **both** files.
- Local work: `./hugo server` (English at `:1313/`, Chinese at `:1313/zh/`); `scripts/new-zh-post.sh` scaffolds a translation; `scripts/i18n-status.sh` reports what is left to do; `scripts/i18n-smoke.sh` proves the wiring; `scripts/measure-home-gap.sh` measures header/profile spacing.
- Publishing: GitHub Actions builds with Hugo 0.166.0, runs the i18n smoke check **before** pushing, and publishes to `lo-tp/lo-tp.github.io`, served at `blog.lotp.xyz` (`static/CNAME`). `deploy.sh` is the manual equivalent.
- Reading scenes: desktop browser and phone (on mobile the header items collapse into the menu overlay), in both light and dark mode.
- Existing materials: `static/images/` post images and GIFs, `static/portrait.jpeg`, robots.txt. No visual identity work has been done beyond the theme plus `assets/custom.css`.

## Capabilities and Constraints

**Language model (binding).** English is the source of record; Chinese is served under `/zh/` as a complete site (own home page, own tag pages, own feed). Language choice is always explicit — no Accept-Language redirects (ADR 0001). The switch renders only where a counterpart exists; an **Untranslated post** is a legal, permanent state, not a gap to fill. `zh` means Simplified Chinese specifically, because Hugo resolves theme i18n by exact key; a Traditional edition would be a separate `zh-hant` language.

**Translation is the author's work.** Tooling never translates article text.

**Terminology is fixed.** Use Original, Translation pair, Untranslated post, Orphan translation, Translation drift, Author translation as defined in `CONTEXT.md`; avoid its listed `_Avoid_` synonyms. Inside Chinese prose, code, commands, file paths, API/library/product names and people's names stay English (保留原文).

**Hard requirement stated by the author:** links to GitHub (`lo-tp`), X (`lo__tp`) and LinkedIn must stay present and reachable. They currently live in the header nav in the order social icons → language switch → dark-mode toggle; on mobile all three are inside the menu overlay, which is why dark mode takes two taps on a phone.

**Deliberate maintenance debt.** `layouts/_default/list.html`, `layouts/_default/single.html` and `layouts/partials/header.html` are vendored copies of hugo-paper's with intentional changes (`absLangURL` tag links, the language switch's position, the header `<script>` sitting after the dark-mode toggle). Diff them against the theme before any hugo-paper update. In a content template nothing may render outside the `define` blocks.

**Spacing has one source.** `assets/custom.css` owns header nav gap and home/article top spacing via `--nav-gap`, `--home-gap`, `--profile-lift`, `--post-gap`, `--article-gap`; the theme's own utilities are cancelled with `!important`. Change one variable, not several.

**Other factual constraints.** Hugo 0.166.0 pinned in CI; `pagerSize = 10`; goldmark `unsafe = true`; one known theme-owned deprecation warning (`.Site.LanguageCode`) that this design accepts rather than vendoring `baseof.html`; Hugo also emits `/en/…` aliases that must be left alone; no subscribe UI — RSS is not enabled in `hugo.toml`, though `/zh/index.xml` exists and can be subscribed directly.

**Resolved by the author.**
- **Replacing the theme is permitted.** hugo-paper 6.30 and the three vendored layouts are the incumbent implementation, not a protected asset; an authored visual world may replace them. What must survive any such replacement unchanged: the bilingual wiring (ADR 0001, explicit switch, `translationKey` pairs on both sides, tag links under `/zh/`, `lang="zh"` and Chinese dates), the social links, the article content, and what `scripts/i18n-smoke.sh` guarantees. Replacement is a decision taken when a redesign is actually requested, and is never a licence to touch the wiring.
- **`/zh/` site chrome must be localized.** `title`, `description` and `bio` under `[languages.zh]` in `hugo.toml` are to be filled in so the Chinese edition stops inheriting the English values. This is authored Chinese copy in the author's own voice — not a translation of English site text — and it obeys the 保留原文 rule.

**Out of scope for now — deferred by the author, not gaps to fill.**
- Translating the remaining 14 English originals. Later work. In the meantime an Untranslated post stays a legal, permanent state, and no UI may present one as incomplete or count it as progress owed.
- Subscribe / RSS affordances. Not a priority; no subscribe UI is to be built, promised, or implied.
- The Chinese tag name for `Skill` remains the author's call (`docs/zh.md`).

## Brand Commitments

- Name: **Lotp's Blog** / "Lotp"; author handle **lotp**; bio **"Every Day in Life Is a First Time"**; avatar `https://blog.lotp.xyz/portrait.jpeg`.
- Voice: first-person, practical, technically specific. The author writes and translates every article by hand; nothing on the site is machine-authored.
- Identity base today: hugo-paper 6.30, with the site's own `assets/custom.css` overrides. The name, bio, avatar and the three social links carry product weight — they are how the personal-brand purpose is delivered — and are binding in any future design. The theme itself is not binding.
- `CONTEXT.md` is the authoritative vocabulary; its definitions and `_Avoid_` lists carry into any future copy or UI text.

## Evidence on Hand

- 16 published English originals dated 2016-08 through 2026-09 in `content/posts/` (LeetCode solutions, TDD with async/await, iframe/postMessage in React, Redux style, Meteor, Linux disk cloning, spaced-repetition algorithm, reading notes, coding-agent + Notion workflow).
- 2 hand-authored Chinese pairs: `I-Let-My-Coding-Agent-Manage-My-Notion-Tasks.zh.md`, `i18n-smoke-test.zh.md` (the latter is a draft fixture, never published).
- Real media: `static/images/notion-agent-cover.jpg`, `static/images/demo-video/demo.gif`, `static/images/swipteToDelete.gif`, `static/images/2018/08/learnFast.jpg`, `static/images/2020/superEggDrop/cover.png`, `static/images/iframePostmessge.gif`.
- Written decisions and tooling: `CONTEXT.md`, `docs/adr/0001-hugo-i18n-with-zh-language-key.md`, `docs/zh.md`, `docs/scripts.md`, `scripts/` (4 scripts), `.github/workflows/deploy.yml`.

**Absent, and must not be invented:** no analytics, no readership or traffic numbers, no testimonials, no reader feedback at all (stated by the author), no company, customer or employer claims, no benchmarks, no pricing or licensing, no press. No future design may imply any of them.

## Product Principles

1. **Answer first.** The reader's question decides what is above the fold. Anything that delays the answer — framing, self-description, decorative structure — is cut.
2. **First-hand only.** Publish what the author actually built or ran, keeping the working code and the failure. No summarizing someone else's experience to fill a slot.
3. **Durable, not timely — and the record *is* the brand.** Write for the reader who arrives in five years. Date-bound facts stay visibly date-bound; a decision is recorded where a future reader or maintainer can find it. Every impression the site gives of the author must be traceable to an article, a script, a measured result, or a linked profile that is already there.
4. **Pairing is declared or it does not exist.** Two articles with similar titles are not a pair; the `translationKey` must exist on both sides, and drift is reported rather than smoothed over.
5. **Change one thing at a time.** Spacing, tags, and language wiring each have a single declared source of truth; a design change is made there or not at all.

## Accessibility & Inclusion

No formal standard is required — the author asked for the ordinary baseline, which here means: readable contrast in both light and dark mode, keyboard-operable controls, real `alt` text on post images, visible focus, and a layout that works on a phone with no hover available.

Known existing friction: on mobile the social links, the language switch and the dark-mode toggle all sit inside the menu overlay, so toggling dark mode takes two taps. The Chinese edition additionally depends on correct `lang="zh"` and Chinese date formatting, which the smoke check guards.
