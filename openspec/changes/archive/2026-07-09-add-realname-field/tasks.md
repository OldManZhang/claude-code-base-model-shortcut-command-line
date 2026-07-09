# Tasks

## Task: bin/cc — load_config() 增加 model_name 读取

**File**: `bin/cc`

在 `load_config()` 中 `export ANTHROPIC_MODEL="$model"` 之前增加 model_name 解析：

```bash
local model_name=$(jq -r --arg p "$provider" --arg m "$model" \
    '.providers[$p].models[$m].model_name // empty' \
    "$MODELS_CONFIG" 2>/dev/null)

export ANTHROPIC_MODEL="${model_name:-$model}"
```

**Done 条件**:
- [x] `cc --dry-run xiaomi:mimo-v2.5-pro` (配置了 `model_name: "mimo-v2.5-pro[1m]"`) 输出 `ANTHROPIC_MODEL=mimo-v2.5-pro[1m]`
- [x] `cc --dry-run kimi:kimi-for-coding`（无 model_name）仍输出 `ANTHROPIC_MODEL=kimi-for-coding`

---

## Task: 更新 models.config.example

**File**: `models.config.example`

在模型条目中添加 `model_name` 示例，展示典型用法。

**Done 条件**:
- [x] `models.config.example` 至少有一个带 `model_name` 的模型条目
- [x] `jq empty models.config.example` 通过

---

## Task: 清理 ~/.cc/models.config 中的 [1m] 脏数据

**File**: `~/.cc/models.config`

将现有模型中带 `[1m]` 的 key 改为干净名字，并将原 key 移入 `model_name` 字段：

| 当前 key | 新 key | model_name |
|----------|--------|------------|
| `MiniMax-M3[1m]` | `MiniMax-M3` | `MiniMax-M3[1m]` |
| `deepseek-v4-flash[1m]` | `deepseek-v4-flash` | `deepseek-v4-flash[1m]` |
| `deepseek-v4-pro[1m]` | `deepseek-v4-pro` | `deepseek-v4-pro[1m]` |
| `mimo-v2.5-pro[1m]` | `mimo-v2.5-pro` | `mimo-v2.5-pro[1m]` |
| `mimo-v2.5[1m]` | `mimo-v2.5` | `mimo-v2.5[1m]` |

同时更新 `MiniMax-M3` 的 `extra_env` 中的 `ANTHROPIC_MODEL` 等值使用 `model_name`。
更新 `default` 字段为干净 key 格式。

**Done 条件**:
- [x] `cc --dry-run` 走 default 成功（default 指向 `deepseek:deepseek-v4-flash`）
- [x] `cc --dry-run deepseek:deepseek-v4-flash` 输出 `ANTHROPIC_MODEL=deepseek-v4-flash[1m]`
- [x] `cc --dry-run xiaomi:mimo-v2.5-pro` 输出 `ANTHROPIC_MODEL=mimo-v2.5-pro[1m]`

---

## Task: 新增测试用例

**File**: `tests/cc_test_cases.sh`

新增以下测试，在 `.cc.dev/models.config` 中添加一个带 `model_name` 的测试用模型。

### 测试数据准备

在 `.cc.dev/models.config` 中添加（例如在 minimax 下）：

```json
"MiniMax-M3-model-name-test": {
  "enable": true,
  "model_name": "MiniMax-M3[1m]"
}
```

### 测试用例

```bash
# model_name 模型 dry-run 正确
test_case "带 model_name 的模型 dry-run 输出正确模型名" \
    "grep -q 'ANTHROPIC_MODEL=MiniMax-M3\\[1m\\]' <($CC --dry-run minimax:MiniMax-M3-model-name-test 2>&1)" \
    "no"

# 无 model_name 的模型行为不变
test_case "无 model_name 模型使用 key 作为模型名" \
    "grep -q 'ANTHROPIC_MODEL=kimi-for-coding' <($CC --dry-run kimi:kimi-for-coding 2>&1)" \
    "no"
```

**Done 条件**:
- [x] `./tests/cc_test_cases.sh` 全部通过，包含新增用例

---

## Task: 更新配置 spec

**File**: `openspec/specs/configuration/spec.md`

在 `Requirement: Model Schema` 中补充 `model_name` 字段的说明和场景。

**Done 条件**:
- [x] spec 文档中 model schema 包含 `model_name` 可选字段

---

## Task: 同步更新 ~/.cc/models.config 中 MiniMax-M3 extra_env

**File**: `~/.cc/models.config`

`MiniMax-M3` 的 `extra_env` 中 `ANTHROPIC_MODEL` 等字段已配置为 `MiniMax-M3[1m]`，现在 `realname` 字段已接管此职责，这些 extra_env 中的模型名覆盖可保留（高优先级覆盖 + 冗余安全）。

**Done 条件**:
- [x] `cc --dry-run minimax:MiniMax-M3` 输出 `ANTHROPIC_MODEL=MiniMax-M3[1m]`（来自 model_name）
