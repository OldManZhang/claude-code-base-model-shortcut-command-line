## Why

部分 LLM 提供商的模型名包含 shell glob 特殊字符（如 DeepSeek 的 `deepseek-v4-flash[1m]`），导致用户在 zsh/bash 中使用 `cc <provider>:<model>` 时必须手动引号包裹参数，否则 shell 将 `[1m]` 解析为通配符并报错 `no matches found`。这不仅影响日常体验，也容易让新用户困惑。

## What Changes

- `models.config` 的模型条目新增可选字段 `model_name`，存放实际发送给 API 的模型名字符串
- `load_config()` 中 `ANTHROPIC_MODEL` 的取值逻辑：
  - 若 `model_name` 存在，则使用 `model_name`
  - 若 `model_name` 不存在，则回退使用当前行为（配置 key 名）
- 模型 key 本身保持为 CLI 级「干净」名字，不再包含 `[1m]` 等 shell 特殊字符
- 同步更新 `models.config.example`，添加 `model_name` 使用示例
- 同步更新 `openspec/specs/configuration/spec.md`，补充 `model_name` 字段的规范

**非 Breaking Change**：`model_name` 为可选字段，不设 `model_name` 的现有模型行为完全不变。

## Capabilities

### New Capabilities

- `model-name-field`: 模型配置中可选的 `model_name` 字段，用于分离 CLI 调用名与实际 API 模型名

### Modified Capabilities

- `configuration`: 模型 Schema 新增可选 `model_name` 字段；`ANTHROPIC_MODEL` 导出逻辑增加 model_name 优先规则

## Impact

- **`bin/cc`** — `load_config()` 中读取 `model_name` 并覆写 `ANTHROPIC_MODEL`（约 +5 行）
- **`models.config.example`** — 在示例中添加 `model_name` 用法
- **`tests/cc_test_cases.sh`** — 新增带 `model_name` 的模型测试用例（含 dry-run 验证输出中模型名正确）
- **配置兼容性** — 现有 `~/.cc/models.config` 无需任何修改；`model_name` 是完全可选的增量字段
