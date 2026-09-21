import 'package:flutter/material.dart';

/// Exact Tailwind color tokens and semantic definitions for the Aksat system.
class AppColors {
  AppColors._();

  // Blue
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB); // Primary
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue950 = Color(0xFF172554);

  // Green
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A); // Success
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);

  // Emerald
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);

  // Amber
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B); // Warning
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // Red
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red400 = Color(0xFFF87171);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626); // Danger
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);

  // Purple
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple700 = Color(0xFF7E22CE);

  // Indigo
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo700 = Color(0xFF4338CA);

  // Yellow & Orange
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow400 = Color(0xFFFACC15);
  static const Color yellow600 = Color(0xFFCA8A04);
  static const Color orange50 = Color(0xFFFFF7ED);

  // Gray
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Slate
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);

  // Page background gradient (135° topLeft -> bottomRight)
  static const Color pageBgFrom = Color(0xFFF0F4F8);
  static const Color pageBgTo = Color(0xFFE2E8F0);

  // Constants
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color modalBackdrop = Color(0x80000000); // black 50%

  // Semantic mappings (Light)
  static const Color primary = blue600;
  static const Color primaryHover = blue700;
  static const Color success = green600;
  static const Color danger = red600;
  static const Color warning = amber500;
  static const Color textPrimary = gray800;
  static const Color textSecondary = gray600;
  static const Color textMuted = gray500;
  static const Color border = gray300;
  static const Color divider = gray200;

  // Single helper function for installment status
  static InstallmentStatusInfo getInstallmentStatus(String? status) {
    switch (status) {
      case 'paid':
        return const InstallmentStatusInfo(
          rowBg: green50,
          badgeBg: green100,
          badgeText: green800,
          label: 'مدفوع',
          emoji: '✅',
        );
      case 'late':
        return const InstallmentStatusInfo(
          rowBg: red50,
          badgeBg: red100,
          badgeText: red800,
          label: 'متأخر',
          emoji: '⚠️',
        );
      default:
        return const InstallmentStatusInfo(
          rowBg: Colors.transparent,
          badgeBg: blue100,
          badgeText: blue800,
          label: 'قادم',
          emoji: '⏳',
        );
    }
  }

  // Stock status helper
  static StockStatusInfo getStockStatus(String? status) {
    switch (status) {
      case 'not_tracked':
        return const StockStatusInfo(
          badgeBg: gray200,
          badgeText: gray700,
          label: 'غير مُتتبَّع',
          emoji: '⏸️',
        );
      case 'out_of_stock':
        return const StockStatusInfo(
          badgeBg: red100,
          badgeText: red800,
          label: 'نفد',
          emoji: '🚫',
        );
      case 'low_stock':
        return const StockStatusInfo(
          badgeBg: amber100,
          badgeText: amber800,
          label: 'منخفض',
          emoji: '⚠️',
        );
      default:
        return const StockStatusInfo(
          badgeBg: green100,
          badgeText: green800,
          label: 'متوفر',
          emoji: '✅',
        );
    }
  }
}

class InstallmentStatusInfo {
  const InstallmentStatusInfo({
    required this.rowBg,
    required this.badgeBg,
    required this.badgeText,
    required this.label,
    required this.emoji,
  });

  final Color rowBg;
  final Color badgeBg;
  final Color badgeText;
  final String label;
  final String emoji;

  String get fullText => '$emoji $label';
}

class StockStatusInfo {
  const StockStatusInfo({
    required this.badgeBg,
    required this.badgeText,
    required this.label,
    required this.emoji,
  });

  final Color badgeBg;
  final Color badgeText;
  final String label;
  final String emoji;

  String get fullText => '$emoji $label';
}
