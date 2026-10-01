---
title: "i18n 冒烟测试（测试夹具，可删除）"
description: "scripts/i18n-smoke.sh 使用的夹具。它是草稿（draft），不会出现在生成的站点里。"
date: 2026-03-01T00:00:00
translationKey: i18n-smoke-test
tags: ["冒烟测试"]
draft: true
---

这个页面只用于验证三件事：配对的英文文章能链接到中文文章、没有翻译的英文文章不显示语言切换、
以及中文文章的标签指向 `/zh/tags/…`。

删除它时，请一并删除它的 `.md` 英文原件和 `.github/workflows/deploy.yml` 里的 `i18n smoke check` 步骤。
