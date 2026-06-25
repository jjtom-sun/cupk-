<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>施工单位月度结算统计（自动生成月度结算表）</span>
          <div>
            <el-button type="primary" @click="loadData">查询</el-button>
            <el-button @click="exportExcel">导出</el-button>
          </div>
        </div>
      </template>
      <el-form :inline="true">
        <el-form-item label="年份">
          <el-input-number v-model="年份" :min="2000" :max="2099" controls-position="right" style="width:120px" />
        </el-form-item>
      </el-form>
      <v-chart :option="lineOption" autoresize style="height: 400px" />
      <h4>明细</h4>
      <el-table :data="list" border stripe>
        <el-table-column prop="年" label="年" width="60" />
        <el-table-column prop="月" label="月" width="60" />
        <el-table-column prop="预算单位" label="预算单位" width="120" />
        <el-table-column prop="项目数" label="项目数" width="80" align="right" />
        <el-table-column prop="预算总额" label="预算总额" align="right" />
        <el-table-column prop="结算总额" label="结算总额" align="right" />
        <el-table-column prop="入账总额" label="入账总额" align="right" />
        <el-table-column prop="差额" label="差额" align="right" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { TooltipComponent, LegendComponent, TitleComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { ElMessage } from 'element-plus'
import { fetchMonthly } from '@/apis/zyxt'

use([CanvasRenderer, LineChart, TooltipComponent, LegendComponent, TitleComponent, GridComponent])

const 年份 = ref(2018)
const list = ref<any[]>([])

const lineOption = computed(() => {
  const months = Array.from({ length: 12 }, (_, i) => `${i + 1}月`)
  const groups: any = {}
  list.value.forEach((r: any) => {
    const k = r.预算单位
    groups[k] = groups[k] || new Array(12).fill(0)
    groups[k][(r.月 || 1) - 1] = r.结算总额
  })
  return {
    tooltip: { trigger: 'axis' },
    legend: { top: 10 },
    grid: { top: 50, left: 60, right: 30, bottom: 30 },
    xAxis: { type: 'category', data: months },
    yAxis: { type: 'value', name: '结算金额（¥）' },
    series: Object.entries(groups).map(([k, v]: any) => ({ name: k, type: 'line', data: v, smooth: true }))
  }
})

const loadData = async () => {
  const res: any = await fetchMonthly({ 年份: 年份.value })
  if (res.code === 200) list.value = res.data
}

const exportExcel = () => {
  if (!list.value.length) return ElMessage.warning('无数据')
  const headers = Object.keys(list.value[0])
  const rows = list.value.map(r => headers.map(h => r[h] ?? ''))
  const csv = [headers.join(','), ...rows.map(r => r.map((c: any) => `"${String(c).replace(/"/g,'""')}"`).join(','))].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob); a.download = `月度结算表_${年份.value}.csv`; a.click()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
h4 { margin: 12px 0; }
</style>
