## Context

当前 cc 工具需要手动复制到 PATH，缺乏统一的安装方式。

## Goals / Non-Goals

- Goals:
  - 一键安装脚本
  - 支持自动更新
  - 保留用户配置

- Non-Goals:
  - 不提供卸载功能（手动删除即可）

## 安装脚本设计

```bash
#!/bin/bash
# install.sh - cc 安装脚本

set -e

# 配置
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.cc"
CONFIG_SUBDIR="${CONFIG_DIR}/configs"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing cc..."

# 1. 创建目录
mkdir -p "$CONFIG_SUBDIR"

# 2. 复制 cc 命令
echo "Installing cc to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp bin/cc "$INSTALL_DIR/cc"
chmod +x "$INSTALL_DIR/cc"

# 3. 复制配置示例（如果配置文件不存在）
if [ ! -f "$CONFIG_SUBDIR/env.kimi" ]; then
    echo "Installing example configs..."
    cp configs/env.* "$CONFIG_SUBDIR/"
fi

# 4. 提示配置 PATH
echo ""
echo "${GREEN}Installation complete!${NC}"
echo ""
echo "Please add the following to your shell config (.bashrc or .zshrc):"
echo "  export PATH=\"\${HOME}/.local/bin:\$PATH\""
echo ""
echo "Then run: source ~/.bashrc  # or ~/.zshrc"
echo ""
echo "Edit your API keys in: $CONFIG_SUBDIR/env.*"
echo "Run 'cc list' to get started!"
```

## 使用方式

### 安装
```bash
curl -fsSL <url>/install.sh | sh
```

### 更新
```bash
# 重新运行安装脚本即可更新
curl -fsSL <url>/install.sh | sh
```

## URL 占位符

实际使用时，`<url>` 替换为实际托管地址（如 GitHub raw URL）。
