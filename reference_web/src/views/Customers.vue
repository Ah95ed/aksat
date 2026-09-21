<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-800 mb-6">👥 المشترين</h1>

    <!-- البحث والفلتر -->
    <div class="card mb-4">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="md:col-span-2">
          <input 
            v-model="search" 
            type="text" 
            placeholder="🔍 بحث بالاسم أو رقم الهاتف..." 
            class="input"
          />
        </div>
        <select v-model="filter" class="input">
          <option value="all">الكل ({{ customers.length }})</option>
          <option value="active">نشط ({{ activeCount }})</option>
          <option value="late">عنده متأخرات ({{ lateCount }})</option>
        </select>
      </div>
    </div>

    <div v-if="loading" class="text-center py-12">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>

    <div v-else-if="filteredCustomers.length === 0" class="card text-center py-12 text-gray-500">
      {{ search ? 'لا توجد نتائج' : 'لا يوجد مشترين بعد' }}
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div 
        v-for="c in filteredCustomers" 
        :key="c.id"
        @click="$router.push(`/customers/${c.id}`)"
        class="card cursor-pointer hover:shadow-xl transition relative"
        :class="{ 'border-2 border-red-300': c.late_count > 0 }"
      >
        <div v-if="c.late_count > 0" class="absolute top-2 left-2">
          <span class="badge-danger">⚠️ {{ c.late_count }} متأخر</span>
        </div>

        <div class="flex items-center gap-3 mb-3">
          <div class="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-2xl">
            👤
          </div>
          <div class="flex-1 min-w-0">
            <h3 class="font-bold text-lg text-gray-800 truncate">{{ c.name }}</h3>
            <p class="text-sm text-gray-500" dir="ltr">📞 {{ c.phone }}</p>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-2 text-sm">
          <div class="bg-blue-50 p-2 rounded-lg text-center">
            <div class="font-bold text-blue-700">{{ c.sales_count || 0 }}</div>
            <div class="text-xs text-gray-600">إجمالي البيوع</div>
          </div>
          <div class="bg-green-50 p-2 rounded-lg text-center">
            <div class="font-bold text-green-700">{{ c.active_sales || 0 }}</div>
            <div class="text-xs text-gray-600">نشط</div>
          </div>
        </div>

        <div class="text-xs text-gray-400 mt-3 text-left">
          منذ {{ formatDateShort(c.created_at) }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '../api'
import { formatDateShort } from '../helpers'

const customers = ref([])
const loading = ref(true)
const search = ref('')
const filter = ref('all')

const lateCount = computed(() => customers.value.filter(c => c.late_count > 0).length)
const activeCount = computed(() => customers.value.filter(c => c.active_sales > 0).length)

const filteredCustomers = computed(() => {
  let list = customers.value
  
  if (filter.value === 'late') {
    list = list.filter(c => c.late_count > 0)
  } else if (filter.value === 'active') {
    list = list.filter(c => c.active_sales > 0)
  }
  
  if (search.value) {
    const q = search.value.toLowerCase()
    list = list.filter(c => 
      c.name.toLowerCase().includes(q) || 
      c.phone.includes(q)
    )
  }
  
  return list
})

const loadCustomers = async () => {
  loading.value = true
  try {
    const res = await api.getCustomers()
    if (res.success) customers.value = res.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

onMounted(loadCustomers)
</script>
