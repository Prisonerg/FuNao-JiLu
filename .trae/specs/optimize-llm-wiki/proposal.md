# GBrain-core Wiki 优化方案

> 基于 Karpathy LLM Wiki 原版（https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f）与仓库现状的全量对照，覆盖四个层面：① 与 Karpathy 原版对齐 ② Schema/规范层 ③ 内容质量层 ④ 工具/自动化层。
>
> 性质：方案文档，不含执行。所有改动建议标注优先级（P0 立即修 / P1 近期修 / P2 远期优化）与风险（低/中/高）。

---

## 0. 现状速览

| 维度 | 现状 |
|---|---|
| 架构 | 三层（raw / wiki / schema）+ scripts/，已落地 GBrain-core 双区结构 |
| 规模 | 20 个知识页、7 个 raw 源、3 个 skill、1 个 lint 脚本 |
| Schema | AGENTS.md / CLAUDE.md 14 节，已**逐字一致**（diff 验证通过） |
| 机器 lint | 0 错误 / 0 警告（但脚本有 bug，见 §4.1） |
| 内容审计 | 0 critical / 3 major / 7 类 minor（见 §3） |
| Karpathy 对齐 | 核心三层 + 三操作已对齐，但漏掉 3 个关键机制（见 §1） |

**总体判断**：地基扎实，双区结构 + MECE type + 机器化 lint 的框架选型正确。主要问题集中在 ① 漏掉 Karpathy 的「Query 回填」复利机制 ② lint 脚本有计数 bug 污染了 index.md ③ 部分页面双区结构执行不到位 ④ 自动化深度不足（index 手维护、skill 与 Schema 重复）。

---

## 1. 与 Karpathy 原版对齐（Gap 分析）

对照 gist 原文逐条核对，发现 **3 个核心遗漏** + **4 个可选借鉴**。

### 1.1 [P0] 遗漏「Query 回填」复利机制 —— 最严重 gap

**Karpathy 原文**（gist §Operations/Query）：
> "The important insight: **good answers can be filed back into the wiki as new pages.** A comparison you asked for, an analysis, a connection you discovered — these are valuable and shouldn't disappear into chat history. This way your explorations compound in the knowledge base just like ingested sources do."

**本仓库现状**：`AGENTS.md §9.2 Query` 5 步流程止于「引用具体页 + 暴露缺口」，**完全没有**「好答案回填为新页」这一步。`skills/llm-wiki-query/SKILL.md` 同样缺失。`§11 log.md` 的操作类型枚举（ingest/query/lint/manual-edit/schema-update）中 query 仅「留痕」，未定义回填动作。

**影响**：这是 Karpathy 模式的**第二复利引擎**（第一是 ingest）。少了它，用户的探索性提问每次都蒸发，wiki 只靠外部源增长，不靠内部思考增长 —— 违背 "explorations compound" 的核心思想。

**建议**：
- 在 `§9.2 Query` 增加步骤 6：「评估回填价值」：若回答综合了 3+ 页、产生了新对比表/新连接/新分析框架，主动询问用户是否回填为 `summary` 或 `original` 页。
- 在 `§11 log.md` 操作类型中新增 `query-fileback`（或复用 `ingest`，源文件记 `User, Query 派生`）。
- 在 `skills/llm-wiki-query/SKILL.md` 补对应流程。
- 回填页的 `sources` 字段写法：列出综合时读取的 wiki 页（用 `[[xxx]]` 而非 raw 路径），或新增 `derived-from` 字段。

**风险**：低。纯增量，不破坏现有结构。

### 1.2 [P1] 遗漏 Query 多形态输出

**Karpathy 原文**：
> "Answers can take different forms depending on the question — a markdown page, a comparison table, a slide deck (Marp), a chart (matplotlib), a canvas."

**本仓库现状**：`§9.2` 与 query skill 只输出 markdown + 对比表，未提 Marp 幻灯片、matplotlib 图表、canvas 等形态。

**建议**：在 `§9.2` 增加输出形态选择指引（按问题类型选）：对比→表、趋势→图、汇报→Marp、关系网络→canvas。回填时按形态选 `summary` / `original` / media 子类型。优先级 P1（不影响核心闭环，但提升表达力）。

**风险**：低。

### 1.3 [P1] 未利用 Obsidian Dataview —— index.md 维护成本高

**Karpathy 原文**：
> "Dataview is an Obsidian plugin that runs queries over page frontmatter. If your LLM adds YAML frontmatter to wiki pages (tags, dates, source counts), Dataview can generate dynamic tables and lists."

**本仓库现状**：frontmatter 字段完备（title/type/domain/tags/sources/created/updated/reliability），完全满足 Dataview 查询条件。但 `index.md` 五区块（快速入口/最近更新/主题 MOC/标签索引/domain×type 分组）**全靠 LLM 手维护**，已出现计数错、排序错、漏登记等问题。

**建议**：将 `index.md` 的「最近更新」「标签索引」「domain×type 分组」三段改为 Dataview 查询块（`` ```dataview ``），由 Obsidian 实时渲染。LLM 只维护「快速入口」（依赖 lint 反向链接矩阵）和「主题 MOC」（需人工主题判断）。这能消除三类手维护错误。

**风险**：中。需用户在 Obsidian 装 Dataview 插件；非 Obsidian 用户（纯 GitHub 浏览）会看到原始查询代码。可保留双写过渡期。

### 1.4 [P2] log.md 格式可优化 grep 友好度

**Karpathy 原文**：
> "if each entry starts with a consistent prefix (e.g. `## [2026-04-02] ingest | Article Title`), the log becomes parseable with simple unix tools — `grep "^## \[" log.md | tail -5`"

**本仓库现状**：格式 `### YYYY-MM-DD HH:MM - 操作类型`。可 grep 但 `###` 三级标题 + 操作类型在前，不如 `## [date] type | title` 对 `tail`/`awk` 友好（标题信息丢失）。

**建议**：可选优化为 `## [YYYY-MM-DD HH:MM] type | 简述`。优先级 P2（当前格式可用，改造需迁移历史条目）。

### 1.5 [P2] 无 git 工作流说明

**Karpathy 原文**：
> "The wiki is just a git repo of markdown files. You get version history, branching, and collaboration for free."

**本仓库现状**：有 `.gitignore`，无 commit 规范、无分支策略、AGENTS.md 未提 git。

**建议**：在 `§14 机器化维护` 增补「git 工作流」小节：每次 ingest/lint 后由 LLM 建议提交（conventional commit，如 `feat(wiki): ingest uhpc-authoritative-standards`），用户确认。优先级 P2。

### 1.6 [P2] 无规模化搜索策略

**Karpathy 原文**：
> "At some point you may want to build small tools... [qmd] is a local search engine for markdown files with hybrid BM25/vector search and LLM re-ranking."

**本仓库现状**：`spec.md` 明确「不引入数据库/CLI/向量检索」。当前 20 页靠 index.md + Grep 够用。

**建议**：在 `§14` 增补「规模化阈值」：当知识页 > 100 且 Query 关键词扫描开始漏页时，引入 qmd 或自建 BM25 脚本。优先级 P2。

### 1.7 [P2] entity 主动检测策略过保守

**Karpathy 原文**（gist §Operations/Ingest）：
> "updates entity pages, revising topic summaries, noting where new data contradicts old claims"

**本仓库现状**：`§13` 只主动捕获 `original`，entity/concept 完全靠手动 ingest。`spec.md` 明确「不全面 entity detection」。

**影响**：已出现覆盖不均 —— 3 位 hobby 创作者有 entity 页，但 ai 域「苏大讲AI」、personal 域「暖暖小星球」无 entity 页（仅有 media 页）。

**建议**：在 ingest 工作流步骤 3「提取实体与概念」后，增加「主动询问」：若发现高频出现的人/组织/产品已有 media 页但无 entity 页，提示用户是否补建。优先级 P2（避免噪音与覆盖不均的平衡）。

---

## 2. Schema/规范层优化

### 2.1 [P0] §9.2 补 Query 回填机制
见 §1.1。这是 Schema 层最高优先级修订。

### 2.2 [P1] §4.0 MECE 决策树补「单源综述」边界规则

**问题**：`rag-vs-llm-wiki.md` 标 `summary`，但 frontmatter `sources` 仅 1 条（karpathy-llm-wiki-gist.md），页面正文自述「本综述基于该单一原始源」。按 §4.0：
- 第 3 步 source-note = 「非媒体类文字资料的**单源**提炼笔记」
- 第 5 步 summary = 「跨**多个**原始源的综合综述」

单源综述落在两者缝隙。当前判定为 summary 是边界合理选择，但 MECE 不够锋利。

**建议**：在 §4.0 增加边界规则：「单源但采用综述形态（背景/论点/对比表/开放问题结构）→ summary；单源且为提炼笔记形态（核心要点/关键引文/延伸问题）→ source-note。区分靠**正文结构**而非源数量。」优先级 P1。

### 2.3 [P1] §9.1 ingest 自检 checklist 机器化验证

**问题**：8 项自检是 LLM 自声明，无机器验证。已发现实际执行有缺口（2 个文字源未建 source-note 页）。

**建议**：
- lint 脚本新增检查项：「最近一次 ingest（从 log.md 取）声明触达的页，是否都满足 updated=今日 + 时间线末条日期=今日」。
- lint 脚本新增检查项：「每个 raw 文件是否至少被一个 wiki 页 sources 引用」（检测 raw 落盘后未 ingest 的孤儿源）。

优先级 P1。

### 2.4 [P1] §10 index.md 降低手维护成本

**问题**：五区块每次 ingest 都要手刷，已出现：快速入口计数虚高（llm-wiki 16 实为 4 唯一页）、排序错位（rag-vs-llm-wiki 9 排在 second-brain 7 之后）、计数与 lint 反向链接矩阵脱钩。

**建议**：
- 快速入口：改为 lint 脚本输出「index-quick-entry.md」片段，LLM 直接粘贴（消除手算错误）。
- 标签索引 / domain×type 分组 / 最近更新：改用 Dataview（见 §1.3）。
- 主题 MOC：保留手维护（需语义判断）。

优先级 P1。

### 2.5 [P2] §11 log.md 与 lint 详细报告分离

**问题**：`spec.md` 说 Trae Schedule 定期 lint 的报告写进 log.md。但 lint 报告含反向链接矩阵（20 页 × N 源页），全塞 log.md 会让日志膨胀，淹没 ingest/query 记录。

**建议**：log.md 只记一行摘要（「2026-07-14 lint：0 错误 3 警告，详见 reports/lint-2026-07-14.md」）；详细报告写到 `reports/` 目录（新增）。优先级 P2。

### 2.6 [P2] §4.5/§4.6 强制「该源本身另建页」的执行保障

**问题**：§9.1 步骤 4 要求「该源本身另建 media 或 source-note 页」。实际：5 个抖音媒体源均有 media 页 ✓，但 2 个文字源（karpathy-llm-wiki-gist.md、uhpc-authoritative-standards-2026-07.md）无独立 source-note 页，内容被分散提取进 concept/summary/entity 页。

**建议**：在 §9.1 自检 checklist 增加第 9 项：「本次 ingest 的 raw 文件本身已有对应 media/source-note 页（若否，补建）」。优先级 P2。

---

## 3. 内容质量层（基于全量审计）

### 3.1 [P0 major] 3 个 entity 页双区结构违规

**问题**：`andrej-karpathy.md`、`quanqiu-dou-zhidao.md`、`secret-fpv-pilot.md` 的 `## 关联实体` 段错置于 `## 时间线` **之下**。按 §4.2 entity 模板，关联实体属编译真相区，应在时间线**之上**。这使编译真相内容落入「只追加、永不编辑」的时间线区，破坏双区边界。

**对照**：第 4 个 entity 页 `zhao-laoshi-jianzhu-keji-yuan.md` 顺序正确（关联实体 → 时间线），可作为参照。

**修复**：将这 3 页的 `## 关联实体` 段整体移动到 `## 时间线` 之前。风险低，纯结构调整。

### 3.2 [P1 minor 系统性] 15 页时间线条目缺 § 章节锚点

**问题**：§7 规定时间线条目格式 `（来源：raw/xxx.md § 章节）`，但 15 页的首次 ingest 条目仅写 `（来源：raw/xxx.md）` 无章节锚点。建筑类 5 页因二次 ingest 已补，其余未补。

**涉及页**：baby-cry-locate-itch、fpv-assembly-tools-infographic、fpv-assembly-tools、fpv-drone、llm-wiki、micrometer-usage-douyin-2026-06、micrometer、nuan-nuan-baby-cry-scratch-video、quanqiu-dou-zhidao、rag-vs-llm-wiki、secret-fpv-pilot、suda-llm-wiki-video、second-brain（2 条中 1 条缺）、zhao-laoshi-jianzhu-keji-yuan（3 条中 2 条缺）。

**修复**：逐页对照 raw 源补章节锚点。优先级 P1（可批量处理）。

### 3.3 [P2 minor] andrej-karpathy.md 5 条公众已知事实条目格式

**问题**：时间线前 5 条（2015-2024）来源标注为 `（来源：公众已知事实）` 而非 raw/ 格式，且日期用年份（`2015`）而非 `YYYY-MM-DD`。页面已有 callout 标注此为已知缺口。

**修复**：待 ingest Karpathy 传记类 raw 后补 raw/ 来源与完整日期。优先级 P2（依赖新源）。

### 3.4 [P2 minor] 2 个文字源缺 source-note 页

**问题**：`karpathy-llm-wiki-gist.md`、`uhpc-authoritative-standards-2026-07.md` 无独立 source-note 页，内容分散进 concept/summary/entity 页。

**修复**：补建 2 个 source-note 页。优先级 P2（见 §2.6 的机制保障）。

### 3.5 [P2 minor] 2 位创作者缺 entity 页

**问题**：ai 域「苏大讲AI」、personal 域「暖暖小星球」仅有 media 页无 entity 页，与 hobby 域 3 位创作者处理不一致。

**修复**：补建 2 个 entity 页，或明确「media 页已足够承载创作者信息」的取舍并写进 Schema。优先级 P2。

### 3.6 [P1 minor] index.md 快速入口数据错误

**问题**：
- 计数虚高：`llm-wiki (16)` 实际唯一入链页 = 4（andrej-karpathy、rag-vs-llm-wiki、second-brain、suda-llm-wiki-video）。16 是链接实例数（含同页多次指向），非「其他页面指向它的次数」。
- 排序错位：`rag-vs-llm-wiki (9)` 排在 `second-brain (7)` 之后，违反降序。
- 头部说明「按入链数（其他页面指向它的次数）排序」与实际数据口径不符。

**根因**：lint 脚本入链计数 bug（见 §4.1）+ LLM 手维护时直接抄了错误数据。

**修复**：先修 lint 脚本（§4.1），再用脚本输出重写快速入口。优先级 P1。

---

## 4. 工具/自动化层优化

### 4.1 [P0] lint 脚本入链重复计数 bug

**位置**：`scripts/wiki-lint.sh` 第 107-115 行（孤岛检查）与第 244-260 行（反向链接矩阵）。

**Bug**：对每个 `[[link]]` 实例计数，同一源页多次指向同一目标被算多次。导致：
- 反向链接矩阵输出 `llm-wiki (16) <- andrej-karpathy andrej-karpathy andrej-karpathy ...`（应为 4 唯一页）。
- 孤岛检查虽未误报（0 入链判定不受影响），但入链数全部虚高。
- index.md 快速入口抄了虚高数据（见 §3.6）。

**修复**：用关联数组记录「源页 → 目标页」的唯一对，而非累加实例。示例：

```bash
declare -A seen_pairs
for f in "${pages[@]}"; do
  src_base=$(basename "$f" .md)
  declare -A targets_in_this_page
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/|.*$//')
    [[ -n "$target" && "$target" != "wikilink" ]] && targets_in_this_page["$target"]=1
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
  for target in "${!targets_in_this_page[@]}"; do
    [[ -n "${inlinks[$target]+x}" ]] && inlinks[$target]=$((inlinks[$target]+1))
  done
  unset targets_in_this_page
done
```

优先级 P0（数据正确性）。

### 4.2 [P1] lint 脚本 frontmatter 字段检查重复条件

**位置**：第 60 行 `if ! echo "$fm" | grep -q "^${field}:" && ! echo "$fm" | grep -q "^${field}:" ; then`

**Bug**：两个条件完全相同（写漏了第二种格式检查，应为 `^${field}:` 与 `^${field} :` 或带空格变体）。当前逻辑上可用（单条件足以检测），但代码冗余且暴露原作者意图未完成。

**修复**：删除重复条件，或补全为检测 `field:` 与 `field :` 两种 YAML 写法。优先级 P1。

### 4.3 [P1] lint 脚本 sources 提取易误捕

**位置**：第 162-171 行 `grep -E '^[[:space:]]*- '`。

**Bug**：该正则匹配 frontmatter 中所有 `- ` 开头的行，若 tags 写成多行数组（`tags:\n  - foo\n  - bar`）会被误判为 sources。当前页面 tags 均为内联数组（`[a, b]`）故未触发，但脆弱。

**修复**：限定在 `sources:` 之后的 `- ` 行提取。可用 awk 状态机：

```bash
awk '/^sources:/{insources=1; next} /^[a-z]/{insources=0} insources && /^[[:space:]]*- /{print}'
```

优先级 P1。

### 4.4 [P1] lint 脚本缺检查项

**缺失**：
1. **文件名 kebab-case 校验**：当前不检查，若 LLM 误建 `Andrej Karpathy.md` 不会报错。
2. **reliability 取值校验**：可选字段但若填应 ∈ {high, medium, low}。
3. **时间线日期格式校验**：当前只检查 `来源：` 出现次数，不检查 `YYYY-MM-DD` 格式（andrej-karpathy 的 `2015` 年份格式不会报错）。
4. **§ 章节锚点校验**：当前不检查时间线条目是否含 `§ 章节`。
5. **index 快速入口与 lint 数据一致性**：lint 算出的入链数与 index.md 声明的数字不校验，导致 §3.6 错误长期存在。
6. **双区语义启发式检查**：机器难判断「重写 vs 追加」，但可检查「时间线之上是否出现 `^- YYYY-MM-DD` 列表项」（编译真相区不应有日期戳列表）。

**建议**：逐项加入。优先级 P1。

### 4.5 [P2] lint 脚本不输出机器可解析格式

**问题**：当前纯人读文本输出。Trae Schedule 触发后，LLM 需解析报告写进 log.md，靠正则提取数字易错。

**建议**：增加 `--json` 参数输出 JSON（错误列表、警告列表、反向链接矩阵）。优先级 P2。

### 4.6 [P1] 3 个 skill 与 AGENTS.md 大量重复

**问题**：`skills/llm-wiki-{ingest,lint,query}/SKILL.md` 大量复述 AGENTS.md 内容（双区结构、矛盾处理、命名约定、交叉引用风格等）。重复内容在两处维护，易不同步（如 §1.1 补 Query 回填时，需同时改 AGENTS.md §9.2 + query skill，漏改则不一致）。

**建议**：skill 文件改为「瘦壳」—— 只保留触发条件 + 「权威依据指向 AGENTS.md 具体章节」+ 该操作特有的注意事项，不复述通用规则。例如 ingest skill 只保留：触发条件、8 步流程纲要（每步一行）、自检 checklist（指向 §9.1 第 8 步）、original 主动捕获触发条件。通用规则（双区/矛盾/命名/引文）全部删去，靠 `**权威依据**：AGENTS.md §X` 引用。优先级 P1。

### 4.7 [P2] Trae Schedule lint 产物分离

见 §2.5。优先级 P2。

---

## 5. 优先级汇总与执行建议

### P0（立即修，影响数据正确性 / 核心机制）

| # | 项 | 层面 | 风险 | 工作量 |
|---|---|---|---|---|
| 1 | 补 Query 回填机制（§1.1 / §2.1） | Karpathy 对齐 + Schema | 低 | 中 |
| 2 | 修 lint 脚本入链重复计数 bug（§4.1） | 工具 | 低 | 小 |
| 3 | 修 3 个 entity 页双区结构违规（§3.1） | 内容 | 低 | 小 |

### P1（近期修，提升健壮性）

| # | 项 | 层面 | 风险 | 工作量 |
|---|---|---|---|---|
| 4 | 补 Query 多形态输出（§1.2） | Karpathy 对齐 | 低 | 小 |
| 5 | index.md 用 Dataview 降手维护（§1.3 / §2.4） | Karpathy 对齐 + Schema | 中 | 中 |
| 6 | §4.0 补单源综述边界规则（§2.2） | Schema | 低 | 小 |
| 7 | ingest 自检机器化验证（§2.3 / §4.4） | Schema + 工具 | 低 | 中 |
| 8 | lint 脚本补 6 项检查（§4.4） | 工具 | 低 | 中 |
| 9 | lint 脚本修 2 个 bug（§4.2 / §4.3） | 工具 | 低 | 小 |
| 10 | 修 index.md 快速入口数据（§3.6，依赖 #2） | 内容 | 低 | 小 |
| 11 | 补 15 页时间线 § 章节锚点（§3.2） | 内容 | 低 | 中 |
| 12 | skill 瘦壳化去重（§4.6） | 工具 | 中 | 中 |

### P2（远期优化，锦上添花）

| # | 项 | 层面 |
|---|---|---|
| 13 | log.md 格式 grep 优化（§1.4） | Karpathy 对齐 |
| 14 | git 工作流说明（§1.5） | Karpathy 对齐 |
| 15 | 规模化搜索阈值（§1.6） | Karpathy 对齐 |
| 16 | entity 主动检测策略（§1.7） | Karpathy 对齐 |
| 17 | log.md 与 lint 报告分离（§2.5 / §4.7） | Schema + 工具 |
| 18 | 强制 raw 必有对应页（§2.6） | Schema |
| 19 | andrej-karpathy 公众事实条目（§3.3，依赖新源） | 内容 |
| 20 | 补 2 个 source-note 页（§3.4） | 内容 |
| 21 | 补 2 个创作者 entity 页（§3.5） | 内容 |
| 22 | lint 脚本 JSON 输出（§4.5） | 工具 |

### 建议执行顺序

1. **先修 P0 三项**（#1-3），解锁正确数据基线。
2. **再批量修 P1 工具层**（#8-9），让 lint 可信。
3. **用可信 lint 修内容层**（#10-11）。
4. **再做 Schema 修订**（#4-7），同步 skill 瘦壳化（#12）。
5. P2 按需推进。

---

## 6. 不建议改动的部分（明确保留）

经审视，以下设计**正确**，优化方案不触碰：

- **三层架构**（raw / wiki / schema）：Karpathy 核心，已对齐。
- **双区结构**（编译真相重写 + 时间线追加）：GBrain-core 核心创新，优于 Karpathy 原版（原版无此机制）。
- **6 种 type MECE 判定**：比 Karpathy 原版（未规定 type）更严谨，仅需补边界规则。
- **扁平结构 + frontmatter 区分**：Obsidian 友好，不分子目录正确。
- **`raw/` 只读不写**（URL ingest 例外）：不可变规则正确。
- **3 个 domain 隐私分层**：personal/ai/hobby 分流正确。
- **original 主动捕获**：高价值设计，保留。
- **AGENTS.md / CLAUDE.md 双写同步**：已验证逐字一致，机制正确。

---

## 附：审计方法说明

- **Karpathy 对齐**：WebFetch 抓取 gist 全文 + 本地 `raw/karpathy-llm-wiki-gist.md` 逐节对照。
- **Schema 审计**：通读 `AGENTS.md` 14 节 + 3 个 skill + `.trae/specs/build-llm-wiki/spec.md`。
- **内容审计**：委派子代理读取全部 20 个知识页，按 9 维度逐页检查（frontmatter/双区/交叉引用/孤岛/sources 对齐/矛盾/过时/命名/type 判定）。
- **机器 lint**：运行 `bash scripts/wiki-lint.sh` 取实际输出，逐行审计脚本逻辑。
- **同步验证**：`diff AGENTS.md CLAUDE.md` 确认逐字一致。
- **数据校验**：读 `index.md` 快速入口，对照 lint 反向链接矩阵，确认计数 bug 影响。
