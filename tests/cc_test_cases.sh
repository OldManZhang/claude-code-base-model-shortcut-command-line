#!/bin/bash
# cc 工具测试用例
# 使用方式: ./cc_test_cases.sh

CC="./bin/cc"
export CC_PATH="$(pwd)/.cc.dev"

echo "=========================================="
echo "cc 工具测试用例"
echo "=========================================="
echo

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

passed=0
failed=0

test_case() {
    local name="$1"
    local command="$2"
    local expect_error="$3"  # "yes" or "no"

    echo "-------------------------------------------"
    echo -e "${YELLOW}测试: $name${NC}"
    echo "命令: $command"
    echo

    output=$($command 2>&1)
    exit_code=$?

    if [ "$expect_error" = "yes" ]; then
        if [ $exit_code -ne 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} (预期错误，实际错误)"
            ((passed++))
        else
            echo -e "${RED}✗ FAIL${NC} (预期错误，实际成功)"
            echo "输出: $output"
            ((failed++))
        fi
    else
        if [ $exit_code -eq 0 ]; then
            echo -e "${GREEN}✓ PASS${NC} (预期成功，实际成功)"
            ((passed++))
        else
            echo -e "${RED}✗ FAIL${NC} (预期成功，实际错误)"
            echo "输出: $output"
            ((failed++))
        fi
    fi
    echo
}

# ==========================================
# 正常场景 (使用 --dry-run)
# ==========================================

echo "========== 正常场景 (--dry-run) =========="

test_case "使用默认配置 (--dry-run)" \
    "$CC --dry-run" \
    "no"

test_case "指定有效的 provider:model (--dry-run)" \
    "$CC --dry-run kimi:kimi-for-coding" \
    "no"

test_case "指定 minimax:model (--dry-run)" \
    "$CC --dry-run minimax:MiniMax-M2.7-highspeed" \
    "no"

test_case "列出所有配置" \
    "$CC list" \
    "no"

# ==========================================
# 错误场景 - 格式错误
# ==========================================

echo "========== 错误场景 - 格式错误 =========="

test_case "只提供 provider (无 model) - 应报错" \
    "$CC --dry-run kimi" \
    "yes"

test_case "provider 不带冒号 - 应报错" \
    "$CC --dry-run kimi-model" \
    "yes"

test_case "空 provider - 应报错" \
    "$CC --dry-run :model" \
    "yes"

test_case "空 model - 应报错" \
    "$CC --dry-run provider:" \
    "yes"

# ==========================================
# 错误场景 - provider 不存在
# ==========================================

echo "========== 错误场景 - Provider 不存在 =========="

test_case "不存在的 provider - 应报错" \
    "$CC --dry-run unknown:kimi-for-coding" \
    "yes"

# ==========================================
# 错误场景 - model 不存在
# ==========================================

echo "========== 错误场景 - Model 不存在 =========="

test_case "provider 存在但 model 不存在 - 应报错" \
    "$CC --dry-run kimi:kimi-for-coding1" \
    "yes"

test_case "provider 存在但 model 不存在 - minimax - 应报错" \
    "$CC --dry-run minimax:unknown-model" \
    "yes"

test_case "provider 存在但 model 为空 - 应报错" \
    "$CC --dry-run kimi:" \
    "yes"

# ==========================================
# 帮助命令
# ==========================================

echo "========== 帮助命令 =========="

test_case "查看帮助" \
    "$CC help" \
    "no"

test_case "查看帮助 (短选项)" \
    "$CC -h" \
    "no"

# ==========================================
# 测试结果汇总
# ==========================================

echo "=========================================="
echo "测试结果汇总"
echo "=========================================="
echo -e "${GREEN}通过: $passed${NC}"
echo -e "${RED}失败: $failed${NC}"
echo

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}所有测试通过!${NC}"
    exit 0
else
    echo -e "${RED}有测试失败!${NC}"
    exit 1
fi
