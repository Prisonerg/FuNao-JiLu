# Checklist

本 checklist 用于 spec 执行后的系统化验证。每项对应 spec 的一个 Requirement/Scenario。

## P0 验证

- [ ] lint 脚本入链按唯一源页计数：重跑 lint，`llm-wiki` 入链数 = 4（非 16），`uhpc` = 5（非 15），反向链接矩阵无同页重复列出
- [ ] lint 脚本 frontmatter 字段检查无重复条件（第 60 行两个相同条件已合并/补全）
- [ ] lint 脚本 sources 提取不误捕 tags 多行数组（构造一个 tags 多行数组的测试页验证）
- [ ] `wiki/andrej-karpathy.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [ ] `wiki/quanqiu-dou-zhidao.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [ ] `wiki/secret-fpv-pilot.md` 的 `## 关联实体` 在 `## 时间线` 之上
- [ ] `AGENTS.md §9.2 Query` 含步骤 6「评估回填价值」（综合 3+ 页或产生新对比/连接/框架时主动询问回填）
- [ ] `AGENTS.md §9.2 Query` 含多形态输出指引（对比→表/趋势→图/汇报→Marp/关系→canvas）
- [ ] `AGENTS.md §11` 操作类型枚举含 `query-fileback`（共 6 种）
- [ ] `skills/llm-wiki-query/SKILL.md` 含回填流程 + 多形态输出（与 §9.2 一致）
- [ ] CLAUDE.md 与 AGENTS.md 逐字一致（`diff` 无输出）

## P1 验证

- [ ] lint 新增检查 1：文件名非 kebab-case 时报错
- [ ] lint 新增检查 2：reliability 取值非 {high,medium,low} 时报错
- [ ] lint 新增检查 3：时间线日期非 `YYYY-MM-DD` 格式时警告
- [ ] lint 新增检查 4：时间线条目缺 `§ 章节` 时警告（对 15 页执行后报警告，补全后消失）
- [ ] lint 新增检查 5：index.md 快速入口入链数与 lint 反向链接矩阵不一致时报错
- [ ] lint 新增检查 6：编译真相区出现 `^- YYYY-MM-DD` 列表项时警告
- [ ] lint 新增检查 7：最近一次 ingest 触达页 updated/时间线末条与 ingest 日期不一致时报错
- [ ] lint 新增检查 8：raw 文件未被任何 wiki 页 sources 引用时警告（孤儿源检测）
- [ ] `wiki/index.md` 快速入口入链数与 lint 输出一致，按降序排列，入链 <3 不列入
- [ ] 15 页时间线条目均含 `§ 章节` 锚点（lint 检查 4 对这些页不再报警告）
- [ ] `wiki/rag-vs-llm-wiki.md` 对比表「矛盾处理」行描述双区版机制（时间线追加修正 + 编译真相重写 + callout 仅临时），无「callout 标记并保留旧结论」表述
- [ ] `wiki/rag-vs-llm-wiki.md` 时间线含本次修正条目，updated 已刷新
- [ ] `wiki/log.md` 条目严格正序（17:27 在 17:35 前；07:33 在 15:10 前）
- [ ] `wiki/log.md` 头部操作类型枚举含 `schema-update` 与 `query-fileback`
- [ ] `wiki/log.md` 正文 `schema-update` 大小写统一（无 `Schema-update`）
- [ ] `AGENTS.md §3` updated 字段说明明确「= 编译真相区最后一次重写日期，非 lint 触达日期」
- [ ] 20 页 updated 字段经核定，反映真实最后重写日期（14 页误刷的已回退）
- [ ] `AGENTS.md §4.0` 含单源综述边界规则（综述形态→summary / 提炼笔记形态→source-note）
- [ ] `AGENTS.md §9.1` 自检 checklist 含第 9 项（raw 本身已有对应 media/source-note 页）
- [ ] `wiki/index.md` 「最近更新」「标签索引」「domain×type 分组」三段为 Dataview 查询块
- [ ] `wiki/index.md` 「快速入口」「主题 MOC」保留手维护
- [ ] `skills/llm-wiki-ingest/SKILL.md` 已瘦壳化（无与 AGENTS.md 重复的通用规则，靠章节引用）
- [ ] `skills/llm-wiki-query/SKILL.md` 已瘦壳化
- [ ] `skills/llm-wiki-lint/SKILL.md` 已瘦壳化

## P2 验证

- [ ] `AGENTS.md §14` 含「git 工作流」小节（conventional commit 建议）
- [ ] `AGENTS.md §14` 含「规模化搜索阈值」小节（>100 页引入 qmd/BM25）
- [ ] `AGENTS.md §14` 或 §9.1 含「entity 主动检测」策略
- [ ] `reports/` 目录已建；lint 详细报告写 `reports/lint-YYYY-MM-DD.md`，log.md 只记摘要
- [ ] lint 脚本支持 `--json` 参数输出 JSON
- [ ] log.md 条目格式为 `## [YYYY-MM-DD HH:MM] type | 简述`
- [ ] 【阻塞验证】2 个 source-note 页已建并登记 index.md（待重新 ingest）
- [ ] 【阻塞验证】2 位创作者 entity 页已建并登记 index.md（待新源）
- [ ] 【阻塞验证】`andrej-karpathy.md` 5 条公众事实条目含 raw/ 来源与完整日期，callout 已移除（待传记源）

## 收尾验证

- [ ] 重跑 `bash scripts/wiki-lint.sh` 退出码 0（0 错误）
- [ ] `diff AGENTS.md CLAUDE.md` 无输出（逐字一致）
- [ ] `wiki/log.md` 末尾含一条 `schema-update` 记录本次全量优化
- [ ] 所有非阻塞任务在 tasks.md 已勾选
- [ ] 阻塞任务（27/28/29）在 tasks.md 标注「阻塞：待新源」未勾选，不影响收尾
