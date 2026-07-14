# Wiki 主目录

这是 wiki 主目录，包含四个部分：
1. **快速入口** — 按入链数排序的核心枢纽页（你最常从这里出发）
2. **最近更新** — 最近 10 次 ingest/修改的页面（按更新时间倒序）
3. **主题地图（MOC）** — 按主题聚合跨 domain/type 的相关页
4. **domain × type 分组** — 完整的分类列表

每次 ingest 后 LLM 会同步更新本目录；Query 操作时 LLM 会先读本目录定位相关页。链接用 Obsidian `[[wikilink]]` 语法（不带 `.md` 后缀）。

## 快速入口（核心枢纽页）

按入链数（其他页面指向它的次数）排序，这些是知识网络的核心节点，从这里出发能找到大部分内容：

- [[llm-wiki]] (16) — LLM Wiki 核心概念，AI 领域入口
- [[uhpc]] (15) — UHPC 超高性能混凝土，建筑材料入口
- [[steel-fiber-concrete]] (14) — 钢纤维混凝土，增韧增强理论
- [[concrete-patch-repair]] (10) — 混凝土修补工艺
- [[andrej-karpathy]] (10) — Andrej Karpathy，LLM Wiki 提出者
- [[zhao-laoshi-jianzhu-keji-yuan]] (10) — 赵老师-建筑科技研究院，抖音建筑材料创作者
- [[uhpc-steel-fiber-repair-douyin-2026-07]] (8) — UHPC 钢纤维修补配比视频笔记
- [[compressive-strength]] (8) — 抗压强度，混凝土核心力学性能
- [[second-brain]] (7) — 第二大脑，PKM 概念，LLM Wiki 本土化框架
- [[rag-vs-llm-wiki]] (9) — RAG vs LLM Wiki 系统对比
- [[suda-llm-wiki-video]] (7) — 苏大讲AI LLM Wiki 学习潮视频笔记

## 最近更新（倒序）

- **2026-07-12** — [[uhpc]]、[[steel-fiber-concrete]]、[[concrete-patch-repair]]、[[compressive-strength]]、[[zhao-laoshi-jianzhu-keji-yuan]]、[[uhpc-steel-fiber-repair-douyin-2026-07]] 补充权威源交叉验证数据
- **2026-07-12** — [[uhpc]]、[[steel-fiber-concrete]]、[[concrete-patch-repair]]、[[compressive-strength]]、[[zhao-laoshi-jianzhu-keji-yuan]]、[[uhpc-steel-fiber-repair-douyin-2026-07]] 新建 ingest
- **2026-07-12** — [[micrometer]]、[[quanqiu-dou-zhidao]]、[[micrometer-usage-douyin-2026-06]] 新建 ingest
- **2026-07-12** — [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]]、[[fpv-assembly-tools-infographic]] 新建 ingest
- **2026-07-12** — [[baby-cry-locate-itch]]、[[nuan-nuan-baby-cry-scratch-video]] 新建 ingest
- **2026-07-12** — [[llm-wiki]]、[[andrej-karpathy]]、[[second-brain]]、[[suda-llm-wiki-video]] 首次 ingest

## 主题地图（MOC）

按主题聚合跨 type/domain 的相关页，便于主题浏览。

### 主题：知识管理 / LLM Wiki
- [[llm-wiki]]、[[rag-vs-llm-wiki]]、[[second-brain]]、[[andrej-karpathy]]、[[suda-llm-wiki-video]]

### 主题：FPV / 穿越机
- [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]]、[[fpv-assembly-tools-infographic]]

### 主题：精密量具 / 测量
- [[micrometer]]、[[quanqiu-dou-zhidao]]、[[micrometer-usage-douyin-2026-06]]

### 主题：建筑材料 / 工程材料
- [[uhpc]]、[[steel-fiber-concrete]]、[[concrete-patch-repair]]、[[compressive-strength]]、[[zhao-laoshi-jianzhu-keji-yuan]]、[[uhpc-steel-fiber-repair-douyin-2026-07]]

### 主题：育儿 / 婴儿护理
- [[baby-cry-locate-itch]]、[[nuan-nuan-baby-cry-scratch-video]]

---

## 标签索引

按标签聚合，帮助你从关键词直接定位到相关页：

| 标签 | 页面 |
|------|------|
| `#fpv` / `#drone` / `#穿越机` | [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]]、[[fpv-assembly-tools-infographic]] |
| `#knowledge-management` / `#llm-wiki` / `#pkm` | [[llm-wiki]]、[[rag-vs-llm-wiki]]、[[second-brain]]、[[andrej-karpathy]] |
| `#concrete` / `#建筑材料` / `#工程材料` | [[uhpc]]、[[steel-fiber-concrete]]、[[concrete-patch-repair]]、[[compressive-strength]] |
| `#micrometer` / `#千分尺` / `#precision-measurement` | [[micrometer]]、[[quanqiu-dou-zhidao]]、[[micrometer-usage-douyin-2026-06]] |
| `#parenting` / `#baby-cry` | [[baby-cry-locate-itch]]、[[nuan-nuan-baby-cry-scratch-video]] |
| `#douyin` / `#content-creator` | [[suda-llm-wiki-video]]、[[secret-fpv-pilot]]、[[quanqiu-dou-zhidao]]、[[zhao-laoshi-jianzhu-keji-yuan]] |
| `#karpathy` / `#openai` / `#ai-educator` | [[andrej-karpathy]]、[[llm-wiki]] |
| `#douyin` / `#科普` / `#science-popularization` | [[quanqiu-dou-zhidao]]、[[micrometer-usage-douyin-2026-06]] |
| `#UHPC` / `#钢纤维` / `#steel-fiber` | [[uhpc]]、[[steel-fiber-concrete]]、[[uhpc-steel-fiber-repair-douyin-2026-07]] |
| `#concrete-repair` / `#修补` / `#应急维修` | [[concrete-patch-repair]]、[[uhpc-steel-fiber-repair-douyin-2026-07]] |

---

## AI 领域

### Entity
- [[andrej-karpathy]] —— OpenAI 联合创始成员、前 Tesla AI 总监、AI 教育者，LLM Wiki 模式提出者

### Concept
- [[llm-wiki]] —— Karpathy 提出的持久化知识编译模式，与 RAG 形成对比
- [[second-brain]] —— 个人知识管理理念，中文社区对 LLM Wiki 的本土化框架表述

### Summary
- [[rag-vs-llm-wiki]] —— RAG 与 LLM Wiki 两种知识管理范式的系统对比（含对比表）

### Source-note
- 暂无

### Original
- 暂无（用户在对话中产生原创洞见时，LLM 会主动询问是否捕获）

### Media
- [[suda-llm-wiki-video]] —— 抖音「苏大讲AI」科普视频：2026-06 中文社区对 LLM Wiki 学习潮的反响

## Personal 领域

### Entity
- 暂无

### Concept
- [[baby-cry-locate-itch]] —— 经验性排查技巧：排除吃喝拉撒后全身挠一遍，以哭闹停止定位婴儿痒点

### Summary
- 暂无

### Source-note
- 暂无

### Original
- 暂无

### Media
- [[nuan-nuan-baby-cry-scratch-video]] —— 抖音「暖暖小星球」带娃妙招视频：宝宝哭闹全身挠一遍定位痒点

## Hobby 领域

### Entity
- [[secret-fpv-pilot]] —— 抖音穿越机/FPV 领域内容创作者，发布装机工具图文
- [[quanqiu-dou-zhidao]] —— 抖音科普动画创作者，作品覆盖精密量具（千分尺、游标卡尺）使用方法
- [[zhao-laoshi-jianzhu-keji-yuan]] —— 抖音建筑科技领域创作者，分享 UHPC/混凝土修补等工程材料配比

### Concept
- [[fpv-drone]] —— 穿越机/FPV 无人机概念：第一人称视角飞行、自组装文化
- [[fpv-assembly-tools]] —— 穿越机新手装机必备工具与耗材清单（耗材 13 项 + 工具 10 项 + 辅助 6 项）
- [[micrometer]] —— 千分尺：高精度螺旋测微量具，分辨率 0.01 mm，含结构与读数方法
- [[uhpc]] —— 超高性能混凝土：抗压强度 ≥100 MPa 的水泥基复合材料，含钢纤维增强
- [[steel-fiber-concrete]] —— 钢纤维混凝土：掺短切钢纤维的增韧水泥基复合材料，UHPC 的关键增强组分
- [[concrete-patch-repair]] —— 混凝土修补：对破损混凝土填充补强的工艺，含浅层/深层分层策略
- [[compressive-strength]] —— 抗压强度（混凝土）：混凝土核心力学性能指标，强度等级划分依据

### Summary
- 暂无

### Source-note
- 暂无

### Original
- 暂无

### Media
- [[fpv-assembly-tools-infographic]] —— 抖音「秘密无人机飞手」装机工具图文笔记：OCR 识别的单张信息图
- [[micrometer-usage-douyin-2026-06]] —— 抖音「全球都知道」千分尺使用方法视频笔记：原理动画讲解结构与读数
- [[uhpc-steel-fiber-repair-douyin-2026-07]] —— 抖音「赵老师-建筑科技研究院」UHPC 钢纤维修补配比视频笔记：2h 39.2MPa / 1d 43.3MPa / 28d 100MPa
