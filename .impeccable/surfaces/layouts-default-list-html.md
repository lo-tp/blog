---
version: 1
slug: "layouts-default-list-html"
primary_target: "layouts/_default/list.html"
related_targets: ["layouts/_default/single.html","layouts/partials/header.html","assets/custom.css"]
---

# Surface brief — home page and the edition apparatus

Primary target: `layouts/_default/list.html`
Visitor mode: **Persuade** on the home page and tag index (the visitor decides what to read and forms a read on the author); **Read** on the article page (`layouts/_default/single.html`).

## Audience, job, action

Engineers mid-project: find the one record that answers the problem they are holding, then read it. Recruiters and prospective collaborators: form a read on the author in one pass over the front matter and one record. Chinese-speaking readers do both on `/zh/`, which is a complete edition, not a mirror.

Actions on the surface: open a record, enter a technique index, jump to a year, switch to a record's twin language, reach GitHub / X / LinkedIn.

## Constraints held fixed

Bilingual wiring (`translationKey` on both files, `absLangURL` tag links, `lang="zh"`, Chinese dates, explicit switch only, no switch where no twin exists); `scripts/i18n-smoke.sh`'s header order — social icons → language switch → dark-mode toggle → the script that wires it; `--nav-gap` must ship in the built CSS; no new build tooling (CI downloads a Hugo binary only); real counts only — 15 published Originals, 1 Author translation, 14 Untranslated posts, 2016 → 2026; no analytics, testimonials or invented claims; name, bio, avatar and the three social links stay.

## Direction contract

**THESIS.** The site is a bilingual printed edition, not a blog template: running head, folio number and the facing pair are the organising apparatus. It refuses the incumbent arrangement — avatar, bio, then a chronological list of bare titles — and refuses the marketing hero it could easily become.

**OWN-WORLD.** Cool paper `#f2f3f4`, graphite ink `#1a1a1f`, technical blue `#2f5d8a` for navigation and index chrome, brick `#b03f26` reserved for one thing only: the record or technique you are on. Night edition `#141719` with chalk values, never neon. Hairline rules, a centre gutter, running heads and date/folio numerals in self-hosted Archivo Narrow with tabular figures; Latin body in a workhorse UI stack, Chinese prose in Songti, Chinese headings in PingFang, code in system mono on a graphite plate. No cards, no textures, no gradients.

**STORY.** A visitor lands on an edition's front matter: the author named, the span dated, the contents as a ledger of numbered records indexed by technique and by year. Paired records print as two joined halves — Original and 中文 — with one folio in the gutter; Untranslated posts hold the full measure with no gap and no apology. What is provable is on the page; nothing else is.

**FIRST VIEWPORT (1440).** A masthead band under a hairline: `LOTP` at ~52px tracked caps in Archivo Narrow, set flush left against a centre rule; beside it a two-line front matter in tracked small capitals — `工程记录 / ENGINEERING NOTES · 2016 → 2026` and `WRITTEN AND TRANSLATED BY HAND`. Below it the spread divides: left column (34%) is the index — techniques with counts, the year spine 2016 … 2026, the author plate with avatar and the three profile links, the 中文 entry; right column (66%) is the contents ledger, records grouped under year markers, each row `№ 15 · 2026-09-30`, title in 22px, technique labels, and a joined `中文` half printed only where a twin exists. No hero image, no CTA.

**FORM.** Facing Pages — Loeb-classical facing-page editions and 中英对照 technical translations. Seed key `4a7c95a6`; chosen as `model-pick` over the assigned Problem Book, carrying the Problem Book's index discipline and the four raises (named states in text; the index plan travels with the ledger on phones; one ink reserved for one thing; whole-step state changes) plus the kept lines from Vertical Feed (prev/next named by title) and Collider Display (isolate a technique, dim the rest).

**FINISH.** unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance.

## Unresolved

`/zh/` chrome wording is drafted for the author's approval, not authored by the tool. The Chinese name of the `Skill` tag stays the author's call.
