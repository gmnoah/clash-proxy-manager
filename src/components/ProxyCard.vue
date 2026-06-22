<template>
  <div class="proxy-card" :class="{ enabled: service.enabled }">
    <div class="card-icon">{{ service.icon }}</div>
    <div class="card-info">
      <h3 class="card-title">{{ service.name }}</h3>
      <p class="card-status">
        {{ service.enabled ? "已开启" : "已关闭" }}
      </p>
    </div>
    <el-switch
      v-model="localEnabled"
      :loading="loading"
      @change="handleToggle"
      size="large"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { ElMessage } from "element-plus";
import type { ProxyService } from "@/types";
import { toggleProxy } from "@/services/proxyService";

const props = defineProps<{
  service: ProxyService;
}>();

const emit = defineEmits<{
  (e: "update", service: ProxyService): void;
}>();

const localEnabled = ref(props.service.enabled);
const loading = ref(false);

watch(
  () => props.service.enabled,
  (val) => {
    localEnabled.value = val;
  }
);

async function handleToggle(val: boolean) {
  loading.value = true;
  try {
    const result = await toggleProxy(props.service, val);
    if (result.success) {
      ElMessage.success(`${props.service.name} 代理已${val ? "开启" : "关闭"}`);
      emit("update", { ...props.service, enabled: val });
    } else {
      localEnabled.value = !val;
      ElMessage.error(`切换失败: ${result.error || "未知错误"}`);
    }
  } catch (error) {
    localEnabled.value = !val;
    const errorMsg = error instanceof Error ? error.message : String(error);
    ElMessage.error(`执行出错: ${errorMsg}`);
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.proxy-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.proxy-card:hover {
  border-color: var(--el-color-primary);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.proxy-card.enabled {
  border-color: var(--el-color-success);
  background: linear-gradient(
    135deg,
    var(--el-bg-color) 0%,
    rgba(103, 194, 58, 0.05) 100%
  );
}

.card-icon {
  font-size: 40px;
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color-light);
  border-radius: 12px;
}

.card-info {
  flex: 1;
}

.card-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.card-status {
  margin: 0;
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.proxy-card.enabled .card-status {
  color: var(--el-color-success);
}
</style>
