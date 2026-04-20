## Context

当前 cc 工具使用分散的 `~/.cc/configs/env.<provider>` 文件管理配置，需要整合为统一格式。

## Goals / Non-Goals

- Goals:
  - 统一纯 Shell 格式配置文件（无外部依赖）
  - 支持 providers 和 models 分类管理
  - 简洁的命令行使用语法

- Non-Goals:
  - 不改变核心的"加载环境变量启动 Claude"逻辑
  - 不支持运行时动态切换模型（仅配置层面）

## Decisions

- **配置文件位置**: `~/.cc/models.config`
- **配置格式**: 纯 Shell 格式（export 语句），保持无外部依赖
- **解析方式**: 使用 sed/awk 解析，纯 Bash 实现
- **命令行语法**:
  - `cc kimi` → 使用 kimi 默认模型
  - `cc kimi:kimi-1.5` → 使用 kimi provider 的 kimi-1.5 模型
  - `cc kimi:coding` → 使用 kimi provider 的 coding 别名
  - `cc coding` → 自动匹配 provider

## 配置文件结构

使用纯 Shell 格式，便于解析且无需外部依赖：

```bash
# ~/.cc/models.config
# 本文件使用纯 Shell 格式，无需 YAML 解析器

# ===== PROVIDERS =====
# 定义 API 服务端点
# 格式: CC_PROVIDER_<name>_<key>="<value>"
CC_PROVIDER_KIMI_BASE_URL="https://api.kimi.com/coding/"
CC_PROVIDER_KIMI_API_KEY="sk-kimi-xxx"
CC_PROVIDER_KIMI_DEFAULT_MODEL="kimi-for-coding"

CC_PROVIDER_OPENAI_BASE_URL="https://api.openai.com/v1"
CC_PROVIDER_OPENAI_API_KEY="sk-xxx"
CC_PROVIDER_OPENAI_DEFAULT_MODEL="gpt-4"

CC_PROVIDER_ANTHROPIC_BASE_URL="https://api.anthropic.com"
CC_PROVIDER_ANTHROPIC_API_KEY="sk-ant-xxx"
CC_PROVIDER_ANTHROPIC_DEFAULT_MODEL="claude-sonnet-4-20250514"

# ===== MODELS =====
# 定义具体模型
# 格式: CC_MODEL_<name>="<provider>[:<default_alias>]" 或 CC_MODEL_<name>="alias:<target>"
# 直接模型
CC_MODEL_KIMI_FOR_CODING="kimi"
CC_MODEL_KIMI_1_5="kimi"
CC_MODEL_GPT_4="openai"
CC_MODEL_GPT_4O="openai"

# 别名 (target 指向另一个模型)
CC_MODEL_CODING="alias:kimi-for-coding"
CC_MODEL_FAST="alias:gpt-4o-mini"

# ===== DEFAULT =====
CC_DEFAULT_PROVIDER="kimi"
CC_DEFAULT_MODEL="kimi-for-coding"
```

### 解析逻辑

使用 sed/awk 从配置文件中提取值：
- Provider: `CC_PROVIDER_{name}_{key}` → 提取 `base_url`, `api_key`, `default_model`
- Model: `CC_MODEL_{name}` → 判断是 provider 名还是 alias

## Risks / Trade-offs

- **风险**: 配置文件解析复杂度 → 解决：使用 sed/awk 提取，保持纯 shell
- **风险**: 兼容旧配置 → 解决：保留旧文件读取逻辑，优先新配置

## Migration Plan

1. 首次运行时检查 `~/.cc/models.config` 是否存在
2. 如不存在，提示用户创建或运行迁移脚本
3. 提供 `cc migrate` 命令将现有 `env.*` 转换为新格式
