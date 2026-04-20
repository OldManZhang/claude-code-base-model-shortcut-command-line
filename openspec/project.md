# Project Context

## Purpose

Claude Command Line Manager (`cc`) - 一个轻量级 shell 脚本工具，允许在不同的 LLM provider 之间切换使用 Claude CLI。该工具管理各种 provider 的环境变量，并自动使用选定的配置启动 Claude CLI。

## Tech Stack

- **语言:** 纯 Bash shell 脚本
- **依赖:** 无外部依赖，仅使用标准 Unix 工具
- **配置文件:** Shell export 语句

## Project Structure

```
.
├── bin/cc              # 主命令行接口 (236行)
├── configs/           # LLM provider 配置文件
│   ├── env.kimi       # Kimi (Moonshot)
│   ├── env.glm       # GLM (Zhipu AI)
│   ├── env.openai    # OpenAI
│   ├── env.anthropic # Anthropic
│   └── env.minimax   # MiniMax
├── install.sh         # 安装脚本
├── README.md          # 使用指南
├── QUICKSTART.md      # 快速入门
└── CLAUDE.md          # Claude Code 开发指南
```

## Project Conventions

### Code Style

- 遵循 POSIX shell 兼容规范
- 使用 `set -e` 错误处理
- 函数命名使用下划线分隔 (snake_case)
- 常量大写

### Architecture Patterns

- **配置驱动:** 每个 provider 在单独的 `env.*` 文件中定义
- **环境变量委托:** Provider 导出统一的 `ANTHROPIC_*` 变量供 Claude CLI 使用
- **Shell sourcing:** 使用 `source` 命令加载环境变量到当前 shell 会话

### Testing Strategy

- 直接运行脚本测试: `./bin/cc <command>`
- 无需构建过程

### Git Workflow

- 单一分支 main
- 不提交敏感文件 (.env, API keys)

## Domain Context

- CLI 工具开发
- 多 LLM provider 集成
- 环境配置管理

## Important Constraints

- 无外部依赖
- 环境变量仅在当前 shell 会话中持久化
- 需要单独安装 Claude CLI

## External Dependencies

- Claude CLI (`claude` 命令)
- 标准 Unix 工具 (bash, source, export)
