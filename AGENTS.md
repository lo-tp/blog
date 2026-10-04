# AGENTS.md

A Hugo blog: English at `/`, Simplified Chinese under `/zh/`. One stylesheet, no theme
templates rendered.

## The dev server is the author's

**The author runs `./hugo server`. Start, stop, restart or kill one at your peril: if a dev
server is already running, it is his — leave it alone.** Check before acting:

```sh
pgrep -fl "hugo server"
```

If one is running, read the rendered page from its own port (`curl http://127.0.0.1:1313/…`) or
build to a throwaway directory (`hugo --gc --destination /tmp/build`) instead of touching it. If
none is running and you need one, start it, use it, and stop only the process you started:

```sh
hugo server -b http://127.0.0.1:1313 --port 1313 --bind 127.0.0.1 >/tmp/hugo.log 2>&1 &
# … measure …
kill <pid you started>     # never pkill -f "hugo server": it kills his too
```

He will say when he wants one started or stopped.

## Read before editing

| Owns | File |
| --- | --- |
| Vocabulary (Original, Translation pair, Untranslated post, drift, orphan) | `CONTEXT.md` |
| Design system, components, the header contract | `DESIGN.md` |
| Product purpose, non-goals, hard requirements | `PRODUCT.md` |
| Architecture decisions | `docs/adr/` |
| Bilingual wiring, the templates' ownership map, what breaks silently | `docs/zh.md` |

`docs/zh.md` is the closest thing to a checklist: since the check scripts were removed, **nothing
in this repo verifies a change** — no build check, no pairing report, no render measurement. When
you finish, say which failure modes you checked by reading the output, and which you did not.

## Rules that are load-bearing

- **`assets/custom.css` is the only stylesheet.** Change a token there, never a selector in a
  template. It is the single source for colour, measure, spacing rhythm, state and motion.
- **The header is the masthead band** (`layouts/partials/header.html`), sticky on every page.
  Its control order — profile links → language switch → dark-mode dial → the script that wires
  the dial — and the script's position *after* the controls it wires are a contract. It measures
  itself into `--band-h`; the sticky index rail and `#y####` anchors offset from that.
  `--header-h` is a floor, never a height.
- **One edition at a time.** A page shows one language. A record's twin is reached through the
  edition switch at the end of the record and nowhere else; a ledger row prints one title, with
  nothing from the other language in it. A page is headed once, by the header band.
- **`translationKey` must be on both files** or the switch works one way — and that builds clean.
- **In a content template (`single.html`) nothing may render outside the `define` blocks** — a
  plain HTML comment there drops every post page silently, zero errors. Use a Hugo comment
  `{{- /* … */ -}}`.
- **Article text is never generated.** Tooling scaffolds files; the author writes and translates.
- **No commit, no deploy, no `git` history rewriting unless asked.** `deploy.sh` is the author's.
- **Never load the `impeccable` skill unless `/skill:impeccable` is invoked explicitly.** Design
  work here goes through `DESIGN.md`.

## The preview trap (it has burned measurements before)

`hugo.toml` sets `baseURL = "https://blog.lotp.xyz/"`, so every asset URL in a plain build is
absolute and cross-origin. A page served that way renders with **no CSS** in a headless browser —
which looks like "my change had no effect" when it means "the stylesheet was blocked". Serve or
build with a local override:

```sh
hugo server -b http://127.0.0.1:1313 --port 1313 --bind 127.0.0.1
hugo --gc --destination /tmp/build -b http://127.0.0.1:8090/
```

Before trusting any rendered number, assert a stylesheet actually loaded
(`document.styleSheets.length > 0`) and that the display face resolved.
