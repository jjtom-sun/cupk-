<template>
  <div class="app-container">
    <el-tabs v-model="activeTab">
      <el-tab-pane label="树形展示" name="tree">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>单位代码 - 层级树形展示（采油厂→采油矿→采油队）</span>
            </div>
          </template>
          <el-input v-model="filter" placeholder="输入名称筛选" style="width:300px;margin-bottom:10px" clearable />
          <el-tree
            ref="treeRef"
            :data="treeData"
            :props="{ label: 'label', children: 'children' }"
            :filter-node-method="filterNode"
            :default-expand-all="true"
            node-key="单位代码"
            highlight-current
            empty-text="正在加载...">
            <template #default="{ node, data }">
              <span>{{ node.label }}</span>
              <el-tag size="small" :type="levelTag(data.单位代码)" style="margin-left:8px">
                {{ levelLabel(data.单位代码) }}
              </el-tag>
            </template>
          </el-tree>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="列表管理" name="list">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>单位代码管理</span>
          <el-button type="primary" @click="handleAdd">新增</el-button>
        </div>
      </template>
      <el-table :data="list" border stripe>
        <el-table-column prop="单位代码" label="单位代码" width="200" />
        <el-table-column prop="单位名称" label="单位名称" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑单位' : '新增单位'" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="单位代码">
          <el-input v-model="form.单位代码" :disabled="isEdit" />
        </el-form-item>
        <el-form-item label="单位名称">
          <el-input v-model="form.单位名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { fetchDwdmList, createDwdm, updateDwdm, deleteDwdm, fetchDwdmTree } from '@/apis/zyxt'
import { ElMessage, ElMessageBox } from 'element-plus'

const activeTab = ref('tree')
const list = ref<any[]>([])
const treeData = ref<any[]>([])
const filter = ref('')
const treeRef = ref<any>()
const dialogVisible = ref(false)
const isEdit = ref(false)
const form = ref({ 单位代码: '', 单位名称: '' })

const loadData = async () => {
  const res: any = await fetchDwdmList()
  if (res.code === 200) list.value = res.data
}

const loadTree = async () => {
  const res: any = await fetchDwdmTree()
  if (res.code === 200) treeData.value = res.data
}

watch(filter, (v) => { treeRef.value?.filter(v) })

const filterNode = (value: string, data: any) => {
  if (!value) return true
  return data.label.includes(value)
}

const levelTag = (code: string) => code.length === 4 ? 'danger' : code.length === 6 ? 'warning' : 'success'
const levelLabel = (code: string) => code.length === 4 ? '采油厂' : code.length === 6 ? '采油矿' : '采油队'

const handleAdd = () => {
  isEdit.value = false
  form.value = { 单位代码: '', 单位名称: '' }
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
      await updateDwdm(form.value.单位代码, form.value)
    } else {
      await createDwdm(form.value)
    }
    ElMessage.success('操作成功')
    dialogVisible.value = false
    loadData()
    loadTree()
  } catch (e: any) {
    ElMessage.error(e.message || '操作失败')
  }
}

const handleDelete = async (row: any) => {
  await ElMessageBox.confirm('确定删除该单位吗？', '提示', { type: 'warning' })
  await deleteDwdm(row.单位代码)
  ElMessage.success('删除成功')
  loadData()
  loadTree()
}

onMounted(() => {
  loadData()
  loadTree()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
