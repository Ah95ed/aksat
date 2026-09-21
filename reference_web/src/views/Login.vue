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

      <h2 class="text-2xl font-bold text-center text-gray-800 mb-6">تسجيل الدخول</h2>
      
      <!-- رسالة الخطأ وزر الواتساب -->
      <div v-if="errorMessage" class="bg-red-100 text-red-700 p-3 rounded mb-4 text-sm text-center">
        <p>{{ errorMessage }}</p>

        <!-- يظهر زر الواتساب فقط إذا كان سبب منع الدخول هو توقف الاشتراك -->
        <a 
          v-if="whatsappLink" 
          :href="whatsappLink" 
          target="_blank" 
          class="mt-3 inline-flex items-center justify-center gap-2 w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-2 px-4 rounded transition shadow text-sm"
        >
          <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
            <path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981zm11.387-5.464c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.198 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.571-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414z"/>
          </svg>
          <span>التواصل عبر واتساب لتجديد الاشتراك</span>
        </a>
      </div>

      <form @submit.prevent="handleLogin" class="space-y-4">
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
            dir="ltr"
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
            dir="ltr"
          >
        </div>

        <!-- زر الإرسال -->
        <button 
          type="submit" 
          :disabled="isLoading"
          class="w-full bg-blue-600 text-white font-bold py-2 px-4 rounded hover:bg-blue-700 transition disabled:opacity-50"
        >
          <span v-if="isLoading">جاري التحقق...</span>
          <span v-else>دخول</span>
        </button>
      </form>

      <!-- رابط العودة لإنشاء حساب -->
      <div class="mt-4 text-center">
        <p class="text-sm text-gray-600">
          ليس لديك حساب؟ 
          <router-link to="/register" class="text-blue-600 hover:underline">إنشاء حساب جديد</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const email = ref('');
const password = ref('');
const errorMessage = ref('');
const whatsappLink = ref('');
const isLoading = ref(false);

const logoLoaded = ref(true);
const handleImageError = () => {
  logoLoaded.value = false;
};

// دالة توليد رابط الواتساب حسب نوع الجهاز
const generateWhatsappUrl = (phone) => {
  const message = encodeURIComponent('السلام عليكم، أرغب بتجديد اشتراكي');
  
  // فحص ما إذا كان المستخدم يفتح الموقع من هاتف أو تابلت
  const isMobileOrTablet = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

  if (isMobileOrTablet) {
    // فتح تطبيق الواتساب المباشر للهاتف والتابلت
    return `https://api.whatsapp.com/send?phone=${phone}&text=${message}`;
  } else {
    // فتح موقع واتساب ويب للكمبيوتر/الحاسبة
    return `https://web.whatsapp.com/send?phone=${phone}&text=${message}`;
  }
};

const handleLogin = async () => {
  isLoading.value = true;
  errorMessage.value = '';
  whatsappLink.value = '';

  try {
    const response = await fetch('/api/login.php', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: email.value,
        password: password.value
      })
    });

    const result = await response.json();

    if (result.success) {
      localStorage.setItem('token', result.data.token);
      window.location.hash = '/';
      window.location.reload();
    } else {
      errorMessage.value = result.message || 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

      // فحص الرسالة: إذا احتوت على النص الخاص بتوقف الاشتراك يتم إنشاء الرابط
      if (result.message && (result.message.includes('إيقاف') || result.message.includes('اشتراكك'))) {
        whatsappLink.value = generateWhatsappUrl('9647706118992');
      }
    }
  } catch (error) {
    errorMessage.value = 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت.';
  } finally {
    isLoading.value = false;
  }
};
</script>