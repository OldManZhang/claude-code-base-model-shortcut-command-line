# Change: 支持模型级别的环境变量配置

## Why

当前 `models.config` 中的模型配置只支持 `provider` 和 `id` 两个核心字段。用户希望在模型配置中能够添加额外的环境变量（如 `ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL` 等），这些变量在 cc 启动 Claude CLI 之前应该被读取并导出到环境变量中。

## What Changes

- 在 `models.config` 中，模型配置除了支持 `provider` 和 `id` 字段外，还支持任意额外的环境变量字段
- `bin/cc` 在加载模型配置时，除了导出 `ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN`、`ANTHROPIC_MODEL` 外，还需要遍历并导出模型配置中的其他字段
- 这些额外字段必须是以 `ANTHROPIC_` 开头的环境变量

## Impact

- Affected specs: `configuration`
- Affected code: `bin/cc` 中的 `load_config` 和 `load_from_models_config` 函数
