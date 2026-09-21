import axios from 'axios'

// مسار السيرفر المحلي على WAMP
const API_BASE = '/api'

const api = axios.create({
  baseURL: API_BASE,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 1. إرفاق التوكن تلقائياً مع كل طلب
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
      // Header إضافي لتجاوز إعدادات Apache التي قد تمنع تمرير Authorization.
      config.headers['X-Authorization'] = `Bearer ${token}`
    }
    return config
  },
  error => Promise.reject(error)
)

// 2. التعامل مع الاستجابات والأخطاء والطرد التلقائي عند إلغاء الاشتراك (401)
api.interceptors.response.use(
  response => response.data,
  error => {
    console.error('API Error:', error)

    // عند إرجاع كود 401 (عندما يلغى الاشتراك أو تنتهي الجلسة)
    if (error.response && error.response.status === 401) {
      // مسح التوكن والبيانات المخزنة محلياً
      localStorage.removeItem('token')
      localStorage.removeItem('user')

      // إعادة توجيه المستخدم لصفحة تسجيل الدخول فوراً
      // ملاحظة: التطبيق يستخدم hash routing (createWebHashHistory)، لذا التحويل
      // يجب أن يكون عبر window.location.hash وليس pathname/href، وإلا يفتح الرابط
      // بدون '#' ثم يعاد توجيهه من جديد داخلياً فيصير الرابط مزدوجاً (login?expired=1#/login)
      if (window.location.hash !== '#/login') {
        window.location.hash = '/login?expired=1'
        window.location.reload()
      }
    }

    return Promise.reject(error.response?.data || { message: 'تعذر الاتصال بالخادم، تأكد من اتصالك بالإنترنت' })
  }
)

export default {
  // ============ Auth (الحسابات) ============
  login(credentials) {
    return api.post('/login.php', credentials)
  },
  register(data) {
    return api.post('/register.php', data)
  },

  // ============ Dashboard ============
  getDashboard() {
    return api.get('/dashboard.php')
  },
  
  // ============ Products ============
  getProducts() {
    return api.get('/products.php')
  },
  createProduct(data) {
    return api.post('/products.php', data)
  },
  updateProduct(data) {
    return api.put('/products.php', data)
  },
  deleteProduct(id) {
    return api.delete(`/products.php?id=${id}`)
  },
  
  // ============ Customers ============
  getCustomers() {
    return api.get('/customers.php')
  },
  getCustomer(id) {
    return api.get(`/customers.php?id=${id}`)
  },
  searchCustomers(query) {
    return api.get(`/customers.php?search=${encodeURIComponent(query)}`)
  },
  createCustomer(data) {
    return api.post('/customers.php', data)
  },
  updateCustomer(data) {
    return api.put('/customers.php', data)
  },
  deleteCustomer(id) {
    return api.delete(`/customers.php?id=${id}`)
  },
  
  // ============ Sales ============
  createSale(data) {
    return api.post('/sales.php', data)
  },
  getSales() {
    return api.get('/sales.php')
  },
  deleteSale(id) {
    return api.delete(`/sales.php?id=${id}`)
  },
  
  // ============ Installments ============
  getInstallments(filter = 'all') {
    return api.get(`/installments.php?filter=${filter}`)
  },
  payInstallment(id, paidDate = null) {
    return api.put('/installments.php', { 
      id, 
      action: 'pay',
      paid_date: paidDate
    })
  },
  unpayInstallment(id) {
    return api.put('/installments.php', { id, action: 'unpay' })
  },
  updateInstallmentNotes(id, notes) {
    return api.put('/installments.php', { id, action: 'update_notes', notes })
  },
  
  // ============ Settings ============
  getSettings() {
    return api.get('/settings.php')
  },
  updateSettings(data) {
    return api.put('/settings.php', data)
  },
  
  // ============ Inventory ============
  getInventory() {
    return api.get('/inventory.php')
  },
  getInventoryByProduct(productId) {
    return api.get(`/inventory.php?product_id=${productId}`)
  },
  getInventoryMovements(productId) {
    return api.get(`/inventory.php?movements=${productId}`)
  },
  getLowStock() {
    return api.get('/inventory.php?low_stock=1')
  },
  setInventory(data) {
    return api.post('/inventory.php', data)
  },
  updateInventorySettings(data) {
    return api.put('/inventory.php', data)
  },
  removeInventoryTracking(productId) {
    return api.delete(`/inventory.php?product_id=${productId}`)
  },
  
  // ============ Reports ============
  getReportSummary(period = 'all', currency = 'all', from = null, to = null) {
    let url = `/reports.php?type=summary&period=${period}&currency=${currency}`
    if (from) url += `&from=${from}`
    if (to) url += `&to=${to}`
    return api.get(url)
  },
  getReportByProduct(period = 'all', currency = 'all', from = null, to = null) {
    let url = `/reports.php?type=by_product&period=${period}&currency=${currency}`
    if (from) url += `&from=${from}`
    if (to) url += `&to=${to}`
    return api.get(url)
  },
  getTopSelling(period = 'all', currency = 'all', from = null, to = null) {
    let url = `/reports.php?type=top_selling&period=${period}&currency=${currency}`
    if (from) url += `&from=${from}`
    if (to) url += `&to=${to}`
    return api.get(url)
  },
  getReportTimeline(period = 'all', groupBy = 'month', currency = 'all', from = null, to = null) {
    let url = `/reports.php?type=timeline&period=${period}&group_by=${groupBy}&currency=${currency}`
    if (from) url += `&from=${from}`
    if (to) url += `&to=${to}`
    return api.get(url)
  },
  getProductSalesDetail(productId, period = 'all', from = null, to = null) {
    let url = `/reports.php?type=product_detail&product_id=${productId}&period=${period}`
    if (from) url += `&from=${from}`
    if (to) url += `&to=${to}`
    return api.get(url)
  },
  
  // ============ Admin ============
  adminGetMe() {
    return api.get('/admin.php?action=me')
  },
  adminGetAdmins() {
    return api.get('/admin.php?action=admins')
  },
  adminAddAdmin(email) {
    return api.post('/admin.php?action=add_admin', { email })
  },
  adminRemoveAdmin(user_id) {
    return api.post('/admin.php?action=remove_admin', { user_id })
  },
  adminGetSubscribers() {
    return api.get('/admin.php?action=subscribers')
  },
  adminSetSubscription(user_id, duration_value, duration_unit) {
    return api.post('/admin.php?action=set_subscription', { user_id, duration_value, duration_unit })
  },
  adminCancelSubscription(user_id) {
    return api.post('/admin.php?action=cancel_subscription', { user_id })
  }
}