#!/usr/bin/env bash
#
# Claude Code 配置安装脚本
# 用法: bash install.sh [--force]
#
# 将本仓库中的配置部署到当前机器的 ~/.claude/
# 敏感信息从 .env 文件读取，写入 settings.json
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FORCE="${1:-}"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ---- 检查 .env ----
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    if [ "$FORCE" != "--force" ]; then
        error ".env 文件不存在。请复制 .env.example 为 .env 并填入实际值:
  cp .env.example .env
  编辑 .env 填入 ANTHROPIC_AUTH_TOKEN 和 ANTHROPIC_BASE_URL"
    fi
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

# 用 sed 替换模板变量
sed \
    -e "s|{{ANTHROPIC_AUTH_TOKEN}}|${ANTHROPIC_AUTH_TOKEN:-}|g" \
    -e "s|{{ANTHROPIC_BASE_URL}}|${ANTHROPIC_BASE_URL:-}|g" \
    "$TEMPLATE" > "$OUTPUT"

if grep -q '{{.*}}' "$OUTPUT"; then
    warn "settings.json 中仍有未替换的模板变量，请检查 .env"
fi

# ---- 创建目标目录 ----
mkdir -p "$HOME/.claude/rules"
mkdir -p "$HOME/.claude/skills"

# ---- 部署 settings.json ----
info "部署 settings.json -> ~/.claude/settings.json"
cp "$OUTPUT" "$HOME/.claude/settings.json"

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

# ---- 清理生成的临时文件 ----
rm -f "$OUTPUT"

echo ""
info "安装完成！"
info "已部署:"
echo "  - ~/.claude/settings.json"
echo "  - ~/.claude/rules/"
echo "  - ~/.claude/skills/ (4 custom skills)"
echo ""
warn "注意: permissions.allow 列表为空，新机器上的权限会在使用时自动添加"
