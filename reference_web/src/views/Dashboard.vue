<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">🏠 لوحة التحكم</h1>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      <p class="mt-4 text-gray-600">جاري التحميل...</p>
    </div>

    <div v-else-if="stats" class="space-y-6">
      <!-- بطاقة ربح الشهر السريعة -->
      <div v-if="monthlyProfit && (monthlyProfit.USD.expected_profit > 0 || monthlyProfit.LOCAL.expected_profit > 0)" class="card bg-gradient-to-l from-green-500 to-emerald-600 text-white">
        <div class="flex flex-col md:flex-row justify-between items-start gap-4">
          <div>
            <div class="text-sm opacity-90 mb-1">💰 ربح هذا الشهر (المتوقع)</div>
            <div class="space-y-1">
              <div v-if="monthlyProfit.USD.expected_profit > 0" class="text-2xl md:text-3xl font-bold">
                ${{ formatAmount(monthlyProfit.USD.expected_profit) }}
              </div>
              <div v-if="monthlyProfit.LOCAL.expected_profit > 0" class="text-2xl md:text-3xl font-bold">
                {{ formatAmount(monthlyProfit.LOCAL.expected_profit) }} {{ currencySymbol('LOCAL', settings) }}
              </div>
            </div>
          </div>
          <router-link to="/reports" class="bg-white text-green-700 px-4 py-2 rounded-lg font-bold hover:bg-green-50">
            📊 التقارير ←
          </router-link>
        </div>
      </div>

      <!-- البطاقات الرئيسية -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div class="card bg-gradient-to-br from-blue-500 to-blue-700 text-white">
          <div class="text-4xl mb-2">👥</div>
          <div class="text-3xl font-bold">{{ stats.total_customers }}</div>
          <div class="text-sm opacity-90">مشتري</div>
        </div>

        <div class="card bg-gradient-to-br from-green-500 to-green-700 text-white">
          <div class="text-4xl mb-2">📦</div>
          <div class="text-3xl font-bold">{{ stats.total_products }}</div>
          <div class="text-sm opacity-90">مادة</div>
        </div>

        <div class="card bg-gradient-to-br from-amber-500 to-amber-700 text-white">
          <div class="text-4xl mb-2">📋</div>
          <div class="text-3xl font-bold">{{ stats.active_sales }}</div>
          <div class="text-sm opacity-90">بيع نشط</div>
        </div>

        <div class="card bg-gradient-to-br from-purple-500 to-purple-700 text-white">
          <div class="text-4xl mb-2">✅</div>
          <div class="text-3xl font-bold">{{ stats.completed_sales }}</div>
          <div class="text-sm opacity-90">بيع مكتمل</div>
        </div>
      </div>

      <!-- المبالغ -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="card">
          <h3 class="text-lg font-bold text-gray-800 mb-3">💰 المحصل</h3>
          <div class="space-y-2">
            <div class="flex justify-between items-center p-3 bg-green-50 rounded-lg">
              <span class="text-sm text-gray-600">دولار</span>
              <span class="text-xl font-bold text-green-700">${{ formatAmount(stats.collected.USD) }}</span>
            </div>
            <div class="flex justify-between items-center p-3 bg-green-50 rounded-lg">
              <span class="text-sm text-gray-600">{{ currencyName('LOCAL', settings) }}</span>
              <span class="text-xl font-bold text-green-700">
                {{ formatAmount(stats.collected.LOCAL) }} {{ currencySymbol('LOCAL', settings) }}
              </span>
            </div>
          </div>
        </div>

        <div class="card">
          <h3 class="text-lg font-bold text-gray-800 mb-3">⏳ المتبقي</h3>
          <div class="space-y-2">
            <div class="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
              <span class="text-sm text-gray-600">دولار</span>
              <span class="text-xl font-bold text-blue-700">${{ formatAmount(stats.remaining.USD) }}</span>
            </div>
            <div class="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
              <span class="text-sm text-gray-600">{{ currencyName('LOCAL', settings) }}</span>
              <span class="text-xl font-bold text-blue-700">
                {{ formatAmount(stats.remaining.LOCAL) }} {{ currencySymbol('LOCAL', settings) }}
              </span>
            </div>
          </div>
        </div>

        <div class="card border-2 border-red-200">
          <h3 class="text-lg font-bold text-red-700 mb-3">
            ⚠️ المتأخرات ({{ stats.late_installments }})
          </h3>
          <div class="space-y-2">
            <div class="flex justify-between items-center p-3 bg-red-50 rounded-lg">
              <span class="text-sm text-gray-600">دولار</span>
              <span class="text-xl font-bold text-red-700">${{ formatAmount(stats.late_amount.USD) }}</span>
            </div>
            <div class="flex justify-between items-center p-3 bg-red-50 rounded-lg">
              <span class="text-sm text-gray-600">{{ currencyName('LOCAL', settings) }}</span>
              <span class="text-xl font-bold text-red-700">
                {{ formatAmount(stats.late_amount.LOCAL) }} {{ currencySymbol('LOCAL', settings) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- الأقساط القادمة -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="card bg-gradient-to-br from-amber-50 to-amber-100 border-2 border-amber-200">
          <h3 class="text-lg font-bold text-amber-800 mb-3">
            📅 أقساط هذا الأسبوع ({{ stats.upcoming_week.count }})
          </h3>
          <div class="space-y-2">
            <div class="flex justify-between text-amber-900">
              <span>دولار:</span>
              <span class="font-bold">${{ formatAmount(stats.upcoming_week.USD) }}</span>
            </div>
            <div class="flex justify-between text-amber-900">
              <span>{{ currencyName('LOCAL', settings) }}:</span>
              <span class="font-bold">
                {{ formatAmount(stats.upcoming_week.LOCAL) }} {{ currencySymbol('LOCAL', settings) }}
              </span>
            </div>
          </div>
          <router-link to="/upcoming" class="block mt-4 text-center text-amber-800 hover:underline font-medium">
            عرض التفاصيل ←
          </router-link>
        </div>

        <div class="card bg-gradient-to-br from-blue-50 to-blue-100 border-2 border-blue-200">
          <h3 class="text-lg font-bold text-blue-800 mb-3">
            📆 أقساط هذا الشهر ({{ stats.upcoming_month.count }})
          </h3>
          <div class="space-y-2">
            <div class="flex justify-between text-blue-900">
              <span>دولار:</span>
              <span class="font-bold">${{ formatAmount(stats.upcoming_month.USD) }}</span>
            </div>
            <div class="flex justify-between text-blue-900">
              <span>{{ currencyName('LOCAL', settings) }}:</span>
              <span class="font-bold">
                {{ formatAmount(stats.upcoming_month.LOCAL) }} {{ currencySymbol('LOCAL', settings) }}
              </span>
            </div>
          </div>
          <router-link to="/upcoming" class="block mt-4 text-center text-blue-800 hover:underline font-medium">
            عرض التفاصيل ←
          </router-link>
        </div>
      </div>

      <!-- تنبيهات المخزون -->
      <div v-if="stats.low_stock_items && stats.low_stock_items.length > 0" class="card bg-gradient-to-r from-amber-50 to-red-50 border-2 border-amber-300">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-bold text-amber-800">
            ⚠️ تنبيهات المخزون ({{ stats.low_stock_items.length }})
          </h3>
          <router-link to="/inventory" class="text-amber-700 hover:underline text-sm font-medium">
            إدارة المخزن ←
          </router-link>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
          <div 
            v-for="item in stats.low_stock_items" 
            :key="item.product_id"
            class="bg-white p-3 rounded-lg flex items-center justify-between"
            :class="{ 'border-2 border-red-300': item.quantity <= 0 }"
          >
            <div>
              <div class="font-medium text-sm">{{ item.product_name }}</div>
              <div class="text-xs text-gray-500">حد التنبيه: {{ item.low_stock_threshold }}</div>
            </div>
            <div 
              class="text-2xl font-bold px-3 py-1 rounded-lg"
              :class="item.quantity <= 0 ? 'bg-red-100 text-red-700' : 'bg-amber-100 text-amber-700'"
            >
              {{ item.quantity }}
            </div>
          </div>
        </div>
      </div>

      <!-- أكثر المواد + آخر العمليات -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="card">
          <h3 class="text-lg font-bold text-gray-800 mb-4">🏆 أكثر المواد مبيعاً</h3>
          <div v-if="stats.top_products.length === 0" class="text-gray-500 text-center py-4">
            لا توجد بيانات بعد
          </div>
          <div v-else class="space-y-2">
            <div 
              v-for="(p, i) in stats.top_products" 
              :key="i"
              class="flex justify-between items-center p-3 bg-gray-50 rounded-lg"
            >
              <span class="font-medium">{{ i + 1 }}. {{ p.product_name }}</span>
              <span class="badge-info">{{ p.sales_count }} بيع</span>
            </div>
          </div>
        </div>

        <div class="card">
          <h3 class="text-lg font-bold text-gray-800 mb-4">🆕 آخر العمليات</h3>
          <div v-if="stats.recent_sales.length === 0" class="text-gray-500 text-center py-4">
            لا توجد عمليات بعد
          </div>
          <div v-else class="space-y-2">
            <div 
              v-for="sale in stats.recent_sales" 
              :key="sale.id"
              class="p-3 bg-gray-50 rounded-lg"
            >
              <div class="flex justify-between items-start">
                <div>
                  <div class="font-medium">{{ sale.customer_name }}</div>
                  <div class="text-sm text-gray-600">{{ sale.product_name }}</div>
                </div>
                <div class="text-left">
                  <div class="font-bold text-green-700">
                    {{ formatAmount(sale.total_price) }} {{ currencySymbol(sale.currency, settings) }}
                  </div>
                  <div class="text-xs text-gray-500">{{ formatDateShort(sale.created_at) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
	<button @click="logout" class="logout-btn">
  تسجيل الخروج
</button>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import api from '../api'
import { formatAmount, formatDateShort, currencyName, currencySymbol } from '../helpers'

const stats = ref(null)
const monthlyProfit = ref(null)
const loading = ref(true)
const settings = inject('settings', ref({}))
const logout = () => {
  // 1. حذف التوكن من التخزين المحلي للمتصفح (و بيانات المستخدم إن وجدت)
  localStorage.removeItem('token');
  localStorage.removeItem('user'); // إذا كنت تحفظ بيانات المستخدم أيضاً

  // 2. إعادة تحميل كاملة للتطبيق (window.location.href وحده لا يعيد التحميل
  // فعلياً هنا لأن التطبيق يستخدم hash routing، فيبقى الإعدادات القديمة محفوظة)
  window.location.hash = '/login';
  window.location.reload();
};
const loadStats = async () => {
  loading.value = true
  try {
    const [statsRes, profitRes] = await Promise.all([
      api.getDashboard(),
      api.getReportSummary('month')
    ])
    if (statsRes.success) stats.value = statsRes.data
    if (profitRes.success) monthlyProfit.value = profitRes.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

onMounted(loadStats)
</script>
