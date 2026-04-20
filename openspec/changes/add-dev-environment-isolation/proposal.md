# Change: 添加本地开发环境隔离支持

## Why

当前 `cc` 工具已支持通过 `CC_PATH` 环境变量指定自定义配置目录，但用户需要手动创建目录和配置。用户希望在项目本地进行开发测试时，能够隔离开发/测试配置与生产配置，避免影响本机的生产环境设置。

## What Changes

- 在 `.gitignore` 中添加 `.cc.dev/` 目录忽略规则
- 用户可在项目根目录创建 `.cc.dev/` 目录作为本地开发配置
- 使用方式：`CC_PATH="$(pwd)/.cc.dev" cc <provider>`

## Impact

- Affected specs: `configuration`
- Affected files: `.gitignore`
