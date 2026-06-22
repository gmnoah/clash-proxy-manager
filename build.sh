#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/../_scripts/lib/common.sh"
cd "$ROOT"
ensure_npm_deps
bundle_args=( $(tauri_bundle_args) )
npm run tauri:build -- "${bundle_args[@]}"
copy_tauri_bundle_to_apps "$ROOT"
echo ">> 完成: 代理控制器"
