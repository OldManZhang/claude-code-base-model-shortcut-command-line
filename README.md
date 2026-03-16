# cc - Claude Command Line Manager

`cc` 是一个轻量级的命令行工具，用于在不同的大模型提供商之间切换配置，并启动 Claude CLI。

## 特性

- **快速切换** - 只需一个命令即可切换不同 LLM 提供商
- **基于配置文件** - 所有配置通过 `~/.cc/models.config` 统一管理
- **简单配置** - 纯 Shell 脚本格式，无需复杂依赖
- **易于扩展** - 添加新提供商只需添加配置，无需修改代码
- **轻量级** - 纯 Shell 脚本，无外部依赖

## 快速开始

```bash
# 一键安装
curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh

# 使 PATH 生效
source ~/.zshrc

# 列出可用提供商
cc list

# 使用默认配置启动 Claude
cc

# 切换到指定提供商
cc kimi
```

## 安装

### 一键安装 (推荐)

```bash
curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh
```

安装完成后，运行以下命令使 PATH 生效：

```bash
source ~/.zshrc  # 或 ~/.bashrc
```

### 手动安装

```bash
# 克隆项目
git clone https://github.com/OldManZhang/claude-code-base-model-shortcut-command-line.git
cd claude-code-base-model-shortcut-command-line

# 安装到 ~/.local/bin/
cp bin/cc ~/.local/bin/cc

# 确保 ~/.local/bin 在 PATH 中
# 编辑 ~/.zshrc 添加: export PATH="$HOME/.local/bin:$PATH"

# 生效配置
source ~/.zshrc

# 验证安装
cc list
```

## 使用方法

### 基本命令

```bash
# 列出所有可用配置
cc list

# 显示当前配置
cc current

# 使用默认配置启动 Claude
cc

# 切换到指定提供商
cc kimi
cc openai
cc glm

# 传递参数给 claude CLI
cc kimi --version
cc --print
```

### 高级用法

```bash
# 指定具体模型
cc kimi:moonshot-v1-8k

# 使用模型别名
cc kimi:code

# 传递多个参数
cc glm --print --verbose
```

## 配置方法

### 配置文件位置

配置文件位于 `~/.cc/models.config`（推荐）或 `~/.cc/configs/env.*`（兼容旧版本）。

### models.config 格式

配置文件为 JSON 格式，位于 `~/.cc/models.config`。

```json
{
  "providers": {
    "kimi": {
      "base_url": "https://api.kimi.com/coding/",
      "api_key": "your-kimi-api-key",
      "default_model": "kimi-for-coding"
    },
    "glm": {
      "base_url": "https://open.bigmodel.cn/api/anthropic",
      "api_key": "your-glm-api-key"
    },
    "openai": {
      "base_url": "https://api.openai.com/v1",
      "api_key": "your-openai-api-key"
    },
    "minimax": {
      "base_url": "https://api.minimaxi.com/anthropic",
      "api_key": "your-minimax-api-key",
      "default_model": "MiniMax-M2.5"
    }
  },
  "models": {
    "claude-sonnet": {
      "provider": "anthropic",
      "id": "claude-sonnet-4-20250514"
    },
    "gpt4": {
      "provider": "openai",
      "id": "gpt-4o"
    },
    "minimax-m2.5": {
      "provider": "minimax",
      "id": "MiniMax-M2.5"
    }
  },
  "default": {
    "provider": "kimi"
  }
}
```

**字段说明：**
- `providers` - 定义 API 提供商，每个 provider 包含：
  - `base_url`: API 端点地址
  - `api_key`: API 密钥
  - `default_model`: 可选，默认使用的模型
- `models` - 定义模型别名，方便使用
  - `provider`: 对应的 provider 名称
  - `id`: 具体模型 ID
- `default` - 设置默认 provider

### 直接使用环境变量

如果不想使用配置文件，也可以直接设置环境变量：

```bash
# 方法 1: 在命令行设置
export ANTHROPIC_BASE_URL="https://api.moonshot.cn"
export ANTHROPIC_AUTH_TOKEN="your-api-key"
export ANTHROPIC_MODEL="moonshot-v1-8k"
claude

# 方法 2: 在 shell 配置中设置
# 在 ~/.zshrc 中添加:
# export ANTHROPIC_AUTH_TOKEN="your-api-key"
```

### 设置默认提供商

在 `~/.cc/models.config` 的 `default` 字段中设置：

```json
"default": {
  "provider": "kimi"
}
```

### 自定义配置目录

```bash
# 使用 CC_PATH 环境变量自定义配置目录
export CC_PATH="/path/to/your/configs"
```

### 获取 API 密钥

- **Kimi (Moonshot)**: [https://platform.moonshot.cn/](https://platform.moonshot.cn/)
- **GLM (Zhipu AI)**: [https://open.bigmodel.cn/](https://open.bigmodel.cn/)
- **OpenAI**: [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Anthropic**: [https://console.anthropic.com/](https://console.anthropic.com/)

## 添加新提供商

1. 编辑 `~/.cc/models.config`
2. 在 `providers` 中添加新配置：
   ```json
   "myprovider": {
     "base_url": "https://api.myprovider.com/anthropic",
     "api_key": "your-api-key",
     "default_model": "my-model-name"
   }
   ```
3. 可选：在 `models` 中添加别名：
   ```json
   "my-alias": {
     "provider": "myprovider",
     "id": "my-model-name"
   }
   ```
4. 使用：
   ```bash
   cc myprovider
   # 或
   cc myprovider:my-model
   # 或
   cc my-alias
   ```

## 环境变量参考

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `CC_PATH` | 配置目录 | `~/.cc` |
| `ANTHROPIC_BASE_URL` | API 端点 | - |
| `ANTHROPIC_AUTH_TOKEN` | API 密钥 | - |
| `ANTHROPIC_MODEL` | 模型名称 | - |

## 常见问题

### Q: 安装后提示 "command not found"

确保 `~/.local/bin` 在 PATH 中：
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Q: 如何查看当前使用的是哪个配置？

```bash
cc current
```

### Q: 配置文件在哪里？

- 推荐: `~/.cc/models.config`
- 兼容旧版: `~/.cc/configs/env.*`

### Q: 可以同时使用多个配置吗？

可以，每次运行 `cc <provider>` 会在新的 shell 会话中加载对应配置。

### Q: API 密钥安全吗？

配置文件中的密钥仅存储在本地，不会被提交到版本控制系统。建议设置适当的文件权限：
```bash
chmod 600 ~/.cc/models.config
```

## 项目结构

```
.
├── bin/
│   └── cc                    # 主命令脚本
├── configs/                  # 配置文件目录
├── install.sh                # 安装脚本
└── README.md                 # 本文档
```

## 工作原理

1. `cc <provider>` 读取 `~/.cc/models.config` 中的对应配置
2. 使用 `source` 命令设置 `ANTHROPIC_*` 环境变量
3. 启动 Claude CLI，传入相应的环境变量

## 注意事项

- API 密钥等敏感信息请妥善保管，不要提交到版本控制系统
- 环境变量只在当前 shell 会话中有效
- 建议在使用前先编辑配置文件添加您的真实 API 密钥

## 相关链接

- [Claude CLI 文档](https://docs.anthropic.com/en/docs/claude-code)
- [Moonshot API 文档](https://platform.moonshot.cn/docs)
- [Zhipu AI API 文档](https://open.bigmodel.cn/doc/)

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！
