# Tasks

## Task: bin/cc — 旧配置自动迁移

**File**: `bin/cc`

在 `main()` 的 `check_jq` 之后：`models.config` 存在且 `config_version` 字段缺失 →
备份（`.bak`，已存在则带时间戳，不覆盖）→ jq 临时文件改名 `api_key`→`anthropic_auth_token` +
写 `config_version=$(get_version)` → `mv` 原子替换 → 打印升级提示；jq 失败/改名冲突
（已有 `anthropic_auth_token`）→ 报错退出、原文件不动。`env.*` legacy 分支不参与。
检测只看字段存在性，不比对版本大小（幂等）。

**Done 条件**:
- [x] 旧格式 fixture 跑 `cc list` exit 0、生成 `.bak`、迁移后含 `config_version` 与 `anthropic_auth_token`
- [x] 重复运行不重复改名、不产生新备份（幂等）
- [x] 冲突（`api_key` + `anthropic_auth_token` 并存）报错退出且原文件不动

---

## Task: bin/cc — 字段解析 + 互斥校验

**File**: `bin/cc`

新增 `resolve_key_field()`，一次 jq 读出 `anthropic_auth_token` / `anthropic_api_key`，
在 `load_config()` 中替换原 `api_key` 判空逻辑：both → 报错；皆无 → 报错；得密钥值与 `key_field`。
`show_current()` 复用同一解析显示认证字段。

**Done 条件**:
- [x] both fixture 与双无 fixture 均 exit ≠ 0 且报错信息指明字段
- [x] `base_url` 缺失单独报错

---

## Task: bin/cc — unset-then-export 导出

**File**: `bin/cc`

`anthropic_auth_token` → `unset ANTHROPIC_API_KEY` 后 `export ANTHROPIC_AUTH_TOKEN`；
`anthropic_api_key` → 反之。保持在 `extra_env` 唯一 `eval` 之前（顺序 load-bearing）。

**Done 条件**:
- [x] claude stub：api_key 模式下残留 `ANTHROPIC_AUTH_TOKEN` 被清、只收到 `ANTHROPIC_API_KEY`
- [x] claude stub：token 模式下残留 `ANTHROPIC_API_KEY` 被清、只收到 `ANTHROPIC_AUTH_TOKEN`

---

## Task: bin/cc — dry-run / show_current / usage 输出

**File**: `bin/cc`

dry-run 认证行按 `key_field` 条件输出 + 新增 `(auth: <token|api_key>)` 行；
`show_current()` 显示所用字段名 + 掩码；usage/tips 补 `ANTHROPIC_API_KEY` 说明。

**Done 条件**:
- [x] token/api_key 两种 dry-run 输出正确、互斥的变量行不出现
- [x] `cc list` / `cc current` 正常显示

---

## Task: 更新 models.config.example

**File**: `models.config.example`

- 加 `"config_version": "0.2.5"`（当前 VERSION 值）
- 全部现存 provider `api_key` → `anthropic_auth_token`
- 新增 `opencode` provider：`anthropic_api_key` + `deepseek-v4.1-flash`
  （`model_name: "deepseek-v4.1-flash[1m]"`，base_url `https://opencode.ai/zen/go`，
  extra_env 含 `ANTHROPIC_DEFAULT_*` 映射）——真实 opencode Go 用法的模板
- 补回测试引用的 `minimax:MiniMax-M3-model-name-test`

**Done 条件**:
- [x] `jq empty models.config.example` 通过
- [x] 无真实密钥（全部占位符）
- [x] 测试引用的模型齐全

---

## Task: tests helper 扩展

**File**: `tests/cc_test_cases.sh`

`test_case` 加可选第 4 参（成功时 `$output` 必须含的子串）/第 5 参（必须不含的子串），
退出码匹配后才做子串断言；存量用例不动。

**Done 条件**:
- [x] 旧用例仍全绿

---

## Task: 新测试用例 + fixtures

**File**: `tests/cc_test_cases.sh`、`tests/fixtures/`

fixtures：`legacy-config/`（旧格式）、`both-fields/`（互斥）、`no-credential/`（双无）。

用例：token dry-run、api_key dry-run、`(auth:)` 标识、both 报错、双无报错、
迁移（备份/改名/写版本/提示）与幂等（直接脚本断言，fixture 先拷贝到临时目录）。

**Done 条件**:
- [x] `./tests/cc_test_cases.sh` 全绿（30 用例）

---

## Task: OpenSpec change 目录

**File**: `openspec/changes/add-anthropic-key-fields/`

`proposal.md`、`tasks.md`、`specs/configuration/spec.md` delta
（MODIFIED: Config File Format、Provider Schema；ADDED: Config Migration）、
`specs/cli-interface/spec.md` delta（MODIFIED: Dry-run 模式；ADDED: 配置自动迁移提示）。

**Done 条件**:
- [x] 目录结构与归档 change 一致

---

## Task: 同步主 spec

**File**: `openspec/specs/configuration/spec.md`、`openspec/specs/cli-interface/spec.md`

与代码一致：字段、互斥、unset-then-export、迁移、dry-run 输出。

**Done 条件**:
- [x] spec 中无旧 `api_key` 导出语义残留，字段与迁移语义完整
- [x] `openspec validate add-anthropic-key-fields` 通过（ADDED 需求留在 delta、归档时应用到主 spec）

---

## Task: 文档

**File**: `README.md`、`CLAUDE.md`、`CHANGELOG.md`

README 字段说明 + 认证方式小节（unset 原理、选择指南、迁移说明）；
CLAUDE.md merge-rule / `load_config()` / Configuration Flow；CHANGELOG `[Unreleased]` Added + Changed。

**Done 条件**:
- [x] 文档示例与 example 一致
- [x] CHANGELOG 两条（Added 字段、Changed 迁移）

---

## Task: 验证

三层验证 + plan 验证节全部命令（迁移演练、claude stub 双向 unset、dry-run）。

**Done 条件**:
- [x] `bash -n` / `jq empty` / 测试套件全绿（30 用例）
- [x] 手动演练全部符合期望（迁移/幂等/冲突、claude stub 双向 unset、dry-run 双模式）
- [x] 端到端：`cc opencode-go:deepseek-v4.1-flash -- --print` 打通 opencode Go 网关返回 pong
