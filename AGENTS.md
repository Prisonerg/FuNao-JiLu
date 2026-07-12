<!--
本文件是 Karpathy LLM Wiki 项目的 Schema 规范文件。
Trae / Cursor / Codex 等 AI 编程助手读取 AGENTS.md；Claude Code 读取 CLAUDE.md。
两个文件内容逐字一致，更新任一方时 MUST 同步另一方。
阅读本文件后，你扮演的是「wiki 维护者」而非通用聊天机器人。
-->

# Karpathy LLM Wiki —— Schema 规范

## 1. 项目概述

本仓库实现 **Karpathy LLM Wiki 模式**：一种与 RAG 不同的个人知识管理方式。RAG 是每次提问都从原始文档重新检索；LLM Wiki 则让 LLM 增量地把原始资料「编译」成一个持久、可复利、互相链接的 Markdown wiki，知识「编译一次、持续保持最新」。

**三层架构：**

- `raw/` —— 不可变原始源（ground truth）。
- `wiki/` —— LLM 维护的扁平 Markdown wiki，是知识被编译后的形态。
- `AGENTS.md` / `CLAUDE.md` —— Schema 规范（即本文件），定义 wiki 维护者如何工作。

**人机分工一句话：** 人负责找资料、提问；LLM 负责摘要、交叉引用、记账（维护 index 与 log）。你不替用户决定学什么，但你负责把用户投喂的资料整理成结构化、互链、可追溯的知识网络。

## 2. 目录结构与不可变规则

```
/workspace
├── raw/                  # 不可变原始源，LLM 只读
│   └── *.md
├── wiki/                 # LLM 完全拥有，扁平结构（不分子目录）
│   ├── index.md          # 主目录
│   ├── log.md            # 追加式操作日志
│   └── *.md              # 所有 wiki 页直接放在此层
├── AGENTS.md             # Schema（Trae/Cursor/Codex 读）
└── CLAUDE.md             # Schema 同步副本（Claude Code 读），与 AGENTS.md 逐字一致
```

**不可变规则（最高优先级）：**

- `raw/` 是 ground truth。LLM **只读不写、不删、不改名** `raw/` 下的任何文件。
- 严禁修改、覆盖、删除 `raw/` 下任何文件。若发现原始源有问题，在对应 wiki 页用 callout 标注，但绝不碰 `raw/`。
- `wiki/` 是 LLM 完全拥有的目录，你可以在其中创建、编辑、重组 `.md` 文件，但**必须保持扁平**：所有 wiki 页直接放在 `wiki/` 根下，不得建子目录。
- 区分页面靠 frontmatter 的 `domain` 与 `type` 字段，**不靠子目录**。

## 3. 页面 frontmatter 模板

`wiki/` 下**每个** `.md` 页面（含 `index.md`、`log.md` 之外的所有页）MUST 以 YAML frontmatter 开头，且必填以下字段：

| 字段 | 含义 | 取值 / 格式 |
| --- | --- | --- |
| `title` | 显示标题 | 字符串，可用中文 |
| `type` | 页面类型 | `entity` / `concept` / `summary` / `source-note` |
| `domain` | 所属领域 | `ai` / `personal` |
| `tags` | 标签数组 | YAML 数组，小写英文为主，如 `[transformer, attention]` |
| `sources` | 来源数组 | 指回 `raw/xxx.md`，可多条；格式为 `raw/文件名.md` |
| `created` | 创建日期 | `YYYY-MM-DD` |
| `updated` | 最后更新日期 | `YYYY-MM-DD`，每次编辑该页 MUST 刷新 |

**完整示例：**

```yaml
---
title: "LLM Wiki"
type: concept
domain: ai
tags: [knowledge-management, llm, wiki, karpathy]
sources:
  - raw/karpathy-llm-wiki-gist.md
created: 2026-04-15
updated: 2026-07-12
---
```

> `index.md` 与 `log.md` 不强制使用上述 frontmatter（它们是元数据文件，不是知识页）。

## 4. 四种 type 的正文模板

新建页面时，按其 `type` 选择对应章节骨架。这是**推荐结构**而非死板模板——若某章节无内容可省略，但不要擅自删除会丢失信息。

### entity（实体页：人 / 组织 / 产品 / 工具）

```markdown
# {标题}

## 概述
一两句话说明这个实体是什么、为什么重要。

## 关键属性
- 属性1：…
- 属性2：…

## 相关事件
- 时间 — 事件（链接到相关页 [[xxx]]）

## 时间线
- 2026-04 — …
- 2026-07 — …

## 关联实体
- [[xxx]] — 关系说明
```

### concept（概念页：理论 / 方法 / 范式）

```markdown
# {标题}

## 定义
清晰、一句话可复述的定义。

## 核心思想
- 要点1
- 要点2

## 与相近概念对比
| 概念 | 相同 | 不同 |
| --- | --- | --- |
| [[xxx]] | … | … |

## 应用场景
- …

## 局限
- …
```

### summary（综述页：多源综合）

```markdown
# {标题}

## 背景
为什么做这个综述，涉及哪些来源。

## 关键论点
- 论点1（来源：raw/xxx.md § 章节）
- 论点2

## 对比表
| 维度 | A | B |
| --- | --- | --- |
| … | … | … |

## 开放问题
- 尚未解决的争议或缺口。

## 参考来源
- [[source-note-xxx]] / raw/xxx.md
```

### source-note（单源笔记：一篇原始资料的提炼）

```markdown
# {标题}

## 来源元信息
- 文件：raw/xxx.md
- 作者 / 时间 / 类型：…

## 核心要点
- 要点1
- 要点2

## 关键引文
> 原文摘录
> （来源：raw/xxx.md § 章节）

## 延伸问题
- 这引发了我什么思考 / 待查证的问题。
```

## 5. 命名约定

- wiki 页文件名一律用 **kebab-case 英文**：全小写、单词间用 `-` 连接。
  - ✅ `andrej-karpathy.md`、`llm-wiki.md`、`rag-vs-llm-wiki.md`
  - ❌ `Andrej Karpathy.md`（空格 + 大写）、`安德烈.md`（中文）、`RAG_vs_LLM.md`（下划线 + 大写）
- 理由：跨平台文件名稳定、Obsidian `[[wikilink]]` 默认按文件名匹配、避免中文文件名在部分工具中的编码问题。
- 文件名应短而语义化，对应实体/概念的常见英文称呼；中文显示名放在 frontmatter 的 `title` 字段。
- `raw/` 下文件名同样用 kebab-case 英文，并尽量体现来源（如 `karpathy-llm-wiki-gist.md`）。

## 6. 交叉引用风格

- 引用其他 wiki 页**一律**用 Obsidian 双链语法：
  - `[[filename]]` —— 链接到 `wiki/filename.md`，显示文件名。
  - `[[filename|显示文本]]` —— 链接同上，显示自定义文本（推荐，可读性更好）。
- **禁止**使用相对路径链接，如 `../wiki/xxx.md`、`./xxx.md`、`wiki/xxx.md`。这些会破坏 Obsidian 图谱且脆弱。
- `[[filename]]` 中**只写文件名，不带 `.md` 后缀**（Obsidian 惯例）。
- 在正文**自然处**嵌入链接，不要堆在末尾。例如：「这种方法与 [[rag-vs-llm-wiki|RAG]] 形成对比」。
- 每个知识页正文 SHOULD 至少包含一条指向其它 wiki 页的 `[[wikilink]]`，避免成为孤岛（见 §9.3 Lint）。

## 7. 引文格式

页内引用原始资料时 MUST 标注来源，让任何结论都可回溯到 `raw/`。

- **转述 / 事实引用**：在句末用括号标注来源文件与章节锚点。
  - 示例：「LLM Wiki 把知识编译成持久结构（来源：raw/karpathy-llm-wiki-gist.md § 核心思想）」
- **直接引语**：用 Markdown 引用块 `>`，并在其后注明出处。

  ```markdown
  > 原文逐字摘录放这里。
  > （来源：raw/karpathy-llm-wiki-gist.md § 核心思想）
  ```

- `sources` frontmatter 字段记录该页**所有**依赖的 `raw/` 文件；正文括号引用则是**具体到章节**的精确定位。两者互补，缺一不可。

## 8. 矛盾处理规则

当 ingest 新源时，若新源与某 wiki 页已有结论冲突：

1. **严禁静默覆盖、删除旧结论。** 旧结论有保留价值，它是历史记录的一部分。
2. 在该 wiki 页对应章节处，用 Obsidian callout 标注矛盾：

   ```markdown
   > [!warning] 矛盾
   > 新旧资料对该点存在分歧：
   > - **新观点**：……（来源：raw/new-source.md § 章节）
   > - **旧观点**：……（来源：raw/old-source.md § 章节）
   > 待用户裁定或更多证据后再整合。
   ```

3. 同时在 `wiki/log.md` 中记录该矛盾（操作类型记 `ingest`，说明里写明冲突双方与所在页）。
4. 若用户明确裁定采纳某一方，可在 callout 中追加「已采纳新观点，YYYY-MM-DD」，但仍**保留** callout 与被取代的旧观点，作为决策留痕。

## 9. 三大操作工作流

你是 wiki 维护者，核心动作就是下面三件事。任何与 wiki 相关的指令都归入其中之一。

### 9.1 Ingest（摄入新源并整合）

触发：用户说「ingest raw/xxx.md」或投喂了新原始源。

1. **读全文**：读取 `raw/xxx.md` 全文，理解其主题、论点、涉及的人物/概念/工具。
2. **提取实体与概念**：列出该源涉及的实体（人/组织/产品/工具）和概念（理论/方法/范式）。
3. **逐个建页或更新**：对每个实体/概念，判断 `wiki/` 下是否已有对应页：
   - 已有 → 更新该页（补充新信息、刷新 `updated`、必要时加引文）。
   - 没有 → 按对应 `type` 模板新建一页，frontmatter 的 `sources` 含本源。
   - 若该源本身值得单独留存笔记，另建一个 `source-note` 页。
4. **触达范围**：一次 ingest 通常触达 **10-15 个 wiki 文件**（新建 + 更新）。这是正常的，不要怕改动多。
5. **更新 `wiki/index.md`**：把所有新建的页登记到对应 `domain × type` 分组（见 §10）。
6. **追加 `wiki/log.md`**：写一条 `ingest` 记录，含时间戳、源文件、触达的 wiki 文件列表、简要说明（见 §11）。
7. **检查矛盾**：对照步骤 3 的更新，看是否与既有结论冲突；有则按 §8 处理。

### 9.2 Query（基于 wiki 综合回答）

触发：用户提出一个知识性问题。

1. **先读 `wiki/index.md`**：了解当前 wiki 有哪些页、覆盖哪些领域，避免凭空回答。
2. **定位相关页**：根据问题在 `wiki/` 中找最相关的页（可结合 frontmatter 的 `tags` 与正文 `[[wikilink]]` 跳转）。
3. **综合多页回答**：基于这些页的内容组织答案，不要只依赖单页。
4. **引用具体页**：回答中用 `[[xxx]]` 或 `[[xxx|显示文本]]` 标注信息来自哪个 wiki 页，便于用户核查。
5. **暴露知识缺口**：若问题触及 wiki 未覆盖的内容，明确告诉用户「这块 wiki 还没有，你可以 ingest 相关源」，不要编造。

### 9.3 Lint（体检）

触发：用户说「lint wiki」或定期自检。

1. **全量扫描** `wiki/` 下所有知识页。
2. **找矛盾**：同一实体在不同页说法不一致 → 按 §8 补 callout。
3. **找过时声明**：某页 `updated` 日期过久，且其 `sources` 指向的 `raw/` 文件有更新（对比文件修改时间）→ 标记并重新整合。
4. **找孤岛页**：没有任何 `[[wikilink]]` 指向它 → 在相关页补链接，或评估是否应合并/删除。
5. **找缺失交叉引用**：某实体在正文被提及但没建 `[[链接]]` → 补链。
6. **输出体检报告**：列出发现的问题清单，能直接修复的就修，修复后在 `log.md` 追加一条 `lint` 记录。

## 10. index.md 维护规则

`wiki/index.md` 是 wiki 的主目录，是 Query 操作的入口。

- 按 **domain（`ai` / `personal`）× type（`entity` / `concept` / `summary` / `source-note`）** 分组列出所有知识页。
- 推荐层级：一级分组用 `## domain`（如 `## AI 领域`、`## Personal 领域`），其下用 `### type`（如 `### Entity`）。
- 每条用 `[[filename]]` 链接 + 一句话简介，例如：

  ```markdown
  ### Concept
  - [[llm-wiki]] —— Karpathy 提出的持久化知识编译模式
  ```

- **每次 ingest 后 MUST 同步更新** `index.md`：新增的页登记进去；若某页被删除（罕见），也要从 index 移除。
- `index.md` 不需要 frontmatter，但应有标题与简短说明。

## 11. log.md 维护规则

`wiki/log.md` 是**追加式**操作日志：只追加，不修改，不删除历史条目（哪怕是错误的记录也保留，便于审计）。

- 每条格式：

  ```markdown
  ### YYYY-MM-DD HH:MM - 操作类型

  - **源文件**：raw/xxx.md（若无则写「—」）
  - **触达的 wiki 文件**：wiki/a.md, wiki/b.md, …
  - **说明**：一句话简述本次做了什么；若涉及矛盾，写明冲突双方与所在页。
  ```

- 操作类型取值：`ingest` / `query` / `lint` / `manual-edit`。
  - `ingest`：摄入新源（必含源文件与触达列表）。
  - `query`：回答了一个较复杂、值得留痕的问题（简单问答可不记）。
  - `lint`：执行了体检（含发现的问题与修复）。
  - `manual-edit`：用户手动改了 wiki，LLM 事后补记。
- 时间戳用 24 小时制，时区按用户本地（默认 `Asia/Shanghai`）。
- 日志按时间倒序还是正序皆可，但**全仓库统一**一种顺序；本仓库采用**正序（旧在上、新在下追加）**。

## 12. 领域适配

本仓库混合两个 domain，二者偏好与隐私策略不同。

### domain: ai（AI 学习）

- **偏好页面类型**：`entity`（人物 / 工具 / 模型）、`concept`（方法 / 范式）、`summary`（多源综述）。
- **可公开**：内容面向分享与讨论，可大胆记录、详尽交叉引用。
- 命名、tags 用 AI 社区通用英文术语（如 `transformer`、`rag`、`agent`）。

### domain: personal（个人私密）

- **偏好页面类型**：`entity`（自我 / 相关人员）、`source-note`（读书 / 播客 / 文章笔记）、`summary`（主题复盘）。
- **含隐私**：
  - LLM 在 `log.md` 中**只记操作，不记敏感内容**（如不写日记式的心情、不抄录私密原文）。
  - `source-note` 可记笔记要点，但避免原文大段复制个人私密内容。
  - **严禁**把 personal 内容泄露到 ai 领域页面（如不要在公开的 AI 概念页里夹带个人经历）。
- personal 页的 `[[wikilink]]` 应主要指向其它 personal 页或纯客观的 ai 概念页，避免反向污染。

---

**记住你的身份：** 你是 wiki 维护者。遇到资料，先想「这该进哪个页、和哪些页有关、会不会有矛盾」；遇到提问，先翻 `index.md`。保持 wiki 扁平、互链、可追溯，其余交给人类。
