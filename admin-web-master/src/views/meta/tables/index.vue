<template>
  <div class="app-container">
    <!-- 概览卡片 -->
    <el-row :gutter="16" class="overview-row">
      <el-col :span="4">
        <el-card shadow="hover" class="stat-card stat-blue">
          <div class="stat-label"><el-icon><Grid /></el-icon> 数据表数量</div>
          <div class="stat-value">{{ overview.tableCount ?? '-' }}</div>
        </el-card>
      </el-col>
      <el-col :span="5">
        <el-card shadow="hover" class="stat-card stat-green">
          <div class="stat-label"><el-icon><Document /></el-icon> 字段总数</div>
          <div class="stat-value">{{ overview.columnCount ?? '-' }}</div>
        </el-card>
      </el-col>
      <el-col :span="5">
        <el-card shadow="hover" class="stat-card stat-orange">
          <div class="stat-label"><el-icon><DataLine /></el-icon> 总记录数</div>
          <div class="stat-value">{{ (overview.totalRows ?? 0).toLocaleString() }}</div>
        </el-card>
      </el-col>
      <el-col :span="5">
        <el-card shadow="hover" class="stat-card stat-purple">
          <div class="stat-label"><el-icon><Coin /></el-icon> 占用空间 (MB)</div>
          <div class="stat-value">{{ (overview.totalSizeMb ?? 0).toFixed(2) }}</div>
        </el-card>
      </el-col>
      <el-col :span="5">
        <el-card shadow="hover" class="stat-card stat-red">
          <div class="stat-label"><el-icon><Key /></el-icon> 主键 / 外键</div>
          <div class="stat-value">{{ overview.pkCount ?? 0 }} / {{ overview.fkCount ?? 0 }}</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区 -->
    <el-row :gutter="16" style="margin-top: 16px;">
      <el-col :span="14">
        <el-card shadow="hover" v-loading="loading">
          <template #header>
            <span><el-icon><TrendCharts /></el-icon> 表行数排行（Top 10）</span>
          </template>
          <div ref="barChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :span="10">
        <el-card shadow="hover" v-loading="loading">
          <template #header>
            <span><el-icon><PieChart /></el-icon> 表空间占比</span>
          </template>
          <div ref="pieChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 表详情列表 -->
    <el-card shadow="hover" style="margin-top: 16px;" v-loading="loading">
      <template #header>
        <div class="card-header">
          <span><el-icon><Files /></el-icon> 表结构详情（点击展开查看字段）</span>
          <el-input v-model="filterText" placeholder="按表名筛选..." style="width: 240px;" clearable />
        </div>
      </template>
      <el-table :data="filteredTables" border stripe row-key="tableName" @expand-change="handleExpand">
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-table :data="columnsMap[row.tableName] || []" size="small" border>
              <el-table-column type="index" label="#" width="60" />
              <el-table-column prop="columnName" label="字段名" min-width="160" />
              <el-table-column prop="dataType" label="类型" min-width="140">
                <template #default="{ row: c }">
                  <el-tag size="small" effect="plain">{{ c.dataType }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="maxLength" label="长度" width="80" align="center" />
              <el-table-column prop="isNullable" label="可空" width="80" align="center">
                <template #default="{ row: c }">
                  <el-tag :type="c.isNullable ? 'warning' : 'success'" size="small">
                    {{ c.isNullable ? 'YES' : 'NO' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="isIdentity" label="自增" width="70" align="center">
                <template #default="{ row: c }">
                  <el-tag v-if="c.isIdentity" type="success" size="small">是</el-tag>
                  <span v-else>-</span>
                </template>
              </el-table-column>
              <el-table-column prop="defaultValue" label="默认值" min-width="160">
                <template #default="{ row: c }">
                  <code v-if="c.defaultValue" class="code-text">{{ c.defaultValue }}</code>
                  <span v-else>-</span>
                </template>
              </el-table-column>
            </el-table>
            <div v-if="!columnsMap[row.tableName]?.length" style="text-align: center; color: #999; padding: 12px;">
              加载字段中...
            </div>
          </template>
        </el-table-column>
        <el-table-column type="index" label="#" width="60" />
        <el-table-column prop="tableName" label="表名" min-width="200">
          <template #default="{ row }">
            <el-icon style="color: #409eff; margin-right: 4px;"><Coin /></el-icon>
            <strong>{{ row.tableName }}</strong>
          </template>
        </el-table-column>
        <el-table-column prop="rowCount" label="行数" width="140" align="right" sortable>
          <template #default="{ row }">
            <span :class="['row-count', getCountClass(row.rowCount)]">{{ row.rowCount.toLocaleString() }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="sizeMb" label="大小 (MB)" width="160" align="right" sortable>
          <template #default="{ row }">
            <el-progress :percentage="getSizePercent(row.sizeMb)" :stroke-width="14" :format="() => row.sizeMb.toFixed(2)" />
          </template>
        </el-table-column>
        <el-table-column label="行数条形图" min-width="200">
          <template #default="{ row }">
            <div class="row-bar" :style="{ width: getRowBarWidth(row.rowCount) + '%' }"></div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, computed, nextTick } from 'vue'
import * as echarts from 'echarts'
import { fetchMetaTables, fetchMetaTableDetail, fetchMetaOverview } from '@/apis/zyxt'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tables = ref<any[]>([])
const overview = ref<any>({})
const columnsMap = ref<Record<string, any[]>>({})
const filterText = ref('')
const barChartRef = ref<HTMLDivElement>()
const pieChartRef = ref<HTMLDivElement>()
let barChart: echarts.ECharts | null = null
let pieChart: echarts.ECharts | null = null

const filteredTables = computed(() => {
  if (!filterText.value) return tables.value
  return tables.value.filter((t) => t.tableName.toLowerCase().includes(filterText.value.toLowerCase()))
})

const maxRows = computed(() => Math.max(1, ...tables.value.map((t) => t.rowCount || 0)))
const maxSize = computed(() => Math.max(1, ...tables.value.map((t) => t.sizeMb || 0)))

const getCountClass = (n: number) => (n > 1000 ? 'count-high' : n > 0 ? 'count-mid' : 'count-zero')
const getSizePercent = (s: number) => Math.min(100, Math.round((s / Math.max(maxSize.value, 0.01)) * 100))
const getRowBarWidth = (n: number) => Math.max(2, Math.round((n / maxRows.value) * 100))

const loadData = async () => {
  loading.value = true
  try {
    const [tablesRes, overviewRes]: any = await Promise.all([fetchMetaTables(), fetchMetaOverview()])
    if (tablesRes.code === 200) tables.value = tablesRes.data
    if (overviewRes.code === 200) overview.value = overviewRes.data
    await nextTick()
    renderCharts()
  } catch (e: any) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

const handleExpand = async (row: any) => {
  if (columnsMap.value[row.tableName]) return
  try {
    const res: any = await fetchMetaTableDetail(row.tableName)
    if (res.code === 200) columnsMap.value[row.tableName] = res.data
    else ElMessage.error(res.message || '加载字段失败')
  } catch (e: any) {
    ElMessage.error(e.message || '加载字段失败')
  }
}

const renderCharts = () => {
  // 柱状图：行数排行 Top 10
  if (barChartRef.value) {
    if (!barChart) barChart = echarts.init(barChartRef.value)
    const top = [...tables.value].sort((a, b) => b.rowCount - a.rowCount).slice(0, 10)
    barChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: 100, right: 30, top: 20, bottom: 30 },
      xAxis: { type: 'value' },
      yAxis: { type: 'category', data: top.map((t) => t.tableName).reverse() },
      series: [
        {
          type: 'bar',
          data: top.map((t) => t.rowCount).reverse(),
          itemStyle: {
            color: (p: any) => {
              const colors = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de']
              return colors[p.dataIndex % colors.length]
            },
            borderRadius: [0, 4, 4, 0],
          },
          label: { show: true, position: 'right', formatter: (p: any) => p.value.toLocaleString() },
        },
      ],
    })
  }
  // 饼图：空间占比
  if (pieChartRef.value) {
    if (!pieChart) pieChart = echarts.init(pieChartRef.value)
    const data = tables.value
      .filter((t) => t.sizeMb > 0)
      .map((t) => ({ name: t.tableName, value: Number(t.sizeMb.toFixed(2)) }))
    pieChart.setOption({
      tooltip: { trigger: 'item', formatter: '{b}: {c} MB ({d}%)' },
      legend: { type: 'scroll', orient: 'vertical', right: 10, top: 20, bottom: 20 },
      series: [
        {
          type: 'pie',
          radius: ['35%', '65%'],
          center: ['38%', '50%'],
          avoidLabelOverlap: true,
          itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
          label: { show: false },
          emphasis: { label: { show: true, fontSize: 14, fontWeight: 600 } },
          data,
        },
      ],
    })
  }
}

const handleResize = () => {
  barChart?.resize()
  pieChart?.resize()
}

onMounted(() => {
  loadData()
  window.addEventListener('resize', handleResize)
})
onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  barChart?.dispose()
  pieChart?.dispose()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.overview-row { margin-bottom: 0; }
.stat-card { transition: transform 0.2s; }
.stat-card:hover { transform: translateY(-3px); }
.stat-label { color: #909399; font-size: 13px; display: flex; align-items: center; gap: 4px; }
.stat-value { font-size: 26px; font-weight: 700; margin-top: 8px; color: #303133; }
.stat-blue .stat-value { color: #409eff; }
.stat-green .stat-value { color: #67c23a; }
.stat-orange .stat-value { color: #e6a23c; }
.stat-purple .stat-value { color: #909399; }
.stat-red .stat-value { color: #f56c6c; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.chart-container { width: 100%; height: 360px; }
.row-bar {
  height: 14px;
  background: linear-gradient(90deg, #409eff, #67c23a);
  border-radius: 7px;
  transition: width 0.3s;
}
.row-count { font-weight: 600; }
.count-high { color: #f56c6c; }
.count-mid { color: #e6a23c; }
.count-zero { color: #c0c4cc; }
.code-text {
  background: #f5f7fa;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
  color: #d63384;
}
</style>
