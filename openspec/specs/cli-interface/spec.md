# cli-interface Specification

## Purpose
TBD - created by archiving change add-passthrough-arguments. Update Purpose after archive.
## Requirements
### Requirement: CLI 参数传递

cc 工具 SHALL 将所有额外命令行参数传递给底层的 claude CLI 命令。

#### Scenario: 带 provider 和参数
- **WHEN** 用户运行 `cc <provider> <args...>`
- **THEN** cc 加载指定 provider 的配置，并传递 `<args...>` 给 claude 命令

#### Scenario: 默认 provider 带参数
- **WHEN** 用户运行 `cc <args...>` 且未指定 provider
- **THEN** cc 使用默认 provider (CC_DEFAULT_PROVIDER 或 kimi)，并传递 `<args...>` 给 claude 命令

#### Scenario: 无参数
- **WHEN** 用户运行 `cc <provider>` 或 `cc` 无额外参数
- **THEN** cc 行为保持不变，正常启动 claude

### Requirement: Dry-run 模式

cc 工具 SHALL 支持 `--dry-run` 选项。

#### Scenario: Dry-run 验证配置
- **WHEN** 用户运行 `cc --dry-run <provider>:<model>`
- **THEN** 工具 SHALL 验证 provider 和 model 是否存在
- **AND** 按 provider 的认证字段打印将设置的环境变量（ANTHROPIC_BASE_URL、
  ANTHROPIC_AUTH_TOKEN 或 ANTHROPIC_API_KEY、ANTHROPIC_MODEL）
- **AND** 打印 `(auth: token)` 或 `(auth: api_key)` 标识所用认证方式
- **AND** 不启动 claude CLI
- **AND** 返回 exit code 0

#### Scenario: Dry-run 显示环境变量（token 认证）
- **WHEN** dry-run 模式验证通过且 provider 使用 `anthropic_auth_token`
- **THEN** 打印以下信息：
  ```
  DRY-RUN: Configuration would be:
  ANTHROPIC_BASE_URL=<value>
  ANTHROPIC_AUTH_TOKEN=<masked>
  ANTHROPIC_MODEL=<value>
  (auth: token)
  ```

#### Scenario: Dry-run 显示环境变量（api_key 认证）
- **WHEN** dry-run 模式验证通过且 provider 使用 `anthropic_api_key`
- **THEN** 打印 `ANTHROPIC_API_KEY=<masked>` 而非 `ANTHROPIC_AUTH_TOKEN` 行，
  并包含 `(auth: api_key)` 标识

#### Scenario: Dry-run 校验互斥错误
- **WHEN** provider 同时设置两个认证字段或均未设置
- **THEN** dry-run SHALL 同样报错并返回非零退出码

### Requirement: 参数分隔符

cc 工具 SHALL 使用 `--` 分隔符区分 cc 参数和 claude 参数。

#### Scenario: 使用分隔符传递 claude 参数
- **WHEN** 用户运行 `cc <provider>:<model> -- <claude args>`
- **THEN** `--` 之前的参数由 cc 解析
- **AND** `--` 之后的参数透传给 claude CLI

#### Scenario: 无 claude 参数
- **WHEN** 用户运行 `cc <provider>:<model>`（无 `--`）
- **THEN** cc 启动交互式 claude CLI

#### Scenario: Dry-run 模式
- **WHEN** 用户运行 `cc --dry-run <provider>:<model> -- <claude args>`
- **THEN** 验证配置后不启动 claude
- **AND** claude 参数被忽略

