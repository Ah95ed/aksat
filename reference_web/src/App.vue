<template>
  <div class="min-h-screen flex flex-col md:flex-row">
    <!-- زر القائمة للموبايل -->
    <button 
      v-if="!isAuthPage"
      @click="mobileMenuOpen = !mobileMenuOpen"
      class="md:hidden fixed top-4 left-4 z-50 bg-blue-600 text-white p-3 rounded-lg shadow-lg no-print"
    >
      <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
              :d="mobileMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'" />
      </svg>
    </button>

    <!-- الشريط الجانبي -->
    <aside 
      v-if="!isAuthPage"
      :class="[
        'bg-gradient-to-b from-blue-700 to-blue-900 text-white w-64 fixed md:relative h-screen md:h-auto z-40 transition-transform duration-300 no-print flex flex-col overflow-y-auto',
        mobileMenuOpen ? 'translate-x-0' : 'translate-x-full md:translate-x-0'
      ]"
    >
      <!-- الهيدر مع الشعار -->
      <div class="p-6 border-b border-blue-600 flex flex-col items-center justify-center">
        <img 
          src="../icon/icon.png" 
          alt="شعار الموقع" 
          class="w-16 h-16 object-contain mb-2 rounded-lg bg-white/10 p-1 shadow-sm"
          @error="handleImageError"
          v-if="logoLoaded"
        />
        <h1 class="text-xl font-bold text-center">{{ storeName }}</h1>
        <p class="text-blue-200 text-sm text-center mt-1">نظام إدارة الأقساط</p>
      </div>

      <!-- قسم الدعم الفني -->
      <div class="p-3 border-b border-blue-600/50 bg-blue-800/40 m-3 rounded-xl text-center space-y-2">
        <p class="text-xs text-blue-200 font-medium">الدعم الفني والخدمة</p>
        
        <a 
          href="tel:07706118992" 
          class="flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-500 text-white py-2 px-3 rounded-lg text-sm transition font-sans"
        >
          <span>📞</span>
          <span dir="ltr">07706118992</span>
        </a>

        <a 
          href="https://wa.me/9647706118992" 
          target="_blank" 
          rel="noopener noreferrer"
          class="flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-500 text-white py-2 px-3 rounded-lg text-sm transition"
        >
          <span>💬</span>
          <span>مراسلة واتساب</span>
        </a>
      </div>

      <!-- قائمة الروابط -->
      <nav class="p-4 space-y-1 flex-1">
        <router-link 
          v-for="link in links" 
          :key="link.path"
          :to="link.path"
          @click="mobileMenuOpen = false"
          class="flex items-center gap-3 px-4 py-3 rounded-lg hover:bg-blue-600 transition"
          :class="{ 'bg-blue-600': $route.path === link.path }"
        >
          <span class="text-2xl">{{ link.icon }}</span>
          <span class="font-medium">{{ link.label }}</span>
        </router-link>
      </nav>

      <!-- قسم تحميل تطبيق الموبايل -->
      <div class="p-3 border-t border-blue-600/50 bg-blue-950/40 m-3 rounded-xl text-center space-y-2">
        <p class="text-xs text-blue-200 font-medium">تحميل تطبيق الموبايل</p>
        
        <div class="grid grid-cols-2 gap-2">
          <!-- زر تحميل أندرويد -->
          <a 
            href="../mobileapp/androidap.apk" 
            download
            class="flex flex-col items-center justify-center gap-1 bg-green-600 hover:bg-green-500 text-white py-2 px-2 rounded-lg text-xs transition"
          >
            <span class="text-lg">🤖</span>
            <span>تطبيق Android</span>
          </a>

          <!-- زر تحميل آيفون -->
		  
          <a 
            href="" 
            
            class="flex flex-col items-center justify-center gap-1 bg-slate-700 hover:bg-slate-600 text-white py-2 px-2 rounded-lg text-xs transition"
          > 
		 
            <span class="text-lg">🍎</span>
            <span>تطبيق  iphone  قريبا </span>
          </a>
        </div>
      </div>

      <div class="p-3 text-center text-blue-300 text-[10px]">
        v1.0.0
      </div>
    </aside>

    <!-- المحتوى الرئيسي -->
    <main :class="['flex-1 overflow-x-hidden', isAuthPage ? 'p-0' : 'p-4 md:p-8']">
      <!-- تنبيه اقتراب انتهاء الاشتراك -->
      <div
        v-if="!isAuthPage && showExpiryWarning"
        class="mb-4 bg-red-50 border-2 border-red-400 text-red-800 rounded-xl p-4 flex flex-col md:flex-row md:items-center md:justify-between gap-3 no-print"
      >
        <div class="flex items-center gap-2 font-bold">
          <span class="text-xl">⚠️</span>
          <span>
            {{ expiryMessage }}
          </span>
        </div>
        <div class="flex gap-2 shrink-0">
          <a
            href="tel:07706118992"
            class="flex items-center justify-center gap-2 bg-red-600 hover:bg-red-700 text-white py-2 px-3 rounded-lg text-sm transition"
          >
            <span>📞</span>
            <span dir="ltr">07706118992</span>
          </a>
          <a
            href="https://wa.me/9647706118992"
            target="_blank"
            rel="noopener noreferrer"
            class="flex items-center justify-center gap-2 bg-emerald-600 hover:bg-emerald-500 text-white py-2 px-3 rounded-lg text-sm transition"
          >
            <span>💬</span>
            <span>واتساب</span>
          </a>
        </div>
      </div>

      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" @settings-updated="loadSettings" />
        </transition>
      </router-view>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, provide, computed } from 'vue'
import { useRoute } from 'vue-router'
import api from './api'

const route = useRoute()
const mobileMenuOpen = ref(false)
const storeName = ref('متجري')
const settings = ref({})
const logoLoaded = ref(true)

const handleImageError = () => {
  logoLoaded.value = false
}

const isAuthPage = computed(() => ['/login', '/register'].includes(route.path) || route.path.startsWith('/admin'))

const links = [
  { path: '/', label: 'لوحة التحكم', icon: '🏠' },
  { path: '/products', label: 'المواد', icon: '📦' },
  { path: '/inventory', label: 'المخزن', icon: '🏪' },
  { path: '/new-sale', label: 'إضافة بيع', icon: '➕' },
  { path: '/customers', label: 'المشترين', icon: '👥' },
  { path: '/upcoming', label: 'الأقساط القادمة', icon: '🔔' },
  { path: '/reports', label: 'التقارير', icon: '📊' },
  { path: '/settings', label: 'الإعدادات', icon: '⚙️' }
]

const loadSettings = async () => {
  try {
    const res = await api.getSettings()
    if (res.success) {
      settings.value = res.data
      storeName.value = res.data.store_name || 'متجري'
    }
  } catch (e) {
    console.error('فشل تحميل الإعدادات')
  }
}

// عدد الأيام المتبقية على انتهاء الاشتراك (يأتي من settings.php)
const remainingDays = computed(() => {
  const val = settings.value.subscription_remaining_days
  if (val === null || val === undefined || val === '') return null
  return Number(val)
})

// إظهار التنبيه فقط عندما يتبقى يومان أو أقل (ولم ينتهِ الاشتراك بعد)
const showExpiryWarning = computed(() => {
  return remainingDays.value !== null && remainingDays.value >= 0 && remainingDays.value <= 2
})

const expiryMessage = computed(() => {
  const days = remainingDays.value
  if (days === 0) {
    return 'تنبيه: سينتهي اشتراكك اليوم! يرجى التواصل معنا لتجديد الاشتراك.'
  }
  if (days === 1) {
    return 'تنبيه: سينتهي اشتراكك غداً! يرجى التواصل معنا لتجديد الاشتراك.'
  }
  return `تنبيه: سينتهي اشتراكك خلال ${days} يومين! يرجى التواصل معنا لتجديد الاشتراك.`
})

provide('settings', settings)
provide('reloadSettings', loadSettings)

onMounted(() => {
  if (!isAuthPage.value) {
    loadSettings()
  }
})
</script>