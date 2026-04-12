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
CONTEXT7_API_KEY=your_context7_key_here
```

然后运行安装脚本：

```bash
bash ~/.claude-config/install.sh
```

## 包含内容

| 内容 | 说明 |
|------|------|
| `claude.json.template` | 全局配置（跳过 onboarding、MCP 服务器） |
| `settings.json.template` | 主配置模板（token 从 .env 注入） |
| `rules/` | 全局规则 |
| `skills-*` | 自定义 skills（context7-mcp, prd, progress, ralph） |
| `install.sh` | 一键部署脚本 |

## MCP 服务器

自动配置以下 MCP 服务器（密钥从 .env 注入）：

- zai-mcp-server — 图像/视频分析
- web-search-prime — Web 搜索
- zread — GitHub 仓库读取
- web-reader — 网页内容抓取
- context7 — 库文档查询

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
