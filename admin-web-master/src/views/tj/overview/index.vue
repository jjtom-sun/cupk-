<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>数据概览</span>
        </div>
      </template>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="hover">
            <template #header><span>项目总数</span></template>
            <div class="stat-value">{{ summary.totalProjects }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <template #header><span>预算总额</span></template>
            <div class="stat-value">¥{{ formatNumber(summary.totalBudget) }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <template #header><span>结算总额</span></template>
            <div class="stat-value">¥{{ formatNumber(summary.totalSettlement) }}</div>
          </el-card>
        </el-col>
        <el-col :span="6">
          <el-card shadow="hover">
            <template #header><span>入账总额</span></template>
            <div class="stat-value">¥{{ formatNumber(summary.totalAccount) }}</div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchSummary } from '@/apis/zyxt'

const summary = ref({ totalProjects: 0, totalBudget: 0, totalSettlement: 0, totalAccount: 0 })

const formatNumber = (num: number) => num?.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) || '0.00'

onMounted(async () => {
  const res: any = await fetchSummary()
  if (res.code === 200 && res.data) summary.value = res.data
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.stat-value { font-size: 28px; font-weight: bold; color: #409eff; text-align: center; padding: 10px 0; }
</style>
