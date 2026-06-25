<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>施工单位管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="list" border stripe>
        <el-table-column prop="施工单位名称" label="施工单位" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑施工单位' : '新增施工单位'" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="施工单位">
          <el-input v-model="form.施工单位名称" :disabled="isEdit" />
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
import { fetchSgdwList, createSgdw, updateSgdw, deleteSgdw } from '@/apis/zyxt'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref<any[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const form = ref<{ 施工单位名称: string }>({ 施工单位名称: '' })

const loadData = async () => {
  const res: any = await fetchSgdwList()
  if (res.code === 200) list.value = res.data
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { 施工单位名称: '' }
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  form.value = { 施工单位名称: row.施工单位名称 }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await updateSgdw(form.value.施工单位名称, { 施工单位名称: form.value.施工单位名称 })
    } else {
      await createSgdw(form.value)
    }
    ElMessage.success('操作成功')
    dialogVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm('确定删除该施工单位吗？', '提示', { type: 'warning' })
  await deleteSgdw(row.施工单位名称)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
