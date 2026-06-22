import { Command } from "@tauri-apps/plugin-shell";
import { exists, mkdir, readTextFile, writeTextFile } from "@tauri-apps/plugin-fs";
import { homeDir, join } from "@tauri-apps/api/path";
import type { ProxyConfig, ProxyService } from "@/types";

// 默认代理脚本路径（通用脚本）
const SCRIPT_PATH = "/Applications/Clash Proxy Manager.app/Contents/Resources/scripts/proxy-toggle.sh";

// 默认配置（首次启动时使用）
const DEFAULT_CONFIG: ProxyConfig = {
  services: [
    // 音乐
    { id: "qishui", name: "汽水音乐", icon: "🎵", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "qqmusic", name: "QQ音乐", icon: "🎶", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "netease", name: "网易云音乐", icon: "☁️", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "kugou", name: "酷狗音乐", icon: "🐶", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "kuwo", name: "酷我音乐", icon: "🎧", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "migu", name: "咪咕音乐/视频", icon: "🎤", category: "音乐", scriptPath: SCRIPT_PATH, enabled: false },
    // 视频
    { id: "bilibili", name: "B站", icon: "📺", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "tencentvideo", name: "腾讯视频", icon: "🎬", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "iqiyi", name: "爱奇艺", icon: "🥝", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "youku", name: "优酷", icon: "🔶", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "mangotv", name: "芒果TV", icon: "🥭", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "xigua", name: "西瓜视频", icon: "🍉", category: "视频", scriptPath: SCRIPT_PATH, enabled: false },
    // 短视频/直播
    { id: "douyin", name: "抖音", icon: "📱", category: "短视频/直播", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "huya", name: "虎牙直播", icon: "🐯", category: "短视频/直播", scriptPath: SCRIPT_PATH, enabled: false },
    { id: "douyu", name: "斗鱼直播", icon: "🐟", category: "短视频/直播", scriptPath: SCRIPT_PATH, enabled: false },
    // 有声
    { id: "ximalaya", name: "喜马拉雅", icon: "🏔️", category: "有声", scriptPath: SCRIPT_PATH, enabled: false },
  ],
};

/**
 * 获取配置文件完整路径
 */
async function getConfigPath(): Promise<string> {
  const home = await homeDir();
  return join(home, ".config/proxy-controller/services.json");
}

/**
 * 确保配置目录存在
 */
async function ensureConfigDir(): Promise<void> {
  const home = await homeDir();
  const configDir = await join(home, ".config/proxy-controller");

  if (!(await exists(configDir))) {
    await mkdir(configDir, { recursive: true });
  }
}

/**
 * 加载配置
 */
export async function loadServices(): Promise<ProxyService[]> {
  try {
    const configPath = await getConfigPath();

    if (!(await exists(configPath))) {
      // 首次启动，创建默认配置
      await ensureConfigDir();
      await saveServices(DEFAULT_CONFIG.services);
      return DEFAULT_CONFIG.services;
    }

    const content = await readTextFile(configPath);
    const config: ProxyConfig = JSON.parse(content);
    return config.services;
  } catch (error) {
    console.error("加载配置失败:", error);
    return DEFAULT_CONFIG.services;
  }
}

/**
 * 保存配置
 */
export async function saveServices(services: ProxyService[]): Promise<void> {
  try {
    const configPath = await getConfigPath();
    await ensureConfigDir();

    const config: ProxyConfig = { services };
    await writeTextFile(configPath, JSON.stringify(config, null, 2));
  } catch (error) {
    console.error("保存配置失败:", error);
    throw error;
  }
}

/**
 * 切换代理状态
 * 使用通用脚本，传入 service-id 和 enable/disable 参数
 */
export async function toggleProxy(
  service: ProxyService,
  enable: boolean
): Promise<{ success: boolean; error?: string }> {
  try {
    const action = enable ? "enable" : "disable";
    const cmd = `${service.scriptPath} ${service.id} ${action}`;
    console.log(`执行命令: sh -c ${cmd}`);

    // 使用 sh -c 执行通用脚本
    const output = await Command.create("exec-sh", ["-c", cmd]).execute();

    console.log("命令输出:", { code: output.code, stdout: output.stdout, stderr: output.stderr });

    if (output.code === 0) {
      // 更新配置
      const services = await loadServices();
      const idx = services.findIndex((s) => s.id === service.id);
      if (idx !== -1) {
        services[idx].enabled = enable;
        await saveServices(services);
      }
      return { success: true };
    } else {
      const errorMsg = output.stderr || output.stdout || `退出码: ${output.code}`;
      console.error("执行失败:", errorMsg);
      return { success: false, error: errorMsg };
    }
  } catch (error) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error("切换代理失败:", errorMsg);
    return { success: false, error: errorMsg };
  }
}
