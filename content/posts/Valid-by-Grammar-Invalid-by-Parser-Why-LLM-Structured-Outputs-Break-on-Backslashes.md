---
title: "Valid by Grammar, Invalid by Parser: Why LLM Structured Outputs Break on Backslashes"
description: "I lost a whole batch of generated work to one character, and the fix was not a better prompt: strict mode off, and the schema and type checking done by hand. The quieter half of this bug is worse than the 502 — nothing fails, and a macro is stored as a form feed."
date: 2026-10-15T00:00:00
draft: false
tags: ["LLM"]
translationKey: Valid-by-Grammar-Invalid-by-Parser-Why-LLM-Structured-Outputs-Break-on-Backslashes
---

**TLDR:** If you ask an LLM for structured JSON and you have met `502 structured_output_failed`, the culprit is
probably not your code. It is a single backslash: a lone `\` inside a JSON string that the server will
generate for you and then refuse to parse. The fix is not a tidier prompt: turn strict mode off and do
the schema and type checking yourself.

## The error

A pipeline that generates text with an LLM is usually a chain of calls, and most of them have to answer
in JSON we can parse — a list of what to write next, a list of items, a list of questions. The clean way
to ask for that is *structured output*: hand the model a JSON schema and let the server enforce it
(in LangGraph that is a `with_structured_output` call on the model; OpenAI-compatible servers take it as
`response_format: {"type": "json_schema", "strict": true}`). On a maths-heavy call, this is what came
back:

```
openai.InternalServerError: Error code: 502
{ "error": {
    "type": "structured_output_failed",
    "code": "structured_output_failed",
    "message": "model did not return valid JSON: Invalid \escape: line 20 column 48 (char 1595)"
}}
```

Nothing in my code caught that class of error, so it propagated as "this generation failed" — and the
unit that failed was not one field, it was a whole batch of work. The mechanism that makes this so
expensive is easy to miss and worth stating plainly: **the server had already generated the answer. The
refusal withholds it.** A refusal is not a partial result you can salvage; it is the completion, thrown
away.

## What I ruled out

My first guess was "the model writes bad JSON on a hard prompt." That was wrong, and the way it was
wrong is the useful part. I replayed the same call at `temperature=0` and changed one variable at a
time:

| request | result |
| --- | --- |
| today's path (`json_schema`), `max_tokens=8192` | **502 `Invalid \escape`** (positions vary: `line 9 col 28`, `line 20 col 48`) |
| today's path, `max_tokens=65536` | **502, same failure** — the output cap is not involved |
| no `response_format` at all | the completion contains **21–22 invalid escapes**; free-form output is just as bad, it simply is not validated server-side |
| those escapes doubled, then parsed and validated locally | ✅ parses; every item passes its schema |
| `method="json_mode"` | fails differently: the model echoed the *schema* instead of an instance |
| `method="function_calling"` | ✅ 2/2 runs ok, 13.4 s and 15.7 s |

- **The token cap was not the cause.** At default temperature the output length looked causal; at
  `temperature=0`, 8192 and 65536 failed identically at the same position. That was sampling variance
  masquerading as a cause.
- **The text was almost fine.** Doubling the backslashes and parsing locally was enough. Nothing was
  wrong with the *answer* — only with how the backslashes inside it were encoded.
- **The model was not bad at JSON.** `json_mode` failed in a different way (echoing the schema rather
  than producing an instance), and `function_calling` succeeded twice. The model was following
  instructions; the instructions and the transport disagreed.

## Why it happens: a grammar and a parser that disagree

**1. The transport.** `with_structured_output` defaults to `method="json_schema"`, so the call sends a
strict JSON schema. My server, llama.cpp, compiles that schema into a GBNF grammar, and here is the
trap: **the grammar enforces JSON *structure* but permits a lone backslash inside a string.** The grammar happily
generates the token — and then the server parses the completion itself, and a backslash before a letter
is not a legal JSON escape. So the server answers 502 about text it generated itself.

The general shape of the bug: **the thing that generated the text and the thing that validated it did
not agree.** "Valid by the grammar" is not "parsable by the parser."

**2. A prompt that mandates backslashes.** One of my system prompts says, in the outputs that must come
back as JSON: *"Use LaTeX for math."* That is where `\frac`, `\int`, `\left` and `\,` come from.

"LaTeX" is only the name this arrived under. A code sample containing `\n`, a regex with
`\d`, a Windows path — any of them hit the same wall.

## The failure mode that reports nothing

The same cause has a second symptom, and it is the worse one because it never fails.

Some backslash sequences *are* legal JSON escapes — and they decode into the wrong character. Verified
against `json.loads`:

| the model wrote | what is stored |
| --- | --- |
| `\frac{d}{dx}` | `U+000C` (form feed) + `rac{d}{dx}` |
| `\nu` | a newline |
| `\times` | a tab |

These pass every schema, so they reach the stored text as corruption that looks like a fragment of the
original. Nothing logs them. A call that ends on `finish_reason="length"` — the model spent its whole
output allowance and returned nothing useful — is unreported in the same way. **The 502 is the failure
you debug; the form feed is the failure you ship.**

## The fix: turn strict mode off and do the schema and type checking yourself

The fix in one line: when the server refuses, ask the same question **with strict mode off** and do the
schema and type checking by hand. It does not ask the model to write tidier JSON, and it does not ban
LaTeX. Strict mode stays for the calls that pass — the fallback is only paid when the strict path fails.

1. **Recognise the refusal.** A 5xx whose body says `structured_output_failed` / "model did not return
   valid JSON" is a known shape, so treat it as one.
2. **Re-ask with strict mode off.** Same messages, same reasoning budget, same output allowance — only
   the enforcement removed. Nothing new is invented.
3. **Repair the escapes in one pass.** Double every backslash that is not already part of a legal escape
   pair; leave `\n`, `\t`, `\r`, `\uXXXX`, `\"`, `\\`, `\/` alone. One judgement call: treat `\f` and
   `\b` as the start of a macro rather than as form-feed and backspace, because in this corpus they are
   overwhelmingly `\frac`, `\beta` and `\bar`. A repair rule has to know what the text is *about*.
4. **Do the schema and type checking by hand.** Validate the parsed answer against the same schema the
   server would have enforced — same acceptance bar, just held locally instead of delegated.

## What I learned

- **Don't name the bug after the content that tripped it.** "It broke on LaTeX" kept me reading prompts
  for an hour. "It breaks on a lone backslash inside a JSON string" pointed straight at the transport.
- **"Valid by the grammar" is not "parsable by the parser."** When a constrained-output call fails,
  check whether the generator and the validator agree — the gap between them is where this class lives.

