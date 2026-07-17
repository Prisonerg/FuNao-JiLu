# Betaflight 2025.12.5 构建日志

## Step 1: 环境与工具链

- 操作系统: Linux (Ubuntu noble, 沙箱 CI=true)
- 时区: Asia/Shanghai
- git: 2.43.0
- make: GNU Make 4.3
- python3: 3.14.4
- arm-none-eabi-gcc: 初始缺失（系统未预装，apt 无法连通 archive.ubuntu.com）
  - 解决方案: 使用 betaflight 内置 `make arm_sdk_install` 下载官方 ARM GNU Toolchain 13.3.rel1 到 `tools/`（被 .gitignore 忽略，不污染源码）
- mise: 2026.4.15 (可用但未使用)

工具链版本要求（来自 `mk/tools.mk`）:
- ARM SDK Version: 13.3.Rel1
- GCC_REQUIRED_VERSION: 13.3.1
- ARM_SDK_URL: https://developer.arm.com/-/media/Files/downloads/gnu/13.3.rel1/binrel/arm-gnu-toolchain-13.3.rel1-x86_64-arm-none-eabi.tar.xz

## Step 2: 克隆与 checkout

- 克隆命令: `git clone --branch 2025.12.5 --single-branch https://github.com/betaflight/betaflight.git`
- 耗时: ~30s
- Tag: 2025.12.5
- Commit SHA: 7348054f268f0058574719c134e9f149565bb8ea
- `git describe --tags` 输出: 2025.12.5
- HEAD 状态: detached HEAD（checkout tag 的正常状态）

## Step 3: 零修改前提验证（checkout 后）

`git status` 输出:
```
Not currently on any branch.
nothing to commit, working tree clean
```
结论: 源码 clean，无任何 modified/untracked tracked 文件。

## 可用 target 列表（20 个）

APM32F405, APM32F407, AT32F435G, AT32F435M, RP2350A, RP2350B, SITL,
STM32F405, STM32F411, STM32F446, STM32F745, STM32F7X2, STM32G47X,
STM32H563, STM32H723, STM32H725, STM32H730, STM32H735, STM32H743, STM32H750

注意: 任务 spec 中提到的 MATEKF405 / MATEKH743 / AG3X / SPEEDYBEEF405 在 2025.12.5
已不存在（betaflight 已将 target 合并为按 MCU 分类的 20 个 base target）。
冒烟测试改用实际存在的 STM32F405（spec 明确允许的回退选项）。

## gitignore 验证

- `.gitignore` 第 13 行: `obj/`
- `.gitignore` 第 24 行: `/tools/`
- 二者均为 make 产物/工具链目录，写入不影响 git tracked 文件。

## Step 4-5: 编译记录

（见下方各 target 编译输出）
