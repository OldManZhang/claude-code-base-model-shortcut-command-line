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
# （脚本会自动把 export PATH="$HOME/.local/bin:$PATH" 写入 ~/.zshrc，已存在则跳过）
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

安装脚本会自动把 `export PATH="$HOME/.local/bin:$PATH"` 追加到 `~/.zshrc`（或 `~/.bashrc`，
已存在则跳过；若未识别到你的 shell，会提示手动添加这一行）。安装完成后，运行以下命令使其生效：

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
  "config_version": "0.2.5",
  "providers": {
    "kimi": {
      "base_url": "https://api.moonshot.cn",
      "anthropic_auth_token": "your-kimi-api-key",
      "models": {
        "kimi-for-coding": { "enable": true }
      }
    },
    "glm": {
      "base_url": "https://open.bigmodel.cn/api/paas/v4",
      "anthropic_auth_token": "your-glm-api-key",
      "models": {}
    },
    "opencode": {
      "base_url": "https://opencode.ai/zen/go",
      "anthropic_api_key": "your-opencode-go-api-key",
      "models": {
        "deepseek-v4.1-flash": { "enable": true, "model_name": "deepseek-v4.1-flash[1m]" }
      }
    },
    "minimax": {
      "base_url": "https://api.minimaxi.com/anthropic",
      "anthropic_auth_token": "your-minimax-api-key",
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
- `config_version` - 配置 schema 版本（由生成它的 cc 版本号标记）；旧配置没有此字段，`cc` 启动时会自动升级（见下文「旧配置自动迁移」）
- `providers` - 定义 API 提供商，每个 provider 包含：
  - `base_url`: API 端点地址
  - `anthropic_auth_token` / `anthropic_api_key`: API 密钥，**二选一、互斥**，字段名即导出的环境变量名（见下文「认证方式」）
  - `extra_env` (可选): 该 provider 下所有模型共享的额外环境变量（见下文）
  - `models`: 该 provider 支持的模型，key 是 model ID，value 包含 `enable` 属性，可选 `extra_env`
- `default` - 设置默认 provider:model，格式为 `provider:model` 字符串

### 额外环境变量 (extra_env)

如果某个 provider 或 model 需要设置 `ANTHROPIC_BASE_URL` / `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_MODEL` 之外的额外环境变量（例如 MiniMax-M3 需要的 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=512000`），可以在 `extra_env` 子对象中声明：

- **provider 级** (`providers[name].extra_env`)：对该 provider 下所有 model 生效
- **model 级** (`providers[name].models[name].extra_env`)：只对该 model 生效，**同名 key 覆盖 provider 级**

```json
"minimax": {
  "base_url": "https://api.minimaxi.com/anthropic",
  "api_key": "your-minimax-api-key",
  "extra_env": {
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "MiniMax-M2.5",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "MiniMax-M2.5",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "MiniMax-M2.5"
  },
  "models": {
    "MiniMax-M2.5":           { "enable": true },
    "MiniMax-M2.5-highspeed": { "enable": true },
    "MiniMax-M3": {
      "enable": true,
      "extra_env": {
        "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "512000"
      }
    }
  }
}
```

`cc minimax:MiniMax-M3` 启动 claude 时会自动注入上述所有 `extra_env` 键作为环境变量。

### 认证方式 (anthropic_auth_token / anthropic_api_key)

不同工具读取的认证环境变量不同，`cc` 用**字段名**区分，写哪个字段就导出哪个变量：

| 配置字段 | 导出的环境变量 | 适用 |
|---|---|---|
| `anthropic_auth_token` | `ANTHROPIC_AUTH_TOKEN`（Bearer） | claude + 大多数 Anthropic 兼容网关（默认方式） |
| `anthropic_api_key` | `ANTHROPIC_API_KEY`（x-api-key） | opencode 等读取 API key 的工具，如 opencode Go 套餐 |

- **互斥**：同一个 provider 两个字段都写会报错；都不写也报错（缺密钥）
- **先清后设**：claude 只要环境里存在 `ANTHROPIC_AUTH_TOKEN` 就优先走 token —— 因此
  `anthropic_api_key` 模式会先 `unset ANTHROPIC_AUTH_TOKEN` 再导出 key（token 模式对称清理残留的
  `ANTHROPIC_API_KEY`），保证子进程里只有配置声明的那一个生效
- **选择建议**：普通 Anthropic 兼容网关用 `anthropic_auth_token`；opencode / 只认 API key 的服务用
  `anthropic_api_key`；不确定时看工具文档读哪个变量
- `extra_env` 在认证变量之后导出，仍可覆盖任何 `ANTHROPIC_*`

### 旧配置自动迁移

旧版配置的密钥字段叫 `api_key`（当时固定导出 token）。`cc` 启动时检测到配置缺少 `config_version`
会自动升级，全程无需手工操作：

1. 备份原文件为 `models.config.bak`（已存在则追加时间戳，绝不覆盖）
2. 各 provider 的 `api_key` 改名为 `anthropic_auth_token`（导出行为不变）
3. 写入 `config_version`（执行升级的 cc 版本号），打印一行升级提示

迁移后行为与升级前完全一致；要切换某个 provider 到 API key 认证，手动把字段名改成
`anthropic_api_key` 即可。

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
     "extra_env": {},
     "models": {
       "my-model": { "enable": true }
     }
   }
   ```
3. 使用：
   ```bash
   cc myprovider:my-model
   ```

如果新模型需要额外环境变量，给该 model 加 `extra_env` 子对象（见上文）。

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

1. `cc <provider>:<model>` 读取 `~/.cc/models.config` 中的对应配置（旧格式先自动迁移）
2. 按认证字段导出 `ANTHROPIC_*` 环境变量：`ANTHROPIC_BASE_URL`、`ANTHROPIC_MODEL`，以及
   `ANTHROPIC_AUTH_TOKEN`（`anthropic_auth_token` 字段）或 `ANTHROPIC_API_KEY`（`anthropic_api_key` 字段），
   导出前先清掉另一个认证变量
3. 合并导出 `extra_env`，启动 Claude CLI，传入相应的环境变量

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


