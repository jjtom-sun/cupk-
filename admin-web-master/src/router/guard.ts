import router from '@/router/index'
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import { useUserStore } from '@/stores/user'
import usePermissionStore from '@/stores/permission'

// 无需登陆的白名单路径
const whiteList = ['/login']
// 配置路由前置守卫函数（每次路由跳转都会执行）
router.beforeEach((to, from, next) => {
  NProgress.start()
  const userStore = useUserStore()
  const permissionStore = usePermissionStore()
  if (userStore.userInfo.token) {
    if (to.path === '/login') {
      next({ path: '/' })
      NProgress.done()
    } else {
      if (permissionStore.addRouters.length === 0) {
        permissionStore.generateRoutes()
        permissionStore.addRouters.forEach(route => {
          router.addRoute(route)
        })
        next({ ...to, replace: true })
      } else {
        next()
      }
    }
  } else {
    if (whiteList.indexOf(to.path) !== -1) {
      next()
    } else {
      next('/login')
      NProgress.done()
    }
  }
})

router.afterEach(() => {
  NProgress.done()
})
