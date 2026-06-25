<template>
  <div class="app-container">
    <el-tabs v-model="active">
      <el-tab-pane label="按项目汇总" name="p">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>按项目汇总材料费</span>
              <div>
                <el-button type="primary" @click="loadP">刷新</el-button>
                <el-button @click="exportP">导出</el-button>
              </div>
            </div>
          </template>
          <el-table :data="pList" border stripe>
            <el-table-column prop="单据号" label="单据号" width="120" />
            <el-table-column prop="预算单位" label="预算单位" width="120" />
            <el-table-column prop="井号" label="井号" width="80" />
            <el-table-column prop="施工单位" label="施工单位" width="160" />
            <el-table-column prop="物料种数" label="物料种数" align="right" />
            <el-table-column prop="材料费合计" label="材料费合计" align="right" />
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="按物料汇总" name="m">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>按物料汇总消耗（反查项目支撑）</span>
              <div>
                <el-button type="primary" @click="loadM">刷新</el-button>
                <el-button @click="exportM">导出</el-button>
              </div>
            </div>
          </template>
          <el-table :data="mList" border stripe @row-click="rowClick" :row-style="{cursor:'pointer'}">
            <el-table-column prop="物码" label="物码" width="100" />
            <el-table-column prop="名称规格" label="名称规格" />
            <el-table-column prop="计量单位" label="单位" width="80" />
            <el-table-column prop="消耗总量" label="消耗总量" align="right" />
            <el-table-column prop="平均单价" label="平均单价" align="right" />
            <el-table-column prop="总金额" label="总金额" align="right" />
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button type="primary" size="small" @click.stop="viewProjects(row)">消耗项目</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="反查：物料→项目" name="r">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>按物料反查项目</span>
            </div>
          </template>
          <el-form :inline="true">
            <el-form-item label="选择物料">
              <el-select v-model="selWM" filterable style="width:240px">
                <el-option v-for="w in wmOpts" :key="w.物码" :label="`${w.物码} ${w.名称规格}`" :value="w.物码" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadReverse">查询</el-button>
            </el-form-item>
          </el-form>
          <el-table :data="rList" border stripe>
            <el-table-column prop="单据号" label="单据号" width="120" />
            <el-table-column prop="井号" label="井号" width="80" />
            <el-table-column prop="名称规格" label="材料" />
            <el-table-column prop="消耗数量" label="数量" align="right" />
            <el-table-column prop="单价" label="单价" align="right" />
            <el-table-column prop="金额" label="金额" align="right" />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { fetchClfAggregateByProject, fetchClfAggregateByMaterial, fetchClfProjectsOfMaterial, fetchWmList } from '@/apis/zyxt'

const active = ref('p')
const pList = ref<any[]>([])
const mList = ref<any[]>([])
const rList = ref<any[]>([])
const wmOpts = ref<any[]>([])
const selWM = ref('')

const loadP = async () => {
  const r: any = await fetchClfAggregateByProject()
  if (r.code === 200) pList.value = r.data
}
const loadM = async () => {
  const r: any = await fetchClfAggregateByMaterial()
  if (r.code === 200) mList.value = r.data
}
const viewProjects = async (row: any) => {
  selWM.value = row.物码
  active.value = 'r'
  await loadReverse()
}
const rowClick = (row: any) => viewProjects(row)
const loadReverse = async () => {
  if (!selWM.value) return ElMessage.warning('请选择物料')
  const r: any = await fetchClfProjectsOfMaterial(selWM.value)
  if (r.code === 200) rList.value = r.data
}

const exportExcel = (list: any[], name: string) => {
  if (!list.length) return ElMessage.warning('无数据')
  const headers = Object.keys(list[0])
  const rows = list.map(r => headers.map(h => r[h] ?? ''))
  const csv = [headers.join(','), ...rows.map(r => r.map((c: any) => `"${String(c).replace(/"/g,'""')}"`).join(','))].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv' })
  const a = document.createElement('a')
  a.href = URL.createObjectURL(blob); a.download = `${name}_${Date.now()}.csv`; a.click()
}
const exportP = () => exportExcel(pList.value, '材料费按项目汇总')
const exportM = () => exportExcel(mList.value, '材料费按物料汇总')

onMounted(async () => {
  loadP()
  loadM()
  const w: any = await fetchWmList()
  if (w.code === 200) wmOpts.value = w.data
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
