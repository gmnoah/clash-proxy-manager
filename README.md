# Clash Proxy Manager

[English](#english) | [中文](#中文)

---

## English

A lightweight desktop app for managing Clash Verge proxy rules. Toggle proxy rules for Chinese streaming services with one click.

### Supported Services (16)

| Category | Service | ID |
|----------|---------|-----|
| 🎵 Music | Qishui Music (汽水音乐) | `qishui` |
| 🎵 Music | QQ Music (QQ音乐) | `qqmusic` |
| 🎵 Music | NetEase Cloud Music (网易云音乐) | `netease` |
| 🎵 Music | Kugou (酷狗音乐) | `kugou` |
| 🎵 Music | Kuwo (酷我音乐) | `kuwo` |
| 🎵 Music | Migu (咪咕音乐/视频) | `migu` |
| 📺 Video | Bilibili (B站) | `bilibili` |
| 📺 Video | Tencent Video (腾讯视频) | `tencentvideo` |
| 📺 Video | iQiyi (爱奇艺) | `iqiyi` |
| 📺 Video | Youku (优酷) | `youku` |
| 📺 Video | Mango TV (芒果TV) | `mangotv` |
| 📺 Video | Xigua Video (西瓜视频) | `xigua` |
| 📱 Short Video / Live | Douyin (抖音) | `douyin` |
| 📱 Short Video / Live | Huya (虎牙直播) | `huya` |
| 📱 Short Video / Live | Douyu (斗鱼直播) | `douyu` |
| 🎙️ Audio | Ximalaya (喜马拉雅) | `ximalaya` |

### Features

- 🎵 **One-click toggle** — Enable/disable proxy rules instantly
- 🖥️ **GUI interface** — No more editing config files manually
- 🔧 **16 services** — All major Chinese streaming platforms
- 📂 **Category view** — Services grouped by type (Music, Video, Live, Audio)
- 💾 **Persistent config** — Settings survive app restarts
- ⚡ **Lightweight** — Built with Tauri 2, minimal resource usage

### Tech Stack

| Technology | Role |
|-----------|------|
| [Tauri 2](https://tauri.app/) | Desktop framework |
| [Vue 3](https://vuejs.org/) | Frontend |
| [TypeScript](https://www.typescriptlang.org/) | Type safety |
| [Vite](https://vitejs.dev/) | Build tool |
| [Element Plus](https://element-plus.org/) | UI components |

### Install

#### Download

Grab the latest `.dmg` (macOS) or `.msi` (Windows) from [Releases](https://github.com/gmnoah/clash-proxy-manager/releases).

#### Build from source

```bash
# Prerequisites: Node.js 18+, Rust

npm install
npm run tauri:dev
npm run tauri:build
```

### CLI Usage

You can also use the proxy toggle script directly:

```bash
./scripts/proxy-toggle.sh <service-id> enable|disable

# Examples:
./scripts/proxy-toggle.sh qqmusic enable
./scripts/proxy-toggle.sh bilibili disable
```

### License

[MIT](LICENSE)

---

## 中文

轻量级桌面代理管理工具，一键开关国内主流流媒体的 Clash Verge 代理规则。

### 支持的服务 (16个)

| 分类 | 服务 | ID |
|------|------|-----|
| 🎵 音乐 | 汽水音乐 | `qishui` |
| 🎵 音乐 | QQ音乐 | `qqmusic` |
| 🎵 音乐 | 网易云音乐 | `netease` |
| 🎵 音乐 | 酷狗音乐 | `kugou` |
| 🎵 音乐 | 酷我音乐 | `kuwo` |
| 🎵 音乐 | 咪咕音乐/视频 | `migu` |
| 📺 视频 | B站 | `bilibili` |
| 📺 视频 | 腾讯视频 | `tencentvideo` |
| 📺 视频 | 爱奇艺 | `iqiyi` |
| 📺 视频 | 优酷 | `youku` |
| 📺 视频 | 芒果TV | `mangotv` |
| 📺 视频 | 西瓜视频 | `xigua` |
| 📱 短视频/直播 | 抖音 | `douyin` |
| 📱 短视频/直播 | 虎牙直播 | `huya` |
| 📱 短视频/直播 | 斗鱼直播 | `douyu` |
| 🎙️ 有声 | 喜马拉雅 | `ximalaya` |

### 功能特性

- 🎵 **一键开关** — 即时启用/禁用代理规则
- 🖥️ **可视化界面** — 告别手动编辑配置文件
- 🔧 **16 个服务** — 覆盖国内主流流媒体平台
- 📂 **分类视图** — 按音乐、视频、直播、有声分类展示
- 💾 **配置持久化** — 设置重启后保留
- ⚡ **轻量高效** — 基于 Tauri 2，资源占用极低

### 技术栈

| 技术 | 用途 |
|-----|------|
| [Tauri 2](https://tauri.app/) | 桌面应用框架 |
| [Vue 3](https://vuejs.org/) | 前端框架 |
| [TypeScript](https://www.typescriptlang.org/) | 类型安全 |
| [Vite](https://vitejs.dev/) | 构建工具 |
| [Element Plus](https://element-plus.org/) | UI 组件库 |

### 安装

#### 下载

从 [Releases](https://github.com/gmnoah/clash-proxy-manager/releases) 下载最新 `.dmg`（macOS）或 `.msi`（Windows）。

#### 从源码构建

```bash
# 前置条件: Node.js 18+, Rust

npm install
npm run tauri:dev
npm run tauri:build
```

### 命令行使用

也可以直接使用代理切换脚本：

```bash
./scripts/proxy-toggle.sh <服务ID> enable|disable

# 示例：
./scripts/proxy-toggle.sh qqmusic enable
./scripts/proxy-toggle.sh bilibili disable
```

### 工作原理

每个服务的代理规则包含：
- **PROCESS-NAME** 规则 — 匹配客户端进程名
- **DOMAIN-SUFFIX** 规则 — 匹配服务域名和 CDN 节点

脚本会自动修改 Clash Verge 的配置文件并热重载内核，无需重启 Clash Verge。

### 许可证

[MIT](LICENSE)
