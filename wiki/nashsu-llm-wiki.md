---
title: "nashsu/llm_wiki"
type: entity
domain: ai
tags: [llm-wiki, knowledge-management, knowledge-graph, community-detection]
sources:
  - raw/nashsu-llm-wiki-readme.md
reliability: high
created: 2026-07-14
updated: 2026-07-14
---

# nashsu/llm_wiki

## 概述
nashsu/llm_wiki 是 Karpathy LLM Wiki 理念的最完整独立实现——"A personal knowledge base that builds itself." 它在 Karpathy 原版三层架构（raw/wiki/schema）的基础上，增加了 Two-Step Chain-of-Thought Ingest、4-Signal 知识图谱、Louvain 社区发现、Graph Insights 等创新机制，将 LLM Wiki 从「LLM 维护的 Markdown 文件集合」升级为「带知识图谱和社区发现的智能知识系统」。682 commits，Rust 后端 + TypeScript 前端，支持 MCP Server、Browser Extension、Chat Agent。

## 关键属性
- **Two-Step Chain-of-Thought Ingest**：LLM 先分析源的结构/主题/实体，再生成 wiki 页，含增量缓存和源可追溯性
- **4-Signal Knowledge Graph**：直接链接（wikilink）+ 源重叠（共享 raw）+ Adamic-Adar（共同邻居）+ 类型亲和度（同 type 页更相关），四种信号加权计算页面相关性
- **Louvain Community Detection**：自动发现知识簇（cluster），带 cohesion scoring，与人工 MOC 互补
- **Graph Insights**：检测意外连接（跨域路径）和知识缺口（高频实体无独立页），支持一键 Deep Research
- **Multimodal Image Ingestion**：从 PDF 提取嵌入图片，用 vision LLM 生成事实性 caption，支持图片搜索和 lightbox 预览
- **Vector Semantic Search**：基于 LanceDB 的可选向量检索，支持任意 OpenAI 兼容端点
- **Persistent Ingest Queue**：串行处理 + 崩溃恢复 + 取消/重试 + 进度可视化
- **Source Folder Auto-Watch**：自动检测 raw/ 新增文件并触发 ingest
- **技术栈**：Rust 后端 + TypeScript 前端 + MCP Server + Browser Extension + Chat Agent

## 相关事件
- 2026-07-08 — 最新 commit，持续活跃开发中
- 682 commits，163 issues

## 关联实体
- [[andrej-karpathy]] — Karpathy 是 LLM Wiki 概念的首倡者，nashsu/llm_wiki 是其理念的独立实现
- [[llm-wiki]] — LLM Wiki 概念页，nashsu/llm_wiki 是该概念的最完整工程实现
- [[knowledge-graph]] — 知识图谱概念页，nashsu/llm_wiki 的 4-Signal KG 是核心创新
- [[community-detection]] — 社区发现概念页，nashsu/llm_wiki 的 Louvain 检测是核心创新

## 时间线

- 2026-07-14 | 首次 ingest 自 raw/nashsu-llm-wiki-readme.md，建立概述与关键属性
  （来源：raw/nashsu-llm-wiki-readme.md § Features）