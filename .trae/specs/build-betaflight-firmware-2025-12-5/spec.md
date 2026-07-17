# Betaflight Firmware 2025.12.5 编译 Spec

## Why

用户希望从 Betaflight firmware 仓库的 `2025.12.5` release tag 原样编译出固件二进制，用于验证官方 release 的可复现性 / 获取自定义目标的构建产物，且要求**不修改任何源码数据**（即严格按照 tag 提交点构建，不打补丁、不改配置）。

## 重要事实澄清（关于 "exe"）

用户原始请求是「编译出 exe」，但需明确：

- URL `https://github.com/betaflight/betaflight/releases/tag/2025.12.5` 指向的是 **Betaflight firmware**（飞控固件）仓库。
- Firmware 的构建工具链是 `arm-none-eabi-gcc`（ARM 交叉编译器），构建产物是 `.hex` / `.bin` / `.elf` 文件，用于通过 Betaflight Configurator 或 DFU 烧录到飞控 MCU（STM32 系列）。**不会产出 `.exe`**。
- Betaflight 体系中真正产出 Windows `.exe` 的是独立项目 **`betaflight/betaflight-configurator`**（基于 NW.js 的桌面应用），与本 tag 不在同一仓库。

本 spec 按 URL 实际指向的 **firmware** 进行编译，产出固件 `.hex`。若用户实际想要 `.exe`，应另起 spec 编译 configurator。

## What Changes

- 在工作目录下克隆 `betaflight/betaflight` 仓库，精确 checkout 到 tag `2025.12.5`。
- 准备 firmware 构建所需的工具链与依赖：`arm-none-eabi-gcc` 工具链、`make`、`git`、`python3`、`openssl` 等。
- **不修改任何源码、配置或 Makefile**：所有构建基于 tag 原始提交点。
- 对一组常用目标（targets）执行 `make TARGET=<target>`，产出对应 `.hex` 文件。
- 不打补丁、不替换文件、不调整编译参数（除工具链路径等环境必需项）。
- **BREAKING**：无（仅构建，不修改既有系统状态）。

## Impact

- **Affected specs**：无（本仓库为 GBrain-core Wiki 项目，本 spec 是独立的构建任务，不影响 wiki schema）。
- **Affected code**：不修改 `/workspace` 既有文件；构建将在 `/workspace` 下的新目录（如 `/workspace/build/betaflight`）中进行，克隆的源码与产物均落在此目录。
- **外部依赖**：需要网络访问 GitHub 与 ARM 工具链下载源；需要磁盘空间（源码 + 各 target 构建产物，约数百 MB 至数 GB 视目标数量而定）。

## ADDED Requirements

### Requirement: 从 tag 2025.12.5 原样编译 firmware

系统 SHALL 在不修改 Betaflight 源码的前提下，从 `2025.12.5` tag 成功编译出指定 target 的 `.hex` 固件文件。

#### Scenario: 源码获取

- **WHEN** 执行 `git clone` 并 `git checkout 2025.12.5`
- **THEN** 仓库工作区处于 tag 对应的提交点，`git status` 干净，无任何本地修改。

#### Scenario: 工具链就绪

- **WHEN** 检查构建环境
- **THEN** `arm-none-eabi-gcc`、`make`、`git`、`python3` 可用且版本满足 Betaflight 构建要求（参考 `docs/development/` 或 `Makefile` 中的最低版本约束）。

#### Scenario: 单 target 编译成功

- **WHEN** 对某 target（如 `MATEKF405`）执行 `make TARGET=MATEKF405`
- **THEN** 构建退出码为 0，且 `obj/main/betaflight_MATEKF405.hex`（或对应产物路径）生成。

#### Scenario: 不修改源码数据

- **WHEN** 编译完成后再次执行 `git status`
- **THEN** 仓库工作区仍干净（构建产物在 `obj/` 等被 `.gitignore` 忽略的路径下，不影响源码 tracked 文件）。任何中间生成文件都位于 gitignored 目录，源码数据零修改。

### Requirement: 构建产物可识别与汇总

系统 SHALL 在编译结束后，列出所有生成的 `.hex` 文件路径与大小，便于用户取用。

#### Scenario: 产物清单

- **WHEN** 编译流程结束
- **THEN** 输出一份产物清单（target 名 → `.hex` 路径 → 文件大小），并指明可烧录的飞控硬件。
