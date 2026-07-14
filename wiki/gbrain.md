---
title: "GBrain"
type: entity
domain: ai
tags: [knowledge-management, synthesis, agent-memory, llm-wiki]
sources: []
reliability: high
created: 2026-07-14
updated: 2026-07-14
---

# GBrain

## 概述
GBrain 是 Y Combinator 总裁 Garry Tan 构建的生产级 AI 知识脑系统——"Search gives you raw pages. GBrain gives you the answer." 它以 146,646 页、24,585 人、5,339 公司、66 个 cron jobs 的规模自主运行，是 LLM Wiki 理念在生产环境中的最大规模实践之一。与 [[llm-wiki|LLM Wiki]] 的「编译一次、持续保持最新」理念一致，GBrain 增加了 synthesis layer、graph traversal、gap analysis 等企业级能力。

## 关键属性
- **Synthesis Layer**：不是返回检索片段，而是给出带引用的综合答案，并明确标注"脑还不知道什么"
- **Graph Traversal**：遍历实体间的知识图谱关系，发现深层连接
- **Gap Analysis**：主动暴露知识缺口，引导用户补充
- **Content-Quality Gate**：同步时自动检测并隔离垃圾内容
- **RBAC Company-Brain**：团队模式下每人有独立脑区，按登录隔离，fuzz-tested 零泄露
- **Cron 自动化**：66 个 cron jobs，夜间自动 enrichment、修复引用、整合记忆
- **版本**：v0.42.8.0（2026-06），289 commits

## 相关事件
- 2026-06 — v0.42.8.0 发布，新增 content-quality gate on sync
- Garry Tan 在 YC 的 Request for Startups 中提出 "company-brain" 概念，GBrain 是其参考实现

## 关联实体
- [[llm-wiki]] — LLM Wiki 概念的首倡者 Karpathy 模式，GBrain 是生产级实现
- [[rag-vs-llm-wiki]] — GBrain 代表了 synthesis 路线（与 RAG 检索路线对立）
- [[weknora]] — 腾讯的 RAG+Agent+Auto-Wiki 系统，与 GBrain 形成企业知识管理生态对比
- [[ragflow]] — infiniflow 的 deep document understanding RAG 系统

## 时间线

- 2026-07-14 | 首次 ingest 自 GitHub README（WebFetch 抓取），建立概述与关键属性
  （来源：https://github.com/garrytan/gbrain README）