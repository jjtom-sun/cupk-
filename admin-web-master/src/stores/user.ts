import { defineStore } from 'pinia'
import { login, getInfo } from '@/apis/zyxt'
import { ref } from 'vue'

export const useUserStore = defineStore(
  'user',
  () => {
    const userInfo = ref<any>({
      username: '',
      password: '',
      avatar: '',
      roles: [],
      token: '',
      menus: [],
    })

    const userLogin = async (loginParam: { username: string; password: string }) => {
      const res: any = await login(loginParam)
      if (res.code === 200) {
        userInfo.value.token = res.data.token
        userInfo.value.username = loginParam.username
        userInfo.value.roles = res.data.roles || ['admin']
        userInfo.value.menus = []
      }
    }

    const getUserInfo = async () => {
      const res: any = await getInfo()
      if (res.code === 200) {
        userInfo.value.username = res.data.username
        userInfo.value.avatar = res.data.icon || ''
        userInfo.value.roles = res.data.roles || ['admin']
      }
    }

    const userLogout = async () => {
      userInfo.value.token = ''
      userInfo.value.roles = []
    }

    const fedLogout = () => {
      userInfo.value.token = ''
    }

    return {
      userInfo,
      userLogin,
      getUserInfo,
      userLogout,
      fedLogout,
    }
  },
  {
    persist: true,
  },
)
