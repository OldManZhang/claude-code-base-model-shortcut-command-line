# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- 添加 `install.sh` 一键安装脚本，支持 `curl -fsSL <url>/install.sh | sh` 安装

## [v0.1.0] - 2025-01-29

### Added
- 初始版本发布
- 支持多 LLM provider 配置切换 (kimi, glm, openai, anthropic, minimax)
- `cc list` - 列出所有可用 provider
- `cc current` - 显示当前配置
- `cc <provider>` - 切换到指定 provider
- 支持 `CC_DEFAULT_PROVIDER` 环境变量设置默认 provider
- 支持 `CC_PATH` 环境变量自定义配置目录
- 支持传递命令行参数给 claude CLI
