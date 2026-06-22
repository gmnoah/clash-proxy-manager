import { Command } from "@tauri-apps/plugin-shell";
import { exists, mkdir, readTextFile, writeTextFile } from "@tauri-apps/plugin-fs";
import { homeDir, join } from "@tauri-apps/api/path";
import type { ProxyConfig, ProxyService } from "@/types";

// 默认配置（首次启动时使用）
const DEFAULT_CONFIG: ProxyConfig = {
  services: [
    {
      id: "qishui",
      name: "汽水音乐",
      icon: "🎵",
      scriptPath:
        "/Users/mac/NOAH/NOAH-CODE/05_NOAH_PRACTICE/01_APP/50_qishuiCommand/qishui-proxy-control.sh",
      enabled: false,
    },
    {
      id: "bilibili",
      name: "B站",
      icon: "📺",
      scriptPath:
        "/Users/mac/NOAH/NOAH-CODE/05_NOAH_PRACTICE/01_APP/50_qishuiCommand/bilibili-proxy-control.sh",
      enabled: false,
    },
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
 */
export async function toggleProxy(
  service: ProxyService,
  enable: boolean
): Promise<{ success: boolean; error?: string }> {
  try {
    const action = enable ? "enable" : "disable";
    const cmd = `${service.scriptPath} ${action}`;
    console.log(`执行命令: sh -c ${cmd}`);

    // 使用 sh -c 执行脚本
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
