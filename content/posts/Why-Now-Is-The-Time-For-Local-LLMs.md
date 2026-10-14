---
title: "Why now is the time for local LLMs"
description: "A 27B model on a consumer graphics card does the work I used to rent. Here is what I can prove from my own repos, what I'm borrowing from elsewhere, and what I'd still keep off this machine."
date: 2026-10-12T00:00:00
draft: true
tags: ["Local LLM", "LLM"]
---

Everything measured in this post was measured on 2026-10-12, on my machine, from my own repositories.
Everything not measured by me is linked and dated, and I say which is which as I go. Numbers age; treat
this one as dated rather than true forever.

The claim is narrow and it is this: **the gap between what a local model can do and what I actually ask
of one has closed enough that renting intelligence is now the more expensive and less reliable option for
my own work.** Not for frontier research, not for anything that serves other people over the public
internet. For the work I do in my own repositories, on my own schedule.

## What this model built

Not a toy. Three repositories, all public, all mine:

- [`learn-anything-backend`](https://github.com/lo-tp/learn-anything-backend) — a FastAPI application:
  **125 Python files, 15,523 lines, 34 test files, 138 commits between 2026-09-08 and 2026-10-11**, four
  graph modules (`clarify`, `plan`, `material`, `probe`), a slides router, Alembic migrations, and a
  deploy pipeline where `main` is checked with `ruff`, `pyright` and `pytest` and merging into `release`
  is the act that ships.
- [`learn-anything-infra`](https://github.com/lo-tp/learn-anything-infra) — the same product's
  Kubernetes environment as code: **40 Terraform and Kustomize files, 67 commits in four days
  (2026-10-07 → 2026-10-10), seven architecture decision records.**
- [`learn-anything-frontend`](https://github.com/lo-tp/learn-anything-frontend) — the app the browser
  talks to, which also carries every issue (including the backend's), the domain glossary and the ADRs.

I got those numbers with `git log` and `find | wc -l` today, so you can get them too.

Most of that was written by a model running on the machine in the next room, under my review. Two builds
of it: **Qwen3.8-27B** and a quantised build of the same weights served as
**`qwen3.8-flash-next-iq3_s`**. The prompts that steer the product live in a private submodule and are
never published; the code, the history and the issues are.

That is the whole argument, and the rest of this post is evidence and caveats.

## Then and now

I have been running local models on real projects for years, and for a long time it was not worth the
trouble. The clearest example I can give is one exact model:
**`Qwen/Qwen2.5-Coder-14B-Instruct-GPTQ-Int4`**, a 14B coder model, 4-bit, in a context window it could
barely fill.

I asked it to find and fix a CSS bug in a product I worked on at a previous company. I can't name that
codebase, so take it on trust that it was a real one — a real stylesheet, real selectors, a bug only
visible in one layout state. It found *a* rule, changed it, and the change broke another rule. That was
the loop: it could edit CSS, it could not hold the consequences of the edit. I was the debugger, every
time, and being the debugger of a model's edits is more tiring than doing the edit.

The same category of task today, in a codebase the size of the one above: the model reads a router,
follows the migration convention, notices that the repository's own instructions say never to commit
directly to `release`, and comes back with a change that passes `ruff`, `pyright` and the tests. I still
review every line — that isn't changing — but I am reviewing a diff instead of supervising a beginner.

What changed is not magic and it isn't only parameter count. It's that these models now hold a long task
in mind, they follow a prompt that contains several constraints at once, and they produce structured
output the first time instead of on the third try.

## The box

```
$ curl -s http://192.168.200.54:1919/v1/models
{"object":"list","data":[{"id":"qwen3.8-flash-next-iq3_s","object":"model",
  "status":{"value":"loaded"},"meta":{"n_ctx":262144},
  "architecture":{"input_modalities":["text","image"],"output_modalities":["text"]}}]}

$ curl -s http://192.168.200.54:1919/metrics | head -c 400
{"engine":{"model":"qwen3.8-flash-next-iq3_s","max_context":262144,"images":true,
  "version":"0.1.38","context":262144,"kv":"int8","kv_resident":32768,
  "expert_slots":4416,"expert_cache_mib":8626,"mtp_max":4,"lookup":3,
  "vram_free_mib":431,"arena_mib":47962,"pool_workers":11, …
```

The hardware is a **desktop PC: an NVIDIA RTX 4080 Super (16 GB), an Intel i3-13500, 128 GB of system
RAM.** A consumer card you can buy at a shop, and a CPU that is deliberately unremarkable.

Read the metrics and the claim becomes concrete. **262,144 tokens of context, served on a 16 GB card**,
with the model's experts cached in system RAM (8.6 GiB) rather than in VRAM, the KV cache at int8, and
multi-token prediction doing speculative decoding (4 tokens at a time). It fits because 16 GB of VRAM is
not the whole machine: **47.9 GiB of arena sits in the RAM**, and the 128 GB is not overkill — it is how
a 27B model ends up with a quarter of a million tokens of context. When I looked, **431 MiB of VRAM was
left over**, which is the honest way to say "this is full and it works".

The file it serves is `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, aliased `qwen3.8-flash-next-iq3_s`. One
warning from my own setup, since it is the kind of thing that only bites when it is yours: the `.env` of
the app still names a stale alias, `…iq3_xxs`, while the server answers to `…iq3_s`. A reader who copies
my config gets a "model not found". Pin the weights and you also get to keep the typo.

## What it takes to switch an app onto it

This is the part that used to be a project and is now a configuration change. From the backend:

```python
llm = ChatOpenAI(
    api_key=_api_key,
    base_url=os.getenv("OPENAI_BASE_URL"),
    model=os.getenv("LLM_MODEL", "gpt-4o-mini"),
    max_tokens=65536,
)
```

Three environment values: a base URL, a model name, a key. Moving the app from a hosted API to a LAN
address was an edit to `.env` and a restart. Nothing else in the application knows or cares which model
answered. The same flag that lets the acceptance walk run against a mock with `MOCK_LLM=1` means the test
suite spends nothing at all — which is worth more than it sounds when inference is on the other side of a
network you don't control.

That is the "operational cost" half of the argument. It is not clever. It is ordinary, and ordinary is
what makes the timing.

## The other thing it makes

The same box generates the teaching material: the `material` graph plans a sequence of slides for one
step of a learning path, then writes the deck. Its system prompt (private) asks for a specific pedagogy —
state the unconditional truths first, motivate every result so nothing appears from nowhere, make the
connections to earlier steps explicit, and aim for the moment where a pile of lonely facts collapses into
a few connected ideas.

That is a long instruction with several constraints in it, and the decks come out following it. A model
that cannot follow a prompt like that is not much use for teaching. The output is the proof; you can open
it at [learn.lotp.xyz](https://learn.lotp.xyz) rather than take my word for it. (Not the npm package
`learn-anything-cli` — a different project, same name, and I'll keep having to say that.)

## Model vs model

I did not benchmark this machine, and I won't pretend otherwise. What I can do is put three rows next to
each other and let the gap speak.

| | What it is | Agentic coding | Caveat |
|---|---|---|---|
| The published card | Qwen3.8-27B, released 2026-08-14, Apache 2.0, 262K native context (1M with YaRN) | **86.0 % SWE-bench Verified · 61.7 % SWE-bench Pro · 73.0 Terminal-Bench 2.1** | as reported by a third party mirroring [the model card](https://huggingface.co/Qwen/Qwen3.8-27B), which publishes these as images — so treat it as reported, not as transcribed by me ([mirror](https://qubrid.com/blog/qwen38-27b-benchmarks-official-and-independent-results), accessed 2026-10-12) |
| Someone else's consumer card | same weights, RTX 5090, quantised, the official SWE-bench harness, single attempt | **66.2 % (331/500)**, run 2026-08-21/22 | local and quantised: about twenty points below the hosted claim ([results](https://github.com/adrienbrault/qwen3.8-27b-rtx5090/blob/main/bench/results/agentic-benchmarks-qwen38.md), accessed 2026-10-12) |
| My box | `qwen3.8-flash-next-iq3_s` from `Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, RTX 4080 Super | not benchmarked | it runs my applications; I measured what I use, not a score |

The middle row is the one worth reading. Sixty-six percent on a consumer card is *worse* than the
headline, and it is still enough to build the codebase in the first section — which is the actual
relationship between a benchmark and my work. Nobody should have to reach 86 % to ship software.

## What only local gives you

Three things, named precisely, because "it's private and reliable" is a slogan and slogans are not
evidence.

**Model churn.** A hosted model gets deprecated, renamed or swapped under you. My prompts and my tests are
tuned against behaviour that can be withdrawn by someone else's release note. My model is a file. It does
not move. If I want it to change, I change the file, and the change is in a commit.

**Silent quality drift.** The harder version of the same thing: the name stays, the behaviour shifts, and
there is nothing to diff. Locally, drift is impossible by construction — same weights, same quantisation,
same server version — which also means the failure mode moves to my side: I upgrade when I choose to, and
I get to notice.

**Rationing.** Rate limits, thinking tokens counted against your budget, truncation under load,
degraded tiers. You can be rationed out of capability you were paying for without being told. The machine
in the next room has no one to ration it.

The incident that settled this for me was not a benchmark. I was fixing an urgent bug with a paid coding
agent — I won't name it, because plans and limits change and the story doesn't depend on which one — and
mid-task it simply stopped: quota. Not a failure to reason about, a commercial ceiling arriving in the
middle of a problem I was holding in my head. Nothing on my own network can do that to me.

**Privacy, the version that actually happened.** In September, Z.ai **disabled features of its ZCode
coding assistant after users noticed that the default Codebase Indexing tool had uploaded entire local
repositories** to a cloud service they had not authorised ([Reuters, 2026-09-21](https://www.reuters.com/legal/litigation/chinas-zai-disables-ai-coding-assistant-features-after-security-issue-2026-09-21/)).
That is my entire argument, told by someone else: an indexer moved whole repositories off a machine by
default, the users found out afterwards, and the vendor's remedy was to switch features off.

The controls exist, and they are yours to remember. On the paid API tier the major providers say they do
not train on your content; on consumer plans that can be on by default, with a setting to turn it off —
for Anthropic, "Allow model training" under account data-privacy controls, and their own
[retention documentation](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention)
(accessed 2026-10-12) states that zero data retention **does not cover consumer plans, including their
coding agent on those plans**, and that local agent session transcripts are kept for **six years** by
default. I read that page and then thought about my own session logs, which is a feeling I do not get
when the model is on my own LAN. Inference on this box has one route off the machine, and I configured
it; if I turn it off, there is no upload to authorise, retroactively, by anyone.

## What I would not run here

Keep these in the same post as the arguments above, because they are not marketing and I'd rather be
wrong in public than smooth.

**Long-horizon agent work.** While writing this, an agent doing research for me sat on a single tool call
for twenty-one minutes before I interrupted it. It had not crashed; it was stuck, and I was not watching.
Frontier models fail less often in that specific way, and "less often" is a real difference when the work
is unattended.

**More than one user.** `total_slots: 1`. This is a single-user machine by configuration, and it is fine
that way. Anything that must serve other people from a cloud VPC has a different shape of problem — and a
model on your LAN is not reachable from a cloud VPC at all, which is the first thing you find out when
you try to make a local model back a deployed app.

**The far end of capability.** Long-horizon reasoning, deep multi-file architecture work, anything where
I want a second opinion from something smarter than everything I own. Those I still rent, and I'm not
going to pretend a 16 GB card is a substitute for them.

## What would change my mind

If the models I use stopped holding a long task — if I went back to being the debugger of every edit —
the argument would end. It hasn't. What changed over the last year is not that local models got close to
the frontier; they didn't. It's that "close enough for the software I actually build" arrived on hardware
that is already sitting under my desk, and that talking to it is now three environment variables.

If you're reading this years later, that last sentence is the one that will have rotted. That's fine —
it was dated on purpose.

<!-- DRAFT NOTE: this article was drafted by the agent running on that box at the author's request, and
edited by the author before publishing. Delete this note, or keep it: PRODUCT.md says no article body is
produced automatically, so this post is a deliberate exception and the note is what keeps the claim true. -->
