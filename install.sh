#!/bin/bash

# cc install script
# Usage: curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh

set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.cc"
REPO_URL="https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Helper functions (using printf for sh compatibility)
step() {
    printf "\n${BOLD}${BLUE}▶ $1${NC}\n\n"
}

doing() {
    printf "  ${YELLOW}○${NC} $1...\n"
}

done_msg() {
    printf "  ${GREEN}✓${NC} $1\n"
}

info() {
    printf "  ${BLUE}→${NC} $1\n"
}

warn() {
    printf "  ${YELLOW}!${NC} $1\n"
}

error() {
    printf "  ${RED}✗${NC} $1\n"
}

# Banner
printf "\n${BOLD}╔═══════════════════════════════════════════╗${NC}\n"
printf "${BOLD}║        cc - Claude CLI Provider Manager   ║${NC}\n"
printf "${BOLD}╚═══════════════════════════════════════════╝${NC}\n"

# Step 1: Prepare source files
step "步骤 1/4: 准备安装文件"

# Detect if running via pipe (curl | sh)
if [ -t 0 ]; then
    # Running directly (not piped), use script's directory
    CC_REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
    doing "检测安装方式"
    done_msg "本地安装 (从 $CC_REPO_DIR)"
else
    # Running via pipe, download files to temp directory
    doing "检测安装方式"
    done_msg "远程安装 (从 GitHub 下载)"

    TEMP_DIR=$(mktemp -d)
    trap "rm -rf '$TEMP_DIR'" EXIT

    mkdir -p "$TEMP_DIR/bin"
    mkdir -p "$TEMP_DIR/configs"

    doing "下载 cc 主程序"
    curl -fsSL "$REPO_URL/bin/cc" -o "$TEMP_DIR/bin/cc"
    chmod +x "$TEMP_DIR/bin/cc"
    done_msg "cc 主程序下载完成"

    doing "下载配置文件模板"
    curl -fsSL "$REPO_URL/models.config.example" -o "$TEMP_DIR/models.config.example" 2>/dev/null || true
    done_msg "已下载 models.config.example"

    CC_REPO_DIR="$TEMP_DIR"
fi

# Step 2: Install cc command
step "步骤 2/4: 安装 cc 命令"

doing "创建安装目录"
mkdir -p "$INSTALL_DIR"
done_msg "安装目录: $INSTALL_DIR"

doing "安装 cc 可执行文件"
if [ -f "$INSTALL_DIR/cc" ]; then
    warn "已存在旧版本，将被覆盖"
fi
cp "$CC_REPO_DIR/bin/cc" "$INSTALL_DIR/cc"
chmod +x "$INSTALL_DIR/cc"
done_msg "已安装到: $INSTALL_DIR/cc"

# Step 3: Setup configuration
step "步骤 3/4: 配置初始化"

doing "创建配置目录"
mkdir -p "$CONFIG_DIR"
done_msg "配置目录: $CONFIG_DIR"

# Check if models.config needs to be copied
MODELS_CONFIG="${HOME}/.cc/models.config"
if [ ! -f "$MODELS_CONFIG" ]; then
    doing "复制配置模板"
    if [ -f "$CC_REPO_DIR/models.config.example" ]; then
        cp "$CC_REPO_DIR/models.config.example" "$MODELS_CONFIG"
        done_msg "已复制 models.config.example 到 $MODELS_CONFIG"
    fi
else
    info "配置文件已存在，跳过复制"
fi

# Step 4: Configure PATH
step "步骤 4/4: 配置环境变量"

SHELL_RC=""
SHELL_NAME=""
# macOS 默认使用 zsh，其他系统检测 shell 类型
if [ "$(uname)" = "Darwin" ] || [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

PATH_CONFIGURED=false
if [ -n "$SHELL_RC" ]; then
    doing "检查 PATH 配置"
    if grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
        done_msg "PATH 已配置 (在 $SHELL_RC)"
        PATH_CONFIGURED=true
    else
        doing "添加 ~/.local/bin 到 PATH"
        printf "\n" >> "$SHELL_RC"
        printf "# cc - Claude CLI Provider Manager\n" >> "$SHELL_RC"
        printf 'export PATH="$HOME/.local/bin:$PATH"\n' >> "$SHELL_RC"
        done_msg "已添加到 $SHELL_RC"
    fi
else
    warn "无法检测 shell 配置文件，请手动添加 PATH"
fi

# Summary
printf "\n${BOLD}══════════════════════════════════════════════${NC}\n"
printf "${GREEN}${BOLD}  安装完成!${NC}\n"
printf "${BOLD}══════════════════════════════════════════════${NC}\n"

printf "\n${BOLD}已安装:${NC}\n"
printf "  • cc 命令: ${GREEN}$INSTALL_DIR/cc${NC}\n"
printf "  • 配置目录: ${GREEN}$CONFIG_DIR${NC}\n"
if [ -f "$MODELS_CONFIG" ]; then
    printf "  • 配置文件: ${GREEN}$MODELS_CONFIG${NC}\n"
fi

printf "\n${BOLD}后续步骤:${NC}\n"
if [ "$PATH_CONFIGURED" = true ]; then
    printf "  ${YELLOW}1.${NC} PATH 已配置，运行以下命令使其生效:\n"
    printf "     ${BLUE}source %s${NC}\n" "$SHELL_RC"
else
    printf "  ${YELLOW}1.${NC} 将以下内容添加到你的 shell 配置文件:\n"
    printf "     ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
fi
printf "  ${YELLOW}2.${NC} 编辑配置文件添加你的 API Key:\n"
printf "     ${BLUE}vim ~/.cc/models.config${NC}\n"
printf "  ${YELLOW}3.${NC} 运行以下命令开始使用:\n"
printf "     ${BLUE}cc help${NC}  - 查看帮助\n"
printf "     ${BLUE}cc list${NC}  - 列出所有提供商\n"
printf "     ${BLUE}cc --dry-run kimi:kimi-for-coding${NC}  - 验证配置\n"

printf "\n"