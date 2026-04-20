# Change: 添加一键安装脚本

## Why

当前 cc 工具没有统一的安装脚本，用户需要手动复制文件到 PATH 目录。这导致：
1. 安装步骤繁琐，需要手动操作
2. 没有便捷的更新方式
3. 用户难以快速部署使用

通过提供一个 install.sh 安装脚本，可以一键完成安装和更新。

## What Changes

- 创建 `install.sh` 安装脚本
- 支持一行命令安装：`curl -fsSL <url>/install.sh | sh`
- 重新运行安装脚本即可更新 cc
- 自动处理 PATH 配置

**BREAKING**: 无破坏性变更

## Impact

- Affected specs: installation
- Affected code: `bin/cc`, `install.sh`
