---
title: "RAGFlow"
type: entity
domain: ai
tags: [rag, knowledge-management, document-understanding, agent]
sources: []
reliability: high
created: 2026-07-14
updated: 2026-07-14
---

# RAGFlow

## 概述
RAGFlow 是 infiniflow 开源的企业级 RAG 系统，核心特色是「deep document understanding」——不仅做 chunk-and-retrieve，而是对文档进行深度解析和理解后再检索。与 [[llm-wiki|LLM Wiki]] 的「编译一次、持续保持最新」不同，RAGFlow 坚守 RAG 路线，但在文档理解深度上做了大量工程优化，是 RAG 生态中规模最大的开源项目之一（7,355 commits）。

## 关键属性
- **Deep Document Understanding**：深度文档解析，超越简单的文本分块
- **Agent-Based RAG**：Agent 驱动的检索增强生成
- **知识库管理**：完整的数据集管理和文档生命周期
- **Docker 部署**：一键部署，支持 cloud 版本
- **版本**：v0.26.4（2026-07），7,355 commits

## 相关事件
- 2026-07-14 — 持续活跃开发中

## 关联实体
- [[weknora]] — 腾讯的 RAG+Agent+Auto-Wiki 系统，与 RAGFlow 同属 RAG 生态
- [[llm-wiki]] — LLM Wiki 概念，RAGFlow 代表了 RAG 路线的极致工程化
- [[rag-vs-llm-wiki]] — RAG vs LLM Wiki 对比，RAGFlow 是 RAG 列的代表性实现
- [[gbrain]] — Garry Tan 的 GBrain，synthesis 路线的生产级系统

## 时间线

- 2026-07-14 | 首次 ingest 自 GitHub README（WebFetch 抓取），建立概述与关键属性
  （来源：https://github.com/infiniflow/ragflow README）