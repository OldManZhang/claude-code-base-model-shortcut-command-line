# Development Workflow

这份文档说明如何在本仓库做开发。如果只是想用 `cc`，看 [README.md](../README.md)。

## TL;DR

```bash
git clone <repo>
cd claude-code-base-model-shortcut-command-line
mkdir -p .cc.dev
cp models.config.example .cc.dev/models.config
$EDITOR .cc.dev/models.config       # 填 API key

export PATH="$(pwd)/bin:$PATH"
export CC_PATH="$(pwd)/.cc.dev"
cc --dry-run kimi:kimi-for-coding  # 验证配置
./tests/cc_test_cases.sh           # 跑测试
```

## 本地开发设置

`CC_PATH` 环境变量让你在不改 `~/.cc/` 的情况下用本地配置：

```bash
mkdir -p .cc.dev
cp models.config.example .cc.dev/models.config
$EDITOR .cc.dev/models.config
```

`.cc.dev/` 已在 `.gitignore` 里，永远不会误提交。

## 三层验证

按顺序跑，缺一不可：

```bash
# 1. Bash 语法
bash -n bin/cc
bash -n install.sh
bash -n scripts/release.sh

# 2. JSON 语法
jq empty .cc.dev/models.config
jq empty models.config.example

# 3. 集成测试
./tests/cc_test_cases.sh

# 4. 手动 dry-run（改了配置或 load_config 时必跑）
cc --dry-run <provider>:<model>
```

CI 会自动跑 1 / 2 / 3，4 是你自己 dry-run 新场景。

## Commit 规范

[Conventional Commits](https://www.conventionalcommits.org/) 风格，前缀必填，描述用中文：

| 前缀 | 用途 | 是否进 CHANGELOG |
|------|------|------------------|
| `feat` | 新功能 | 是 |
| `fix` | 修复 | 是 |
| `refactor` | 重构（不改行为）| 否 |
| `docs` | 仅文档 | 否 |
| `chore` | 杂项 / 工具 | 否 |
| `release` | 发版（仅 `scripts/release.sh` 使用） | 是 |

例子：

```
feat: 支持 provider/model 级 extra_env 环境变量
fix: macOS 优先使用 .zshrc 配置 PATH
docs: 更新 CLAUDE.md 描述 extra_env 合并规则
```

## 分支策略

单 `main` 分支（见 `openspec/config.yaml`）。需要长命分支时命名 `feat/<name>`，合并后删除。

不要把 `feat/v0.2.4-snapshot` 这类自动命名的分支作为长期分支 —— 那是开发期的临时占位。

## OpenSpec 使用

OpenSpec（v1.4.0+）管理本仓库的设计规格。

### 何时新建 change

当你做的改动：
- 增加 / 修改 CLI 接口（`bin/cc` 命令、参数）
- 改变配置文件 schema（`models.config`）
- 改变安装流程（`install.sh`）

→ 新建 `openspec/changes/<change-name>/`，至少包含：
- `proposal.md` - 提议
- `tasks.md` - 任务清单
- `design.md` - 设计（可选，复杂场景）

### 归档

变更落地后归档到 `openspec/changes/archive/<change-name>/`。CI 校验这步。

### spec 更新

如果变更影响 `openspec/specs/<area>/spec.md` 的需求 / 场景，需要同步更新 spec —— 这是文档化「当前行为」的地方，应与代码同步。

## CHANGELOG 维护

所有用户可见改动写进 `[Unreleased]` 段，按子段分类：

```markdown
## [Unreleased]

### Added
- 新增 minimax:MiniMax-M3 模型

### Changed
- show_current() 现在显示 extra_env

### Fixed
- 修复 macOS 下 PATH 未持久化
```

发版时 `scripts/release.sh` 自动把 `[Unreleased]` 内容搬到新版本段（详见 [RELEASE.md](RELEASE.md)）。

## 测试编写

`tests/cc_test_cases.sh` 是 shell 集成测试。新增 case：

```bash
test_case "测试名称" \
    "$CC --dry-run minimax:MiniMax-M3" \
    "no"   # 期望成功；期望失败写 "yes"
```

`test_case()` 检查 exit code（不看 stdout）。要检查输出内容，单独写一个 case 然后 `grep` 输出。

不要在这里引入新测试框架（bats、shunit2 等）—— 项目体量小，单一 bash 脚本更易维护。

## 敏感信息

API key 只进 `~/.cc/models.config`，绝不进 `models.config.example`（那是模板，会进 git）和 `.cc.dev/models.config`（也已被 `.gitignore` 包含，但避免误提交）。

如果不小心 commit 了 key：
1. 立刻去 provider 控制台 revoke
2. `git filter-repo` 或 BFG 清理历史（仅必要时）
3. 重新发版
