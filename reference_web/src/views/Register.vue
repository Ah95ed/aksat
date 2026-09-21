<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100 p-4">
    <div class="max-w-md w-full bg-white rounded-lg shadow-md p-8">
      
      <!-- شعار الموقع -->
      <div class="flex justify-center mb-4" v-if="logoLoaded">
        <img 
          src="../../icon/icon.png" 
          alt="شعار الموقع" 
          class="w-20 h-20 object-contain p-1 rounded-xl bg-gray-50 shadow-sm border border-gray-200"
          @error="handleImageError"
        />
      </div>

      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">إنشاء حساب جديد</h2>
      
      <!-- رسالة الخطأ -->
      <div v-if="errorMessage" class="bg-red-100 text-red-700 p-3 rounded mb-4 text-sm text-center">
        {{ errorMessage }}
      </div>

      <form @submit.prevent="handleRegister" class="space-y-4">
        <!-- حقل الاسم -->
        <div>
          <label class="block text-gray-700 text-sm font-bold mb-2" for="name">الاسم الكامل</label>
          <input 
            v-model="name" 
            type="text" 
            id="name" 
            required
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-blue-500"
            placeholder="أدخل اسمك"
          >
        </div>

        <!-- حقل البريد الإلكتروني -->
        <div>
          <label class="block text-gray-700 text-sm font-bold mb-2" for="email">البريد الإلكتروني</label>
          <input 
            v-model="email" 
            type="email" 
            id="email" 
            required
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-blue-500"
            placeholder="example@mail.com"
          >
        </div>

        <!-- حقل كلمة المرور -->
        <div>
          <label class="block text-gray-700 text-sm font-bold mb-2" for="password">كلمة المرور</label>
          <input 
            v-model="password" 
            type="password" 
            id="password" 
            required
            class="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:border-blue-500"
            placeholder="********"
          >
        </div>

        <!-- زر الإرسال -->
        <button 
          type="submit" 
          :disabled="isLoading"
          class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 transition disabled:opacity-50"
        >
          <span v-if="isLoading">جاري التسجيل...</span>
          <span v-else>إنشاء الحساب</span>
        </button>
      </form>

      <!-- رابط العودة لتسجيل الدخول -->
      <div class="mt-4 text-center">
        <p class="text-sm text-gray-600">
          لديك حساب بالفعل؟ 
          <router-link to="/login" class="text-blue-600 hover:underline">تسجيل الدخول</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';

// تعريف المتغيرات
const router = useRouter();
const name = ref('');
const email = ref('');
const password = ref('');
const errorMessage = ref('');
const isLoading = ref(false);

const logoLoaded = ref(true);
const handleImageError = () => {
  logoLoaded.value = false;
};

// دالة إرسال البيانات للـ API
const handleRegister = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    const response = await fetch('/api/register.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: name.value,
        email: email.value,
        password: password.value
      })
    });

    const result = await response.json();

    if (result.success) {
      // حفظ التوكن في المتصفح
      localStorage.setItem('token', result.data.token);

      // إعادة تحميل كاملة للتطبيق (وليس تنقل داخلي فقط) حتى لا تبقى
      // بيانات/إعدادات المستخدم السابق محفوظة في ذاكرة المتصفح
      window.location.hash = '/';
      window.location.reload();
    } else {
      errorMessage.value = result.message || 'حدث خطأ غير متوقع';
    }
  } catch (error) {
    errorMessage.value = 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت.';
  } finally {
    isLoading.value = false;
  }
};
</script>