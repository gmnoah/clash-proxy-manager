#!/bin/bash
set -u

MODE="${1:-}"

if [ "$MODE" != "enable" ] && [ "$MODE" != "disable" ]; then
  echo "Usage: $0 enable|disable"
  exit 2
fi

PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="$(command -v python3)"
elif [ -x /opt/homebrew/bin/python3 ]; then
  PYTHON_BIN="/opt/homebrew/bin/python3"
elif [ -x /usr/local/bin/python3 ]; then
  PYTHON_BIN="/usr/local/bin/python3"
elif [ -x /usr/bin/python3 ]; then
  PYTHON_BIN="/usr/bin/python3"
fi

if [ -z "$PYTHON_BIN" ]; then
  echo "没有找到 python3，无法安全修改 Clash Verge 配置。"
  exit 1
fi

"$PYTHON_BIN" - "$MODE" <<'PY'
from __future__ import annotations

import datetime as _dt
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

mode = sys.argv[1]
enable = mode == "enable"

app_dir = Path.home() / "Library/Application Support/io.github.clash-verge-rev.clash-verge-rev"
profiles_dir = app_dir / "profiles"
profiles_yaml = app_dir / "profiles.yaml"
clash_yaml = app_dir / "clash-verge.yaml"
check_yaml = app_dir / "clash-verge-check.yaml"
mihomo = Path("/Applications/Clash Verge.app/Contents/MacOS/verge-mihomo")
socket = Path("/tmp/verge/verge-mihomo.sock")

rules = [
    "PROCESS-NAME,汽水音乐,🚀 节点选择",
    "PROCESS-NAME,汽水音乐 Helper,🚀 节点选择",
    "PROCESS-NAME,汽水音乐 Helper (Renderer),🚀 节点选择",
    "DOMAIN-SUFFIX,qishui.com,🚀 节点选择",
    "DOMAIN-SUFFIX,qishui.cn,🚀 节点选择",
    "DOMAIN-SUFFIX,qishui.com.cn,🚀 节点选择",
    "DOMAIN-SUFFIX,qishuimusic.cn,🚀 节点选择",
    "DOMAIN-SUFFIX,qishuimusic.com.cn,🚀 节点选择",
]


def find_current_rules_file() -> Path:
    fallback = profiles_dir / "r9i6cc2mzne0.yaml"
    if not profiles_yaml.exists():
        return fallback

    text = profiles_yaml.read_text(encoding="utf-8")
    current = None
    for line in text.splitlines():
        if line.startswith("current:"):
            current = line.split(":", 1)[1].strip()
            break

    if not current:
        return fallback

    current_item = False
    in_option = False
    rules_uid = None
    for line in text.splitlines():
        if line.startswith("- uid: "):
            uid = line.split(":", 1)[1].strip()
            current_item = uid == current
            in_option = False
            continue

        if not current_item:
            continue

        stripped = line.strip()
        if stripped == "option:":
            in_option = True
            continue

        if in_option and stripped.startswith("rules:"):
            value = stripped.split(":", 1)[1].strip()
            if value and value != "null":
                rules_uid = value
            break

    candidate = profiles_dir / f"{rules_uid}.yaml" if rules_uid else fallback
    return candidate if candidate.exists() else fallback


def split_lines(text: str) -> list[str]:
    return text.splitlines()


def join_lines(lines: list[str]) -> str:
    return "\n".join(lines).rstrip() + "\n"


def payload_for_rule_line(line: str) -> str | None:
    stripped = line.strip()
    if not stripped.startswith("- "):
        return None
    payload = stripped[2:].strip()
    if len(payload) >= 2 and payload[0] == payload[-1] and payload[0] in {"'", '"'}:
        payload = payload[1:-1]
    return payload


def remove_qishui_rules(lines: list[str]) -> list[str]:
    return [line for line in lines if payload_for_rule_line(line) not in rules]


def top_level_section_end(lines: list[str], start: int) -> int:
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if line and not line.startswith((" ", "\t")) and not line.lstrip().startswith("#"):
            return index
    return len(lines)


def update_enhancement_file(path: Path, want_enable: bool) -> None:
    if path.exists():
        lines = split_lines(path.read_text(encoding="utf-8"))
    else:
        lines = ["prepend: []", "append: []", "delete: []"]

    lines = remove_qishui_rules(lines)
    prepend_index = None
    for index, line in enumerate(lines):
        if line.startswith("prepend:"):
            prepend_index = index
            break

    block = [f"  - '{rule}'" for rule in rules]

    if prepend_index is None:
        if want_enable:
            lines = ["prepend:"] + block + lines
        path.write_text(join_lines(lines), encoding="utf-8")
        return

    prepend_line = lines[prepend_index].strip()
    if want_enable:
        if prepend_line == "prepend: []":
            lines[prepend_index : prepend_index + 1] = ["prepend:"] + block
        else:
            lines[prepend_index + 1 : prepend_index + 1] = block
    else:
        if prepend_line != "prepend: []":
            end = top_level_section_end(lines, prepend_index)
            section = lines[prepend_index + 1 : end]
            has_remaining_rule_items = any(payload_for_rule_line(line) is not None for line in section)
            if not has_remaining_rule_items:
                lines[prepend_index:end] = ["prepend: []"]

    path.write_text(join_lines(lines), encoding="utf-8")


def update_generated_config(path: Path, want_enable: bool) -> None:
    if not path.exists():
        return
    lines = remove_qishui_rules(split_lines(path.read_text(encoding="utf-8")))
    if want_enable:
        insert_at = None
        for index, line in enumerate(lines):
            if line.strip() == "rules:":
                insert_at = index + 1
                break
        if insert_at is None:
            raise RuntimeError(f"没有在 {path} 找到 rules: 段落")
        lines[insert_at:insert_at] = [f"- {rule}" for rule in rules]
    path.write_text(join_lines(lines), encoding="utf-8")


def run(cmd: list[str], timeout: int = 30) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True, timeout=timeout)


def restore(backups: list[tuple[Path, Path]]) -> None:
    for original, backup in backups:
        if backup.exists():
            shutil.copy2(backup, original)


def validate_config() -> None:
    if not mihomo.exists() or not check_yaml.exists():
        return
    result = run([str(mihomo), "-t", "-d", str(app_dir), "-f", str(check_yaml)])
    if result.returncode != 0:
        output = (result.stdout + "\n" + result.stderr).strip()
        raise RuntimeError("Clash 配置校验失败：\n" + output[-4000:])


def reload_core() -> str:
    if not socket.exists() or not clash_yaml.exists():
        return "Clash Verge 似乎没有在运行；配置已保存，下次启动 Clash Verge 会生效。"

    payload = json.dumps({"path": str(clash_yaml), "force": True}, ensure_ascii=False)
    curl = shutil.which("curl") or "/usr/bin/curl"
    result = run([
        curl,
        "-sS",
        "-X",
        "PUT",
        "--unix-socket",
        str(socket),
        "http://localhost/configs",
        "-H",
        "Content-Type: application/json",
        "-d",
        payload,
    ])
    if result.returncode != 0:
        return "配置已保存，但热重载失败；重启 Clash Verge 后会生效。\n" + (result.stderr or result.stdout)
    return "Clash 内核已热重载。"


def main() -> int:
    if not app_dir.exists():
        print("没有找到 Clash Verge 配置目录：", app_dir)
        return 1

    rules_file = find_current_rules_file()
    targets = [rules_file, clash_yaml, check_yaml]
    timestamp = _dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    backups: list[tuple[Path, Path]] = []

    try:
        for target in targets:
            if target.exists():
                backup = target.with_name(target.name + f".bak-qishui-toggle-{timestamp}")
                shutil.copy2(target, backup)
                backups.append((target, backup))

        update_enhancement_file(rules_file, enable)
        update_generated_config(clash_yaml, enable)
        update_generated_config(check_yaml, enable)
        validate_config()
        reload_message = reload_core()
    except Exception as exc:
        restore(backups)
        print("操作失败，已回滚到本次运行前的备份。")
        print(str(exc))
        return 1

    action = "开启" if enable else "关闭"
    print(f"已{action}汽水音乐走代理规则。")
    print(reload_message)
    print()
    print("已处理的持久规则文件：")
    print(rules_file)
    print()
    print("提示：如果汽水音乐已有旧连接，退出并重新打开汽水音乐后会完全按新规则连接。")
    return 0


raise SystemExit(main())
PY
STATUS=$?

echo
printf "按任意键关闭窗口..."
IFS= read -r -n 1 -s _
echo
exit "$STATUS"
