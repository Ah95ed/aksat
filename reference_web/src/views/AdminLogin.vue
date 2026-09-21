<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-900 p-4">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-8">
      <h2 class="text-2xl font-bold text-center text-gray-800 mb-1">لوحة تحكم الأدمن</h2>
      <p class="text-center text-gray-500 text-sm mb-6">تسجيل دخول خاص بالإدارة فقط</p>

      <div v-if="errorMessage" class="bg-red-100 text-red-700 p-3 rounded mb-4 text-sm text-center">
        {{ errorMessage }}
      </div>

      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block text-gray-700 text-sm font-bold mb-2">البريد الإلكتروني</label>
          <input
            v-model="email"
            type="email"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-800"
            placeholder="admin@example.com"
            dir="ltr"
          >
        </div>

        <div>
          <label class="block text-gray-700 text-sm font-bold mb-2">كلمة المرور</label>
          <input
            v-model="password"
            type="password"
            required
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-gray-800"
            placeholder="********"
            dir="ltr"
          >
        </div>

        <button
          type="submit"
          :disabled="isLoading"
          class="w-full bg-gray-900 text-white font-bold py-2 px-4 rounded hover:bg-gray-800 transition disabled:opacity-50"
        >
          <span v-if="isLoading">جاري التحقق...</span>
          <span v-else>دخول لوحة الإدارة</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

const router = useRouter()
const email = ref('')
const password = ref('')
const errorMessage = ref('')
const isLoading = ref(false)

const handleLogin = async () => {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const result = await api.login({ email: email.value, password: password.value })

    if (result.success) {
      if (result.data.user.role !== 'admin') {
        errorMessage.value = 'هذا الحساب لا يملك صلاحية الوصول للوحة الإدارة'
        isLoading.value = false
        return
      }
      localStorage.setItem('token', result.data.token)
      router.push('/admin')
    } else {
      errorMessage.value = result.message || 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
    }
  } catch (error) {
    errorMessage.value = error.message || 'تعذر الاتصال بالخادم'
  } finally {
    isLoading.value = false
  }
}
</script>
