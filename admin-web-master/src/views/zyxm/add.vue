<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>添加作业项目</span>
          <el-button @click="$router.back()">返回</el-button>
        </div>
      </template>
      <el-form :model="form" label-width="120px" style="max-width: 800px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="单据号">
              <el-input v-model="form.单据号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预算单位">
              <el-input v-model="form.预算单位" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="井号">
              <el-input v-model="form.井号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预算金额">
              <el-input-number v-model="form.预算金额" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预算人">
              <el-input v-model="form.预算人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预算日期">
              <el-date-picker v-model="form.预算日期" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="开工日期">
              <el-date-picker v-model="form.开工日期" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="完工日期">
              <el-date-picker v-model="form.完工日期" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="施工单位">
              <el-input v-model="form.施工单位" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="施工内容">
              <el-input v-model="form.施工内容" type="textarea" :rows="3" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="材料费">
              <el-input-number v-model="form.材料费" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="人工费">
              <el-input-number v-model="form.人工费" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="设备费">
              <el-input-number v-model="form.设备费" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="其它费用">
              <el-input-number v-model="form.其它费用" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结算金额">
              <el-input-number v-model="form.结算金额" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结算人">
              <el-input v-model="form.结算人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="结算日期">
              <el-date-picker v-model="form.结算日期" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入账金额">
              <el-input-number v-model="form.入账金额" :precision="2" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入账人">
              <el-input v-model="form.入账人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入账日期">
              <el-date-picker v-model="form.入账日期" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item>
          <el-button type="primary" @click="handleSubmit">提交</el-button>
          <el-button @click="$router.back()">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { createZyxm } from '@/apis/zyxt'
import { ElMessage } from 'element-plus'

const router = useRouter()
const form = ref({
  单据号: '',
  预算单位: '',
  井号: '',
  预算金额: 0,
  预算人: '',
  预算日期: '',
  开工日期: '',
  完工日期: '',
  施工单位: '',
  施工内容: '',
  材料费: 0,
  人工费: 0,
  设备费: 0,
  其它费用: 0,
  结算金额: 0,
  结算人: '',
  结算日期: '',
  入账金额: 0,
  入账人: '',
  入账日期: '',
})

const handleSubmit = async () => {
  try {
    await createZyxm(form.value)
    ElMessage.success('添加成功')
    router.push('/zyxm/list')
  } catch (e: any) {
    ElMessage.error(e.message || '添加失败')
  }
}
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
