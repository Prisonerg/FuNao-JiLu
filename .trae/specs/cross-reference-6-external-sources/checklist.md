# Checklist

## TG1 — Karpathy 原版对照

### Schema 修订
- [ ] `AGENTS.md §2` 含「Obsidian 是 IDE / LLM 是程序员 / wiki 是代码库」核心隐喻
- [ ] `AGENTS.md` 含「schema 由用户和 LLM co-evolve」哲学表述
- [ ] `AGENTS.md §9.1` 含「方式 C：batch-ingest」模式描述
- [ ] `AGENTS.md §9.1` dry-run 后含「分析阶段」步骤（步骤 0.5）
- [ ] `AGENTS.md §14` 含 Obsidian Web Clipper 推荐
- [ ] `AGENTS.md §14` 含「Download attachments for current file」热键技巧
- [ ] `AGENTS.md §14` 含 Obsidian 四项核心价值（local-first / 插件架构 / 图谱视图 / Dataview）
- [ ] `AGENTS.md §9.3` LLM 补充检查含 (5) Graph Insights（意外连接 + 知识缺口）
- [ ] `AGENTS.md §9.3` LLM 补充检查含 (6) 社区检测（Louvain 概念建议 MOC 新建）
- [ ] `AGENTS.md §14` 含 Persistent Ingest Queue 概念
- [ ] `AGENTS.md §14` 含 Source Folder Auto-Watch 概念
- [ ] `CLAUDE.md` 与 `AGENTS.md` 逐字一致（`diff` 无输出）

### 内容修复
- [ ] `wiki/llm-wiki.md` 编译真相含「Why this works」维护成本趋零论点
- [ ] `wiki/llm-wiki.md` 编译真相含「Obsidian 是 IDE」隐喻
- [ ] `wiki/llm-wiki.md` 编译真相含「Memex 1945」历史类比
- [ ] `wiki/llm-wiki.md` 编译真相含 batch-ingest 模式提及
- [ ] `wiki/llm-wiki.md` updated 已刷新为 2026-07-14，时间线含修正条目
- [ ] `wiki/rag-vs-llm-wiki.md` LLM Wiki 列描述与 Karpathy 原文一致
- [ ] `wiki/rag-vs-llm-wiki.md` updated 已刷新，时间线含修正条目
- [ ] `wiki/karpathy-llm-wiki-gist-note.md` 核心要点覆盖原文全部 8 个章节
- [ ] `wiki/karpathy-llm-wiki-gist-note.md` 关键引文摘录了代表性段落
- [ ] `wiki/karpathy-llm-wiki-gist-note.md` updated 已刷新，时间线含修正条目

## TG2 — nashsu/llm_wiki 创新

### raw 文件
- [ ] `raw/nashsu-llm-wiki-readme.md` 已落盘
- [ ] raw 文件头标注「LLM WebFetch 抓取整理，用户授权」+ 来源 URL

### 新建页
- [ ] `wiki/nashsu-llm-wiki.md` 已建（entity，ai 域，reliability: high）
- [ ] frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）
- [ ] 含 `## 时间线` 双区结构
- [ ] 正文至少 1 条 `[[wikilink]]`（如 [[andrej-karpathy]]、[[llm-wiki]]）
- [ ] `wiki/knowledge-graph.md` 已建（concept，ai 域，reliability: medium）
- [ ] frontmatter 完整，含双区结构，正文至少 1 条 `[[wikilink]]`
- [ ] 含 4-Signal 模型（直接链接/源重叠/Adamic-Adar/类型亲和度）
- [ ] `wiki/community-detection.md` 已建（concept，ai 域，reliability: medium）
- [ ] frontmatter 完整，含双区结构，正文至少 1 条 `[[wikilink]]`
- [ ] 含 Louvain 算法简介 + 与 MOC 互补关系

## TG3 — GBrain/WeKnora/RAGFlow

### 新建页
- [ ] `wiki/gbrain.md` 已建（entity，ai 域，reliability: high）
- [ ] 含 synthesis layer / content-quality gate / RBAC / cron 自动化等关键属性
- [ ] frontmatter 完整，含双区结构，`## 关联实体` 在 `## 时间线` 之上
- [ ] 正文至少 1 条 `[[wikilink]]`（如 [[llm-wiki]]、[[rag-vs-llm-wiki]]）
- [ ] `wiki/weknora.md` 已建（entity，ai 域，reliability: high）
- [ ] 含 hybrid RAG / multi-engine OCR / agentic RAG / MCP server 等关键属性
- [ ] frontmatter 完整，含双区结构，`## 关联实体` 在 `## 时间线` 之上
- [ ] 正文至少 1 条 `[[wikilink]]`（如 [[llm-wiki]]、[[ragflow]]、[[rag-vs-llm-wiki]]）
- [ ] `wiki/ragflow.md` 已建（entity，ai 域，reliability: high）
- [ ] 含 deep document understanding / agent-based RAG 等关键属性
- [ ] frontmatter 完整，含双区结构，`## 关联实体` 在 `## 时间线` 之上
- [ ] 正文至少 1 条 `[[wikilink]]`（如 [[weknora]]、[[llm-wiki]]、[[rag-vs-llm-wiki]]）

### 对比表更新
- [ ] `wiki/rag-vs-llm-wiki.md` 对比表从 2 列扩展为 5 列（RAG / LLM Wiki / GBrain / WeKnora / RAGFlow）
- [ ] 新增维度行：Synthesis Layer / Graph Analysis / OCR Pipeline / RBAC / Auto-Wiki
- [ ] updated 已刷新，时间线含修正条目

## TG4 — 收尾

- [ ] 6 个新页出现在 index.md Dataview 渲染的 domain×type 分组
- [ ] index.md 主题 MOC 含新的「知识管理」主题（含 6 个新页 + 已有相关页）
- [ ] index.md 最近更新含本次优化记录
- [ ] 重跑 `bash scripts/wiki-lint.sh` 退出码 0
- [ ] `diff AGENTS.md CLAUDE.md` 无输出
- [ ] `wiki/log.md` 末尾含 `schema-update` 记录本次全量优化
- [ ] log.md 含 6 条新建页的 `ingest` 条目