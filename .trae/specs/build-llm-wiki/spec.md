# 搭建 LLM Wiki（Karpathy 原版 gist 模式）Spec

## Why
Andrej Karpathy 在 2026 年 4 月发布的 LLM Wiki gist 提出了一种与 RAG 不同的个人知识管理模式：让 LLM 增量地"编译"原始资料为一个持久、可复利、互相链接的 Markdown wiki，而不是每次提问都从原始文档重新检索。当前仓库 `/workspace` 仅有一个占位 README，需要把这套模式落地到本仓库，作为用户长期积累「AI 学习 + 个人私密」知识的底座。

## What Changes
- 在仓库根目录搭建 Karpathy 三层架构：`raw/`（不可变原始源）→ `wiki/`（LLM 维护的扁平 Markdown wiki）→ `AGENTS.md` + `CLAUDE.md`（schema 规范文件）。
- 写一份中文 schema 文件，并同步出 `AGENTS.md`（Trae/Cursor/Codex 识别）与 `CLAUDE.md`（Claude Code 识别）两个副本，内容一致。
- schema 文件定义：目录规则、页面模板、frontmatter 字段、命名约定、`[[wikilink]]` 交叉引用风格、引文格式、矛盾处理、Ingest/Query/Lint 三大操作工作流、index.md/log.md 维护规则。
- 预填一个完整可运行示例：把 Karpathy 原始 gist 文本放入 `raw/karpathy-llm-wiki-gist.md`，并生成对应的 demo wiki 页（1 个概念页 + 1 个实体页 + 1 个综述页），以及填好的 `wiki/index.md` 与 `wiki/log.md`。
- wiki 采用**扁平结构**，所有页面放在 `wiki/` 根下（不再分子目录），靠 frontmatter 的 `domain`（ai/personal）和 `type`（entity/concept/summary/source-note）字段区分。
- 兼容 Obsidian：使用 `[[wikilink]]` 双向链接、frontmatter、callout 语法；新增 `.gitignore` 忽略 `.obsidian/` 等编辑器产物。
- 更新根 `README.md`，说明仓库用途、三层架构、如何 ingest 一个新源、如何在 Obsidian 中打开。

非变更（明确不做）：
- **不**写任何应用程序代码（无 Python/Node 脚本、无 API 调用、无构建步骤）。
- **不**引入向量数据库或 RAG 管线。
- **不**预填用户私密内容，私密领域只留模板说明。

## Impact
- Affected specs: 无（仓库首次建立 spec）。
- Affected code: 新增 `AGENTS.md`、`CLAUDE.md`、`.gitignore`、`raw/karpathy-llm-wiki-gist.md`、`wiki/index.md`、`wiki/log.md`、`wiki/llm-wiki.md`、`wiki/andrej-karpathy.md`、`wiki/rag-vs-llm-wiki.md`；修改 `README.md`。
- 后续任何 AI 编程助手（Trae/Claude Code/Cursor/Codex）打开本仓库时，会自动读取 `AGENTS.md`/`CLAUDE.md` 作为项目规则，按 wiki 维护者身份工作。

## ADDED Requirements

### Requirement: 三层目录架构
系统 SHALL 在仓库根目录提供 Karpathy LLM Wiki 的三层结构：
- `raw/` —— 原始源文件目录，schema MUST 声明其**不可变**，LLM 只读不写。
- `wiki/` —— LLM 完全拥有的 Markdown wiki 目录，扁平结构，不分子目录。
- `AGENTS.md` 与 `CLAUDE.md` —— schema 规范文件，二者内容 MUST 一致。

#### Scenario: 目录就位
- **WHEN** 任何人打开仓库
- **THEN** 能看到 `raw/`、`wiki/`、`AGENTS.md`、`CLAUDE.md`、`README.md`、`.gitignore` 均存在
- **AND** `wiki/` 下直接是 `.md` 文件，无子目录

#### Scenario: raw 不可变
- **WHEN** LLM 按 schema 工作时
- **THEN** LLM 只从 `raw/` 读取，MUST NOT 修改或删除 `raw/` 下任何文件

### Requirement: Schema 文件（AGENTS.md / CLAUDE.md）
schema 文件 SHALL 用中文撰写，并包含以下章节：
1. 项目概述（三层架构、人机分工）
2. 目录结构与不可变规则
3. 页面 frontmatter 模板（必填字段：`title`、`type`、`domain`、`tags`、`sources`、`created`、`updated`）
4. 页面正文模板（按 `type` 区分：entity / concept / summary / source-note）
5. 文件命名约定（kebab-case 英文文件名，便于跨平台与 Obsidian 链接）
6. 交叉引用风格（Obsidian `[[wikilink]]`，禁用纯相对路径链接）
7. 引文格式（页内引用 MUST 标注来源 `raw/xxx.md` 及锚点）
8. 矛盾处理（新旧资料冲突时 MUST 用 `> [!warning]` callout 标注，MUST NOT 静默覆盖旧结论）
9. 三大操作工作流：
   - **Ingest**：读 `raw/` 新源 → 提取实体/概念 → 创建或更新相关 wiki 页（一次可能触达 10-15 个文件）→ 更新 `index.md` → 追加 `log.md`
   - **Query**：读 `index.md` 找相关页 → 综合回答 → 引用回具体 wiki 页
   - **Lint**：检查矛盾、过时声明、孤岛页、缺失交叉引用
10. `index.md` 维护规则（按 domain × type 分组列出所有页）
11. `log.md` 维护规则（追加式，每条含时间戳、操作类型、触达文件列表）
12. 领域适配（`domain: ai` 与 `domain: personal` 各自的页面类型偏好与隐私提示）

#### Scenario: 双文件同步
- **WHEN** 完成 schema 撰写
- **THEN** `AGENTS.md` 与 `CLAUDE.md` 内容**逐字一致**
- **AND** Trae/Cursor/Codex 读 `AGENTS.md`，Claude Code 读 `CLAUDE.md`，行为一致

#### Scenario: 矛盾不被静默覆盖
- **WHEN** LLM ingest 一个新源，发现与某 wiki 页已有结论冲突
- **THEN** LLM MUST 在该页用 `> [!warning] 矛盾` callout 写明新旧两方与来源
- **AND** MUST NOT 直接删除旧结论

### Requirement: 预填完整示例
系统 SHALL 预填一个可运行的示例，让 LLM 看到正确格式：
- `raw/karpathy-llm-wiki-gist.md` —— Karpathy 原始 gist 全文（作为第一个原始源）。
- `wiki/llm-wiki.md` —— 概念页（`type: concept`, `domain: ai`）。
- `wiki/andrej-karpathy.md` —— 实体页（`type: entity`, `domain: ai`）。
- `wiki/rag-vs-llm-wiki.md` —— 综述页（`type: summary`, `domain: ai`），含对比表格。
- `wiki/index.md` —— 主目录，按 domain × type 分组列出上述 3 个示例页。
- `wiki/log.md` —— 操作日志，记录"ingest raw/karpathy-llm-wiki-gist.md"这一条操作，触达文件列表完整。

#### Scenario: 示例页符合模板
- **WHEN** 检查任意示例 wiki 页
- **THEN** 其 frontmatter 包含所有必填字段
- **AND** 正文结构符合其 `type` 对应模板
- **AND** 页内至少包含一条 `[[wikilink]]` 指向另一示例页

#### Scenario: 示例链接可解析
- **WHEN** 在 Obsidian 中打开 `wiki/` 作为 vault
- **THEN** 所有 `[[wikilink]]` 都能正确跳转到存在的页面，无悬空链接

### Requirement: Obsidian 兼容
系统 SHALL 确保仓库可作为 Obsidian vault 直接打开：
- 所有交叉引用使用 `[[filename]]` 或 `[[filename|显示文本]]` 语法。
- frontmatter 使用 YAML，字段名稳定。
- `.gitignore` MUST 忽略 `.obsidian/` 目录与常见编辑器临时文件。

#### Scenario: Obsidian 打开无残留
- **WHEN** 用户用 Obsidian 打开 `wiki/` 或仓库根目录
- **THEN** 图谱视图能展示示例页之间的链接关系
- **AND** `.obsidian/` 不会污染 git

### Requirement: README 说明
根 `README.md` SHALL 用中文说明：
- 仓库是什么（LLM Wiki，Karpathy 模式）
- 三层架构示意
- 如何 ingest 一个新源（把文件丢进 `raw/`，对 AI 助手说"ingest raw/xxx"）
- 如何 query（直接问，AI 会查 `index.md` 后综合）
- 如何 lint（对 AI 助手说"lint wiki"）
- 如何在 Obsidian 中打开

#### Scenario: 新用户可上手
- **WHEN** 一个新用户读 `README.md`
- **THEN** 能在不看 schema 的情况下知道仓库用法与三大操作

## MODIFIED Requirements

### Requirement: 根 README.md
原 `README.md` 内容仅为 `# FuNao-JiLu\n隐私`。SHALL 替换为完整的 LLM Wiki 用法说明（见上文 Requirement: README 说明），但保留原标题 `FuNao-JiLu` 作为仓库名标识。

## REMOVED Requirements
无。
