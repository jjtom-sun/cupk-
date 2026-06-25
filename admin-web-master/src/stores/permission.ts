import { defineStore } from 'pinia'
import { shallowRef } from 'vue'
import { asyncRouterMap, constantRouterMap } from '@/router/index'
import type { RouteRecordExt } from '@/types/router'

export const usePermissionStore = defineStore('permission', () => {
  const routers = shallowRef(constantRouterMap)
  const addRouters = shallowRef<RouteRecordExt[]>([])

  const generateRoutes = () => {
    addRouters.value = asyncRouterMap
    routers.value = constantRouterMap.concat(asyncRouterMap)
  }

  return {
    routers,
    addRouters,
    generateRoutes,
  }
})

export default usePermissionStore
