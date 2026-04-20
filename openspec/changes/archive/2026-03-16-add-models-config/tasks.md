## 1. 配置文件设计

- [x] 1.1 设计 `~/.cc/models.config` 纯 Shell 格式结构
- [x] 1.2 创建示例配置文件 configs/models.config.example

## 2. 配置加载逻辑

- [x] 2.1 实现纯 Shell 配置解析函数（sed/awk）
- [x] 2.2 实现 providers 和 models 的加载逻辑
- [x] 2.3 实现 model 到 provider 的自动匹配

## 3. 命令行解析

- [x] 3.1 支持 `cc <provider>:<model>` 语法
- [x] 3.2 支持 `cc <provider>:<alias>` 语法
- [x] 3.3 兼容旧语法 `cc <provider>` 和 `cc <alias>`

## 4. 向后兼容

- [x] 4.1 保留 `~/.cc/configs/env.*` 文件的读取支持
- [x] 4.2 优先读取新的 models.config
- [ ] 4.3 提供配置迁移脚本

## 5. 测试

- [ ] 5.1 测试新语法加载配置
- [ ] 5.2 测试向后兼容
- [ ] 5.3 测试默认 provider/model
