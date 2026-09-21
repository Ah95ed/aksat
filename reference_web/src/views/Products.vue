<template>
  <div>
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
      <h1 class="text-3xl font-bold text-gray-800">📦 إدارة المواد</h1>
      <div class="flex gap-2 flex-wrap">
        <router-link to="/inventory" class="btn-secondary">
          🏪 المخزن
        </router-link>
        <button @click="openAddModal" class="btn-primary">
          ➕ إضافة مادة جديدة
        </button>
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

    <!-- جدول المواد -->
    <div class="card overflow-x-auto">
      <div v-if="loading" class="text-center py-8">
        <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>

      <div v-else-if="filteredProducts.length === 0" class="text-center py-12 text-gray-500">
        لا توجد مواد. ابدأ بإضافة مادة جديدة.
      </div>

      <table v-else class="w-full text-right">
        <thead>
          <tr class="border-b-2 border-gray-200">
            <th class="py-3 px-4 font-bold text-gray-700">#</th>
            <th class="py-3 px-4 font-bold text-gray-700">اسم المادة</th>
            <th class="py-3 px-4 font-bold text-gray-700 hidden md:table-cell">سعر الشراء</th>
            <th class="py-3 px-4 font-bold text-gray-700">سعر البيع</th>
            <th class="py-3 px-4 font-bold text-gray-700 hidden md:table-cell">الربح</th>
            <th class="py-3 px-4 font-bold text-gray-700">العملة</th>
            <th class="py-3 px-4 font-bold text-gray-700 hidden md:table-cell">ملاحظات</th>
            <th class="py-3 px-4 font-bold text-gray-700">الإجراءات</th>
          </tr>
        </thead>
        <tbody>
          <tr 
            v-for="(product, i) in filteredProducts" 
            :key="product.id"
            class="border-b border-gray-100 hover:bg-gray-50"
          >
            <td class="py-3 px-4">{{ i + 1 }}</td>
            <td class="py-3 px-4 font-medium">{{ product.name }}</td>
            <td class="py-3 px-4 hidden md:table-cell text-amber-700">
              {{ product.cost_price > 0 ? formatAmount(product.cost_price) : '-' }}
            </td>
            <td class="py-3 px-4 font-bold text-green-700">
              {{ formatAmount(product.price) }}
            </td>
            <td class="py-3 px-4 hidden md:table-cell font-bold" :class="profitClass(product)">
              {{ profitDisplay(product) }}
            </td>
            <td class="py-3 px-4">
              <span :class="product.currency === 'USD' ? 'badge-info' : 'badge-warning'">
                {{ product.currency === 'USD' ? '$ دولار' : `${currencySymbol('LOCAL', settings)} ${currencyName('LOCAL', settings)}` }}
              </span>
            </td>
            <td class="py-3 px-4 text-sm text-gray-600 hidden md:table-cell">
              {{ product.notes || '-' }}
            </td>
            <td class="py-3 px-4">
              <div class="flex gap-2">
                <button @click="openEditModal(product)" class="text-blue-600 hover:text-blue-800" title="تعديل">
                  ✏️
                </button>
                <button @click="deleteProduct(product)" class="text-red-600 hover:text-red-800" title="حذف">
                  🗑️
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- نموذج الإضافة/التعديل -->
    <div 
      v-if="showModal" 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="showModal = false"
    >
      <div class="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">
          {{ editingProduct ? '✏️ تعديل المادة' : '➕ إضافة مادة جديدة' }}
        </h2>

        <div class="space-y-4">
          <div>
            <label class="label">اسم المادة *</label>
            <input v-model="form.name" type="text" class="input" placeholder="مثال: ثلاجة LG" />
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="label">سعر الشراء</label>
              <input v-model.number="form.cost_price" type="number" min="0" step="0.01" class="input" placeholder="السعر الذي اشتريت به" />
              <p class="text-xs text-gray-500 mt-1">للتقارير والأرباح فقط</p>
            </div>
            <div>
              <label class="label">سعر البيع *</label>
              <input v-model.number="form.price" type="number" min="0" step="0.01" class="input" placeholder="السعر الذي تبيع به" />
            </div>
          </div>
          
          <div v-if="form.cost_price > 0 && form.price > 0" class="bg-green-50 p-3 rounded-lg text-sm">
            <div class="flex justify-between">
              <span>الربح المتوقع:</span>
              <span class="font-bold text-green-700">
                {{ formatAmount(form.price - form.cost_price) }}
                ({{ ((form.price - form.cost_price) / form.cost_price * 100).toFixed(1) }}%)
              </span>
            </div>
          </div>

          <div>
            <label class="label">العملة *</label>
            <select v-model="form.currency" class="input">
              <option value="USD">دولار $</option>
              <option value="LOCAL">{{ currencyName('LOCAL', settings) }}</option>
            </select>
          </div>

          <div>
            <label class="label">ملاحظات</label>
            <textarea v-model="form.notes" rows="3" class="input" placeholder="ملاحظات اختيارية"></textarea>
          </div>
        </div>

        <div class="flex gap-3 mt-6">
          <button @click="saveProduct" :disabled="saving" class="btn-primary flex-1">
            {{ saving ? '⏳ جاري الحفظ...' : '💾 حفظ' }}
          </button>
          <button @click="showModal = false" class="btn-secondary flex-1">
            إلغاء
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import api from '../api'
import { formatAmount, currencyName, currencySymbol } from '../helpers'

const products = ref([])
const loading = ref(true)
const showModal = ref(false)
const editingProduct = ref(null)
const saving = ref(false)
const search = ref('')
const settings = inject('settings', ref({}))

const form = ref({
  name: '',
  cost_price: 0,
  price: 0,
  currency: 'LOCAL',
  notes: ''
})

const profitDisplay = (product) => {
  if (!product.cost_price || product.cost_price <= 0) return '-'
  const profit = parseFloat(product.price) - parseFloat(product.cost_price)
  return formatAmount(profit)
}

const profitClass = (product) => {
  if (!product.cost_price || product.cost_price <= 0) return 'text-gray-400'
  const profit = parseFloat(product.price) - parseFloat(product.cost_price)
  if (profit > 0) return 'text-green-700'
  if (profit < 0) return 'text-red-700'
  return 'text-gray-700'
}

const filteredProducts = computed(() => {
  if (!search.value) return products.value
  const q = search.value.toLowerCase()
  return products.value.filter(p => 
    p.name.toLowerCase().includes(q) ||
    (p.notes && p.notes.toLowerCase().includes(q))
  )
})

const loadProducts = async () => {
  loading.value = true
  try {
    const res = await api.getProducts()
    if (res.success) products.value = res.data
  } catch (e) {
    alert('فشل تحميل المواد')
  } finally {
    loading.value = false
  }
}

const openAddModal = () => {
  editingProduct.value = null
  form.value = { name: '', cost_price: 0, price: 0, currency: 'LOCAL', notes: '' }
  showModal.value = true
}

const openEditModal = (product) => {
  editingProduct.value = product
  form.value = {
    id: Number(product.id),
    name: product.name || '',
    cost_price: Number(product.cost_price ?? 0),
    price: Number(product.price ?? 0),
    currency: product.currency || 'LOCAL',
    notes: product.notes || ''
  }
  showModal.value = true
}

const saveProduct = async () => {
  if (!form.value.name || !form.value.price) {
    alert('الرجاء إدخال الاسم والسعر')
    return
  }
  
  saving.value = true
  try {
    const payload = {
      ...(editingProduct.value ? { id: Number(editingProduct.value.id) } : {}),
      name: form.value.name.trim(),
      cost_price: Number(form.value.cost_price || 0),
      price: Number(form.value.price),
      currency: form.value.currency,
      notes: (form.value.notes || '').trim()
    }

    const res = editingProduct.value
      ? await api.updateProduct(payload)
      : await api.createProduct(payload)

    if (!res?.success) {
      throw new Error(res?.message || 'تعذر حفظ المادة')
    }

    showModal.value = false
    await loadProducts()
  } catch (e) {
    alert('فشل الحفظ: ' + (e?.message || 'حدث خطأ غير معروف'))
  } finally {
    saving.value = false
  }
}

const deleteProduct = async (product) => {
  if (!confirm(`هل تريد حذف "${product.name}"؟`)) return
  try {
    const res = await api.deleteProduct(product.id)

    if (!res?.success) {
      throw new Error(res?.message || 'تعذر حذف المادة')
    }

    await loadProducts()
  } catch (e) {
    alert(e?.message || 'فشل الحذف')
  }
}

onMounted(loadProducts)
</script>
