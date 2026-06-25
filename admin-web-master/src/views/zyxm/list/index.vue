<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>作业项目综合查询（多条件）</span>
          <div>
            <el-button type="primary" @click="$router.push('/zyxm/add')">新增项目</el-button>
            <el-button @click="loadData">刷新</el-button>
          </div>
        </div>
      </template>
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="单据号">
          <el-input v-model="queryParams.单据号" placeholder="精确匹配" clearable style="width:130px" />
        </el-form-item>
        <el-form-item label="预算单位">
          <el-select v-model="queryParams.预算单位" placeholder="全部" clearable filterable style="width:160px">
            <el-option v-for="u in dwdmList" :key="u.单位代码" :label="u.单位名称" :value="u.单位代码" />
          </el-select>
        </el-form-item>
        <el-form-item label="井号">
          <el-input v-model="queryParams.井号" placeholder="精确匹配" clearable style="width:110px" />
        </el-form-item>
        <el-form-item label="施工单位">
          <el-select v-model="queryParams.施工单位" placeholder="全部" clearable filterable style="width:180px">
            <el-option v-for="c in sgdwList" :key="c.施工单位名称" :label="c.施工单位名称" :value="c.施工单位名称" />
          </el-select>
        </el-form-item>
        <el-form-item label="项目状态">
          <el-select v-model="queryParams.项目状态" placeholder="全部" clearable style="width:120px">
            <el-option v-for="s in statusOptions" :key="s" :label="s" :value="s" />
          </el-select>
        </el-form-item>
        <el-form-item label="预算日期">
          <el-date-picker v-model="dateRange" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始" end-placeholder="结束" style="width:240px" />
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="queryParams.关键字" placeholder="单据号/井号/施工单位" clearable style="width:200px" />
        </el-form-item>
        <el-form-item>
          <el-checkbox v-model="queryParams.超支">仅看超支</el-checkbox>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="loadData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="list" border stripe :row-class-name="rowClass">
        <el-table-column type="index" label="#" width="50" />
        <el-table-column prop="项目状态" label="项目状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.项目状态)" size="small">{{ row.项目状态 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="单据号" label="单据号" width="120" />
        <el-table-column prop="预算单位" label="预算单位" width="110" />
        <el-table-column prop="井号" label="井号" width="80" />
        <el-table-column prop="施工内容" label="施工内容" min-width="120" show-overflow-tooltip />
        <el-table-column prop="施工单位" label="施工单位" width="140" show-overflow-tooltip />
        <el-table-column prop="预算金额" label="预算金额" width="110" align="right">
          <template #default="{ row }">¥{{ formatNumber(row.预算金额) }}</template>
        </el-table-column>
        <el-table-column prop="结算金额" label="结算金额" width="110" align="right">
          <template #default="{ row }">{{ row.结算金额 != null ? '¥' + formatNumber(row.结算金额) : '-' }}</template>
        </el-table-column>
        <el-table-column label="超支" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.超支" type="danger" size="small">⚠ 超支</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="预算日期" label="预算日期" width="110" />
        <el-table-column prop="入账人" label="入账人" width="80" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="$router.push({ path: '/zyxm/update', query: { id: row.单据号 } })">编辑</el-button>
            <el-button type="success" size="small" @click="openStatusDialog(row)">流程</el-button>
            <el-button type="warning" size="small" @click="openClfDialog(row)">材料</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 状态流转 -->
    <el-dialog v-model="statusDialog" :title="`流程推进 - ${currentRow.单据号}`" width="600px">
      <el-steps :active="stepIndex" finish-status="success" simple>
        <el-step v-for="s in statusOptions" :key="s" :title="s" />
      </el-steps>
      <el-form :model="statusForm" label-width="120px" style="margin-top:20px">
        <el-form-item label="目标状态">
          <el-select v-model="statusForm.项目状态" style="width:200px">
            <el-option v-for="s in statusOptions" :key="s" :label="s" :value="s" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="needDate('开工日期')" label="开工日期">
          <el-date-picker v-model="statusForm.开工日期" type="date" value-format="YYYY-MM-DD" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needDate('完工日期')" label="完工日期">
          <el-date-picker v-model="statusForm.完工日期" type="date" value-format="YYYY-MM-DD" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needField('结算金额')" label="结算金额">
          <el-input-number v-model="statusForm.结算金额" :precision="2" :min="0" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needField('结算人')" label="结算人">
          <el-input v-model="statusForm.结算人" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needDate('结算日期')" label="结算日期">
          <el-date-picker v-model="statusForm.结算日期" type="date" value-format="YYYY-MM-DD" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needField('入账金额')" label="入账金额">
          <el-input-number v-model="statusForm.入账金额" :precision="2" :min="0" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needField('入账人')" label="入账人">
          <el-input v-model="statusForm.入账人" style="width:200px" />
        </el-form-item>
        <el-form-item v-if="needDate('入账日期')" label="入账日期">
          <el-date-picker v-model="statusForm.入账日期" type="date" value-format="YYYY-MM-DD" style="width:200px" />
        </el-form-item>
        <el-alert v-if="statusForm.结算金额 && currentRow.预算金额 && statusForm.结算金额 > currentRow.预算金额" type="error" :closable="false" show-icon
          :title="`⚠ 预算超支：结算 ${statusForm.结算金额} > 预算 ${currentRow.预算金额}，差额 ${(statusForm.结算金额 - currentRow.预算金额).toFixed(2)}`" />
      </el-form>
      <template #footer>
        <el-button @click="statusDialog=false">取消</el-button>
        <el-button type="primary" @click="submitStatus">保存</el-button>
      </template>
    </el-dialog>

    <!-- 材料明细 -->
    <el-dialog v-model="clfDialog" :title="`项目材料明细 - ${currentRow.单据号}`" width="900px">
      <el-button type="primary" size="small" @click="openAddClf">新增材料</el-button>
      <el-table :data="clfList" border stripe style="margin-top:10px">
        <el-table-column prop="物码" label="物码" width="100" />
        <el-table-column prop="名称规格" label="材料" />
        <el-table-column prop="计量单位" label="单位" width="80" />
        <el-table-column prop="消耗数量" label="数量" width="80" />
        <el-table-column prop="单价" label="单价" width="100" />
        <el-table-column prop="金额" label="金额" width="110" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="deleteClf(row)">删</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-row style="margin-top:10px" :gutter="20">
        <el-col :span="12">合计材料费：<b>¥{{ formatNumber(clfTotal) }}</b></el-col>
      </el-row>
    </el-dialog>

    <!-- 材料费新增 -->
    <el-dialog v-model="addClfDialog" title="新增材料" width="500px">
      <el-form :model="clfForm" label-width="100px">
        <el-form-item label="物码">
          <el-select v-model="clfForm.物码" filterable style="width:100%">
            <el-option v-for="w in wmList" :key="w.物码" :label="`${w.物码} ${w.名称规格}`" :value="w.物码" />
          </el-select>
        </el-form-item>
        <el-form-item label="消耗数量">
          <el-input-number v-model="clfForm.消耗数量" :min="1" style="width:100%" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="clfForm.单价" :precision="2" :min="0.01" style="width:100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addClfDialog=false">取消</el-button>
        <el-button type="primary" @click="submitAddClf">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  fetchZyxmSearch, changeZyxmStatus, deleteZyxm, fetchStatusOptions,
  fetchDwdmList, fetchSgdwList, fetchWmList,
  fetchClfByProject, createClf, deleteClf
} from '@/apis/zyxt'

const list = ref<any[]>([])
const dwdmList = ref<any[]>([])
const sgdwList = ref<any[]>([])
const wmList = ref<any[]>([])
const statusOptions = ref<string[]>([])
const dateRange = ref<string[]>([])

const queryParams = ref<any>({
  单据号: '', 预算单位: '', 井号: '', 施工单位: '',
  项目状态: '', 关键字: '', 超支: false
})

watch(dateRange, (v) => {
  queryParams.value.开始日期 = v?.[0] || ''
  queryParams.value.结束日期 = v?.[1] || ''
})

const loadData = async () => {
  const p: any = { ...queryParams.value }
  if (p.超支) p.超支 = '1'; else delete p.超支
  if (!p.开始日期) delete p.开始日期
  if (!p.结束日期) delete p.结束日期
  const res: any = await fetchZyxmSearch(p)
  if (res.code === 200) list.value = res.data
}

const resetQuery = () => {
  queryParams.value = { 单据号:'', 预算单位:'', 井号:'', 施工单位:'', 项目状态:'', 关键字:'', 超支:false }
  dateRange.value = []
  loadData()
}

const statusTag = (s: string) => ({
  '已预算':'info','施工中':'warning','已完工':'primary','已结算':'success','已入账':'success'
} as any)[s] || 'info'

const rowClass = ({ row }: any) => row.超支 ? 'over-budget-row' : ''

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm(`确定删除【${row.单据号}】？将级联删除其材料明细`, '提示', { type:'warning' })
  await deleteZyxm(row.单据号)
  ElMessage.success('删除成功')
  loadData()
}

const formatNumber = (n: number) => n?.toLocaleString('zh-CN', { minimumFractionDigits: 2 }) || '0.00'

// ---- 状态流转对话框 ----
const statusDialog = ref(false)
const currentRow = ref<any>({})
const statusForm = ref<any>({
  项目状态: '', 开工日期: '', 完工日期: '',
  结算金额: null, 结算人: '', 结算日期: '',
  入账金额: null, 入账人: '', 入账日期: ''
})
const stepIndex = computed(() => statusOptions.value.indexOf(statusForm.value.项目状态))

const needDate = (k: string) => ['开工日期','完工日期','结算日期','入账日期'].includes(k) && stepIndex.value >= ({'开工日期':1,'完工日期':2,'结算日期':3,'入账日期':4} as any)[k]
const needField = (k: string) => stepIndex.value >= ({'结算金额':3,'结算人':3,'入账金额':4,'入账人':4} as any)[k]

const openStatusDialog = (row: any) => {
  currentRow.value = row
  statusForm.value = {
    项目状态: row.项目状态,
    开工日期: row.开工日期 ? String(row.开工日期).substring(0,10) : '',
    完工日期: row.完工日期 ? String(row.完工日期).substring(0,10) : '',
    结算金额: row.结算金额, 结算人: row.结算人 || '',
    结算日期: row.结算日期 ? String(row.结算日期).substring(0,10) : '',
    入账金额: row.入账金额, 入账人: row.入账人 || '',
    入账日期: row.入账日期 ? String(row.入账日期).substring(0,10) : ''
  }
  statusDialog.value = true
}

const submitStatus = async () => {
  try {
    await changeZyxmStatus(currentRow.value.单据号, statusForm.value)
    ElMessage.success('已更新')
    statusDialog.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e.message)
  }
}

// ---- 材料明细 ----
const clfDialog = ref(false)
const clfList = ref<any[]>([])
const clfTotal = computed(() => clfList.value.reduce((s,r) => s + (r.金额 || r.消耗数量*r.单价 || 0), 0))

const openClfDialog = async (row: any) => {
  currentRow.value = row
  await reloadClf()
  clfDialog.value = true
}

const reloadClf = async () => {
  const res: any = await fetchClfByProject(currentRow.value.单据号)
  if (res.code === 200) clfList.value = res.data
}

const addClfDialog = ref(false)
const clfForm = ref({ 物码: '', 消耗数量: 1, 单价: 0 })

const openAddClf = () => {
  clfForm.value = { 物码: '', 消耗数量: 1, 单价: 0 }
  addClfDialog.value = true
}

const submitAddClf = async () => {
  try {
    await createClf({ ...clfForm.value, 单据号: currentRow.value.单据号 })
    ElMessage.success('已添加')
    addClfDialog.value = false
    reloadClf()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e.message)
  }
}

const deleteClf = async (row: any) => {
  await ElMessageBox.confirm('确定删除？', '提示', { type:'warning' })
  await deleteClf({ 单据号: row.单据号, 物码: row.物码 })
  ElMessage.success('已删除')
  reloadClf()
}

onMounted(async () => {
  const [o, d, s, w] = await Promise.all([fetchStatusOptions(), fetchDwdmList(), fetchSgdwList(), fetchWmList()])
  if (o.code === 200) statusOptions.value = o.data
  if (d.code === 200) dwdmList.value = d.data
  if (s.code === 200) sgdwList.value = s.data
  if (w.code === 200) wmList.value = w.data
  loadData()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.search-form { margin-bottom: 20px; }
:deep(.over-budget-row) {
  background-color: #fef0f0 !important;
  color: #f56c6c;
  font-weight: 600;
}
</style>
