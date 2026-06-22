<template>
  <div class="app-container">
    <header class="app-header">
      <div class="brand-lockup">
        <img class="app-logo" src="/logo.png" alt="" aria-hidden="true" />
        <div class="brand-copy">
          <h1>代理控制器</h1>
          <p class="subtitle">Clash Verge 代理一键管理</p>
        </div>
      </div>
    </header>

    <main class="app-main">
      <div v-if="loading" class="loading-state">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>加载中...</span>
      </div>

      <div v-else-if="services.length === 0" class="empty-state">
        <p>暂无代理服务配置</p>
        <p class="hint">请编辑配置文件添加代理服务</p>
      </div>

      <div v-else class="services-grid">
        <ProxyCard
          v-for="service in services"
          :key="service.id"
          :service="service"
          @update="handleServiceUpdate"
        />
      </div>
    </main>

    <footer class="app-footer">
      <el-button text size="small" @click="refreshServices">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
      <span class="footer-hint">
        配置文件: ~/.config/proxy-controller/services.json
      </span>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { Loading, Refresh } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";
import ProxyCard from "@/components/ProxyCard.vue";
import type { ProxyService } from "@/types";
import { loadServices } from "@/services/proxyService";

const services = ref<ProxyService[]>([]);
const loading = ref(true);

async function refreshServices() {
  loading.value = true;
  try {
    services.value = await loadServices();
  } catch (error) {
    ElMessage.error(`加载失败: ${error}`);
  } finally {
    loading.value = false;
  }
}

function handleServiceUpdate(updated: ProxyService) {
  const idx = services.value.findIndex((s) => s.id === updated.id);
  if (idx !== -1) {
    services.value[idx] = updated;
  }
}

onMounted(() => {
  refreshServices();
});
</script>

<style scoped>
.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--el-bg-color-page);
}

.app-header {
  padding: 24px 32px 16px;
  display: flex;
  justify-content: center;
  background: linear-gradient(
    180deg,
    var(--el-bg-color) 0%,
    var(--el-bg-color-page) 100%
  );
}

.brand-lockup {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  text-align: left;
}

.brand-copy {
  min-width: 0;
}

.app-logo {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  box-shadow: 0 10px 24px rgba(12, 30, 54, 0.14);
  flex: 0 0 auto;
}

.app-header h1 {
  margin: 0 0 6px 0;
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
}

.subtitle {
  margin: 0;
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.app-main {
  flex: 1;
  padding: 16px 32px;
  overflow-y: auto;
}

.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 20px;
  color: var(--el-text-color-secondary);
}

.loading-state .el-icon {
  font-size: 32px;
  margin-bottom: 12px;
}

.empty-state .hint {
  font-size: 13px;
  margin-top: 8px;
  opacity: 0.7;
}

.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
  max-width: 800px;
  margin: 0 auto;
}

.app-footer {
  padding: 12px 32px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid var(--el-border-color-lighter);
  background: var(--el-bg-color);
}

.footer-hint {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  font-family: monospace;
}

@media (max-width: 520px) {
  .app-header {
    padding: 20px 20px 14px;
  }

  .app-logo {
    width: 50px;
    height: 50px;
    border-radius: 13px;
  }
}
</style>
