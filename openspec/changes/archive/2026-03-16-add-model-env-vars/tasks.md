## 1. Implementation

- [x] 1.1 修改 `bin/cc` 中的 `load_config` 函数，添加对模型额外环境变量的处理
- [x] 1.2 添加 `get_model_extra_env_vars` 函数，用于获取模型配置中除 `provider` 和 `id` 之外的所有字段
- [x] 1.3 在加载模型配置后，遍历并导出这些额外环境变量
- [x] 1.4 更新 `load_from_models_config` 函数以支持额外环境变量

## 2. Testing

- [x] 2.1 手动测试：使用包含额外环境变量的模型配置启动 cc
- [x] 2.2 验证额外环境变量是否正确导出到 Claude CLI

## 3. Documentation

- [ ] 3.1 更新 README.md 或 CLAUDE.md 说明模型配置支持额外环境变量
