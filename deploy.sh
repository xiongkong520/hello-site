#!/usr/bin/env bash
# 一键构建 + 发布到 Cloudflare Pages（直接上传模式）
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh
wrangler pages deploy dist --project-name=mimichong --commit-dirty=true
