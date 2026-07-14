# 6 外部源交叉对照优化 Spec

## Why

本仓库在上一轮 `optimize-llm-wiki` 已完成 30 项优化，但对照 Karpathy LLM Wiki 原版 gist 全文、nashsu/llm_wiki 独立实现、GBrain (Garry Tan)、WeKnora (腾讯)、RAGFlow (infiniflow)、Obsidian 官方文档后，发现三类新缺口：

1. **Karpathy 原版遗漏**：原版 gist 中「Obsidian 是 IDE / LLM 是程序员 / wiki 是代码库」的核心隐喻、batch-ingest 模式、Obsidian Web Clipper / 本地图片下载等实用技巧、以及「schema 由人机 co-evolve」的哲学，在 AGENTS.md 中未充分体现。
2. **nashsu/llm_wiki 创新未借鉴**：Two-Step Chain-of-Thought Ingest、4-Signal 知识图谱、Louvain 社区发现、Graph Insights（意外连接 + 知识缺口）、Persistent Ingest Queue、Source Folder Auto-Watch 等机制，可显著提升本仓库的自动化深度。
3. **GBrain/WeKnora/RAGFlow 架构未 ingest**：三个项目的 synthesis layer、content-quality gate、agentic RAG、multi-engine OCR pipeline 等设计，对理解 LLM Wiki 生态位有价值，但尚未作为知识页进入 wiki。

## What Changes

### LLM Wiki 对照（Schema 修订）
- **补 Karpathy 原版 5 项遗漏**：核心隐喻、batch-ingest 模式、Web Clipper 技巧、本地图片下载、schema co-evolution 哲学
- **借鉴 nashsu/llm_wiki 6 项创新**：Two-Step CoT Ingest、4-Signal KG、Louvain 社区发现、Graph Insights、Persistent Ingest Queue、Auto-Watch

### LLM Wiki 对照（内容修复）
- **重读 Karpathy gist 原文逐项对照**：检查 `wiki/llm-wiki.md`、`wiki/rag-vs-llm-wiki.md`、`wiki/karpathy-llm-wiki-gist-note.md` 三页编译真相是否与原文一致
- **检查逻辑错误**：对照原文发现「Why this works」段的核心论点（维护成本趋零）在当前 wiki 页中是否充分表达

### 新建页（LLM Wiki 生态）
- **nashsu/llm_wiki 项目页**：`wiki/nashsu-llm-wiki.md`（entity，ai 域，reliability: high）
- **知识图谱概念页**：`wiki/knowledge-graph.md`（concept，ai 域）
- **社区发现概念页**：`wiki/community-detection.md`（concept，ai 域）

### Obsidian → Schema 设计哲学
- **补 Obsidian 设计哲学**：local-first、插件架构、图谱视图作为「思想的 IDE」的隐喻
- **补 Obsidian Web Clipper 工作流**到 §14 工具链

### GBrain/WeKnora/RAGFlow → 架构对照 + ingest
- **GBrain 项目页**：`wiki/gbrain.md`（entity，ai 域），含 synthesis layer / content-quality gate / RBAC 分析
- **WeKnora 项目页**：`wiki/weknora.md`（entity，ai 域），含 hybrid RAG+Agent+Auto-Wiki 架构分析
- **RAGFlow 项目页**：`wiki/ragflow.md`（entity，ai 域），含 deep document understanding 分析
- **更新 `wiki/rag-vs-llm-wiki.md`**：对比表新增 GBrain / WeKnora / RAGFlow 三列，展示更完整的生态位

### 非变更（明确不做）
- 不改三层架构、双区结构、6 种 type MECE、扁平 + frontmatter、raw 只读、3 domain 分层
- 不修改 nashsu/llm_wiki 的源码（本仓库只参考其设计，不 fork）
- 不修改 GBrain/WeKnora/RAGFlow 的源码

## Impact

- **Affected specs**：本文件（`.trae/specs/cross-reference-6-external-sources/spec.md`）
- **Affected files**：
  - `AGENTS.md` + `CLAUDE.md`（§2/§9.1/§14 修订，增补 Karpathy 遗漏 + nashsu 创新 + Obsidian 哲学）
  - `wiki/llm-wiki.md`（编译真相重写，对照原文修正）
  - `wiki/rag-vs-llm-wiki.md`（对比表扩展 + 编译真相修正）
  - `wiki/karpathy-llm-wiki-gist-note.md`（编译真相修正，对照原文）
  - `wiki/index.md`（新增 6 个 wiki 页登记 + 主题 MOC 更新）
  - `wiki/log.md`（追加 ingest 记录）
  - 新建 6 个 wiki 页：`nashsu-llm-wiki.md`、`knowledge-graph.md`、`community-detection.md`、`gbrain.md`、`weknora.md`、`ragflow.md`
  - 新建 1 个 raw 文件：`raw/nashsu-llm-wiki-readme.md`（nashsu/llm_wiki README 落盘，URL 直接 ingest）

## ADDED Requirements

### Requirement: Karpathy 原版 5 项遗漏补全
AGENTS.md SHALL 补全 Karpathy 原版 gist 中已描述但当前 Schema 未体现的 5 项内容。

#### Scenario: 核心隐喻
- **WHEN** AGENTS.md 描述项目定位
- **THEN** SHALL 包含「Obsidian 是 IDE / LLM 是程序员 / wiki 是代码库」的核心隐喻（Karpathy 原文 § The core idea 末段）

#### Scenario: batch-ingest 模式
- **WHEN** §9.1 Ingest 描述工作流
- **THEN** SHALL 提及 batch-ingest 模式（多源同时 ingest，低监督）作为可选方案，而非仅描述单源逐个 ingest

#### Scenario: Obsidian Web Clipper
- **WHEN** §14 工具链描述
- **THEN** SHALL 包含 Obsidian Web Clipper 浏览器扩展推荐（Karpathy 原文 § Tips and tricks 第 1 条）

#### Scenario: 本地图片下载
- **WHEN** §14 工具链描述
- **THEN** SHALL 包含「Download attachments for current file」热键绑定技巧（Karpathy 原文 § Tips and tricks 第 2 条）

#### Scenario: Schema co-evolution 哲学
- **WHEN** AGENTS.md 描述 schema 定位
- **THEN** SHALL 包含「schema 由用户和 LLM co-evolve——边用边改，逐步适配你的领域」的哲学表述（Karpathy 原文 § Architecture 末段）

### Requirement: nashsu/llm_wiki 6 项创新借鉴
AGENTS.md SHALL 借鉴 nashsu/llm_wiki 的 6 项创新机制，提升自动化深度。

#### Scenario: Two-Step Chain-of-Thought Ingest
- **WHEN** §9.1 Ingest 流程描述
- **THEN** SHALL 在步骤 0 dry-run 后增加「分析阶段」（先分析源的结构/主题/关键实体，再生成具体操作），与 nashsu 的「LLM analyzes first, then generates wiki pages」一致

#### Scenario: 4-Signal Knowledge Graph
- **WHEN** §9.3 Lint 或 §14 机器化维护
- **THEN** SHALL 引入「4-Signal 知识图谱」概念：直接链接（wikilink）+ 源重叠（共享 raw）+ Adamic-Adar（共同邻居）+ 类型亲和度（同 type 页更可能相关），作为 lint 增强检查的参考框架

#### Scenario: Louvain 社区发现
- **WHEN** §9.3 Lint 或 §14 机器化维护
- **THEN** SHALL 引入「Louvain 社区发现」概念：自动检测 wiki 中的知识簇（cluster），与 index.md 的「主题 MOC」形成互补——MOC 人工命名，Louvain 自动发现；发现后 LLM 可建议新建 MOC 主题

#### Scenario: Graph Insights
- **WHEN** §9.3 Lint 检查项
- **THEN** SHALL 增加「意外连接」（两个表面上不相关的页通过中间页形成路径）和「知识缺口」（某概念被频繁提及但无独立页）的检测逻辑

#### Scenario: Persistent Ingest Queue
- **WHEN** §14 机器化维护
- **THEN** SHALL 引入「持久化 ingest 队列」概念：批量 ingest 时的串行处理 + 崩溃恢复 + 进度可视化，作为规模化后的可选增强

#### Scenario: Source Folder Auto-Watch
- **WHEN** §14 机器化维护
- **THEN** SHALL 引入「源文件夹自动监控」概念：检测 raw/ 目录新增文件并自动触发 ingest dry-run 预览，作为 Schedule 自动化的可选增强

### Requirement: Obsidian 设计哲学
AGENTS.md §14 SHALL 补充 Obsidian 作为「思想的 IDE」的设计哲学，帮助理解为何选择 Obsidian 作为 wiki 浏览器。

#### Scenario: Obsidian 核心价值
- **WHEN** §14 描述工具链
- **THEN** SHALL 包含：local-first（数据本地所有）、插件架构（可扩展性）、图谱视图（可视化知识网络）、Dataview（frontmatter 查询）四项核心价值

### Requirement: 新建 wiki 页合规性
本 spec 新建的 6 个 wiki 页 SHALL 满足全部 Schema 不可变规则（同 `optimize-llm-wiki` spec 的 Requirement 要求）。

### Requirement: rag-vs-llm-wiki.md 扩展
`wiki/rag-vs-llm-wiki.md` 对比表 SHALL 从当前 2 列（RAG vs LLM Wiki）扩展为 5 列（RAG / LLM Wiki / GBrain / WeKnora / RAGFlow），展示更完整的知识管理生态位。

## MODIFIED Requirements

### Requirement: §2 目录结构说明
§2 SHALL 在 `wiki/` 目录说明后增补「Obsidian 是 IDE / LLM 是程序员 / wiki 是代码库」隐喻，作为设计哲学的背景说明。

### Requirement: §9.1 Ingest 流程
§9.1 SHALL 在方式 A/B 之后增补「方式 C：batch-ingest」（多源同时 ingest，低监督），并在 dry-run 预览后增加「分析阶段」步骤。

### Requirement: §9.3 Lint 检查项
§9.3 LLM 补充检查 SHALL 增补 2 项：(5) Graph Insights——检测意外连接（跨域路径）和知识缺口（高频实体无独立页）；(6) 社区检测——建议基于 Louvain 概念的主题 MOC 新建。

### Requirement: §14 工具链
§14 SHALL 增补：(1) Obsidian Web Clipper 推荐；(2) 本地图片下载热键；(3) Persistent Ingest Queue 概念（规模化后可选）；(4) Source Folder Auto-Watch 概念（自动化增强）。

## REMOVED Requirements
无。