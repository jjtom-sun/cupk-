<template>
  <div class="app-container">
    <el-tabs v-model="active">
      <el-tab-pane label="超预算项目" name="over">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>超预算项目（结算金额 &gt; 预算金额）</span>
              <el-button type="primary" @click="loadOver">刷新</el-button>
            </div>
          </template>
          <el-alert type="warning" :closable="false" show-icon
            :title="`共发现 ${overList.length} 个超预算项目`" />
          <el-table :data="overList" border stripe style="margin-top:10px">
            <el-table-column prop="单据号" label="单据号" width="120" />
            <el-table-column prop="预算单位" label="预算单位" width="120" />
            <el-table-column prop="井号" label="井号" width="80" />
            <el-table-column prop="施工单位" label="施工单位" width="160" />
            <el-table-column prop="施工内容" label="施工内容" />
            <el-table-column prop="预算金额" label="预算金额" width="100" align="right" />
            <el-table-column prop="结算金额" label="结算金额" width="100" align="right" />
            <el-table-column label="超支金额" width="100" align="right">
              <template #default="{ row }">¥{{ (row.结算金额 - row.预算金额).toFixed(2) }}</template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="异常项目" name="anom">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>异常项目筛查（已结算未入账 / 已完工未结算）</span>
              <el-button type="primary" @click="loadAnom">刷新</el-button>
            </div>
          </template>
          <el-table :data="anomList" border stripe>
            <el-table-column prop="单据号" label="单据号" width="120" />
            <el-table-column prop="预算单位" label="预算单位" width="120" />
            <el-table-column prop="井号" label="井号" width="80" />
            <el-table-column prop="项目状态" label="项目状态" width="100">
              <template #default="{ row }">
                <el-tag :type="row.项目状态==='已结算' ? 'warning' : 'danger'">{{ row.项目状态 }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="预算金额" label="预算金额" align="right" />
            <el-table-column prop="结算金额" label="结算金额" align="right" />
            <el-table-column prop="入账金额" label="入账金额" align="right">
              <template #default="{ row }">{{ row.入账金额 ?? '-' }}</template>
            </el-table-column>
            <el-table-column label="问题类型" width="180">
              <template #default="{ row }">
                <el-tag v-if="row.项目状态==='已结算' && !row.入账金额" type="warning">已结算未入账</el-tag>
                <el-tag v-else-if="row.项目状态==='已完工'" type="info">已完工未结算</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-tab-pane>

      <el-tab-pane label="材料超标项目" name="mat">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>单类材料消耗超阈值项目</span>
            </div>
          </template>
          <el-form :inline="true">
            <el-form-item label="阈值（元）">
              <el-input-number v-model="阈值" :min="1" :precision="2" style="width:150px" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="loadOverMat">查询</el-button>
            </el-form-item>
          </el-form>
          <el-table :data="overMatList" border stripe>
            <el-table-column prop="单据号" label="单据号" width="120" />
            <el-table-column prop="物码" label="物码" width="100" />
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
import { fetchOverBudget, fetchAnomalies, fetchClfOverMaterial } from '@/apis/zyxt'

const active = ref('over')
const overList = ref<any[]>([])
const anomList = ref<any[]>([])
const overMatList = ref<any[]>([])
const 阈值 = ref(2000)

const loadOver = async () => {
  const r: any = await fetchOverBudget()
  if (r.code === 200) overList.value = r.data
}
const loadAnom = async () => {
  const r: any = await fetchAnomalies()
  if (r.code === 200) anomList.value = r.data
}
const loadOverMat = async () => {
  const r: any = await fetchClfOverMaterial({ 阈值: 阈值.value })
  if (r.code === 200) overMatList.value = r.data
}

onMounted(() => {
  loadOver()
  loadAnom()
  loadOverMat()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
