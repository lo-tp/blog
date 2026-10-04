---
translationKey: I-Let-My-Coding-Agent-Manage-My-Notion-Tasks
title: "我让 Coding Agent 帮我管 Notion 任务，学到了什么"
description: "我给 Coding Agent 配了个 CLI 去管我的 Notion 任务。结论是：确定性的活交给脚本，要拿主意的活交给 prompt。"
date: 2026-09-30T00:00:00
images:
  - "/images/notion-agent-cover.jpg"
tags: ["Coding Agent", "Notion", "Skill", "LLM"]
---

<img src="/images/demo-video/demo.gif" alt="notion-todo demo" width="720" />

## 问题

我的任务都放在 Notion 里。那算是我的第二个大脑——任务、项目、时间追踪，全都串在一起。可通过图形界面去折腾它……挺费劲。我得先打开 Notion，点来点去，找到对的数据库，再点开卡片改。往往正跟 Coding Agent 写代码写到一半，忽然想到该建一个后续任务，这一来一回的上下文切换*代价极大*。

我想要的其实很简单：**用人话跟Agent说，它替我把 Notion 里的任务管好。**「加个任务：修登录那个 bug，明天截止。」「今天我手上都有什么？」「给 auth refactor 开个计时。」说完就完事，不用碰界面。

## 架构

方案就是 [notion-todo](https://github.com/lo-tp/notion-todo)——一个给 Coding Agent 用的 skill，分三层：

1. **Notion** 是唯一的数据源头来源，也是给人看的界面，卡片本来就住在里面。
2. **本地一个 SQLite 镜像**存一份又快又能查的副本。代理读的是这个，不是 API。
3. **一个 CLI 脚本**（`notion_cards.py`）包掉所有写入操作——创建、修改、删除、时间追踪、评论。每写一次，镜像自动跟着同步。

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

## 第一个坎：我压根没写脚本

一开始我一个脚本都没写。只是把 Notion 数据库长什么样讲给代理听，告诉它「Notion API 是这样用的，你去建一张卡」。于是每一次它都得自己去搞 HTTP 请求、拼 JSON payload、处理 relation，还得顾上镜像同步——全靠自己。

这一版凑合着用也还行，但失败率太高了：漏掉一个 property、拿错 database ID、拼出一个不对的 relation、忘了同步镜像。每个错都意味着重试，重试就是更多 token、更久的等待、更多连锁出错的机会。这就像把一件复杂的工具扔给别人却不给说明书——他*能*用，但一定手忙脚乱。

**事后回头看，办法简单得很：把确定性的那部分写成脚本。**

于是我编写了一个 CLI（`notion_cards.py`），CRUD、时间追踪、评论、同步全归它管。代理不用再知道 Notion 的 API 是怎么工作的了，它只要跑：

```bash
bash scripts/run.sh notion_cards create "Fix login bug" --status "Today" --priority 5
```

成功率从「看运气」变成「基本不会错」。代理的活儿也回到了它真正擅长的地方：听懂人话，决定该跑*哪一条*命令。

### 原则：确定性的交给脚本，要判断的交给 prompt

| **写成脚本** | **交给 prompt** |
|---|---|
| CRUD 操作 | 理解自然语言 |
| 同步逻辑 | 搞懂含糊的指代 |
| 时间追踪的状态 | 决定跑哪个查询 |
| 文件 I/O、schema 迁移 | 判断什么时候该确认、什么时候直接动手 |

skill 文件就是你的 prompt engineering，脚本就是你的确定性骨架。没有脚本，代理每次调用都在重新发明轮子，而且失败得非常频繁——频繁到让人对整个系统都失去信心。

## 第二个坎：去哪儿找项目根目录

我的项目里有 `.venv`、`mirror.sqlite` 和 `scripts/`，但代理不知道「项目根目录」在哪。它会在当前工作目录里找 `.venv`，找不到，就放弃了。解决办法是一个 `run.sh` 包装脚本，所有路径都按它自己所在的位置解析——代理只要跑 `bash <root>/scripts/run.sh notion_cards ...`，剩下的交给包装脚本。skill 文件里则告诉代理：「从当前目录一层层往上走，找到那个同时有 `pyproject.toml` 和 `.venv` 的目录，那就是根。」

## 如果你也想写一个自己的 skill

1. **你的 skill 文件就是 prompt**。它是写给代理看的，不是给人看的。所有变量、需要确认的地方、边界情况上都要说准。
2. **别让代理去做脚本能干的事**。一个操作是确定性的，就写成脚本。代理负责决定*做什么*，不负责*怎么做*。

## 结果

现在我用 Coding Agent 管我的任务，跟用它管我的代码是同一种方式。「开个计时。」「停。」「这周我在这上面花了多少时间？」它快，它靠得住，而我不用从自己的状态里出来。GUI 还在那儿，真需要的时候可以用——但我已经很少去点它了。

如果你也用 Coding Agent，任务又放在 Notion 里，[notion-todo](https://github.com/lo-tp/notion-todo) 是开源的，MIT 授权。上手大概一分钟：

```bash
npm install -g notion-todo
```

然后把 skill 链到你的代理：

| 代理 | 命令 |
|-------|---------|
| **Claude Code** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.claude/skills/notion-todo` |
| **Codex** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.codex/skills/notion-todo` |
| **Pi** | `pi install notion-todo` |
| **任何支持 Agent-Skills 的代理** | `ln -s "$(npm root -g)/notion-todo/skills/notion-todo" ~/.agents/skills/notion-todo` |
