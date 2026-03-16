# cc 新版本更新说明

## 概述

cc (Claude Command Line Manager) 新版本带来了多项重要更新，统一了配置管理方式，增加了灵活性和易用性。

---

## 快速开始

```bash
# 一键安装
curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh

# 使 PATH 生效
source ~/.zshrc

# 列出可用提供商
cc list

# 切换到指定提供商
cc kimi
```

---

## 新增功能

### 1. 一键安装脚本

使用 JSON 格式的单一配置文件管理所有配置。

```json
{
  "providers": {
    "kimi": {
      "base_url": "https://api.moonshot.cn",
      "api_key": "your-api-key"
    }
  },
  "models": {
    "kimi": {
      "provider": "kimi",
      "id": "kimi-for-coding"
    }
  },
  "default": "kimi"
}
```

**配置文件位置**: `~/.cc/models.config`

### 2. 支持模型别名

为常用模型设置简短别名，方便快速切换：

```json
{
  "models": {
    "code": "kimi",
    "fast": "glm:glm-4-flash",
    "gpt4": "openai:gpt-4o"
  }
}
```

### 3. 指定具体模型

使用 `provider:model` 语法指定具体模型：

```bash
cc kimi:moonshot-v1-8k
cc openai:gpt-4o
cc glm:glm-4-flash
```

### 4. 命令行参数透传

可以将参数传递给底层的 claude CLI：

```bash
cc kimi --version
cc --print
cc glm --print --verbose
```

### 5. CC_PATH 环境变量

自定义配置文件目录：

```bash
export CC_PATH="/path/to/your/configs"
```

### 6. 向后兼容

同时支持新的 JSON 配置和旧的 `env.*` 配置格式。

---

## 使用示例

### 基本用法

| 命令 | 说明 |
|------|------|
| `cc` | 使用默认配置启动 Claude |
| `cc kimi` | 切换到 kimi 提供商 |
| `cc list` | 列出所有可用配置 |
| `cc current` | 显示当前配置 |

### 高级用法

```bash
# 指定具体模型
cc kimi:moonshot-v1-8k

# 使用别名
cc gpt4
cc minimax-m2.5

# 传递参数给 claude
cc kimi --print
cc --version
```

### 直接使用环境变量

```bash
# 不使用 cc，直接设置环境变量
export ANTHROPIC_BASE_URL="https://api.moonshot.cn"
export ANTHROPIC_AUTH_TOKEN="your-api-key"
export ANTHROPIC_MODEL="moonshot-v1-8k"
claude
```

---

## 命令输出示例

### cc list

```
Available configurations:

Environment variables:
  CC_PATH=~/.cc
  LLM_PROVIDER=<not set>

Configuration file: ~/.cc/models.config (JSON format)

Providers:
  kimi
  glm
  openai
  anthropic
  minimax

Models/Aliases:
  kimi (kimi:kimi-for-coding)
  qwen (bailian:qwen3.5-plug)
  claude-sonnet (anthropic:claude-sonnet-4-20250514)
  gpt4 (openai:gpt-4o)
  minimax-m2.5 (minimax:MiniMax-M2.5) [default]
  minimax-fast (minimax:MiniMax-M2.5-highspeed)

Tip: Set env vars to use directly:
  export ANTHROPIC_BASE_URL=https://api.example.com
  export ANTHROPIC_AUTH_TOKEN=your-api-key
  claude  # Run claude directly
```

### cc kimi:moonshot-v1-8k

```
Loading kimi with model moonshot-v1-8k...

✓ Configuration loaded for kimi
Model: moonshot-v1-8k

✓ Now you can use Claude with kimi configuration

Starting Claude CLI...
```

### cc current

```
Current configuration status:

Environment variables:
  CC_PATH=~/.cc
  LLM_PROVIDER=<not set>

Configuration file: ~/.cc/models.config

No configuration is currently active

Tip: Set env vars to use directly:
  export ANTHROPIC_BASE_URL=https://api.example.com
  export ANTHROPIC_AUTH_TOKEN=your-api-key
  claude  # Run claude directly
```

### cc (使用默认配置)

```
Using default provider: minimax-m2.5

Loading configuration for minimax...

✓ Configuration loaded for minimax
Model: MiniMax-M2.5

✓ Now you can use Claude with minimax configuration

Starting Claude CLI...
```

---

## 环境变量参考

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `CC_PATH` | 配置目录 | `~/.cc` |
| `LLM_PROVIDER` | 当前活跃的提供商 | - |
| `ANTHROPIC_BASE_URL` | API 端点 | - |
| `ANTHROPIC_AUTH_TOKEN` | API 密钥 | - |
| `ANTHROPIC_MODEL` | 模型名称 | - |

---

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|----------|
| v0.2.2 | 2026-03-16 | 修复 JSON 格式兼容性问题，install.sh 生成纯 JSON |
| v0.2.1 | 2026-03-16 | 添加 CC_PATH 环境变量支持 |
| v0.2.0 | 2026-03-16 | 添加命令行参数透传支持 |
| v0.1.0 | 2026-01-29 | 初始版本，支持多 provider 切换 |

---

## 迁移指南

### 从旧版本升级

v0.2.x 完全向后兼容，旧版的 `~/.cc/configs/env.*` 配置文件仍然可用。

### 使用新配置格式

1. 复制示例配置：
   ```bash
   cp configs/models.config.example ~/.cc/models.config
   ```

2. 编辑配置，填入你的 API 密钥：
   ```bash
   vim ~/.cc/models.config
   ```

3. 新的 JSON 配置会优先使用，旧版配置作为备选。
