---
title: "一个反斜杠导致结构化输出失败：LLM 生成 JSON 时最隐蔽的坑"
description: "一个反斜杠让我整批生成好的东西全没了。修复跟把 prompt 写得更规矩没关系：把 strict mode 关掉，schema 和类型检查自己做。更麻烦的是这 bug 安静的那半——什么都不报错，宏被存成了一个换页符。"
date: 2026-10-15T00:00:00
draft: false
tags: ["LLM"]
translationKey: Valid-by-Grammar-Invalid-by-Parser-Why-LLM-Structured-Outputs-Break-on-Backslashes
---

**太长不读:** 如果你让 LLM 输出结构化 JSON，遇到报错 `502 structured_output_failed`，元凶多半不在你的代码里。而是一个反斜杠：JSON 字符串里孤零零的一个 `\`——服务器自己把它生成出来，却无法解析它。修复也不是把改写 prompt 而是：关掉 strict mode，schema 和类型检查自己做。

## 报错

一个用 LLM 生成文本的流程通常就是一串调用，其中大多数Response都是JSON。要 JSON Response 的最通用的做法就是*结构化输出*（structured output）：把一份 JSON schema 交给模型，让服务器去生成 Response 并根据 JSON Schema校验（在 LangGraph 里就是对模型调一次 `with_structured_output`；OpenAI 兼容的服务器收到的就是 `response_format: {"type": "json_schema", "strict": true}`）。有一次调用时牵扯到很多数学公式公式，导致了如下的报错：

```
openai.InternalServerError: Error code: 502
{ "error": {
    "type": "structured_output_failed",
    "code": "structured_output_failed",
    "message": "model did not return valid JSON: Invalid \escape: line 20 column 48 (char 1595)"
}}
```

我的代码里没有任何地方处理这类报错，于是它一路往上冒，导致整个 workflow 都挂掉。耐人寻味的是：**服务器其实已经把 Response 生成出来了，只是这个 Response 通过不过校验**。

## Debug

我最初的猜测是「这个 prompt 太难，模型写出了不合格的 JSON」。于是我把同一个调用在 `temperature=0` 下重放，一次只改一个变量：

| 请求 | 结果 |
| --- | --- |
| （`json_schema`），`max_tokens=8192` | **502 `Invalid \escape`**（报错位置会变：`line 9 col 28`、`line 20 col 48`） |
| `max_tokens=65536` | **502，同一个错**——跟输出上限没关系 |
| 完全不带 `response_format` | 生成结果里有 **21–22 处非法转义**；自由格式的输出一样糟，只是服务器不做校验 |
| 把这些反斜杠翻倍，然后在本地解析、本地校验 | ✅ 能解析；每一条都过 schema |
| `method="json_mode"` | 换一种方式失败：模型把 *schema* 原样抄了一遍，没有产出实例 |
| `method="function_calling"` | ✅ 两次都成功 |

- **输出上限不是原因。** 默认 temperature 下，输出长度看着就是原因；把 `temperature=0` 固定住之后，8192 和 65536 在同一个位置、以同样的方式失败。
- **模型写出来的东西基本是对的。** 把反斜杠翻倍、然后在本地解析就不报错了。*Response*本身没有任何问题——错的只是它里面那些反斜杠的编码方式。
- **模型并不是不会写 JSON**。模型一直在照着指令做；是 grammar 和 parser 冲突了。

## 为什么：grammar 和 parser 会冲突

**1. ** `with_structured_output` 默认走 `method="json_schema"`，所以每次调用参照 JSON schema 校验 Response。服务器 把 schema 编译成一个 GBNF grammar，坑就在这儿：**grammar 管的是 JSON 的*结构*，它不 Care 字符串里一个孤立的反斜杠。** grammar 高高兴兴把这个 token 生成了出来——然后服务器自己去解析，而一个字母前面的反斜杠并不是合法的 JSON 转义。于是服务器因为它自己生成的文本返回了一个 502。

这个 bug 的一般形状：**生成文本的那一方和校验文本的那一方没有达成一致。**「grammar 里合法」不等于「parser 解析得了」。

**2. 我的一个 system prompt** 在一次 结构调用中写着：*“Use LaTeX for math.”* `\frac`、`\int`、`\left`、`\,` 就是从这儿来的。

「LaTeX」只是导火索。一段含 `\n` 的代码示例、一个带 `\d` 的正则、一个 Windows 路径—-都会引发同样的错误。

## 更隐蔽的问题

有些反斜杠序列*是*合法的 JSON 转义——它们会解码成错误的字符。对着 `json.loads` 验过：

| 模型写的 | 存下来的是 |
| --- | --- |
| `\frac{d}{dx}` | `U+000C`（换页符）+ `rac{d}{dx}` |
| `\nu` | 一个换行 |
| `\times` | 一个制表符 |

它们全都能过 schema，会被以「看起来像原文剩下来的一截」的样子进了存下来的文本。渲染结果异常的。

## 修复：关掉 strict mode，schema 和类型检查自己做

一句话说清修复：检测服务器 502 错误，把同一个问题再问一遍，**但不开 strict mode**，schema 和类型检查自己动手做。不需要模型把 JSON 写得更规矩，也不用禁掉 LaTeX。能过的调用照旧走 strict——fallback 只在 strict 这条路失败的时候才使用。

1. **识别异常原因。** body 里写着 `structured_output_failed` / “model did not return valid JSON”。
2. **关掉 strict mode 再问一遍。** 同样的消息、同样的 reasoning 预算、同样的输出额度——只把强制类型检查取消。
3. **一遍把所有转义修好。** 凡不属于合法转义对的反斜杠，统统翻倍；`\n`、`\t`、`\r`、`\uXXXX`、`\"`、`\\`、`\/` 原样不动。
4. **schema 和类型检查自己动手。** 替服务器在本地做类型校验。

## 我学到了什么

- **别被错误引发的导火索迷了眼睛。** 「 LaTeX 引发的错误」让我花了一小时去读 prompt；实际上 LaTex 只是导火索，根结在反斜杠。
- **「grammar 里合法」不等于「parser 解析得了」。** 一个结构化调用失败时，去检查生成方和校验方是否有冲突。
