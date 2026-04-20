## ADDED Requirements

### Requirement: Shell 配置文件格式

cc 工具 SHALL 从 `~/.cc/models.config` 文件读取 providers 和 models 配置。

#### Scenario: 加载配置文件
- **WHEN** cc 工具启动且 `~/.cc/models.config` 存在
- **THEN** 解析 Shell 格式文件并加载 providers 和 models 配置

### Requirement: Provider 配置

配置文件的 `providers` 部分 SHALL 包含每个 provider 的：
- `base_url`: API 端点地址
- `api_key`: API 密钥
- `default_model`: 默认使用的模型

#### Scenario: Provider 配置完整
- **WHEN** provider 配置包含 base_url, api_key, default_model
- **THEN** 使用该 provider 的默认模型启动 Claude

### Requirement: Model 配置

配置文件的 `models` 部分 SHALL 支持：
- 直接模型配置：指定 `provider` 属性
- 别名配置：指定 `target` 属性指向另一个模型

#### Scenario: 直接模型
- **WHEN** model 配置指定了 `provider` 属性
- **THEN** 使用该 provider 和模型启动 Claude

#### Scenario: 模型别名
- **WHEN** model 配置指定了 `target` 属性
- **THEN** 解析 target 指向的实际模型，然后启动 Claude

### Requirement: 命令行语法

cc 工具 SHALL 支持以下命令行语法：

#### Scenario: Provider 语法
- **WHEN** 用户运行 `cc <provider>`
- **THEN** 使用该 provider 的默认模型启动 Claude

#### Scenario: Provider:Model 语法
- **WHEN** 用户运行 `cc <provider>:<model>`
- **THEN** 使用指定 provider 的指定模型启动 Claude

#### Scenario: Alias 语法
- **WHEN** 用户运行 `cc <alias>`（非 provider 名称）
- **THEN** 查找 alias 指向的模型并启动 Claude

### Requirement: 向后兼容

cc 工具 SHALL 保持与旧配置文件的兼容。

#### Scenario: 旧配置文件存在
- **WHEN** `~/.cc/models.config` 不存在但 `~/.cc/configs/env.*` 存在
- **THEN** 使用旧的配置文件方式加载配置
