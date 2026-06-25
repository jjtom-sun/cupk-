import { createRouter, createWebHashHistory } from 'vue-router'
import Layout from '@/views/layout/Layout.vue'
import type { RouteRecordExt } from '@/types/router'

export const constantRouterMap: RouteRecordExt[] = [
  { path: '/404', component: () => import('@/views/normal/404/index.vue'), hidden: true },
  { path: '/login', component: () => import('@/views/normal/login/index.vue'), hidden: true },
  {
    path: '',
    component: Layout,
    redirect: '/home',
    meta: { title: '首页', icon: 'home' },
    children: [
      {
        path: 'home',
        name: 'home',
        component: () => import('@/views/home/index.vue'),
        meta: { title: '首页', icon: 'dashboard' },
      },
    ],
  },
]

export const asyncRouterMap: RouteRecordExt[] = [
  {
    path: '/base',
    component: Layout,
    redirect: '/base/dwdm',
    name: 'base',
    meta: { title: '基础数据', icon: 'document' },
    children: [
      {
        path: 'dwdm',
        name: 'dwdm',
        component: () => import('@/views/base/dwdm/index.vue'),
        meta: { title: '单位代码管理', icon: 'table' },
      },
      {
        path: 'ysj',
        name: 'ysj',
        component: () => import('@/views/base/ysj/index.vue'),
        meta: { title: '油水井管理', icon: 'tree' },
      },
      {
        path: 'sgdw',
        name: 'sgdw',
        component: () => import('@/views/base/sgdw/index.vue'),
        meta: { title: '施工单位管理', icon: 'table' },
      },
      {
        path: 'wm',
        name: 'wm',
        component: () => import('@/views/base/wm/index.vue'),
        meta: { title: '物码管理', icon: 'table' },
      },
    ],
  },
  {
    path: '/zyxm',
    component: Layout,
    redirect: '/zyxm/list',
    name: 'zyxm',
    meta: { title: '作业项目', icon: 'form' },
    children: [
      {
        path: 'list',
        name: 'zyxmList',
        component: () => import('@/views/zyxm/list/index.vue'),
        meta: { title: '作业项目列表', icon: 'table' },
      },
      {
        path: 'add',
        name: 'zyxmAdd',
        component: () => import('@/views/zyxm/add.vue'),
        meta: { title: '添加作业项目' },
        hidden: true,
      },
      {
        path: 'update',
        name: 'zyxmUpdate',
        component: () => import('@/views/zyxm/update.vue'),
        meta: { title: '修改作业项目' },
        hidden: true,
      },
    ],
  },
  {
    path: '/clf',
    component: Layout,
    redirect: '/clf/list',
    name: 'clf',
    meta: { title: '材料费管理', icon: 'example' },
    children: [
      {
        path: 'list',
        name: 'clfList',
        component: () => import('@/views/clf/list/index.vue'),
        meta: { title: '材料费明细', icon: 'table' },
      },
      {
        path: 'stat',
        name: 'clfStat',
        component: () => import('@/views/clf/stat.vue'),
        meta: { title: '材料费统计', icon: 'chart' },
      },
    ],
  },
  {
    path: '/tj',
    component: Layout,
    redirect: '/tj/overview',
    name: 'tj',
    meta: { title: '统计查询', icon: 'tree' },
    children: [
      {
        path: 'overview',
        name: 'tjOverview',
        component: () => import('@/views/tj/overview/index.vue'),
        meta: { title: '数据概览', icon: 'dashboard' },
      },
      {
        path: 'byUnit',
        name: 'tjByUnit',
        component: () => import('@/views/tj/byUnit/index.vue'),
        meta: { title: '按单位统计', icon: 'table' },
      },
      {
        path: 'byContractor',
        name: 'tjByContractor',
        component: () => import('@/views/tj/byContractor/index.vue'),
        meta: { title: '按施工单位统计', icon: 'table' },
      },
      {
        path: 'costrun',
        name: 'tjCostRun',
        component: () => import('@/views/tj/costrun.vue'),
        meta: { title: '多级单位成本运行', icon: 'tree' },
      },
      {
        path: 'coststructure',
        name: 'tjCostStructure',
        component: () => import('@/views/tj/coststructure.vue'),
        meta: { title: '成本构成分析', icon: 'chart' },
      },
      {
        path: 'monthly',
        name: 'tjMonthly',
        component: () => import('@/views/tj/monthly.vue'),
        meta: { title: '月度结算表', icon: 'chart' },
      },
      {
        path: 'anomalies',
        name: 'tjAnomalies',
        component: () => import('@/views/tj/anomalies.vue'),
        meta: { title: '异常项目筛查', icon: 'warning' },
      },
    ],
  },
  {
    path: '/log',
    component: Layout,
    redirect: '/log/list',
    name: 'log',
    meta: { title: '系统管控', icon: 'eye-open' },
    children: [
      {
        path: 'list',
        name: 'logList',
        component: () => import('@/views/log/index.vue'),
        meta: { title: '操作日志', icon: 'document' },
      },
    ],
  },
  {
    path: '/meta',
    component: Layout,
    redirect: '/meta/constraints',
    name: 'meta',
    meta: { title: '数据元信息', icon: 'eye' },
    children: [
      {
        path: 'constraints',
        name: 'metaConstraints',
        component: () => import('@/views/meta/constraints/index.vue'),
        meta: { title: '约束可视化', icon: 'tree' },
      },
      {
        path: 'tables',
        name: 'metaTables',
        component: () => import('@/views/meta/tables/index.vue'),
        meta: { title: '表统计', icon: 'table' },
      },
    ],
  },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes: constantRouterMap,
})

export default router
