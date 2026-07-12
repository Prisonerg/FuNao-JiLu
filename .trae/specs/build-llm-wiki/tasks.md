# Tasks

- [x] Task 1: 重写 AGENTS.md 为 GBrain-core Schema
  - [x] SubTask 1.1: §1-3 概述/目录/frontmatter（加可选 reliability）
  - [x] SubTask 1.2: §4 六种 type 判定测试（MECE 决策树）+ 双区结构 + 各 type 模板
  - [x] SubTask 1.3: §5-7 命名/交叉引用/引文（timeline source 增强）
  - [x] SubTask 1.4: §8 矛盾处理双区版（时间线追加修正 + 编译真相重写）
  - [x] SubTask 1.5: §9 三大工作流（ingest 8 项自检 / query 全量扫描 / lint 机器化）
  - [x] SubTask 1.6: §10-14 index MOC / log / 领域适配 / original 捕获 / 机器化维护
- [x] Task 2: 同步 CLAUDE.md（与 AGENTS.md 逐字一致）
- [x] Task 3: 创建 scripts/wiki-lint.sh
  - [x] SubTask 3.1: 实现 8 项机器化检查 + 反向链接矩阵
  - [x] SubTask 3.2: 修复脚本边界 case（markdown 表格 `\|` 转义、`[[wikilink]]` 示例文字误提取）
  - [x] SubTask 3.3: 首次运行验证 0 错误 0 警告
- [x] Task 4: 全量迁移 13 个 wiki 页
  - [x] SubTask 4.1: AI 域 5 页（llm-wiki / andrej-karpathy / rag-vs-llm-wiki / second-brain / suda-llm-wiki-video）
  - [x] SubTask 4.2: Hobby 域 7 页（fpv-drone / fpv-assembly-tools / secret-fpv-pilot / fpv-assembly-tools-infographic / micrometer / quanqiu-dou-zhidao / micrometer-usage-douyin-2026-06）
  - [x] SubTask 4.3: Personal 域 2 页（baby-cry-locate-itch / nuan-nuan-baby-cry-scratch-video）
  - [x] SubTask 4.4: 4 页 source-note→media（章节标题 + type 字段）
  - [x] SubTask 4.5: 2 页 entity 时间线表格→列表
  - [x] SubTask 4.6: 13 页加 reliability 字段
  - [x] SubTask 4.7: 修复 2 处失效交叉引用
- [x] Task 5: 重写 index.md（顶部 4 主题 MOC + 下方 3 domain × 6 type 分组）
- [x] Task 6: 追加 log.md schema-update 记录
- [x] Task 7: 创建 Trae Schedule「每周 Wiki Lint 体检」（每周一 09:00 Beijing time）
- [x] Task 8: 更新 README.md 为 GBrain-core 模式说明
- [x] Task 9: 更新 .trae/specs/build-llm-wiki/ 三个 spec 文件为 GBrain-core 版
- [x] Task 10: 最终自检（lint 脚本 0 错误、CLAUDE.md 一致、raw/ 未碰）

# Task Dependencies
- Task 2 依赖 Task 1（先有 AGENTS.md 才能同步）
- Task 3 与 Task 1 可并行（脚本独立于 Schema 文字）
- Task 4 依赖 Task 1（需新 Schema 才能迁移）
- Task 5 依赖 Task 4（页迁移完才能重组 index）
- Task 6 依赖 Task 1-5
- Task 7 依赖 Task 3（需 lint 脚本才能调度）
- Task 8、Task 9 可在 Task 1-7 完成后并行
- Task 10 依赖全部完成
