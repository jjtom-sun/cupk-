import http from '@/utils/http'

// 登录
export function login(data: { username: string; password: string }) {
  return http({
    url: '/admin/login',
    method: 'post',
    data,
  })
}

export function getInfo() {
  return http({
    url: '/admin/info',
    method: 'get',
  })
}

// 单位代码表
export function fetchDwdmList() {
  return http({ url: '/dwdm/list', method: 'get' })
}

export function fetchDwdmListAll() {
  return http({ url: '/dwdm/listAll', method: 'get' })
}

export function createDwdm(data: any) {
  return http({ url: '/dwdm', method: 'post', data })
}

export function updateDwdm(code: string, data: any) {
  return http({ url: `/dwdm/${code}`, method: 'put', data })
}

export function deleteDwdm(code: string) {
  return http({ url: `/dwdm/${code}`, method: 'delete' })
}

// 油水井表
export function fetchYsjList() {
  return http({ url: '/ysj/list', method: 'get' })
}

export function fetchYsjListAll() {
  return http({ url: '/ysj/listAll', method: 'get' })
}

export function createYsj(data: any) {
  return http({ url: '/ysj', method: 'post', data })
}

export function updateYsj(id: string, data: any) {
  return http({ url: `/ysj/${id}`, method: 'put', data })
}

export function deleteYsj(id: string) {
  return http({ url: `/ysj/${id}`, method: 'delete' })
}

// 施工单位表
export function fetchSgdwList() {
  return http({ url: '/sgdw/list', method: 'get' })
}

export function fetchSgdwListAll() {
  return http({ url: '/sgdw/listAll', method: 'get' })
}

export function createSgdw(data: any) {
  return http({ url: '/sgdw', method: 'post', data })
}

export function updateSgdw(name: string, data: any) {
  return http({ url: `/sgdw/${name}`, method: 'put', data })
}

export function deleteSgdw(name: string) {
  return http({ url: `/sgdw/${name}`, method: 'delete' })
}

// 物码表
export function fetchWmList() {
  return http({ url: '/wm/list', method: 'get' })
}

export function fetchWmListAll() {
  return http({ url: '/wm/listAll', method: 'get' })
}

export function createWm(data: any) {
  return http({ url: '/wm', method: 'post', data })
}

export function updateWm(code: string, data: any) {
  return http({ url: `/wm/${code}`, method: 'put', data })
}

export function deleteWm(code: string) {
  return http({ url: `/wm/${code}`, method: 'delete' })
}

// 作业项目表
export function fetchZyxmList(params: any) {
  return http({ url: '/zyxm/list', method: 'get', params })
}

export function fetchZyxmDetail(id: string) {
  return http({ url: `/zyxm/${id}`, method: 'get' })
}

export function createZyxm(data: any) {
  return http({ url: '/zyxm', method: 'post', data })
}

export function updateZyxm(id: string, data: any) {
  return http({ url: `/zyxm/${id}`, method: 'put', data })
}

export function deleteZyxm(id: string) {
  return http({ url: `/zyxm/${id}`, method: 'delete' })
}

// 材料费表
export function fetchClfList(params: any) {
  return http({ url: '/clf/list', method: 'get', params })
}

export function createClf(data: any) {
  return http({ url: '/clf', method: 'post', data })
}

export function updateClf(data: any) {
  return http({ url: '/clf', method: 'put', data })
}

export function deleteClf(data: { 单据号: string; 物码: string }) {
  return http({ url: '/clf', method: 'delete', data })
}

// 统计查询
export function fetchSummary() {
  return http({ url: '/tj/summary', method: 'get' })
}

export function fetchByUnit() {
  return http({ url: '/tj/byUnit', method: 'get' })
}

export function fetchByContractor() {
  return http({ url: '/tj/byContractor', method: 'get' })
}

// 数据库元信息
export function fetchMetaTables() {
  return http({ url: '/meta/tables', method: 'get' })
}

export function fetchMetaTableDetail(name: string) {
  return http({ url: `/meta/tables/${name}`, method: 'get' })
}

export function fetchMetaConstraints() {
  return http({ url: '/meta/constraints', method: 'get' })
}

export function fetchMetaOverview() {
  return http({ url: '/meta/overview', method: 'get' })
}

// ============== 系统重构：业务增强 API ==============

// 仪表盘
export const fetchDashOverview = () => http({ url: '/dash/overview', method: 'get' })
export const fetchDashTrend    = () => http({ url: '/dash/trend', method: 'get' })
export const fetchDashStatusPie= () => http({ url: '/dash/statusPie', method: 'get' })
export const fetchDashUnitPie  = () => http({ url: '/dash/unitPie', method: 'get' })

// 作业项目 综合查询
export const fetchZyxmSearch   = (params: any) => http({ url: '/zyxm/search', method: 'get', params })
export const changeZyxmStatus  = (id: string, data: any) => http({ url: `/zyxm/${id}/status`, method: 'post', data })
export const fetchStatusOptions= () => http({ url: '/util/statusOptions', method: 'get' })

// 统计增强
export const fetchCostRun      = () => http({ url: '/tj/costRun', method: 'get' })
export const fetchCostRunProc  = (params: any) => http({ url: '/tj/costRunProc', method: 'get', params })
export const fetchMonthly      = (params: any) => http({ url: '/tj/monthly', method: 'get', params })
export const fetchCostStructure= (params: any) => http({ url: '/tj/costStructure', method: 'get', params })
export const fetchOverBudget   = () => http({ url: '/tj/overBudget', method: 'get' })
export const fetchAnomalies    = () => http({ url: '/tj/anomalies', method: 'get' })

// 操作日志
export const fetchLogList      = (params: any) => http({ url: '/log/list', method: 'get', params })

// 材料费 增强
export const fetchClfByProject    = (id: string)        => http({ url: `/clf/byProject/${id}`, method: 'get' })
export const fetchClfAggregateByProject  = () => http({ url: '/clf/aggregateByProject', method: 'get' })
export const fetchClfAggregateByMaterial = () => http({ url: '/clf/aggregateByMaterial', method: 'get' })
export const fetchClfProjectsOfMaterial  = (wm: string) => http({ url: `/clf/projectsOfMaterial/${wm}`, method: 'get' })
export const fetchClfOverMaterial        = (params: any) => http({ url: '/clf/overMaterial', method: 'get', params })

// 单位代码 树形
export const fetchDwdmTree     = () => http({ url: '/dwdm/tree', method: 'get' })

