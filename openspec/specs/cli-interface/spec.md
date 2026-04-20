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
- **AND** 打印将设置的环境变量（ANTHROPIC_BASE_URL, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_MODEL）
- **AND** 不启动 claude CLI
- **AND** 返回 exit code 0

#### Scenario: Dry-run 显示环境变量
- **WHEN** dry-run 模式验证通过
- **THEN** 打印以下信息：
  ```
  DRY-RUN: Configuration would be:
  ANTHROPIC_BASE_URL=<value>
  ANTHROPIC_AUTH_TOKEN=<masked>
  ANTHROPIC_MODEL=<value>
  ```

