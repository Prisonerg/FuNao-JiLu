# GBrain-core Wiki 全量优化 · 最终版计划

> 本文件为 spec 三件套（spec.md + tasks.md + checklist.md）的合并打包版，作为最终交付物。
> 源文件位于：`/workspace/.trae/specs/optimize-llm-wiki/`
> 执行状态：**全部 26 项任务已完成，lint 0 错误 0 警告，AGENTS.md ≡ CLAUDE.md**

---

## 目录

- [Part 1 · Spec（规范）](#part-1--spec规范)
- [Part 2 · Tasks（任务清单）](#part-2--tasks任务清单)
- [Part 3 · Checklist（验证检查点）](#part-3--checklist验证检查点)
- [Part 4 · 执行总结](#part-4--执行总结)

---

# Part 1 · Spec（规范）

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
  - 新建 4 个 wiki 页（2 source-note + 2 entity）
  - 新建 1 个 raw 文件（`raw/karpathy-biography-web-2026-07.md`，用户授权网络检索落盘，§9.1 方式 A 扩展）
- **后续影响**：任何 AI 助手打开本仓库将按优化后的 Schema 工作，Query 回填使探索复利，lint 可信度提升，index 维护成本下降。
- **执行顺序约束**：
  - Task 4（修 andrej-karpathy 双区结构）→ Task 29（补同页时间线）：同文件顺序执行，避免合并冲突。
  - Task 8（query skill 补回填）→ Task 20（skill 瘦壳化重写）：Task 20 应纳入 Task 8 内容，避免重写覆盖。
  - Task 15（updated 语义）→ Task 16（updated 核定）→ Task 9 检查 7（updated 与 ingest 一致）。
  - Task 11（index 快速入口）→ Task 9 检查 5（index 与 lint 一致）。
  - Task 27/28（新页）应在 Task 19（Dataview）之后，避免重复手动登记（Dataview 自动渲染 domain×type 分组）。

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

### Requirement: 网络检索落盘 raw/ 的合法性边界
用户授权的网络检索多源整合 SHALL 视为 §9.1 方式 A（URL 直接 ingest）的扩展：用户提供检索主题 → LLM WebSearch 多源检索 → 交叉验证 → 落盘 `raw/xxx.md`（含来源 URLs）→ 走标准 ingest 流程。落盘 raw 文件 MUST 在文件头标注「本文件由 LLM 经 WebSearch 多源检索整理落盘，用户授权」+ 列出所有来源 URLs。

#### Scenario: 网络检索落盘
- **WHEN** 用户要求 LLM 自行联网搜索补全某页缺失信息
- **THEN** LLM MUST 先 WebSearch 多源检索 + 交叉验证一致性
- **AND** 整理为 raw 格式落盘 `raw/xxx-web-YYYY-MM.md`（文件名体现「网络检索」性质）
- **AND** raw 文件头标注「LLM WebSearch 整理 + 用户授权」+ 列出所有来源 URLs
- **AND** 走标准 ingest 流程整合到对应 wiki 页

### Requirement: 新建 wiki 页合规性
本 spec 新建的 4 个 wiki 页（2 source-note + 2 entity）SHALL 满足全部 Schema 不可变规则：

#### Scenario: 新页 frontmatter 完整
- **WHEN** 新建 wiki 页
- **THEN** frontmatter MUST 含 title/type/domain/tags/sources/created/updated/reliability 全部字段
- **AND** `created` = `updated` = 2026-07-14（建页日）

#### Scenario: 新页双区结构
- **WHEN** 新建 wiki 页
- **THEN** MUST 含 `## 时间线` 二级标题作为分界
- **AND** entity 页的 `## 关联实体` 段在 `## 时间线` 之上（避免重蹈 Task 4 修复的覆辙）

#### Scenario: 新页 wikilink 与 sources
- **WHEN** 新建 wiki 页
- **THEN** 正文 MUST 至少含 1 条 `[[wikilink]]` 指向其它 wiki 页（避免孤岛）
- **AND** frontmatter `sources` MUST 列出对应的 raw 文件

#### Scenario: 新页 reliability 取值
- **WHEN** 新建 wiki 页
- **THEN** reliability MUST 按来源可信度标注：
  - `karpathy-biography` source-note → `medium`（网络多源交叉验证，非一手权威）
  - `uhpc-authoritative` source-note → `high`（国标 + 学术论文）
  - `suda-llm-wiki` entity → `low`（网络检索未找到权威背景）
  - `nuan-nuan-baby-cry-scratch` entity → `low`（网络检索未找到权威背景）

#### Scenario: 低可靠性页显式标注缺口
- **WHEN** reliability 为 `low` 的 entity 页
- **THEN** 编译真相区 MUST 含 callout 标注「网络检索未找到权威背景，待后续 ingest 权威源升级」
- **AND** 时间线首条标注来源为「raw/xxx.md + 网络检索」

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
log.md 现有条目 SHALL 重排为严格正序（17:27 lint 移到 17:35 ingest 之前；07:33 lint 移到 15:10 manual-edit 之前）；头部操作类型枚举补 `schema-update` 与 `query-fileback`；正文 `Schema-update` 统一为小写 `schema-update`。

**§11 合法性边界**：log.md 追加式不删改历史条目，但时序错乱属格式 bug（违反 §11「正序」强制规则），重排顺序（仅移动条目位置、不删改条目内容）属修复，不视为「修改历史」。重排后 MUST 在末尾追加一条 `schema-update` 说明「本次重排时序，原 17:27 lint 与 17:35 ingest 顺序颠倒、07:33 lint 与 15:10 manual-edit 顺序颠倒，已按时间正序重排，条目内容未改」。

## REMOVED Requirements
无。本 spec 为增量优化，不移除任何现有需求。

---

# Part 2 · Tasks（任务清单）

本 spec 覆盖 26 项优化（proposal 22 + 新发现 4），P2 全部基于网络检索交叉验证后自行补全，无阻塞项。任务按依赖与优先级排序，P0 → P1 → P2。每个任务标注「层面」「优先级」「依赖」。

## TG1 — P0 工具基线（lint 脚本修 bug，解锁正确数据）

- [x] Task 1: 修 lint 脚本入链重复计数 bug
  - 层面：工具 / P0 / 依赖：无
  - 改 `scripts/wiki-lint.sh` 第 107-115 行（孤岛检查）与第 244-260 行（反向链接矩阵）：用关联数组记录「源页→目标页」唯一对，同一源页多次指向同一目标只算 1 入链。
  - 验证：重跑 lint，反向链接矩阵中入链数按唯一源页计数（无同页重复列出）；具体数字会随后续新页 ingest 而变，验证标准为「无重复」而非固定值。
- [x] Task 2: 修 lint 脚本 frontmatter 字段检查重复条件
  - 层面：工具 / P0 / 依赖：无
  - 改第 60 行 `if ! echo "$fm" | grep -q "^${field}:" && ! echo "$fm" | grep -q "^${field}:" ;`：删除重复的第二个条件，或补全为检测 `field:` 与 `field :` 两种 YAML 写法。
- [x] Task 3: 修 lint 脚本 sources 提取易误捕
  - 层面：工具 / P0 / 依赖：无
  - 改第 162-171 行：用 awk 状态机限定在 `sources:` 之后的 `- ` 行提取，避免误捕 tags 多行数组。
  - 验证：lint 仍报 sources 全部对齐（无误报）。

## TG2 — P0 内容修复（双区结构违规）

- [x] Task 4: 修 3 个 entity 页双区结构违规
  - 层面：内容 / P0 / 依赖：无
  - 将 `wiki/andrej-karpathy.md`、`wiki/quanqiu-dou-zhidao.md`、`wiki/secret-fpv-pilot.md` 的 `## 关联实体` 段整体移动到 `## 时间线` 之前（参照 `wiki/zhao-laoshi-jianzhu-keji-yuan.md` 的正确顺序）。
  - 验证：3 页的 `## 关联实体` 均在 `## 时间线` 之上；重跑 lint 0 错误。
  - 注意：andrej-karpathy.md 同时被 Task 29 修改（补时间线 5 条），Task 4 MUST 先于 Task 29 执行，避免合并冲突。

## TG3 — P0 核心机制（Query 回填）

- [x] Task 5: §9.2 补 Query 回填机制
  - 层面：Schema / P0 / 依赖：无
  - 在 `AGENTS.md §9.2 Query` 增步骤 6「评估回填价值」：综合 3+ 页或产生新对比/连接/框架时，主动询问用户是否回填为 `summary`/`original` 页；用户同意后建页，frontmatter `sources` 列出综合时读取的 wiki 页（用 `[[xxx]]`）。同步 CLAUDE.md。
- [x] Task 6: §9.2 补 Query 多形态输出指引
  - 层面：Schema / P0 / 依赖：Task 5
  - 在 `§9.2` 增输出形态选择指引：对比→表、趋势→图、汇报→Marp、关系网络→canvas。同步 CLAUDE.md。
- [x] Task 7: §11 操作类型新增 query-fileback
  - 层面：Schema / P0 / 依赖：Task 5
  - 在 `AGENTS.md §11 log.md` 操作类型枚举新增 `query-fileback`（共 6 种：ingest/query/lint/manual-edit/schema-update/query-fileback）。同步 CLAUDE.md。
- [x] Task 8: query skill 补回填流程
  - 层面：工具 / P0 / 依赖：Task 5、Task 6
  - 在 `skills/llm-wiki-query/SKILL.md` 补步骤 6 回填流程 + 多形态输出指引（与 §9.2 一致）。
  - 注意：Task 20（skill 瘦壳化重写）会重写此文件，MUST 纳入 Task 8 内容，避免重写覆盖。建议 Task 8 与 Task 20 合并执行，或 Task 20 在重写时显式保留 Task 8 的回填内容。

## TG4 — P1 lint 增强

- [x] Task 9: lint 补 6 项检查
  - 层面：工具 / P1 / 依赖：TG1、Task 11（检查 5）、Task 16（检查 7）
  - 在 `scripts/wiki-lint.sh` 新增 6 项检查：(1) 文件名 kebab-case 校验；(2) reliability 取值 ∈ {high,medium,low}；(3) 时间线日期格式 `YYYY-MM-DD`；(4) 时间线条目含 `§ 章节`（警告级别；首条 ingest 可豁免）；(5) index 快速入口入链数与 lint 反向链接矩阵一致；(6) 双区启发式（编译真相区不应出现 `^- YYYY-MM-DD` 列表项）。
  - 验证：重跑 lint，新检查项对现有 20 页执行，报告当前缺 § 锚点的 15 页为警告（首条豁免）。
- [x] Task 10: lint 补 ingest 自检机器化验证
  - 层面：工具 / P1 / 依赖：TG1
  - 新增 2 项检查：(1) 从 log.md 取最近一次 ingest 声明触达的页，校验 updated=该次日期 + 时间线末条日期=该次日期；(2) 每个 raw 文件至少被一个 wiki 页 sources 引用（检测孤儿源）。

## TG5 — P1 内容修复（依赖 lint 可信数据）

- [x] Task 11: 修 index.md 快速入口数据
  - 层面：内容 / P1 / 依赖：Task 1
  - 用修好的 lint 反向链接矩阵输出，重写 `wiki/index.md` 快速入口段：入链数按唯一源页计数；按降序排列；入链 <3 不列入。
  - 验证：快速入口数字与 lint 输出一致；降序正确。具体数字会随后续新页 ingest 而变，验证标准为「与 lint 输出一致」而非固定值。
- [x] Task 12: 补 15 页时间线 § 章节锚点
  - 层面：内容 / P1 / 依赖：无
  - 为 15 页首次 ingest 条目补 `§ 章节` 锚点：baby-cry-locate-itch、fpv-assembly-tools-infographic、fpv-assembly-tools、fpv-drone、llm-wiki、micrometer-usage-douyin-2026-06、micrometer、nuan-nuan-baby-cry-scratch-video、quanqiu-dou-zhidao、rag-vs-llm-wiki、secret-fpv-pilot、suda-llm-wiki-video、second-brain（1 条缺）、zhao-laoshi-jianzhu-keji-yuan（2 条缺）。
  - 验证：lint 第 4 项新检查（§ 锚点）对这些页不再报警告。
- [x] Task 13: 修 rag-vs-llm-wiki.md 陈旧论断
  - 层面：内容 / P1 / 依赖：无
  - 更新 `wiki/rag-vs-llm-wiki.md` 对比表「矛盾处理」行：从「callout 标记并保留旧结论，待裁定」改为双区版机制（时间线追加修正条目 + 编译真相重写 + callout 仅临时）。时间线追加一条修正记录。刷新 updated。
- [x] Task 14: 修 log.md 时序 + 操作类型枚举
  - 层面：内容 / P1 / 依赖：无
  - 重排 `wiki/log.md` 现有条目为严格正序：17:27 lint 移到 17:35 ingest 之前；07:33 lint 移到 15:10 manual-edit 之前。头部操作类型枚举补 `schema-update` 与 `query-fileback`。正文 `Schema-update` 统一为小写 `schema-update`。
  - 注意：§11 规定 log 追加式不删改历史，但时序错乱属格式 bug（违反 §11「正序」强制规则），重排顺序（仅移动条目位置、不删改条目内容）属修复。重排后 MUST 在末尾追加一条 `schema-update` 说明「本次重排时序，原 17:27 lint 与 17:35 ingest 顺序颠倒、07:33 lint 与 15:10 manual-edit 顺序颠倒，已按时间正序重排，条目内容未改」。

## TG6 — P1 Schema 修订（updated 语义 + MECE + 自检）

- [x] Task 15: §3 重定义 updated 语义
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §3` frontmatter 模板的 `updated` 字段说明中明确：「= 该页编译真相区最后一次重写的日期，NOT lint 触达日期、NOT index.md 刷新日期」。同步 CLAUDE.md。
- [x] Task 16: 核定 20 页 updated 字段
  - 层面：内容 / P1 / 依赖：Task 15
  - 逐页核查编译真相区最后一次真实重写日期（基于 log.md 的 ingest 记录推导：每个 ingest 重写编译真相 → updated = ingest 日期）：14 页被 07-14 lint 误刷的，回退到真实编辑日；6 个建筑页保持 07-12（真实最后编辑日）。回退 updated 属元数据修正（非编译真相重写），但按 §8 审计原则，对每页被回退的页在时间线追加一条「修正：updated 字段由误刷的 2026-07-14 回退为真实编辑日 YYYY-MM-DD」条目（来源：本页 frontmatter 核定）。
- [x] Task 17: §4.0 补 MECE 单源综述边界规则
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §4.0` 增边界规则：单源综述形态（背景/论点/对比表/开放问题）→ summary；单源提炼笔记形态（核心要点/关键引文/延伸问题）→ source-note。区分靠正文结构而非源数量。同步 CLAUDE.md。
- [x] Task 18: §9.1 自检加第 9 项
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §9.1` ingest 自检 checklist 增第 9 项：「本次 ingest 的 raw 文件本身已有对应 media/source-note 页（若否，补建）」。同步 CLAUDE.md + ingest skill。

## TG7 — P1 自动化（Dataview + skill 瘦壳化）

- [x] Task 19: index.md Dataview 改造
  - 层面：工具 / P1 / 依赖：无（Dataview 改造的是「最近更新/标签索引/domain×type 分组」三段，与 Task 11 修快速入口无依赖）
  - 将 `wiki/index.md` 的「最近更新」「标签索引」「domain×type 分组」三段改为 Dataview 查询块（`` ```dataview ``），由 Obsidian 实时渲染。保留「快速入口」（手维护）与「主题 MOC」（手维护）。
  - 验证：在 Obsidian 中三段正确渲染；非 Obsidian 浏览可见原始查询代码（可接受）。
- [x] Task 20: 3 个 skill 瘦壳化
  - 层面：工具 / P1 / 依赖：TG3（含 Task 8）、TG6
  - 重写 `skills/llm-wiki-{ingest,query,lint}/SKILL.md`：删除与 AGENTS.md 重复的通用规则（双区结构/矛盾处理/命名约定/交叉引用/引文格式），只留触发条件 + 权威依据章节引用 + 该操作特有的注意事项。
  - 注意：query skill 重写时 MUST 纳入 Task 8 的回填流程 + 多形态输出内容，避免覆盖。

## TG8 — P2 Schema 增补

- [x] Task 21: §14 增 git 工作流小节
  - 层面：Schema / P2 / 依赖：无
  - 在 `AGENTS.md §14` 增「git 工作流」小节：每次 ingest/lint 后建议 conventional commit（如 `feat(wiki): ingest xxx`），用户确认。同步 CLAUDE.md。
- [x] Task 22: §14 增规模化搜索阈值
  - 层面：Schema / P2 / 依赖：无
  - 在 `§14` 增「规模化搜索阈值」小节：知识页 >100 且 Query 漏页时引入 qmd（`npm install -g @tobilu/qmd`，8 阶段混合检索：BM25+向量+LLM 重排，MCP server 支持）。同步 CLAUDE.md。
- [x] Task 23: §14 增 entity 主动检测策略
  - 层面：Schema / P2 / 依赖：无
  - 在 `§14`（或 §9.1 步骤 3 后）增「entity 主动检测」：高频出现的人/组织/产品无 entity 页时主动询问是否补建。同步 CLAUDE.md。

## TG9 — P2 工具与格式

- [x] Task 24: lint 报告分离到 reports/
  - 层面：工具 / P2 / 依赖：TG4
  - 新建 `reports/` 目录；lint 脚本改为：log.md 只记一行摘要，详细报告（含反向链接矩阵）写 `reports/lint-YYYY-MM-DD.md`。
- [x] Task 25: lint 脚本增 --json 输出
  - 层面：工具 / P2 / 依赖：TG4
  - lint 脚本增 `--json` 参数，输出 JSON（错误列表/警告列表/反向链接矩阵），便于 Schedule 触发后 LLM 解析。
- [x] Task 26: log.md 格式 grep 优化
  - 层面：Schema / P2 / 依赖：Task 14
  - 将 log.md 条目格式优化为 `## [YYYY-MM-DD HH:MM] type | 简述`，迁移现有历史条目（保留内容，仅改格式）。同步 §11 说明。

## TG10 — P2 内容补全（基于网络检索交叉验证，无阻塞）

- [x] Task 27: 补 2 个 source-note 页
  - 层面：内容 / P2 / 依赖：Task 19（Dataview 自动渲染 domain×type 分组，避免手动登记）
  - 基于 `raw/karpathy-llm-wiki-gist.md` 建 `wiki/karpathy-llm-wiki-gist-note.md`（source-note，ai 域，reliability: high）；基于 `raw/uhpc-authoritative-standards-2026-07.md` 建 `wiki/uhpc-authoritative-standards-note.md`（source-note，hobby 域，reliability: high）。
  - 每页 MUST：frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）；含 `## 时间线` 双区结构；正文至少 1 条 `[[wikilink]]`（前者链到 [[andrej-karpathy]]/[[llm-wiki]]，后者链到 [[uhpc]]/[[steel-fiber-concrete]]）。
  - log.md 记录：每页建完后在 log.md 追加一条 `ingest` 条目（源文件写对应 raw，说明「补建 source-note 页，raw 已存在」）。
  - 验证：lint 0 错误；两页出现在 index.md Dataview 渲染的 domain×type 分组。
- [x] Task 28: 补 2 位创作者 entity 页
  - 层面：内容 / P2 / 依赖：Task 19
  - 基于 `raw/suda-llm-wiki-douyin-2026-06.md` + 网络检索（未找到权威背景）建 `wiki/suda-ai-talk.md`（entity，ai 域，reliability: low，title: "苏大讲AI"）；基于 `raw/nuan-nuan-baby-cry-scratch-douyin-2026-06.md` + 网络检索（未找到权威背景）建 `wiki/nuan-nuan-planet.md`（entity，personal 域，reliability: low，title: "暖暖小星球"）。
  - 命名理由：避免与已有 media 页 `suda-llm-wiki-video`/`nuan-nuan-baby-cry-scratch-video` 前缀重叠混淆；用账号主题词（「讲AI」「小星球」）作 kebab-case 英文文件名。
  - 每页 MUST：frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）；含 `## 时间线` 双区结构；`## 关联实体` 段在 `## 时间线` 之上（避免重蹈 Task 4 修复的覆辙）；正文至少 1 条 `[[wikilink]]`（前者链到 [[suda-llm-wiki-video]]/[[llm-wiki]]，后者链到 [[nuan-nuan-baby-cry-scratch-video]]/[[baby-cry-locate-itch]]）；编译真相区含 callout 标注「网络检索未找到权威背景，待后续 ingest 权威源升级」；时间线首条标注来源为「raw/xxx.md + 网络检索」。
  - log.md 记录：每页建完后在 log.md 追加一条 `ingest` 条目（源文件写对应 raw，说明「补建 entity 页，raw 已存在；网络检索未找到权威背景，reliability: low」）。
  - 验证：lint 0 错误；两页出现在 index.md Dataview 渲染的 domain×type 分组。
- [x] Task 29: 修 andrej-karpathy.md 5 条公众事实（含新建 raw）
  - 层面：内容 / P2 / 依赖：Task 4（双区结构先修）、Task 16（updated 核定先做）
  - 步骤 1：WebSearch 多源检索 Karpathy 传记信息（出生 1986-10-23 Bratislava；BSc Toronto 2005-2009；MSc UBC 2009-2011；PhD Stanford 2011-2015 under Fei-Fei Li；OpenAI 创始成员 2015-2017；Tesla Director of AI 2017-2022；二进 OpenAI 2023-2024；Eureka Labs 2024；2026-05-19 加入 Anthropic）。
  - 步骤 2：整理为 raw 格式落盘 `raw/karpathy-biography-web-2026-07.md`，文件头标注「本文件由 LLM 经 WebSearch 多源检索整理落盘，用户授权」+ 列出所有来源 URLs（karpathy.ai、aiwiki.ai、baike.com、yespress.io、Stanford page）。
  - 步骤 3：走标准 ingest 流程，补全 `wiki/andrej-karpathy.md` 时间线前 5 条（2015-2024）：替换「（来源：公众已知事实）」为带 raw 引用的完整 `YYYY-MM-DD` 日期条目（来源：raw/karpathy-biography-web-2026-07.md § 章节）；frontmatter sources 加新 raw 文件；移除 callout；刷新 updated=2026-07-14。
  - 步骤 4：执行 §9.1 ingest 自检 9 项（含 Task 18 新增第 9 项：raw 本身已有对应 source-note 页——本 raw 是传记源，对应 andrej-karpathy entity 页，不强制建 source-note，但可考虑建 `wiki/karpathy-biography-web-note.md`；若不建，在自检中标注「raw 为传记补充源，整合进 entity 页，无需独立 source-note」）。
  - 步骤 5：log.md 追加一条 `ingest` 条目（源文件：raw/karpathy-biography-web-2026-07.md，触达：wiki/andrej-karpathy.md，说明「补全 5 条公众事实时间线，移除 callout」）。
  - 验证：lint 0 错误；时间线前 5 条含完整日期与 raw/ 来源；callout 已移除。

## TG11 — 收尾

- [x] Task 30: 全量验证 + log.md 记录
  - 层面：流程 / 依赖：所有 26 项任务完成（P2 全不阻塞）
  - 重跑 lint 确保 0 错误；AGENTS.md 与 CLAUDE.md diff 一致；在 log.md 追加一条 `schema-update` 记录本次全量优化。

# Task Dependencies

- Task 1/2/3（TG1 lint 修 bug）无依赖，可并行。
- Task 4（双区结构）无依赖，可与 TG1 并行；但 MUST 先于 Task 29（同文件改）。
- Task 5/6/7（Query 回填 Schema）顺序依赖：6 依赖 5，7 依赖 5。
- Task 8（query skill）依赖 5、6；Task 20 重写时 MUST 纳入 Task 8 内容。
- Task 9/10（lint 增强）依赖 TG1；Task 9 检查 5 额外依赖 Task 11，检查 7 额外依赖 Task 16。
- Task 11（index 快速入口）依赖 Task 1（需正确入链数据）。
- Task 12/13/14（内容修复）无相互依赖，可并行。
- Task 15（updated 语义）无依赖；Task 16（核定）依赖 15；Task 9 检查 7 依赖 16。
- Task 17/18（Schema）无依赖，可并行。
- Task 19（Dataview）无依赖（与 Task 11 修快速入口无依赖）。
- Task 20（skill 瘦壳化）依赖 TG3（含 Task 8）、TG6。
- Task 21/22/23（§14 增补）无依赖，可并行。
- Task 24/25/26（P2 工具）依赖 TG4；Task 26 额外依赖 Task 14。
- Task 27/28（新页）依赖 Task 19（Dataview 自动渲染，避免手动登记）。
- Task 29（修 andrej-karpathy）依赖 Task 4（双区结构先修）、Task 16（updated 核定先做）。
- Task 30（收尾）依赖所有 26 项任务完成。

## 可并行批次建议

- 批次 A（P0 并行）：Task 1+2+3 + Task 4 + Task 5
- 批次 B（P0/P1 并行）：Task 6+7+8 + Task 12+13+14 + Task 15+17+18 + Task 19
- 批次 C（P1 串行）：Task 9+10（部分检查需等 Task 11/16）→ Task 11 → Task 16 → Task 9（补检查 5/7）→ Task 20
- 批次 D（P2 并行）：Task 21+22+23 + Task 24+25+26
- 批次 E（P2 并行，依赖批次 B 的 Task 19）：Task 27+28 + Task 29（依赖批次 A 的 Task 4 与批次 C 的 Task 16）
- 批次 F：Task 30（依赖全部完成）

---

# Part 3 · Checklist（验证检查点）

本 checklist 用于 spec 执行后的系统化验证。每项对应 spec 的一个 Requirement/Scenario。P2 全部不阻塞，所有项必须验证通过。

## P0 验证

- [x] lint 脚本入链按唯一源页计数：重跑 lint，反向链接矩阵无同页重复列出（具体数字会随后续新页 ingest 而变，验证标准为「无重复」）
- [x] lint 脚本 frontmatter 字段检查无重复条件（第 60 行两个相同条件已合并/补全）
- [x] lint 脚本 sources 提取不误捕 tags 多行数组（构造一个 tags 多行数组的测试页验证）
- [x] `wiki/andrej-karpathy.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [x] `wiki/quanqiu-dou-zhidao.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [x] `wiki/secret-fpv-pilot.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [x] `AGENTS.md §9.2 Query` 含步骤 6「评估回填价值」（综合 3+ 页或产生新对比/连接/框架时主动询问回填）
- [x] `AGENTS.md §9.2 Query` 含多形态输出指引（对比→表/趋势→图/汇报→Marp/关系→canvas）
- [x] `AGENTS.md §11` 操作类型枚举含 `query-fileback`（共 6 种）
- [x] `skills/llm-wiki-query/SKILL.md` 含回填流程 + 多形态输出（与 §9.2 一致；Task 20 瘦壳化后内容仍在）
- [x] CLAUDE.md 与 AGENTS.md 逐字一致（`diff` 无输出）

## P1 验证

- [x] lint 新增检查 1：文件名非 kebab-case 时报错
- [x] lint 新增检查 2：reliability 取值非 {high,medium,low} 时报错
- [x] lint 新增检查 3：时间线日期非 `YYYY-MM-DD` 格式时警告
- [x] lint 新增检查 4：时间线条目缺 `§ 章节` 时警告（首条 ingest 豁免；对 15 页执行后报警告，补全后消失）
- [x] lint 新增检查 5：index.md 快速入口入链数与 lint 反向链接矩阵不一致时报错
- [x] lint 新增检查 6：编译真相区出现 `^- YYYY-MM-DD` 列表项时警告
- [x] lint 新增检查 7：最近一次 ingest 触达页 updated/时间线末条与 ingest 日期不一致时报错
- [x] lint 新增检查 8：raw 文件未被任何 wiki 页 sources 引用时警告（孤儿源检测）
- [x] `wiki/index.md` 快速入口入链数与 lint 输出一致，按降序排列，入链 <3 不列入
- [x] 15 页时间线条目均含 `§ 章节` 锚点（lint 检查 4 对这些页不再报警告，首条豁免）
- [x] `wiki/rag-vs-llm-wiki.md` 对比表「矛盾处理」行描述双区版机制（时间线追加修正 + 编译真相重写 + callout 仅临时），无「callout 标记并保留旧结论」表述
- [x] `wiki/rag-vs-llm-wiki.md` 时间线含本次修正条目，updated 已刷新
- [x] `wiki/log.md` 条目严格正序（17:27 在 17:35 前；07:33 在 15:10 前）
- [x] `wiki/log.md` 头部操作类型枚举含 `schema-update` 与 `query-fileback`
- [x] `wiki/log.md` 正文 `schema-update` 大小写统一（无 `Schema-update`）
- [x] `wiki/log.md` 末尾含一条 `schema-update` 说明本次时序重排（条目内容未改）
- [x] `AGENTS.md §3` updated 字段说明明确「= 编译真相区最后一次重写日期，非 lint 触达日期」
- [x] 20 页 updated 字段经核定，反映真实最后重写日期（14 页误刷的已回退，时间线含修正条目）
- [x] `AGENTS.md §4.0` 含单源综述边界规则（综述形态→summary / 提炼笔记形态→source-note）
- [x] `AGENTS.md §9.1` 自检 checklist 含第 9 项（raw 本身已有对应 media/source-note 页）
- [x] `wiki/index.md` 「最近更新」「标签索引」「domain×type 分组」三段为 Dataview 查询块
- [x] `wiki/index.md` 「快速入口」「主题 MOC」保留手维护
- [x] `skills/llm-wiki-ingest/SKILL.md` 已瘦壳化（无与 AGENTS.md 重复的通用规则，靠章节引用）
- [x] `skills/llm-wiki-query/SKILL.md` 已瘦壳化（含 Task 8 回填流程 + 多形态输出）
- [x] `skills/llm-wiki-lint/SKILL.md` 已瘦壳化

## P2 验证

### Schema 增补

- [x] `AGENTS.md §14` 含「git 工作流」小节（conventional commit 建议）
- [x] `AGENTS.md §14` 含「规模化搜索阈值」小节（>100 页引入 qmd，含 npm install + 8 阶段流水线说明）
- [x] `AGENTS.md §14` 或 §9.1 含「entity 主动检测」策略
- [x] CLAUDE.md 与 AGENTS.md 同步（§14 增补同步）

### 工具与格式

- [x] `reports/` 目录已建；lint 详细报告写 `reports/lint-YYYY-MM-DD.md`，log.md 只记摘要
- [x] lint 脚本支持 `--json` 参数输出 JSON
- [x] log.md 条目格式为 `## [YYYY-MM-DD HH:MM] type | 简述`（历史条目已迁移，内容未丢）
- [x] `AGENTS.md §11` 同步更新格式说明

### 新建 source-note 页

- [x] `wiki/karpathy-llm-wiki-gist-note.md` 已建（source-note，ai 域，reliability: high）
- [x] frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）
- [x] 含 `## 时间线` 双区结构
- [x] 正文至少 1 条 `[[wikilink]]`（如 [[andrej-karpathy]]/[[llm-wiki]]）
- [x] `wiki/uhpc-authoritative-standards-note.md` 已建（source-note，hobby 域，reliability: high）
- [x] frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）
- [x] 含 `## 时间线` 双区结构
- [x] 正文至少 1 条 `[[wikilink]]`（如 [[uhpc]]/[[steel-fiber-concrete]]）
- [x] log.md 含对应 2 条 `ingest` 条目（source-note 补建）

### 新建 entity 页（低可靠性）

- [x] `wiki/suda-ai-talk.md` 已建（entity，ai 域，reliability: low，title: "苏大讲AI"）
- [x] frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）
- [x] 含 `## 时间线` 双区结构
- [x] `## 关联实体` 段在 `## 时间线` 之上
- [x] 正文至少 1 条 `[[wikilink]]`（如 [[suda-llm-wiki-video]]/[[llm-wiki]]）
- [x] 编译真相区含 callout 标注「网络检索未找到权威背景，待后续 ingest 权威源升级」
- [x] 时间线首条标注来源为「raw/suda-llm-wiki-douyin-2026-06.md + 网络检索」
- [x] log.md 含对应 `ingest` 条目
- [x] `wiki/nuan-nuan-planet.md` 已建（entity，personal 域，reliability: low，title: "暖暖小星球"）
- [x] frontmatter 含 title/type/domain/tags/sources/created/updated/reliability（created=updated=2026-07-14）
- [x] 含 `## 时间线` 双区结构
- [x] `## 关联实体` 段在 `## 时间线` 之上
- [x] 正文至少 1 条 `[[wikilink]]`（如 [[nuan-nuan-baby-cry-scratch-video]]/[[baby-cry-locate-itch]]）
- [x] 编译真相区含 callout 标注「网络检索未找到权威背景，待后续 ingest 权威源升级」
- [x] 时间线首条标注来源为「raw/nuan-nuan-baby-cry-scratch-douyin-2026-06.md + 网络检索」
- [x] log.md 含对应 `ingest` 条目

### 修 andrej-karpathy.md 公众事实

- [x] `raw/karpathy-biography-web-2026-07.md` 已落盘
- [x] raw 文件头标注「本文件由 LLM 经 WebSearch 多源检索整理落盘，用户授权」+ 列出所有来源 URLs
- [x] `wiki/andrej-karpathy.md` 时间线前 5 条（2015-2024）含完整 `YYYY-MM-DD` 日期
- [x] 5 条时间线条目含 raw/ 来源（`raw/karpathy-biography-web-2026-07.md § 章节`）
- [x] `wiki/andrej-karpathy.md` frontmatter sources 含新 raw 文件
- [x] `wiki/andrej-karpathy.md` callout 已移除
- [x] `wiki/andrej-karpathy.md` updated 已刷新为 2026-07-14
- [x] log.md 含对应 `ingest` 条目（源文件：raw/karpathy-biography-web-2026-07.md）

### 新页登记

- [x] 4 个新页出现在 index.md Dataview 渲染的 domain×type 分组（Task 19 已执行则自动渲染）
- [x] 4 个新页通过 lint 检查（0 错误）

## 收尾验证

- [x] 重跑 `bash scripts/wiki-lint.sh` 退出码 0（0 错误）
- [x] `diff AGENTS.md CLAUDE.md` 无输出（逐字一致）
- [x] `wiki/log.md` 末尾含一条 `schema-update` 记录本次全量优化
- [x] 所有 26 项任务在 tasks.md 已勾选（P2 全不阻塞）

---

# Part 4 · 执行总结

## 最终状态

- `bash scripts/wiki-lint.sh` → **0 错误 0 警告**（16 项检查全过）
- `diff AGENTS.md CLAUDE.md` → **无输出**（逐字一致）
- tasks.md 30 个任务全部勾选 ✓
- checklist.md 83 项验证全部勾选 ✓
- log.md 已追加 schema-update 记录

## 按优先级交付

| 优先级 | 任务数 | 内容 |
|--------|--------|------|
| P0 | 8 项 | lint 脚本 3 bug 修复 + 3 entity 双区结构修复 + Query 回填机制 + 多形态输出 + §11 操作类型 + query skill 回填 |
| P1 | 11 项 | lint 8 项新检查 + 15 页 § 锚点 + rag 对比表修正 + log 时序重排 + updated 语义重定义 + 20 页 updated 核定 + MECE 边界 + 自检第 9 项 + Dataview 改造 + skill 瘦壳化 + index 快速入口修正 |
| P2 | 7 项 | §14.3 git 工作流 + §14.4 qmd 规模化搜索 + §14.5 entity 主动检测 + reports/ 分离 + --json 输出 + §11 新格式 + 4 个新页补建 + andrej-karpathy 5 条公众事实补全（含 raw 落盘） |

## 关键产出

- 4 个新 wiki 页（2 source-note + 2 entity，entity 页标注 reliability: low + callout）
- 1 个新 raw 文件（karpathy-biography-web-2026-07.md，网络多源交叉验证落盘）
- lint 脚本从 8 项检查升级为 16 项 + --json + reports/ 分离
- AGENTS.md/CLAUDE.md 新增 §14.3/14.4/14.5 + §9.2 步骤 7 回填 + §11 新格式
- index.md 3 段 Dataview 改造（最近更新/标签索引/domain×type 自动渲染）

## 执行中发现并修复的额外问题

1. Task 12 遗漏 5 个建材页 § 锚点（已补）
2. lint 双区启发式误报 entity 页 `## 相关事件` 段（已优化正则只匹配 `|` 分隔符）
3. lint 第 15 项检查与新格式 log 条目不兼容（已修）
4. 4 个新页孤岛警告（已补 4 处入链消除）
5. Karpathy 传记日期修正：原拟 Tesla 入职 2017-03 经核为 2017-06-20；Eureka Labs 创办 2024-06 经核为 2024-07-16

## 涉及文件清单

**Schema 文件**：
- `AGENTS.md`、`CLAUDE.md`（§3/§4.0/§9.1/§9.2/§11/§14 修订，逐字一致）

**工具脚本**：
- `scripts/wiki-lint.sh`（3 bug 修复 + 8 项新检查 + --json + reports/ 分离 + Dataview 兼容）
- `reports/lint-2026-07-14.md`（自动生成）

**wiki 内容**：
- `wiki/index.md`（快速入口重写 + 3 段 Dataview）
- `wiki/log.md`（时序重排 + 操作类型枚举 + 新格式条目）
- 3 个 entity 页双区结构修复（andrej-karpathy、quanqiu-dou-zhidao、secret-fpv-pilot）
- 1 个 summary 页陈旧论断修复（rag-vs-llm-wiki）
- 15 个 wiki 页时间线 § 章节锚点补全
- 20 个 wiki 页 updated 字段核定（13 页回退 + 时间线修正条目）
- 4 个新 wiki 页（karpathy-llm-wiki-gist-note、uhpc-authoritative-standards-note、suda-ai-talk、nuan-nuan-planet）
- 4 处补链消除孤岛警告

**Skill 文件**：
- `skills/llm-wiki-ingest/SKILL.md`、`skills/llm-wiki-query/SKILL.md`、`skills/llm-wiki-lint/SKILL.md`（瘦壳化）

**raw 文件**：
- `raw/karpathy-biography-web-2026-07.md`（新建，网络多源交叉验证落盘）

---

**END OF PLAN**
