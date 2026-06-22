/**
 * 代理服务配置
 */
export interface ProxyService {
  /** 唯一标识 */
  id: string;
  /** 显示名称 */
  name: string;
  /** 图标（emoji 或图片路径） */
  icon: string;
  /** 分类 */
  category?: string;
  /** 控制脚本路径 */
  scriptPath: string;
  /** 当前是否启用 */
  enabled: boolean;
}

/**
 * 配置文件结构
 */
export interface ProxyConfig {
  services: ProxyService[];
}
