# cli-interface Specification

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: 配置自动迁移提示

cc SHALL 在旧版配置被自动升级时向用户输出可见提示。

#### Scenario: 迁移发生时

- **WHEN** cc 检测到 `models.config` 缺少 `config_version` 并执行迁移
- **THEN** 输出包含备份路径与 `api_key -> anthropic_auth_token` 变更说明的提示行

#### Scenario: 无需迁移时

- **WHEN** 配置已包含 `config_version`
- **THEN** 不输出任何迁移相关提示
