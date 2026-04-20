## ADDED Requirements

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
