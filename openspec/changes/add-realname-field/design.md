## Overview

在 `models.config` 的模型条目中新增可选 `model_name` 字段，解耦 CLI 调用时使用的模型名与实际发送给 API 的模型名。

## Design

### 配置 Schema 变更

`models.config` 中模型条目新增 `model_name` 字段：

```json
{
  "providers": {
    "xiaomi": {
      "base_url": "https://api.xiaomimimo.com/anthropic",
      "api_key": "sk-...",
      "models": {
        "mimo-v2.5-pro": {
          "enable": true,
          "model_name": "mimo-v2.5-pro[1m]"
        }
      }
    },
    "deepseek": {
      "base_url": "https://api.deepseek.com/anthropic",
      "api_key": "sk-...",
      "models": {
        "deepseek-v4-flash": {
          "enable": true,
          "model_name": "deepseek-v4-flash[1m]"
        }
      }
    }
  }
}
```

### load_config() 变更

在 `load_config()` 中 `export ANTHROPIC_MODEL` 之前新增 model_name 解析：

```bash
# 读取 model_name，不存在则回退 model key
local model_name=$(jq -r --arg p "$provider" --arg m "$model" \
    '.providers[$p].models[$m].model_name // empty' \
    "$MODELS_CONFIG" 2>/dev/null)

export ANTHROPIC_MODEL="${model_name:-$model}"
```

**关键规则**：
- `model_name` 是纯字符串字段，支持任意字符（包括 `[1m]`、空格等）
- `model_name` 不存在或为空时 → 使用模型 key 名（当前行为，完全向后兼容）
- `model_name` 存在且非空时 → 使用 `model_name` 值导出 `ANTHROPIC_MODEL`

### 其他影响

| 位置 | 变化 | 说明 |
|------|------|------|
| `show_current()` / dry-run 输出 | 同时展示 model key 和 model_name | 方便用户确认映射关系 |
| `model_exists()` | 不变 | 仍基于模型 key 校验 |
| `list_configs()` | 可选展示 model_name | 不必须，暂不改动 |

### 未采纳的方案

1. **仅建议用户引号包裹** — 可行但体验差，每次都要手动加引号，且新用户易困惑
2. **在 `cc` 内部 strip `[1m]`** — 过于魔幻，无法区分是故意命名还是脏数据
3. **在模型 key 中支持 glob 转义** — 交给 shell 转义不是 `cc` 的责任
