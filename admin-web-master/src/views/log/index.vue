<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>操作日志</span>
          <el-button type="primary" @click="loadData">刷新</el-button>
        </div>
      </template>
      <el-form :inline="true">
        <el-form-item label="对象表">
          <el-select v-model="query.对象表" clearable placeholder="全部" style="width:150px">
            <el-option v-for="t in tableOpts" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="query.操作类型" clearable placeholder="全部" style="width:130px">
            <el-option v-for="t in typeOpts" :key="t" :label="t" :value="t" />
          </el-select>
        </el-form-item>
        <el-form-item label="对象主键">
          <el-input v-model="query.对象主键" clearable style="width:150px" />
        </el-form-item>
        <el-form-item label="日期">
          <el-date-picker v-model="dateRange" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始" end-placeholder="结束" style="width:240px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadData">查询</el-button>
          <el-button @click="reset">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="list" border stripe>
        <el-table-column prop="日志ID" label="ID" width="70" />
        <el-table-column prop="操作时间" label="操作时间" width="180" />
        <el-table-column prop="操作人" label="操作人" width="100" />
        <el-table-column prop="操作类型" label="操作类型" width="100">
          <template #default="{ row }">
            <el-tag :type="tagType(row.操作类型)">{{ row.操作类型 }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="对象表" label="对象表" width="120" />
        <el-table-column prop="对象主键" label="对象主键" width="140" />
        <el-table-column prop="操作摘要" label="操作摘要" show-overflow-tooltip />
      </el-table>
      <el-pagination
        v-model:current-page="query.页码"
        v-model:page-size="query.页大小"
        :page-sizes="[10,20,50,100]"
        :total="total"
        layout="total,sizes,prev,pager,next,jumper"
        @current-change="loadData"
        @size-change="loadData"
        style="margin-top:14px" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { fetchLogList } from '@/apis/zyxt'

const list = ref<any[]>([])
const total = ref(0)
const dateRange = ref<string[]>([])
const tableOpts = ['作业项目表','材料费表','单位代码表','油水井表','施工单位表','物码表']
const typeOpts = ['新增','修改','删除','查询','预警']

const query = ref<any>({ 对象表:'', 操作类型:'', 对象主键:'', 页码:1, 页大小:20 })

watch(dateRange, (v) => {
  query.value.起始日期 = v?.[0] || ''
  query.value.结束日期 = v?.[1] || ''
})

const loadData = async () => {
  const p: any = { ...query.value }
  if (!p.起始日期) delete p.起始日期
  if (!p.结束日期) delete p.结束日期
  const r: any = await fetchLogList(p)
  if (r.code === 200) {
    list.value = r.data.list
    total.value = r.data.total
  }
}

const reset = () => {
  query.value = { 对象表:'', 操作类型:'', 对象主键:'', 页码:1, 页大小:20 }
  dateRange.value = []
  loadData()
}

const tagType = (t: string) => ({ '新增':'success','修改':'primary','删除':'danger','查询':'info','预警':'warning' } as any)[t] || 'info'

onMounted(loadData)
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
</style>
