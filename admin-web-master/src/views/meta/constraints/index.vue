<template>
  <div class="app-container">
    <el-tabs v-model="activeTab" class="meta-tabs">
      <!-- 外键关系图 -->
      <el-tab-pane name="fk">
        <template #label>
          <span class="tab-label">
            <el-icon><Connection /></el-icon> 外键约束
            <el-tag type="danger" size="small" round class="tab-badge">{{ constraints.foreignKey?.length || 0 }}</el-tag>
          </span>
        </template>
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span><el-icon><Connection /></el-icon> 表外键关系图</span>
              <el-tag size="small">节点=表，连线=外键引用</el-tag>
            </div>
          </template>
          <div ref="fkChartRef" class="chart-container" v-loading="loading"></div>
        </el-card>
        <el-card shadow="hover" style="margin-top: 16px;">
          <template #header>
            <span><el-icon><List /></el-icon> 外键约束列表</span>
          </template>
          <el-table :data="constraints.foreignKey || []" border stripe size="default">
            <el-table-column type="index" label="#" width="60" />
            <el-table-column prop="constraintName" label="约束名" min-width="200" />
            <el-table-column prop="tableName" label="所在表" min-width="150" />
            <el-table-column prop="columnName" label="外键列" min-width="150" />
            <el-table-column label="引用关系" min-width="300">
              <template #default="{ row }">
                <el-tag type="info" size="small">{{ row.referencedTable }}.{{ row.referencedColumn }}</el-tag>
                <el-icon style="margin: 0 8px;"><Right /></el-icon>
                <el-tag type="warning" size="small">{{ row.tableName }}.{{ row.columnName }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 主键约束 -->
      <el-tab-pane name="pk">
        <template #label>
          <span class="tab-label">
            <el-icon><Key /></el-icon> 主键约束
            <el-tag type="success" size="small" round class="tab-badge">{{ constraints.primaryKey?.length || 0 }}</el-tag>
          </span>
        </template>
        <el-card shadow="hover">
          <el-table :data="constraints.primaryKey || []" border stripe>
            <el-table-column type="index" label="#" width="60" />
            <el-table-column prop="constraintName" label="主键约束名" min-width="220" />
            <el-table-column prop="tableName" label="所在表" min-width="200">
              <template #default="{ row }">
                <el-tag type="primary" size="small">{{ row.tableName }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="columnName" label="主键列" min-width="220" />
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 唯一约束 -->
      <el-tab-pane name="uq">
        <template #label>
          <span class="tab-label">
            <el-icon><Lock /></el-icon> 唯一约束
            <el-tag type="warning" size="small" round class="tab-badge">{{ constraints.unique?.length || 0 }}</el-tag>
          </span>
        </template>
        <el-card shadow="hover">
          <el-table :data="constraints.unique || []" border stripe>
            <el-table-column type="index" label="#" width="60" />
            <el-table-column prop="constraintName" label="唯一约束名" min-width="220" />
            <el-table-column prop="tableName" label="所在表" min-width="200">
              <template #default="{ row }">
                <el-tag type="primary" size="small">{{ row.tableName }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="columnName" label="唯一列" min-width="220" />
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 检查约束 -->
      <el-tab-pane name="ck">
        <template #label>
          <span class="tab-label">
            <el-icon><CircleCheck /></el-icon> 检查约束
            <el-tag type="info" size="small" round class="tab-badge">{{ constraints.check?.length || 0 }}</el-tag>
          </span>
        </template>
        <el-card shadow="hover">
          <el-table :data="constraints.check || []" border stripe>
            <el-table-column type="index" label="#" width="60" />
            <el-table-column prop="constraintName" label="检查约束名" min-width="200" />
            <el-table-column prop="tableName" label="所在表" min-width="180">
              <template #default="{ row }">
                <el-tag type="primary" size="small">{{ row.tableName }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="definitionText" label="约束表达式" min-width="300">
              <template #default="{ row }">
                <code class="code-text">{{ row.definitionText }}</code>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <!-- 默认约束 -->
      <el-tab-pane name="df">
        <template #label>
          <span class="tab-label">
            <el-icon><Document /></el-icon> 默认约束
            <el-tag size="small" round class="tab-badge">{{ constraints.default?.length || 0 }}</el-tag>
          </span>
        </template>
        <el-card shadow="hover">
          <el-table :data="constraints.default || []" border stripe>
            <el-table-column type="index" label="#" width="60" />
            <el-table-column prop="constraintName" label="默认约束名" min-width="200" />
            <el-table-column prop="tableName" label="所在表" min-width="180">
              <template #default="{ row }">
                <el-tag type="primary" size="small">{{ row.tableName }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="columnName" label="默认列" min-width="180" />
            <el-table-column prop="definitionText" label="默认值" min-width="200">
              <template #default="{ row }">
                <code class="code-text">{{ row.definitionText }}</code>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch, nextTick } from 'vue'
import * as echarts from 'echarts'
import { fetchMetaConstraints } from '@/apis/zyxt'
import { ElMessage } from 'element-plus'

const activeTab = ref('fk')
const loading = ref(false)
const constraints = ref<any>({
  primaryKey: [],
  foreignKey: [],
  unique: [],
  check: [],
  default: [],
})

const fkChartRef = ref<HTMLDivElement>()
let fkChart: echarts.ECharts | null = null

const loadConstraints = async () => {
  loading.value = true
  try {
    const res: any = await fetchMetaConstraints()
    if (res.code === 200) {
      constraints.value = res.data
      await nextTick()
      renderFkChart()
    } else {
      ElMessage.error(res.message || '加载失败')
    }
  } catch (e: any) {
    ElMessage.error(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

const buildColorByTable = (tables: string[]) => {
  const palette = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc']
  const map: Record<string, string> = {}
  tables.forEach((t, i) => { map[t] = palette[i % palette.length] })
  return map
}

const renderFkChart = () => {
  if (!fkChartRef.value) return
  const fkList = constraints.value.foreignKey || []
  if (!fkList.length) {
    fkChartRef.value.innerHTML = '<div style="text-align:center;color:#909399;padding:60px 0;">暂无外键约束</div>'
    return
  }
  if (!fkChart) fkChart = echarts.init(fkChartRef.value)
  const tableSet = new Set<string>()
  fkList.forEach((it: any) => {
    tableSet.add(it.tableName)
    tableSet.add(it.referencedTable)
  })
  const tables = Array.from(tableSet)
  const colorMap = buildColorByTable(tables)
  const nodes = tables.map((t) => ({
    id: t,
    name: t,
    symbolSize: 60,
    itemStyle: { color: colorMap[t] },
    label: { show: true, fontSize: 13, fontWeight: 600 },
  }))
  const links = fkList.map((it: any) => ({
    source: it.referencedTable,
    target: it.tableName,
    label: { show: true, formatter: it.columnName, fontSize: 11 },
    lineStyle: { color: '#aaa', curveness: 0.15 },
  }))
  fkChart.setOption({
    tooltip: {
      formatter: (p: any) => {
        if (p.dataType === 'edge') {
          return `${p.data.source} → ${p.data.target}<br/>外键列: ${p.data.label?.formatter || ''}`
        }
        return `表: <b>${p.name}</b>`
      },
    },
    legend: { data: tables, bottom: 10, type: 'scroll' },
    series: [
      {
        type: 'graph',
        layout: 'force',
        roam: true,
        draggable: true,
        animation: true,
        data: nodes,
        links,
        force: { repulsion: 400, edgeLength: 180 },
        emphasis: { focus: 'adjacency', lineStyle: { width: 4 } },
      },
    ],
  })
}

const handleResize = () => fkChart?.resize()

watch(activeTab, (v) => {
  if (v === 'fk') nextTick(renderFkChart)
})

onMounted(() => {
  loadConstraints()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  fkChart?.dispose()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.meta-tabs { background: #fff; padding: 16px; border-radius: 4px; }
.tab-label { display: inline-flex; align-items: center; gap: 4px; }
.tab-badge { margin-left: 4px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.chart-container { width: 100%; height: 520px; }
.code-text {
  background: #f5f7fa;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
  color: #d63384;
}
</style>
