---
title: "知识图谱（4-Signal KG）"
type: concept
domain: ai
tags: [knowledge-graph, knowledge-management, llm-wiki]
sources: []
reliability: medium
created: 2026-07-14
updated: 2026-07-14
---

# 知识图谱（4-Signal KG）

## 定义
4-Signal 知识图谱是一种用于 LLM 维护的 wiki 系统的页面相关性计算模型，通过四种信号加权计算任意两个 wiki 页之间的关联强度，不同于传统 KG 的「实体-关系-实体」三元组模式。该设计源自 nashsu/llm_wiki 项目。

## 核心思想
- **四种信号**：
  1. **直接链接（Direct Links）**：页面 A 的正文中是否包含指向页面 B 的 `[[wikilink]]`，以及 B 是否反向引用 A
  2. **源重叠（Source Overlap）**：两个页面共享多少 `raw/` 源文件（通过 frontmatter `sources` 字段比对）
  3. **Adamic-Adar**：两个页面共享的邻居节点（被两者共同引用的第三方页面）的稀有度加权——越稀有的共同邻居，信号越强
  4. **类型亲和度（Type Affinity）**：同 type（如 entity-entity、concept-concept）的页面更可能相关
- **与 wikilink 的关系**：wikilink 是 4-Signal 中「直接链接」信号的载体，但 4-Signal KG 通过另外三种信号发现了 wikilink 无法捕捉的隐性关联

## 与相近概念对比
| 概念 | 相同 | 不同 |
| --- | --- | --- |
| [[llm-wiki|LLM Wiki]] | 同为知识组织方式 | LLM Wiki 是方法论，4-Signal KG 是 LLM Wiki 内部的关联度量机制 |
| 传统知识图谱 | 都度量实体间关系 | 传统 KG 是「实体-关系-实体」三元组，4-Signal 是四种加权信号，且面向 wiki 页面而非现实世界实体 |

## 应用场景
- **Lint 增强**：不仅检查 `[[wikilink]]` 指向是否存在，还检查「源重叠」发现本该链接但未链接的页面
- **社区发现**：作为 [[community-detection|Louvain 社区发现]] 的边权重输入
- **Graph Insights**：基于信号强度排序，优先展示最强的意外连接

## 局限
- 来源为 nashsu/llm_wiki 的 README 描述，非论文级别的完整定义，reliability 标注为 medium
- 四种信号的权重如何确定暂无公开文档
- 当前本仓库规模较小（~20 页），4-Signal 的优势尚未充分体现

## 时间线

- 2026-07-14 | 首次 ingest 自 nashsu/llm_wiki README（WebFetch 抓取），建立定义与核心思想
  （来源：https://github.com/nashsu/llm_wiki README § Features）