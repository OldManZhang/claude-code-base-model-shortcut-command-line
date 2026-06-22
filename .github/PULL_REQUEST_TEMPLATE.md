## 改动类型

- [ ] feat: 新功能
- [ ] fix: 修复
- [ ] refactor: 重构（不改行为）
- [ ] docs: 仅文档
- [ ] chore: 杂项 / 工具

## 说明

<!-- 1–3 句话描述这次改动做什么，以及为什么 -->

## 关联

- 关联 issue / 讨论：#
- 关联 OpenSpec 变更：`openspec/changes/<name>/`（如有）

## 检查清单

- [ ] CHANGELOG.md 的 `[Unreleased]` 段已更新（Added / Changed / Fixed 分类）
- [ ] 本地已运行：`bash -n bin/cc && ./tests/cc_test_cases.sh`
- [ ] 本地已用 `--dry-run` 验证新配置（如改动 models.config）
- [ ] 已同步更新 `openspec/specs/` 相关 spec（如架构 / 接口有变）
- [ ] API key 等敏感信息未出现在 diff 中
