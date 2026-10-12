#!/bin/bash
set -Eeuo pipefail

# Xianchongji static portfolio deploy helper for macOS.
# This script does not request or save GitHub passwords or tokens.
ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO="xianchongji-ui-portfolio"

printf '\n================================================\n'
printf '   XIANCHONGJI / GitHub Pages publisher\n'
printf '================================================\n\n'

if [[ ! -f "$ROOT/index.html" || ! -f "$ROOT/downloads/xianchongji-portfolio.pdf" ]]; then
  echo "缺少网站文件。请先把下载的 ZIP 完整解压后再运行。"
  read -r -p "按回车退出..." _
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "你的电脑尚未安装 Git。请先运行 xcode-select --install，并完成系统提示的安装。"
  read -r -p "按回车退出..." _
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "需要 GitHub 官方 CLI (gh)，用于创建仓库和安全登录。"
  if command -v brew >/dev/null 2>&1; then
    read -r -p "是否通过 Homebrew 安装 gh？[y/N] " INSTALL_GH
    if [[ "$INSTALL_GH" == "y" || "$INSTALL_GH" == "Y" ]]; then
      brew install gh
    else
      echo "已取消。你也可以手动安装：https://cli.github.com/"
      read -r -p "按回车退出..." _
      exit 1
    fi
  else
    echo "未检测到 Homebrew。请先安装 gh：https://cli.github.com/"
    read -r -p "按回车退出..." _
    exit 1
  fi
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "即将打开 GitHub 的浏览器登录授权，完成后自动继续。"
  gh auth login --hostname github.com --git-protocol https --web
fi

GH_USER="$(gh api user --jq '.login')"
GH_ID="$(gh api user --jq '.id')"
FULL="$GH_USER/$REPO"
URL="https://$GH_USER.github.io/$REPO/"
echo "当前 GitHub 账号：$GH_USER"
printf '即将创建公开仓库：https://github.com/%s\n' "$FULL"
echo "注意：作品集图片和 PDF 将对所有人公开。"
read -r -p "确认创建并上传？[y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "已取消，未上传。"
  read -r -p "按回车退出..." _
  exit 0
fi

if gh repo view "$FULL" >/dev/null 2>&1; then
  echo "这个仓库已经存在，为避免覆盖原有内容，自动上传已停止："
  echo "https://github.com/$FULL"
  echo "可联系 ChatGPT 检查现有仓库后再安全地更新。"
  read -r -p "按回车退出..." _
  exit 1
fi

cd "$ROOT"
if [[ -d .git ]]; then
  echo "当前文件夹已有 Git 历史。为避免误操作，请使用新解压的文件夹重试。"
  read -r -p "按回车退出..." _
  exit 1
fi

git init -b main
if [[ -z "$(git config user.name || true)" ]]; then git config user.name "$GH_USER"; fi
if [[ -z "$(git config user.email || true)" ]]; then git config user.email "$GH_ID+$GH_USER@users.noreply.github.com"; fi
git add .
git commit -m "Publish Xianchongji UI/UX design portfolio"

echo "创建仓库并上传文件中，图片约 30 MB，请稍候..."
gh repo create "$FULL" --public --description "Xianchongji pet commerce UI/UX design portfolio · 贤宠集作品集" --source . --remote origin --push

echo "配置 GitHub Pages..."
if gh api --method POST "repos/$FULL/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1; then
  echo "GitHub Pages 已提交启用请求。"
elif gh api "repos/$FULL/pages" >/dev/null 2>&1; then
  echo "GitHub Pages 已经启用。"
else
  echo "GitHub Pages 未能自动开启。请进入仓库 Settings > Pages，选择 main / (root)。"
fi

printf '\n================ 处理结果 ================\n'
echo "GitHub 仓库：https://github.com/$FULL"
echo "作品集网址：$URL"
echo "首次部署通常需要几分钟，刚打开网址可能暂时显示 404。"
echo "文件已上传后，请将 GitHub 仓库链接发给 ChatGPT 继续检查。"
echo "==========================================\n"
read -r -p "按回车关闭窗口..." _
