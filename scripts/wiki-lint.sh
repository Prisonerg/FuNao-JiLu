#!/usr/bin/env bash
# wiki-lint.sh —— GBrain-core Wiki 机器化体检脚本
# 纯 bash/grep 实现，无外部依赖。检查项见 AGENTS.md §9.3。
# 用法：bash scripts/wiki-lint.sh

set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)/wiki"
RAW_DIR="$(cd "$(dirname "$0")/.." && pwd)/raw"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 计数器
ERRORS=0
WARNINGS=0
INFO=0

# 合法取值
VALID_TYPES="entity concept summary source-note original media"
VALID_DOMAINS="ai personal hobby"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}GBrain-core Wiki Lint 体检报告${NC}"
echo -e "${BLUE}========================================${NC}"
echo "时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 获取所有知识页（排除 index.md, log.md）
pages=()
for f in "$WIKI_DIR"/*.md; do
  base=$(basename "$f")
  if [[ "$base" != "index.md" && "$base" != "log.md" ]]; then
    pages+=("$f")
  fi
done

echo -e "${BLUE}【1/8】frontmatter 完整性${NC}"
echo "----------------------------------------"
echo "说明：检查每个知识页开头的 YAML frontmatter 是否包含所有必填字段，type/domain 取值是否合法。"
echo "必填字段：title, type, domain, tags, sources, created, updated"
echo "错误：缺必填字段，或 type/domain 取值不合法。必须修复。"
echo ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  # 提取 frontmatter（第一个 --- 到第二个 --- 之间）
  fm=$(awk '/^---$/{c++; if(c==2) exit; if(c==1) next} c==1' "$f")
  if [[ -z "$fm" ]]; then
    echo -e "${RED}  ✗ $base: 无 frontmatter${NC}"
    ERRORS=$((ERRORS+1))
    continue
  fi
  # 检查必填字段
  for field in title type domain tags sources created updated; do
    if ! echo "$fm" | grep -q "^${field}:" && ! echo "$fm" | grep -q "^${field}:" ; then
      echo -e "${RED}  ✗ $base: 缺字段 ${field}${NC}"
      ERRORS=$((ERRORS+1))
    fi
  done
  # 检查 type 取值
  t=$(echo "$fm" | grep "^type:" | head -1 | sed 's/^type:[[:space:]]*//')
  if [[ -n "$t" ]] && ! echo "$VALID_TYPES" | grep -qw "$t"; then
    echo -e "${RED}  ✗ $base: type '$t' 非法（合法: $VALID_TYPES）${NC}"
    ERRORS=$((ERRORS+1))
  fi
  # 检查 domain 取值
  d=$(echo "$fm" | grep "^domain:" | head -1 | sed 's/^domain:[[:space:]]*//')
  if [[ -n "$d" ]] && ! echo "$VALID_DOMAINS" | grep -qw "$d"; then
    echo -e "${RED}  ✗ $base: domain '$d' 非法（合法: $VALID_DOMAINS）${NC}"
    ERRORS=$((ERRORS+1))
  fi
done
echo ""

echo -e "${BLUE}【2/8】双区结构（## 时间线）${NC}"
echo "----------------------------------------"
echo "说明：每个知识页必须包含 '## 时间线' 二级标题，这是双区结构的分界线。"
echo "错误：缺少该标题。必须修复。"
echo ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  if ! grep -q "^## 时间线" "$f"; then
    echo -e "${RED}  ✗ $base: 缺少 ## 时间线 二级标题${NC}"
    ERRORS=$((ERRORS+1))
  fi
done
echo -e "${GREEN}  已检查 ${#pages[@]} 个页面${NC}"
echo ""

echo -e "${BLUE}【3/8】孤岛页（无入链）${NC}"
echo "----------------------------------------"
echo "说明：孤岛页指没有任何其他 wiki 页用 [[wikilink]] 指向它的页面。"
echo "建议：检查它是否和其他知识不相关，或在相关页补一个交叉引用。"
echo "这是警告，不是错误，可酌情处理。"
echo ""
# 收集所有 wikilink 目标
declare -A inlinks
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  inlinks[$base]=0
done
for f in "${pages[@]}"; do
  # 提取 [[xxx]] 或 [[xxx|yyy]] 中的 xxx
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" && -n "${inlinks[$target]+x}" ]]; then
      inlinks[$target]=$((inlinks[$target]+1))
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
done
island=0
for base in "${!inlinks[@]}"; do
  if [[ ${inlinks[$base]} -eq 0 ]]; then
    echo -e "${YELLOW}  ⚠ $base: 孤岛页（无任何 [[wikilink]] 指向它）${NC}"
    WARNINGS=$((WARNINGS+1))
    island=1
  fi
done
if [[ $island -eq 0 ]]; then
  echo -e "${GREEN}  无孤岛页${NC}"
fi
echo ""

echo -e "${BLUE}【4/8】悬空引用（指向不存在的页）${NC}"
echo "----------------------------------------"
echo "说明：悬空引用指 [[xxx]] 指向了一个不存在的 wiki 文件。"
echo "通常是文件名拼错了，或者页面被删除了但引用还在。错误，必须修复。"
echo ""
dangling=0
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" ]]; then
      if [[ ! -f "$WIKI_DIR/$target.md" ]]; then
        echo -e "${RED}  ✗ $base: 悬空引用 [[$target]]（文件不存在）${NC}"
        ERRORS=$((ERRORS+1))
        dangling=1
      fi
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
done
if [[ $dangling -eq 0 ]]; then
  echo -e "${GREEN}  无悬空引用${NC}"
fi
echo ""

echo -e "${BLUE}【5/8】sources 与 raw 对齐${NC}"
echo "----------------------------------------"
echo "说明：检查 frontmatter 中 sources 字段列出的文件，是否真的存在于 raw/ 目录。"
echo "每个 wiki 页的 sources 必须指向真实存在的 raw 文件。错误，必须修复。"
echo ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  fm=$(awk '/^---$/{c++; if(c==2) exit; if(c==1) next} c==1' "$f")
  # 提取 sources 列表
  while IFS= read -r line; do
    src=$(echo "$line" | sed 's/^[[:space:]]*- //' | tr -d ' ')
    if [[ -n "$src" ]]; then
      rawpath="$RAW_DIR/$(basename "$src")"
      if [[ ! -f "$rawpath" ]]; then
        echo -e "${RED}  ✗ $base: sources 指向的 $src 在 raw/ 下不存在${NC}"
        ERRORS=$((ERRORS+1))
      fi
    fi
  done < <(echo "$fm" | grep -E '^[[:space:]]*- ' || true)
done
echo -e "${GREEN}  已检查 sources 对齐${NC}"
echo ""

echo -e "${BLUE}【6/8】index 与实际页对齐${NC}"
echo "----------------------------------------"
echo "说明：检查 index.md 是否列出了所有实际存在的 wiki 页，以及 index 列出的页是否都存在。"
echo "警告：页面存在但 index 未登记（需要添加）。错误：index 登记了不存在的页面（需要删除）。"
echo ""
index_file="$WIKI_DIR/index.md"
if [[ ! -f "$index_file" ]]; then
  echo -e "${RED}  ✗ index.md 不存在${NC}"
  ERRORS=$((ERRORS+1))
else
  # index 中登记的页
  declare -A indexed
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" ]]; then
      indexed[$target]=1
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$index_file" || true)
  # 检查实际页是否都在 index
  for f in "${pages[@]}"; do
    base=$(basename "$f" .md)
    if [[ -z "${indexed[$base]+x}" ]]; then
      echo -e "${YELLOW}  ⚠ $base: 实际页存在但 index.md 未登记${NC}"
      WARNINGS=$((WARNINGS+1))
    fi
  done
  # 检查 index 登记的页是否存在
  for target in "${!indexed[@]}"; do
    if [[ ! -f "$WIKI_DIR/$target.md" ]]; then
      echo -e "${RED}  ✗ index.md 登记的 [[$target]] 实际不存在${NC}"
      ERRORS=$((ERRORS+1))
    fi
  done
fi
echo ""

echo -e "${BLUE}【7/8】时间线格式${NC}"
echo "----------------------------------------"
echo "说明：检查时间线的每条记录是否都包含来源标注（'来源：'）。"
echo "规范要求每条时间线必须标注来源，便于追溯。警告，可酌情处理。"
echo ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  # 提取时间线区
  timeline=$(awk '/^## 时间线/{found=1; next} found' "$f")
  if [[ -z "$timeline" ]]; then
    # 已在检查2报过
    continue
  fi
  # 检查时间线条目是否含来源标注
  entry_count=$(echo "$timeline" | grep -cE '^[[:space:]]*- [0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
  source_count=$(echo "$timeline" | grep -c '来源：' || true)
  if [[ $entry_count -gt 0 && $source_count -lt $entry_count ]]; then
    echo -e "${YELLOW}  ⚠ $base: 时间线有 $entry_count 条目，但仅 $source_count 条含来源标注${NC}"
    WARNINGS=$((WARNINGS+1))
  fi
done
echo -e "${GREEN}  已检查时间线格式${NC}"
echo ""

echo -e "${BLUE}【8/8】反向链接矩阵${NC}"
echo "----------------------------------------"
echo "说明：列出每个页面被哪些其他页面链接，以及入链数量。"
echo "入链越多说明这个页面越核心，是知识网络的枢纽。"
echo "页名 (入链数) <- 来源页面列表"
echo "----------------------------------------"
echo "页名 <- 被谁指向"
echo "----------------------------------------"
for base in $(echo "${!inlinks[@]}" | tr ' ' '\n' | sort); do
  count=${inlinks[$base]}
  if [[ $count -gt 0 ]]; then
    # 找谁指向它
    sources_list=""
    for f in "${pages[@]}"; do
      src_base=$(basename "$f" .md)
      while IFS= read -r link; do
        target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
        if [[ "$target" == "$base" ]]; then
          sources_list="$sources_list $src_base"
        fi
      done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
    done
    echo "  $base ($count) <-$sources_list"
  fi
done
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}汇总${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "页面总数：${#pages[@]}"
echo -e "错误：${RED}${ERRORS}${NC}"
echo -e "警告：${YELLOW}${WARNINGS}${NC}"
echo ""
if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}✗ 体检未通过，请修复上述错误${NC}"
  exit 1
else
  echo -e "${GREEN}✓ 错误为零，体检通过（警告可酌情处理）${NC}"
  exit 0
fi
