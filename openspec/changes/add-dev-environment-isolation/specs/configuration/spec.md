## ADDED Requirements

### Requirement: 本地开发环境隔离

cc 工具 SHALL 支持使用项目本地的 `.cc.dev/` 目录作为开发配置，该目录应被 `.gitignore` 忽略。

#### Scenario: 使用本地开发配置
- **WHEN** 用户在项目根目录创建 `.cc.dev/` 目录并配置 `models.config`
- **AND** 用户运行 `CC_PATH="$(pwd)/.cc.dev" cc <provider>`
- **THEN** 工具 SHALL 从 `.cc.dev/` 目录加载配置

#### Scenario: .cc.dev 目录被版本控制忽略
- **WHEN** 用户在项目内创建 `.cc.dev/` 目录
- **THEN** 该目录 SHALL 被 `.gitignore` 忽略，不会被提交到版本控制系统
