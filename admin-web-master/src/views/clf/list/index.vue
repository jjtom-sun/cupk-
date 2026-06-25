<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>材料费明细</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="单据号">
          <el-input v-model="queryParams.单据号" placeholder="请输入单据号" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="list" border stripe>
        <el-table-column prop="单据号" label="单据号" width="150" />
        <el-table-column prop="物码" label="物码" width="120" />
        <el-table-column prop="材料名称" label="材料名称" />
        <el-table-column prop="消耗数量" label="消耗数量" width="120" />
        <el-table-column prop="单价" label="单价" width="100" />
        <el-table-column prop="计量单位" label="计量单位" width="100" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" title="新增材料费" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="单据号">
          <el-input v-model="form.单据号" />
        </el-form-item>
        <el-form-item label="物码">
          <el-input v-model="form.物码" />
        </el-form-item>
        <el-form-item label="消耗数量">
          <el-input-number v-model="form.消耗数量" :precision="2" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="form.单价" :precision="2" :min="0" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { fetchClfList, createClf, deleteClf } from '@/apis/zyxt'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref<any[]>([])
const queryParams = ref({ 单据号: '' })
const dialogVisible = ref(false)
const form = ref({ 单据号: '', 物码: '', 消耗数量: 0, 单价: 0 })

const loadData = async () => {
  const res: any = await fetchClfList(queryParams.value)
  if (res.code === 200) list.value = res.data
}

const resetQuery = () => {
  queryParams.value = { 单据号: '' }
  loadData()
}

const handleAdd = () => {
  form.value = { 单据号: '', 物码: '', 消耗数量: 0, 单价: 0 }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  try {
    await createClf(form.value)
    ElMessage.success('添加成功')
    dialogVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e.message || '添加失败')
  }
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm('确定删除该材料费记录吗？', '提示', { type: 'warning' })
  await deleteClf({ 单据号: row.单据号, 物码: row.物码 })
  ElMessage.success('删除成功')
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.search-form { margin-bottom: 20px; }
</style>
