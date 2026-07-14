#!/usr/bin/env bash
# wiki-lint.sh —— GBrain-core Wiki 机器化体检脚本
# 纯 bash/grep/jq 实现，无其它外部依赖。检查项见 AGENTS.md §9.3。
# 用法：
#   bash scripts/wiki-lint.sh          # 文本输出（默认；详细报告另写 reports/）
#   bash scripts/wiki-lint.sh --json   # JSON 输出（便于 Schedule 触发后 LLM 解析）
#
# 输出：
#   - stdout：文本体检报告（或 --json 时的 JSON）
#   - reports/lint-YYYY-MM-DD.md：每次运行的详细报告（含反向链接矩阵），供人工查阅
#   - log.md 由调用者/LLM 追加一行摘要（脚本本身不写 log.md，保持 log 追加式不变）
#
# 16 项检查（1-8 原有，9-16 新增）：
#   1. frontmatter 完整性
#   2. 双区结构（## 时间线）
#   3. 孤岛页（无入链）
#   4. 悬空引用
#   5. sources 与 raw 对齐
#   6. index 与实际页对齐（Dataview 兼容：仅扫快速入口 + 主题 MOC）
#   7. 时间线格式（来源标注）
#   8. 反向链接矩阵
#   9. 文件名 kebab-case 校验（新）
#  10. reliability 取值校验（新）
#  11. 时间线日期格式校验 YYYY-MM-DD（新）
#  12. 时间线条目含 § 章节（新，单条目豁免）
#  13. index 快速入口入链数与 lint 矩阵一致（新）
#  14. 双区启发式（编译真相区不应有时间线条目格式）（新）
#  15. 最近一次 ingest 自检机器化验证（新）
#  16. 孤儿 raw 文件（未被任何 wiki 页 sources 引用）（新）

set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)/wiki"
RAW_DIR="$(cd "$(dirname "$0")/.." && pwd)/raw"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORTS_DIR="$ROOT_DIR/reports"
TODAY=$(date '+%Y-%m-%d')
NOW_TS=$(date '+%Y-%m-%d %H:%M:%S')

# 解析参数
JSON_OUTPUT=0
for arg in "$@"; do
  case "$arg" in
    --json) JSON_OUTPUT=1 ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
  esac
done

mkdir -p "$REPORTS_DIR"

# 颜色（JSON 模式下置空，保持输出纯净）
if [[ $JSON_OUTPUT -eq 1 ]]; then
  RED='' GREEN='' YELLOW='' BLUE='' NC=''
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
fi

# 合法取值
VALID_TYPES="entity concept summary source-note original media"
VALID_DOMAINS="ai personal hobby"
VALID_RELIABILITY="high medium low"

# 计数器
ERRORS=0
WARNINGS=0

# 结构化 issue 存储（用于 JSON 输出）：4 个并行数组
declare -a issue_check issue_severity issue_page issue_message

# 反向链接矩阵：page -> count；page -> "src1 src2 ..."
declare -A inlinks
declare -A inlink_sources

# 文本输出缓冲（按行存，escape 序列未解释，输出时用 printf %b 解释）
declare -a text_buf
emit() { text_buf+=("$1"); }

add_issue() {
  local check="$1" sev="$2" page="$3" msg="$4"
  issue_check+=("$check")
  issue_severity+=("$sev")
  issue_page+=("$page")
  issue_message+=("$msg")
  if [[ "$sev" == "error" ]]; then
    ERRORS=$((ERRORS+1))
  else
    WARNINGS=$((WARNINGS+1))
  fi
}

# 收集所有知识页（排除 index.md, log.md）
pages=()
for f in "$WIKI_DIR"/*.md; do
  base=$(basename "$f")
  if [[ "$base" != "index.md" && "$base" != "log.md" ]]; then
    pages+=("$f")
  fi
done

# 初始化 inlinks 计数（所有页都先置 0）
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  inlinks[$base]=0
done

# 工具函数：取 frontmatter（第一个 --- 到第二个 --- 之间）
get_fm() {
  awk '/^---$/{c++; if(c==2) exit; if(c==1) next} c==1' "$1"
}

# 头部
emit ""
emit "========================================"
emit "GBrain-core Wiki Lint 体检报告"
emit "========================================"
emit "时间：${NOW_TS}"
emit "页面数：${#pages[@]}"
emit ""

# ============================================================
# 检查 1/16: frontmatter 完整性
# ============================================================
emit "【1/16】frontmatter 完整性"
emit "----------------------------------------"
emit "说明：检查每个知识页开头的 YAML frontmatter 是否包含所有必填字段，type/domain 取值是否合法。"
emit "必填字段：title, type, domain, tags, sources, created, updated"
emit "错误：缺必填字段，或 type/domain 取值不合法。必须修复。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  fm=$(get_fm "$f")
  if [[ -z "$fm" ]]; then
    emit "${RED}  ✗ $base: 无 frontmatter${NC}"
    add_issue "1" "error" "$base" "无 frontmatter"
    continue
  fi
  for field in title type domain tags sources created updated; do
    if ! echo "$fm" | grep -q "^${field}:" && ! echo "$fm" | grep -q "^${field} :" ; then
      emit "${RED}  ✗ $base: 缺字段 ${field}${NC}"
      add_issue "1" "error" "$base" "缺字段 ${field}"
    fi
  done
  t=$(echo "$fm" | grep "^type:" | head -1 | sed 's/^type:[[:space:]]*//')
  if [[ -n "$t" ]] && ! echo "$VALID_TYPES" | grep -qw "$t"; then
    emit "${RED}  ✗ $base: type '$t' 非法（合法: $VALID_TYPES）${NC}"
    add_issue "1" "error" "$base" "type '$t' 非法（合法: $VALID_TYPES）"
  fi
  d=$(echo "$fm" | grep "^domain:" | head -1 | sed 's/^domain:[[:space:]]*//')
  if [[ -n "$d" ]] && ! echo "$VALID_DOMAINS" | grep -qw "$d"; then
    emit "${RED}  ✗ $base: domain '$d' 非法（合法: $VALID_DOMAINS）${NC}"
    add_issue "1" "error" "$base" "domain '$d' 非法（合法: $VALID_DOMAINS）"
  fi
done
emit ""

# ============================================================
# 检查 2/16: 双区结构（## 时间线）
# ============================================================
emit "【2/16】双区结构（## 时间线）"
emit "----------------------------------------"
emit "说明：每个知识页必须包含 '## 时间线' 二级标题，这是双区结构的分界线。"
emit "错误：缺少该标题。必须修复。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  if ! grep -q "^## 时间线" "$f"; then
    emit "${RED}  ✗ $base: 缺少 ## 时间线 二级标题${NC}"
    add_issue "2" "error" "$base" "缺少 ## 时间线 二级标题"
  fi
done
emit "${GREEN}  已检查 ${#pages[@]} 个页面${NC}"
emit ""

# ============================================================
# 检查 3/16: 孤岛页（无入链）+ 构建反向链接矩阵
# ============================================================
emit "【3/16】孤岛页（无入链）"
emit "----------------------------------------"
emit "说明：孤岛页指没有任何其他 wiki 页用 [[wikilink]] 指向它的页面。"
emit "建议：检查它是否和其他知识不相关，或在相关页补一个交叉引用。"
emit "这是警告，不是错误，可酌情处理。"
emit ""
# 构建反向链接矩阵（同一源页多次指向同一目标只算 1 入链）
declare -A seen_pairs
for f in "${pages[@]}"; do
  src_base=$(basename "$f" .md)
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" && -n "${inlinks[$target]+x}" ]]; then
      pair_key="${src_base}->${target}"
      if [[ -z "${seen_pairs[$pair_key]+x}" ]]; then
        seen_pairs[$pair_key]=1
        inlinks[$target]=$((inlinks[$target]+1))
        if [[ -z "${inlink_sources[$target]+x}" ]]; then
          inlink_sources[$target]="$src_base"
        else
          inlink_sources[$target]="${inlink_sources[$target]} $src_base"
        fi
      fi
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
done
island=0
for base in "${!inlinks[@]}"; do
  if [[ ${inlinks[$base]} -eq 0 ]]; then
    emit "${YELLOW}  ⚠ $base: 孤岛页（无任何 [[wikilink]] 指向它）${NC}"
    add_issue "3" "warning" "$base" "孤岛页（无任何 [[wikilink]] 指向它）"
    island=1
  fi
done
if [[ $island -eq 0 ]]; then
  emit "${GREEN}  无孤岛页${NC}"
fi
emit ""

# ============================================================
# 检查 4/16: 悬空引用
# ============================================================
emit "【4/16】悬空引用（指向不存在的页）"
emit "----------------------------------------"
emit "说明：悬空引用指 [[xxx]] 指向了一个不存在的 wiki 文件。"
emit "通常是文件名拼错了，或者页面被删除了但引用还在。错误，必须修复。"
emit ""
dangling=0
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" ]]; then
      if [[ ! -f "$WIKI_DIR/$target.md" ]]; then
        emit "${RED}  ✗ $base: 悬空引用 [[$target]]（文件不存在）${NC}"
        add_issue "4" "error" "$base" "悬空引用 [[$target]]（文件不存在）"
        dangling=1
      fi
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" || true)
done
if [[ $dangling -eq 0 ]]; then
  emit "${GREEN}  无悬空引用${NC}"
fi
emit ""

# ============================================================
# 检查 5/16: sources 与 raw 对齐
# ============================================================
emit "【5/16】sources 与 raw 对齐"
emit "----------------------------------------"
emit "说明：检查 frontmatter 中 sources 字段列出的文件，是否真的存在于 raw/ 目录。"
emit "每个 wiki 页的 sources 必须指向真实存在的 raw 文件。错误，必须修复。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  fm=$(get_fm "$f")
  while IFS= read -r line; do
    src=$(echo "$line" | sed 's/^[[:space:]]*- //' | tr -d ' ')
    if [[ -n "$src" ]]; then
      rawpath="$RAW_DIR/$(basename "$src")"
      if [[ ! -f "$rawpath" ]]; then
        emit "${RED}  ✗ $base: sources 指向的 $src 在 raw/ 下不存在${NC}"
        add_issue "5" "error" "$base" "sources 指向的 $src 在 raw/ 下不存在"
      fi
    fi
  done < <(echo "$fm" | awk '
    /^sources:[[:space:]]*$/{in_src=1; next}
    /^[^[:space:]]/{in_src=0}
    in_src && /^[[:space:]]*- /{print}
  ' || true)
done
emit "${GREEN}  已检查 sources 对齐${NC}"
emit ""

# ============================================================
# 检查 6/16: index 与实际页对齐（Dataview 兼容版）
# ============================================================
emit "【6/16】index 与实际页对齐（仅快速入口 + 主题 MOC，Dataview 段不参与）"
emit "----------------------------------------"
emit "说明：检查 index.md 是否列出了所有实际存在的 wiki 页。"
emit "Dataview 兼容性：'domain×type 分组'与'标签索引'已由 Dataview 自动渲染，"
emit "  无法被 bash/grep 解析，故本检查只扫描手维护的「快速入口」与「主题地图（MOC）」两段。"
emit "警告：页面存在但 index 未登记（Dataview 段已自动登记，可忽略）。"
emit "错误：index 登记了不存在的页面（需删除）。"
emit ""
index_file="$WIKI_DIR/index.md"
if [[ ! -f "$index_file" ]]; then
  emit "${RED}  ✗ index.md 不存在${NC}"
  add_issue "6" "error" "index" "index.md 不存在"
else
  # 提取快速入口段（## 快速入口 到下一个 ## 之前）
  quick=$(awk '
    /^## 快速入口/{flag=1; next}
    /^## /{if(flag) exit}
    flag
  ' "$index_file")
  # 提取主题 MOC 段（## 主题... 到下一个 ## 之前）
  moc=$(awk '
    /^## 主题/{flag=1; next}
    /^## /{if(flag) exit}
    flag
  ' "$index_file")
  combined="$quick"$'\n'"$moc"
  declare -A indexed
  while IFS= read -r link; do
    target=$(echo "$link" | sed 's/^\[\[//; s/\]\]$//; s/\\|.*$//; s/|.*$//')
    if [[ -n "$target" && "$target" != "wikilink" ]]; then
      indexed[$target]=1
    fi
  done < <(echo "$combined" | grep -oE '\[\[[^]]+\]\]' || true)
  for f in "${pages[@]}"; do
    base=$(basename "$f" .md)
    if [[ -z "${indexed[$base]+x}" ]]; then
      emit "${YELLOW}  ⚠ $base: 实际页存在但 index.md 快速入口/主题 MOC 未登记（Dataview 段已自动登记，可忽略）${NC}"
      add_issue "6" "warning" "$base" "实际页存在但 index.md 快速入口/主题 MOC 未登记（Dataview 段已自动登记，可忽略）"
    fi
  done
  for target in "${!indexed[@]}"; do
    if [[ ! -f "$WIKI_DIR/$target.md" ]]; then
      emit "${RED}  ✗ index.md 登记的 [[$target]] 实际不存在${NC}"
      add_issue "6" "error" "index" "登记的 [[$target]] 实际不存在"
    fi
  done
fi
emit ""

# ============================================================
# 检查 7/16: 时间线格式（来源标注）
# ============================================================
emit "【7/16】时间线格式（来源标注）"
emit "----------------------------------------"
emit "说明：检查时间线的每条记录是否都包含来源标注（'来源：'）。"
emit "规范要求每条时间线必须标注来源，便于追溯。警告，可酌情处理。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  timeline=$(awk '/^## 时间线/{found=1; next} found' "$f")
  if [[ -z "$timeline" ]]; then
    continue
  fi
  entry_count=$(echo "$timeline" | grep -cE '^[[:space:]]*- [0-9]{4}-[0-9]{2}-[0-9]{2}' || true)
  source_count=$(echo "$timeline" | grep -c '来源：' || true)
  if [[ $entry_count -gt 0 && $source_count -lt $entry_count ]]; then
    emit "${YELLOW}  ⚠ $base: 时间线有 $entry_count 条目，但仅 $source_count 条含来源标注${NC}"
    add_issue "7" "warning" "$base" "时间线有 $entry_count 条目，但仅 $source_count 条含来源标注"
  fi
done
emit "${GREEN}  已检查时间线格式${NC}"
emit ""

# ============================================================
# 检查 8/16: 反向链接矩阵
# ============================================================
emit "【8/16】反向链接矩阵"
emit "----------------------------------------"
emit "说明：列出每个页面被哪些其他页面链接，以及入链数量。"
emit "入链越多说明这个页面越核心，是知识网络的枢纽。"
emit "页名 (入链数) <- 来源页面列表"
emit "----------------------------------------"
for base in $(echo "${!inlinks[@]}" | tr ' ' '\n' | sort); do
  count=${inlinks[$base]}
  if [[ $count -gt 0 ]]; then
    sources_list="${inlink_sources[$base]}"
    emit "  $base ($count) <-$sources_list"
  fi
done
emit ""

# ============================================================
# 检查 9/16: 文件名 kebab-case 校验（新）
# ============================================================
emit "【9/16】文件名 kebab-case 校验"
emit "----------------------------------------"
emit "说明：wiki/ 下所有 .md 文件名必须全小写字母/数字 + 连字符（kebab-case）。"
emit "禁止大写、下划线、空格、中文。错误，必须修复（重命名 + 更新所有引用）。"
emit ""
for f in "$WIKI_DIR"/*.md; do
  base=$(basename "$f")   # 含 .md
  name="${base%.md}"
  if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    emit "${RED}  ✗ $base: 文件名非 kebab-case（应全小写+连字符）${NC}"
    add_issue "9" "error" "$name" "文件名非 kebab-case（应全小写+连字符）"
  fi
done
emit "${GREEN}  已检查文件名 kebab-case${NC}"
emit ""

# ============================================================
# 检查 10/16: reliability 取值校验（新）
# ============================================================
emit "【10/16】reliability 取值校验"
emit "----------------------------------------"
emit "说明：若 frontmatter 含 reliability 字段，取值必须 ∈ {high, medium, low}。"
emit "错误：取值非法。必须修复。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  fm=$(get_fm "$f")
  rel=$(echo "$fm" | grep "^reliability:" | head -1 | sed 's/^reliability:[[:space:]]*//' | tr -d ' ')
  if [[ -n "$rel" ]] && ! echo "$VALID_RELIABILITY" | grep -qw "$rel"; then
    emit "${RED}  ✗ $base: reliability '$rel' 非法（合法: $VALID_RELIABILITY）${NC}"
    add_issue "10" "error" "$base" "reliability '$rel' 非法（合法: $VALID_RELIABILITY）"
  fi
done
emit "${GREEN}  已检查 reliability 取值${NC}"
emit ""

# ============================================================
# 检查 11/16: 时间线日期格式校验（YYYY-MM-DD）（新）
# ============================================================
emit "【11/16】时间线日期格式校验（YYYY-MM-DD）"
emit "----------------------------------------"
emit "说明：## 时间线 下的条目首字符 - 后必须紧跟 YYYY-MM-DD 日期（可附带 HH:MM）。"
emit "警告：格式不符。建议修复。"
emit ""
date_re='^[[:space:]]*-[[:space:]]+([0-9]{4}-[0-9]{2}-[0-9]{2})([[:space:]][0-9]{2}:[0-9]{2})?[[:space:]]*[|｜]'
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  timeline=$(awk '/^## 时间线/{found=1; next} found' "$f")
  if [[ -z "$timeline" ]]; then
    continue
  fi
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
      # 提取日期段（- 后到第一个 | 或空格 之前）
      date_seg=$(echo "$line" | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]].*//')
      # 容许两种格式：YYYY-MM-DD 或 YYYY-MM-DD HH:MM
      if [[ ! "$date_seg" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        emit "${YELLOW}  ⚠ $base: 时间线条目日期格式不符: '$date_seg'${NC}"
        add_issue "11" "warning" "$base" "时间线条目日期格式不符: '$date_seg'"
      fi
    fi
  done < <(echo "$timeline")
done
emit "${GREEN}  已检查时间线日期格式${NC}"
emit ""

# ============================================================
# 检查 12/16: 时间线条目含 § 章节（新）
# ============================================================
emit "【12/16】时间线条目含 § 章节"
emit "----------------------------------------"
emit "说明：## 时间线 下的条目应含 '§ 章节' 精确章节引用（来源：raw/xxx.md § 章节）。"
emit "豁免：若该页时间线只有 1 条（首次 ingest），整页豁免。"
emit "警告：条目未含 § 章节。建议补充。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  # 用 awk 把每个条目块（首行 + 后续缩进行）合并为单行输出
  entries=$(awk '
    /^## 时间线/{in_tl=1; next}
    in_tl && /^[[:space:]]*-[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}/{
      if (cur != "") { print cur; cur="" }
      cur=$0
      next
    }
    in_tl && cur != "" && /^[[:space:]]+/{
      cur=cur " | " $0
      next
    }
    END { if (cur != "") print cur }
  ' "$f")
  if [[ -z "$entries" ]]; then
    continue
  fi
  entry_count=$(echo "$entries" | grep -c . || true)
  if [[ $entry_count -le 1 ]]; then
    # 单条目豁免
    continue
  fi
  while IFS= read -r entry; do
    if [[ "$entry" != *"§"* ]]; then
      date_part=$(echo "$entry" | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]].*//')
      emit "${YELLOW}  ⚠ $base: 时间线条目 $date_part 未含 § 章节${NC}"
      add_issue "12" "warning" "$base" "时间线条目 $date_part 未含 § 章节"
    fi
  done < <(echo "$entries")
done
emit "${GREEN}  已检查时间线条目 § 章节${NC}"
emit ""

# ============================================================
# 检查 13/16: index 快速入口入链数与 lint 反向链接矩阵一致（新）
# ============================================================
emit "【13/16】index 快速入口入链数与 lint 反向链接矩阵一致"
emit "----------------------------------------"
emit "说明：index.md 快速入口段标注的入链数 (N) 必须与 lint 计算的实际入链数一致。"
emit "错误：不一致。需刷新 index.md。"
emit ""
if [[ -f "$index_file" ]]; then
  quick=$(awk '/^## 快速入口/{flag=1; next} /^## /{if(flag) exit} flag' "$index_file")
  re='\[\[([^]|]+)(\|[^]]+)?\]\][[:space:]]*\(([0-9]+)\)'
  while IFS= read -r line; do
    if [[ "$line" =~ $re ]]; then
      target="${BASH_REMATCH[1]}"
      declared="${BASH_REMATCH[3]}"
      actual=${inlinks[$target]:-0}
      if [[ "$declared" != "$actual" ]]; then
        emit "${RED}  ✗ index 快速入口 [[$target]] 标注入链数 $declared，实际 $actual${NC}"
        add_issue "13" "error" "index" "快速入口 [[$target]] 标注入链数 $declared，实际 $actual"
      fi
    fi
  done < <(echo "$quick")
fi
emit "${GREEN}  已检查 index 快速入口入链数一致性${NC}"
emit ""

# ============================================================
# 检查 14/16: 双区启发式（编译真相区不应有时间线条目格式）（新）
# ============================================================
emit "【14/16】双区启发式（编译真相区不应有时间线条目格式）"
emit "----------------------------------------"
emit "说明：编译真相区（## 时间线 之前，frontmatter 之后）不应出现 '^- YYYY-MM-DD |' 列表项格式"
emit "（带 | 分隔符的才是时间线条目格式；## 相关事件 段的 '— ' 分隔符格式属 §4.2 entity 模板标准，不报警）。警告，需检查。"
emit ""
for f in "${pages[@]}"; do
  base=$(basename "$f" .md)
  # 提取 ## 时间线 之前的内容，并去掉 frontmatter（--- 之间）
  truth=$(awk '
    BEGIN{c=0; in_tl=0}
    /^## 时间线/{in_tl=1; exit}
    in_tl{next}
    /^---$/{c++; next}
    c>=2{print}
  ' "$f")
  while IFS= read -r line; do
    # 只匹配时间线条目格式 '- YYYY-MM-DD [HH:MM] |'（带 | 分隔符），
    # 排除 ## 相关事件 段的 '- YYYY-MM-DD [HH:MM] — ' 格式（em-dash 分隔符，§4.2 entity 模板标准）
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}([[:space:]][0-9]{2}:[0-9]{2})?[[:space:]]*\| ]]; then
      # 截短显示
      short=$(echo "$line" | cut -c1-80)
      emit "${YELLOW}  ⚠ $base: 编译真相区出现时间线条目格式: '$short'${NC}"
      add_issue "14" "warning" "$base" "编译真相区出现时间线条目格式: '$short'"
    fi
  done < <(echo "$truth")
done
emit "${GREEN}  已检查双区启发式${NC}"
emit ""

# ============================================================
# 检查 15/16: 最近一次 ingest 自检机器化验证（新）
# ============================================================
emit "【15/16】最近一次 ingest 自检机器化验证"
emit "----------------------------------------"
emit "说明：从 log.md 取最近一次 ingest 声明触达的页，校验每页 updated=该次日期"
emit "且时间线末条日期=该次日期。不一致警告（可能漏改 updated 或漏加时间线）。"
emit ""
log_file="$WIKI_DIR/log.md"
if [[ ! -f "$log_file" ]]; then
  emit "${YELLOW}  ⚠ log.md 不存在${NC}"
  add_issue "15" "warning" "log" "log.md 不存在"
else
  # 找最后一个 ingest 条目，提取日期与触达文件列表
  # 兼容两种 log 格式：旧格式 `### YYYY-MM-DD HH:MM - ingest`、新格式 `## [YYYY-MM-DD HH:MM] ingest | ...`
  latest_ingest_date=""
  latest_ingest_files=""
  in_ingest=0
  ingest_re_old='^### ([0-9]{4}-[0-9]{2}-[0-9]{2})([[:space:]]+([0-9]{2}:[0-9]{2}))?.*-[[:space:]]*[Ii]ngest'
  ingest_re_new='^##[[:space:]]\[([0-9]{4}-[0-9]{2}-[0-9]{2})[[:space:]]+[0-9]{2}:[0-9]{2}\][[:space:]]+ingest\b'
  touched_re='^-[[:space:]]*\*\*触达的 wiki 文件\*\*[：:][[:space:]]*(.+)$'
  # 任意新条目头（用于停止采集触达文件）：旧格式 `### ` 或新格式 `## [`
  entry_header_re='^(##[[:space:]]\[|### )'
  while IFS= read -r line; do
    if [[ "$line" =~ $ingest_re_old ]]; then
      latest_ingest_date="${BASH_REMATCH[1]}"
      in_ingest=1
      latest_ingest_files=""
      continue
    fi
    if [[ "$line" =~ $ingest_re_new ]]; then
      latest_ingest_date="${BASH_REMATCH[1]}"
      in_ingest=1
      latest_ingest_files=""
      continue
    fi
    if [[ $in_ingest -eq 1 ]]; then
      if [[ "$line" =~ $touched_re ]]; then
        latest_ingest_files="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ $entry_header_re ]]; then
        # 进入下一个条目（非 ingest），停止采集
        in_ingest=0
      fi
    fi
  done < "$log_file"

  if [[ -n "$latest_ingest_date" && -n "$latest_ingest_files" ]]; then
    emit "  最近一次 ingest 日期：$latest_ingest_date"
    emit "  触达文件：$latest_ingest_files"
    emit ""
    # 解析触达的 wiki 文件路径（wiki/xxx.md）
    for path in $(echo "$latest_ingest_files" | grep -oE 'wiki/[a-z0-9-]+\.md' | sort -u); do
      base=$(basename "$path" .md)
      wiki_path="$WIKI_DIR/$base.md"
      if [[ ! -f "$wiki_path" ]]; then
        continue
      fi
      if [[ "$base" == "index" || "$base" == "log" ]]; then
        continue
      fi
      fm=$(get_fm "$wiki_path")
      upd=$(echo "$fm" | grep "^updated:" | head -1 | sed 's/^updated:[[:space:]]*//' | tr -d ' ')
      if [[ "$upd" != "$latest_ingest_date" ]]; then
        emit "${YELLOW}  ⚠ $base: updated='$upd'，与最近 ingest 日期 $latest_ingest_date 不一致${NC}"
        add_issue "15" "warning" "$base" "updated='$upd'，与最近 ingest 日期 $latest_ingest_date 不一致"
      fi
      timeline=$(awk '/^## 时间线/{found=1; next} found' "$wiki_path")
      last_date=$(echo "$timeline" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -1 || true)
      if [[ -n "$last_date" && "$last_date" != "$latest_ingest_date" ]]; then
        emit "${YELLOW}  ⚠ $base: 时间线末条日期 $last_date，与最近 ingest 日期 $latest_ingest_date 不一致${NC}"
        add_issue "15" "warning" "$base" "时间线末条日期 $last_date，与最近 ingest 日期 $latest_ingest_date 不一致"
      fi
    done
  else
    emit "${YELLOW}  ⚠ log.md 未找到 ingest 条目或触达文件列表${NC}"
    add_issue "15" "warning" "log" "log.md 未找到 ingest 条目或触达文件列表"
  fi
fi
emit "${GREEN}  已检查最近一次 ingest 自检${NC}"
emit ""

# ============================================================
# 检查 16/16: 疯儿 raw 文件（未被任何 wiki 页 sources 引用）（新）
# ============================================================
emit "【16/16】孤儿 raw 文件（未被任何 wiki 页 sources 引用）"
emit "----------------------------------------"
emit "说明：每个 raw 文件至少应被一个 wiki 页的 frontmatter sources 引用。"
emit "孤儿 raw（未被引用）警告：可能是漏建 wiki 页，或 raw 文件已废弃。"
emit ""
declare -A referenced_raw
for f in "${pages[@]}"; do
  fm=$(get_fm "$f")
  while IFS= read -r line; do
    src=$(echo "$line" | sed 's/^[[:space:]]*- //' | tr -d ' ')
    if [[ -n "$src" ]]; then
      referenced_raw[$(basename "$src")]=1
    fi
  done < <(echo "$fm" | awk '
    /^sources:[[:space:]]*$/{in_src=1; next}
    /^[^[:space:]]/{in_src=0}
    in_src && /^[[:space:]]*- /{print}
  ' || true)
done
orphan=0
shopt -s nullglob
raw_files=("$RAW_DIR"/*.md)
shopt -u nullglob
for r in "${raw_files[@]}"; do
  rbase=$(basename "$r")
  if [[ -z "${referenced_raw[$rbase]+x}" ]]; then
    emit "${YELLOW}  ⚠ raw/$rbase: 未被任何 wiki 页 sources 引用${NC}"
    add_issue "16" "warning" "raw/$rbase" "未被任何 wiki 页 sources 引用"
    orphan=1
  fi
done
if [[ $orphan -eq 0 ]]; then
  emit "${GREEN}  无孤儿 raw 文件${NC}"
fi
emit ""

# ============================================================
# 汇总
# ============================================================
emit "========================================"
emit "汇总"
emit "========================================"
emit "页面总数：${#pages[@]}"
emit "错误：${ERRORS}"
emit "警告：${WARNINGS}"
emit ""
if [[ $ERRORS -gt 0 ]]; then
  emit "${RED}✗ 体检未通过，请修复上述错误${NC}"
  exit_code=1
else
  emit "${GREEN}✓ 错误为零，体检通过（警告可酌情处理）${NC}"
  exit_code=0
fi

# ============================================================
# 写 reports/lint-YYYY-MM-DD.md（详细报告，含反向链接矩阵）
# ============================================================
report_file="$REPORTS_DIR/lint-${TODAY}.md"
# 把 text_buf 输出为字符串并解释 escape
text_with_colors=$(printf '%b\n' "${text_buf[@]}")
# 去除 ANSI 颜色码用于文件
text_no_colors=$(printf '%b\n' "${text_buf[@]}" | sed 's/\x1b\[[0-9;]*m//g')
{
  echo "# Wiki Lint 体检报告 - ${TODAY}"
  echo ""
  echo "运行时间：${NOW_TS}"
  echo "页面数：${#pages[@]}"
  echo "错误：${ERRORS}　警告：${WARNINGS}"
  echo ""
  echo "## 详细报告"
  echo ""
  echo '```'
  printf '%s\n' "$text_no_colors"
  echo '```'
} > "$report_file"

# ============================================================
# 输出到 stdout
# ============================================================
if [[ $JSON_OUTPUT -eq 1 ]]; then
  # 构建 issue JSONL
  issues_file=$(mktemp)
  if [[ ${#issue_check[@]} -gt 0 ]]; then
    for i in "${!issue_check[@]}"; do
      jq -nc \
        --arg c "${issue_check[$i]}" \
        --arg s "${issue_severity[$i]}" \
        --arg p "${issue_page[$i]}" \
        --arg m "${issue_message[$i]}" \
        '{check:$c, severity:$s, page:$p, message:$m}' >> "$issues_file"
    done
  fi
  # 构建反向链接矩阵 JSONL
  matrix_file=$(mktemp)
  for base in $(echo "${!inlinks[@]}" | tr ' ' '\n' | sort); do
    count=${inlinks[$base]}
    if [[ $count -gt 0 ]]; then
      sources_arr=$(echo "${inlink_sources[$base]}" | tr ' ' '\n' | jq -R . | jq -sc .)
      jq -nc \
        --arg p "$base" \
        --argjson c "$count" \
        --argjson s "$sources_arr" \
        '{page:$p, count:$c, sources:$s}' >> "$matrix_file"
    fi
  done
  # 组装最终 JSON
  jq -n \
    --arg timestamp "$NOW_TS" \
    --arg date "$TODAY" \
    --arg report_file "reports/lint-${TODAY}.md" \
    --argjson total_errors "$ERRORS" \
    --argjson total_warnings "$WARNINGS" \
    --argjson total_pages "${#pages[@]}" \
    --slurpfile issues "$issues_file" \
    --slurpfile matrix "$matrix_file" \
    '{
      timestamp: $timestamp,
      date: $date,
      report_file: $report_file,
      summary: {
        total_pages: $total_pages,
        errors: $total_errors,
        warnings: $total_warnings,
        passed: ($total_errors == 0)
      },
      errors: [$issues[] | select(.severity == "error") | {check, page, message}],
      warnings: [$issues[] | select(.severity == "warning") | {check, page, message}],
      backlink_matrix: $matrix
    }'
  rm -f "$issues_file" "$matrix_file"
else
  printf '%b\n' "${text_buf[@]}"
  echo ""
  echo "详细报告已写入：$report_file"
fi

exit $exit_code
