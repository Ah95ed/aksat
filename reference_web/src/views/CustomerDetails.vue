<template>
  <div>
    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <div v-else-if="!customer" class="card text-center py-12 text-gray-500">
      المشتري غير موجود
    </div>

    <div v-else class="space-y-6">
      <!-- شريط الإجراءات -->
      <div class="flex flex-wrap gap-2 no-print">
        <router-link to="/customers" class="btn-secondary">
          → العودة للقائمة
        </router-link>
      </div>

      <!-- بطاقة معلومات المشتري -->
      <div class="card">
        <div class="flex flex-col md:flex-row justify-between items-start gap-4">
          <div class="flex items-center gap-4">
            <div class="w-20 h-20 rounded-full bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center text-4xl text-white">
              👤
            </div>
            <div>
              <h1 class="text-2xl md:text-3xl font-bold text-gray-800">{{ customer.name }}</h1>
              <p class="text-gray-600 mt-1" dir="ltr">📞 {{ customer.phone }}</p>
              <p v-if="customer.address" class="text-gray-500 text-sm mt-1">📍 {{ customer.address }}</p>
            </div>
          </div>
        </div>

        <!-- الإحصائيات - تظهر على الشاشة فقط ولا تدخل في الطباعة -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mt-6 no-print">
          <div class="bg-blue-50 p-3 rounded-lg text-center">
            <div class="text-2xl font-bold text-blue-700">{{ customer.sales.length }}</div>
            <div class="text-sm text-gray-600">إجمالي البيوع</div>
          </div>
          <div class="bg-green-50 p-3 rounded-lg text-center">
            <div class="text-2xl font-bold text-green-700">{{ activeSales.length }}</div>
            <div class="text-sm text-gray-600">نشط</div>
          </div>
          <div class="bg-purple-50 p-3 rounded-lg text-center">
            <div class="text-2xl font-bold text-purple-700">{{ completedSales.length }}</div>
            <div class="text-sm text-gray-600">مكتمل</div>
          </div>
          <div class="bg-red-50 p-3 rounded-lg text-center">
            <div class="text-2xl font-bold text-red-700">{{ totalLateCount }}</div>
            <div class="text-sm text-gray-600">قسط متأخر</div>
          </div>
        </div>
      </div>

      <!-- عرض كل عملية بيع -->
      <div v-if="customer.sales.length === 0" class="card text-center py-12 text-gray-500">
        لا توجد مبيعات لهذا المشتري
      </div>

      <div
        v-for="sale in customer.sales"
        :key="sale.id"
        class="card sale-card"
        :data-sale-id="sale.id"
        :class="{ 'border-2 border-green-300': sale.status === 'completed' }"
      >
        <!-- رأس البيع -->
        <div class="flex flex-col md:flex-row justify-between items-start gap-3 pb-4 border-b border-gray-200">
          <div>
            <h2 class="text-xl font-bold text-gray-800">
              📦 {{ sale.product_name }}
              <span v-if="sale.quantity > 1" class="badge-info mr-2">× {{ sale.quantity }}</span>
              <span v-if="sale.status === 'completed'" class="badge-success mr-2">✅ مكتمل</span>
              <span v-else-if="sale.late_count > 0" class="badge-danger mr-2">⚠️ متأخر</span>
              <span v-else class="badge-info mr-2">🔄 نشط</span>
            </h2>
            <p class="text-sm text-gray-500 mt-1">تاريخ البيع: {{ formatDateNumeric(sale.sale_date) }}</p>
          </div>

          <!-- إجراءات عملية البيع - لا تظهر في الطباعة -->
          <div class="flex gap-2 no-print">
            <button @click="printSale(sale.id)" class="btn-primary text-sm">
              🖨️ طباعة
            </button>

            <button @click="sendWhatsApp(sale)" class="btn-success text-sm">
              💬 واتساب
            </button>

            <button @click="toggleCurrency(sale.id)" class="btn-secondary text-sm">
              💱 {{ displayCurrency[sale.id] === 'OTHER' ? 'الأصلية' : 'تبديل' }}
            </button>
          </div>
        </div>

        <!-- ملخص البيع -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 my-4">
          <div class="bg-gray-50 p-3 rounded-lg">
            <div class="text-xs text-gray-600">السعر الكلي</div>
            <div class="font-bold text-lg">
              {{ formatAmount(getDisplayAmount(sale.total_price, sale.currency, sale.id)) }}
              {{ getDisplaySymbol(sale.currency, sale.id) }}
            </div>
          </div>
          <div class="bg-amber-50 p-3 rounded-lg">
            <div class="text-xs text-gray-600">المقدمة</div>
            <div class="font-bold text-lg text-amber-700">
              {{ formatAmount(getDisplayAmount(sale.down_payment, sale.currency, sale.id)) }}
              {{ getDisplaySymbol(sale.currency, sale.id) }}
            </div>
          </div>
          <div class="bg-green-50 p-3 rounded-lg">
            <div class="text-xs text-gray-600">المدفوع</div>
            <div class="font-bold text-lg text-green-700">
              {{ formatAmount(getDisplayAmount(parseFloat(sale.paid_amount) + parseFloat(sale.down_payment), sale.currency, sale.id)) }}
              {{ getDisplaySymbol(sale.currency, sale.id) }}
            </div>
          </div>
          <div class="bg-blue-50 p-3 rounded-lg">
            <div class="text-xs text-gray-600">المتبقي</div>
            <div class="font-bold text-lg text-blue-700">
              {{ formatAmount(getDisplayAmount(sale.remaining - sale.paid_amount, sale.currency, sale.id)) }}
              {{ getDisplaySymbol(sale.currency, sale.id) }}
            </div>
          </div>
        </div>

        <!-- شريط التقدم -->
        <div class="mb-4">
          <div class="flex justify-between text-sm mb-1">
            <span class="text-gray-600">التقدم</span>
            <span class="font-bold">{{ sale.paid_count }} / {{ sale.installments.length }} قسط</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-3">
            <div
              class="bg-gradient-to-r from-green-500 to-green-600 h-3 rounded-full transition-all"
              :style="`width: ${(sale.paid_count / sale.installments.length) * 100}%`"
            ></div>
          </div>
        </div>

        <!-- جدول الأقساط -->
        <div class="overflow-x-auto">
          <table class="w-full text-right text-sm">
            <thead>
              <tr class="border-b-2 border-gray-200 text-gray-700">
                <th class="py-2 px-2">#</th>
                <th class="py-2 px-2">تاريخ الاستحقاق</th>
                <th class="py-2 px-2">المبلغ</th>
                <th class="py-2 px-2">الحالة</th>
                <th class="py-2 px-2">تاريخ الدفع</th>
                <th class="py-2 px-2 no-print">الإجراءات</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="inst in sale.installments"
                :key="inst.id"
                class="border-b border-gray-100"
                :class="{
                  'bg-red-50': inst.status === 'late',
                  'bg-green-50': inst.status === 'paid'
                }"
              >
                <td class="py-3 px-2 font-bold">{{ inst.installment_number }}</td>
                <td class="py-3 px-2">{{ formatDateShort(inst.due_date) }}</td>
                <td class="py-3 px-2 font-bold">
                  {{ formatAmount(getDisplayAmount(inst.amount, sale.currency, sale.id)) }}
                  {{ getDisplaySymbol(sale.currency, sale.id) }}
                </td>
                <td class="py-3 px-2">
                  <span v-if="inst.status === 'paid'" class="badge-success">✅ مدفوع</span>
                  <span v-else-if="inst.status === 'late'" class="badge-danger">⚠️ متأخر</span>
                  <span v-else class="badge-info">⏳ قادم</span>
                </td>
                <td class="py-3 px-2 text-gray-600">
                  {{ inst.paid_date ? formatDateShort(inst.paid_date) : '-' }}
                </td>
                <td class="py-3 px-2 no-print">
                  <button
                    v-if="inst.status !== 'paid'"
                    @click="payInstallment(inst.id)"
                    class="bg-green-600 text-white px-3 py-1 rounded text-xs hover:bg-green-700"
                  >
                    💵 دفع
                  </button>
                  <button
                    v-else
                    @click="unpayInstallment(inst.id)"
                    class="bg-gray-500 text-white px-3 py-1 rounded text-xs hover:bg-gray-600"
                  >
                    ↩️ إلغاء
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="sale.notes" class="mt-4 p-3 bg-yellow-50 border-r-4 border-yellow-400 text-sm text-gray-700">
          📝 {{ sale.notes }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject, reactive } from 'vue'
import { useRoute } from 'vue-router'
import api from '../api'
import {
  formatAmount,
  formatDate,
  formatDateShort,
  currencyName,
  currencySymbol,
  convertCurrency,
  whatsappLink
} from '../helpers'

const route = useRoute()
const settings = inject('settings', ref({}))

const customer = ref(null)
const loading = ref(true)
const displayCurrency = reactive({}) // لكل عملية بيع نحفظ العملة المعروضة

const activeSales = computed(() =>
  customer.value?.sales.filter(s => s.status === 'active') || []
)

const completedSales = computed(() =>
  customer.value?.sales.filter(s => s.status === 'completed') || []
)

const totalLateCount = computed(() =>
  customer.value?.sales.reduce((sum, s) => sum + (s.late_count || 0), 0) || 0
)

const loadCustomer = async () => {
  loading.value = true
  try {
    const res = await api.getCustomer(route.params.id)
    if (res.success) customer.value = res.data
  } catch (e) {
    alert('فشل تحميل البيانات')
  } finally {
    loading.value = false
  }
}

const getDisplayAmount = (amount, originalCurrency, saleId) => {
  if (!displayCurrency[saleId] || displayCurrency[saleId] === 'ORIGINAL') {
    return amount
  }

  // تحويل للعملة الأخرى
  const targetCurrency = originalCurrency === 'USD' ? 'LOCAL' : 'USD'
  return convertCurrency(parseFloat(amount), originalCurrency, targetCurrency, settings.value.exchange_rate)
}

const getDisplaySymbol = (originalCurrency, saleId) => {
  if (!displayCurrency[saleId] || displayCurrency[saleId] === 'ORIGINAL') {
    return originalCurrency === 'USD' ? '$' : currencySymbol('LOCAL', settings.value)
  }

  return originalCurrency === 'USD' ? currencySymbol('LOCAL', settings.value) : '$'
}

const formatDateNumeric = (date) => {
  if (!date) return '-'

  const d = new Date(date)
  if (Number.isNaN(d.getTime())) return '-'

  return `${d.getFullYear()}/${d.getMonth() + 1}/${d.getDate()}`
}

const toggleCurrency = (saleId) => {
  if (!displayCurrency[saleId] || displayCurrency[saleId] === 'ORIGINAL') {
    displayCurrency[saleId] = 'OTHER'
  } else {
    displayCurrency[saleId] = 'ORIGINAL'
  }
}

const payInstallment = async (id) => {
  if (!confirm('تأكيد دفع هذا القسط؟')) return

  try {
    await api.payInstallment(id)
    await loadCustomer()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  }
}

const unpayInstallment = async (id) => {
  if (!confirm('إلغاء دفع هذا القسط؟')) return

  try {
    await api.unpayInstallment(id)
    await loadCustomer()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  }
}

const sendWhatsApp = (sale) => {
  // البحث عن أقرب قسط غير مدفوع
  const nextInst = sale.installments.find(i => i.status !== 'paid')

  const template = settings.value.whatsapp_template ||
    `السلام عليكم {customer_name}،\nنذكركم بقسط {product_name}\nالمبلغ: {amount} {currency}\nتاريخ الاستحقاق: {due_date}\nشكراً لتعاملكم معنا.`

  const message = template
    .replace('{customer_name}', customer.value.name)
    .replace('{product_name}', sale.product_name)
    .replace('{amount}', nextInst ? formatAmount(nextInst.amount) : formatAmount(sale.remaining - sale.paid_amount))
    .replace('{currency}', sale.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings.value))
    .replace('{due_date}', nextInst ? formatDateShort(nextInst.due_date) : '-')

  // تنظيف رقم الهاتف من أية رموز زائدة (مثل + أو مسافات)
  const cleanPhone = customer.value.phone.replace(/\D/g, '')
  const encodedMessage = encodeURIComponent(message)

  // الفحص: هل المستخدم يستخدم هاتف محمول؟
  const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

  // اختيار الرابط المناسب بناءً على نوع الجهاز
  const url = isMobile
    ? `whatsapp://send?phone=${cleanPhone}&text=${encodedMessage}` // يفتح تطبيق الواتساب مباشرة في الموبايل
    : `https://web.whatsapp.com/send?phone=${cleanPhone}&text=${encodedMessage}` // يفتح واتساب ويب في الكمبيوتر

  window.open(url, '_blank')
}

/*
 * طباعة عملية بيع واحدة فقط
 * عند الضغط على زر الطباعة داخل عملية معينة:
 * - نخفي جميع عمليات البيع الأخرى
 * - نخفي الإحصائيات والأزرار التي تحمل no-print
 * - نطبع عملية البيع المحددة فقط
 */
const printSale = (saleId) => {
  // إزالة أي عملية طباعة سابقة
  document.querySelectorAll('.sale-card.print-target').forEach(el => {
    el.classList.remove('print-target')
  })

  // تحديد عملية البيع المطلوبة فقط
  const saleElement = document.querySelector(
    `.sale-card[data-sale-id="${saleId}"]`
  )

  if (!saleElement) return

  saleElement.classList.add('print-target')
  document.body.classList.add('printing-sale')

  // بعد انتهاء نافذة الطباعة نعيد الصفحة إلى وضعها الطبيعي
  const cleanup = () => {
    document.body.classList.remove('printing-sale')
    saleElement.classList.remove('print-target')
    window.removeEventListener('afterprint', cleanup)
  }

  window.addEventListener('afterprint', cleanup)

  window.print()
}

onMounted(loadCustomer)
</script>

<style>
/* ================================
   إعدادات الطباعة
   ================================ */

@media print {
  /* إخفاء جميع العناصر التي تحمل no-print */
  .no-print {
    display: none !important;
  }

  /*
   * عند طباعة عملية معينة:
   * نخفي جميع عمليات البيع الأخرى
   */
  body.printing-sale .sale-card:not(.print-target) {
    display: none !important;
  }

  /* إظهار عملية البيع المحددة فقط */
  body.printing-sale .sale-card.print-target {
    display: block !important;
    width: 100% !important;
    margin: 0 !important;
    padding: 15px !important;
    box-shadow: none !important;
    border: 1px solid #ddd !important;
  }

  /* إخفاء خلفية الصفحة أثناء الطباعة */
  body.printing-sale {
    background: white !important;
  }

  /* إزالة الظلال من البطاقات */
  body.printing-sale .card {
    box-shadow: none !important;
  }

  /* تحسين الجدول للطباعة */
  body.printing-sale table {
    width: 100% !important;
    border-collapse: collapse !important;
  }

  body.printing-sale th,
  body.printing-sale td {
    border-bottom: 1px solid #ddd !important;
    padding: 8px !important;
  }

  /* منع تقسيم صفوف الجدول بين الصفحات */
  body.printing-sale tr {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* منع تقسيم بطاقة البيع قدر الإمكان */
  body.printing-sale .print-target {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* إزالة الحركة من شريط التقدم أثناء الطباعة */
  body.printing-sale * {
    transition: none !important;
  }
}

/* إعداد ورق الطباعة */
@page {
  size: A4;
  margin: 10mm;
}
</style>
