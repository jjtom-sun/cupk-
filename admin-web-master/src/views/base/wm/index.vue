<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>物码管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="list" border stripe>
        <el-table-column prop="物码" label="物码" width="150" />
        <el-table-column prop="名称规格" label="名称规格" />
        <el-table-column prop="计量单位" label="计量单位" width="100" />
        <el-table-column prop="单价" label="单价" width="100" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑物码' : '新增物码'" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="物码">
          <el-input v-model="form.物码" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="名称规格">
          <el-input v-model="form.名称规格" />
        </el-form-item>
        <el-form-item label="计量单位">
          <el-input v-model="form.计量单位" />
        </el-form-item>
        <el-form-item label="单价">
          <el-input-number v-model="form.单价" :precision="2" :min="0" />
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
import { fetchWmList, createWm, updateWm, deleteWm } from '@/apis/zyxt'
import { ElMessage, ElMessageBox } from 'element-plus'

const list = ref<any[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const form = ref({ 物码: '', 名称规格: '', 计量单位: '', 单价: 0 })

const loadData = async () => {
  const res: any = await fetchWmList()
  if (res.code === 200) list.value = res.data
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { 物码: '', 名称规格: '', 计量单位: '', 单价: 0 }
  dialogVisible.value = true
}

const handleEdit = (row: any) => {
  isEdit.value = true
  form.value = { ...row }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  try {
    if (isEdit.value) {
      await updateWm(form.value.物码, form.value)
    } else {
      await createWm(form.value)
    }
    ElMessage.success('操作成功')
    dialogVisible.value = false
    loadData()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm('确定删除该物码吗？', '提示', { type: 'warning' })
  await deleteWm(row.物码)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
