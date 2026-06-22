# Release Workflow

这份文档说明如何把改动发布成新版本给用户。日常开发流程见 [DEVELOPMENT.md](DEVELOPMENT.md)。

## 发布渠道

`install.sh` 始终从 `main` 分支拉取：

```bash
REPO_URL="https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main"
```

所以「发版」本质上是：把改动 merge 到 `main` 然后 push。下一次有人跑 `curl | sh` 就会拿到新版。git tag 仅作版本标记，不会触发自动部署。

## 何时发版

不必每次 merge 都发版。常见触发：

- 累积了若干用户可见改动
- 修了影响多人的 bug
- 改了用户配置格式（如 `models.config` schema）
- Breaking change

## 一键发版：`scripts/release.sh`

### 用法

```bash
./scripts/release.sh <new-version>
```

例子：

```bash
./scripts/release.sh 0.2.4
```

### 校验项

脚本会拒绝以下情况：

- `<new-version>` 不是 `X.Y.Z` 格式
- 当前不在 `main` 分支
- working tree 不干净（`VERSION` / `CHANGELOG.md` 之外有未提交改动）
- 新版本 ≤ 当前 `VERSION` 内容
- tag `v<new-version>` 已存在

### 步骤

1. 确认 `[Unreleased]` 段已更新（用户可见改动都在里面）
2. 在 `main` 分支、clean tree 下运行 `./scripts/release.sh X.Y.Z`
3. 脚本自动：
   - 把 `[Unreleased]` 内容移到 `## [vX.Y.Z] - <today>` 段
   - 重置 `[Unreleased]` 为空模板
   - 写 `VERSION`
   - commit `VERSION` + `CHANGELOG.md`
   - 打 annotated tag `vX.Y.Z`
4. 检查输出，确认 commit 和 tag 已建
5. **手动** push：

   ```bash
   git push origin main --tags
   ```

6. 在 GitHub 上确认 release（可选）：去 Releases 页 → Draft a new release → 选刚 push 的 tag

### 发版后用户怎么拿到

发版完成后，**已安装的用户需要重跑安装脚本**才能拿到新版：

```bash
curl -fsSL https://raw.githubusercontent.com/OldManZhang/claude-code-base-model-shortcut-command-line/main/install.sh | sh
```

`install.sh` 直接覆盖 `~/.local/bin/cc` 和 `VERSION`。用户已有的 `~/.cc/models.config` 不会被覆盖。

## 手动 fallback

如果 `release.sh` 坏了，按以下步骤手动发版（**仅在脚本真的不能跑时**）：

```bash
# 1. 编辑 VERSION
$EDITOR VERSION            # 改成新版本号

# 2. 编辑 CHANGELOG.md
#    把 ## [Unreleased] 段内容搬到 ## [vX.Y.Z] - YYYY-MM-DD
#    重置 [Unreleased] 为空

# 3. 提交
git add VERSION CHANGELOG.md
git commit -m "release: vX.Y.Z"

# 4. 打 tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# 5. push
git push origin main --tags
```

完成后请修好 `release.sh`，并提交一个 `fix(release): ...` 修复。

## 回滚

如果发版后发现严重问题：

### 方案 A：发新版修复（推荐）

发个 patch 版本（X.Y.Z+1），在 commit 里 revert 问题 commit。`install.sh` 用户下次重装就拿到修好的版本。

### 方案 B：彻底撤回

```bash
# 1. 删除远程 tag
git push origin :refs/tags/vX.Y.Z

# 2. revert merge commit（或 release commit）
git revert <commit-sha>
git push origin main
```

注意：`install.sh` 用户已经装过 vX.Y.Z 不会被自动回滚 —— 他们需要重装。

### 方案 C：rebase 改写历史（危险）

如果这个 tag 还没人装过，可以 `git tag -d vX.Y.Z` + `git reset --hard HEAD~1` + `git push --force origin main`。

**仅在 vX.Y.Z 装的人极少（< 5 人）且你能联系上时考虑。** 否则用方案 A。

## 与 CI 的关系

CI（`.github/workflows/test.yml`）跑测试套件 + 校验 JSON / bash 语法。**发版必须先在 PR 里通过 CI**。直接 push 到 main 也会跑 CI，但推荐走 PR 流程以便 review。

CI 不做的事：
- 自动 publish release（依赖 push tag 后手动操作）
- shellcheck / shfmt lint（项目小，收益低）
- 多平台 matrix（ubuntu 足够覆盖 POSIX shell 行为）

## 版本号规则

[Semantic Versioning](https://semver.org/)：

- `MAJOR.MINOR.PATCH` （如 `0.2.4`）
- 项目还在 `0.x`，API 仍可能不稳 —— MINOR bump 可以包含 breaking change
- 发版前 README / CLAUDE.md 里如果有版本相关的描述也要更新（但当前没有）
