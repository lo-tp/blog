---
name: Lotp's Blog — Facing Pages
description: A bilingual printed edition: one record, two languages, one typeset page.
colors:
  paper: "#f2f3f4"
  paper-pressed: "#e8eaec"
  graphite-plate: "#1b2023"
  ink: "#1a1a1f"
  ink-settled: "#4c5257"
  ink-muted: "#5f666c"
  hairline: "#c7ccd1"
  hairline-strong: "#9ba2a8"
  technical-blue: "#2f5d8a"
  technical-blue-deep: "#1f4468"
  brick: "#b03f26"
  chalk: "#e6e9ea"
  night-paper: "#141719"
  night-paper-pressed: "#1b2023"
  night-ink: "#e7eae6"
  night-ink-settled: "#a9b2b6"
  night-ink-muted: "#8b9499"
  night-hairline: "#2b3134"
  night-hairline-strong: "#454d52"
  night-technical-blue: "#8fbce6"
  night-brick: "#e08166"
typography:
  masthead:
    fontFamily: "'Archivo Narrow', 'Arial Narrow', sans-serif"
    fontSize: "clamp(2.4rem, 4.4vw, 3.25rem)"
    fontWeight: 700
    lineHeight: 0.95
    letterSpacing: "0.1em"
  part-title:
    fontFamily: "'Archivo Narrow', 'Arial Narrow', sans-serif"
    fontSize: "clamp(1.5rem, 3.2vw, 2.1rem)"
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: "0.08em"
  record-title:
    fontFamily: "var(--font-head)"
    fontSize: "clamp(1.7rem, 3.6vw, 2.3rem)"
    fontWeight: 700
    lineHeight: 1.16
  ledger-title:
    fontFamily: "var(--font-head)"
    fontSize: "1.3rem"
    fontWeight: 700
    lineHeight: 1.4
  body:
    fontFamily: 'system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "PingFang SC", "Hiragino Sans GB", "Songti SC", "Noto Sans CJK SC", sans-serif'
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.7
  body-cjk:
    fontFamily: '"Songti SC", STSong, "Hiragino Mincho Per Six", "Source Han Serif SC", "Noto Serif CJK SC", SimSun, serif'
    fontSize: "17px"
    lineHeight: 1.7
  label:
    fontFamily: "'Archivo Narrow', 'Arial Narrow', sans-serif"
    fontSize: "0.72rem"
    fontWeight: 600
    letterSpacing: "0.16em"
  folio:
    fontFamily: "'Archivo Narrow', 'Arial Narrow', sans-serif"
    fontSize: "0.8rem"
    fontWeight: 600
    letterSpacing: "0.08em"
  code:
    fontFamily: 'ui-monospace, "SF Mono", "JetBrains Mono", Menlo, Consolas, monospace'
    fontSize: "0.9rem"
    lineHeight: 1.62
rounded:
  none: "0"
spacing:
  g1: "0.5rem"
  g2: "1rem"
  g3: "1.5rem"
  g4: "2.5rem"
  g5: "4rem"
  nav-gap: "0.75rem"
  row-gap: "1.9rem"
  block-gap: "2.25rem"
  head-room: "2.75rem"
  head-room-after: "0.85rem"
components:
  running-head:
    height: "64px"
    textColor: "{colors.ink}"
  language-switch:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.technical-blue}"
    rounded: "{rounded.none}"
    padding: "0.25rem 0.4rem"
  language-switch-hover:
    backgroundColor: "{colors.paper-pressed}"
    textColor: "{colors.technical-blue-deep}"
  dark-dial:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.ink-settled}"
    rounded: "{rounded.none}"
    size: "22px"
  state-label:
    textColor: "{colors.brick}"
    typography: "{typography.label}"
  code-plate:
    backgroundColor: "{colors.graphite-plate}"
    textColor: "{colors.chalk}"
    rounded: "{rounded.none}"
    padding: "1rem 1.15rem"
  ledger-row:
    textColor: "{colors.ink}"
    backgroundColor: "{colors.paper}"
---

# Design System: Lotp's Blog — Facing Pages

## Overview

**Creative North Star: "Facing Pages"**

The site is typeset as a bilingual printed edition. A page is paper, not a screen full of
surfaces: one ground, one ink, hairline rules instead of boxes, a masthead header and a colophon
instead of a nav bar and a footer widget. The organising idea is the edition
switch — a record exists in two languages, and the site shows one of them at a time: the other
edition is a named control, never a second column of the same text printed beside it. Everything
else on the site is apparatus in service of that: a contents ledger, a technique index, a year spine, an
author plate, page turns named by title.

Density is editorial, not dashboard-y. The title page puts the index plan beside the contents
ledger, so the whole eight-year record is readable in one scroll without hiding anything behind
a menu. A record page sets one text block, centred between the sheet margins, and stops: no
related-content cards, no newsletter box, no comments prompt. The night edition is the same
page printed on slate in chalk, not a different design.

The bilingual claim has to be typographic, not a translated UI: Latin chrome in a condensed
grotesque, Chinese prose in Songti and Chinese headings in the sans, dates formatted per
edition, tag links resolved inside the reader's own language. **Key Characteristics:**

- One ground, one ink, rules instead of containers.
- The display face sets chrome only — never content.
- One reserved colour (brick) for the single thing the reader is on.
- States are named in words, never colour alone.
- Apparatus carries the chronology: the header band, folio dates, a year spine.

## Colors

A neutral, cool-toned print palette with exactly two chromatic accents, each with a stated job;
the night edition dims its accents with its paper so the contrast relationship is unchanged.

### Primary
- **Technical Blue** (#2f5d8a): navigation only — every link that moves you somewhere in the
  site, the language switch, index entries, page turns. Night: **Night Technical Blue** (#8fbce6).

### Secondary
- **Brick** (#b03f26): the reserved ink. Only the record or technique you are currently on — the
  date in a record's meta rule, the current entry in the technique index, a record's edition
  switch on hover, a named state such as `Untranslated post`. Never used for decoration,
  never two things on one screen. Night: **Night Brick** (#e08166).

### Neutral
- **Cool Paper** (#f2f3f4): the page. Deliberately not cream — a technical paper, not a warm one.
- **Pressed Paper** (#e8eaec): hover fills and table row banding only.
- **Graphite Ink** (#1a1a1f): text and the rules that structure a page.
- **Settled Ink** (#4c5257) / **Muted Ink** (#5f666c): secondary text — meta rules, tag lists,
  index counts, colophon. Both stay above 4.5:1 on paper (5.25:1 and 7.1:1).
- **Hairline** (#c7ccd1) / **Stronger Hairline** (#9ba2a8): row separators, control borders.
  Structure, not decoration.
- **Graphite Plate** (#1b2023) + **Chalk** (#e6e9ea): the one dark surface in either edition —
  code. Syntax colours come from this stylesheet, not from a highlighter theme.
- Night edition: **Night Paper** (#141719), **Night Ink** (#e7eae6), **Night Hairline** (#2b3134).

### Named Rules
**The Reserved Ink Rule.** Brick appears once per screen and only on the thing the reader is
on. If a screen needs two marks, one of them is wrong.
**The Blue-is-Motion Rule.** Blue means "this moves you". Nothing that is not a link is blue.

## Typography

**Display / Chrome Font:** Archivo Narrow (self-hosted, `static/fonts/archivo-narrow-latin.woff2`,
SIL OFL 1.1, variable 400–700) with Arial Narrow as fallback
**Body Font (Latin):** the system UI workhorse stack
**Body Font (Chinese):** Songti SC → Source Han Serif SC → Noto Serif CJK SC for prose; PingFang
SC / Heiti for Chinese headings
**Label / Folio Font:** Archivo Narrow, with `font-variant-numeric: tabular-nums lining-nums`
**Code Font:** the system mono stack

**Character:** a condensed editorial grotesque for apparatus against an unremarkable, highly
readable workhorse for content. The chrome is allowed to be characterful because it is short —
mastheads, year numerals, index labels, folios, page turns. Content is never set in it, because
long titles and long paragraphs must stay readable. Chinese is set the way Chinese is read: Songti
for prose, the sans for headings.

### Hierarchy
- **Masthead** (700, clamp(2.4rem, 4.4vw, 3.25rem), lh 0.95, tracked 0.1em, capitals): the title
  page only. Section and technique pages use **Part Title** (clamp(1.5rem, 3.2vw, 2.1rem)).
- **Record Title** (700, clamp(1.7rem, 3.6vw, 2.3rem), lh 1.16): the h1 of one record.
- **Ledger Title** (700, 1.3rem, lh 1.4): a row's title in the contents ledger.
- **Body** (400, 17px, lh 1.7): article prose, 57ch measure (≈75 characters per line).
- **Label** (600, 0.72rem, tracked 0.16em, capitals): the edition's label voice — `Contents`,
  `Index of techniques`, `Earlier record`, named states. Short strings only.
- **Meta / Folio** (500–600, 0.75–0.8rem, tracked 0.05em, tabular figures): dates, counts,
  language tags, pagination position.

### Named Rules
**The Chrome-Only Rule.** Archivo Narrow never sets content. If a face has to carry a sentence,
it is a text face.
**The Short Labels Rule.** Capital, tracked labels are for two-to-three-word apparatus strings.
Anything that reads as a sentence is set in text, sentence case.

## Layout

A single **sheet**: `max-width: 1220px`, centred, with `clamp(1rem, 3vw, 2rem)` side padding.
On the sheet: a **header** — the masthead band itself, sticky at the top of the sheet on every
page (masthead or part title at the near edge, controls right-aligned in the fixed order profile
links → language switch → dark-mode dial, 2px rule below) — then the page content, then the
**colophon**. There is no separate running head: the title page's masthead row *is* the header.
`--header-h: 64px` is the floor the band must clear, never its height; the band publishes its
measured height as `--band-h` and everything that sticks below it offsets from that. No template
from hugo-paper renders; `layouts/_default/baseof.html` is the shell.

- **Title page and technique pages** use a two-column **spread**: a 264px **index rail** on the
  left (techniques counted, then the year spine, then the author plate), sticky from 1000px up;
  the **contents ledger** on the right, grouped by a **year spine** (`6.2rem` folio column +
  titles). Every row is the same: date column plus one title, whether or not the record is
  paired.
- **Record pages** set one text block, `max-width: 57ch`, centred between the sheet margins.
  The edition switch and the earlier/later pair print inside the same measure.
- **Rhythm is one scale.** `--g-1 … --g-5` (0.5 / 1 / 1.5 / 2.5 / 4rem), plus `--head-room:
  2.75rem` above a heading, `--head-room-after: 0.85rem` below it, `--row-gap: 1.9rem` between
  ledger rows, `--block-gap: 2.25rem` between article blocks. More space above a heading than
  below it, everywhere, always.
- **Responsive:** at 1000px the index plan stops being a column and travels with the ledger as a
  sticky bar above it; at 720px rows collapse to one column, and the header band stacks into one
  column without losing the control order. No control is ever hidden behind a menu.

## Elevation & Depth

No shadows anywhere. Depth is printed: hairline rules to separate, weight-2 rules to open a
section, `--paper-pressed` tints for state, and one genuinely dark surface — the code plate —
which is the only place the edition shows a second ground. A row that is "on" is marked by the
reserved ink and a solid rule, not by a lift.

**The Flat-By-Default Rule.** Nothing on this site is raised. If you want a surface to feel
active, give it a rule and the reserved ink.

## Shapes

Square corners throughout (`border-radius: 0`); borders are 1px hairlines, section openers are
2px rules. The only clipping is `clip-path: inset(0)` on the portrait (a printed photo, not a
circle) and `clip-path: inset(50%)` for visually-hidden text. Geometry is typographic: a `1px`
em-rule under each year marker, a drawn dial for the
dark-mode control, drawn glyphs from one icon set for the profile links on the title page.

## Components

### Header (the masthead band)
- **Style:** full sheet width, 2px ink rule below, sticky at top 0 on every page. Its height is its own content: masthead scale on the title page, Part Title scale on a section or technique page, Part Title scale with a `Record` part label on a record page. Below 1000px it stacks into one column, control order preserved.
- **Content:** the masthead or part title at the near edge; profile links → language switch → dark-mode dial at the far edge, labelled on the title page and plain on inner pages.

### Language switch
- **Style:** outlined rectangle, no radius, `0.25rem 0.4rem` padding, 1px `--rule-2` border, Technical Blue text, `hreflang` and the destination language named in the accessible name.
- **Hover / Focus:** border takes the blue, fill takes `--paper-pressed`.
- **Rule:** renders only where a translation twin exists. An Untranslated post shows no switch and no apology.

### Dark-mode dial
- **Style:** a 22px drawn control, not an emoji or a stock glyph. Day prints the left half inked; night prints it as a crescent. One step, no cross-fade.
- **Hover:** the reserved ink.

### Ledger row (contents)
- **Style:** folio date in the 6.2rem column (tabular figures), title at 1.3rem, tag list beneath in Muted Ink at 0.76rem in the tags' own spelling. 1px bottom rule; `:last-child` has none.
- **State:** hovering a row turns its title blue; the tag list stays quiet.
- **One title per row:** `6.2rem 1fr`, identical whether or not the record is a Translation pair. Nothing in a row names, marks or links the other language; the twin is reached from the record itself.

### Edition switch (signature component)
- **Where:** the end of a record that exists in both languages — and nowhere else on the site, not even the ledger.
- **Style:** a 2px rule, then one right-aligned control — an apparatus label naming the act (`Read this record in` / `以该语言阅读这条记录`) beside the destination language in an outlined box. Never two columns holding the same record twice.
- **The authored interaction:** on hover or keyboard focus the switch box takes the blue border and `--paper-pressed` fill and its label takes the reserved ink (120ms, `cubic-bezier(0.2, 0, 0.2, 1)`). Reduced-motion gets the same end states with no movement. This is the only authored interaction on a record page; the ledger has none.

### Index rail
- **Style:** sticky 264px column: techniques (counted entries; a technique with one record is set as a plain name in the tail line), the year spine, the author plate (64px portrait, name, bio, profile links).
- **Isolate-and-dim:** on a technique page the current entry is solid and marked in the reserved ink; every other entry stays present and legible, dimmed to Muted Ink. Nothing is removed.

### Page turns
- **Style:** a 1px top rule across the sheet, position (`Page 2 / 5`) in tabular figures at one end, named turns (`← 上一页`, `下一页 →`) at the other. No arrows without names, no pills.

### Record neighbours
- **Style:** two labelled halves, "Earlier record" and "Later record", each naming the title it leads to. Never an anonymous back-to-list arrow.

### Code plate
- **Style:** `--plate` ground, chalk text, 1px rules top and bottom, `1rem 1.15rem` padding, 0.9rem mono, horizontal scroll inside the plate. Applies to fenced *and* indented blocks, so a wide ASCII diagram scrolls inside its plate instead of widening the page.

### Tables
- **Style:** header row in the label voice with an ink rule, body rows banded with `--paper-pressed` at 65%.

## Do's and Don'ts

### Do:
- **Do** change a token in `assets/custom.css` rather than a selector in a template. Every
  measure, colour, rule and motion in the site comes from that one file.
- **Do** name every state in words: `Untranslated post`, `Page 2 / 5`,
  `← 上一页`. Colour is never the only signal.
- **Do** keep the header contract: profile links → language switch → dark-mode dial in the header
  band, with the script that wires the dial after them, at every width, and the band's measured
  height published as `--band-h` so the sticky index rail and the year anchors sit below it.
- **Do** resolve tag and feed links with `absLangURL`, so a Chinese reader stays under `/zh/`.
- **Do** put more space above a heading (`--head-room`) than below it (`--head-room-after`).
- **Do** keep secondary chrome text above 4.5:1 — `--ink-3` is #5f666c (5.25:1 on paper) for a
  reason.

### Don't:
- **Don't** card anything. No rounded panels, no borders on all four sides, no shadows.
- **Don't** use the reserved brick for anything but the record or technique the reader is on.
- **Don't** gradient anything, and no violet/indigo identity, no glass, no aurora.
- **Don't** set content in the display face, and don't set a sentence in tracked capitals.
- **Don't** animate on scroll for its own sake. The ledger does not fade itself in; its dates and
  titles hold full contrast at every scroll position.
- **Don't** invent evidence: no testimonial, no count, no badge that the author has not written.
- **Don't** hide a control behind a menu on a phone.
