# Change: 简化 cc 命令行语法 — 移除 alias 支持，统一使用 provider:model 格式

## Why

当前 `cc` 支持两种调用方式：
- `cc <provider>:<model>` — 直接指定 provider 和 model
- `cc <alias>` — 通过 alias 间接解析

用户反馈 `provider:model` 方式不生效，实际走的是 alias 逻辑。需要统一为更直观的方式。

## What Changes

1. **简化 models.config 结构**
   - 将 `models` 节点并入 `providers` 节点
   - 每个 provider 内的 `models` 是对象，每个 model 有 `enable` 属性（默认 true）
   - `default` 格式改为 `provider:model` 字符串

2. **简化 bin/cc 逻辑**
   - 移除 alias 相关代码
   - 移除 `models` 顶层节点解析
   - 强制要求 `cc <provider>:<model>` 格式

3. **Breaking Change**
   - `models` 节点结构变更，旧配置需迁移
   - `cc <alias>` 语法移除
   - `cc <provider>` 不再允许，必须指定 model

## Impact

- Affected specs: `configuration`
- Affected files: `bin/cc`、`models.config` 格式
