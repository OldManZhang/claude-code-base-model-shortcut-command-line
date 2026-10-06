#!/bin/bash
# cc 工具测试用例
# 使用方式: ./cc_test_cases.sh

CC="./bin/cc"
CC_PATH="$(pwd)/.cc.dev"

# Bootstrap CC_PATH from models.config.example if it doesn't exist.
# Lets the suite run in CI where .cc.dev/ is gitignored and absent.
if [ ! -f "$CC_PATH/models.config" ]; then
    mkdir -p "$CC_PATH"
    cp models.config.example "$CC_PATH/models.config"
fi

export CC_PATH

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
    local expect_error="$3"         # "yes" or "no"
    local expect_contains="${4:-}"   # optional: substring that must appear in output
    local expect_not_contains="${5:-}" # optional: substring that must NOT appear in output

    echo "-------------------------------------------"
    echo -e "${YELLOW}测试: $name${NC}"
    echo "命令: $command"
    echo

    output=$($command 2>&1)
    exit_code=$?

    # Determine failure reason; empty means exit code matched expectation
    local reason=""
    if [ "$expect_error" = "yes" ]; then
        if [ $exit_code -eq 0 ]; then
            reason="(预期错误，实际成功)"
        fi
    else
        if [ $exit_code -ne 0 ]; then
            reason="(预期成功，实际错误)"
        fi
    fi

    # Output substring assertions (only checked when exit code matched)
    if [ -z "$reason" ] && [ -n "$expect_contains" ]; then
        if ! grep -qF "$expect_contains" <<< "$output"; then
            reason="(输出缺少期望内容: $expect_contains)"
        fi
    fi
    if [ -z "$reason" ] && [ -n "$expect_not_contains" ]; then
        if grep -qF "$expect_not_contains" <<< "$output"; then
            reason="(输出包含不应存在的内容: $expect_not_contains)"
        fi
    fi

    if [ -z "$reason" ]; then
        if [ "$expect_error" = "yes" ]; then
            echo -e "${GREEN}✓ PASS${NC} (预期错误，实际错误)"
        else
            echo -e "${GREEN}✓ PASS${NC} (预期成功，实际成功)"
        fi
        ((passed++))
    else
        echo -e "${RED}✗ FAIL${NC} $reason"
        echo "输出: $output"
        ((failed++))
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
    "$CC --dry-run minimax:MiniMax-M3" \
    "no"

test_case "列出所有配置" \
    "$CC list" \
    "no"

# ==========================================
# model_name 字段测试 (使用 --dry-run)
# ==========================================

echo "========== model_name 字段测试 (--dry-run) =========="

test_case "带 model_name 的模型导出正确的 ANTHROPIC_MODEL 值" \
    "$CC --dry-run minimax:MiniMax-M3-model-name-test 2>&1 | grep -qF 'ANTHROPIC_MODEL=MiniMax-M3[1m]'" \
    "no"

test_case "带 model_name 的模型显示映射提示" \
    "$CC --dry-run minimax:MiniMax-M3-model-name-test 2>&1 | grep -q 'model_key.*model_name'" \
    "no"

test_case "无 model_name 的模型使用 key 作为模型名" \
    "$CC --dry-run kimi:kimi-for-coding 2>&1 | grep -qF 'ANTHROPIC_MODEL=kimi-for-coding'" \
    "no"

# ==========================================
# 认证字段测试 (anthropic_auth_token / anthropic_api_key)
# ==========================================

echo "========== 认证字段测试 (--dry-run) =========="

test_case "token 认证 dry-run 导出 ANTHROPIC_AUTH_TOKEN" \
    "$CC --dry-run kimi:kimi-for-coding" \
    "no" "ANTHROPIC_AUTH_TOKEN=****" "ANTHROPIC_API_KEY="

test_case "token 认证 dry-run 显示 auth 标识" \
    "$CC --dry-run kimi:kimi-for-coding" \
    "no" "(auth: token)"

test_case "api_key 认证 dry-run 导出 ANTHROPIC_API_KEY" \
    "$CC --dry-run opencode:deepseek-v4.1-flash" \
    "no" "ANTHROPIC_API_KEY=****" "ANTHROPIC_AUTH_TOKEN="

test_case "api_key 认证 dry-run 显示 auth 标识" \
    "$CC --dry-run opencode:deepseek-v4.1-flash" \
    "no" "(auth: api_key)"

test_case "两认证字段互斥 - 应报错" \
    "env CC_PATH=$(pwd)/tests/fixtures/both-fields $CC --dry-run both:m" \
    "yes"

test_case "缺少认证字段 - 应报错" \
    "env CC_PATH=$(pwd)/tests/fixtures/no-credential $CC --dry-run empty:m" \
    "yes"

# ==========================================
# 配置自动迁移 (legacy api_key -> anthropic_auth_token)
# ==========================================

echo "========== 配置自动迁移 =========="

migration_dir=$(mktemp -d)
cp tests/fixtures/legacy-config/models.config "$migration_dir/"
migration_out=$(env CC_PATH="$migration_dir" "$CC" list 2>&1)
migration_exit=$?
if [ $migration_exit -eq 0 ] \
    && [ -f "$migration_dir/models.config.bak" ] \
    && jq -e '.config_version
              and (.providers.kimi | has("anthropic_auth_token"))
              and ((.providers.kimi | has("api_key")) | not)' \
           "$migration_dir/models.config" >/dev/null 2>&1 \
    && printf '%s' "$migration_out" | grep -q "auto-upgraded"; then
    echo -e "${GREEN}✓ PASS${NC} 测试: 旧配置自动迁移 (备份/改名/写版本/提示)"
    ((passed++))
else
    echo -e "${RED}✗ FAIL${NC} 测试: 旧配置自动迁移"
    echo "exit=$migration_exit"
    echo "输出: $migration_out"
    ((failed++))
fi

# 幂等：再次运行不应产生新的备份文件
migration_out2=$(env CC_PATH="$migration_dir" "$CC" list 2>&1)
migration_exit2=$?
bak_count=$(ls "$migration_dir" | grep -c "models.config.bak")
if [ $migration_exit2 -eq 0 ] && [ "$bak_count" -eq 1 ]; then
    echo -e "${GREEN}✓ PASS${NC} 测试: 迁移幂等 (重复运行不重复备份)"
    ((passed++))
else
    echo -e "${RED}✗ FAIL${NC} 测试: 迁移幂等 (重复运行不重复备份)"
    echo "exit=$migration_exit2 bak_count=$bak_count"
    ((failed++))
fi
rm -rf "$migration_dir"

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
# 分隔符测试
# ==========================================

echo "========== 分隔符测试 =========="

test_case "带分隔符 + claude args (--dry-run)" \
    "$CC --dry-run kimi:kimi-for-coding -- --print" \
    "no"

test_case "无分隔符，只有 provider:model" \
    "$CC --dry-run kimi:kimi-for-coding" \
    "no"

test_case "分隔符但无 claude args" \
    "$CC --dry-run kimi:kimi-for-coding --" \
    "no"

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

echo "========== 版本命令 =========="

test_case "查看版本 (--version)" \
    "$CC --version" \
    "no"

test_case "查看版本 (version)" \
    "$CC version" \
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
