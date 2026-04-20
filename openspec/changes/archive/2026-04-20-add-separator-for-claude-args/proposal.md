# Change: 使用 `--` 分隔 cc 参数和 claude 参数

## Why

当前所有参数都透传给 claude，不够清晰。使用 `--` 分隔符可以明确区分：
- `--` 前面是 cc 自身的参数（如 `--dry-run`、`provider:model`）
- `--` 后面是透传给 claude 的参数

没有 `--` 时，cc 启动交互式 claude CLI，不传递任何参数。

## What Changes

命令行格式变为：
```
cc [cc options] <provider>:<model> -- [claude arguments]
```

示例：
- `cc --dry-run kimi:kimi-for-coding` — 只验证配置，不启动 claude
- `cc kimi:kimi-for-coding` — 启动交互式 claude（无参数透传）
- `cc kimi:kimi-for-coding -- --print "hello"` — 使用 kimi 配置，传递 `--print "hello"` 给 claude
- `cc --dry-run kimi:kimi-for-coding -- --print "hello"` — 验证配置，claude args 被忽略

## Impact

- Affected specs: `cli-interface`
- Affected files: `bin/cc`
