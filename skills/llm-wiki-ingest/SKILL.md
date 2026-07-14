---
name: llm-wiki-ingest
description: 用于向 LLM Wiki 摄入（ingest）新的原始源并整合进现有 wiki。当用户说「ingest raw/xxx」「摄入这篇资料」「把这个文件加进 wiki」「整理一下 raw 里的新文章」，或提到需要读取 raw/ 下的文件、提取实体概念、更新 wiki 页面时使用。不用于代码任务或与 wiki 无关的普通问题。
---

# LLM Wiki Ingest —— 摄入新源并整合

本 skill 指导你将 `raw/` 下的新原始源摄入（ingest）进 GBrain-core Wiki，整合到现有知识网络。你是 wiki 维护者，核心动作是把用户投喂的资料整理成结构化、互链、可追溯、双区分明的知识页面。

**权威依据**：`/workspace/AGENTS.md`（GBrain-core Wiki Schema 规范）。本 skill 是其中 §9.1 的工作流展开，遇到任何未尽事宜以 AGENTS.md 为准。

## 不可变规则（最高优先级）

- `raw/` 是 ground truth，LLM **只读不写、不删、不改名** `raw/` 下任何文件。
- `wiki/` 是 LLM 完全拥有的目录，可创建、编辑、重组 `.md` 文件，但**必须保持扁平**：所有 wiki 页直接放在 `wiki/` 根下，不得建子目录。
- 区分页面靠 frontmatter 的 `domain` 与 `type` 字段，**不靠子目录**。

## 触发条件

用户说以下任一时触发：
- 「ingest raw/xxx.md」「摄入这篇资料」「把这个文件加进 wiki」
- 「整理一下 raw 里的新文章」
- 提到需要读取 `raw/` 下的文件、提取实体概念、更新 wiki 页面
- 用户在对话中表达原创框架/命名/洞见（此时走 §13 original 主动捕获流程，见下文「original 主动捕获」段）

## Ingest 工作流（8 步）

### 步骤 1：读全文

读取 `raw/xxx.md` 全文，理解其主题、论点、涉及的人物/概念/工具。

### 步骤 2：判定资料形态

- **媒体作品**（视频 / 图文 / 播客 / 教程 / 信息图）→ 建 `media` 页
- **非媒体文字资料**（文章 / 论文 / 书籍章节 / gist）→ 建 `source-note` 页

按 §4.0 type 判定测试（MECE 决策树）确定每个知识对象的 type。判定顺序，命中即定 type，不再往下：

1. **original？** —— 用户自己的原创框架 / 命名 / 洞见 / 综合 → `original`
2. **media？** —— 媒体作品本身的客观实体 + 提炼笔记 → `media`
3. **source-note？** —— 非媒体类文字资料的单源提炼笔记 → `source-note`
4. **entity？** —— 有人格 / 品牌 / 组织属性的具象对象（人 / 组织 / 产品 / 工具 / 创作者）→ `entity`
5. **summary？** —— 跨多个原始源的综合综述 → `summary`
6. **concept？** —— 可被多人共享复用的方法 / 理论 / 范式 / 术语 → `concept`

**关键边界**：
- 具体某次视频内容进 `media`，不进 concept；视频催生的方法/理论进 `concept`。
- 别人 coin 的概念进 `concept`；用户自己的综合/解读进 `original`（synthesis IS original）。
- `media` 与 `source-note` 按资料形态分流：媒体作品 → media；文字资料 → source-note。两者不重叠。

### 步骤 3：提取实体与概念

列出该源涉及的实体（人/组织/产品/工具）和概念（理论/方法/范式）。

### 步骤 4：逐个建页或更新

对每个实体/概念，判断 `wiki/` 下是否已有对应页：

**已有页** → 
- **重写编译真相区**（`## 时间线` 以上）整合新信息
- 在 `## 时间线` 追加一条来源条目（格式：`- YYYY-MM-DD HH:MM | 摘要\n  （来源：raw/xxx.md § 章节）`）
- 刷新 frontmatter `updated` 为今日
- 在 `sources` 数组加入本源（若尚未包含）

**没有对应页** → 按对应 type 模板新建一页：
- frontmatter 必填字段：`title`、`type`、`domain`（ai/personal/hobby）、`tags`（小写英文数组）、`sources`（指向 raw/xxx.md）、`created`、`updated`
- 可选字段：`reliability`（high/medium/low；一手权威源为 high，二手转述/UGC/AI 摘要为 medium/low）
- 正文 MUST 包含双区结构（见下文）
- 该源本身另建 `media` 或 `source-note` 页

### 步骤 5：触达范围

一次 ingest 通常触达 **10-15 个 wiki 文件**（新建 + 更新）。这是正常的，不要怕改动多。

### 步骤 6：更新 index.md

把所有新建的页登记到 `wiki/index.md` 对应的 `domain × type` 分组：
- 一级分组：`## AI 领域` / `## Personal 领域` / `## Hobby 领域`
- 二级分组：`### Entity` / `### Concept` / `### Summary` / `### Source-note` / `### Original` / `### Media`
- 每条用 `[[filename]]` 链接 + 一句话简介
- 顶部主题 MOC 视需要增减主题

### 步骤 7：追加 log.md

在 `wiki/log.md` 末尾追加一条 `ingest` 记录：

```markdown
### YYYY-MM-DD HH:MM - Ingest

- **源文件**：raw/xxx.md（新建/已有；注明来源与落盘方式）
- **触达的 wiki 文件**：wiki/a.md, wiki/b.md, …
- **说明**：一句话简述本次做了什么；若涉及矛盾，写明冲突双方与所在页。
```

时间戳用 24 小时制，时区按用户本地（默认 `Asia/Shanghai`）。日志采用正序（旧在上、新在下追加）。

### 步骤 8：检查矛盾

对照步骤 4 的更新，看是否与既有编译真相冲突。有则按矛盾处理规则处理（见下文）。

## 双区结构（所有 type 通用）

每个知识页 MUST 包含「编译真相」与「时间线」双区，用 `## 时间线` 二级标题作为分界：

| 区 | 动作 | 说明 |
| --- | --- | --- |
| 编译真相（`## 时间线` 以上） | **重写** | 当前综合。证据变则重写整合，不追加旧结论。 |
| 时间线（`## 时间线` 以下） | **追加** | 证据链。永不编辑既有条目；信息有误则追加「修正:…」条目。 |

编译真相的每个论断 SHOULD 能追溯到至少一条时间线条目。

## 矛盾处理规则（双区版）

当 ingest 新源时，若新源与某 wiki 页编译真相已有结论冲突：

1. **在时间线追加一条「修正」条目**（永不编辑既有条目）：
   ```markdown
   - 2026-07-12 | 修正：原称「xxx」，新源显示「yyy」
     （来源：raw/new-source.md § 章节）
   ```
2. **重写编译真相区**为最新结论（不保留旧结论在编译真相里，旧结论已永久留存在时间线）。
3. 若矛盾尚未裁定，用 callout 临时标注分歧，裁定后移除并重写。
4. 在 `wiki/log.md` 中记录该矛盾。
5. 若用户明确裁定采纳某方，重写编译真相，移除 callout，在时间线追加裁定条目。

## 命名约定

- wiki 页文件名一律用 **kebab-case 英文**：全小写、单词间用 `-` 连接。
- `original` 页命名用用户原话的 kebab-case（如 `ambition-debt`），保留生动性。
- 中文显示名放在 frontmatter 的 `title` 字段。

## 交叉引用风格

- 引用其他 wiki 页**一律**用 Obsidian 双链语法：`[[filename]]` 或 `[[filename|显示文本]]`。
- `[[filename]]` 中**只写文件名，不带 `.md` 后缀**。
- **禁止**使用相对路径链接（如 `../wiki/xxx.md`）。
- 在正文**自然处**嵌入链接，不要堆在末尾。
- 每个新建页正文 SHOULD 至少包含一条指向其它 wiki 页的 `[[wikilink]]`，避免成为孤岛。

## 引文格式

- **转述 / 事实引用**：句末括号标注 `（来源：raw/xxx.md § 章节）`。
- **直接引语**：用 `>` 引用块，其后注明 `（来源：raw/xxx.md § 章节）`。
- **时间线条目**：每条 MUST 含 `（来源：raw/xxx.md § 章节）`。
- `sources` frontmatter 字段记录该页所有依赖的 `raw/` 文件；正文括号引用是具体到章节的精确定位；时间线条目是事件级的来源留痕。三者互补，缺一不可。

## original 主动捕获

`original` 是 wiki 最易流失的资产。当用户在对话中表达以下任一形态的原创思考时，**主动询问**用户是否记进 wiki：
- 新颖的框架 / 命名（如「我管这叫 ambition debt」）
- 对他人工作的独到综合 / 解读 / 反驳（synthesis IS original）
- 跨多个实体的模式识别
- 带推理的预测 / 逆向观点

用户同意后：
1. 用用户原话的 kebab-case 作为文件名与标题（生动性即概念）。
2. 按 original 模板建页，`## 原始表述` 逐字保留用户原话（不润色）。
3. 在 index.md 的 `### Original` 分组登记。
4. log.md 追加 `ingest` 记录（源文件写「User, 对话」）。

不自动捕获 entity / concept / media / source-note（避免噪音）。只有 original 因其高价值且易流失，才主动询问。

## ingest 完成前 MUST 自检（8 项）

任一为否则不允许结束本次 ingest：

- [ ] 所有触达页的 frontmatter `sources` 已含本源
- [ ] 所有触达页的 `updated` 已刷新为今日
- [ ] 所有触达页的 `## 时间线` 已追加新条目
- [ ] 新建页已在 index.md 对应 domain × type 分组登记
- [ ] log.md 已追加 ingest 条目（含触达文件列表）
- [ ] 每个新建页正文至少 1 条 `[[wikilink]]` 指向其它页
- [ ] 编译真相区已重写整合（非追加旧结论）
- [ ] 矛盾检查已执行（有则按矛盾处理规则处理）

## 领域适配

| domain | 隐私 | 偏好页面类型 | 注意事项 |
| --- | --- | --- | --- |
| ai | 可公开 | entity / concept / summary / original | 命名用 AI 社区通用英文术语 |
| personal | 含隐私 | entity / source-note / media / summary / original | log.md 只记操作不记敏感内容；严禁泄露到 ai 领域页 |
| hobby | 可公开 | entity / concept / media / source-note / summary | 命名用爱好社区通用术语；私密购买记录归 personal |
