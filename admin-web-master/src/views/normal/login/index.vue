<script lang="ts" setup>
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user';
import { type FormInstance, type FormRules } from 'element-plus';

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref<FormInstance>()

const loginForm = reactive({
  username: '',
  password: '',
})

const loginRules = reactive<FormRules<typeof loginForm>>({
  username: [{ required: true, trigger: 'blur', message: '请输入用户名' }],
  password: [{ required: true, trigger: 'blur', message: '请输入密码' }]
})

const loading = ref(false)

onMounted(() => {
  loginForm.username = userStore.userInfo.username || 'admin'
  loginForm.password = userStore.userInfo.password || ''
})

const handleLogin = () => {
  loginFormRef.value!.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        await userStore.userLogin({
          username: loginForm.username.trim(),
          password: loginForm.password
        })
        loading.value = false
        router.push({ path: '/' })
      }
      catch (err) {
        loading.value = false
        console.log(err)
      }
    }
  })
}
</script>

<template>
  <div>
    <el-card class="login-form-layout">
      <el-form autoComplete="on" :model="loginForm" :rules="loginRules" ref="loginFormRef" label-position="left">
        <div style="text-align: center">
          <svg-icon icon-class="login-mall" style="width: 56px;height: 56px;color: #409EFF"></svg-icon>
        </div>
        <h2 class="login-title color-main">采油厂油水井作业成本管理系统</h2>
        <el-form-item prop="username">
          <el-input name="username" type="text" v-model="loginForm.username" autoComplete="on" placeholder="请输入用户名">
            <template #prefix>
              <span>
                <svg-icon icon-class="user" class="color-main"></svg-icon>
              </span>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item prop="password">
          <el-input name="password" @keyup.enter="handleLogin" v-model="loginForm.password" autoComplete="on"
            show-password placeholder="请输入密码">
            <template #prefix>
              <span>
                <svg-icon icon-class="password" class="color-main"></svg-icon>
              </span>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item style="margin-bottom: 60px;text-align: center">
          <el-button style="width: 100%" type="primary" :loading="loading" @click="handleLogin">
            登录
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <img src="@/assets/images/login_center_bg.png" class="login-center-layout">
  </div>
</template>

<style scoped>
.login-form-layout {
  position: absolute;
  left: 0;
  right: 0;
  width: 360px;
  margin: 140px auto;
  border-top: 10px solid #409EFF;
}

.login-title {
  text-align: center;
  font-size: 18px;
  margin: 10px 0;
}

.login-center-layout {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 400px;
  opacity: 0.3;
}
</style>
