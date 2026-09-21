<template>
  <div class="min-h-screen bg-gray-100">
    <header class="bg-gray-900 text-white p-4 flex items-center justify-between">
      <h1 class="text-lg font-bold">لوحة تحكم الأدمن</h1>
      <button @click="logout" class="text-sm bg-gray-700 hover:bg-gray-600 px-3 py-1.5 rounded">تسجيل الخروج</button>
    </header>

    <div class="p-4 md:p-8 max-w-6xl mx-auto">
      <div v-if="toast" :class="toastError ? 'bg-red-100 text-red-700' : 'bg-green-100 text-green-700'" class="p-3 rounded mb-4 text-sm text-center">
        {{ toast }}
      </div>

      <!-- تبويبات -->
      <div class="flex gap-2 mb-6 border-b border-gray-300">
        <button
          @click="tab = 'subscribers'"
          class="px-4 py-2 font-medium"
          :class="tab === 'subscribers' ? 'border-b-2 border-gray-900 text-gray-900' : 'text-gray-500'"
        >المشتركين ({{ subscribers.length }})</button>
        <button
          @click="tab = 'admins'"
          class="px-4 py-2 font-medium"
          :class="tab === 'admins' ? 'border-b-2 border-gray-900 text-gray-900' : 'text-gray-500'"
        >المدراء ({{ admins.length }})</button>
      </div>

      <!-- ============ المشتركين ============ -->
      <div v-if="tab === 'subscribers'">
        <div class="bg-white rounded-lg shadow overflow-x-auto">
          <table class="w-full text-sm text-right">
            <thead class="bg-gray-50 text-gray-600">
              <tr>
                <th class="p-3">الاسم</th>
                <th class="p-3">البريد الإلكتروني</th>
                <th class="p-3">تاريخ التسجيل</th>
                <th class="p-3">حالة الاشتراك</th>
                <th class="p-3">المتبقي</th>
                <th class="p-3">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="s in subscribers" :key="s.id" class="border-t">
                <td class="p-3 font-medium">{{ s.name }}</td>
                <td class="p-3 text-gray-500" dir="ltr">{{ s.email }}</td>
                <td class="p-3 text-gray-500">{{ formatDate(s.created_at) }}</td>
                <td class="p-3">
                  <span :class="statusBadge(s.subscription_status)" class="px-2 py-1 rounded text-xs font-bold">
                    {{ statusLabel(s.subscription_status) }}
                  </span>
                </td>
                <td class="p-3">
                  <span v-if="s.end_date">
                    {{ remainingLabel(s) }}
                  </span>
                  <span v-else class="text-gray-400">لا يوجد اشتراك</span>
                </td>
                <td class="p-3">
                  <div class="flex gap-2 flex-wrap">
                    <button @click="openSubModal(s)" class="text-xs bg-blue-600 text-white px-2 py-1 rounded hover:bg-blue-700">
                      تفعيل / تجديد
                    </button>
                    <button
                      v-if="s.subscription_status === 'active'"
                      @click="cancelSub(s)"
                      class="text-xs bg-red-600 text-white px-2 py-1 rounded hover:bg-red-700"
                    >
                      إلغاء الاشتراك
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="!subscribers.length">
                <td colspan="6" class="p-6 text-center text-gray-400">لا يوجد مشتركون بعد</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ============ المدراء ============ -->
      <div v-if="tab === 'admins'">
        <div class="bg-white rounded-lg shadow p-4 mb-4">
          <h3 class="font-bold mb-3">إضافة أدمن جديد</h3>
          <p class="text-xs text-gray-500 mb-2">يجب أن يكون البريد الإلكتروني مسجلاً كحساب مسبقاً في النظام.</p>
          <div class="flex gap-2">
            <input
              v-model="newAdminEmail"
              type="email"
              dir="ltr"
              placeholder="user@example.com"
              class="flex-1 px-3 py-2 border border-gray-300 rounded"
            >
            <button @click="addAdmin" class="bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800">إضافة</button>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow overflow-x-auto">
          <table class="w-full text-sm text-right">
            <thead class="bg-gray-50 text-gray-600">
              <tr>
                <th class="p-3">الاسم</th>
                <th class="p-3">البريد الإلكتروني</th>
                <th class="p-3">تاريخ الإضافة</th>
                <th class="p-3">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="a in admins" :key="a.id" class="border-t">
                <td class="p-3 font-medium">{{ a.name }}</td>
                <td class="p-3 text-gray-500" dir="ltr">{{ a.email }}</td>
                <td class="p-3 text-gray-500">{{ formatDate(a.created_at) }}</td>
                <td class="p-3">
                  <button
                    v-if="a.id !== me.id"
                    @click="removeAdmin(a)"
                    class="text-xs bg-red-600 text-white px-2 py-1 rounded hover:bg-red-700"
                  >
                    إلغاء صلاحية الأدمن
                  </button>
                  <span v-else class="text-xs text-gray-400">(أنت)</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Modal تفعيل/تجديد الاشتراك -->
    <div v-if="subModal.open" class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-lg shadow-lg p-6 w-full max-w-sm">
        <h3 class="font-bold mb-4">تفعيل/تجديد اشتراك: {{ subModal.target?.name }}</h3>
        <div class="flex gap-2 mb-4">
          <input v-model.number="subModal.value" type="number" min="1" class="w-24 px-3 py-2 border border-gray-300 rounded">
          <select v-model="subModal.unit" class="flex-1 px-3 py-2 border border-gray-300 rounded">
            <option value="day">يوم</option>
            <option value="week">أسبوع</option>
            <option value="month">شهر</option>
            <option value="year">سنة</option>
          </select>
        </div>
        <div class="flex gap-2 justify-end">
          <button @click="subModal.open = false" class="px-4 py-2 rounded border border-gray-300">إلغاء</button>
          <button @click="confirmSub" class="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700">تأكيد</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../api'

const router = useRouter()
const tab = ref('subscribers')
const me = ref({})
const admins = ref([])
const subscribers = ref([])
const newAdminEmail = ref('')
const toast = ref('')
const toastError = ref(false)

const subModal = ref({ open: false, target: null, value: 1, unit: 'month' })

const showToast = (msg, isError = false) => {
  toast.value = msg
  toastError.value = isError
  setTimeout(() => { toast.value = '' }, 3500)
}

const loadAll = async () => {
  try {
    const meRes = await api.adminGetMe()
    me.value = meRes.data

    const [adminsRes, subsRes] = await Promise.all([
      api.adminGetAdmins(),
      api.adminGetSubscribers()
    ])
    admins.value = adminsRes.data
    subscribers.value = subsRes.data
  } catch (e) {
    // ليس أدمن أو التوكن غير صالح -> إعادة توجيه لصفحة دخول الأدمن
    localStorage.removeItem('token')
    router.push('/admin/login')
  }
}

const addAdmin = async () => {
  if (!newAdminEmail.value) return
  try {
    const res = await api.adminAddAdmin(newAdminEmail.value)
    showToast(res.message, !res.success)
    if (res.success) {
      newAdminEmail.value = ''
      await loadAll()
    }
  } catch (e) {
    showToast(e.message || 'حدث خطأ', true)
  }
}

const removeAdmin = async (a) => {
  if (!confirm(`هل أنت متأكد من إلغاء صلاحية الأدمن عن ${a.name}؟`)) return
  try {
    const res = await api.adminRemoveAdmin(a.id)
    showToast(res.message, !res.success)
    await loadAll()
  } catch (e) {
    showToast(e.message || 'حدث خطأ', true)
  }
}

const openSubModal = (s) => {
  subModal.value = { open: true, target: s, value: 1, unit: 'month' }
}

const confirmSub = async () => {
  const { target, value, unit } = subModal.value
  try {
    const res = await api.adminSetSubscription(target.id, value, unit)
    showToast(res.message, !res.success)
    subModal.value.open = false
    await loadAll()
  } catch (e) {
    showToast(e.message || 'حدث خطأ', true)
  }
}

const cancelSub = async (s) => {
  if (!confirm(`هل تريد إلغاء اشتراك ${s.name}؟ لن يتمكن من الدخول للنظام بعد ذلك`)) return
  try {
    const res = await api.adminCancelSubscription(s.id)
    showToast(res.message, !res.success)
    await loadAll()
  } catch (e) {
    showToast(e.message || 'حدث خطأ', true)
  }
}

const formatDate = (d) => d ? new Date(d).toLocaleDateString('ar-EG') : '-'

const statusLabel = (status) => ({
  active: 'نشط',
  cancelled: 'ملغى',
  expired: 'منتهي'
}[status] || status)

const statusBadge = (status) => ({
  active: 'bg-green-100 text-green-700',
  cancelled: 'bg-red-100 text-red-700',
  expired: 'bg-orange-100 text-orange-700'
}[status] || 'bg-gray-100 text-gray-700')

const remainingLabel = (s) => {
  if (s.current_sub_status !== 'active') return statusLabel(s.current_sub_status)
  const days = s.remaining_days
  if (days === null || days === undefined) return '-'
  if (days < 0) return 'منتهي'
  if (days === 0) return 'ينتهي اليوم'
  if (days < 7) return `${days} يوم`
  if (days < 30) return `${Math.round(days / 7)} أسبوع`
  if (days < 365) return `${Math.round(days / 30)} شهر`
  return `${Math.round(days / 365)} سنة`
}

const logout = () => {
  localStorage.removeItem('token')
  window.location.hash = '/admin/login'
  window.location.reload()
}

onMounted(loadAll)
</script>
