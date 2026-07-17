# Tasks

- [ ] Task 1: 准备构建环境与目录
  - [ ] SubTask 1.1: 在 `/workspace/build/betaflight` 创建独立构建目录，与 wiki 工作区隔离
  - [ ] SubTask 1.2: 检查并安装/确认工具链：`git`、`make`、`python3`、`arm-none-eabi-gcc`（GNU Arm Embedded Toolchain，版本符合 Betaflight `docs/development/` 要求）
  - [ ] SubTask 1.3: 记录工具链版本快照（`arm-none-eabi-gcc --version`、`make --version` 等），写入构建日志

- [ ] Task 2: 克隆源码并精确 checkout 到 tag `2025.12.5`
  - [ ] SubTask 2.1: `git clone https://github.com/betaflight/betaflight.git` 到构建目录
  - [ ] SubTask 2.2: `git checkout 2025.12.5`，确认 `git status` 干净、`git describe --tags` 输出 `2025.12.5`
  - [ ] SubTask 2.3: 记录 tag 对应的 commit SHA，便于审计可复现性

- [ ] Task 3: 验证源码零修改前提
  - [ ] SubTask 3.1: 检查 `git status` 在 checkout 后必须 clean
  - [ ] SubTask 3.2: 整个构建流程中禁止 `sed`/`Edit`/patch 等任何对 tracked 文件的写操作；只允许 `make` 触发的 gitignored 路径写入

- [ ] Task 4: 执行单 target 试编译（冒烟测试）
  - [ ] SubTask 4.1: 选一个常用 target（如 `MATEKF405`）执行 `make TARGET=MATEKF405`
  - [ ] SubTask 4.2: 确认退出码 0，产物 `obj/main/betaflight_MATEKF405.hex` 生成
  - [ ] SubTask 4.3: 若失败，停止并向用户报告错误（不擅自改源码去修复）

- [ ] Task 5: 批量编译常用 targets
  - [ ] SubTask 5.1: 选定 target 列表（默认至少含 `MATEKF405`、`STM32F405`、`MATEKH743` 等主流飞控；最终列表在执行阶段与用户确认或取 release 页面附带的 target 集合）
  - [ ] SubTask 5.2: 对每个 target 执行 `make TARGET=<target>`，捕获日志
  - [ ] SubTask 5.3: 失败 target 单独标记，不阻断其它 target 编译

- [ ] Task 6: 产物汇总与校验
  - [ ] SubTask 6.1: 收集所有生成的 `.hex` 文件路径与大小
  - [ ] SubTask 6.2: 对每个 `.hex` 计算 SHA256，写入 `build-manifest.md`
  - [ ] SubTask 6.3: 输出 target → hex 路径 → 大小 → SHA256 的清单，标注对应飞控硬件
  - [ ] SubTask 6.4: 再次执行 `git status` 确认源码仍 clean（验证「不修改任何数据」约束）

# Task Dependencies

- Task 2 depends on Task 1（环境就绪后才能 clone）
- Task 3 depends on Task 2（checkout 完成后才能验证零修改）
- Task 4 depends on Task 3（确认源码干净后再编译）
- Task 5 depends on Task 4（冒烟测试通过后再批量编译）
- Task 6 depends on Task 5（全部编译完成后汇总）
