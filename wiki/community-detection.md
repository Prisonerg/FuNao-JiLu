---
title: "社区发现（Louvain Community Detection）"
type: concept
domain: ai
tags: [community-detection, knowledge-graph, llm-wiki, graph-algorithm]
sources: []
reliability: medium
created: 2026-07-14
updated: 2026-07-14
---

# 社区发现（Louvain Community Detection）

## 定义
Louvain 社区发现是一种基于模块度（modularity）优化的图聚类算法，在 LLM Wiki 场景中用于自动发现 wiki 页面间因 `[[wikilink]]` 密度自然形成的知识簇（cluster）。该设计源自 nashsu/llm_wiki 项目，带 cohesion scoring（凝聚度评分）。

## 核心思想
- **算法原理**：Louvain 算法通过迭代优化图的模块度（社区内部边密度高于社区间边密度的程度），自动将节点分组为社区
- **在 LLM Wiki 中的应用**：将 wiki 页面作为节点，`[[wikilink]]` 作为边，运行 Louvain 后自动发现知识簇——例如「AI 学习」页面群和「FPV 穿越机」页面群会自然分离
- **Cohesion Scoring**：nashsu/llm_wiki 对每个发现的社区计算凝聚度分数，帮助判断该社区是「真正的知识簇」还是「噪音聚合」

## 与相近概念对比
| 概念 | 相同 | 不同 |
| --- | --- | --- |
| index.md 主题 MOC | 都用于组织 wiki 页面群 | MOC 由人工命名和手动维护，Louvain 自动发现且无人工语义标签；两者互补——Louvain 发现新簇后，LLM 可建议在 index.md 新建 MOC |
| [[knowledge-graph\|4-Signal KG]] | 都用于发现 wiki 页面间的关系 | 4-Signal KG 计算页面对的相关性，Louvain 在此基础上做社区聚类 |

## 应用场景
- **Lint 增强**：发现 wiki 中自然形成但未被 index.md 主题 MOC 覆盖的知识簇，提示用户补建 MOC
- **孤岛检测**：某些页面不属于任何社区（孤立节点），提示可能存在交叉引用缺失
- **Graph Insights**：与 nashsu/llm_wiki 的「意外连接」和「知识缺口」检测配合使用

## 局限
- 来源为 nashsu/llm_wiki 的 README 描述，reliability 标注为 medium
- 当前本仓库规模较小（~20 页），社区发现的优势尚未充分体现（图太小，社区结构不明显）
- 算法无法理解页面的语义内容，仅依赖 `[[wikilink]]` 拓扑结构

## 时间线

- 2026-07-14 | 首次 ingest 自 nashsu/llm_wiki README（WebFetch 抓取），建立定义与核心思想
  （来源：https://github.com/nashsu/llm_wiki README § Features）