## ADDED Requirements

### Requirement: CC_PATH 环境变量支持
工具 SHALL 支持通过 CC_PATH 环境变量指定自定义配置目录。

#### Scenario: 使用自定义配置目录
- **WHEN** 用户设置 `CC_PATH` 环境变量并运行 `cc` 命令
- **THEN** 工具 SHALL 从 `$CC_PATH` 目录加载配置文件

#### Scenario: 使用默认配置目录
- **WHEN** 用户未设置 `CC_PATH` 环境变量并运行 `cc` 命令
- **THEN** 工具 SHALL 从 `~/.cc/configs` 目录加载配置文件

#### Scenario: 显示 CC_PATH 状态
- **WHEN** 用户运行 `cc list` 或 `cc current` 命令
- **THEN** 工具 SHALL 显示当前 CC_PATH 的值（已设置的值或 `<default>`）
