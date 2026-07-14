# Tasks

本 spec 覆盖 26 项优化（proposal 22 + 新发现 4）。任务按依赖与优先级排序，P0 → P1 → P2。每个任务标注「层面」「优先级」「依赖」。

## TG1 — P0 工具基线（lint 脚本修 bug，解锁正确数据）

- [ ] Task 1: 修 lint 脚本入链重复计数 bug
  - 层面：工具 / P0 / 依赖：无
  - 改 `scripts/wiki-lint.sh` 第 107-115 行（孤岛检查）与第 244-260 行（反向链接矩阵）：用关联数组记录「源页→目标页」唯一对，同一源页多次指向同一目标只算 1 入链。
  - 验证：重跑 lint，反向链接矩阵中 `llm-wiki` 入链数从 16 降为 4（唯一源页：andrej-karpathy、rag-vs-llm-wiki、second-brain、suda-llm-wiki-video）。
- [ ] Task 2: 修 lint 脚本 frontmatter 字段检查重复条件
  - 层面：工具 / P0 / 依赖：无
  - 改第 60 行 `if ! echo "$fm" | grep -q "^${field}:" && ! echo "$fm" | grep -q "^${field}:" ;`：删除重复的第二个条件，或补全为检测 `field:` 与 `field :` 两种 YAML 写法。
- [ ] Task 3: 修 lint 脚本 sources 提取易误捕
  - 层面：工具 / P0 / 依赖：无
  - 改第 162-171 行：用 awk 状态机限定在 `sources:` 之后的 `- ` 行提取，避免误捕 tags 多行数组。
  - 验证：lint 仍报 sources 全部对齐（无误报）。

## TG2 — P0 内容修复（双区结构违规）

- [ ] Task 4: 修 3 个 entity 页双区结构违规
  - 层面：内容 / P0 / 依赖：无
  - 将 `wiki/andrej-karpathy.md`、`wiki/quanqiu-dou-zhidao.md`、`wiki/secret-fpv-pilot.md` 的 `## 关联实体` 段整体移动到 `## 时间线` 之前（参照 `wiki/zhao-laoshi-jianzhu-keji-yuan.md` 的正确顺序）。
  - 验证：3 页的 `## 关联实体` 均在 `## 时间线` 之上；重跑 lint 0 错误。

## TG3 — P0 核心机制（Query 回填）

- [ ] Task 5: §9.2 补 Query 回填机制
  - 层面：Schema / P0 / 依赖：无
  - 在 `AGENTS.md §9.2 Query` 增步骤 6「评估回填价值」：综合 3+ 页或产生新对比/连接/框架时，主动询问用户是否回填为 `summary`/`original` 页；用户同意后建页，frontmatter `sources` 列出综合时读取的 wiki 页（用 `[[xxx]]`）。
- [ ] Task 6: §9.2 补 Query 多形态输出指引
  - 层面：Schema / P0 / 依赖：Task 5
  - 在 `§9.2` 增输出形态选择指引：对比→表、趋势→图、汇报→Marp、关系网络→canvas。
- [ ] Task 7: §11 操作类型新增 query-fileback
  - 层面：Schema / P0 / 依赖：Task 5
  - 在 `AGENTS.md §11 log.md` 操作类型枚举新增 `query-fileback`（共 6 种：ingest/query/lint/manual-edit/schema-update/query-fileback）。
- [ ] Task 8: query skill 补回填流程
  - 层面：工具 / P0 / 依赖：Task 5、Task 6
  - 在 `skills/llm-wiki-query/SKILL.md` 补步骤 6 回填流程 + 多形态输出指引（与 §9.2 一致）。

## TG4 — P1 lint 增强

- [ ] Task 9: lint 补 6 项检查
  - 层面：工具 / P1 / 依赖：TG1
  - 在 `scripts/wiki-lint.sh` 新增 6 项检查：(1) 文件名 kebab-case 校验；(2) reliability 取值 ∈ {high,medium,low}；(3) 时间线日期格式 `YYYY-MM-DD`；(4) 时间线条目含 `§ 章节`；(5) index 快速入口入链数与 lint 反向链接矩阵一致；(6) 双区启发式（编译真相区不应出现 `^- YYYY-MM-DD` 列表项）。
  - 验证：重跑 lint，新检查项对现有 20 页执行，报告当前缺 § 锚点的 15 页为警告。
- [ ] Task 10: lint 补 ingest 自检机器化验证
  - 层面：工具 / P1 / 依赖：TG1
  - 新增 2 项检查：(1) 从 log.md 取最近一次 ingest 声明触达的页，校验 updated=该次日期 + 时间线末条日期=该次日期；(2) 每个 raw 文件至少被一个 wiki 页 sources 引用（检测孤儿源）。

## TG5 — P1 内容修复（依赖 lint 可信数据）

- [ ] Task 11: 修 index.md 快速入口数据
  - 层面：内容 / P1 / 依赖：Task 1
  - 用修好的 lint 反向链接矩阵输出，重写 `wiki/index.md` 快速入口段：入链数按唯一源页计数；按降序排列；入链 <3 不列入。
  - 验证：快速入口 `llm-wiki (4)`、`uhpc (5)` 等数字与 lint 输出一致；降序正确。
- [ ] Task 12: 补 15 页时间线 § 章节锚点
  - 层面：内容 / P1 / 依赖：无
  - 为 15 页首次 ingest 条目补 `§ 章节` 锚点：baby-cry-locate-itch、fpv-assembly-tools-infographic、fpv-assembly-tools、fpv-drone、llm-wiki、micrometer-usage-douyin-2026-06、micrometer、nuan-nuan-baby-cry-scratch-video、quanqiu-dou-zhidao、rag-vs-llm-wiki、secret-fpv-pilot、suda-llm-wiki-video、second-brain（1 条缺）、zhao-laoshi-jianzhu-keji-yuan（2 条缺）。
  - 验证：lint 第 4 项新检查（§ 锚点）对这些页不再报警告。
- [ ] Task 13: 修 rag-vs-llm-wiki.md 陈旧论断
  - 层面：内容 / P1 / 依赖：无
  - 更新 `wiki/rag-vs-llm-wiki.md` 对比表「矛盾处理」行：从「callout 标记并保留旧结论，待裁定」改为双区版机制（时间线追加修正条目 + 编译真相重写 + callout 仅临时）。时间线追加一条修正记录。刷新 updated。
- [ ] Task 14: 修 log.md 时序 + 操作类型枚举
  - 层面：内容 / P1 / 依赖：无
  - 重排 `wiki/log.md` 现有条目为严格正序：17:27 lint 移到 17:35 ingest 之前；07:33 lint 移到 15:10 manual-edit 之前。头部操作类型枚举补 `schema-update` 与 `query-fileback`。正文 `Schema-update` 统一为小写 `schema-update`。
  - 注意：§11 规定 log 追加式不删改历史，但时序错乱属格式 bug，重排顺序（不删内容）属修复，需在末尾追加一条说明。

## TG6 — P1 Schema 修订（updated 语义 + MECE + 自检）

- [ ] Task 15: §3 重定义 updated 语义
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §3` frontmatter 模板的 `updated` 字段说明中明确：「= 该页编译真相区最后一次重写的日期，NOT lint 触达日期、NOT index.md 刷新日期」。同步 CLAUDE.md。
- [ ] Task 16: 核定 20 页 updated 字段
  - 层面：内容 / P1 / 依赖：Task 15
  - 逐页核查编译真相区最后一次真实重写日期：14 页被 07-14 lint 误刷的，回退到真实编辑日；6 个建筑页保持 07-12（真实最后编辑日）。回退 updated 属元数据修正（非编译真相重写），但按 §8 审计原则，对每页被回退的页在时间线追加一条「修正：updated 字段由误刷的 2026-07-14 回退为真实编辑日 YYYY-MM-DD」条目（来源：本页 frontmatter 核定）。
- [ ] Task 17: §4.0 补 MECE 单源综述边界规则
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §4.0` 增边界规则：单源综述形态（背景/论点/对比表/开放问题）→ summary；单源提炼笔记形态（核心要点/关键引文/延伸问题）→ source-note。区分靠正文结构而非源数量。同步 CLAUDE.md。
- [ ] Task 18: §9.1 自检加第 9 项
  - 层面：Schema / P1 / 依赖：无
  - 在 `AGENTS.md §9.1` ingest 自检 checklist 增第 9 项：「本次 ingest 的 raw 文件本身已有对应 media/source-note 页（若否，补建）」。同步 CLAUDE.md + ingest skill。

## TG7 — P1 自动化（Dataview + skill 瘦壳化）

- [ ] Task 19: index.md Dataview 改造
  - 层面：工具 / P1 / 依赖：Task 11
  - 将 `wiki/index.md` 的「最近更新」「标签索引」「domain×type 分组」三段改为 Dataview 查询块（`` ```dataview ``），由 Obsidian 实时渲染。保留「快速入口」（手维护）与「主题 MOC」（手维护）。
  - 验证：在 Obsidian 中三段正确渲染；非 Obsidian 浏览可见原始查询代码（可接受）。
- [ ] Task 20: 3 个 skill 瘦壳化
  - 层面：工具 / P1 / 依赖：TG3、TG6
  - 重写 `skills/llm-wiki-{ingest,query,lint}/SKILL.md`：删除与 AGENTS.md 重复的通用规则（双区结构/矛盾处理/命名约定/交叉引用/引文格式），只留触发条件 + 权威依据章节引用 + 该操作特有的注意事项。

## TG8 — P2 Schema 增补

- [ ] Task 21: §14 增 git 工作流小节
  - 层面：Schema / P2 / 依赖：无
  - 在 `AGENTS.md §14` 增「git 工作流」小节：每次 ingest/lint 后建议 conventional commit（如 `feat(wiki): ingest xxx`），用户确认。同步 CLAUDE.md。
- [ ] Task 22: §14 增规模化搜索阈值
  - 层面：Schema / P2 / 依赖：无
  - 在 `§14` 增「规模化搜索阈值」小节：知识页 >100 且 Query 漏页时引入 qmd/BM25。同步 CLAUDE.md。
- [ ] Task 23: §14 增 entity 主动检测策略
  - 层面：Schema / P2 / 依赖：无
  - 在 `§14`（或 §9.1 步骤 3 后）增「entity 主动检测」：高频出现的人/组织/产品无 entity 页时主动询问是否补建。同步 CLAUDE.md。

## TG9 — P2 工具与格式

- [ ] Task 24: lint 报告分离到 reports/
  - 层面：工具 / P2 / 依赖：TG4
  - 新建 `reports/` 目录；lint 脚本改为：log.md 只记一行摘要，详细报告（含反向链接矩阵）写 `reports/lint-YYYY-MM-DD.md`。
- [ ] Task 25: lint 脚本增 --json 输出
  - 层面：工具 / P2 / 依赖：TG4
  - lint 脚本增 `--json` 参数，输出 JSON（错误列表/警告列表/反向链接矩阵），便于 Schedule 触发后 LLM 解析。
- [ ] Task 26: log.md 格式 grep 优化
  - 层面：Schema / P2 / 依赖：Task 14
  - 将 log.md 条目格式优化为 `## [YYYY-MM-DD HH:MM] type | 简述`，迁移现有历史条目（保留内容，仅改格式）。同步 §11 说明。

## TG10 — P2 阻塞项（依赖新源）

- [ ] Task 27: 【阻塞：待重新 ingest】补 2 个 source-note 页
  - 层面：内容 / P2 / 依赖：用户重新 ingest karpathy-llm-wiki-gist 与 uhpc-authoritative-standards
  - 为 `raw/karpathy-llm-wiki-gist.md`、`raw/uhpc-authoritative-standards-2026-07.md` 各建一个 source-note 页（按 §4.5 模板），登记到 index.md。
- [ ] Task 28: 【阻塞：待新源】补 2 位创作者 entity 页
  - 层面：内容 / P2 / 依赖：用户提供「苏大讲AI」「暖暖小星球」更多背景信息
  - 为 ai 域「苏大讲AI」、personal 域「暖暖小星球」各建 entity 页（按 §4.2 模板），登记到 index.md。
- [ ] Task 29: 【阻塞：待传记源】修 andrej-karpathy.md 公众事实条目
  - 层面：内容 / P2 / 依赖：用户 ingest Karpathy 传记类 raw
  - 修 `wiki/andrej-karpathy.md` 时间线前 5 条（2015-2024）：补 raw/ 来源与完整 `YYYY-MM-DD` 日期，替换「（来源：公众已知事实）」。移除 callout。

## TG11 — 收尾

- [ ] Task 30: 全量验证 + log.md 记录
  - 层面：流程 / 依赖：所有非阻塞任务完成
  - 重跑 lint 确保 0 错误；AGENTS.md 与 CLAUDE.md diff 一致；在 log.md 追加一条 `schema-update` 记录本次全量优化。

# Task Dependencies

- Task 1/2/3（TG1 lint 修 bug）无依赖，可并行。
- Task 4（双区结构）无依赖，可与 TG1 并行。
- Task 5/6/7（Query 回填 Schema）顺序依赖：6 依赖 5，7 依赖 5。
- Task 8（query skill）依赖 5、6。
- Task 9/10（lint 增强）依赖 TG1（在修好的脚本上加检查）。
- Task 11（index 快速入口）依赖 Task 1（需正确入链数据）。
- Task 12/13/14（内容修复）无相互依赖，可并行。
- Task 15（updated 语义）无依赖；Task 16（核定）依赖 15。
- Task 17/18（Schema）无依赖，可并行。
- Task 19（Dataview）依赖 Task 11（快速入口先修好）。
- Task 20（skill 瘦壳化）依赖 TG3、TG6（Schema 改完再瘦壳）。
- Task 21/22/23（§14 增补）无依赖，可并行。
- Task 24/25/26（P2 工具）依赖 TG4。
- Task 27/28/29（阻塞项）依赖外部新源，不阻塞其他任务。
- Task 30（收尾）依赖所有非阻塞任务完成。

## 可并行批次建议

- 批次 A（P0 并行）：Task 1+2+3 + Task 4 + Task 5
- 批次 B（P0/P1 并行）：Task 6+7+8 + Task 12+13+14 + Task 15+17+18
- 批次 C（P1 串行）：Task 9+10 → Task 11 → Task 19 → Task 20 → Task 16
- 批次 D（P2 并行）：Task 21+22+23 + Task 24+25+26
- 批次 E（阻塞）：Task 27+28+29（待新源）
- 批次 F：Task 30
