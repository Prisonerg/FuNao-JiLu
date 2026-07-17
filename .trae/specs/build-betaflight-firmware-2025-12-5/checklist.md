# Checklist

## 环境
- [ ] 构建在独立目录 `/workspace/build/betaflight` 进行，不污染 `/workspace` 下的 wiki 与 spec 文件
- [ ] `arm-none-eabi-gcc`、`make`、`git`、`python3` 工具链可用且版本符合 Betaflight 要求
- [ ] 工具链版本快照已记录到构建日志

## 源码完整性
- [ ] 源码从 `https://github.com/betaflight/betaflight.git` 克隆
- [ ] 精确 checkout 到 tag `2025.12.5`，`git describe --tags` 输出 `2025.12.5`
- [ ] checkout 后 `git status` clean，无本地修改
- [ ] 编译完成后 `git status` 仍 clean（验证「不修改任何数据」核心约束）
- [ ] 全程未对 tracked 文件执行任何写操作（无 patch、无 sed、无 Edit）

## 编译
- [ ] 冒烟测试 target（如 `MATEKF405`）编译退出码 0
- [ ] 冒烟测试产物 `obj/main/betaflight_MATEKF405.hex` 实际生成
- [ ] 至少一个 target 的 `.hex` 文件成功产出
- [ ] 失败 target 已单独标记并报告，未尝试通过改源码去修复

## 产物汇总
- [ ] 输出 target → `.hex` 路径 → 大小 → SHA256 清单
- [ ] 清单标注每个 target 对应的飞控硬件
- [ ] 清单写入 `build-manifest.md` 供用户取用
- [ ] 若用户实际想要的是 Windows `.exe`（即 Configurator），已在最终响应中明确说明 firmware 不产出 `.exe` 并给出后续路径建议
