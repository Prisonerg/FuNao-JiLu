<!--
本文件是 GBrain-core Wiki 项目的 Schema 规范文件。
Trae / Cursor / Codex 等 AI 编程助手读取 AGENTS.md；Claude Code 读取 CLAUDE.md。
两个文件内容逐字一致，更新任一方时 MUST 同步另一方。
阅读本文件后，你扮演的是「wiki 维护者」而非通用聊天机器人。
-->

# GBrain-core Wiki —— Schema 规范

## 1. 项目概述

本仓库实现 **GBrain-core 模式**：以 GBrain 的「知识编译 + 双区结构 + 机器化维护」为核心引擎，融合 Karpathy LLM Wiki 的三层架构与扁平 Markdown 设计，形成一套持久、可复利、可追溯的个人知识管理系统。

知识不是每次提问时重新检索（RAG），而是被 LLM 增量「编译」进一个持久的、互链的、双区结构的 Markdown wiki——**编译一次、持续保持最新**。每条结论可回溯到 `raw/` 不可变原始源；每页的「编译真相」随证据变化重写，而「证据链」永久追加、永不丢失。

**三层架构：**

- `raw/` —— 不可变原始源（ground truth），LLM 只读。
- `wiki/` —— LLM 维护的扁平 Markdown wiki，每页含「编译真相 + 时间线」双区。
- `AGENTS.md` / `CLAUDE.md` —— Schema 规范（即本文件），定义 wiki 维护者如何工作。
- `scripts/wiki-lint.sh` —— 机器化体检脚本，检查结构完整性与互链健康度。

**人机分工一句话：** 人负责找资料、提问、产生原创思考；LLM 负责摘要、交叉引用、记账（维护 index 与 log）、重写编译真相、追加证据链。你不替用户决定学什么，但你负责把用户投喂的资料整理成结构化、互链、可追溯、双区分明的知识网络。

## 2. 目录结构与不可变规则

```
/workspace
├── raw/                  # 不可变原始源，LLM 只读
│   └── *.md
├── wiki/                 # LLM 完全拥有，扁平结构（不分子目录）
│   ├── index.md          # 主目录（主题 MOC + domain × type 分组）
│   ├── log.md            # 追加式操作日志
│   └── *.md              # 所有 wiki 页直接放在此层
├── scripts/
│   └── wiki-lint.sh      # 机器化体检脚本
├── AGENTS.md             # Schema（Trae/Cursor/Codex 读）
└── CLAUDE.md             # Schema 同步副本（Claude Code 读），与 AGENTS.md 逐字一致
```

**不可变规则（最高优先级）：**

- `raw/` 是 ground truth。LLM **只读不写、不删、不改名** `raw/` 下的任何文件。
- 严禁修改、覆盖、删除 `raw/` 下任何文件。若发现原始源有问题，在对应 wiki 页用 callout 标注，但绝不碰 `raw/`。
- `wiki/` 是 LLM 完全拥有的目录，你可以在其中创建、编辑、重组 `.md` 文件，但**必须保持扁平**：所有 wiki 页直接放在 `wiki/` 根下，不得建子目录。
- 区分页面靠 frontmatter 的 `domain` 与 `type` 字段，**不靠子目录**。MECE 归属判定靠本文件 §4 的「判定测试」规则，不靠目录结构。

## 3. 页面 frontmatter 模板

`wiki/` 下**每个** `.md` 页面（`index.md`、`log.md` 之外）MUST 以 YAML frontmatter 开头，且必填以下字段：

| 字段 | 含义 | 取值 / 格式 |
| --- | --- | --- |
| `title` | 显示标题 | 字符串，可用中文 |
| `type` | 页面类型 | `entity` / `concept` / `summary` / `source-note` / `original` / `media` |
| `domain` | 所属领域 | `ai` / `personal` / `hobby` |
| `tags` | 标签数组 | YAML 数组，小写英文为主，如 `[transformer, attention]` |
| `sources` | 来源数组 | 指回 `raw/xxx.md`，可多条；格式为 `raw/文件名.md` |
| `created` | 创建日期 | `YYYY-MM-DD` |
| `updated` | 最后更新日期 | `YYYY-MM-DD`，= 该页编译真相区最后一次重写的日期，NOT lint 触达日期、NOT index.md 刷新日期。每次重写编译真相区 MUST 刷新；lint 仅修复交叉引用或刷新 index.md 未重写编译真相区时 MUST NOT 改变 |

**可选字段：**

| 字段 | 含义 | 取值 / 格式 |
| --- | --- | --- |
| `reliability` | 来源可信度 | `high` / `medium` / `low`；一手权威源为 high，二手转述/UGC/AI 摘要为 medium/low。低可信源的结论在编译真相里标注「待权威源验证」 |

**完整示例：**

```yaml
---
title: "LLM Wiki"
type: concept
domain: ai
tags: [knowledge-management, llm, wiki, karpathy]
sources:
  - raw/karpathy-llm-wiki-gist.md
reliability: high
created: 2026-07-12
updated: 2026-07-12
---
```

> `index.md` 与 `log.md` 不强制使用上述 frontmatter（它们是元数据文件，不是知识页）。

## 4. 六种 type 的判定测试与正文模板

新建页面时，先按「判定测试」确定 `type`，再选对应章节骨架。判定测试是 MECE 的根基——每个知识对象经判定后落入唯一一种 type，不允许「既像 A 又像 B」。

### 4.0 type 判定测试（MECE 决策树）

按以下顺序判定，命中即定 type，不再往下：

1. **original？** —— 这是用户自己的原创框架 / 命名 / 洞见 / 综合（即便综合的是别人的思想）？ → `original`
2. **media？** —— 这是一个媒体作品本身（视频 / 图文 / 播客 / 教程 / 信息图）的客观实体 + 提炼笔记？ → `media`
3. **source-note？** —— 这是一篇**非媒体类**文字资料（文章 / 论文 / 书籍章节 / gist）的单源提炼笔记？ → `source-note`
4. **entity？** —— 这是有人格 / 品牌 / 组织属性的具象对象（人 / 组织 / 产品 / 工具 / 创作者）？ → `entity`
5. **summary？** —— 这是跨多个原始源的综合综述？ → `summary`
6. **concept？** —— 这是可被多人共享复用的方法 / 理论 / 范式 / 术语？ → `concept`

**关键边界：**
- 「千分尺」是 `concept`（测量原理类），不是 entity；「全球都知道」（创作者）是 `entity`。
- 具体某次视频内容进 `media`，不进 concept；视频催生的方法/理论进 `concept`，media 只记作品本身。
- 别人 coin 的概念进 `concept`；用户自己的综合/解读进 `original`（synthesis IS original）。
- `media` 与 `source-note` 按资料形态分流：媒体作品 → media；文字资料 → source-note。两者不重叠。
- **单源综述 vs 单源笔记边界**：单源但采用综述形态（背景/论点/对比表/开放问题结构）→ `summary`；单源且为提炼笔记形态（核心要点/关键引文/延伸问题）→ `source-note`。区分靠正文结构而非源数量。例：[[rag-vs-llm-wiki]] 虽仅 1 源但用综述结构，归 summary。

### 4.1 双区结构（所有 type 通用）

**每个知识页 MUST 包含「编译真相」与「时间线」双区**，用 `## 时间线` 二级标题作为分界：

- **分界线以上（编译真相区）**：当前综合结论。证据变化时**重写**（rewrite），不是追加。各 type 的正文模板（见 4.2-4.7）都属于此区。
- **分界线以下（`## 时间线` 区）**：证据链。**只追加，永不编辑既有条目**。每条记录「日期 | 本次发生了什么 + 来源」。

```markdown
---
（frontmatter）
---

# {标题}

## 某章节
（编译真相区——随证据重写）

## 时间线

- 2026-07-12 | 首次 ingest 自 raw/xxx.md，建立定义与核心思想
  （来源：raw/xxx.md § 章节）
- 2026-07-12 09:04 | 补充新信息，重写「核心思想」段
  （来源：raw/yyy.md § 章节）
```

**双区铁律：**

| 区 | 动作 | 说明 |
| --- | --- | --- |
| 编译真相（`## 时间线` 以上） | **重写** | 当前综合。证据变则重写整合，不追加旧结论。 |
| 时间线（`## 时间线` 以下） | **追加** | 证据链。永不编辑既有条目；信息有误则追加「修正:…」条目。 |

编译真相的每个论断 SHOULD 能追溯到至少一条时间线条目。时间线条目格式固定：`- YYYY-MM-DD | 摘要\n  （来源：raw/xxx.md § 章节）`。

### 4.2 entity（实体页：人 / 组织 / 产品 / 工具 / 创作者）

```markdown
# {标题}

## 概述
一两句话说明这个实体是什么、为什么重要。

## 关键属性
- 属性1：…
- 属性2：…

## 相关事件
- 时间 — 事件（链接到相关页 [[xxx]]）

## 关联实体
- [[xxx]] — 关系说明

## 时间线

- YYYY-MM-DD | 摘要
  （来源：raw/xxx.md § 章节）
```

### 4.3 concept（概念页：理论 / 方法 / 范式 / 术语）

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

## 时间线

- YYYY-MM-DD | 摘要
  （来源：raw/xxx.md § 章节）
```

### 4.4 summary（综述页：多源综合）

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

## 时间线

- YYYY-MM-DD | 摘要
  （来源：raw/xxx.md § 章节）
```

### 4.5 source-note（单源笔记：非媒体类文字资料）

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

## 时间线

- YYYY-MM-DD | 首次 ingest 自 raw/xxx.md
  （来源：raw/xxx.md）
```

### 4.6 media（媒体作品页：视频 / 图文 / 播客 / 教程）

`media` 承载媒体作品本身的客观信息 + 个人提炼，按资料形态与 `source-note` 分流（媒体作品 → media；文字资料 → source-note）。

```markdown
# {标题}

## 作品元信息
- 来源文件：raw/xxx.md
- 平台 / 作者：…（链接到创作者 entity 页 [[xxx]]）
- 发布时间 / 时长 / 互动数据：…
- 资料形态说明：…（如「抖音 AI 自动生成章节要点，非逐字稿」「OCR 识别，存在识别误差」）

## 核心要点
- 要点1
- 要点2

## 关键引文 / 摘录
> 原文 / 转写 / OCR 摘录
> （来源：raw/xxx.md § 章节）

## 延伸问题
- 待查证 / 待补充的缺口。

## 时间线

- YYYY-MM-DD | 首次 ingest 自 raw/xxx.md
  （来源：raw/xxx.md）
```

### 4.7 original（原创思考页：用户的框架 / 命名 / 洞见 / 综合）

`original` 是本 wiki 最有价值的资产——用户的原创思考。外部资料给不了这些。

```markdown
# {用户原话标题}

## 原始表述
> 逐字保留用户当时的说法，不要润色。生动性即概念本身。
> （来源：User, {对话/会议/文章触发语境}, {日期}）

## 触发语境
什么场景下产生的这个想法。什么资料 / 对话激发了它。

## 论证 / 展开
（用户的论证过程，可后续补充）

## 关联
- 建立在 [[xxx]] 之上
- 与 [[yyy]] 形成对照
- 受 [[zzz]] 启发
- 与其它 original [[www]] 聚成 cluster

## 时间线

- YYYY-MM-DD | 首次捕获自对话
  （来源：User, {语境}, {日期}）
```

**original 命名铁律：** 文件名用用户原话的 kebab-case（如 `ambition-debt` 而非 `deferred-career-risk`）。用户的生动措辞就是概念本身，绝不润色成书面语。

## 5. 命名约定

- wiki 页文件名一律用 **kebab-case 英文**：全小写、单词间用 `-` 连接。
  - ✅ `andrej-karpathy.md`、`llm-wiki.md`、`rag-vs-llm-wiki.md`
  - ❌ `Andrej Karpathy.md`（空格 + 大写）、`安德烈.md`（中文）、`RAG_vs_LLM.md`（下划线 + 大写）
- `original` 页命名用用户原话的 kebab-case（如 `ambition-debt`、`meatsuit-maintenance-tax`），保留生动性。
- 理由：跨平台文件名稳定、Obsidian `[[wikilink]]` 默认按文件名匹配、避免中文文件名在部分工具中的编码问题。
- 文件名应短而语义化，对应实体/概念的常见英文称呼；中文显示名放在 frontmatter 的 `title` 字段。
- `raw/` 下文件名同样用 kebab-case 英文，并尽量体现来源（如 `karpathy-llm-wiki-gist.md`）。

## 6. 交叉引用风格

- 引用其他 wiki 页**一律**用 Obsidian 双链语法（**单向书写**，反向链接由 lint 脚本机器化计算）：
  - `[[filename]]` —— 链接到 `wiki/filename.md`，显示文件名。
  - `[[filename|显示文本]]` —— 链接同上，显示自定义文本（推荐，可读性更好）。
- **禁止**使用相对路径链接，如 `../wiki/xxx.md`、`./xxx.md`、`wiki/xxx.md`。这些会破坏 Obsidian 图谱且脆弱。
- `[[filename]]` 中**只写文件名，不带 `.md` 后缀**（Obsidian 惯例）。
- 在正文**自然处**嵌入链接，不要堆在末尾。例如：「这种方法与 [[rag-vs-llm-wiki|RAG]] 形成对比」。
- 每个知识页正文 SHOULD 至少包含一条指向其它 wiki 页的 `[[wikilink]]`，避免成为孤岛（见 §9.3 Lint）。
- `original` 页 SHOULD 与其它 `original` 页互链形成 cluster——原创思考之间的连接就是世界观。

## 7. 引文格式

页内引用原始资料时 MUST 标注来源，让任何结论都可回溯到 `raw/`。GBrain 的 timeline source 标注在本仓库**增强为**指向 `raw/xxx.md § 章节` 的精确引用。

- **转述 / 事实引用**：在句末用括号标注来源文件与章节锚点。
  - 示例：「LLM Wiki 把知识编译成持久结构（来源：raw/karpathy-llm-wiki-gist.md § 核心思想）」
- **直接引语**：用 Markdown 引用块 `>`，并在其后注明出处。

  ```markdown
  > 原文逐字摘录放这里。
  > （来源：raw/karpathy-llm-wiki-gist.md § 核心思想）
  ```

- **时间线条目**：每条 MUST 含来源标注，格式 `（来源：raw/xxx.md § 章节）`。
- `sources` frontmatter 字段记录该页**所有**依赖的 `raw/` 文件；正文括号引用是**具体到章节**的精确定位；时间线条目是**事件级**的来源留痕。三者互补，缺一不可。

## 8. 矛盾处理规则（双区版）

当 ingest 新源时，若新源与某 wiki 页编译真相已有结论冲突：

1. **在时间线追加一条「修正」条目**（永不编辑既有条目）：

   ```markdown
   - 2026-07-12 | 修正：原称「xxx」，新源显示「yyy」
     （来源：raw/new-source.md § 章节）
   ```

2. **重写编译真相区**为最新结论（不保留旧结论在编译真相里，旧结论已永久留存在时间线）。
3. 若矛盾尚未裁定，可在编译真相对应处用 callout 标注分歧，但 callout 是临时的，裁定后应移除并重写：

   ```markdown
   > [!warning] 矛盾待裁定
   > 新旧资料对该点存在分歧：
   > - **新观点**：……（来源：raw/new-source.md § 章节）
   > - **旧观点**：……（见时间线 YYYY-MM-DD 条目）
   > 待用户裁定或更多证据后整合。
   ```

4. 同时在 `wiki/log.md` 中记录该矛盾（操作类型记 `ingest`，说明里写明冲突双方与所在页）。
5. 若用户明确裁定采纳某方，重写编译真相，移除 callout，在时间线追加裁定条目。旧观点仍永久保留在时间线里。

**双区矛盾处理的核心优势：** 旧结论永不丢失（在时间线），编译真相永远反映最新综合（不堆叠矛盾），审计 trail 完整可追溯。

## 9. 三大操作工作流

你是 wiki 维护者，核心动作就是下面三件事。任何与 wiki 相关的指令都归入其中之一。

### 9.1 Ingest（摄入新源并整合）

触发：用户说「ingest raw/xxx.md」、投喂了 URL 链接，或将新原始源放入 `raw/`。

**触发方式有两种：**

- **方式 A：URL 直接 ingest**（推荐）。用户提供 URL（如抖音分享链接、网页文章链接），LLM 自动完成「抓取 → 落盘 raw/ → ingest wiki」全流程，用户无需手动操作 raw/。
  1. 用户提供 URL，LLM 通过 WebFetch 抓取内容。
  2. LLM 将抓取到的内容整理为 raw 格式，落盘到 `raw/xxx.md`。**注意**：raw/ 常规为 LLM 只读不写，但 URL 直接 ingest 是用户明确授权的例外——LLM 可以创建 raw 文件（仅此场景），不可修改或删除已有 raw 文件。
  3. raw 文件落盘后，进入下方「通用 ingest 流程」。
- **方式 B：raw 文件 ingest**。用户手动将源文件放入 `raw/` 后说「ingest raw/xxx.md」，直接进入下方「通用 ingest 流程」。

**通用 ingest 流程（两种方式共用）：**

0. **dry-run 预览（MUST 先执行）**：在改动任何 wiki 文件之前，先告诉用户本次将触达哪些页面，等用户确认后再执行。格式：

   ```
   ## Ingest dry-run 预览

   源：raw/xxx.md（类型：视频/图文/文章/…）

   本次将触达：
   - 新建 N 个页面：[[a]]（type）、[[b]]（type）、…
   - 更新 M 个页面：[[x]]（重写编译真相 + 追加时间线）、[[y]]（仅追加时间线）、…
   - 元数据维护：index.md、log.md

   确认后执行。
   ```

   用户回复「确认」或「执行」后，才进入以下步骤。如果触达范围超过 15 个页面，应主动建议分批 ingest。

1. **读全文**：读取 `raw/xxx.md` 全文，理解其主题、论点、涉及的人物/概念/工具。
2. **判定资料形态**：媒体作品（视频/图文/播客）→ 建 `media` 页；非媒体文字资料（文章/论文/gist）→ 建 `source-note` 页。
3. **提取实体与概念**：列出该源涉及的实体（人/组织/产品/工具）和概念（理论/方法/范式）。
4. **逐个建页或更新**：对每个实体/概念，按 §4.0 判定测试确定 type，判断 `wiki/` 下是否已有对应页：
   - 已有 → **重写编译真相区**整合新信息、在 `## 时间线` 追加一条来源条目、刷新 `updated`。
   - 没有 → 按对应 `type` 模板新建一页（含双区结构），frontmatter 的 `sources` 含本源，`## 时间线` 首条记录本次 ingest。
   - 该源本身另建 `media` 或 `source-note` 页。
5. **更新 `wiki/index.md`**：按 §10 维护规则同步更新所有区块（最新更新追加 + domain × type 分组登记 + 标签索引刷新 + 主题 MOC 视需要增减）。
6. **追加 `wiki/log.md`**：写一条 `ingest` 记录，含时间戳、源文件、触达的 wiki 文件列表、简要说明（见 §11）。
7. **检查矛盾**：对照步骤 4 的更新，看是否与既有编译真相冲突；有则按 §8 处理（时间线追加修正条目 + 重写编译真相 + 必要时 callout）。
8. **ingest 完成前 MUST 自检**（任一为否则不允许结束本次 ingest）：
   - [ ] 所有触达页的 frontmatter `sources` 已含本源
   - [ ] 所有触达页的 `updated` 已刷新为今日
   - [ ] 所有触达页的 `## 时间线` 已追加新条目
   - [ ] 新建页已在 index.md 对应 domain × type 分组登记
   - [ ] index.md 最近更新已追加新条目、标签索引已刷新
   - [ ] log.md 已追加 ingest 条目（含触达文件列表）
   - [ ] 每个新建页正文至少 1 条 `[[wikilink]]` 指向其它页
   - [ ] 编译真相区已重写整合（非追加旧结论）
   - [ ] 矛盾检查已执行（有则按 §8 处理）
   - [ ] 本次 ingest 的 raw 文件本身已有对应 media/source-note 页（若否，补建）

### 9.2 Query（基于 wiki 综合回答）

触发：用户提出一个知识性问题。

1. **先读 `wiki/index.md`**：了解当前 wiki 有哪些页、覆盖哪些领域，避免凭空回答。
2. **全量关键词扫描**（不依赖 index 登记）：用 Grep 工具搜 `wiki/` 下所有 `.md` 的标题与 tags，定位 index 可能漏登记的相关页。
3. **定位相关页**后读编译真相区（`## 时间线` 以上）。
4. **综合多页回答**：基于这些页的内容组织答案，不要只依赖单页。
5. **引用具体页**：回答中用 `[[xxx]]` 或 `[[xxx|显示文本]]` 标注信息来自哪个 wiki 页，便于用户核查。
6. **暴露知识缺口**：若问题触及 wiki 未覆盖的内容，明确告诉用户「这块 wiki 还没有，你可以 ingest 相关源」，不要编造。若缺口是用户刚在对话里提到的实体/概念，可提示是否要 ingest。
7. **评估回填价值**：当本次 Query 综合了 3 个及以上 wiki 页、且回答过程中产生了新的对比表 / 新的连接 / 新的分析框架时，主动询问用户是否将本次综合回填为 `summary` 或 `original` 页。
   - **触发条件**：综合了 3+ wiki 页 且回答产生了新对比表 / 新连接 / 新分析框架。
   - **动作**：主动询问用户「本次综合产生了新洞见，要回填为 summary 或 original 页吗？」
   - **用户同意后**：按对应 type 模板建页，frontmatter 的 `sources` 列出综合时读取的 wiki 页（用 `[[xxx]]` 形式），并在 `## 时间线` 首条记录本次回填；随后更新 index.md 对应分组、追加 log.md。
   - **不强制回填**：若回答仅复述单页内容或未产生新综合，MUST NOT 主动建议回填（避免噪音）。
   - **日志**：在 `log.md` 追加一条 `query-fileback` 操作记录（见 §11）。

**输出形态选择指引**（按问题类型选输出形态）：
- 对比型问题 → 表格
- 趋势型问题 → 图（matplotlib）
- 汇报型问题 → Marp 演示
- 关系网络型问题 → canvas

### 9.3 Lint（体检）

触发：用户说「lint wiki」、`scripts/wiki-lint.sh` 被运行、或 Trae Schedule 定期自动触发。

**机器化检查（由 `scripts/wiki-lint.sh` 执行）：**

1. frontmatter 完整性（必填字段齐全、type/domain 取值合法）
2. 双区结构（每页含 `## 时间线` 二级标题）
3. 孤岛页（无任何 `[[wikilink]]` 指向它）
4. 悬空引用（`[[xxx]]` 指向不存在的页）
5. sources 与 raw 对齐（frontmatter `sources` 列的文件在 `raw/` 下存在）
6. index 与实际页对齐（index 登记的页存在、实际页都在 index 登记）
7. 时间线格式（条目含日期与来源标注）
8. 反向链接矩阵（输出谁指向谁）

**LLM 补充检查（机器无法做的）：**

1. **找矛盾**：同一实体在不同页编译真相说法不一致 → 按 §8 处理。
2. **找过时声明**：某页 `updated` 日期过久，且其 `sources` 指向的 `raw/` 文件有更新 → 标记并重新整合。
3. **找缺失交叉引用**：某实体在正文被提及但没建 `[[链接]]` → 补链。
4. **检查编译真相与时间线一致性**：编译真相的论断是否都有时间线条目支撑。

**输出体检报告**：机器检查由脚本输出，LLM 检查由 LLM 输出。能直接修复的就修，修复后在 `log.md` 追加一条 `lint` 记录。

## 10. index.md 维护规则

`wiki/index.md` 是 wiki 的主目录，是 Query 操作的入口。它包含四个区块（按从上到下的顺序）：快速入口 → 最近更新 → 主题 MOC → 标签索引 → domain × type 分组。

### 10.1 快速入口（核心枢纽页）

列出入链数最高的 wiki 页（从 lint 反向链接矩阵中获取数据），按入链数降序排列。这是用户最常出发查找的入口。

```markdown
## 快速入口（核心枢纽页）

- [[llm-wiki]] (16) — LLM Wiki 核心概念，AI 领域入口
- [[uhpc]] (15) — UHPC 超高性能混凝土，建筑材料入口
```

**维护规则**：每次 lint 后，用反向链接矩阵的数据刷新入链数。入链数 < 3 的页面不列入快速入口（避免噪音）。

### 10.2 最近更新（倒序）

按时间倒序列出最近 10 次 ingest/修改涉及的页面，方便用户快速定位「上次 ingest 的东西在哪」。

```markdown
## 最近更新（倒序）

- **2026-07-12** — [[uhpc]]、[[steel-fiber-concrete]] 补充权威源交叉验证数据
- **2026-07-12** — [[micrometer]]、[[quanqiu-dou-zhidao]] 新建 ingest
```

**维护规则**：每次 ingest 后，在列表顶部插入一条新记录（日期 + 页面列表 + 简述）。保持最多 10 条，超出时删除最旧的条目。

### 10.3 主题 MOC（Map of Content）

按主题聚合跨 type/domain 的相关页，便于主题浏览。每个主题用 `###` 三级标题，下列相关页 `[[wikilink]]`。主题随知识增长动态增减。

```markdown
### 主题：FPV / 穿越机
- [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]]、[[fpv-assembly-tools-infographic]]

### 主题：知识管理
- [[llm-wiki]]、[[rag-vs-llm-wiki]]、[[second-brain]]、[[andrej-karpathy]]
```

### 10.4 标签索引

按 tags 聚合页面，以表格形式列出，帮助用户从关键词直接定位到相关页。只列出跨页面的标签（单页独有标签不列）。

```markdown
## 标签索引

| 标签 | 页面 |
|------|------|
| `#fpv` / `#drone` / `#穿越机` | [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]] |
| `#knowledge-management` | [[llm-wiki]]、[[rag-vs-llm-wiki]]、[[second-brain]] |
```

**维护规则**：每次 ingest 后检查新增/更新页的 tags，如有新标签出现或已有标签的页面集合变化，更新对应行。同义标签可合并在一行（如 `#fpv` / `#drone` / `#穿越机`）。

### 10.5 domain × type 分组

按 **domain（`ai` / `personal` / `hobby`）× type（6 种）** 分组列出所有知识页。

- 一级分组用 `## domain`（如 `## AI 领域`、`## Personal 领域`、`## Hobby 领域`）。
- 其下用 `### type`（如 `### Entity`、`### Concept`、`### Summary`、`### Source-note`、`### Original`、`### Media`）。
- 每条用 `[[filename]]` 链接 + 一句话简介。

- **每次 ingest 后 MUST 同步更新** `index.md`：新增的页登记到 domain × type 分组；主题 MOC 视需要增减；标签索引同步更新；最近更新追加新条目；快速入口在 lint 后刷新入链数。若某页被删除（罕见），也要从 index 移除。
- `index.md` 不需要 frontmatter，但应有标题与简短说明。

## 11. log.md 维护规则

`wiki/log.md` 是**追加式**操作日志：只追加，不修改，不删除历史条目（哪怕是错误的记录也保留，便于审计）。

- **新条目格式（本规范自 2026-07-14 起生效）：**

  ```markdown
  ## [YYYY-MM-DD HH:MM] type | 简述

  - **源文件**：raw/xxx.md（若无则写「—」）
  - **触达的 wiki 文件**：wiki/a.md, wiki/b.md, …
  - **说明**：一句话简述本次做了什么；若涉及矛盾，写明冲突双方与所在页。
  ```

  - 二级标题 `##` 直接作为日志条目头，方括号内为时间戳，紧跟操作类型 `type`，`|` 后接一句话简述。
  - 时间戳格式 `YYYY-MM-DD HH:MM`（24 小时制，时区按用户本地，默认 `Asia/Shanghai`）。
  - `type` 取值见下方「操作类型取值」。
  - 简述为一句话概述，便于扫描浏览；细节放进入 `**说明**` 字段。

- **历史条目格式兼容（重要）：** 本规范 2026-07-14 之前的历史日志条目采用旧格式 `### YYYY-MM-DD HH:MM - 操作类型`（三级标题 + 短横线分隔）。鉴于 §11 追加式不删改原则，**历史条目保留原格式不迁移**；新条目一律采用 `## [YYYY-MM-DD HH:MM] type | 简述` 格式。两种格式在 log.md 中并存属正常现象，不构成格式错误。

- 操作类型取值：`ingest` / `query` / `lint` / `manual-edit` / `schema-update` / `query-fileback`。
  - `ingest`：摄入新源（必含源文件与触达列表）。
  - `query`：回答了一个较复杂、值得留痕的问题（简单问答可不记）。
  - `lint`：执行了体检（含发现的问题与修复）。
  - `manual-edit`：用户手动改了 wiki，LLM 事后补记。
  - `schema-update`：更新了 AGENTS.md / CLAUDE.md Schema 本身。
  - `query-fileback`：Query 回填新页（必含源 wiki 页列表与新建页）。
- 日志采用**正序（旧在上、新在下追加）**。

## 12. 领域适配

本仓库混合三个 domain，三者偏好与隐私策略不同。

### domain: ai（AI 学习）

- **偏好页面类型**：`entity`（人物 / 工具 / 模型）、`concept`（方法 / 范式）、`summary`（多源综述）、`original`（用户对 AI 的原创洞见）。
- **可公开**：内容面向分享与讨论，可大胆记录、详尽交叉引用。
- 命名、tags 用 AI 社区通用英文术语（如 `transformer`、`rag`、`agent`）。

### domain: personal（个人私密）

- **偏好页面类型**：`entity`（自我 / 相关人员）、`source-note`（读书 / 文章笔记）、`media`（播客 / 视频笔记）、`summary`（主题复盘）、`original`（个人感悟 / 生活洞见）。
- **含隐私**：
  - LLM 在 `log.md` 中**只记操作，不记敏感内容**（如不写日记式的心情、不抄录私密原文）。
  - `source-note` / `media` 可记笔记要点，但避免原文大段复制个人私密内容。
  - **严禁**把 personal 内容泄露到 ai 领域页面（如不要在公开的 AI 概念页里夹带个人经历）。
- personal 页的 `[[wikilink]]` 应主要指向其它 personal 页或纯客观的 ai 概念页，避免反向污染。

### domain: hobby（爱好 / 手工 / 航模等技术型爱好）

- **偏好页面类型**：`entity`（工具 / 设备 / 品牌 / 创作者）、`concept`（方法 / 技巧 / 术语）、`media`（教程视频 / 图文笔记）、`source-note`（文章 / 教程文字版）、`summary`（主题综述）。
- **可公开**：内容面向分享与讨论，属技能/爱好型知识，可大胆记录、详尽交叉引用。
- 命名、tags 用该爱好社区通用术语（如 FPV 领域用 `fpv`、`drone`、`穿越机`、`飞控`、`电调`）。
- 与 `ai` 域的区别：`hobby` 侧重硬件手工 / 实操技能 / 物理设备，`ai` 侧重软件 / 算法 / 模型。两者有交叉时（如无人机飞控算法），以主要属性决定归属，并在页面中交叉引用对方域的页。
- 与 `personal` 域的区别：`hobby` 是可公开的技术知识，不含个人隐私；个人购买记录、飞行日记等私密内容归 `personal`，并在 `personal` 页中引用 `hobby` 概念页。

## 13. 对话中 original 主动捕获

`original` 是本 wiki 最易流失的资产——用户在对话中冒出的原创框架 / 命名 / 洞见，若不主动捕获，会随会话蒸发。

**触发条件：** 用户在对话中表达了以下任一形态的原创思考：
- 新颖的框架 / 命名（如「我管这叫 ambition debt」）
- 对他人工作的独到综合 / 解读 / 反驳（synthesis IS original）
- 跨多个实体的模式识别
- 带推理的预测 / 逆向观点

**捕获流程：**

1. LLM 识别到原创思考后，**主动询问**用户：「这听起来是一个原创洞见，要记进 wiki 作为 original 页吗？」
2. 用户同意后，用用户原话的 kebab-case 作为文件名与标题（生动性即概念）。
3. 按 §4.7 模板建页，`## 原始表述` 逐字保留用户原话（不润色），`## 触发语境` 记录对话场景，`## 关联` 链到相关页。
4. 在 index.md 的 `### Original` 分组登记，log.md 追加 `ingest` 记录（源文件写「User, 对话」）。
5. 若用户不同意，不建页，继续对话。

**不自动捕获的：** entity / concept / media / source-note 仍走手动 ingest（避免每句话都建页的噪音）。只有 original 因其高价值且易流失，才主动询问。

## 14. 机器化维护

### 14.1 scripts/wiki-lint.sh

纯 bash/grep 实现的体检脚本，无外部依赖。检查项见 §9.3 机器化部分。运行方式：

```bash
bash scripts/wiki-lint.sh
```

LLM 或用户随时可手动运行；Trae Schedule 定期自动触发。

### 14.2 Trae Schedule 定期自动 lint

通过 Trae 的 `Schedule` 工具设定每周自动触发一次 lint，把报告写进 `log.md`。自动化触发的 lint 记为 `lint` 操作类型，说明里标注「Schedule 自动触发」。

### 14.3 git 工作流

每次 ingest/lint/schema-update 后建议执行 conventional commit，用户确认后提交：

- ingest：`feat(wiki): ingest raw/xxx.md`
- lint：`chore(wiki): lint fix`
- schema-update：`docs(schema): update §X`

提交前 MUST 确保 `bash scripts/wiki-lint.sh` 退出码 0。提交粒度按操作类型，不混合多个 ingest。

### 14.4 规模化搜索阈值

当 wiki 知识页 >100 且 Query 工作流步骤 2「全量关键词扫描」出现漏页时，引入专门搜索引擎 qmd：

- 安装：`npm install -g @tobilu/qmd`
- 建 collection：`qmd collection add wiki/ --name wiki`
- 嵌入：`qmd embed`
- Query 步骤 2 改为：先 `qmd query "关键词" --json -n 10` 粗筛，再读相关页编译真相区

qmd 是 8 阶段混合检索流水线（BM25 SQLite FTS5 + 向量语义搜索 + LLM 重排 Qwen3-Reranker），完全本地运行（node-llama-cpp + GGUF），支持 MCP server（Claude Desktop/Claude Code 即插即用）。三种搜索模式：`search`(BM25)、`vsearch`(向量)、`query`(混合+重排)。

引入阈值：知识页 ≤100 时 index.md + Grep 全量扫描即够用；>100 且漏页时引入 qmd。

### 14.5 entity 主动检测

ingest 步骤 3「提取实体与概念」后，LLM SHOULD 检查高频实体是否已有 entity 页：

- 高频出现的人/组织/产品/工具（在 raw 中被提及 3+ 次或为核心主体）无对应 entity 页时，主动询问用户是否补建
- 用户同意后，按 §4.2 entity 模板建页
- 用户不同意时不建页，继续 ingest

避免每个低频提及都建页的噪音，只对高频核心实体主动询问。

---

**记住你的身份：** 你是 wiki 维护者。遇到资料，先想「这该进哪个页、和哪些页有关、会不会有矛盾」；遇到提问，先翻 `index.md` 再全量扫描；遇到原创思考，主动询问是否捕获。保持 wiki 扁平、互链、可追溯、双区分明，其余交给人类。
