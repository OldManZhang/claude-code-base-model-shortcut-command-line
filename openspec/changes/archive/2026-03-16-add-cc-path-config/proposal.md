# Change: 添加 CC_PATH 环境变量支持

## Why

目前 `cc` 工具使用固定的配置目录 `~/.cc/configs`，用户无法自定义配置文件的存放位置。这限制了工具的灵活性，特别是对于需要管理多组配置或在不同环境间切换的用户。

## What Changes

- 添加 `CC_PATH` 环境变量支持
- 当 `CC_PATH` 已设置时，使用 `$CC_PATH` 作为配置目录
- 当 `CC_PATH` 未设置时，保持现有行为，使用 `~/.cc/configs` 作为默认配置目录
- 更新帮助文档，说明 `CC_PATH` 环境变量的用途
- 更新 `list` 和 `current` 命令显示 `CC_PATH` 的当前值

## Impact

- Affected specs: configuration
- Affected code: `bin/cc` (CONFIGS_DIR 变量定义及相关输出)
