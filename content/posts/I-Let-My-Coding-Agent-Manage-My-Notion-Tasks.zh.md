---
translationKey: I-Let-My-Coding-Agent-Manage-My-Notion-Tasks
title: "我让编程代理管理我的 Notion 任务，学到了什么"
description: "我给编程代理配了一个 CLI 来管理我的 Notion 任务。结论是：确定性的部分交给脚本，需要判断的部分交给 prompt。"
date: 2026-09-30T00:00:00
images:
  - "/images/notion-agent-cover.jpg"
tags: ["编程代理", "Notion", "Skill", "LLM"]
---

<img src="/images/demo-video/demo.gif" alt="notion-todo demo" width="720" />

## 问题

我用 Notion 管理任务。那是我的大脑——任务、项目、时间追踪，全都相互关联。但通过 GUI 和它交互……很费劲。我得打开 Notion，点来点去，找到对的数据库，编辑卡片。我正和编程代理写代码，忽然意识到要建一个后续任务，而这次上下文切换*代价极大*。

我想要的其实很简单：**用自然语言跟代理说话，它替我管理 Notion 任务。**「加一个任务：修复登录 bug，明天截止。」「今天我手上有什么？」「给 auth refactor 开计时。」结束。不用 GUI。

## 架构

方案是 [notion-todo](https://github.com/lo-tp/notion-todo)——一个编程代理的 skill，分三层：

1. **Notion** 是唯一的真相来源。是给人用的界面。卡片住在那里。
2. **一个本地 SQLite 镜像**保存一份快速、可查询的副本。代理读的是这个，不是 API。
3. **一个 CLI 脚本**（`notion_cards.py`）负责所有写入操作——创建、修改、删除、时间追踪、评论。每次写入都会自动同步镜像。

```
┌─────────────────────────────────────────────────────────────┐
│  User (natural language)                                     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Agent (LLM) — interprets intent, picks the right action    │
│  guided by SKILL.md (prompt)                                │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  CLI Script (deterministic) — notion_cards.py               │
│  handles CRUD, time tracking, comments, sync                │
└──────────┬──────────────────────────┬───────────────────────┘
           │                          │
           ▼                          ▼
┌──────────────────────┐    ┌──────────────────────────┐
│  Notion (source of   │◄──►│  SQLite Mirror (fast     │
│  truth, human UI)    │    │  reads, agent queries)   │
└──────────────────────┘    └──────────────────────────┘
```

## 第一个难点：我没有写脚本

**一开始我一个脚本都没写。**我只是把我的 Notion 数据库描述给代理，告诉它「Notion API 是这样的，去建一张卡。」代理每次都得自己搞定 HTTP 调用、拼 JSON payload、处理 relation、还要同步镜像。

它*差一点*就能用。但失败率很高。代理会漏掉一个 property、用错 database ID、拼出一个不合法的 relation、忘了同步镜像。每个错误都意味着重试，重试意味着更多 token、更高延迟、更多级联失败的可能。这就像把一件复杂的工具丢给某人却不给说明书——他*能*用，但一定会手忙脚乱。

**事后回看，解决办法很简单：给确定性的部分写脚本。**

我做了那个 CLI（`notion_cards.py`），它负责所有 CRUD、时间追踪、评论和同步。代理不再需要了解 Notion 的 API 怎么工作。它只需要运行：

```bash
bash scripts/run.sh notion_cards create "Fix login bug" --status "Today" --priority 5
```

成功率从「时好时坏」变成「稳定正确」。代理的活儿回到了它真正擅长的事：理解自然语言，决定要运行*哪条*命令。

### 原则：确定性交脚本，灵活性交 prompt

| **写成脚本** | **交给 prompt** |
|---|---|
| CRUD 操作 | 理解自然语言 |
| 同步逻辑 | 解析含糊的指代 |
| 时间追踪的状态 | 选择要跑哪个查询 |
| 文件 I/O、schema 迁移 | 决定什么时候确认、什么时候直接做 |

skill 文件就是你的 prompt engineering，脚本就是你的确定性骨架。没有脚本，代理每次调用都在重造轮子，而且失败得足够频繁，会让用户对整个系统失去信任。

## 第二个难点：找到项目根目录

我的项目里有 `.venv`、`mirror.sqlite` 和 `scripts/`，但代理不知道「项目根目录」在哪。它会在当前工作目录里找 `.venv`，找不到，然后放弃。解决办法是一个 `run.sh` 包装脚本，所有路径都相对它自己的文件位置解析——代理只要运行 `bash <root>/scripts/run.sh notion_cards ...`，剩下的交给包装脚本。skill 文件里告诉代理：「从 cwd 往上走，找到同时含有 `pyproject.toml` 和 `.venv` 的那个目录——那就是根。」

## 如果你也要写一个自己的 skill

1. **你的 skill 文件就是 prompt。**它为代理而写，不是为人而写。在不变量、需要确认的地方、边界情况上要精确。
2. **别让代理做脚本能做的事。**操作是确定性的，就写成脚本。代理的职责是决定*做什么*，不是*怎么做*。
3. **模糊匹配才是它用起来自然的原因。**让代理可以说「登录那个」，而不是要求精确的名字。一个 unique-substring 解析器只有 20 行 Python，价值千金。

## 结果

现在我的编程代理管理我的任务，和它管理我的代码是同一种方式。「开计时。」「停。」「这周我花了多少时间？」它快，它可靠，而我保持在心流里。GUI 还在那里，需要的时候可以用——但我很少再去碰它。

如果你用编程代理，而任务放在 Notion 里，[notion-todo](https://github.com/lo-tp/notion-todo) 是开源的、MIT 授权。上手大约一分钟：

```bash
npm install -g notion-todo
```

然后把 skill 链接到你的代理：

| 代理 | 命令 |
|-------|---------|
| **Claude Code** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.claude/skills/notion-todo` |
| **Codex** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.codex/skills/notion-todo` |
| **Pi** | `pi install notion-todo` |
| **任何支持 Agent-Skills 的代理** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.agents/skills/notion-todo` |
