## ADDED Requirements

### Requirement: 安装脚本

cc 工具 SHALL 提供 install.sh 安装脚本，支持一键安装。

#### Scenario: 一行命令安装
- **WHEN** 用户运行 `curl -fsSL <url>/install.sh | sh`
- **THEN** 安装脚本执行以下操作：
  1. 创建配置目录 `~/.cc/configs/`
  2. 复制 cc 命令到 `~/.local/bin/cc`
  3. 复制配置示例文件（如果不存在）

#### Scenario: 重新运行安装
- **WHEN** 用户重新运行安装脚本
- **THEN** 覆盖现有 cc 命令文件，保留用户配置文件

#### Scenario: 配置文件保留
- **WHEN** 安装脚本检测到 `~/.cc/configs/` 中已有配置文件
- **THEN** 不覆盖现有配置文件，仅安装/更新 cc 命令
