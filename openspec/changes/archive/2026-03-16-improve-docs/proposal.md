# Change: 优化 README 和 CHANGELOG 文档

## Why

- 当前 README 缺少新功能（如 models.config）的使用说明
- 缺少快速入门指南，新用户难以快速上手
- CHANGELOG 格式不统一，难以追踪版本历史
- 没有展示环境变量直接使用的说明

## What Changes

### README.md 重构
- 添加"快速开始"章节，提供一键安装命令
- 添加 models.config 配置格式的详细说明
- 添加环境变量直接使用说明
- 添加常见问题解答 (FAQ)
- 统一文档格式和目录结构

### CHANGELOG.md 规范化
- 遵循语义化版本控制 (Semantic Versioning)
- 标准化每个版本的格式：日期、功能、修复
- 添加版本号规划

**BREAKING**: 无

## Impact

- Affected specs: documentation
- Affected code: README.md, CHANGELOG.md
