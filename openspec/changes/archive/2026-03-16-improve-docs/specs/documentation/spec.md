## ADDED Requirements

### Requirement: README 文档完整性

README.md SHALL 包含完整的用户文档，帮助用户快速上手和深入使用。

#### Scenario: 快速开始
- **WHEN** 新用户查看 README
- **THEN** 可以在 5 分钟内完成安装和基本配置

#### Scenario: 配置说明
- **WHEN** 用户需要配置 providers 或 models
- **THEN** README 包含清晰的配置格式说明和示例

#### Scenario: 命令参考
- **WHEN** 用户忘记某个命令用法
- **THEN** README 包含所有命令的完整参考

### Requirement: CHANGELOG 格式规范

CHANGELOG.md SHALL 按照语义化版本格式记录变更。

#### Scenario: 版本记录
- **WHEN** 发布新版本时更新 CHANGELOG
- **THEN** 每个版本包含日期和变更列表

#### Scenario: 版本追溯
- **WHEN** 用户查看历史版本
- **THEN** CHANGELOG 清晰展示每个版本的变更内容
