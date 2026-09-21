<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">➕ إضافة عملية بيع جديدة</h1>

    <div class="card max-w-3xl mx-auto">
      <div class="space-y-6">
        
        <!-- معلومات المشتري -->
        <div>
          <h2 class="text-xl font-bold text-blue-700 mb-4 pb-2 border-b border-gray-200">
            👤 معلومات المشتري
          </h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="relative">
              <label class="label">اسم المشتري *</label>
              <input 
                v-model="customer.name" 
                @input="searchCustomers"
                @focus="showSuggestions = true"
                type="text" 
                class="input" 
                placeholder="ابدأ بكتابة الاسم..."
                autocomplete="off"
              />
              
              <!-- اقتراحات البحث -->
              <div 
                v-if="showSuggestions && suggestions.length > 0" 
                class="absolute top-full right-0 left-0 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg z-10 max-h-60 overflow-y-auto"
              >
                <div 
                  v-for="s in suggestions" 
                  :key="s.id"
                  @click="selectCustomer(s)"
                  class="px-4 py-2 hover:bg-blue-50 cursor-pointer border-b border-gray-100"
                >
                  <div class="font-medium">{{ s.name }}</div>
                  <div class="text-sm text-gray-500">📞 {{ s.phone }}</div>
                </div>
              </div>
            </div>

            <div>
              <label class="label">رقم الهاتف *</label>
              <input 
                v-model="customer.phone" 
                type="tel" 
                class="input" 
                placeholder="07X XXX XXXX"
                dir="ltr"
              />
            </div>

            <div class="md:col-span-2">
              <label class="label">العنوان</label>
              <input v-model="customer.address" type="text" class="input" placeholder="اختياري" />
            </div>
          </div>

          <div v-if="customer.id" class="mt-3 p-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-800">
            ✅ مشتري موجود مسبقاً - سيتم استخدام بياناته
          </div>
        </div>

        <!-- معلومات البيع -->
        <div>
          <h2 class="text-xl font-bold text-blue-700 mb-4 pb-2 border-b border-gray-200">
            🛒 معلومات البيع
          </h2>

          <div class="space-y-4">
            <div>
              <label class="label">اختر المادة *</label>
              <select v-model="selectedProductId" @change="onProductChange" class="input">
                <option value="">-- اختر مادة --</option>
                <option v-for="p in products" :key="p.id" :value="p.id">
                  {{ p.name }} - {{ formatAmount(p.price) }} {{ p.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings) }}
                </option>
              </select>
              <div v-if="products.length === 0" class="text-sm text-amber-700 mt-2">
                ⚠️ لا توجد مواد. <router-link to="/products" class="underline">أضف مادة أولاً</router-link>
              </div>
            </div>

            <div v-if="selectedProduct" class="bg-blue-50 p-4 rounded-lg space-y-3">
              
              <!-- معلومات المخزن للمادة المختارة -->
              <div v-if="productInventory" class="p-3 rounded-lg border-2" :class="inventoryAlertClass">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-2">
                    <span class="text-2xl">{{ inventoryIcon }}</span>
                    <div>
                      <div class="font-bold text-sm">{{ inventoryStatusText }}</div>
                      <div class="text-xs">الكمية المتوفرة في المخزن: <span class="font-bold">{{ productInventory.quantity }}</span></div>
                    </div>
                  </div>
                </div>
              </div>
              
              <div v-else class="p-3 bg-gray-100 rounded-lg text-sm text-gray-600">
                <span class="text-xl">⏸️</span>
                هذه المادة لا تتبع نظام المخزن (سيتم البيع بدون التأثير على المخزن)
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="label">الكمية *</label>
                  <input 
                    v-model.number="sale.quantity" 
                    type="number" 
                    min="1"
                    class="input" 
                    @input="updateTotalPrice"
                  />
                  <p v-if="productInventory && sale.quantity > productInventory.quantity" class="text-xs text-red-600 mt-1">
                    ⚠️ الكمية المطلوبة أكبر من المتوفر! (متوفر: {{ productInventory.quantity }})
                  </p>
                </div>
                <div>
                  <label class="label">السعر الكلي *</label>
                  <input 
                    v-model.number="sale.total_price" 
                    type="number" 
                    min="0" 
                    step="0.01"
                    class="input" 
                  />
                  <p v-if="sale.quantity > 1" class="text-xs text-gray-500 mt-1">
                    سعر الوحدة: {{ formatAmount(unitPrice) }} × {{ sale.quantity }}
                  </p>
                </div>
              </div>

              <div>
                <label class="label">المقدمة (اختياري)</label>
                <input 
                  v-model.number="sale.down_payment" 
                  type="number" 
                  min="0" 
                  step="0.01"
                  :max="sale.total_price"
                  class="input" 
                />
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="label">عدد الأقساط *</label>
                  <input 
                    v-model.number="sale.installments_count" 
                    type="number" 
                    min="1" 
                    max="120"
                    class="input" 
                  />
                </div>
                <div>
                  <label class="label">نوع القسط *</label>
                  <select v-model="sale.installment_type" class="input">
                    <option value="monthly">شهري</option>
                    <option value="weekly">أسبوعي</option>
                  </select>
                </div>
              </div>

              <div>
                <label class="label">تاريخ البيع *</label>
                <input v-model="sale.sale_date" type="date" class="input" />
              </div>

              <!-- الملخص -->
              <div class="bg-white p-4 rounded-lg border-2 border-blue-300">
                <h3 class="font-bold text-gray-800 mb-3">📊 ملخص العملية:</h3>
                <div class="space-y-2 text-sm">
                  <div class="flex justify-between">
                    <span>السعر الكلي:</span>
                    <span class="font-bold">{{ formatAmount(sale.total_price) }} {{ currencyDisplay }}</span>
                  </div>
                  <div class="flex justify-between text-amber-700">
                    <span>المقدمة:</span>
                    <span class="font-bold">- {{ formatAmount(sale.down_payment) }} {{ currencyDisplay }}</span>
                  </div>
                  <div class="flex justify-between border-t pt-2">
                    <span>المتبقي للأقساط:</span>
                    <span class="font-bold text-blue-700">{{ formatAmount(remaining) }} {{ currencyDisplay }}</span>
                  </div>
                  <div class="flex justify-between text-green-700 text-base">
                    <span>💵 قيمة كل قسط:</span>
                    <span class="font-bold">{{ formatAmount(installmentValue) }} {{ currencyDisplay }}</span>
                  </div>
                  <div class="flex justify-between text-gray-600 mt-3 pt-2 border-t">
                    <span>عدد الأقساط:</span>
                    <span class="font-bold">{{ sale.installments_count }} قسط {{ sale.installment_type === 'weekly' ? 'أسبوعي' : 'شهري' }}</span>
                  </div>
                  <div class="flex justify-between text-gray-600">
                    <span>أول قسط في:</span>
                    <span class="font-bold">{{ firstInstallmentDate }}</span>
                  </div>
                  <div class="flex justify-between text-gray-600">
                    <span>آخر قسط في:</span>
                    <span class="font-bold">{{ lastInstallmentDate }}</span>
                  </div>
                  
                  <!-- معلومات الربح المتوقع -->
                  <div v-if="selectedProduct && selectedProduct.cost_price > 0" class="mt-3 pt-3 border-t-2 border-green-300 space-y-1">
                    <div class="flex justify-between text-gray-600 text-xs">
                      <span>تكلفة الشراء (إجمالي):</span>
                      <span>{{ formatAmount(selectedProduct.cost_price * sale.quantity) }} {{ currencyDisplay }}</span>
                    </div>
                    <div class="flex justify-between text-green-700 font-bold">
                      <span>💰 الربح المتوقع:</span>
                      <span>{{ formatAmount(expectedProfit) }} {{ currencyDisplay }}</span>
                    </div>
                    <div class="flex justify-between text-green-600 text-xs">
                      <span>نسبة الربح:</span>
                      <span>{{ profitPercentage }}%</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div>
              <label class="label">ملاحظات</label>
              <textarea v-model="sale.notes" rows="2" class="input" placeholder="ملاحظات اختيارية"></textarea>
            </div>
          </div>
        </div>

        <!-- أزرار الإجراءات -->
        <div class="flex gap-3 pt-4 border-t border-gray-200">
          <button 
            @click="submit" 
            :disabled="submitting || !canSubmit"
            class="btn-success flex-1 text-lg py-3"
          >
            {{ submitting ? '⏳ جاري الحفظ...' : '✅ تسجيل البيع' }}
          </button>
          <button @click="resetForm" class="btn-secondary">
            🔄 مسح
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'
import { formatAmount, formatDateShort, currencyName, currencySymbol } from '../helpers'

const router = useRouter()
const settings = inject('settings', ref({}))

const products = ref([])
const suggestions = ref([])
const showSuggestions = ref(false)
const submitting = ref(false)
const selectedProductId = ref('')
const selectedProduct = ref(null)
const productInventory = ref(null)

const customer = ref({
  id: null,
  name: '',
  phone: '',
  address: ''
})

const sale = ref({
  quantity: 1,
  total_price: 0,
  down_payment: 0,
  installments_count: 1,
  installment_type: 'monthly',
  sale_date: new Date().toISOString().split('T')[0],
  notes: ''
})

const unitPrice = computed(() => {
  if (!selectedProduct.value) return 0
  return parseFloat(selectedProduct.value.price)
})

// تنبيهات المخزن للمادة المختارة
const inventoryStatusText = computed(() => {
  if (!productInventory.value) return ''
  const qty = productInventory.value.quantity
  const threshold = productInventory.value.low_stock_threshold
  if (qty <= 0) return '🚫 نفدت الكمية من المخزن (يمكن البيع لكنها ستصبح بالسالب)'
  if (qty <= threshold) return '⚠️ المخزون منخفض'
  return '✅ المخزون متوفر'
})

const inventoryIcon = computed(() => {
  if (!productInventory.value) return '📦'
  const qty = productInventory.value.quantity
  const threshold = productInventory.value.low_stock_threshold
  if (qty <= 0) return '🚫'
  if (qty <= threshold) return '⚠️'
  return '✅'
})

const inventoryAlertClass = computed(() => {
  if (!productInventory.value) return ''
  const qty = productInventory.value.quantity
  const threshold = productInventory.value.low_stock_threshold
  if (qty <= 0) return 'bg-red-100 border-red-400 text-red-800'
  if (qty <= threshold) return 'bg-amber-100 border-amber-400 text-amber-800'
  return 'bg-green-100 border-green-400 text-green-800'
})

const remaining = computed(() => {
  return Math.max(0, (sale.value.total_price || 0) - (sale.value.down_payment || 0))
})

const installmentValue = computed(() => {
  if (!sale.value.installments_count) return 0
  return remaining.value / sale.value.installments_count
})

const expectedProfit = computed(() => {
  if (!selectedProduct.value || !selectedProduct.value.cost_price) return 0
  const totalCost = parseFloat(selectedProduct.value.cost_price) * sale.value.quantity
  return sale.value.total_price - totalCost
})

const profitPercentage = computed(() => {
  if (!selectedProduct.value || !selectedProduct.value.cost_price) return 0
  const totalCost = parseFloat(selectedProduct.value.cost_price) * sale.value.quantity
  if (totalCost === 0) return 0
  return ((expectedProfit.value / totalCost) * 100).toFixed(1)
})

const currencyDisplay = computed(() => {
  if (!selectedProduct.value) return ''
  return selectedProduct.value.currency === 'USD' ? '$' : currencySymbol('LOCAL', settings.value)
})

const firstInstallmentDate = computed(() => {
  if (!sale.value.sale_date) return '-'
  const date = new Date(sale.value.sale_date)
  if (sale.value.installment_type === 'weekly') {
    date.setDate(date.getDate() + 7)
  } else {
    date.setMonth(date.getMonth() + 1)
  }
  return formatDateShort(date)
})

const lastInstallmentDate = computed(() => {
  if (!sale.value.sale_date || !sale.value.installments_count) return '-'
  const date = new Date(sale.value.sale_date)
  if (sale.value.installment_type === 'weekly') {
    date.setDate(date.getDate() + (7 * sale.value.installments_count))
  } else {
    date.setMonth(date.getMonth() + sale.value.installments_count)
  }
  return formatDateShort(date)
})

const canSubmit = computed(() => {
  return customer.value.name && 
         customer.value.phone && 
         selectedProductId.value && 
         sale.value.total_price > 0 &&
         sale.value.installments_count > 0 &&
         remaining.value > 0
})

let searchTimer = null

const searchCustomers = async () => {
  customer.value.id = null
  if (searchTimer) clearTimeout(searchTimer)
  
  if (!customer.value.name || customer.value.name.length < 2) {
    suggestions.value = []
    return
  }
  
  searchTimer = setTimeout(async () => {
    try {
      const res = await api.searchCustomers(customer.value.name)
      if (res.success) {
        suggestions.value = res.data
        showSuggestions.value = true
      }
    } catch (e) {}
  }, 300)
}

const selectCustomer = (c) => {
  customer.value = {
    id: c.id,
    name: c.name,
    phone: c.phone,
    address: c.address || ''
  }
  suggestions.value = []
  showSuggestions.value = false
}

const loadProducts = async () => {
  try {
    const res = await api.getProducts()
    if (res.success) products.value = res.data
  } catch (e) {}
}

const onProductChange = async () => {
  const p = products.value.find(p => p.id == selectedProductId.value)
  if (p) {
    selectedProduct.value = p
    sale.value.quantity = 1
    sale.value.total_price = parseFloat(p.price)
    
    // تحميل بيانات المخزن للمادة
    try {
      const res = await api.getInventoryByProduct(p.id)
      productInventory.value = res.success ? res.data : null
    } catch (e) {
      productInventory.value = null
    }
  } else {
    selectedProduct.value = null
    productInventory.value = null
  }
}

const updateTotalPrice = () => {
  if (selectedProduct.value && sale.value.quantity > 0) {
    sale.value.total_price = unitPrice.value * sale.value.quantity
  }
}

const submit = async () => {
  if (!canSubmit.value) {
    alert('الرجاء إكمال جميع البيانات المطلوبة')
    return
  }
  
  // تحذير عند نقص المخزون
  if (productInventory.value && sale.value.quantity > productInventory.value.quantity) {
    const remaining = productInventory.value.quantity - sale.value.quantity
    if (!confirm(
      `⚠️ تحذير: الكمية المطلوبة (${sale.value.quantity}) أكبر من المتوفر في المخزن (${productInventory.value.quantity}).\n\n` +
      `ستصبح الكمية في المخزن: ${remaining}\n\n` +
      `هل تريد المتابعة بالبيع رغم ذلك؟`
    )) {
      return
    }
  }
  
  submitting.value = true
  try {
    let customerId = customer.value.id
    if (!customerId) {
      const res = await api.createCustomer({
        name: customer.value.name,
        phone: customer.value.phone,
        address: customer.value.address
      })
      if (res.success) customerId = res.data.id
      else throw new Error(res.message)
    }
    
    const saleRes = await api.createSale({
      customer_id: customerId,
      product_id: parseInt(selectedProductId.value),
      product_name: selectedProduct.value.name,
      quantity: sale.value.quantity,
      total_price: sale.value.total_price,
      down_payment: sale.value.down_payment || 0,
      installments_count: sale.value.installments_count,
      installment_type: sale.value.installment_type,
      currency: selectedProduct.value.currency,
      sale_date: sale.value.sale_date,
      notes: sale.value.notes
    })
    
    if (saleRes.success) {
      let msg = '✅ تم تسجيل البيع بنجاح!'
      if (saleRes.data?.stock_warning) {
        msg += '\n' + saleRes.data.stock_warning
      }
      alert(msg)
      router.push(`/customers/${customerId}`)
    }
  } catch (e) {
    alert('فشل: ' + (e.message || ''))
  } finally {
    submitting.value = false
  }
}

const resetForm = () => {
  if (!confirm('هل تريد مسح كل البيانات؟')) return
  customer.value = { id: null, name: '', phone: '', address: '' }
  sale.value = {
    quantity: 1,
    total_price: 0,
    down_payment: 0,
    installments_count: 1,
    installment_type: 'monthly',
    sale_date: new Date().toISOString().split('T')[0],
    notes: ''
  }
  selectedProductId.value = ''
  selectedProduct.value = null
  productInventory.value = null
}

onMounted(loadProducts)
</script>
