# Tasks

本 spec 覆盖 3 类优化：Karpathy 原版对照（Schema + 内容修复）、nashsu/llm_wiki 创新借鉴（Schema + 新建概念页）、GBrain/WeKnora/RAGFlow/Obsidian（Schema 设计哲学 + 新建项目页）。共 3 个工作组，组内可并行。

## TG1 — Karpathy 原版对照（Schema 修订 + 内容修复）

- [x] Task 1: §2 补核心隐喻 + Schema co-evolution 哲学
  - 层面：Schema / 依赖：无
  - 在 `AGENTS.md §2` 末尾增补「Obsidian 是 IDE / LLM 是程序员 / wiki 是代码库」隐喻段落；在 `§1` 或 `§2` 增补「schema 由用户和 LLM co-evolve」哲学。同步 `CLAUDE.md`。
  - 验证：`diff AGENTS.md CLAUDE.md` 无输出。

- [x] Task 2: §9.1 补 batch-ingest 模式 + Two-Step CoT 分析阶段
  - 层面：Schema / 依赖：Task 1
  - 在 `AGENTS.md §9.1` 增补「方式 C：batch-ingest」（多源同时 ingest，低监督，用户可事后抽查）；在 dry-run 预览（步骤 0）后增补「步骤 0.5：分析阶段」（LLM 先分析源的结构/主题/关键实体，再生成触达预览）。同步 `CLAUDE.md`。
  - 验证：§9.1 含「方式 C」与「分析阶段」。

- [x] Task 3: §14 补 Obsidian 工具链（Web Clipper + 本地图片下载 + 设计哲学）
  - 层面：Schema / 依赖：无（可与 Task 1/2 并行）
  - 在 `AGENTS.md §14` 增补：(a) Obsidian Web Clipper 浏览器扩展推荐；(b) 「Download attachments for current file」热键绑定技巧；(c) Obsidian 四项核心价值（local-first / 插件架构 / 图谱视图 / Dataview）。同步 `CLAUDE.md`。
  - 验证：§14 含上述 3 项。

- [x] Task 4: §9.3 补 Graph Insights + 社区检测；§14 补 Persistent Queue + Auto-Watch
  - 层面：Schema / 依赖：Task 1
  - 在 `AGENTS.md §9.3` LLM 补充检查增补：(5) Graph Insights（意外连接 + 知识缺口）；(6) 社区检测（基于 Louvain 概念建议 MOC 新建）。在 `§14` 增补：Persistent Ingest Queue 概念（规模化可选）；Source Folder Auto-Watch 概念（自动化增强）。同步 `CLAUDE.md`。
  - 验证：§9.3 含 (5)(6)，§14 含 Queue + Auto-Watch。

- [x] Task 5: 对照 Karpathy 原文修复 wiki/llm-wiki.md 编译真相
  - 层面：内容 / 依赖：无（可与 TG1 其他任务并行）
  - 逐段对照 `raw/karpathy-llm-wiki-gist.md` 原文，检查 `wiki/llm-wiki.md` 编译真相区：(a) 「Why this works」核心论点（维护成本趋零）是否充分表达；(b) 「Obsidian 是 IDE」隐喻是否已在编译真相中体现；(c) 「Memex 1945」历史类比是否已收录；(d) batch-ingest 是否已提及。逐项修正，重写编译真相区，刷新 `updated`，时间线追加修正条目。
  - 验证：编译真相与原文关键论点一致。

- [x] Task 6: 对照 Karpathy 原文修复 wiki/rag-vs-llm-wiki.md
  - 层面：内容 / 依赖：Task 5（同文件先后无关，但逻辑上先修 llm-wiki 再修对比更合理）
  - 检查 `wiki/rag-vs-llm-wiki.md` 对比表中「LLM Wiki」列描述是否与 Karpathy 原意一致：(a) 是否混淆了 RAG 检索与 LLM Wiki 编译的概念；(b) 「维护成本」行是否准确（原文强调「维护成本趋零」）。修正后刷新 `updated`，时间线追加修正条目。
  - 验证：LLM Wiki 列描述与 Karpathy 原文一致。

- [x] Task 7: 对照 Karpathy 原文修复 wiki/karpathy-llm-wiki-gist-note.md
  - 层面：内容 / 依赖：无
  - 检查 `wiki/karpathy-llm-wiki-gist-note.md`（source-note）的「核心要点」是否完整覆盖原文 8 个章节（core idea / architecture / operations / indexing / CLI tools / tips / why this works / note）。如有遗漏补全；检查「关键引文」是否摘录了最有代表性的原文段落。修正后刷新 `updated`，时间线追加修正条目。
  - 验证：核心要点覆盖原文全部 8 个章节。

## TG2 — nashsu/llm_wiki 创新 ingest（新建 raw + 3 个 wiki 页）

- [x] Task 8: 抓取 nashsu/llm_wiki README 落盘 raw/
  - 层面：内容 / 依赖：无
  - 通过 WebFetch 抓取 `https://raw.githubusercontent.com/nashsu/llm_wiki/main/README.md`，整理为 raw 格式落盘 `raw/nashsu-llm-wiki-readme.md`。文件头标注「本文件由 LLM 经 WebFetch 抓取整理落盘，用户授权；来源：https://github.com/nashsu/llm_wiki」。
  - 验证：raw 文件存在，含完整 README 内容。

- [x] Task 9: 建 nashsu/llm_wiki 项目 entity 页
  - 层面：内容 / 依赖：Task 8
  - 建 `wiki/nashsu-llm-wiki.md`（entity，ai 域，reliability: high）：含概述、关键属性（Two-Step CoT Ingest / 4-Signal KG / Louvain / Graph Insights / Persistent Queue / Auto-Watch 等）、关联实体（[[andrej-karpathy]]、[[llm-wiki]]）、双区结构。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误，出现在 index.md domain×type 分组。

- [x] Task 10: 建知识图谱 concept 页
  - 层面：内容 / 依赖：Task 9（逻辑依赖，可并行）
  - 建 `wiki/knowledge-graph.md`（concept，ai 域，reliability: medium）：定义、4-Signal 模型（直接链接 + 源重叠 + Adamic-Adar + 类型亲和度）、应用场景（wiki 交叉引用增强）、与 [[llm-wiki]] 的关系。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误。

- [x] Task 11: 建社区发现 concept 页
  - 层面：内容 / 依赖：Task 10（逻辑依赖，可并行）
  - 建 `wiki/community-detection.md`（concept，ai 域，reliability: medium）：定义、Louvain 算法简介、与 index.md 主题 MOC 的互补关系、应用场景。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`（链到 [[knowledge-graph]]、[[llm-wiki]]）。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误。

## TG3 — GBrain/WeKnora/RAGFlow 架构对照 + ingest（3 个 entity 页 + 1 个对比表更新）

- [x] Task 12: 建 GBrain 项目 entity 页
  - 层面：内容 / 依赖：无
  - 基于 WebFetch 获取的 GBrain README 内容，建 `wiki/gbrain.md`（entity，ai 域，reliability: high，title: "GBrain"）：概述（Garry Tan / YC 总裁 / 146K 页 / 24K 人 / 5K 公司的生产级知识脑）、关键属性（synthesis layer / graph traversal / gap analysis / content-quality gate / RBAC company-brain / cron 自动化）、关联实体（[[llm-wiki]]、[[rag-vs-llm-wiki]]）。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误。

- [x] Task 13: 建 WeKnora 项目 entity 页
  - 层面：内容 / 依赖：无
  - 基于 WebFetch 获取的 WeKnora README 内容，建 `wiki/weknora.md`（entity，ai 域，reliability: high，title: "WeKnora"）：概述（腾讯 / RAG+Agent+Auto-Wiki / OCR pipeline / 知识图谱）、关键属性（hybrid RAG / multi-engine OCR / agentic RAG / MCP server / CLI）、关联实体（[[llm-wiki]]、[[ragflow]]、[[rag-vs-llm-wiki]]）。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误。

- [x] Task 14: 建 RAGFlow 项目 entity 页
  - 层面：内容 / 依赖：无
  - 基于 WebFetch 获取的 RAGFlow README 内容，建 `wiki/ragflow.md`（entity，ai 域，reliability: high，title: "RAGFlow"）：概述（infiniflow / deep document understanding / agent-based RAG / 7K+ commits）、关键属性（deep document parsing / RAG pipeline / agentic RAG）、关联实体（[[weknora]]、[[llm-wiki]]、[[rag-vs-llm-wiki]]）。frontmatter 完整（created=updated=2026-07-14）。正文至少 1 条 `[[wikilink]]`。log.md 追加 `ingest` 条目。
  - 验证：lint 0 错误。

- [x] Task 15: 更新 rag-vs-llm-wiki.md 对比表为 5 列
  - 层面：内容 / 依赖：Task 12、Task 13、Task 14（需要新页面的 [[wikilink]] 存在）
  - 将 `wiki/rag-vs-llm-wiki.md` 对比表从 2 列（RAG / LLM Wiki）扩展为 5 列（RAG / LLM Wiki / GBrain / WeKnora / RAGFlow）。新增维度行：「Synthesis Layer」「Graph Analysis」「OCR Pipeline」「RBAC」「Auto-Wiki」。编译真相区重写整合，刷新 `updated`，时间线追加修正条目。
  - 验证：对比表含 5 列，新增维度行合理。

## TG4 — 收尾

- [x] Task 16: 更新 index.md + 全量验证 + log.md 记录
  - 层面：流程 / 依赖：Task 1-15 全部完成
  - 在 `wiki/index.md` 的「主题 MOC」新增「知识管理」主题条目（含 [[nashsu-llm-wiki]]、[[gbrain]]、[[weknora]]、[[ragflow]]、[[knowledge-graph]]、[[community-detection]]）；「最近更新」追加一条本次优化记录。重跑 `bash scripts/wiki-lint.sh` 确保 0 错误。`diff AGENTS.md CLAUDE.md` 确保一致。在 `wiki/log.md` 追加一条 `schema-update` 记录本次全量优化。
  - 验证：lint 0 错误，AGENTS.md 与 CLAUDE.md 一致，log.md 含记录。

# Task Dependencies

- Task 1（核心隐喻）→ Task 2（§9.1）、Task 4（§9.3/§14）依赖
- Task 3（§14 工具链）无依赖，可与 Task 1 并行
- Task 5/6/7（内容修复）无相互依赖，可并行
- Task 8（抓取 raw）→ Task 9（nashsu entity）依赖
- Task 10/11（concept 页）可与 Task 8/9 并行
- Task 12/13/14（GBrain/WeKnora/RAGFlow entity）无相互依赖，可并行
- Task 15（对比表扩展）依赖 Task 12/13/14
- Task 16（收尾）依赖全部 Task 1-15

## 可并行批次

- 批次 A：Task 1 + Task 3 + Task 5 + Task 6 + Task 7 + Task 8 + Task 12 + Task 13 + Task 14
- 批次 B：Task 2 + Task 4 + Task 9 + Task 10 + Task 11
- 批次 C：Task 15
- 批次 D：Task 16