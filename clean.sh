#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/../_scripts/lib/common.sh"
cd "$ROOT"

parse_clean_args "$@"
for arg in "$@"; do
  case "$arg" in
    -h|--help) clean_help; exit 0 ;;
  esac
done

echo "将清理:"
[[ -d "$ROOT/dist" ]] && report_dir_size "$ROOT/dist"
[[ -d "$ROOT/node_modules" ]] && report_dir_size "$ROOT/node_modules"
[[ -d "$ROOT/src-tauri/target" ]] && report_dir_size "$ROOT/src-tauri/target"
[[ -d "$ROOT/dist" || -d "$ROOT/node_modules" || -d "$ROOT/src-tauri/target" ]] || { echo "无需清理"; exit 0; }
confirm_delete "$CLEAN_YES" || exit 0
rm_dir_if_exists "$ROOT/dist" "dist/"
rm_dir_if_exists "$ROOT/node_modules" "node_modules/"
rm_dir_if_exists "$ROOT/src-tauri/target" "src-tauri/target/"
echo ">> 清理完成"
