## 1. Implementation

- [x] 1.1 修改 `bin/cc` 的 `load_config()` 函数，支持接收并传递额外参数给 claude 命令
- [x] 1.2 修改 `bin/cc` 的 `load_default_config()` 函数，支持接收并传递额外参数
- [x] 1.3 更新 `show_usage()` 帮助文档，说明新语法

## 2. Testing

- [x] 2.1 测试 `cc kimi --version` 正确传递参数
- [x] 2.2 测试 `cc --print` 使用默认 provider 并传递参数
- [x] 2.3 测试多个参数 `cc glm --print --verbose`
- [x] 2.4 测试无参数场景仍然正常工作
