# Change: 支持将参数传递给 claude CLI

## Why

当前 `cc` 工具不支持将命令行参数传递给底层的 `claude` 命令。用户运行如 `cc kimi --print` 时，参数会被忽略。这限制了用户使用 claude CLI 高级功能（如 `--print`、`--version`、`--dangerously-skip-permissions` 等）的能力。

## What Changes

- 支持 `cc <provider> <args...>` 语法，将额外参数传递给 claude 命令
- 支持 `cc <args...>` 无 provider 参数时，也传递参数给默认配置的 claude
- 参数透传不经过任何过滤或处理

**BREAKING**: 无破坏性变更

## Impact

- Affected specs: cli-interface
- Affected code: `bin/cc`
