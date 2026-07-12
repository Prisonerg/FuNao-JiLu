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
