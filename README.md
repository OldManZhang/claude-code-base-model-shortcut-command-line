# cc - Claude Command Line Manager

`cc` 是一个轻量级的命令行工具，用于在**不同的大模型**提供商之间切换配置，并启动 Claude CLI。

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

# 修改配置，添加上对应的 LLM 供应商和模型
# edit ~/.cc/models.config

# 列出可用提供商
cc list

# 使用默认配置启动 Claude
cc

# 使用指定配置启动 Claude
cc kimi:kimi-for-coding
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

# 使用默认配置启动 Claude
cc

# 使用指定 provider:model 启动 Claude
cc kimi:kimi-for-coding
```

### Dry-run 模式

验证配置是否正确，不启动 Claude CLI：

```bash
cc --dry-run kimi:kimi-for-coding
```

### 传递参数给 Claude CLI

使用 `--` 分隔符：

```bash
# 传递参数给 Claude
cc kimi:kimi-for-coding -- --print "hello"

# 不传递参数，启动交互式 Claude
cc kimi:kimi-for-coding
```

## 配置方法

### 配置文件位置

配置文件位于 `~/.cc/models.config`。

### models.config 格式

```json
{
  "providers": {
    "kimi": {
      "base_url": "https://api.moonshot.cn",
      "api_key": "your-kimi-api-key",
      "models": {
        "kimi-for-coding": { "enable": true }
      }
    },
    "glm": {
      "base_url": "https://open.bigmodel.cn/api/paas/v4",
      "api_key": "your-glm-api-key",
      "models": {}
    },
    "minimax": {
      "base_url": "https://api.minimaxi.com/anthropic",
      "api_key": "your-minimax-api-key",
      "models": {
        "MiniMax-M2.5": { "enable": true },
        "MiniMax-M2.5-highspeed": { "enable": true }
      }
    }
  },
  "default": "minimax:MiniMax-M2.5"
}
```

**字段说明：**
- `providers` - 定义 API 提供商，每个 provider 包含：
  - `base_url`: API 端点地址
  - `api_key`: API 密钥
  - `models`: 该 provider 支持的模型，key 是 model ID，value 包含 `enable` 属性
- `default` - 设置默认 provider:model，格式为 `provider:model` 字符串



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
- **MiniMax**: [https://platform.minimaxi.com/](https://platform.minimaxi.com/)

## 添加新提供商

1. 编辑 `~/.cc/models.config`
2. 在 `providers` 中添加新配置：
   ```json
   "myprovider": {
     "base_url": "https://api.myprovider.com/anthropic",
     "api_key": "your-api-key",
     "models": {
       "my-model": { "enable": true }
     }
   }
   ```
3. 使用：
   ```bash
   cc myprovider:my-model
   ```

## 环境变量参考

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `CC_PATH` | 配置目录 | `~/.cc` |


## 常见问题

### Q: 安装后提示 "command not found"

确保 `~/.local/bin` 在 PATH 中：
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```


### Q: 配置文件在哪里？

- 默认配置文件: `~/.cc/models.config`

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
├── models.config.example     # 配置文件示例
├── install.sh                # 安装脚本
└── README.md                 # 本文档
```

## 工作原理

1. `cc <provider>:<model>` 读取 `~/.cc/models.config` 中的对应配置
2. 使用 `source` 命令设置 `ANTHROPIC_*` 环境变量， `ANTHROPIC_BASE_URL` /`ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_MODEL`
3. 启动 Claude CLI，传入相应的环境变量

## 二次开发

### 项目结构

```
.
├── bin/cc                    # 主命令脚本
├── tests/
│   └── cc_test_cases.sh     # 测试用例
├── models.config.example     # 配置文件示例
├── install.sh                # 安装脚本

```

### 开发环境隔离

本地开发时，可以使用 `CC_PATH` 指定开发配置目录，不影响生产配置：

```bash
# 创建开发配置目录
mkdir .cc.dev
cp ~/.cc/models.config .cc.dev/

# 记得要在 .gitignore 中添加，进行 ignore

# 使用本地 cc 脚本 + 本地配置
CC_PATH="$(pwd)/.cc.dev" ./bin/cc kimi:kimi-for-coding
```

### 测试

```bash
# 运行测试用例
chmod +x tests/cc_test_cases.sh
./tests/cc_test_cases.sh

# Dry-run 验证配置
./bin/cc --dry-run kimi:kimi-for-coding
```

### 提交变更

```bash
git add .
git commit -m "feat: 描述变更"
```

### 关键文件

- `bin/cc` - 主脚本


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


