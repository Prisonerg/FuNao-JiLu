# Wiki 操作日志

这是追加式操作日志：只追加，不修改、不删除历史条目（即便错误也保留，便于审计）。本仓库采用正序（旧在上、新在下追加）。操作类型：`ingest` / `query` / `lint` / `manual-edit`。

### 2026-07-12 -- Ingest

- **源文件**：raw/karpathy-llm-wiki-gist.md
- **触达的 wiki 文件**：wiki/llm-wiki.md, wiki/andrej-karpathy.md, wiki/rag-vs-llm-wiki.md, wiki/index.md, wiki/log.md
- **说明**：首次搭建，摄入 Karpathy LLM Wiki gist 并生成 3 个示例页（1 概念页 + 1 实体页 + 1 综述页），同步建立 index.md 主目录与 log.md 操作日志；本次未发现新旧资料矛盾（首份原始源）。

### 2026-07-12 09:04 - Ingest

- **源文件**：raw/suda-llm-wiki-douyin-2026-06.md（新建；由 Trae wiki 维护者经 WebFetch 抓取抖音视频页元信息与 AI 章节摘要后落盘，用户授权「整理视频内容而后保存」）
- **触达的 wiki 文件**：wiki/suda-llm-wiki-video.md（新建 source-note）, wiki/second-brain.md（新建 concept）, wiki/llm-wiki.md（补「中文社区反响 2026-06」段 + 对比表加 second-brain 行 + sources 加新源）, wiki/andrej-karpathy.md（相关事件 + 时间线加 2026-06 + 关联实体 + sources 加新源）, wiki/rag-vs-llm-wiki.md（参考来源加 second-brain 交叉引用）, wiki/index.md（登记 1 source-note + 1 concept）, wiki/log.md
- **说明**：摄入抖音「苏大讲AI」《完犊子了！卡帕西刚引爆的"LLM Wiki"学习潮！》视频（2026-06-23 发布，1.1 万赞）。raw 文件性质特殊——章节要点为抖音 AI 自动生成（页面标注「内容由AI生成」），非逐字稿，存在「作者二次解读 + 平台 AI 摘要」两层中介化，已在 raw 文件头与 source-note 页显式标注。新建 [[second-brain]] 概念页承接视频把 LLM Wiki 等同「第二大脑」的本土化框架。矛盾检查：视频称 Karpathy 为「OpenAI 创始人」，wiki 据 gist 与公众事实记为「OpenAI 联合创始成员之一」——判定为口语化简化而非事实冲突，未触发 callout，仅在 raw 备注与 source-note 延伸问题中标注。

### 2026-07-12 09:24 - Lint

- **源文件**：—（全量自检，无新源）
- **触达的 wiki 文件**：wiki/llm-wiki.md, wiki/andrej-karpathy.md, wiki/rag-vs-llm-wiki.md, wiki/index.md, wiki/log.md
- **说明**：首次全量体检并执行修复。共发现 4 项可修复问题，均已处理：
  (1) **M1/S1 矛盾+过时**：[llm-wiki] 定义段原称「本页唯一原始源即为 gist」，与 frontmatter sources 列两源（含 raw/suda-llm-wiki-douyin-2026-06.md）矛盾——系第二次 ingest 漏改。已改为「核心原始源为 gist，另见 [[suda-llm-wiki-video|中文社区反响源]]」。
  (2) **C1 引文违规**：[andrej-karpathy] 相关事件首条引文含「.trae/specs/build-llm-wiki/spec.md § Why」，该文件不在 raw/ 下、违反 §7。已删除该悬空引用，仅保留 raw/karpathy-llm-wiki-gist.md。
  (3) **C2 悬空引用**：[rag-vs-llm-wiki] 开放问题首条含「任务描述中提及的『约 50K-100K token』」，该任务描述不在 wiki/raw 中、无法回溯。已删除该悬空表述。
  (4) **C4 命名不一致**：[index] 一级分组原为「## 个人领域（Personal）」，与 §10 示例「## Personal 领域」不一致。已统一为「## Personal 领域」。
  另：log.md 首条记录（2026-07-12 -- Ingest）缺 HH:MM 且用 `--` 而非 ` - `，不符合 §11 格式——但 §11 规定 log 追加式不删改历史，故保留原样，仅此说明。
  孤岛页检查：0 项（5 个知识页入链均 ≥3）。缺失交叉引用：0 项。被修复页面 updated 字段均已是今日（2026-07-12），无需刷新。可选改进项（O1 新建实体页 / O2 补 tag / O3 措辞微调）未执行，留待后续 ingest。

### 2026-07-12 10:07 - Ingest

- **源文件**：raw/nuan-nuan-baby-cry-scratch-douyin-2026-06.md（新建；由 Trae wiki 维护者经 WebFetch 抓取抖音视频页文字描述后落盘，用户授权「完整 ingest 进 wiki」。注：raw/ 常规为 LLM 只读不写，本次系用户明确授权的一次性原始源入库）
- **触达的 wiki 文件**：wiki/nuan-nuan-baby-cry-scratch-video.md（新建 source-note）, wiki/baby-cry-locate-itch.md（新建 concept）, wiki/index.md（Personal 领域登记 1 source-note + 1 concept）, wiki/log.md
- **说明**：摄入抖音「暖暖小星球」《带娃妙招 宝宝哭闹就全身挠一遍》视频（2026-06-26 12:44 发布，00:18，64.9 万播放 / 22 万收藏）。该源为本次会话用户触发「查询育儿知识」后发现 wiki 育儿内容为空，用户记忆中的「婴儿头痒」知识即源自此视频；用户遂授权完整 ingest。新建 [[baby-cry-locate-itch]] 概念页承接方法本体（排除吃喝拉撒 → 全身挠 → 以哭闹停止定位痒点），[[nuan-nuan-baby-cry-scratch-video]] source-note 记录视频元信息与两层中介化性质（WebFetch 文字描述非逐字稿 + UGC 非医学权威）。来源经用户口述链接提供、WebFetch 抓取，raw 文件性质已在文件头与 source-note 显式标注。矛盾检查：本源为 wiki 首个 personal 领域内容，与既有 AI 领域页面无交叉，无新旧结论冲突，未触发 callout。已知缺口：方法适用边界、婴儿头痒具体诱因（乳痂/湿疹等）本源未覆盖，待后续 ingest 儿科权威源补全，已在两页「局限/延伸问题」中标注。
