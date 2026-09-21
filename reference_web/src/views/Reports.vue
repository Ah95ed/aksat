<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">📊 التقارير والأرباح</h1>

    <!-- شريط التصفية -->
    <div class="card mb-4">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="label">الفترة الزمنية</label>
          <select v-model="filters.period" @change="loadAll" class="input">
            <option value="today">اليوم</option>
            <option value="week">آخر 7 أيام</option>
            <option value="month">هذا الشهر</option>
            <option value="last_month">الشهر الماضي</option>
            <option value="year">هذه السنة</option>
            <option value="all">كل الوقت</option>
            <option value="custom">فترة مخصصة</option>
          </select>
        </div>
        
        <template v-if="filters.period === 'custom'">
          <div>
            <label class="label">من تاريخ</label>
            <input v-model="filters.from" type="date" class="input" @change="loadAll" />
          </div>
          <div>
            <label class="label">إلى تاريخ</label>
            <input v-model="filters.to" type="date" class="input" @change="loadAll" />
          </div>
        </template>
        
        <div v-else>
          <label class="label">العملة</label>
          <select v-model="filters.currency" @change="loadAll" class="input">
            <option value="all">كل العملات</option>
            <option value="USD">دولار 💵</option>
            <option value="LOCAL">{{ currencyName('LOCAL', settings) }} 🪙</option>
          </select>
        </div>
      </div>
    </div>

    <!-- تابات التقارير -->
    <div class="card mb-4">
      <div class="flex flex-wrap gap-2">
        <button 
          v-for="t in tabs" 
          :key="t.value"
          @click="activeTab = t.value"
          :class="[
            'px-4 py-2 rounded-lg font-medium transition',
            activeTab === t.value ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
          ]"
        >
          {{ t.icon }} {{ t.label }}
        </button>
      </div>
    </div>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <!-- التاب: ملخص الأرباح -->
    <div v-else-if="activeTab === 'summary'" class="space-y-4">
      <div v-if="!summary" class="card text-center py-12 text-gray-500">
        لا توجد بيانات
      </div>
      
      <div v-else>
        <!-- بطاقات كل عملة -->
        <div v-for="cur in ['USD', 'LOCAL']" :key="cur" class="mb-6">
          <div v-if="summary[cur].sales_count > 0" class="card">
            <h2 class="text-xl font-bold mb-4 pb-2 border-b border-gray-200">
              {{ cur === 'USD' ? '💵 الدولار' : '🪙 ' + currencyName('LOCAL', settings) }}
            </h2>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
              <div class="bg-blue-50 p-4 rounded-lg">
                <div class="text-xs text-gray-600 mb-1">عدد المبيعات</div>
                <div class="text-2xl font-bold text-blue-700">{{ summary[cur].sales_count }}</div>
              </div>
              <div class="bg-indigo-50 p-4 rounded-lg">
                <div class="text-xs text-gray-600 mb-1">عدد القطع</div>
                <div class="text-2xl font-bold text-indigo-700">{{ summary[cur].items_sold }}</div>
              </div>
              <div class="bg-purple-50 p-4 rounded-lg">
                <div class="text-xs text-gray-600 mb-1">إجمالي الإيرادات</div>
                <div class="text-xl font-bold text-purple-700">
                  {{ formatAmount(summary[cur].total_revenue) }} {{ symbolFor(cur) }}
                </div>
              </div>
              <div class="bg-amber-50 p-4 rounded-lg">
                <div class="text-xs text-gray-600 mb-1">إجمالي التكلفة</div>
                <div class="text-xl font-bold text-amber-700">
                  {{ formatAmount(summary[cur].total_cost) }} {{ symbolFor(cur) }}
                </div>
              </div>
            </div>

            <!-- الأرباح -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="bg-gradient-to-br from-green-50 to-green-100 p-5 rounded-lg border-2 border-green-300">
                <div class="text-sm text-gray-700 mb-1">💰 الربح المتوقع (كل المبيعات)</div>
                <div class="text-3xl font-bold text-green-700">
                  {{ formatAmount(summary[cur].expected_profit) }} {{ symbolFor(cur) }}
                </div>
                <div class="text-xs text-gray-600 mt-2">
                  هامش الربح: {{ profitMargin(summary[cur].expected_profit, summary[cur].total_revenue) }}%
                </div>
              </div>

              <div class="bg-gradient-to-br from-blue-50 to-blue-100 p-5 rounded-lg border-2 border-blue-300">
                <div class="text-sm text-gray-700 mb-1">✅ الربح الفعلي (المُحصَّل)</div>
                <div class="text-3xl font-bold text-blue-700">
                  {{ formatAmount(summary[cur].actual_profit) }} {{ symbolFor(cur) }}
                </div>
                <div class="text-xs text-gray-600 mt-2">
                  من إجمالي {{ formatAmount(summary[cur].total_collected) }} {{ symbolFor(cur) }} مُحصَّل
                </div>
              </div>
            </div>
            
            <div class="mt-3 text-xs text-gray-500 bg-gray-50 p-2 rounded">
              💡 الربح المتوقع: يحسب جميع المبيعات حتى لو لم تُدفع جميع الأقساط<br>
              💡 الربح الفعلي: يحسب الجزء المُحصَّل فعلياً (نسبة من المتوقع)
            </div>
          </div>
        </div>

        <div v-if="summary.USD.sales_count === 0 && summary.LOCAL.sales_count === 0" 
             class="card text-center py-12 text-gray-500">
          لا توجد مبيعات في هذه الفترة
        </div>
      </div>
    </div>

    <!-- التاب: ربح كل مادة -->
    <div v-else-if="activeTab === 'by_product'" class="card overflow-x-auto">
      <div v-if="byProduct.length === 0" class="text-center py-12 text-gray-500">
        لا توجد بيانات
      </div>
      <table v-else class="w-full text-right">
        <thead>
          <tr class="border-b-2 border-gray-200">
            <th class="py-3 px-3">#</th>
            <th class="py-3 px-3">المادة</th>
            <th class="py-3 px-3">الكمية المباعة</th>
            <th class="py-3 px-3">إيرادات</th>
            <th class="py-3 px-3">تكلفة</th>
            <th class="py-3 px-3">الربح</th>
            <th class="py-3 px-3">الهامش</th>
            <th class="py-3 px-3">العملة</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(p, i) in byProduct" 
            :key="i"
            class="border-b border-gray-100 hover:bg-gray-50"
          >
            <td class="py-3 px-3">{{ i + 1 }}</td>
            <td class="py-3 px-3 font-medium">{{ p.product_name }}</td>
            <td class="py-3 px-3">{{ p.total_quantity }}</td>
            <td class="py-3 px-3 text-purple-700">{{ formatAmount(p.total_revenue) }}</td>
            <td class="py-3 px-3 text-amber-700">{{ formatAmount(p.total_cost) }}</td>
            <td class="py-3 px-3 font-bold" :class="p.expected_profit >= 0 ? 'text-green-700' : 'text-red-700'">
              {{ formatAmount(p.expected_profit) }}
            </td>
            <td class="py-3 px-3 text-sm">
              {{ profitMargin(p.expected_profit, p.total_revenue) }}%
            </td>
            <td class="py-3 px-3">
              <span :class="p.currency === 'USD' ? 'badge-info' : 'badge-warning'">
                {{ p.currency === 'USD' ? '$' : symbolFor('LOCAL') }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- التاب: أكثر المواد مبيعاً -->
    <div v-else-if="activeTab === 'top_selling'" class="card">
      <div v-if="topSelling.length === 0" class="text-center py-12 text-gray-500">
        لا توجد بيانات
      </div>
      <div v-else class="space-y-3">
        <div 
          v-for="(p, i) in topSelling" 
          :key="i"
          class="flex items-center gap-4 p-4 rounded-lg"
          :class="i < 3 ? 'bg-gradient-to-l from-yellow-50 to-orange-50 border-2 border-yellow-300' : 'bg-gray-50'"
        >
          <div class="text-3xl font-bold w-12 text-center" :class="i < 3 ? 'text-yellow-600' : 'text-gray-400'">
            {{ rankIcon(i) }}
          </div>
          <div class="flex-1">
            <div class="font-bold text-lg">{{ p.product_name }}</div>
            <div class="text-sm text-gray-600">
              {{ p.sales_count }} عملية بيع • {{ p.total_quantity }} قطعة
            </div>
          </div>
          <div class="text-left">
            <div class="text-xs text-gray-500">الربح</div>
            <div class="font-bold text-green-700">
              {{ formatAmount(p.expected_profit) }} {{ p.currency === 'USD' ? '$' : symbolFor('LOCAL') }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- التاب: الأرباح حسب الفترة -->
    <div v-else-if="activeTab === 'timeline'" class="card overflow-x-auto">
      <div class="flex gap-2 mb-4 flex-wrap">
        <button 
          v-for="g in ['day', 'week', 'month', 'year']" 
          :key="g"
          @click="changeGroupBy(g)"
          :class="[
            'px-3 py-1 rounded-lg text-sm',
            filters.groupBy === g ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700'
          ]"
        >
          {{ groupByLabel(g) }}
        </button>
      </div>
      
      <div v-if="timeline.length === 0" class="text-center py-12 text-gray-500">
        لا توجد بيانات
      </div>
      <table v-else class="w-full text-right">
        <thead>
          <tr class="border-b-2 border-gray-200">
            <th class="py-3 px-3">الفترة</th>
            <th class="py-3 px-3">عدد المبيعات</th>
            <th class="py-3 px-3">القطع المباعة</th>
            <th class="py-3 px-3">الإيرادات</th>
            <th class="py-3 px-3">التكلفة</th>
            <th class="py-3 px-3">الربح</th>
            <th class="py-3 px-3">العملة</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(t, i) in timeline" 
            :key="i"
            class="border-b border-gray-100 hover:bg-gray-50"
          >
            <td class="py-3 px-3 font-medium">{{ formatPeriod(t.period) }}</td>
            <td class="py-3 px-3">{{ t.sales_count }}</td>
            <td class="py-3 px-3">{{ t.items_sold }}</td>
            <td class="py-3 px-3 text-purple-700">{{ formatAmount(t.total_revenue) }}</td>
            <td class="py-3 px-3 text-amber-700">{{ formatAmount(t.total_cost) }}</td>
            <td class="py-3 px-3 font-bold" :class="t.expected_profit >= 0 ? 'text-green-700' : 'text-red-700'">
              {{ formatAmount(t.expected_profit) }}
            </td>
            <td class="py-3 px-3">
              <span :class="t.currency === 'USD' ? 'badge-info' : 'badge-warning'">
                {{ t.currency === 'USD' ? '$' : symbolFor('LOCAL') }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, inject, watch } from 'vue'
import api from '../api'
import { formatAmount, currencyName, currencySymbol } from '../helpers'

const settings = inject('settings', ref({}))

const loading = ref(false)
const activeTab = ref('summary')
const summary = ref(null)
const byProduct = ref([])
const topSelling = ref([])
const timeline = ref([])

const filters = reactive({
  period: 'month',
  currency: 'all',
  groupBy: 'month',
  from: '',
  to: ''
})

const tabs = [
  { value: 'summary', label: 'ملخص الأرباح', icon: '💰' },
  { value: 'by_product', label: 'ربح كل مادة', icon: '📦' },
  { value: 'top_selling', label: 'أكثر مبيعاً', icon: '🏆' },
  { value: 'timeline', label: 'الأرباح حسب الفترة', icon: '📈' }
]

const symbolFor = (cur) => {
  return cur === 'USD' ? '$' : currencySymbol('LOCAL', settings.value)
}

const profitMargin = (profit, revenue) => {
  if (!revenue || revenue == 0) return '0'
  return ((profit / revenue) * 100).toFixed(1)
}

const rankIcon = (i) => {
  if (i === 0) return '🥇'
  if (i === 1) return '🥈'
  if (i === 2) return '🥉'
  return `#${i + 1}`
}

const groupByLabel = (g) => {
  const labels = { day: 'يومي', week: 'أسبوعي', month: 'شهري', year: 'سنوي' }
  return labels[g] || g
}

const formatPeriod = (period) => {
  if (!period) return '-'
  // التحقق من نوع التنسيق
  if (period.includes('-W')) {
    return period.replace('-W', ' الأسبوع ')
  }
  if (period.length === 7) {
    // YYYY-MM
    const [year, month] = period.split('-')
    const months = ['يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر']
    return `${months[parseInt(month) - 1]} ${year}`
  }
  if (period.length === 4) {
    return period
  }
  // تاريخ كامل
  return new Date(period).toLocaleDateString('ar-EG', { year: 'numeric', month: 'long', day: 'numeric' })
}

const changeGroupBy = (g) => {
  filters.groupBy = g
  loadTimeline()
}

const loadSummary = async () => {
  try {
    const res = await api.getReportSummary(filters.period, filters.currency, filters.from, filters.to)
    if (res.success) summary.value = res.data
  } catch (e) {
    console.error(e)
  }
}

const loadByProduct = async () => {
  try {
    const res = await api.getReportByProduct(filters.period, filters.currency, filters.from, filters.to)
    if (res.success) byProduct.value = res.data
  } catch (e) {
    console.error(e)
  }
}

const loadTopSelling = async () => {
  try {
    const res = await api.getTopSelling(filters.period, filters.currency, filters.from, filters.to)
    if (res.success) topSelling.value = res.data
  } catch (e) {
    console.error(e)
  }
}

const loadTimeline = async () => {
  try {
    const res = await api.getReportTimeline(filters.period, filters.groupBy, filters.currency, filters.from, filters.to)
    if (res.success) timeline.value = res.data
  } catch (e) {
    console.error(e)
  }
}

const loadAll = async () => {
  loading.value = true
  await Promise.all([
    loadSummary(),
    loadByProduct(),
    loadTopSelling(),
    loadTimeline()
  ])
  loading.value = false
}

onMounted(loadAll)
</script>
