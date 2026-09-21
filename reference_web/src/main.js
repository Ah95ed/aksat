import { createApp } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import App from './App.vue'
import './style.css'

// استيراد صفحات المصادقة (الدخول والتسجيل)
import Login from './views/Login.vue' // تأكد من وجود هذا الملف في مجلد views
import Register from './views/Register.vue'
import AdminLogin from './views/AdminLogin.vue'
import AdminPanel from './views/AdminPanel.vue'

// استيراد الصفحات الأخرى
import Dashboard from './views/Dashboard.vue'
import Products from './views/Products.vue'
import NewSale from './views/NewSale.vue'
import Customers from './views/Customers.vue'
import CustomerDetails from './views/CustomerDetails.vue'
import UpcomingInstallments from './views/UpcomingInstallments.vue'
import Settings from './views/Settings.vue'
import Inventory from './views/Inventory.vue'
import Reports from './views/Reports.vue'

const routes = [
  // مسارات المصادقة
  { path: '/login', component: Login, name: 'login' },
  { path: '/register', component: Register, name: 'register' },
  { path: '/admin/login', component: AdminLogin, name: 'admin-login' },
  { path: '/admin', component: AdminPanel, name: 'admin-panel' },
  
  // مسارات النظام
  { path: '/', component: Dashboard, name: 'dashboard' },
  { path: '/products', component: Products, name: 'products' },
  { path: '/inventory', component: Inventory, name: 'inventory' },
  { path: '/new-sale', component: NewSale, name: 'new-sale' },
  { path: '/customers', component: Customers, name: 'customers' },
  { path: '/customers/:id', component: CustomerDetails, name: 'customer-details' },
  { path: '/upcoming', component: UpcomingInstallments, name: 'upcoming' },
  { path: '/reports', component: Reports, name: 'reports' },
  { path: '/settings', component: Settings, name: 'settings' }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// === حارس التوجيه (Navigation Guard) لحماية المسارات ===
router.beforeEach((to, from, next) => {
  // التحقق من وجود التوكن في التخزين المحلي (يدل على أن المستخدم مسجل الدخول)
  const isAuthenticated = localStorage.getItem('token');
  
  // الصفحات التي يُسمح للزوار بفتحها بدون تسجيل دخول
  const publicPages = ['/login', '/register', '/admin/login'];
  const authRequired = !publicPages.includes(to.path);

  // مسارات الأدمن لها منطق توجيه مستقل (يتم التحقق من صلاحية الأدمن داخل AdminPanel.vue)
  if (to.path === '/admin' || to.path === '/admin/login') {
    if (to.path === '/admin' && !isAuthenticated) {
      next('/admin/login');
    } else {
      next();
    }
    return;
  }

  if (authRequired && !isAuthenticated) {
    // 1. إذا كان المسار محمي والمستخدم غير مسجل -> تحويله لصفحة تسجيل الدخول
    next('/login');
  } else if (!authRequired && isAuthenticated) {
    // 2. إذا كان مسجلاً وحاول فتح صفحة الدخول أو التسجيل -> إعادته للوحة التحكم
    next('/');
  } else {
    // 3. السماح بالمرور في الحالات العادية
    next();
  }
})

const app = createApp(App)
app.use(router)
app.mount('#app')