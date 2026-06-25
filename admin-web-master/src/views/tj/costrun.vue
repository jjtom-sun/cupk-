<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>多级单位成本运行情况</span>
          <div>
            <el-button type="primary" @click="loadData">刷新</el-button>
            <el-button @click="exportExcel('多级单位成本运行情况')">导出</el-button>
          </div>
        </div>
      </template>
      <el-form :inline="true">
        <el-form-item label="单位代码">
          <el-input v-model="单位代码" placeholder="如：112201001" style="width:180px" clearable />
        </el-form-item>
        <el-form-item label="起始日期">
          <el-date-picker v-model="起始日期" type="date" value-format="YYYY-MM-DD" style="width:160px" />
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker v-model="结束日期" type="date" value-format="YYYY-MM-DD" style="width:160px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">调用存储过程查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="list" border stripe>
        <el-table-column prop="单位代码" label="单位代码" width="120" />
        <el-table-column prop="单位名称" label="单位名称" />
        <el-table-column prop="项目数" label="项目数" width="80" align="right" />
        <el-table-column prop="预算总额" label="预算总额" width="120" align="right" />
        <el-table-column prop="结算总额" label="结算总额" width="120" align="right" />
        <el-table-column prop="入账总额" label="入账总额" width="120" align="right" />
        <el-table-column prop="未结算金额" label="未结算金额" width="120" align="right" />
        <el-table-column prop="未入账金额" label="未入账金额" width="120" align="right" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { fetchCostRun, fetchCostRunProc } from '@/apis/zyxt'

const list = ref<any[]>([])
const 单位代码 = ref('')
const 起始日期 = ref('2018-01-01')
const 结束日期 = ref('2018-12-31')

const loadData = async () => {
  if (单位代码.value) {
    const res: any = await fetchCostRunProc({ 单位代码: 单位代码.value, 起始日期: 起始日期.value, 结束日期: 结束日期.value })
    if (res.code === 200) {
      list.value = res.data
      ElMessage.success(`存储过程返回 ${res.data.length} 条`)
    }
  } else {
    const res: any = await fetchCostRun()
    if (res.code === 200) list.value = res.data
  }
}

const exportExcel = (name: string) => {
  if (!list.value.length) return ElMessage.warning('无数据可导出')
  const headers = Object.keys(list.value[0])
  const rows = list.value.map(r => headers.map(h => r[h] ?? ''))
  const csv = [headers.join(','), ...rows.map(r => r.map((c: any) => `"${String(c).replace(/"/g,'""')}"`).join(','))].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob)
  a.download = `${name}_${Date.now()}.csv`
  a.click()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
