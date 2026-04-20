# cli-interface Specification

## Purpose
定义 cc 工具的命令行接口规范。

## ADDED Requirements

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
