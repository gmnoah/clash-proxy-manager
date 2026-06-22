#!/bin/bash
# proxy-toggle.sh - 通用代理规则切换脚本
# 用法: proxy-toggle.sh <service-id> enable|disable
#
# 支持的服务 ID 见下方 SERVICES 配置
set -u

SERVICE_ID="${1:-}"
MODE="${2:-}"

if [ -z "$SERVICE_ID" ] || [ -z "$MODE" ]; then
  echo "Usage: $0 <service-id> enable|disable"
  echo ""
  echo "Supported services:"
  echo "  qishui       汽水音乐"
  echo "  bilibili     B站"
  echo "  qqmusic      QQ音乐"
  echo "  tencentvideo 腾讯视频"
  echo "  iqiyi        爱奇艺"
  echo "  youku        优酷"
  echo "  netease      网易云音乐"
  echo "  douyin       抖音"
  echo "  xigua        西瓜视频"
  echo "  mangotv      芒果TV"
  echo "  migu         咪咕音乐/视频"
  echo "  kugou        酷狗音乐"
  echo "  kuwo         酷我音乐"
  echo "  ximalaya     喜马拉雅"
  echo "  huya         虎牙直播"
  echo "  douyu        斗鱼直播"
  exit 2
fi

if [ "$MODE" != "enable" ] && [ "$MODE" != "disable" ]; then
  echo "Error: mode must be 'enable' or 'disable'"
  exit 2
fi

# 查找 python3
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

"$PYTHON_BIN" - "$SERVICE_ID" "$MODE" <<'PYEOF'
from __future__ import annotations

import datetime as _dt
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

service_id = sys.argv[1]
mode = sys.argv[2]
enable = mode == "enable"

# ============================================================
# 服务规则定义
# ============================================================
SERVICES = {
    "qishui": {
        "name": "汽水音乐",
        "rules": [
            "PROCESS-NAME,汽水音乐,🚀 节点选择",
            "PROCESS-NAME,汽水音乐 Helper,🚀 节点选择",
            "PROCESS-NAME,汽水音乐 Helper (Renderer),🚀 节点选择",
            "DOMAIN-SUFFIX,qishui.com,🚀 节点选择",
            "DOMAIN-SUFFIX,qishui.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,qishui.com.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,qishuimusic.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,qishuimusic.com.cn,🚀 节点选择",
        ],
    },
    "bilibili": {
        "name": "B站",
        "rules": [
            "PROCESS-NAME,bilibili,🚀 节点选择",
            "PROCESS-NAME,bilibili Helper,🚀 节点选择",
            "PROCESS-NAME,bilibili Helper (Renderer),🚀 节点选择",
            "DOMAIN-SUFFIX,bilibili.com,🚀 节点选择",
            "DOMAIN-SUFFIX,bilibili.tv,🚀 节点选择",
            "DOMAIN-SUFFIX,bilivideo.com,🚀 节点选择",
            "DOMAIN-SUFFIX,hdslb.com,🚀 节点选择",
            "DOMAIN-SUFFIX,bilivideo.cn,🚀 节点选择",
        ],
    },
    "qqmusic": {
        "name": "QQ音乐",
        "rules": [
            "PROCESS-NAME,QQMusic,🚀 节点选择",
            "PROCESS-NAME,QQMusicMac,🚀 节点选择",
            "DOMAIN-SUFFIX,music.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,qqmusic.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,y.gtimg.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,music.tc.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,streamoc.music.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,dl.stream.qqmusic.qq.com,🚀 节点选择",
        ],
    },
    "tencentvideo": {
        "name": "腾讯视频",
        "rules": [
            "PROCESS-NAME,腾讯视频,🚀 节点选择",
            "PROCESS-NAME,tenvideo,🚀 节点选择",
            "PROCESS-NAME,tenvideo_mac,🚀 节点选择",
            "DOMAIN-SUFFIX,v.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,video.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,tdatasrc.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,live.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,h5vv.qq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,vi.l.qq.com,🚀 节点选择",
        ],
    },
    "iqiyi": {
        "name": "爱奇艺",
        "rules": [
            "PROCESS-NAME,爱奇艺,🚀 节点选择",
            "PROCESS-NAME,iQiyi,🚀 节点选择",
            "DOMAIN-SUFFIX,iqiyi.com,🚀 节点选择",
            "DOMAIN-SUFFIX,iq.com,🚀 节点选择",
            "DOMAIN-SUFFIX,aiqiyi.com,🚀 节点选择",
            "DOMAIN-SUFFIX,pps.tv,🚀 节点选择",
            "DOMAIN-SUFFIX,qiyi.com,🚀 节点选择",
        ],
    },
    "youku": {
        "name": "优酷",
        "rules": [
            "PROCESS-NAME,优酷,🚀 节点选择",
            "PROCESS-NAME,Youku,🚀 节点选择",
            "DOMAIN-SUFFIX,youku.com,🚀 节点选择",
            "DOMAIN-SUFFIX,ykimg.com,🚀 节点选择",
            "DOMAIN-SUFFIX,tudou.com,🚀 节点选择",
            "DOMAIN-SUFFIX,alicdn.com,🚀 节点选择",
        ],
    },
    "netease": {
        "name": "网易云音乐",
        "rules": [
            "PROCESS-NAME,网易云音乐,🚀 节点选择",
            "PROCESS-NAME,NeteaseMusic,🚀 节点选择",
            "DOMAIN-SUFFIX,music.163.com,🚀 节点选择",
            "DOMAIN-SUFFIX,netease.com,🚀 节点选择",
            "DOMAIN-SUFFIX,126.net,🚀 节点选择",
            "DOMAIN-SUFFIX,127.net,🚀 节点选择",
            "DOMAIN-SUFFIX,y.music.163.com,🚀 节点选择",
        ],
    },
    "douyin": {
        "name": "抖音",
        "rules": [
            "PROCESS-NAME,抖音,🚀 节点选择",
            "PROCESS-NAME,Douyin,🚀 节点选择",
            "DOMAIN-SUFFIX,douyin.com,🚀 节点选择",
            "DOMAIN-SUFFIX,douyinpic.com,🚀 节点选择",
            "DOMAIN-SUFFIX,douyincdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,tiktokcdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,bytedance.com,🚀 节点选择",
            "DOMAIN-SUFFIX,pstatp.com,🚀 节点选择",
        ],
    },
    "xigua": {
        "name": "西瓜视频",
        "rules": [
            "PROCESS-NAME,西瓜视频,🚀 节点选择",
            "PROCESS-NAME,Xigua,🚀 节点选择",
            "DOMAIN-SUFFIX,ixigua.com,🚀 节点选择",
            "DOMAIN-SUFFIX,xiguacity.com,🚀 节点选择",
            "DOMAIN-SUFFIX,xgcdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,toutiao.com,🚀 节点选择",
            "DOMAIN-SUFFIX,toutiaovod.com,🚀 节点选择",
        ],
    },
    "mangotv": {
        "name": "芒果TV",
        "rules": [
            "PROCESS-NAME,芒果TV,🚀 节点选择",
            "PROCESS-NAME,MangoTV,🚀 节点选择",
            "DOMAIN-SUFFIX,mgtv.com,🚀 节点选择",
            "DOMAIN-SUFFIX,hunantv.com,🚀 节点选择",
            "DOMAIN-SUFFIX,imgo.tv,🚀 节点选择",
        ],
    },
    "migu": {
        "name": "咪咕音乐/视频",
        "rules": [
            "PROCESS-NAME,咪咕音乐,🚀 节点选择",
            "PROCESS-NAME,咪咕视频,🚀 节点选择",
            "PROCESS-NAME,MiguMusic,🚀 节点选择",
            "PROCESS-NAME,MiguVideo,🚀 节点选择",
            "DOMAIN-SUFFIX,migu.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,miguvideo.com,🚀 节点选择",
            "DOMAIN-SUFFIX,migumusic.com,🚀 节点选择",
            "DOMAIN-SUFFIX,cmvideo.cn,🚀 节点选择",
        ],
    },
    "kugou": {
        "name": "酷狗音乐",
        "rules": [
            "PROCESS-NAME,酷狗音乐,🚀 节点选择",
            "PROCESS-NAME,KuGou,🚀 节点选择",
            "DOMAIN-SUFFIX,kugou.com,🚀 节点选择",
            "DOMAIN-SUFFIX,kugoucdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,kuwo.cn,🚀 节点选择",
        ],
    },
    "kuwo": {
        "name": "酷我音乐",
        "rules": [
            "PROCESS-NAME,酷我音乐,🚀 节点选择",
            "PROCESS-NAME,Kuwo,🚀 节点选择",
            "DOMAIN-SUFFIX,kuwo.cn,🚀 节点选择",
            "DOMAIN-SUFFIX,kuwo.com,🚀 节点选择",
            "DOMAIN-SUFFIX,kwcdn.com,🚀 节点选择",
        ],
    },
    "ximalaya": {
        "name": "喜马拉雅",
        "rules": [
            "PROCESS-NAME,喜马拉雅,🚀 节点选择",
            "PROCESS-NAME,Ximalaya,🚀 节点选择",
            "DOMAIN-SUFFIX,ximalaya.com,🚀 节点选择",
            "DOMAIN-SUFFIX,xmly.com,🚀 节点选择",
            "DOMAIN-SUFFIX,ximalaya.com.cn,🚀 节点选择",
        ],
    },
    "huya": {
        "name": "虎牙直播",
        "rules": [
            "PROCESS-NAME,虎牙直播,🚀 节点选择",
            "PROCESS-NAME,Huya,🚀 节点选择",
            "DOMAIN-SUFFIX,huya.com,🚀 节点选择",
            "DOMAIN-SUFFIX,huyacdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,huyaxcdn.com,🚀 节点选择",
        ],
    },
    "douyu": {
        "name": "斗鱼直播",
        "rules": [
            "PROCESS-NAME,斗鱼直播,🚀 节点选择",
            "PROCESS-NAME,Douyu,🚀 节点选择",
            "DOMAIN-SUFFIX,douyu.com,🚀 节点选择",
            "DOMAIN-SUFFIX,douyucdn.com,🚀 节点选择",
            "DOMAIN-SUFFIX,douyutv.com,🚀 节点选择",
        ],
    },
}

if service_id not in SERVICES:
    print(f"未知的服务 ID: {service_id}")
    print(f"支持的服务: {', '.join(SERVICES.keys())}")
    sys.exit(1)

service = SERVICES[service_id]
rules = service["rules"]
service_name = service["name"]

# ============================================================
# Clash Verge 配置路径
# ============================================================
app_dir = Path.home() / "Library/Application Support/io.github.clash-verge-rev.clash-verge-rev"
profiles_dir = app_dir / "profiles"
profiles_yaml = app_dir / "profiles.yaml"
clash_yaml = app_dir / "clash-verge.yaml"
check_yaml = app_dir / "clash-verge-check.yaml"
mihomo = Path("/Applications/Clash Verge.app/Contents/MacOS/verge-mihomo")
socket = Path("/tmp/verge/verge-mihomo.sock")


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


def remove_service_rules(lines: list[str]) -> list[str]:
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

    lines = remove_service_rules(lines)
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
    lines = remove_service_rules(split_lines(path.read_text(encoding="utf-8")))
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
                backup = target.with_name(target.name + f".bak-{service_id}-toggle-{timestamp}")
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
    print(f"已{action}{service_name}走代理规则。")
    print(reload_message)
    print()
    print("已处理的持久规则文件：")
    print(rules_file)
    print()
    print(f"提示：如果{service_name}已有旧连接，退出并重新打开后会完全按新规则连接。")
    return 0


raise SystemExit(main())
PYEOF
STATUS=$?

echo
exit "$STATUS"
