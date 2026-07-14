---
name: llm-wiki-ingest
description: 用于向 LLM Wiki 摄入（ingest）新的原始源并整合进现有 wiki。当用户说「ingest raw/xxx」「摄入这篇资料」「把这个文件加进 wiki」「整理一下 raw 里的新文章」，或投喂 URL 链接、提到需要读取 raw/ 下的文件、提取实体概念、更新 wiki 页面时使用。不用于代码任务或与 wiki 无关的普通问题。
---

# LLM Wiki Ingest —— 摄入新源并整合

本 skill 指导你将新原始源摄入（ingest）进 GBrain-core Wiki。你是 wiki 维护者，核心动作是把用户投喂的资料整理成结构化、互链、可追溯、双区分明的知识页面。

**权威依据**：`/workspace/AGENTS.md`（GBrain-core Wiki Schema 规范）。本 skill 是其中 §9.1 的工作流展开，遇到任何未尽事宜以 AGENTS.md 为准。

## 触发条件

用户说以下任一时触发：
- 「ingest raw/xxx.md」「摄入这篇资料」「把这个文件加进 wiki」「整理一下 raw 里的新文章」
- 投喂 URL 链接（走「方式 A：URL 直接 ingest」）
- 将新原始源放入 `raw/` 后告知
- 用户在对话中表达原创框架/命名/洞见（走 §13 original 主动捕获流程）

## 两种触发方式

**方式 A：URL 直接 ingest**（用户授权例外，LLM 可创建 raw 文件）
1. 用户提供 URL，LLM 通过 WebFetch 抓取内容。
2. LLM 将抓取到的内容整理为 raw 格式落盘到 `raw/xxx.md`。**合法性边界**：raw/ 常规为 LLM 只读不写，但 URL 直接 ingest 是用户明确授权的例外——LLM 仅可创建 raw 文件，不可修改或删除已有 raw 文件。落盘的 raw 文件**头部须标注**来源 URL、抓取时间、抓取方式（如 WebFetch/OCR/转写）。
3. raw 文件落盘后，进入下方「通用 ingest 流程」。

**方式 B：raw 文件 ingest**（常规只读）
用户手动将源文件放入 `raw/` 后说「ingest raw/xxx.md」，直接进入「通用 ingest 流程」。

## 通用 ingest 流程

**权威依据**：AGENTS.md §9.1（ingest 8 步工作流）。完整步骤以 AGENTS.md 为准，本节仅列特有注意事项。

### dry-run 预览（MUST 先执行）

在改动任何 wiki 文件之前，先告诉用户本次将触达哪些页面，等用户确认后再执行。格式见 §9.1。若触达范围超过 15 个页面，主动建议分批 ingest。

### 8 步工作流要点

| 步骤 | 关键点 | 权威依据 |
| --- | --- | --- |
| 1. 读全文 | 理解主题、论点、涉及的人物/概念/工具 | §9.1 |
| 2. 判定资料形态 | 媒体作品 → `media`；非媒体文字资料 → `source-note` | §4.0、§4.6、§4.5 |
| 3. 提取实体与概念 | 列出实体（人/组织/产品/工具）与概念（理论/方法/范式） | §4.0 |
| 4. 逐个建页或更新 | 已有页→重写编译真相 + 追加时间线；无页→按 type 模板新建 | §4.1、§4.2-4.7 |
| 5. 更新 index.md | domain × type 分组登记 + 主题 MOC + 标签索引 + 最近更新 | §10 |
| 6. 追加 log.md | `ingest` 记录，含时间戳、源文件、触达列表 | §11 |
| 7. 检查矛盾 | 与既有编译真相冲突 → 按 §8 处理 | §8 |
| 8. 自检 | 见下方 9 项 checklist | §9.1 |

### type 判定（MECE 决策树）

**权威依据**：AGENTS.md §4.0。判定顺序命中即定 type，不再往下：original？→ media？→ source-note？→ entity？→ summary？→ concept？

关键边界：
- 具体某次视频内容进 `media`，不进 concept；视频催生的方法/理论进 `concept`。
- 别人 coin 的概念进 `concept`；用户自己的综合/解读进 `original`（synthesis IS original）。
- `media` 与 `source-note` 按资料形态分流：媒体作品 → media；文字资料 → source-note。两者不重叠。

## 双区结构与通用规则

以下通用规则一律以 AGENTS.md 为准，不在本 skill 重复：
- 双区结构（编译真相重写 / 时间线追加）：**§4.1**
- 矛盾处理（修正条目 + 重写 + callout）：**§8**
- 命名约定（kebab-case 英文、original 用用户原话）：**§5**
- 交叉引用风格（`[[filename]]` / 禁止相对路径 / 正文自然嵌入）：**§6**
- 引文格式（转述标注 § 章节 / 引用块 / sources 三层互补）：**§7**
- frontmatter 必填字段：**§3**
- 领域适配（ai/personal/hobby 的隐私与偏好）：**§12**

## original 主动捕获

**权威依据**：AGENTS.md §13。

用户在对话中表达以下任一形态时，**主动询问**是否记进 wiki 作为 original 页：
- 新颖的框架 / 命名（如「我管这叫 ambition debt」）
- 对他人工作的独到综合 / 解读 / 反驳（synthesis IS original）
- 跨多个实体的模式识别
- 带推理的预测 / 逆向观点

用户同意后：用用户原话的 kebab-case 作文件名与标题；`## 原始表述` 逐字保留用户原话（不润色）；按 §4.7 模板建页；index.md `### Original` 分组登记；log.md 追加 `ingest` 记录（源文件写「User, 对话」）。

不自动捕获 entity / concept / media / source-note（避免噪音）。只有 original 因其高价值且易流失，才主动询问。

## ingest 完成前 MUST 自检（9 项）

任一为否则不允许结束本次 ingest（前 8 项对应 §9.1，第 9 项为本 skill 扩展）：

- [ ] 所有触达页的 frontmatter `sources` 已含本源
- [ ] 所有触达页的 `updated` 已刷新为今日
- [ ] 所有触达页的 `## 时间线` 已追加新条目
- [ ] 新建页已在 index.md 对应 domain × type 分组登记，且 index.md 最近更新已追加新条目、标签索引已刷新
- [ ] log.md 已追加 ingest 条目（含触达文件列表）
- [ ] 每个新建页正文至少 1 条 `[[wikilink]]` 指向其它页
- [ ] 编译真相区已重写整合（非追加旧结论）
- [ ] 矛盾检查已执行（有则按 §8 处理）
- [ ] **raw 本身已有对应 media/source-note 页**（若 raw 是新源，确认该源本身的 media/source-note 页已建立；若该源已是更新已有 raw，确认对应 media/source-note 页的时间线已追加）
