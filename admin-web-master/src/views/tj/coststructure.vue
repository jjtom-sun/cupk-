<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>成本构成分析</span>
          <div>
            <el-button type="primary" @click="loadData">查询</el-button>
            <el-button @click="exportExcel('成本构成')">导出</el-button>
          </div>
        </div>
      </template>
      <el-form :inline="true">
        <el-form-item label="起始日期">
          <el-date-picker v-model="起始日期" type="date" value-format="YYYY-MM-DD" style="width:160px" />
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker v-model="结束日期" type="date" value-format="YYYY-MM-DD" style="width:160px" />
        </el-form-item>
      </el-form>

      <el-row :gutter="20">
        <el-col :span="14">
          <h4>各成本项占比</h4>
          <v-chart :option="pieOption" autoresize style="height: 380px" />
        </el-col>
        <el-col :span="10">
          <h4>各成本项金额（¥）</h4>
          <v-chart :option="barOption" autoresize style="height: 380px" />
        </el-col>
      </el-row>

      <h4 style="margin-top:20px">明细表</h4>
      <el-table :data="list" border stripe>
        <el-table-column prop="预算单位" label="预算单位" width="120" />
        <el-table-column prop="材料费" label="材料费" align="right" />
        <el-table-column prop="人工费" label="人工费" align="right" />
        <el-table-column prop="设备费" label="设备费" align="right" />
        <el-table-column prop="其它费用" label="其它费用" align="right" />
        <el-table-column prop="总成本" label="总成本" align="right" />
        <el-table-column label="材料占比">
          <template #default="{ row }">{{ ((row.材料费 / row.总成本) * 100 || 0).toFixed(1) }}%</template>
        </el-table-column>
        <el-table-column label="人工占比">
          <template #default="{ row }">{{ ((row.人工费 / row.总成本) * 100 || 0).toFixed(1) }}%</template>
        </el-table-column>
        <el-table-column label="设备占比">
          <template #default="{ row }">{{ ((row.设备费 / row.总成本) * 100 || 0).toFixed(1) }}%</template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, BarChart } from 'echarts/charts'
import { TooltipComponent, LegendComponent, TitleComponent, GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { fetchCostStructure } from '@/apis/zyxt'

use([CanvasRenderer, PieChart, BarChart, TooltipComponent, LegendComponent, TitleComponent, GridComponent])

const list = ref<any[]>([])
const 起始日期 = ref('2018-01-01')
const 结束日期 = ref('2018-12-31')

const totals = computed(() => {
  const t = { 材料费: 0, 人工费: 0, 设备费: 0, 其它费用: 0 }
  list.value.forEach((r: any) => {
    t.材料费 += r.材料费 || 0
    t.人工费 += r.人工费 || 0
    t.设备费 += r.设备费 || 0
    t.其它费用 += r.其它费用 || 0
  })
  return t
})

const pieOption = computed(() => ({
  tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
  legend: { bottom: 10 },
  series: [{
    type: 'pie',
    radius: ['40%', '70%'],
    data: [
      { name: '材料费', value: totals.value.材料费, itemStyle: { color: '#409eff' } },
      { name: '人工费', value: totals.value.人工费, itemStyle: { color: '#67c23a' } },
      { name: '设备费', value: totals.value.设备费, itemStyle: { color: '#e6a23c' } },
      { name: '其它费用', value: totals.value.其它费用, itemStyle: { color: '#f56c6c' } }
    ]
  }]
}))

const barOption = computed(() => ({
  tooltip: { trigger: 'axis' },
  grid: { top: 30, left: 60, right: 30, bottom: 30 },
  xAxis: { type: 'category', data: ['材料费','人工费','设备费','其它费用'] },
  yAxis: { type: 'value' },
  series: [{
    type: 'bar',
    data: [totals.value.材料费, totals.value.人工费, totals.value.设备费, totals.value.其它费用],
    itemStyle: { color: '#409eff' },
    label: { show: true, position: 'top' }
  }]
}))

const loadData = async () => {
  const res: any = await fetchCostStructure({ 起始日期: 起始日期.value, 结束日期: 结束日期.value })
  if (res.code === 200) list.value = res.data
}

const exportExcel = (name: string) => {
  if (!list.value.length) return ElMessage.warning('无数据')
  const headers = Object.keys(list.value[0])
  const rows = list.value.map(r => headers.map(h => r[h] ?? ''))
  const csv = [headers.join(','), ...rows.map(r => r.map((c: any) => `"${String(c).replace(/"/g,'""')}"`).join(','))].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob); a.download = `${name}_${Date.now()}.csv`; a.click()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
h4 { margin: 12px 0; }
</style>
