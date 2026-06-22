# Proxy Controller

[English](#english) | [中文](#中文)

---

## English

A lightweight desktop app for managing Clash Verge proxy services. Toggle proxy rules for apps like Qishui Music and Bilibili with one click.

### Features

- 🎵 **One-click toggle** — Enable/disable proxy rules instantly
- 🖥️ **GUI interface** — No more editing config files manually
- 🔧 **Multi-service support** — Manage Qishui, Bilibili, and custom services
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

Grab the latest `.dmg` (macOS) or `.msi` (Windows) from [Releases](https://github.com/gmnoah/qishui-proxy-controller/releases).

#### Build from source

```bash
# Prerequisites: Node.js 18+, Rust, pnpm

# Install dependencies
npm install

# Development
npm run tauri:dev

# Build
npm run tauri:build
```

### Configuration

Config file: `~/.config/proxy-controller/services.json`

```json
{
  "services": [
    {
      "id": "qishui",
      "name": "Qishui Music",
      "icon": "🎵",
      "scriptPath": "/path/to/qishui-proxy-control.sh",
      "enabled": false
    }
  ]
}
```

#### Adding a new service

1. Edit the config file
2. Add a new service entry with `id`, `name`, `icon`, `scriptPath`
3. Click refresh in the app or restart

> **Note:** Proxy scripts must support `enable` and `disable` arguments.

### License

[MIT](LICENSE)

---

## 中文

轻量级桌面代理管理工具，一键开关汽水音乐、B站等 Clash Verge 代理规则。

### 功能特性

- 🎵 **一键开关** — 即时启用/禁用代理规则
- 🖥️ **可视化界面** — 告别手动编辑配置文件
- 🔧 **多服务支持** — 管理汽水音乐、B站及自定义服务
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

从 [Releases](https://github.com/gmnoah/qishui-proxy-controller/releases) 下载最新 `.dmg`（macOS）或 `.msi`（Windows）。

#### 从源码构建

```bash
# 前置条件: Node.js 18+, Rust, pnpm

# 安装依赖
npm install

# 开发模式
npm run tauri:dev

# 构建打包
npm run tauri:build
```

### 配置说明

配置文件：`~/.config/proxy-controller/services.json`

```json
{
  "services": [
    {
      "id": "qishui",
      "name": "汽水音乐",
      "icon": "🎵",
      "scriptPath": "/path/to/qishui-proxy-control.sh",
      "enabled": false
    }
  ]
}
```

#### 添加新服务

1. 编辑配置文件
2. 添加新的服务条目（包含 `id`、`name`、`icon`、`scriptPath`）
3. 点击应用中的刷新按钮或重启应用

> **注意：** 代理脚本需支持 `enable` 和 `disable` 两个参数。

### 许可证

[MIT](LICENSE)
