// ============ Helpers ============

// تنسيق التاريخ بالعربي
export function formatDate(date) {
  if (!date) return '-'
  const d = new Date(date)
  return d.toLocaleDateString('ar-EG', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// تنسيق التاريخ المختصر
export function formatDateShort(date) {
  if (!date) return '-'
  const d = new Date(date)
  const day = String(d.getDate()).padStart(2, '0')
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const year = d.getFullYear()
  return `${day}/${month}/${year}`
}

// تنسيق المبلغ
export function formatAmount(amount) {
  if (amount === null || amount === undefined) return '0'
  return Number(amount).toLocaleString('en-US', {
    minimumFractionDigits: 0,
    maximumFractionDigits: 2
  })
}

// رمز العملة
export function currencySymbol(currency, settings = {}) {
  if (currency === 'USD') return '$'
  return settings.currency_symbol || 'د.ع'
}

// اسم العملة
export function currencyName(currency, settings = {}) {
  if (currency === 'USD') return 'دولار'
  return settings.currency_name || 'دينار'
}

// تحويل العملة
export function convertCurrency(amount, fromCurrency, toCurrency, exchangeRate) {
  if (fromCurrency === toCurrency) return amount
  const rate = parseFloat(exchangeRate) || 1
  
  if (fromCurrency === 'USD' && toCurrency === 'LOCAL') {
    return amount * rate
  }
  if (fromCurrency === 'LOCAL' && toCurrency === 'USD') {
    return amount / rate
  }
  return amount
}

// عدد الأيام المتبقية
export function daysUntil(date) {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const target = new Date(date)
  target.setHours(0, 0, 0, 0)
  const diff = Math.floor((target - today) / (1000 * 60 * 60 * 24))
  return diff
}

// نص الأيام المتبقية
export function daysUntilText(date) {
  const days = daysUntil(date)
  if (days < 0) return `متأخر ${Math.abs(days)} يوم`
  if (days === 0) return 'اليوم'
  if (days === 1) return 'غداً'
  if (days <= 7) return `خلال ${days} أيام`
  return `خلال ${days} يوم`
}

// تنسيق رقم الهاتف لرابط واتساب
export function formatPhoneForWhatsApp(phone) {
  if (!phone) return ''
  // إزالة كل ما ليس رقماً
  let cleaned = phone.replace(/[^0-9]/g, '')
  // إذا يبدأ بصفر، يُستبدل بـ 964 (عراق افتراضي)
  if (cleaned.startsWith('0')) {
    cleaned = '964' + cleaned.substring(1)
  }
  return cleaned
}

// إنشاء رابط واتساب
export function whatsappLink(phone, message) {
  const formattedPhone = formatPhoneForWhatsApp(phone)
  const encodedMessage = encodeURIComponent(message)
  return `https://wa.me/${formattedPhone}?text=${encodedMessage}`
}
