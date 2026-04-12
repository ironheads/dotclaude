# dotclaude

Claude Code 便携配置，跨机器同步使用。

## 快速开始

```bash
git clone git@github.com:ironheads/dotclaude.git ~/.claude-config
cp ~/.claude-config/.env.example ~/.claude-config/.env
```

编辑 `~/.claude-config/.env`，填入：

```
ANTHROPIC_AUTH_TOKEN=your_token_here
ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic
```

然后运行安装脚本：

```bash
bash ~/.claude-config/install.sh
```

## 包含内容

| 内容 | 说明 |
|------|------|
| `settings.json.template` | 主配置模板（token 从 .env 注入） |
| `rules/` | 全局规则 |
| `skills-*` | 自定义 skills（context7-mcp, prd, progress, ralph） |
| `install.sh` | 一键部署脚本 |

## 已启用的插件

Claude Code 启动时自动从官方 marketplace 安装：

- frontend-design
- superpowers
- context7
- code-review
- code-simplifier
- github
- feature-dev
- playwright
- commit-commands
- serena
- pr-review-toolkit

## 注意事项

- `.env` 文件包含敏感信息，已被 `.gitignore` 忽略，不会提交到仓库
- `permissions.allow` 列表为空，新机器上的权限会在使用时自动积累
- 安装后需要重启 Claude Code 才能生效
