# Checklist

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
