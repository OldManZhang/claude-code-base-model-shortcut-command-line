# cli-interface Specification

## Purpose
定义 cc 工具的命令行接口规范。

## ADDED Requirements

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
