# cc - Claude Command Line Manager

`cc` 是一个简单易用的命令行工具，用于在不同的大模型提供商之间切换配置，并启动 Claude CLI。

## 特性

- 🔄 **快速切换** - 只需一个命令即可切换不同 LLM 提供商
- 📝 **基于配置文件** - 所有配置通过 `~/.cc/configs/` 目录下的配置文件管理，切换就是切换配置文件
- 🎯 **简单配置** - 基于纯环境变量配置文件
- 🔧 **易于扩展** - 添加新提供商只需添加配置文件，无需修改代码
- 📦 **轻量级** - 纯 Shell 脚本，无复杂依赖

## 安装

### 快速安装

```bash
# 克隆或下载项目后
git clone <repository-url>
cd cc-command-line

# 安装到系统
cp bin/cc ~/.local/bin/

# 确认~/.local/bin/ 添加到 PATH
echo $PATH | grep -q "~/.local/bin"

# 重启 terminal

# 验证安装
cc list
```

## 使用方法

所有配置都通过 `~/.cc/configs/` 目录下的配置文件管理。**每个提供商对应一个配置文件**，查看、切换提供商其实就是查看、切换配置文件：

### 查看可用配置（所有配置文件）

```bash
cc list
```

### 显示当前配置

```bash
cc current
```

### 使用默认配置启动 Claude

```bash
# 使用默认提供商启动（ 通过 CC_DEFAULT_PROVIDER 设置）
cc
```

### 切换到指定提供商并启动 Claude（就是切换配置文件）

```bash
# 使用 OpenAI 配置文件
cc openai

# 使用 Anthropic 配置文件
cc anthropic
```

### 查看帮助

```bash
cc help
```

## 配置方法

### 配置文件格式

所有配置文件位于 `~/.cc/configs/` 目录中，遵循 `env.MODEL_NAME` 格式。

配置文件使用标准的 `export` 语句，设置 **ANTHROPIC_** 开头的环境变量：

```bash
# 配置文件命名
env.openai
env.anthropic
```

### 编辑配置文件

编辑相应文件添加您的 API 密钥：

```bash
# 编辑 kimi 配置
vim ~/.cc/configs/env.kimi

# 内容示例：
export ANTHROPIC_BASE_URL="https://api.moonshot.cn"
export ANTHROPIC_AUTH_TOKEN="your-actual-api-key-here"
export ANTHROPIC_MODEL="moonshot-v1-8k"
```

### 设置默认提供商

您可以通过环境变量设置默认提供商：

```bash
# 设置默认提供商为 GLM
export CC_DEFAULT_PROVIDER=glm

# 然后直接使用 cc 启动默认提供商
cc
```

### 获取 API 密钥
- **OpenAI**: [https://platform.openai.com/api-keys](https://platform.openai.com/api-keys)
- **Anthropic**: [https://console.anthropic.com/](https://console.anthropic.com/)

## 添加新提供商

添加新提供商的核心就是**创建新的配置文件** - 无需修改任何代码：

1. 在 `~/.cc/configs/` 目录创建配置文件，格式为 `env.PROVIDER_NAME`：
   ```bash
   vim ~/.cc/configs/env.myprovider
   ```

2. 添加 ANTHROPIC_* 环境变量配置：
   ```bash
   # MyProvider Configuration
   export ANTHROPIC_AUTH_TOKEN="your-api-key"
   export ANTHROPIC_BASE_URL="https://api.myprovider.com"
   export ANTHROPIC_MODEL="my-model"
   ```

3. 使用新配置：
   ```bash
   cc myprovider
   ```

## 项目结构

```
.
├── bin/
│   └── cc                    # cc 命令脚本
└── env.sample                 # 配置文件样例
└── README.md                 # 本文档
```

## 工作原理

整个工具围绕**配置文件**设计，切换提供商就是切换不同的配置文件：

1. `cc <provider>` 命令读取 `~/.cc/configs/env.<provider>` 配置文件
2. 使用 `source` 命令在当前 shell 环境中设置 ANTHROPIC_* 环境变量
3. 自动启动 Claude CLI，传入相应的环境变量
4. 如果不带参数运行 `cc`，会加载默认配置（kimi 或通过 CC_DEFAULT_PROVIDER 环境变量指定）

## 注意事项

- 配置文件使用 `env.MODEL_NAME` 格式命名，包含标准的 `export ANTHROPIC_*` 语句
- API 密钥等敏感信息请妥善保管，不要提交到版本控制系统
- 环境变量只在当前 shell 会话中有效
- 配置文件位于 `~/.cc/configs/` 目录
- 建议在使用前先编辑配置文件添加您的真实 API 密钥
- 默认提供商可通过 `CC_DEFAULT_PROVIDER` 环境变量自定义

## Changelog

### v0.2.1 (2025-03-16)

- **新增**: 添加 CC_PATH 环境变量支持
  - 设置 `CC_PATH` 自定义配置文件目录
  - 默认使用 `~/.cc/configs`

### v0.2.0 (2025-03-16)

- **新增**: 支持将命令行参数传递给 claude CLI
  - `cc kimi --version` - 切换到 kimi 并传递参数
  - `cc --print` - 使用默认 provider 并传递参数
  - `cc glm --print --verbose` - 传递多个参数

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！