<template>
  <div>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
      <h1 class="text-3xl font-bold text-gray-800">📦 المخزن</h1>
      <div class="flex gap-2 flex-wrap">
        <button @click="filter = 'all'" :class="filterBtn('all')">
          الكل ({{ items.length }})
        </button>
        <button @click="filter = 'tracked'" :class="filterBtn('tracked')">
          📊 مُتتبَّع ({{ trackedCount }})
        </button>
        <button @click="filter = 'low_stock'" :class="filterBtn('low_stock')">
          ⚠️ منخفض ({{ lowStockCount }})
        </button>
        <button @click="filter = 'out_of_stock'" :class="filterBtn('out_of_stock')">
          🚫 نفد ({{ outOfStockCount }})
        </button>
        <button @click="filter = 'not_tracked'" :class="filterBtn('not_tracked')">
          ⏸️ غير مُتتبَّع ({{ notTrackedCount }})
        </button>
      </div>
    </div>

    <!-- شريط المعلومات -->
    <div class="card mb-4 bg-blue-50 border-r-4 border-blue-400">
      <div class="flex items-start gap-3">
        <span class="text-2xl">ℹ️</span>
        <div class="text-sm text-gray-700">
          <p class="font-bold mb-1">المخزن اختياري:</p>
          <p>المواد التي تُفعّل تتبع المخزن لها سيتم خصم الكمية تلقائياً عند البيع.</p>
          <p>المواد غير المُتتبَّعة تُباع بدون أي تأثير على المخزن.</p>
        </div>
      </div>
    </div>

    <!-- البحث -->
    <div class="card mb-4">
      <input 
        v-model="search" 
        type="text" 
        placeholder="🔍 بحث في المواد..." 
        class="input"
      />
    </div>

    <!-- جدول المخزن -->
    <div class="card overflow-x-auto">
      <div v-if="loading" class="text-center py-8">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="filteredItems.length === 0" class="text-center py-12 text-gray-500">
        لا توجد نتائج
      </div>

      <table v-else class="w-full text-right">
        <thead>
          <tr class="border-b-2 border-gray-200">
            <th class="py-3 px-4 font-bold text-gray-700">#</th>
            <th class="py-3 px-4 font-bold text-gray-700">المادة</th>
            <th class="py-3 px-4 font-bold text-gray-700">السعر</th>
            <th class="py-3 px-4 font-bold text-gray-700">الكمية</th>
            <th class="py-3 px-4 font-bold text-gray-700">حد التنبيه</th>
            <th class="py-3 px-4 font-bold text-gray-700">الحالة</th>
            <th class="py-3 px-4 font-bold text-gray-700">الإجراءات</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(item, i) in filteredItems" 
            :key="item.product_id"
            class="border-b border-gray-100 hover:bg-gray-50"
            :class="rowClass(item)"
          >
            <td class="py-3 px-4">{{ i + 1 }}</td>
            <td class="py-3 px-4 font-medium">{{ item.product_name }}</td>
            <td class="py-3 px-4 text-green-700">
              {{ formatAmount(item.price) }}
              {{ item.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings) }}
            </td>
            <td class="py-3 px-4">
              <span v-if="item.stock_status === 'not_tracked'" class="text-gray-400 italic">
                غير مُتتبَّع
              </span>
              <span v-else class="font-bold text-lg" :class="quantityColor(item)">
                {{ item.quantity }}
              </span>
            </td>
            <td class="py-3 px-4 text-gray-600">
              {{ item.stock_status === 'not_tracked' ? '-' : item.low_stock_threshold }}
            </td>
            <td class="py-3 px-4">
              <span v-if="item.stock_status === 'not_tracked'" class="badge bg-gray-200 text-gray-700">
                ⏸️ غير مُتتبَّع
              </span>
              <span v-else-if="item.stock_status === 'out_of_stock'" class="badge-danger">
                🚫 نفد
              </span>
              <span v-else-if="item.stock_status === 'low_stock'" class="badge-warning">
                ⚠️ منخفض
              </span>
              <span v-else class="badge-success">
                ✅ متوفر
              </span>
            </td>
            <td class="py-3 px-4">
              <div class="flex gap-1">
                <button 
                  @click="openAddStockModal(item)"
                  class="bg-green-600 text-white px-3 py-1 rounded text-xs hover:bg-green-700"
                  title="إضافة/تعديل كمية"
                >
                  ➕
                </button>
                <button 
                  v-if="item.stock_status !== 'not_tracked'"
                  @click="viewMovements(item)"
                  class="bg-blue-500 text-white px-3 py-1 rounded text-xs hover:bg-blue-600"
                  title="عرض الحركات"
                >
                  📋
                </button>
                <button 
                  v-if="item.stock_status !== 'not_tracked'"
                  @click="stopTracking(item)"
                  class="bg-red-500 text-white px-3 py-1 rounded text-xs hover:bg-red-600"
                  title="إيقاف التتبع"
                >
                  ⏹️
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- نموذج إضافة/تعديل الكمية -->
    <div 
      v-if="showModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="showModal = false"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-2">
          📦 {{ currentItem?.stock_status === 'not_tracked' ? 'تفعيل المخزن' : 'تحديث المخزن' }}
        </h2>
        <p class="text-gray-600 mb-6">{{ currentItem?.product_name }}</p>

        <div class="space-y-4">
          <div v-if="currentItem?.stock_status !== 'not_tracked'" class="bg-blue-50 p-3 rounded-lg text-sm">
            الكمية الحالية: <span class="font-bold text-blue-700">{{ currentItem?.quantity }}</span>
          </div>

          <div>
            <label class="label">نوع العملية</label>
            <select v-model="form.action" class="input">
              <option value="set">تعيين الكمية ({{ currentItem?.stock_status === 'not_tracked' ? 'البدء بـ' : 'استبدال بـ' }})</option>
              <option value="add">إضافة للكمية الحالية</option>
            </select>
          </div>

          <div>
            <label class="label">
              {{ form.action === 'add' ? 'الكمية المراد إضافتها' : 'الكمية الجديدة' }} *
            </label>
            <input 
              v-model.number="form.quantity" 
              type="number" 
              min="0"
              class="input" 
              placeholder="مثال: 10"
            />
          </div>

          <div>
            <label class="label">حد التنبيه (عند الوصول لهذا الرقم)</label>
            <input 
              v-model.number="form.low_stock_threshold" 
              type="number" 
              min="0"
              class="input" 
              placeholder="مثال: 3"
            />
            <p class="text-xs text-gray-500 mt-1">سيظهر تنبيه عندما تصل الكمية لهذا الحد أو أقل</p>
          </div>

          <div>
            <label class="label">ملاحظات</label>
            <textarea v-model="form.notes" rows="2" class="input" placeholder="اختياري"></textarea>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button @click="saveStock" :disabled="saving" class="btn-primary flex-1">
            {{ saving ? '⏳ جاري الحفظ...' : '💾 حفظ' }}
          </button>
          <button @click="showModal = false" class="btn-secondary flex-1">
            إلغاء
          </button>
        </div>
      </div>
    </div>

    <!-- نموذج عرض الحركات -->
    <div 
      v-if="showMovementsModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="showMovementsModal = false"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-2xl w-full p-6 max-h-[80vh] overflow-y-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-2">📋 حركات المخزن</h2>
        <p class="text-gray-600 mb-4">{{ currentItem?.product_name }}</p>

        <div v-if="movements.length === 0" class="text-center py-8 text-gray-500">
          لا توجد حركات بعد
        </div>

        <div v-else class="space-y-2">
          <div 
            v-for="m in movements" 
            :key="m.id"
            class="flex justify-between items-center p-3 rounded-lg"
            :class="movementBg(m.movement_type)"
          >
            <div>
              <div class="font-bold">
                <span>{{ movementIcon(m.movement_type) }}</span>
                {{ movementLabel(m.movement_type) }}
                <span class="mx-1">{{ m.quantity }}</span>
              </div>
              <div class="text-xs text-gray-600 mt-1">{{ m.notes }}</div>
            </div>
            <div class="text-xs text-gray-500">
              {{ formatDateShort(m.created_at) }}
            </div>
          </div>
        </div>

        <button @click="showMovementsModal = false" class="btn-secondary w-full mt-4">
          إغلاق
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import api from '../api'
import { formatAmount, formatDateShort, currencySymbol } from '../helpers'

const items = ref([])
const movements = ref([])
const loading = ref(true)
const saving = ref(false)
const showModal = ref(false)
const showMovementsModal = ref(false)
const currentItem = ref(null)
const search = ref('')
const filter = ref('all')
const settings = inject('settings', ref({}))

const form = ref({
  quantity: 0,
  low_stock_threshold: 3,
  action: 'set',
  notes: ''
})

const trackedCount = computed(() => items.value.filter(i => i.stock_status !== 'not_tracked').length)
const lowStockCount = computed(() => items.value.filter(i => i.stock_status === 'low_stock').length)
const outOfStockCount = computed(() => items.value.filter(i => i.stock_status === 'out_of_stock').length)
const notTrackedCount = computed(() => items.value.filter(i => i.stock_status === 'not_tracked').length)

const filteredItems = computed(() => {
  let list = items.value
  
  if (filter.value !== 'all') {
    if (filter.value === 'tracked') {
      list = list.filter(i => i.stock_status !== 'not_tracked')
    } else {
      list = list.filter(i => i.stock_status === filter.value)
    }
  }
  
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(i => i.product_name.toLowerCase().includes(q))
  }
  
  return list
})

const filterBtn = (val) => {
  return [
    'px-3 py-2 rounded-lg text-sm font-medium transition',
    filter.value === val ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
  ]
}

const rowClass = (item) => {
  if (item.stock_status === 'out_of_stock') return 'bg-red-50'
  if (item.stock_status === 'low_stock') return 'bg-amber-50'
  return ''
}

const quantityColor = (item) => {
  if (item.quantity <= 0) return 'text-red-700'
  if (item.quantity <= item.low_stock_threshold) return 'text-amber-700'
  return 'text-green-700'
}

const movementIcon = (type) => {
  const icons = { add: '➕', subtract: '➖', return: '↩️', adjustment: '✏️' }
  return icons[type] || '📝'
}

const movementLabel = (type) => {
  const labels = {
    add: 'إضافة',
    subtract: 'بيع/خصم',
    return: 'استرجاع (حذف بيع)',
    adjustment: 'تعديل'
  }
  return labels[type] || type
}

const movementBg = (type) => {
  const bgs = {
    add: 'bg-green-50',
    subtract: 'bg-red-50',
    return: 'bg-blue-50',
    adjustment: 'bg-amber-50'
  }
  return bgs[type] || 'bg-gray-50'
}

const loadInventory = async () => {
  loading.value = true
  try {
    const res = await api.getInventory()
    if (res.success) items.value = res.data
  } catch (e) {
    alert('فشل تحميل بيانات المخزن')
  } finally {
    loading.value = false
  }
}

const openAddStockModal = (item) => {
  currentItem.value = item
  form.value = {
    quantity: item.stock_status === 'not_tracked' ? 0 : item.quantity,
    low_stock_threshold: item.low_stock_threshold || 3,
    action: item.stock_status === 'not_tracked' ? 'set' : 'add',
    notes: ''
  }
  showModal.value = true
}

const saveStock = async () => {
  if (form.value.quantity < 0) {
    alert('الكمية يجب أن تكون 0 أو أكثر')
    return
  }
  
  saving.value = true
  try {
    await api.setInventory({
      product_id: currentItem.value.product_id,
      quantity: form.value.quantity,
      low_stock_threshold: form.value.low_stock_threshold,
      action: form.value.action,
      notes: form.value.notes
    })
    showModal.value = false
    await loadInventory()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  } finally {
    saving.value = false
  }
}

const viewMovements = async (item) => {
  currentItem.value = item
  try {
    const res = await api.getInventoryMovements(item.product_id)
    if (res.success) movements.value = res.data
    showMovementsModal.value = true
  } catch (e) {
    alert('فشل تحميل الحركات')
  }
}

const stopTracking = async (item) => {
  if (!confirm(`إيقاف تتبع المخزن لـ "${item.product_name}"؟\nسيتم حذف بيانات الكمية والحركات.`)) return
  try {
    await api.removeInventoryTracking(item.product_id)
    await loadInventory()
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  }
}

onMounted(loadInventory)
</script>
