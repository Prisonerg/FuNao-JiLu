---
title: "RAG vs LLM Wiki"
type: summary
domain: ai
tags: [rag, llm-wiki, comparison, knowledge-management]
sources:
  - raw/karpathy-llm-wiki-gist.md
created: 2026-07-12
updated: 2026-07-12
reliability: high
---

# RAG vs LLM Wiki

## 背景

RAG（检索增强生成）与 LLM Wiki 是两种用 LLM 处理原始文档的个人知识管理范式。前者是当下主流（NotebookLM、ChatGPT 文件上传、大多数 RAG 系统均属此类），后者由 [[andrej-karpathy|Andrej Karpathy]] 在其 LLM Wiki gist 中提出（来源：raw/karpathy-llm-wiki-gist.md § The core idea）。本综述基于该单一原始源，系统对比两者，作为 [[llm-wiki]] 概念页的展开。因目前仅有一份原始源，本综述的论点全部来自该 gist。

## 关键论点

gist 对 RAG 的核心批评是「没有累积」：

> This works, but the LLM is rediscovering knowledge from scratch on every question. There's no accumulation. Ask a subtle question that requires synthesizing five documents, and the LLM has to find and piece together the relevant fragments every time. Nothing is built up.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

相对地，LLM Wiki 的关键主张是「知识编译一次、持续保持最新」，wiki 是一个持久的、可复利的产物：

> The wiki is a persistent, compounding artifact. The cross-references are already there. The contradictions have already been flagged. The synthesis already reflects everything you've read. The wiki keeps getting richer with every source you add and every question you ask.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

关于维护成本，gist 认为知识库维护的瓶颈在于记账而非阅读思考，LLM 恰好解决了这个问题：

> Humans abandon wikis because the maintenance burden grows faster than the value. LLMs don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass. The wiki stays maintained because the cost of maintenance is near zero.
> （来源：raw/karpathy-llm-wiki-gist.md § Why this works）

## 对比表

| 维度 | RAG | LLM Wiki |
| --- | --- | --- |
| 知识累积方式 | 不累积；每次查询从原始文档重新检索、重新拼装 | 增量累积；每次 ingest 把新信息整合进持久 wiki，知识编译一次、持续保持最新 |
| 产物形态 | 无持久产物；检索结果即时消费后消失 | 持久、互链、可复利的 Markdown wiki（实体页 / 概念页 / 综述页 + index.md + log.md） |
| 矛盾处理 | 通常不显式处理；不同文档的矛盾在每次生成的答案中临时体现 | 显式标注；新旧资料冲突用 callout 标记并保留旧结论，待裁定（见 AGENTS.md § 矛盾处理规则） |
| 维护成本 | 几乎无主动维护，但每次查询的检索 / 综合成本重复支付 | 主动维护成本由 LLM 承担、接近零；人只需 ingest 与提问 |
| 适用规模 | 天然适合大规模语料（向量检索随文档数扩展） | 中等规模内 index.md 即够用；gist 称约 100 个源、数百个页面内无需向量检索基础设施，更大规模需引入专门搜索引擎（如 qmd 的 BM25 / 向量混合检索）（来源：raw/karpathy-llm-wiki-gist.md § Indexing and logging、§ Optional: CLI tools） |

## 开放问题

- **规模边界**：gist 给出「约 100 个源、数百个页面」的经验范围，但未给出向 RAG / 检索方案切换的明确阈值，待后续 ingest 更多资料后厘清。
- **多源综合的忠实度**：LLM Wiki 在多源综合页中可能引入原文没有的合成结论，如何量化「生成效应」并靠引文回溯兜底，尚无定论。
- **与 RAG 的混合**：gist 在「Optional: CLI tools」中提到可给 wiki 配搜索引擎（如 qmd），这实质上是 LLM Wiki + 检索的混合；两者是否始终二选一、还是会在大规模下融合，gist 未明确。
- **跨会话一致性**：wiki 质量强依赖 LLM 严格遵循 schema，不同模型 / 会话执行一致性如何保证，需 lint 兜底但仍缺实证。

## 参考来源

- raw/karpathy-llm-wiki-gist.md（本综述核心原始源）
- 相关 wiki 页：[[llm-wiki]]、[[andrej-karpathy]]、[[second-brain]]（第二大脑视角：传统 PKM 的维护成本问题正是 LLM Wiki 用 LLM 补上的缺口）

## 时间线

- 2026-07-12 | 首次 ingest 自 raw/karpathy-llm-wiki-gist.md,建立 RAG vs LLM Wiki 系统对比
  （来源：raw/karpathy-llm-wiki-gist.md）
