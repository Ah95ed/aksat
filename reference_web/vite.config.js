import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'autoUpdate',
      // لإضافة وسوم الـ HTML تلقائياً للتحكم في الأيقونات
      injectRegister: 'auto',
      manifest: {
        name: 'اسم تطبيقك الكامل',
        short_name: 'التطبيق', // الاسم الذي سيظهر تحت الأيقونة على شاشة الموبايل
        description: 'وصف مختصر للتطبيق',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        display: 'standalone',
        icons: [
          {
            src: '/icon.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: '/icon.png',
            sizes: '512x512',
            type: 'image/png'
          },
          {
            src: '/icon.png',
            sizes: '501x498',
            type: 'image/png',
            purpose: 'any maskable' // لتناسب الأيقونة الأشكال المختلفة لشاشات أندرويد
          }
        ]
      }
    })
  ],

  // التغيير هنا: استخدام '/' بدلاً من './' لأن المشروع يعمل على المسار الرئيسي للدومين
  base: '/',

  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  },

  // هذا الجزء خاص بالسيرفر المحلي فقط ولن يؤثر على السيرفر الخارجي (Production)
  server: {
    port: 3000,

    proxy: {
      '/api': {
        target: 'http://localhost/aksat',
        changeOrigin: true,
        secure: false
      }
    }
  }
})