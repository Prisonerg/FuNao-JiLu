# Wiki 操作日志

这是追加式操作日志：只追加，不修改、不删除历史条目（即便错误也保留，便于审计）。本仓库采用正序（旧在上、新在下追加）。操作类型：`ingest` / `query` / `lint` / `manual-edit`。

### 2026-07-12 -- Ingest

- **源文件**：raw/karpathy-llm-wiki-gist.md
- **触达的 wiki 文件**：wiki/llm-wiki.md, wiki/andrej-karpathy.md, wiki/rag-vs-llm-wiki.md, wiki/index.md, wiki/log.md
- **说明**：首次搭建，摄入 Karpathy LLM Wiki gist 并生成 3 个示例页（1 概念页 + 1 实体页 + 1 综述页），同步建立 index.md 主目录与 log.md 操作日志；本次未发现新旧资料矛盾（首份原始源）。
