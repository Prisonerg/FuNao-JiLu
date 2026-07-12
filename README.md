# FuNao-JiLu

基于 [Karpathy LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) 模式的个人知识库。让 LLM 增量地把原始资料「编译」成一个持久、可复利、互相链接的 Markdown wiki，而不是每次提问都从原始文档重新检索。本仓库覆盖两个领域：**AI 学习**与**个人私密**。

## 三层架构

```
FuNao-JiLu/
├── raw/        # 不可变原始源（LLM 只读）
├── wiki/       # LLM 维护的扁平 Markdown wiki
├── AGENTS.md   # schema（Trae/Cursor/Codex 读取）
├── CLAUDE.md   # schema 同步副本（Claude Code 读取）
└── README.md
```

- `raw/` —— 原始源文件（文章、笔记、PDF），**不可变**，LLM 只读不写。
- `wiki/` —— LLM 完全拥有的扁平 Markdown wiki，靠 frontmatter 的 `domain`（ai/personal）和 `type`（entity/concept/summary/source-note）字段区分页面类型，不分子目录。
- `AGENTS.md` / `CLAUDE.md` —— schema 规范文件，二者内容一致，告诉 LLM 如何维护这个 wiki（页面模板、命名约定、交叉引用风格、三大操作工作流等）。

## 三大操作

### 1. Ingest（摄入）

把文章、笔记或 PDF 丢进 `raw/`，然后对 AI 助手说：

```
ingest raw/xxx.md
```

LLM 会：读全文 → 提取实体与概念 → 创建或更新相关 wiki 页（一次可能触达 10-15 个文件）→ 刷新 `wiki/index.md` → 追加 `wiki/log.md`。新旧资料冲突时，LLM 会用 `> [!warning]` callout 标注，不会静默覆盖旧结论。

### 2. Query（查询）

直接问问题即可。LLM 会先读 `wiki/index.md` 找到相关页，再综合多页给出回答，并引用回具体的 wiki 页。好的回答还可以被回填为新 wiki 页，让探索也复利进知识库。

### 3. Lint（体检）

对 AI 助手说：

```
lint wiki
```

LLM 会检查：页面之间的矛盾、被新资料取代的过时声明、没有入链的孤岛页、被提及但缺少独立页的重要概念、缺失的交叉引用、可用网搜补上的数据缺口。

## 在 Obsidian 中打开

用 Obsidian 把 `/workspace` 或 `wiki/` 作为 vault 打开即可。所有交叉引用使用 `[[wikilink]]` 双向链接语法，**图谱视图（Graph View）** 能直观展示页面之间的链接关系——哪些是枢纽页、哪些是孤岛。`.gitignore` 已忽略 `.obsidian/` 配置目录，不会污染 git。

## 人机分工

> 你负责找资料和提问，LLM 负责所有记账与交叉引用的脏活。

你负责 source（找资料）、探索、提问、判断意义；LLM 负责总结、交叉引用、归档、保持一致性。知识库之所以能长期存活，正是因为维护成本被 LLM 压到了接近零。
