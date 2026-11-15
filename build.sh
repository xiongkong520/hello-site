#!/usr/bin/env bash
# 组装静态产物到 dist/（Cloudflare Pages 构建用）
set -euo pipefail
cd "$(dirname "$0")"
rm -rf dist
mkdir -p dist/food dist/wheel
cp index.html about-me.html meme.webp dist/
cp food/index.html shock.jpg wheel/gummu.jpg dist/food/
cp wheel/index.html wheel/gummu.jpg dist/wheel/
echo "built dist/ ($(find dist -type f | wc -l) files)"
