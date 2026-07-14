---
title: "LLM Wiki gist 笔记"
type: source-note
domain: ai
tags: [llm-wiki, karpathy, knowledge-management]
sources:
  - raw/karpathy-llm-wiki-gist.md
created: 2026-07-14
updated: 2026-07-14
reliability: high
---

# LLM Wiki gist 笔记

## 来源元信息

- **文件**：raw/karpathy-llm-wiki-gist.md
- **作者**：[[andrej-karpathy|Andrej Karpathy]]
- **来源 URL**：https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- **抓取日期**：2026-07-12
- **类型**：GitHub Gist（idea file，设计为 copy-paste 给 LLM Agent 阅读，传达高层思想而非具体实现）
- **性质**：一手权威源。Karpathy 本人是 [[llm-wiki|LLM Wiki]] 模式的提出者，本 gist 是该模式的原始论述，reliability: high。

## 核心要点

- **核心范式对立**：大多数人用 LLM 处理文档的方式是 RAG——查询时检索相关片段、临时拼凑答案，每次都从零重新发现知识，没有积累。LLM Wiki 反其道：LLM 增量地构建并维护一个持久的、互链的 markdown wiki，知识「编译一次、持续保持最新」，而非每次查询重新派生（来源：raw/karpathy-llm-wiki-gist.md § The core idea）。
- **wiki 是持续复利的产物**：交叉引用已就位、矛盾已标记、综述已反映读过的所有内容；每加一个源、每问一个问题，wiki 都更丰富。wiki 由 LLM 写和维护，人负责找资料、探索、提问（来源：raw/karpathy-llm-wiki-gist.md § The core idea）。
- **三层架构**：(1) raw sources——不可变原始源，LLM 只读；(2) wiki——LLM 完全拥有的 markdown 目录（摘要/实体页/概念页/对比/综述）；(3) schema——告诉 LLM wiki 结构、约定与工作流的配置文件（如 CLAUDE.md / AGENTS.md），是让 LLM 成为「守纪律的 wiki 维护者」而非通用聊天机器人的关键（来源：raw/karpathy-llm-wiki-gist.md § Architecture）。
- **三大操作**：Ingest（投喂新源 → LLM 读、讨论、写摘要页、更新 index、更新相关实体/概念页、追加 log，单源可触达 10-15 页）；Query（基于 wiki 综合，好答案可回填为新页让探索复利）；Lint（定期体检：找矛盾、过时声明、孤岛页、缺失交叉引用、数据缺口）（来源：raw/karpathy-llm-wiki-gist.md § Operations）。
- **两个特殊文件**：index.md（内容导向目录，按类别列出每页+一句话摘要，作为查询入口，百级页面规模内无需 embedding RAG）；log.md（时间导向追加式日志，建议条目以一致前缀开头以便 unix 工具解析）（来源：raw/karpathy-llm-wiki-gist.md § Indexing and logging）。
- **为什么可行**：维护知识库的乏味部分不是阅读和思考，而是记账——更新交叉引用、保持摘要最新、标注矛盾、维护一致性。人类因维护负担增长快于价值而放弃 wiki；LLM 不会无聊、不会忘更新交叉引用、能一次触达 15 个文件。维护成本趋近于零，wiki 才得以持续（来源：raw/karpathy-llm-wiki-gist.md § Why this works）。
- **思想渊源**：与 Vannevar Bush 1945 年的 Memex 同源——个人化、主动策划、文档间关联即价值。Bush 当年无法解决的「谁来做维护」问题，由 LLM 解决（来源：raw/karpathy-llm-wiki-gist.md § Why this works）。
- **可选 CLI 工具**：wiki 规模增长后 index 文件不够用时，可引入 qmd——本地 markdown 搜索引擎，支持 BM25/向量混合搜索 + LLM 重排，完全本地运行。有 CLI（LLM 可 shell out）和 MCP server（LLM 原生工具）两种接入方式；也可让 LLM 随手写一个简单搜索脚本（来源：raw/karpathy-llm-wiki-gist.md § Optional: CLI tools）。
- **实用技巧**：(1) Obsidian Web Clipper 浏览器扩展将网页文章转为 markdown 快速入 raw；(2) 下载本地图片——设置附件目录 + 绑定快捷键，采集后一键下载避免 URL 失效；(3) Obsidian 图谱视图看 wiki 连接结构、枢纽页与孤岛页；(4) Marp 插件从 wiki 内容直接生成幻灯片；(5) Dataview 插件按 frontmatter 生成动态表格与列表；(6) wiki 即 git repo，自带版本历史、分支与协作（来源：raw/karpathy-llm-wiki-gist.md § Tips and tricks）。
- **文档是抽象的**：本 gist 描述思想而非具体实现。目录结构、schema 约定、页面格式、工具选择都取决于领域和偏好，所有内容可选且模块化——只需分享给 LLM agent 并共同实例化适合你的版本。LLM 能搞定剩下的（来源：raw/karpathy-llm-wiki-gist.md § Note）。

## 关键引文

> Instead of just retrieving from raw documents at query time, the LLM **incrementally builds and maintains a persistent wiki** — a structured, interlinked collection of markdown files that sits between you and the raw sources.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

> Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

> The wiki is a persistent, compounding artifact.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

> The tedious part of maintaining a knowledge base is not the reading or the thinking — it's the bookkeeping. … LLMs don't get bored, don't forget to update a cross-reference, and can touch 15 files in one pass.
> （来源：raw/karpathy-llm-wiki-gist.md § Why this works）

> Humans abandon wikis because the maintenance burden grows faster than the value.
> （来源：raw/karpathy-llm-wiki-gist.md § Why this works）

## 延伸问题

- 本 gist 是本 wiki schema（AGENTS.md / CLAUDE.md）的种子源，但本仓库已演化为「GBrain-core 模式」，超出 gist 的抽象描述：新增双区结构（编译真相 + 时间线）、6 种 type（含 original / media）、hobby domain、机器化 lint 脚本等。这些增量哪些是 gist 思想的自然落地、哪些是融合 GBrain 的扩展，值得在 [[llm-wiki]] 概念页持续对照。
- gist 强调「文档是抽象的，描述思想而非具体实现」，本仓库的 AGENTS.md 恰是将其「具象化」为可执行 schema 的实例——可思考「抽象 pattern ↔ 具象 schema」的映射关系是否可复用到其他领域。
- gist 提到 qmd（本地 markdown 搜索引擎，BM25/向量混合 + LLM 重排）作为 wiki 增长后的可选工具；本仓库当前规模（约 20 页）尚不需要，但可作为未来扩展预案。
- Karpathy 把 LLM Wiki 与 NotebookLM、ChatGPT 文件上传等 RAG 系统对立；本 wiki 的 [[rag-vs-llm-wiki]] 综述页已展开此对比，可回查是否还有 gist 未覆盖的维度。

## 时间线

- 2026-07-14 | 首次 ingest 自 raw/karpathy-llm-wiki-gist.md，建立 source-note 笔记：来源元信息、核心要点（7 条）、关键引文（4 条）、延伸问题（4 条）。本 gist 早在 2026-07-12 首次搭建时即被摄入并生成 [[llm-wiki]]、[[andrej-karpathy]]、[[rag-vs-llm-wiki]] 三页，但当时未为 gist 本身建 source-note 页，本次补建
  （来源：raw/karpathy-llm-wiki-gist.md）
- 2026-07-14 | 修正：对照 Karpathy 原文补全核心要点（CLI tools / Tips / Note 三节）和关键引文（§ Why this works）
  （来源：raw/karpathy-llm-wiki-gist.md § Optional: CLI tools、§ Tips and tricks、§ Why this works、§ Note）
