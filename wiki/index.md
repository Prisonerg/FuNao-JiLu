# Wiki 主目录

这是 wiki 主目录，包含四个部分：
1. **快速入口** — 按入链数排序的核心枢纽页（你最常从这里出发）
2. **最近更新** — 最近 10 次 ingest/修改的页面（按更新时间倒序）
3. **主题地图（MOC）** — 按主题聚合跨 domain/type 的相关页
4. **domain × type 分组** — 完整的分类列表

每次 ingest 后 LLM 会同步更新本目录；Query 操作时 LLM 会先读本目录定位相关页。链接用 Obsidian `[[wikilink]]` 语法（不带 `.md` 后缀）。

## 快速入口（核心枢纽页）

按入链数（其他页面指向它的次数，按唯一源页计数）降序排列，入链 < 3 不列入。这些是知识网络的核心节点，从这里出发能找到大部分内容：

- [[uhpc]] (6) — UHPC 超高性能混凝土，建筑材料入口
- [[steel-fiber-concrete]] (6) — 钢纤维混凝土，增韧增强理论
- [[concrete-patch-repair]] (6) — 混凝土修补工艺
- [[compressive-strength]] (6) — 抗压强度，混凝土核心力学性能
- [[uhpc-steel-fiber-repair-douyin-2026-07]] (6) — UHPC 钢纤维修补配比视频笔记
- [[llm-wiki]] (6) — LLM Wiki 核心概念，AI 领域入口
- [[andrej-karpathy]] (6) — Andrej Karpathy，LLM Wiki 提出者
- [[zhao-laoshi-jianzhu-keji-yuan]] (5) — 赵老师-建筑科技研究院，抖音建筑材料创作者
- [[rag-vs-llm-wiki]] (5) — RAG vs LLM Wiki 系统对比
- [[second-brain]] (5) — 第二大脑，PKM 概念，LLM Wiki 本土化框架
- [[suda-llm-wiki-video]] (4) — 苏大讲AI LLM Wiki 学习潮视频笔记
- [[fpv-drone]] (3) — 穿越机概念，FPV 领域入口
- [[fpv-assembly-tools]] (3) — 穿越机装机工具清单
- [[fpv-assembly-tools-infographic]] (3) — 装机工具图文笔记
- [[secret-fpv-pilot]] (3) — 秘密无人机飞手，抖音 FPV 创作者
- [[micrometer-usage-douyin-2026-06]] (3) — 千分尺使用方法视频笔记

## 最近更新（倒序）

*Dataview 自动查询：按 `updated` 倒序，最近 10 条页面更新记录。非 Obsidian 环境下显示为原始查询代码。*

```dataview
TABLE updated AS "更新日期", type AS "类型", domain AS "领域"
FROM "wiki"
WHERE file.name != "index" AND file.name != "log"
SORT updated DESC, file.mtime DESC
LIMIT 10
```

## 主题地图（MOC）

按主题聚合跨 type/domain 的相关页，便于主题浏览。

### 主题：知识管理 / LLM Wiki
- [[llm-wiki]]、[[rag-vs-llm-wiki]]、[[second-brain]]、[[andrej-karpathy]]、[[suda-llm-wiki-video]]、[[karpathy-llm-wiki-gist-note]]、[[suda-ai-talk]]

### 主题：FPV / 穿越机
- [[fpv-drone]]、[[fpv-assembly-tools]]、[[secret-fpv-pilot]]、[[fpv-assembly-tools-infographic]]

### 主题：精密量具 / 测量
- [[micrometer]]、[[quanqiu-dou-zhidao]]、[[micrometer-usage-douyin-2026-06]]

### 主题：建筑材料 / 工程材料
- [[uhpc]]、[[steel-fiber-concrete]]、[[concrete-patch-repair]]、[[compressive-strength]]、[[zhao-laoshi-jianzhu-keji-yuan]]、[[uhpc-steel-fiber-repair-douyin-2026-07]]、[[uhpc-authoritative-standards-note]]

### 主题：育儿 / 婴儿护理
- [[baby-cry-locate-itch]]、[[nuan-nuan-baby-cry-scratch-video]]、[[nuan-nuan-planet]]

---

## 标签索引

*Dataview 自动查询：按 tag 聚合所有 wiki 页面。非 Obsidian 环境下显示为原始查询代码。*

```dataview
TABLE WITHOUT ID rows.file.link AS "页面"
FROM "wiki"
WHERE file.name != "index" AND file.name != "log"
FLATTEN tags AS tag
GROUP BY tag
SORT tag ASC
```

---

## domain × type 分组

*Dataview 自动查询：按 `domain` 一级分组，`type` 与 `title` 作为列显示（Dataview 不直接支持 domain×type 二级分组，故 type 作列）。非 Obsidian 环境下显示为原始查询代码。*

```dataview
TABLE WITHOUT ID file.link AS "页面", title AS "标题", type AS "类型"
FROM "wiki"
WHERE file.name != "index" AND file.name != "log"
SORT domain ASC, type ASC, file.name ASC
GROUP BY domain
```
