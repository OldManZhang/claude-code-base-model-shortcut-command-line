# Change: 使用统一的配置文件管理 providers 和 models

## Why

当前 `cc` 工具使用分散的 `env.*` 配置文件管理 LLM provider 配置，导致：
1. 配置分散难以维护
2. 无法同时管理 providers（服务端点）和 models（具体模型）
3. 用户需要记住每个 provider 对应的模型

通过整合为单一的 `~/.cc/models.config` 纯 Shell 格式文件，可以更方便地进行配置管理，同时保持无外部依赖。

## What Changes

- 使用纯 Shell 格式的单一配置文件 `~/.cc/models.config`
- 支持 `providers` 和 `models` 两个配置大类
- 新语法：`cc <provider>:<model>` 或 `cc <provider>:<alias>`
- 兼容旧语法：`cc <provider>` 或 `cc <alias>`（自动匹配 provider）

**BREAKING**: 配置文件路径和格式变更，需要迁移

## Impact

- Affected specs: configuration
- Affected code: `bin/cc`, `configs/`
