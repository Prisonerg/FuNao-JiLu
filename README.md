# FuNao-JiLu

基于 [GBrain-core 模式](https://github.com/garrytan/gbrain)的个人知识库。以 GBrain 的「知识编译 + 双区结构 + 机器化维护」为核心引擎，融合 [Karpathy LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)的三层架构与扁平 Markdown 设计。让 LLM 增量地把原始资料「编译」成一个持久、可复利、互链、双区分明的 Markdown wiki——**编译一次、持续保持最新**。本仓库覆盖三个领域：**AI 学习**、**个人私密**、**技术型爱好（Hobby）**。

## 三层架构 + 机器化维护

```
FuNao-JiLu/
├── raw/                # 不可变原始源（LLM 只读）
├── wiki/               # LLM 维护的扁平 Markdown wiki（每页含编译真相 + 时间线双区）
├── scripts/
│   └── wiki-lint.sh    # 机器化体检脚本（8 项检查 + 反向链接矩阵）
├── AGENTS.md           # Schema（Trae/Cursor/Codex 读取）
├── CLAUDE.md           # Schema 同步副本（Claude Code 读取）
└── README.md
```

- `raw/` —— 原始源文件（文章、笔记、PDF、视频元信息），**不可变**，LLM 只读不写。
- `wiki/` —— LLM 完全拥有的扁平 Markdown wiki，靠 frontmatter 的 `domain`（ai/personal/hobby）和 `type`（6 种）字段区分页面类型，不分子目录。
- `scripts/wiki-lint.sh` —— 纯 bash/grep 机器化体检脚本，检查 frontmatter 完整性、双区结构、孤岛页、悬空引用、sources 对齐等。
- `AGENTS.md` / `CLAUDE.md` —— Schema 规范文件，二者内容一致，告诉 LLM 如何维护这个 wiki。

## 双区结构

每个知识页含「编译真相」与「时间线」双区，用 `## 时间线` 二级标题作为分界：

- **编译真相区**（分界线以上）：当前综合结论。证据变化时**重写**，不追加旧结论。
- **时间线区**（`## 时间线` 以下）：证据链。**只追加，永不编辑既有条目**。

核心优势：旧结论永不丢失（在时间线），编译真相永远反映最新综合，审计 trail 完整可追溯。

## 六种 type 与三个 domain

**type**（按 §4.0 MECE 判定测试确定）：

| type | 用途 |
| --- | --- |
| `entity` | 人 / 组织 / 产品 / 工具 / 创作者 |
| `concept` | 方法 / 理论 / 范式 / 术语 |
| `summary` | 跨多源综述 |
| `source-note` | 非媒体类文字资料（文章/论文/gist）单源笔记 |
| `media` | 媒体作品（视频/图文/播客）客观信息 + 提炼 |
| `original` | 用户原创框架 / 命名 / 洞见 / 综合（最高价值资产） |

**domain**：`ai`（AI 学习，可公开）/ `personal`（个人私密，含隐私隔离）/ `hobby`（技术型爱好，可公开）。

## 三大操作

### 1. Ingest（摄入）

把文章、笔记或 PDF 丢进 `raw/`，然后对 AI 助手说：

```
ingest raw/xxx.md
```

LLM 会：读全文 → 判定资料形态（media/source-note）→ 提取实体与概念 → 按 MECE 判定测试确定 type → 创建或更新相关 wiki 页（重写编译真相 + 追加时间线）→ 刷新 `wiki/index.md` → 追加 `wiki/log.md` → 执行 8 项自检 checklist。新旧资料冲突时，LLM 会在时间线追加「修正」条目并重写编译真相，旧结论永久留存。

### 2. Query（查询）

直接问问题即可。LLM 会：先读 `wiki/index.md` → 全量关键词扫描（不依赖 index 登记）→ 定位相关页读编译真相区 → 综合多页给出回答 → 引用回具体的 wiki 页。若触及 wiki 未覆盖的内容，LLM 会明确暴露缺口而非编造。

### 3. Lint（体检）

对 AI 助手说 `lint wiki`，或直接运行脚本：

```bash
bash scripts/wiki-lint.sh
```

**怎么读 lint 报告：**

| 检查项 | 说明 | 错误/警告 | 需要做什么 |
|--------|------|-----------|------------|
| **1. frontmatter 完整性** | 检查每个知识页开头的 YAML 信息是否齐全 | 错误（必须修） | 补上缺失的字段 |
| **2. 双区结构** | 检查是否有 `## 时间线` 二级标题 | 错误（必须修） | 加上 `## 时间线` |
| **3. 孤岛页** | 没有其他页面链接到它 | 警告（可选修） | 在相关页面补一个 `[[wikilink]]` |
| **4. 悬空引用** | `[[xxx]]` 指向不存在的文件 | 错误（必须修） | 删除引用或修正文件名 |
| **5. sources 与 raw 对齐** | frontmatter 的 sources 是否指向真实存在的 raw 文件 | 错误（必须修） | 修正文件名或删除不存在的 |
| **6. index 与实际页对齐** | index.md 是否列出了所有页面 | 警告（缺登记）/错误（不存在） | 补上或删除 |
| **7. 时间线格式** | 每条记录是否都有来源标注 | 警告（可选修） | 加上 `（来源：raw/xxx.md）` |
| **8. 反向链接矩阵** | 列出每个页面被哪些页面链接 | 信息 | 入链越多越核心 |

脚本执行 8 项机器化检查，LLM 补充检查：矛盾、过时声明、缺失交叉引用、编译真相与时间线一致性。

每周一 09:00（Beijing time）Trae Schedule 自动触发一次 lint，报告写进 `log.md`。

## 对话中 original 主动捕获

当用户在对话中冒出原创框架 / 命名 / 洞见时，LLM 会主动询问「这听起来是一个原创洞见，要记进 wiki 作为 original 页吗？」。用户同意后，用用户原话的 kebab-case 作为文件名（生动性即概念），逐字保留原始表述，链到相关页。这是本 wiki 最易流失的资产，因此主动捕获。

## 在 Obsidian 中打开

用 Obsidian 把 `/workspace` 或 `wiki/` 作为 vault 打开即可。所有交叉引用使用 `[[wikilink]]` 双向链接语法，**图谱视图（Graph View）** 能直观展示页面之间的链接关系——哪些是枢纽页、哪些是孤岛。`.gitignore` 已忽略 `.obsidian/` 配置目录，不会污染 git。

## 人机分工

> 你负责找资料、提问、产生原创思考；LLM 负责所有记账、交叉引用、重写编译真相、追加证据链的脏活。

你负责 source（找资料）、探索、提问、判断意义、产生原创洞见；LLM 负责总结、交叉引用、归档、保持一致性、双区结构维护、机器化体检。知识库之所以能长期存活，正是因为维护成本被 LLM 压到了接近零。
