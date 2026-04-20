#!/usr/bin/env bash
#
# Claude Code 一键配置脚本
#
# 远程用法: bash <(curl -fsSL https://raw.githubusercontent.com/ironheads/dotclaude/main/install.sh)
# 本地用法: bash install.sh [--force]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE="${1:-}"
REPO_URL="https://github.com/ironheads/dotclaude.git"
CLONE_DIR="$HOME/.claude-config"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---- 安装 Claude Code CLI ----
if ! command -v claude &>/dev/null; then
    info "安装 Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    info "Claude Code CLI 已安装: $(claude --version 2>/dev/null || echo 'unknown')"
fi

# ---- 如果不是从克隆目录运行，先克隆仓库 ----
if [ ! -f "$SCRIPT_DIR/settings.json.template" ]; then
    if [ -d "$CLONE_DIR/.git" ]; then
        info "已存在 $CLONE_DIR，跳过克隆"
    else
        info "克隆配置仓库..."
        rm -rf "$CLONE_DIR"
        git clone "$REPO_URL" "$CLONE_DIR"
    fi
    SCRIPT_DIR="$CLONE_DIR"
fi

# ---- 交互式读取密钥 ----
if [ ! -f "$SCRIPT_DIR/.env" ] && [ "$FORCE" != "--force" ]; then
    echo ""
    echo -e "${CYAN}=== Claude Code 配置 ===${NC}"
    echo -e "${CYAN}请输入以下 API 密钥:${NC}"
    echo ""

    read -rp "  ANTHROPIC_AUTH_TOKEN: " ANTHROPIC_AUTH_TOKEN
    if [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
        error "ANTHROPIC_AUTH_TOKEN 不能为空"
    fi

    read -rp "  ANTHROPIC_BASE_URL [https://open.bigmodel.cn/api/anthropic]: " ANTHROPIC_BASE_URL
    ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-https://open.bigmodel.cn/api/anthropic}"

    read -rp "  CONTEXT7_API_KEY: " CONTEXT7_API_KEY
    if [ -z "$CONTEXT7_API_KEY" ]; then
        error "CONTEXT7_API_KEY 不能为空"
    fi

    cat > "$SCRIPT_DIR/.env" <<EOF
ANTHROPIC_AUTH_TOKEN="$ANTHROPIC_AUTH_TOKEN"
ANTHROPIC_BASE_URL="$ANTHROPIC_BASE_URL"
CONTEXT7_API_KEY="$CONTEXT7_API_KEY"
EOF
    info ".env 已生成"
fi

# 读取 .env
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
fi

# ---- 生成 settings.json ----
info "生成 settings.json..."
TEMPLATE="$SCRIPT_DIR/settings.json.template"
OUTPUT="$SCRIPT_DIR/settings.json"

sed \
    -e "s|{{ANTHROPIC_AUTH_TOKEN}}|${ANTHROPIC_AUTH_TOKEN:-}|g" \
    -e "s|{{ANTHROPIC_BASE_URL}}|${ANTHROPIC_BASE_URL:-}|g" \
    "$TEMPLATE" > "$OUTPUT"

if grep -q '{{.*}}' "$OUTPUT"; then
    warn "settings.json 中仍有未替换的模板变量，请检查 .env"
fi

# ---- 生成 .claude.json ----
info "生成 .claude.json..."
CLAUDE_JSON_TEMPLATE="$SCRIPT_DIR/claude.json.template"
CLAUDE_JSON_OUTPUT="$SCRIPT_DIR/.claude.json"

sed \
    -e "s|{{ANTHROPIC_AUTH_TOKEN}}|${ANTHROPIC_AUTH_TOKEN:-}|g" \
    -e "s|{{CONTEXT7_API_KEY}}|${CONTEXT7_API_KEY:-}|g" \
    "$CLAUDE_JSON_TEMPLATE" > "$CLAUDE_JSON_OUTPUT"

if grep -q '{{.*}}' "$CLAUDE_JSON_OUTPUT"; then
    warn ".claude.json 中仍有未替换的模板变量，请检查 .env"
fi

# ---- 创建目标目录 ----
mkdir -p "$HOME/.claude/rules"
mkdir -p "$HOME/.claude/skills"

# ---- 部署 settings.json ----
info "部署 settings.json -> ~/.claude/settings.json"
cp "$OUTPUT" "$HOME/.claude/settings.json"

# ---- 部署 .claude.json ----
info "部署 .claude.json -> ~/.claude.json"
cp "$CLAUDE_JSON_OUTPUT" "$HOME/.claude.json"

# ---- 部署 rules ----
info "部署 rules -> ~/.claude/rules/"
cp -r "$SCRIPT_DIR/rules/"* "$HOME/.claude/rules/"

# ---- 部署 skills (非符号链接的) ----
for skill_dir in "$SCRIPT_DIR"/skills-*; do
    if [ -d "$skill_dir" ]; then
        skill_name="$(basename "$skill_dir" | sed 's/^skills-//')"
        info "部署 skill: $skill_name -> ~/.claude/skills/$skill_name"
        rm -rf "$HOME/.claude/skills/$skill_name"
        cp -r "$skill_dir" "$HOME/.claude/skills/$skill_name"
    fi
done

# ---- 尝试安装字节内部 skills 和部署 record.md (需要内网环境) ----
if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://bnpm.byted.org 2>/dev/null | grep -q "200"; then
    info "检测到内网环境，安装字节内部 skills..."

    # 部署 record.md (飞书记录规则)
    if [ -f "$SCRIPT_DIR/rules/record.md" ]; then
        info "部署 record.md -> ~/.claude/rules/record.md"
        cp "$SCRIPT_DIR/rules/record.md" "$HOME/.claude/rules/record.md"
    fi

    # 加载 nvm（如果已安装）
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! command -v npx &>/dev/null; then
        warn "未找到 npx，无法安装内部 skills。请先安装 Node.js: https://nodejs.org"
    else
        info "安装 bytedance-tools skill..."
        if ! npm_config_registry="https://bnpm.byted.org" npx -y @tiktok-fe/skills@latest add chenyunpeng-1024/skills --skill bytedance-tools --source local 2>&1; then
            warn "安装 bytedance-tools 失败，跳过"
        fi

        info "安装 daily-record skill..."
        if ! npm_config_registry="https://bnpm.byted.org" npx -y @tiktok-fe/skills@latest add sunzhangliang-harris/skills --skill daily-record --source local 2>&1; then
            warn "安装 daily-record 失败，跳过"
        fi

        info "内部 skills 安装完成"
    fi
else
    warn "未检测到内网环境 (bnpm.byted.org)，跳过安装内部 skills"
fi

# ---- 清理生成的临时文件 ----
rm -f "$OUTPUT" "$CLAUDE_JSON_OUTPUT"

echo ""
info "安装完成！"
info "已部署:"
echo "  - ~/.claude.json (onboarding + MCP servers)"
echo "  - ~/.claude/settings.json"
echo "  - ~/.claude/rules/"
echo "  - ~/.claude/skills/ (4 custom skills)"
echo ""
info "重启 Claude Code 即可生效"
