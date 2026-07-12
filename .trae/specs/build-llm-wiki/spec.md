# GBrain-core Wiki 重构 Spec

## Why
仓库原先基于 Karpathy LLM Wiki gist 模式搭建（2026-07-12 首次建立），运行良好但存在结构性与维护性瓶颈：页面混合存储导致更新时易漏改（M1 事件）、矛盾靠 callout 堆叠会降低可读性、纯靠 LLM 手动 lint 在规模化时会漏检、用户原创思考无承载 type 而随会话流失。

Garry Tan 的 [gbrain](https://github.com/garrytan/gbrain) 仓库（14.7 万页生产级部署）提供了系统化解法：Compiled Truth + Timeline 双区结构、Originals 文件夹、Brain-Agent Loop、机器化 doctor/sync 维护。本次重构以 GBrain 的「知识编译 + 双区结构 + 机器化维护」为核心引擎，融合本仓库原有优点（raw/ 不可变层、扁平 + frontmatter 结构、domain 三域隐私分层），升级为「GBrain-core 模式」，为规模化到 50-100 页打地基。

## What Changes
- **AGENTS.md 全量重写**：从「Karpathy LLM Wiki Schema」升级为「GBrain-core Wiki Schema」（14 节）。新增：§4.0 type 判定测试（MECE 决策树）、§4.1 双区结构（`## 时间线` 分界，上重写/下追加）、§4.6 media 模板、§4.7 original 模板、§8 矛盾处理双区版、§9.1 ingest 强制自检 checklist（8 项）、§9.2 query 前置全量关键词扫描、§9.3 lint 机器化（8 项检查）、§10.1 主题 MOC、§13 对话中 original 主动捕获、§14 机器化维护。
- **type 从 4 种扩为 6 种**：`entity` / `concept` / `summary` / `source-note` / `original` / `media`。media 与 source-note 按资料形态分流（媒体作品 → media；文字资料 → source-note）。
- **frontmatter 加可选字段 `reliability`**：high/medium/low，低可信源结论标注「待权威源验证」。
- **CLAUDE.md 同步**：与 AGENTS.md 逐字一致。
- **scripts/wiki-lint.sh 新建**：纯 bash/grep 机器化体检脚本，8 项检查 + 反向链接矩阵，无外部依赖。
- **13 个 wiki 页全量迁移**：所有页加 `## 时间线` 双区结构；4 个 source-note（媒体作品类）转 media 类型（章节「来源元信息」→「作品元信息」）；2 个 entity 时间线从表格改为新列表格式；所有页 frontmatter 加 reliability；修复 2 处失效交叉引用。
- **index.md 重写**：顶部加主题 MOC（4 个主题），下方 domain × type 分组扩为 6 种 type（预留 original/media 槽位）。
- **log.md 追加**：schema-update 记录，含完整变更说明。
- **Trae Schedule 创建**：每周一 09:00（Beijing time）自动触发 lint，报告写进 log.md。

非变更（明确不做）：
- **不**放弃 `raw/` 不可变层（保留三层架构）。
- **不**改为 MECE 子目录结构（保持扁平 + frontmatter 区分）。
- **不**引入数据库/CLI/向量检索（保持纯 markdown + Obsidian 友好）。
- **不**全面 entity detection（只主动捕获 original，entity/concept 仍走手动 ingest）。
- **不**修改任何 `raw/` 下文件。

## Impact
- Affected specs: 本文件（原地更新为 GBrain-core 版）。
- Affected code: `AGENTS.md`（全量重写）、`CLAUDE.md`（同步）、`scripts/wiki-lint.sh`（新建）、`wiki/index.md`（重写）、13 个 wiki 页（迁移）、`wiki/log.md`（追加）、`README.md`（更新）、`.trae/specs/build-llm-wiki/{spec,checklist,tasks}.md`（更新）、Trae Schedule（新建）。
- 后续任何 AI 编程助手打开本仓库时，会读取新 AGENTS.md/CLAUDE.md，按 GBrain-core 维护者身份工作：遇资料先判定 type、双区结构更新、ingest 末尾自检、对话中主动捕获 original。

## ADDED Requirements

### Requirement: 双区结构（Compiled Truth + Timeline）
每个知识页 SHALL 包含「编译真相」与「时间线」双区，用 `## 时间线` 二级标题作为分界。

#### Scenario: 编译真相随证据重写
- **WHEN** LLM ingest 一个新源，发现某页编译真相需更新
- **THEN** LLM MUST 重写编译真相区（`## 时间线` 以上）为最新综合
- **AND** MUST NOT 在编译真相区追加旧结论

#### Scenario: 时间线只追加不编辑
- **WHEN** 时间线已有条目
- **THEN** LLM MUST NOT 编辑既有条目
- **AND** 新信息 MUST 追加为新条目，格式 `- YYYY-MM-DD | 摘要\n  （来源：raw/xxx.md § 章节）`

#### Scenario: 矛盾处理走双区
- **WHEN** 新源与编译真相已有结论冲突
- **THEN** LLM MUST 在时间线追加「修正」条目
- **AND** MUST 重写编译真相为最新结论
- **AND** 旧结论永久保留在时间线里

### Requirement: 六种 type 的 MECE 判定
type 字段取值 SHALL 为 6 种之一：`entity` / `concept` / `summary` / `source-note` / `original` / `media`。每个知识对象经 §4.0 判定测试落入唯一一种 type。

#### Scenario: media 与 source-note 按资料形态分流
- **WHEN** ingest 一个视频/图文/播客作品
- **THEN** LLM MUST 建 `media` 页（章节「作品元信息」）
- **WHEN** ingest 一篇文章/论文/gist
- **THEN** LLM MUST 建 `source-note` 页（章节「来源元信息」）

#### Scenario: original 承载用户原创思考
- **WHEN** 用户在对话中表达原创框架/命名/洞见
- **THEN** LLM MUST 主动询问是否捕获为 original 页
- **AND** 用户同意后，文件名用用户原话的 kebab-case，`## 原始表述` 逐字保留用户原话

### Requirement: 机器化体检脚本
系统 SHALL 提供 `scripts/wiki-lint.sh`（纯 bash/grep，无外部依赖），执行 8 项机器化检查 + 反向链接矩阵。

#### Scenario: 脚本可独立运行
- **WHEN** 运行 `bash scripts/wiki-lint.sh`
- **THEN** 脚本输出 8 项检查结果（frontmatter 完整性、双区结构、孤岛页、悬空引用、sources 与 raw 对齐、index 与实际页对齐、时间线格式、反向链接矩阵）
- **AND** 退出码为 0（无错误）或 1（有错误）

### Requirement: Trae Schedule 定期自动 lint
系统 SHALL 通过 Trae Schedule 设定每周自动触发一次 lint。

#### Scenario: 每周自动体检
- **WHEN** 每周一 09:00（Beijing time）
- **THEN** Schedule 自动派发新会话执行 lint
- **AND** 报告写进 `wiki/log.md`（操作类型 `lint`，说明标注「Schedule 自动触发」）

### Requirement: ingest 强制自检 checklist
ingest 完成前 MUST 执行 8 项自检，任一为否则不允许结束本次 ingest。

#### Scenario: 自检全通过才结束
- **WHEN** LLM 完成 ingest 的 8 个步骤
- **THEN** LLM MUST 逐条声明 8 项自检 checklist 全部为真
- **AND** 若任一为假，MUST 回去补齐

## MODIFIED Requirements

### Requirement: 三层目录架构
原 Karpathy 三层架构（raw / wiki / schema）保留，新增 `scripts/` 目录承载机器化体检脚本。

#### Scenario: 目录就位
- **WHEN** 任何人打开仓库
- **THEN** 能看到 `raw/`、`wiki/`、`scripts/`、`AGENTS.md`、`CLAUDE.md`、`README.md`、`.gitignore` 均存在
- **AND** `wiki/` 下直接是 `.md` 文件，无子目录
- **AND** `scripts/` 下含 `wiki-lint.sh`

### Requirement: Schema 文件（AGENTS.md / CLAUDE.md）
schema 文件 SHALL 用中文撰写，并包含以下 14 个章节：
1. 项目概述（GBrain-core 模式、三层架构、人机分工）
2. 目录结构与不可变规则
3. 页面 frontmatter 模板（必填字段 + 可选 reliability）
4. 六种 type 的判定测试与正文模板（含 §4.0 MECE 决策树、§4.1 双区结构、§4.2-4.7 各 type 模板）
5. 命名约定（kebab-case，original 用用户原话）
6. 交叉引用风格（单向 `[[wikilink]]`，反向链接由 lint 脚本算）
7. 引文格式（timeline source 增强为 `raw/xxx.md § 章节` 精确引用）
8. 矛盾处理规则（双区版：时间线追加修正 + 编译真相重写）
9. 三大操作工作流（ingest 含自检 checklist、query 含全量扫描、lint 机器化）
10. index.md 维护规则（主题 MOC + domain × type 分组）
11. log.md 维护规则（追加式，操作类型含 schema-update）
12. 领域适配（ai / personal / hobby 三域）
13. 对话中 original 主动捕获
14. 机器化维护（lint 脚本 + Trae Schedule）

### Requirement: index.md 双视图
index.md SHALL 包含两个视图：顶部主题 MOC + 下方 domain × type 分组。

#### Scenario: 主题 MOC 聚合跨 type 相关页
- **WHEN** 用户浏览 index.md 顶部
- **THEN** 能看到按主题（如「FPV / 穿越机」「知识管理」）聚合的相关页 `[[wikilink]]`

### Requirement: 根 README.md
README.md SHALL 用中文说明 GBrain-core 模式，包含：
- 仓库是什么（GBrain-core Wiki，融合 GBrain + Karpathy）
- 三层架构 + scripts/ 示意
- 6 种 type 与 3 个 domain 说明
- 双区结构（编译真相 + 时间线）说明
- 三大操作（ingest / query / lint）
- 机器化维护（lint 脚本 + Schedule）
- 如何在 Obsidian 中打开

## REMOVED Requirements
- 旧 spec 中的「矛盾处理用 `> [!warning]` callout 标注」改为双区结构处理（callout 仅作临时标注，裁定后移除）。
- 旧 spec 中的「四种 type」改为六种 type。
- 旧 spec 中的「无应用程序代码」改为「有 scripts/wiki-lint.sh 机器化体检脚本」。
