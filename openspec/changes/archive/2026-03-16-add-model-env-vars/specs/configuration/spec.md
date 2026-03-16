## MODIFIED Requirements
### Requirement: Model 配置

配置文件的 `models` 部分 SHALL 支持：
- 直接模型配置：指定 `provider` 属性
- 别名配置：指定 `target` 属性指向另一个模型
- **额外环境变量**：除了 `provider` 和 `id` 之外，可以添加任意 `ANTHROPIC_` 开头的环境变量

#### Scenario: 直接模型
- **WHEN** model 配置指定了 `provider` 属性
- **THEN** 使用该 provider 和模型启动 Claude

#### Scenario: 模型别名
- **WHEN** model 配置指定了 `target` 属性
- **THEN** 解析 target 指向的实际模型，然后启动 Claude

#### Scenario: 模型额外环境变量
- **WHEN** model 配置中包含 `ANTHROPIC_` 开头的额外字段
- **THEN** 在启动 Claude 前，将这些额外字段导出为环境变量
- **AND** 额外环境变量的优先级高于 provider 级别的环境变量

#### Scenario: MiniMax 默认模型配置
- **WHEN** 用户配置了 MiniMax 模型，并设置了 `ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL`
- **THEN** 这些变量在 cc 启动 Claude 时被正确导出
