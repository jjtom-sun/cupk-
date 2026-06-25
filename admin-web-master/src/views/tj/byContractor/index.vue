<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>按施工单位统计</span>
        </div>
      </template>
      <el-table :data="list" border stripe>
        <el-table-column prop="施工单位" label="施工单位" />
        <el-table-column prop="项目数" label="项目数" width="100" />
        <el-table-column prop="结算总额" label="结算总额" width="150">
          <template #default="{ row }">¥{{ formatNumber(row.结算总额) }}</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchByContractor } from '@/apis/zyxt'

const list = ref<any[]>([])
const formatNumber = (num: number) => num?.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) || '0.00'

onMounted(async () => {
  const res: any = await fetchByContractor()
  if (res.code === 200) list.value = res.data
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
