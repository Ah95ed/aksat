<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">⚙️ الإعدادات</h1>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <div v-else class="space-y-6 max-w-3xl">
      <!-- معلومات المتجر -->
      <div class="card">
        <h2 class="text-xl font-bold text-blue-700 mb-4 pb-2 border-b border-gray-200">
          🏪 معلومات المتجر
        </h2>
        <div class="space-y-4">
          <div>
            <label class="label">اسم المتجر</label>
            <input v-model="form.store_name" type="text" class="input" />
          </div>
        </div>
      </div>

      <!-- إعدادات العملة -->
      <div class="card">
        <h2 class="text-xl font-bold text-blue-700 mb-4 pb-2 border-b border-gray-200">
          💱 إعدادات العملة
        </h2>
        <div class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="label">اسم العملة المحلية</label>
              <input v-model="form.currency_name" type="text" class="input" placeholder="مثال: دينار، ريال، جنيه" />
            </div>
            <div>
              <label class="label">رمز العملة</label>
              <input v-model="form.currency_symbol" type="text" class="input" placeholder="مثال: د.ع، ر.س" />
            </div>
          </div>

          <div>
            <label class="label">سعر صرف الدولار (1$ = ?)</label>
            <input v-model="form.exchange_rate" type="number" min="0" step="0.01" class="input" />
            <p class="text-xs text-gray-500 mt-1">
              أدخل قيمة الدولار الواحد بالعملة المحلية. مثال: 1450 للدينار العراقي
            </p>
          </div>
        </div>
      </div>

      <!-- قالب رسالة واتساب -->
      <div class="card">
        <h2 class="text-xl font-bold text-blue-700 mb-4 pb-2 border-b border-gray-200">
          💬 قالب رسالة الواتساب
        </h2>
        <div>
          <label class="label">القالب</label>
          <textarea v-model="form.whatsapp_template" rows="6" class="input font-mono text-sm"></textarea>
          <div class="mt-2 text-xs text-gray-600 space-y-1">
            <p>المتغيرات المتاحة:</p>
            <ul class="list-disc list-inside space-y-1 text-gray-500">
              <li><code class="bg-gray-100 px-1">{customer_name}</code> - اسم المشتري</li>
              <li><code class="bg-gray-100 px-1">{product_name}</code> - اسم المادة</li>
              <li><code class="bg-gray-100 px-1">{amount}</code> - مبلغ القسط</li>
              <li><code class="bg-gray-100 px-1">{currency}</code> - رمز العملة</li>
              <li><code class="bg-gray-100 px-1">{due_date}</code> - تاريخ الاستحقاق</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- أزرار الحفظ -->
      <div class="flex gap-3">
        <button @click="save" :disabled="saving" class="btn-primary flex-1 md:flex-none">
          {{ saving ? '⏳ جاري الحفظ...' : '💾 حفظ التغييرات' }}
        </button>
      </div>

      <!-- معلومات النظام -->
      <div class="card bg-gray-50">
        <h2 class="text-xl font-bold text-gray-700 mb-4">ℹ️ معلومات النظام</h2>
        <div class="space-y-2 text-sm">
          <div class="flex justify-between">
            <span class="text-gray-600">إصدار النظام:</span>
            <span class="font-bold">1.0.0</span>
          </div>
          <div class="flex justify-between">
            <span class="text-gray-600">حالة قاعدة البيانات:</span>
            <span class="badge-success">متصلة</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import api from '../api'

const emit = defineEmits(['settings-updated'])
const reloadSettings = inject('reloadSettings')

const loading = ref(true)
const saving = ref(false)
const form = ref({
  store_name: '',
  currency_name: 'دينار',
  currency_symbol: 'د.ع',
  exchange_rate: '1450',
  whatsapp_template: ''
})

const load = async () => {
  loading.value = true
  try {
    const res = await api.getSettings()
    if (res.success) {
      form.value = { ...form.value, ...res.data }
    }
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const save = async () => {
  saving.value = true
  try {
    await api.updateSettings(form.value)
    alert('✅ تم حفظ الإعدادات')
    if (reloadSettings) reloadSettings()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>
