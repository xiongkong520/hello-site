#!/usr/bin/env bash
# 组装静态产物到 dist/（Cloudflare Pages「连接 Git」模式用它作为 Build command）
set -euo pipefail
cd "$(dirname "$0")"
rm -rf dist
mkdir -p dist/food
cp index.html about-me.html meme.webp dist/
cp food.html dist/food/index.html
cp shock.jpg dist/food/shock.jpg
echo "built dist/ ($(find dist -type f | wc -l) files)"
