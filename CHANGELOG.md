# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

## [v0.2.3] - 2026-04-20

### Added

- `--dry-run` 模式，验证配置不启动 Claude
- `--` 分隔符，明确区分 cc 参数和 claude 参数

### Changed

- **BREAKING**: 移除 alias 支持，统一使用 `provider:model` 格式
- **BREAKING**: `models` 配置从顶层移入 `providers.<provider>.models`
- **BREAKING**: `default` 格式改为 `provider:model` 字符串
- `cc <provider>` 不再支持，必须使用 `cc <provider>:<model>`

### Fixed

- 修复 model 验证，确保指定的 model 存在于 provider 下

## [v0.2.2] - 2026-03-16

## [v0.2.1] - 2026-03-16

### Added

- `CC_PATH` 环境变量支持，允许自定义配置文件目录

## [v0.2.0] - 2026-03-16

### Added

- 命令行参数透传支持，允许将参数传递给 claude CLI
  - `cc <provider> <args...>` 语法
  - `cc <args...>` 无 provider 参数语法

## [v0.1.0] - 2026-01-29

### Added

- 初始版本发布
- 多 LLM provider 配置切换 (kimi, glm, openai, anthropic, minimax)
- `cc list` - 列出所有可用 provider
- `cc current` - 显示当前配置
- `cc <provider>` - 切换到指定 provider
- `CC_DEFAULT_PROVIDER` 环境变量设置默认 provider

---

## Version Planning

### Planned for v0.3.0

- [ ] 统一配置文件 `~/.cc/models.config` 支持
- [ ] `cc <provider>:<model>` 语法支持
- [ ] 模型别名 (alias) 配置支持
- [ ] 向后兼容旧版 `env.*` 配置文件

### Future Ideas

- [ ] 交互式配置向导
- [ ] 配置验证命令
- [ ] 多配置切换支持

---

## Migration Guides

### Upgrading to v0.2.x

No migration needed. The new version is fully backward compatible with v0.1.0 configurations.

### Upgrading to v0.3.0 (Planned)

The new `models.config` format will take precedence, but old `env.*` files will continue to work.
