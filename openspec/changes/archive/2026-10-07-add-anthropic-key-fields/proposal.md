# add-anthropic-key-fields

## Why

`cc` 目前固定将配置中的密钥导出为 `ANTHROPIC_AUTH_TOKEN`（Bearer token）。opencode 等工具读取的是 `ANTHROPIC_API_KEY`，其中 opencode Go 套餐仅支持 API key，导致这类工具无法使用 `cc` 管理的 provider 配置。同时 claude 的认证变量存在优先级：环境中存在 `ANTHROPIC_AUTH_TOKEN` 时，即使设置了 `ANTHROPIC_API_KEY` 也不生效——因此认证方式切换必须是「先 unset 后 export」的确定性动作。

## What Changes

- `models.config` 的 provider 级密钥字段拆分为两种，字段名对齐目标环境变量：
  - `anthropic_auth_token` → 导出 `ANTHROPIC_AUTH_TOKEN`（先 `unset ANTHROPIC_API_KEY`）
  - `anthropic_api_key` → 导出 `ANTHROPIC_API_KEY`（先 `unset ANTHROPIC_AUTH_TOKEN`）
- 互斥校验：同一 provider 两字段同写 → 报错；两字段皆无 → 报错（缺密钥）
- 新增顶层 `config_version` 字段，值为生成该配置的 cc 版本号
- **旧配置自动迁移**：启动时检测到 `models.config` 无 `config_version` →
  自动备份 `.bak` → 各 provider `api_key` 改名 `anthropic_auth_token` →
  写入 `config_version`（当前 cc 版本）→ 打印升级提示；行为无缝（迁移后仍导 token）
- `--dry-run` / `cc current` 输出随认证字段变化，新增 `(auth: token|api_key)` 标识
- 同步更新 `models.config.example`（新格式 + opencode Go 示例）、configuration/cli-interface spec、
  测试与 README/CLAUDE.md/CHANGELOG

**兼容性**：存量配置零手工修改（自动迁移 + 备份）；迁移后所有现存 provider 行为与今天完全一致。
仅显式写 `anthropic_api_key` 字段的 provider 才切换为 API key 认证。

## Capabilities

### New Capabilities

- `anthropic-key-fields`: provider 级 `anthropic_auth_token` / `anthropic_api_key` 互斥字段，
  字段即认证方式，配套「先 unset 后 export」语义
- `config-auto-migration`: 无 `config_version` 的旧配置启动时自动备份并升级

### Modified Capabilities

- `configuration`: Provider Schema 密钥字段与导出规则；新增 `config_version`
- `cli-interface`: dry-run 认证输出行；配置自动迁移提示

## Impact

- **`bin/cc`** — 入口迁移逻辑、字段解析/互斥校验、unset-then-export、dry-run/current/usage 输出
- **`models.config.example`** — `config_version`、`api_key`→`anthropic_auth_token` 改名、
  新增 opencode provider（api_key 认证示例）、补回缺失的 `MiniMax-M3-model-name-test`
- **`tests/cc_test_cases.sh`** — helper 输出断言参数；token/api_key/互斥/缺失/迁移用例；`tests/fixtures/`
- **`openspec/`** — 新 change 目录 + 同步两个主 spec
- **README / CLAUDE.md / CHANGELOG** — 字段文档、迁移说明、认证选择指南
- **配置兼容性** — 旧配置自动升级（备份 `.bak`），无需用户手工操作
