---
title: "WeKnora"
type: entity
domain: ai
tags: [rag, knowledge-management, agent, llm-wiki, ocr]
sources: []
reliability: high
created: 2026-07-14
updated: 2026-07-14
---

# WeKnora

## 概述
WeKnora 是腾讯开源的企业级知识管理框架，定位为「RAG + Agent + Auto-Wiki」三位一体——"Turn Documents into Living Knowledge with RAG, Agents and Auto-Wiki"。它处于 RAG 检索与 LLM Wiki 编译之间的中间地带：既有 RAG 的实时检索能力，又有 Agent 驱动的自动 wiki 生成。与 [[llm-wiki|LLM Wiki]] 的「LLM 全权维护 wiki」不同，WeKnora 更偏向「RAG 管道 + Agent 增强 + 自动 wiki 输出」的工程化方案。

## 关键属性
- **Hybrid RAG Pipeline**：传统 RAG 检索 + 多引擎 OCR 文档解析（MinerU / Docling / Marker / PaddleOCR）
- **Agentic RAG**：Agent 驱动检索，含工具调用，不只是被动检索
- **Auto-Wiki Generation**：从文档自动生成结构化 wiki 页面
- **知识图谱**：实体关系抽取与图谱可视化
- **MCP Server**：支持 Claude Desktop / Claude Code 等通过 MCP 协议接入
- **CLI Tool**：命令行工具，支持 agent-first 交互
- **Chrome Extension**：浏览器扩展，一键导入网页
- **微信集成**：与微信对话开放平台对接
- **版本**：v0.6.3（2026-07），MIT license，2,291 commits

## 相关事件
- 2026-07 — v0.6.3，CLI v0.10 发布

## 关联实体
- [[llm-wiki]] — LLM Wiki 概念的提出者 Karpathy 模式，WeKnora 是 RAG+Agent 路线的工程化实现
- [[rag-vs-llm-wiki]] — WeKnora 代表了 RAG 与 LLM Wiki 之间的混合路径
- [[gbrain]] — Garry Tan 的 GBrain，synthesis 路线的生产级系统
- [[ragflow]] — infiniflow 的 deep document understanding RAG 系统

## 时间线

- 2026-07-14 | 首次 ingest 自 GitHub README（WebFetch 抓取），建立概述与关键属性
  （来源：https://github.com/Tencent/WeKnora README）