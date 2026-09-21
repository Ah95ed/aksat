<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">🔔 الأقساط القادمة والمتأخرة</h1>

    <!-- الفلاتر -->
    <div class="card mb-4">
      <div class="flex flex-wrap gap-2">
        <button 
          v-for="f in filters" 
          :key="f.value"
          @click="filter = f.value"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition',
            filter === f.value ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          ]"
        >
          {{ f.label }}
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <div v-else-if="installments.length === 0" class="card text-center py-12 text-gray-500">
      ✨ لا توجد أقساط في هذه الفئة
    </div>

    <div v-else class="card overflow-x-auto">
      <table class="w-full text-right text-sm">
        <thead>
          <tr class="border-b-2 border-gray-200 text-gray-700">
            <th class="py-3 px-2">المشتري</th>
            <th class="py-3 px-2 hidden md:table-cell">الهاتف</th>
            <th class="py-3 px-2">المادة</th>
            <th class="py-3 px-2">القسط</th>
            <th class="py-3 px-2">المبلغ</th>
            <th class="py-3 px-2">تاريخ الاستحقاق</th>
            <th class="py-3 px-2">الحالة</th>
            <th class="py-3 px-2">الإجراءات</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="inst in installments" 
            :key="inst.id"
            class="border-b border-gray-100 hover:bg-gray-50"
            :class="{ 'bg-red-50': inst.status === 'late' }"
          >
            <td class="py-3 px-2">
              <router-link 
                :to="`/customers/${inst.customer_id}`"
                class="font-medium text-blue-700 hover:underline"
              >
                {{ inst.customer_name }}
              </router-link>
            </td>
            <td class="py-3 px-2 hidden md:table-cell text-gray-600" dir="ltr">
              {{ inst.customer_phone }}
            </td>
            <td class="py-3 px-2">{{ inst.product_name }}</td>
            <td class="py-3 px-2">#{{ inst.installment_number }}</td>
            <td class="py-3 px-2 font-bold">
              {{ formatAmount(inst.amount) }} {{ inst.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings) }}
            </td>
            <td class="py-3 px-2">
              <div>{{ formatDateShort(inst.due_date) }}</div>
              <div class="text-xs" :class="daysClass(inst.due_date)">
                {{ daysUntilText(inst.due_date) }}
              </div>
            </td>
            <td class="py-3 px-2">
              <span v-if="inst.status === 'late'" class="badge-danger">⚠️ متأخر</span>
              <span v-else class="badge-info">⏳ قادم</span>
            </td>
            <td class="py-3 px-2">
              <div class="flex gap-1">
                <button 
                  @click="payInstallment(inst.id)"
                  class="bg-green-600 text-white px-2 py-1 rounded text-xs hover:bg-green-700"
                  title="دفع"
                >
                  💵
                </button>
                <button 
                  @click="sendWhatsApp(inst)"
                  class="bg-green-500 text-white px-2 py-1 rounded text-xs hover:bg-green-600"
                  title="واتساب"
                >
                  💬
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, inject } from 'vue'
import api from '../api'
import { 
  formatAmount, 
  formatDateShort, 
  currencySymbol, 
  daysUntilText, 
  daysUntil,
  whatsappLink 
} from '../helpers'

const settings = inject('settings', ref({}))

const installments = ref([])
const loading = ref(true)
const filter = ref('late')

const filters = [
  { value: 'late', label: '⚠️ المتأخرة' },
  { value: 'upcoming_week', label: '📅 هذا الأسبوع' },
  { value: 'upcoming_month', label: '📆 هذا الشهر' },
  { value: 'all', label: '📋 الكل' },
  { value: 'paid', label: '✅ المدفوعة' }
]

const load = async () => {
  loading.value = true
  try {
    const res = await api.getInstallments(filter.value)
    if (res.success) installments.value = res.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const daysClass = (date) => {
  const d = daysUntil(date)
  if (d < 0) return 'text-red-700 font-bold'
  if (d <= 3) return 'text-amber-700 font-bold'
  return 'text-gray-500'
}

const payInstallment = async (id) => {
  if (!confirm('تأكيد دفع هذا القسط؟')) return
  try {
    await api.payInstallment(id)
    await load()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  }
}

const sendWhatsApp = (inst) => {
  const template = settings.value.whatsapp_template || 
    `السلام عليكم {customer_name}،\nنذكركم بقسط {product_name}\nالمبلغ: {amount} {currency}\nتاريخ الاستحقاق: {due_date}\nشكراً لتعاملكم معنا.`
  
  const message = template
    .replace('{customer_name}', inst.customer_name)
    .replace('{product_name}', inst.product_name)
    .replace('{amount}', formatAmount(inst.amount))
    .replace('{currency}', inst.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings.value))
    .replace('{due_date}', formatDateShort(inst.due_date))
  
  window.open(whatsappLink(inst.customer_phone, message), '_blank')
}

watch(filter, load)
onMounted(load)
</script>
