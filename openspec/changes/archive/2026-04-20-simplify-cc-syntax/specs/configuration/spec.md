# configuration Specification

## Purpose
简化 cc 工具的配置格式和命令行语法，统一使用 provider:model 格式。

## ADDED Requirements

### Requirement: Provider 内嵌 Models 配置

配置文件的 `providers` 部分 SHALL 包含每个 provider 的：
- `base_url`: API 端点地址
- `api_key`: API 密钥
- `models`: 模型配置对象

#### Scenario: Provider 模型配置
- **WHEN** provider 配置包含 models 对象
- **THEN** 每个 model 的 key 是 model ID，value 是包含 `enable` 属性的对象
- **AND** `enable` 默认为 true

### Requirement: Default 格式

配置文件的 `default` SHALL 是字符串，格式为 `provider:model`。

#### Scenario: 默认配置格式
- **WHEN** `default` 设置为 `"kimi:kimi-for-coding"`
- **THEN** 表示默认使用 kimi provider 的 kimi-for-coding 模型

## MODIFIED Requirements

### Requirement: 命令行语法

cc 工具 SHALL 只支持 `provider:model` 格式。

#### Scenario: 必须指定 model
- **WHEN** 用户运行 `cc <provider>` 但未指定 model
- **THEN** 工具 SHALL 报错，提示必须使用 `provider:model` 格式

#### Scenario: Provider:Model 语法
- **WHEN** 用户运行 `cc <provider>:<model>`
- **THEN** 使用指定 provider 的指定模型启动 Claude

## REMOVED Requirements

### Requirement: Alias 语法

cc 工具 SHALL 不再支持 alias 语法。

### Requirement: 顶层 Models 节点

配置文件的 `models` 顶层节点 SHALL 被移除，models 配置并入 providers 节点内。
