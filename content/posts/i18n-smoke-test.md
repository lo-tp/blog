---
title: "i18n smoke test (test fixture — safe to delete)"
description: "Fixture for scripts/i18n-smoke.sh. It is a draft, so it is never published."
date: 2026-03-01T00:00:00
translationKey: i18n-smoke-test
tags: ["i18n-smoke-test"]
draft: true
---

This page exists only so `scripts/i18n-smoke.sh` can assert three things: a paired
English post links to its Chinese twin, an unpaired post shows no language switch, and a
Chinese post links to `/zh/tags/…` rather than the English tag pages.

If you delete it, delete its `.zh.md` twin and the `i18n smoke check` step in
`.github/workflows/deploy.yml` too.
