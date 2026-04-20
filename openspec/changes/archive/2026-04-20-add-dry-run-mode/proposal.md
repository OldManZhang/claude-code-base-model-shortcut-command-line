# Change: 添加 --dry-run 模式

## Why

测试 cc 工具时，需要验证配置加载是否正确，但不想真的启动 claude CLI。添加 `--dry-run` 模式可以方便验证配置而不执行。

## What Changes

- 添加 `--dry-run` 选项
- 使用 `cc --dry-run <provider:model>` 时，只验证配置并打印环境变量，不启动 claude

## Impact

- Affected specs: `cli-interface`
- Affected files: `bin/cc`
