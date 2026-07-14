# GBrain-core Wiki 全量优化 Spec

## Why

基于 Karpathy LLM Wiki 原版（https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f）与仓库现状的全量对照（详见 `proposal.md` 22 项 + 二次深度检查新发现 4 项 bug），本仓库地基扎实但存在三类待解问题：

1. **核心机制缺口**：遗漏 Karpathy 模式的「Query 回填」第二复利引擎；`rag-vs-llm-wiki.md` 对比表仍描述旧版 callout 矛盾处理机制，与已重写的 §8 双区版不一致。
2. **数据正确性受损**：lint 脚本入链重复计数 bug 污染了 index.md 快速入口；log.md 时序错乱违反 §11 正序规则；`updated` 字段语义模糊导致 14 页被 lint 误刷。
3. **自动化深度不足**：index.md 五区块全手维护易错；3 个 skill 与 AGENTS.md 大量重复维护易不同步；lint 缺 6 项检查（文件名/reliability/日期格式/§锚点/index一致性/双区启发式）。

本 spec 将上述 26 项（22+4）合并为一个完整可执行方案，分 P0/P1/P2 三级推进，覆盖四个层面（Karpathy 对齐 / Schema 规范 / 内容质量 / 工具自动化）。

## What Changes

### P0（数据正确性与核心机制）
- **修 lint 脚本入链重复计数 bug**（`scripts/wiki-lint.sh` 第 107-115、244-260 行）：改为按「源页→目标页」唯一对计数。
- **修 3 个 entity 页双区结构违规**：`andrej-karpathy.md`、`quanqiu-dou-zhidao.md`、`secret-fpv-pilot.md` 的 `## 关联实体` 段移至 `## 时间线` 之上。
- **补 Query 回填复利机制**：`§9.2` 增步骤 6「评估回填价值」；`§11` 操作类型新增 `query-fileback`；`skills/llm-wiki-query/SKILL.md` 补回填流程。

### P1（健壮性）
- **lint 脚本修 2 bug**：frontmatter 字段检查重复条件（第 60 行）；sources 提取易误捕（第 162-171 行）。
- **lint 脚本补 6 项检查**：文件名 kebab-case、reliability 取值、时间线日期格式、§ 章节锚点、index 快速入口与 lint 数据一致性、双区启发式（编译真相区不应有日期戳列表）。
- **ingest 自检机器化验证**：lint 新增「最近一次 ingest 声明触达的页是否 updated=今日 + 时间线末条=今日」「每个 raw 是否至少被一个 wiki 页 sources 引用」。
- **修 index.md 快速入口数据**：用修好的 lint 输出重写（修计数虚高 + 排序错位）。
- **补 15 页时间线 § 章节锚点**。
- **修 rag-vs-llm-wiki.md 陈旧论断**：对比表「矛盾处理」行更新为双区版机制。
- **修 log.md 时序 + 操作类型枚举**：重排为正序；头部操作类型补 `schema-update`；统一大小写。
- **§3 重定义 `updated` 语义**：明确「= 编译真相区最后一次重写日期，非 lint 触达日期」；逐页核定并修正。
- **§4.0 补 MECE 边界规则**：单源综述（综述形态→summary / 提炼笔记形态→source-note，靠正文结构区分）。
- **§9.1 自检加第 9 项**：「本次 ingest 的 raw 本身已有对应 media/source-note 页」。
- **index.md Dataview 改造**：最近更新/标签索引/domain×type 分组三段改 Dataview 查询块；快速入口由 lint 输出片段；主题 MOC 保留手维护。
- **3 个 skill 瘦壳化**：删除与 AGENTS.md 重复的通用规则，只留触发条件 + 章节引用 + 操作特有事项。
- **Query 多形态输出指引**：§9.2 增按问题类型选输出形态（对比→表/趋势→图/汇报→Marp/关系→canvas）。

### P2（锦上添花，基于网络检索交叉验证后自行补全）
- **§14 增 git 工作流小节**：每次 ingest/lint 后建议 conventional commit。
- **§14 增规模化搜索阈值**：>100 页且 Query 漏页时引入 qmd（8 阶段混合检索：BM25+向量+LLM 重排，MCP server 支持）。
- **§14 增 entity 主动检测策略**：ingest 步骤 3 后高频实体无 entity 页时主动询问。
- **log.md 与 lint 报告分离**：log 只记摘要，详细报告写 `reports/`。
- **lint 脚本增 `--json` 输出**。
- **log.md 格式 grep 优化**：`## [YYYY-MM-DD HH:MM] type | 简述`（迁移历史条目）。
- **补 2 个 source-note 页**：基于已有 raw 文件（`raw/karpathy-llm-wiki-gist.md`、`raw/uhpc-authoritative-standards-2026-07.md`）自行整理建页，无需等待用户重新 ingest。
- **补 2 位创作者 entity 页**（苏大讲AI、暖暖小星球）：基于网络检索结果 + 已有 raw 元信息建页，`reliability: low`，明确标注「网络检索未找到权威背景，待后续 ingest 权威源升级」。
- **修 andrej-karpathy.md 5 条公众事实**：基于网络检索的 Karpathy 传记信息（出生 1986-10-23 Bratislava；BSc Toronto 2009；MSc UBC 2011；PhD Stanford 2011-2015 under Fei-Fei Li；OpenAI 创始成员 2015-2017；Tesla Director of AI 2017-2022；二进 OpenAI 2023-2024；Eureka Labs 2024；2026 加入 Anthropic），新建 `raw/karpathy-biography-web-2026-07.md` 落盘后补全 5 条时间线条目，移除 callout。

### 非变更（明确不做）
- 不改三层架构、双区结构、6 种 type MECE、扁平 + frontmatter、raw 只读、3 domain 分层、original 主动捕获、AGENTS/CLAUDE 双写同步。

## Impact
- **Affected specs**：本文件（`.trae/specs/optimize-llm-wiki/spec.md`）；原 `build-llm-wiki/spec.md` 不变。
- **Affected code/files**：
  - `AGENTS.md` + `CLAUDE.md`（§3/§4.0/§9.1/§9.2/§10/§11/§14 修订，二者同步）
  - `scripts/wiki-lint.sh`（修 3 bug + 补 8 项检查 + --json）
  - `wiki/index.md`（快速入口重写 + 3 段 Dataview）
  - `wiki/log.md`（时序重排 + 操作类型枚举 + 格式优化）
  - `wiki/andrej-karpathy.md`、`wiki/quanqiu-dou-zhidao.md`、`wiki/secret-fpv-pilot.md`（双区结构修复）
  - `wiki/rag-vs-llm-wiki.md`（陈旧论断修复）
  - 15 个 wiki 页（时间线 § 章节锚点补全）
  - 20 个 wiki 页（updated 字段核定）
  - `skills/llm-wiki-{ingest,query,lint}/SKILL.md`（瘦壳化）
  - 新建 `reports/` 目录（lint 报告分离）
  - 【阻塞项】新建 2 source-note + 2 entity 页
- **后续影响**：任何 AI 助手打开本仓库将按优化后的 Schema 工作，Query 回填使探索复利，lint 可信度提升，index 维护成本下降。

## ADDED Requirements

### Requirement: Query 回填复利机制
系统 SHALL 在 Query 工作流末尾增加「评估回填价值」步骤，使高质量回答回填为新 wiki 页，实现探索复利。

#### Scenario: 好答案回填
- **WHEN** LLM 完成一个综合了 3+ wiki 页的 Query 回答，且回答产生了新对比表/新连接/新分析框架
- **THEN** LLM MUST 主动询问用户是否回填为 `summary` 或 `original` 页
- **AND** 用户同意后，按对应 type 模板建页，frontmatter `sources` 列出综合时读取的 wiki 页（用 `[[xxx]]`）
- **AND** 在 `log.md` 追加 `query-fileback` 操作记录

#### Scenario: 不强制回填
- **WHEN** 回答仅复述单页内容或未产生新综合
- **THEN** LLM MUST NOT 主动建议回填（避免噪音）

### Requirement: lint 机器化检查增强
`scripts/wiki-lint.sh` SHALL 新增 8 项检查并修复 3 个 bug，使机器化体检覆盖全部 Schema 不可变规则。

#### Scenario: 入链按唯一源页计数
- **WHEN** 同一源页多次 `[[link]]` 指向同一目标
- **THEN** 入链数 MUST 只 +1（按源页去重）
- **AND** 反向链接矩阵输出的入链数与 index.md 快速入口数据一致

#### Scenario: 文件名 kebab-case 校验
- **WHEN** wiki/ 下存在非 kebab-case 文件名（如含空格/大写/中文）
- **THEN** lint MUST 报错

#### Scenario: updated 与时间线一致性机器校验
- **WHEN** 运行 lint
- **THEN** MUST 检查「最近一次 ingest（从 log.md 取）声明触达的页，是否 updated=该次日期 + 时间线末条日期=该次日期」
- **AND** MUST 检查「每个 raw 文件是否至少被一个 wiki 页 sources 引用」

### Requirement: index.md Dataview 自动化
index.md 的「最近更新」「标签索引」「domain×type 分组」三段 SHALL 改为 Dataview 查询块，由 Obsidian 实时渲染，消除手维护错误。

#### Scenario: Dataview 渲染动态列表
- **WHEN** 用户在 Obsidian 打开 index.md
- **THEN** 三段由 Dataview 查询 frontmatter（type/domain/tags/updated）实时渲染
- **AND** LLM 不再手维护这三段（仅维护快速入口与主题 MOC）

### Requirement: lint 报告分离
系统 SHALL 将 lint 详细报告与 log.md 分离，避免日志膨胀。

#### Scenario: 详细报告写 reports/
- **WHEN** lint 执行（含 Schedule 自动触发）
- **THEN** log.md 只记一行摘要（日期 + 错误/警告数 + 详见 reports/lint-YYYY-MM-DD.md）
- **AND** 详细报告（含反向链接矩阵）写到 `reports/lint-YYYY-MM-DD.md`

## MODIFIED Requirements

### Requirement: §3 frontmatter `updated` 语义
`updated` 字段 SHALL 表示「该页编译真相区最后一次重写的日期」，NOT lint 触达日期、NOT index.md 刷新日期。

#### Scenario: lint 不刷 updated
- **WHEN** lint 仅修复交叉引用或刷新 index.md，未重写某页编译真相区
- **THEN** 该页 `updated` MUST NOT 改变

#### Scenario: ingest 重写刷 updated
- **WHEN** ingest 重写某页编译真相区
- **THEN** `updated` MUST 刷新为当日 + 时间线追加条目

### Requirement: §4.0 MECE 单源综述边界
§4.0 决策树 SHALL 增加边界规则：单源但采用综述形态（背景/论点/对比表/开放问题结构）→ `summary`；单源且为提炼笔记形态（核心要点/关键引文/延伸问题）→ `source-note`。区分靠正文结构而非源数量。

### Requirement: §9.1 ingest 自检第 9 项
ingest 完成前 MUST 自检 9 项（原 8 项 + 新增第 9 项）：「本次 ingest 的 raw 文件本身已有对应 media/source-note 页（若否，补建）」。

### Requirement: §11 log.md 操作类型与格式
- 操作类型枚举 SHALL 为 6 种：`ingest` / `query` / `lint` / `manual-edit` / `schema-update` / `query-fileback`。
- 日志 MUST 严格正序（旧在上、新在下追加），不得时序颠倒。
- 大小写统一为小写 `schema-update`。
- 【P2】格式可优化为 `## [YYYY-MM-DD HH:MM] type | 简述` 以提升 grep 友好度。

### Requirement: §14 机器化维护增补
§14 SHALL 增补三小节：
1. **git 工作流**：每次 ingest/lint 后建议 conventional commit，用户确认。
2. **规模化搜索阈值**：知识页 >100 且 Query 漏页时引入 qmd/BM25。
3. **entity 主动检测**：ingest 步骤 3 后，高频出现的人/组织/产品无 entity 页时主动询问是否补建。

### Requirement: 3 个 skill 瘦壳化
`skills/llm-wiki-{ingest,query,lint}/SKILL.md` SHALL 删除与 AGENTS.md 重复的通用规则（双区结构/矛盾处理/命名约定/交叉引用/引文格式），只保留：触发条件 + 权威依据章节引用 + 该操作特有的注意事项。通用规则一律靠 `**权威依据**：AGENTS.md §X` 引用，避免双处维护不同步。

### Requirement: rag-vs-llm-wiki.md 矛盾处理论断
`wiki/rag-vs-llm-wiki.md` 对比表「矛盾处理」行 SHALL 更新为双区版机制描述（时间线追加修正条目 + 编译真相重写 + callout 仅临时），删除旧版「callout 标记并保留旧结论」表述。

### Requirement: 3 个 entity 页双区结构
`andrej-karpathy.md`、`quanqiu-dou-zhidao.md`、`secret-fpv-pilot.md` 的 `## 关联实体` 段 SHALL 移至 `## 时间线` 之上，符合 §4.2 entity 模板（关联实体属编译真相区）。

### Requirement: log.md 时序与枚举修复
log.md 现有条目 SHALL 重排为严格正序（17:27 lint 移到 17:35 ingest 之前；07:33 lint 移到 15:10 manual-edit 之前）；头部操作类型枚举补 `schema-update`；正文 `Schema-update` 统一为 `schema-update`。

## REMOVED Requirements
无。本 spec 为增量优化，不移除任何现有需求。
