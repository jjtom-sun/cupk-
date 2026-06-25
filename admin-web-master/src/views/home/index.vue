<template>
  <div class="app-container">
    <el-row :gutter="14">
      <el-col :span="6" v-for="card in cards" :key="card.label">
        <el-card class="metric-card" :body-style="{padding:'16px'}">
          <div class="metric-label">{{ card.label }}</div>
          <div class="metric-value" :style="{color: card.color}">{{ card.value }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="14" style="margin-top:14px">
      <el-col :span="8">
        <el-card>
          <template #header>项目状态分布</template>
          <v-chart :option="statusPieOption" autoresize style="height: 320px" />
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>各单位预算占比</template>
          <v-chart :option="unitPieOption" autoresize style="height: 320px" />
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card>
          <template #header>月度成本趋势</template>
          <v-chart :option="trendOption" autoresize style="height: 320px" />
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="14" style="margin-top:14px">
      <el-col :span="14">
        <el-card>
          <template #header>项目状态流水</template>
          <el-table :data="statusTable" border>
            <el-table-column v-for="s in ['已预算','施工中','已完工','已结算','已入账']" :key="s" :label="s">
              <template #default>
                <el-tag>{{ counts[s] || 0 }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="10">
        <el-card>
          <template #header>预警信息</template>
          <el-alert :title="`超预算项目 ${overview.cntOverBudget || 0} 个`" :type="(overview.cntOverBudget||0)>0 ? 'error' : 'success'" :closable="false" show-icon style="margin-bottom:8px" />
          <el-alert title="已结算未入账 / 已完工未结算：见 异常项目 页面" type="warning" :closable="false" show-icon />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, LineChart } from 'echarts/charts'
import { TooltipComponent, LegendComponent, TitleComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { fetchDashOverview, fetchDashStatusPie, fetchDashUnitPie, fetchDashTrend } from '@/apis/zyxt'

use([CanvasRenderer, PieChart, LineChart, TooltipComponent, LegendComponent, TitleComponent, GridComponent])

const overview = ref<any>({})
const statusPie = ref<any[]>([])
const unitPie = ref<any[]>([])
const trend = ref<any[]>([])

const cards = computed(() => {
  const o = overview.value || {}
  const fmt = (n: number) => '¥' + (n || 0).toLocaleString('zh-CN')
  return [
    { label: '项目总数', value: o.totalProjects ?? 0, color: '#409eff' },
    { label: '总预算', value: fmt(o.totalBudget), color: '#67c23a' },
    { label: '总结算', value: fmt(o.totalSettlement), color: '#e6a23c' },
    { label: '总入账', value: fmt(o.totalAccount), color: '#f56c6c' },
    { label: '油水井', value: o.wellCount ?? 0, color: '#909399' },
    { label: '组织单位', value: o.unitCount ?? 0, color: '#909399' },
    { label: '施工单位', value: o.contractorCount ?? 0, color: '#909399' },
    { label: '物料种数', value: o.materialCount ?? 0, color: '#909399' }
  ]
})

const counts = computed(() => {
  const c: any = {}
  statusPie.value.forEach((it: any) => c[it.name] = it.value)
  return c
})

const statusTable = computed(() => statusPie.value.map((it: any) => ({ name: it.name, value: it.value })))

const statusPieOption = computed(() => ({
  tooltip: { trigger: 'item' },
  legend: { bottom: 10 },
  series: [{
    type: 'pie',
    radius: ['40%', '70%'],
    data: statusPie.value
  }]
}))

const unitPieOption = computed(() => ({
  tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
  legend: { bottom: 10 },
  series: [{
    type: 'pie',
    radius: '70%',
    data: unitPie.value
  }]
}))

const trendOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  legend: { top: 10 },
  grid: { top: 50, left: 60, right: 30, bottom: 30 },
  xAxis: { type: 'category', data: trend.value.map((t: any) => t.月份) },
  yAxis: { type: 'value', name: '金额' },
  series: [
    { name: '预算', type: 'line', data: trend.value.map((t: any) => t.预算), smooth: true },
    { name: '结算', type: 'line', data: trend.value.map((t: any) => t.结算), smooth: true },
    { name: '入账', type: 'line', data: trend.value.map((t: any) => t.入账), smooth: true }
  ]
}))

const load = async () => {
  const [o, sp, up, tr]: any[] = await Promise.all([
    fetchDashOverview(), fetchDashStatusPie(), fetchDashUnitPie(), fetchDashTrend()
  ])
  if (o.code === 200) overview.value = o.data
  if (sp.code === 200) statusPie.value = sp.data
  if (up.code === 200) unitPie.value = up.data
  if (tr.code === 200) trend.value = tr.data
}

onMounted(load)
</script>

<style scoped>
.app-container { padding: 20px; }
.metric-card { text-align: center; }
.metric-label { font-size: 13px; color: #909399; margin-bottom: 6px; }
.metric-value { font-size: 22px; font-weight: 700; }
</style>
