#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/../_scripts/lib/common.sh"
cd "$ROOT"
ensure_npm_deps
exec npm run tauri:dev
