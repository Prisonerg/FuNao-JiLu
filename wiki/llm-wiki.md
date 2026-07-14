---
title: "LLM Wiki"
type: concept
domain: ai
tags: [knowledge-management, rag, agent-memory, karpathy]
sources:
  - raw/karpathy-llm-wiki-gist.md
  - raw/suda-llm-wiki-douyin-2026-06.md
created: 2026-07-12
updated: 2026-07-14
reliability: medium
---

# LLM Wiki

## 定义

LLM Wiki 是一种个人知识管理模式：让 LLM 增量地把原始资料「编译」成一个持久、可复利、互相链接的 Markdown wiki，知识「编译一次、持续保持最新」，从而区别于每次提问都从原始文档重新检索的 [[rag-vs-llm-wiki|RAG]]（来源：raw/karpathy-llm-wiki-gist.md § The core idea）。该模式由 [[andrej-karpathy|Andrej Karpathy]] 提出，本页核心原始源为其发布的 LLM Wiki gist，另见 [[suda-llm-wiki-video|中文社区反响源]]。

## 核心思想

LLM Wiki 建立在三层数据结构之上（来源：raw/karpathy-llm-wiki-gist.md § Architecture）：

- **Raw sources（不可变原始源）**：人工策展的源文档集合（文章、论文、图片、数据文件等）。这是 ground truth，LLM 只读不写、永不修改。
- **The wiki（LLM 维护的 Markdown wiki）**：LLM 生成的 markdown 文件目录，含摘要页、实体页、概念页、对比页、综述页等。这一层完全由 LLM 拥有：它创建页面、在新源到来时更新、维护交叉引用、保持一致性。人读它，LLM 写它。
- **The schema（规范文件）**：一份文档（如 Claude Code 的 CLAUDE.md、Codex / Trae 的 AGENTS.md），告诉 LLM wiki 的结构、命名约定，以及 ingest / query / lint 三大工作流。它使 LLM 成为「有纪律的 wiki 维护者」而非通用聊天机器人，由人与 LLM 协同演化。

与 [[rag-vs-llm-wiki|RAG]] 的本质区别在于知识的存在形态（来源：raw/karpathy-llm-wiki-gist.md § The core idea）：

> Most people's experience with LLMs and documents looks like RAG: you upload a collection of files, the LLM retrieves relevant chunks at query time, and generates an answer. This works, but the LLM is rediscovering knowledge from scratch on every question. There's no accumulation.
> （来源：raw/karpathy-llm-wiki-gist.md § The core idea）

换言之，RAG 是「每次重新检索、每次重新发现」，没有累积；而 LLM Wiki 是「编译一次、持续保持当前」——交叉引用已就位、矛盾已被标注、综述已反映读过的所有内容，每加入一个新源、提出一个新问题，wiki 都变得更丰富。wiki 是一个**持久的、可复利的产物（a persistent, compounding artifact）**。

人机分工一句话：人负责找资料、探索、提问；LLM 负责摘要、交叉引用、记账（维护 index 与 log）等全部 grunt work。Karpathy 用一个精确的隐喻概括这种关系：**Obsidian 是 IDE，LLM 是程序员，wiki 是代码库**——人像看代码一样在 Obsidian 中浏览 wiki，LLM 像程序员一样编辑和维护它（来源：raw/karpathy-llm-wiki-gist.md § The core idea）。这种对比在 [[rag-vs-llm-wiki]] 中有更系统的展开。

## 与相近概念对比

| 概念 | 相同 | 不同 |
| --- | --- | --- |
| [[rag-vs-llm-wiki]] | 都用 LLM 处理原始文档、都支持基于多文档的综合回答 | RAG 在查询时从原始文档重新检索、知识不累积；LLM Wiki 让 LLM 增量编译持久 wiki，知识编译一次、持续保持最新 |
| [[andrej-karpathy]] | —— | LLM Wiki 模式的提出者；其 gist 是本页核心原始源 |
| [[second-brain]] | 都追求知识的持久化与复利累积；都用 Obsidian 等工具承载 | 第二大脑是更广义的 PKM 理念，传统上由人手工维护；LLM Wiki 强调 LLM 承担全部维护 grunt work，是第二大脑在 LLM 时代的实现形态（来源：raw/suda-llm-wiki-douyin-2026-06.md § 章节要点-总述） |

## 应用场景

gist 列举了 LLM Wiki 适用的多种「随时间累积知识并希望被组织而非散落」的场景（来源：raw/karpathy-llm-wiki-gist.md § The core idea）：

- **个人成长（Personal）**：跟踪个人目标、健康、心理、自我提升，归档日记条目、文章、播客笔记，逐步构建关于自己的结构化图景。
- **研究（Research）**：数周或数月深入某个主题，阅读论文、文章、报告，增量构建一个带有演进论点的综合 wiki。
- **读书（Reading a book）**：逐章归档，构建角色、主题、情节线及其关联的页面，最终得到一本丰富的伴读 wiki（类比社区多年协作构建的 Tolkien Gateway 等粉丝 wiki）。
- **商业 / 团队（Business/team）**：由 LLM 维护的内部 wiki，输入来自 Slack 线程、会议纪要、项目文档、客户通话，可加入人工审核环节；wiki 之所以能保持最新，是因为 LLM 承担了团队无人愿做的维护工作。
- **其它**：竞品分析、尽职调查、旅行规划、课程笔记、爱好深挖——任何「随时间累积知识并希望被组织」的场景。

此外，Karpathy 指出 ingest 不限于逐源交互模式——也可以 **batch-ingest** 一次批量摄入多个源，以较少的人工监督完成（来源：raw/karpathy-llm-wiki-gist.md § Operations）。选择哪种模式取决于用户偏好，并可写入 schema 供后续会话使用。

## 中文社区反响（2026-06）

LLM Wiki 模式在中文社区引发了显见的传播与二次创作。2026-06-23，抖音作者「苏大讲AI」发布短视频《完犊子了！卡帕西刚引爆的"LLM Wiki"学习潮！》，把该模式包装为「用 Obsidian + Claude 建立第二大脑」的本土化叙事，获得 1.1 万赞、1.0 万收藏的互动热度（来源：raw/suda-llm-wiki-douyin-2026-06.md § 视频元信息、§ 章节要点-总述）。该视频把 LLM Wiki 与 [[second-brain|第二大脑]] 概念直接绑定，构成中文社区对该模式的典型框架化解读，详见 [[suda-llm-wiki-video|视频笔记页]]。

需注意：视频作者把 [[andrej-karpathy|Karpathy]] 称为「OpenAI 创始人」，属口语化简化（Karpathy 实为 OpenAI 联合创始成员之一）；且视频章节要点为抖音 AI 自动生成、非逐字稿，存在两层 AI 中介化（详见 [[suda-llm-wiki-video]] § 作品元信息）。

## 为什么可行

Karpathy 的核心论点：人类放弃 wiki 是因为维护负担的增长快于价值（来源：raw/karpathy-llm-wiki-gist.md § Why this works）。维护知识库最繁琐的不是阅读或思考，而是记账——更新交叉引用、保持摘要最新、标注新旧矛盾、维持数十个页面的一致。LLM 不会感到无聊、不会忘记更新交叉引用、可以一次触及 15 个文件。**wiki 之所以能保持维护，是因为维护成本趋近于零。**

人的工作是策展来源、指导分析、提出好问题、思考这一切意味着什么。LLM 的工作是其余一切。

这一思想在精神上与 Vannevar Bush 1945 年提出的 **Memex** 概念一脉相承（来源：raw/karpathy-llm-wiki-gist.md § Why this works）：一个私人的、主动策展的知识存储，文档之间通过联想轨迹（associative trails）互联。Bush 的愿景比后来的万维网更接近 LLM Wiki——私有的、主动策展的、文档之间的连接与文档本身同等珍贵。Bush 未能解决的部分是「谁来做维护」；LLM 解决了这个问题。

## 局限

诚实记录该模式的固有局限：

- **知识漂移（drift）**：wiki 是 LLM 对原始源的中介化产物，多次 ingest 与改写后，表述可能偏离 raw 原意；schema 因此强制要求页内引文回溯到 `raw/xxx.md` 的具体章节，但漂移风险无法完全消除。
- **生成效应 / 失真**：LLM 在摘要、综合时可能引入原文没有的措辞或因果链；尤其在多源综合页中，需警惕「流畅但偏离源」的合成结论。
- **矛盾累积成本**：随源增多，新旧资料冲突会增多；schema 的 callout 机制能保留分歧，但若长期不裁定，wiki 会堆叠大量「待裁定」标注，可读性下降。
- **规模上限**：gist 自承基于 index.md 的方案在中等规模（约 100 个源、数百个页面）内效果良好，更大规模需引入专门搜索引擎（如 qmd 的 BM25 / 向量混合检索），并非无限可扩展（来源：raw/karpathy-llm-wiki-gist.md § Indexing and logging、§ Optional: CLI tools）。
- **强依赖 LLM 会话的纪律性**：wiki 的质量取决于 LLM 是否严格遵循 schema；不同模型 / 会话对 schema 的执行一致性问题，需靠 lint 工作流兜底。
- **非实时**：wiki 反映的是最近一次 ingest 的状态，不自动追踪外部世界的变化，需人工触发新源 ingest。

## 时间线

- 2026-07-12 | 首次 ingest 自 raw/karpathy-llm-wiki-gist.md,建立定义、核心思想、应用场景、局限
  （来源：raw/karpathy-llm-wiki-gist.md § The core idea）
- 2026-07-12 09:04 | 补充中文社区反响段,sources 增加抖音源,加 second-brain 对比行
  （来源：raw/suda-llm-wiki-douyin-2026-06.md § 章节要点-总述）
- 2026-07-14 | 修正：updated 字段由误刷的 2026-07-14 回退为真实编辑日 2026-07-12（2026-07-14 07:33 lint 误刷，本次按 §3 新语义回退）
  （来源：本页 frontmatter 核定，参见 log.md 2026-07-14 07:33 lint 条目）
- 2026-07-14 | 修正：对照 Karpathy 原文补全「为什么可行」段（维护成本趋零 + Memex 1945）、强化「Obsidian 是 IDE」隐喻、提及 batch-ingest 模式
  （来源：raw/karpathy-llm-wiki-gist.md § Why this works、§ The core idea）
