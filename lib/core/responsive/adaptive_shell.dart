import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import '../utils/whatsapp_launcher.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';
import 'breakpoints.dart';

class NavItem {
  const NavItem({
    required this.route,
    required this.label,
    required this.labelEn,
    required this.emoji,
  });

  final String route;
  final String label;
  final String labelEn;
  final String emoji;
}

class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.child,
  });

  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final Widget child;

  static const List<NavItem> navItems = [
    NavItem(route: '/', label: 'لوحة التحكم', labelEn: 'Dashboard', emoji: '🏠'),
    NavItem(route: '/products', label: 'المواد', labelEn: 'Products', emoji: '📦'),
    NavItem(route: '/inventory', label: 'المخزن', labelEn: 'Inventory', emoji: '🏪'),
    NavItem(route: '/new-sale', label: 'إضافة بيع', labelEn: 'New Sale', emoji: '➕'),
    NavItem(route: '/customers', label: 'المشترين', labelEn: 'Customers', emoji: '👥'),
    NavItem(route: '/upcoming', label: 'الأقساط القادمة', labelEn: 'Upcoming', emoji: '🔔'),
    NavItem(route: '/reports', label: 'التقارير', labelEn: 'Reports', emoji: '📊'),
    NavItem(route: '/settings', label: 'الإعدادات', labelEn: 'Settings', emoji: '⚙️'),
  ];

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _drawerOpen = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < Breakpoints.mobile;

    final settingsCtrl = context.watch<SettingsController>();
    final storeName = settingsCtrl.settings.storeName.isNotEmpty
        ? settingsCtrl.settings.storeName
        : 'متجري';
    final remainingDays = settingsCtrl.settings.subscriptionRemainingDays;

    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildSidebar({required ValueChanged<String> onSelect}) => _SidebarContent(
      currentRoute: widget.currentRoute,
      storeName: storeName,
      isArabic: isArabic,
      isDark: isDark,
      onSelect: onSelect,
    );

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        drawerScrimColor: AppColors.modalBackdrop,
        onDrawerChanged: (isOpen) {
          setState(() {
            _drawerOpen = isOpen;
          });
        },
        drawer: isMobile && !isArabic
            ? Drawer(
                width: AppDimens.sidebarWidth,
                child: buildSidebar(
                  onSelect: (route) {
                    Navigator.of(context).pop();
                    widget.onNavigate(route);
                  },
                ),
              )
            : null,
        endDrawer: isMobile && isArabic
            ? Drawer(
                width: AppDimens.sidebarWidth,
                child: buildSidebar(
                  onSelect: (route) {
                    Navigator.of(context).pop();
                    widget.onNavigate(route);
                  },
                ),
              )
            : null,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                  : const [AppColors.pageBgFrom, AppColors.pageBgTo],
            ),
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fixed sidebar for >= 768px (placed on the right in RTL, on the left in LTR)
                  if (!isMobile)
                    SizedBox(
                      width: AppDimens.sidebarWidth,
                      child: buildSidebar(onSelect: widget.onNavigate),
                    ),

                  // Main content
                  Expanded(
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: Breakpoints.maxContentWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Subscription warning banner (Section 6.3)
                              if (remainingDays != null &&
                                  remainingDays >= 0 &&
                                  remainingDays <= 2)
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    isMobile ? 16 : 32,
                                    16,
                                    isMobile ? 16 : 32,
                                    0,
                                  ),
                                  child: _SubscriptionBanner(
                                    remainingDays: remainingDays,
                                    isMobile: isMobile,
                                  ),
                                ),

                              Expanded(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                                  child: widget.child,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Floating hamburger button for mobile (< 768px)
              // Lowered below status bar using MediaQuery.paddingOf(context).top + 10
              if (isMobile)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 10,
                  left: 16,
                  child: Material(
                    color: AppColors.blue600,
                    borderRadius: AppDimens.borderLg,
                    elevation: 4,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      onTap: () {
                        if (_drawerOpen) {
                          Navigator.of(context).pop();
                        } else {
                          if (isArabic) {
                            _scaffoldKey.currentState?.openEndDrawer();
                          } else {
                            _scaffoldKey.currentState?.openDrawer();
                          }
                        }
                      },
                      borderRadius: AppDimens.borderLg,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          _drawerOpen ? Icons.close : Icons.menu,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarContent extends StatefulWidget {
  const _SidebarContent({
    required this.currentRoute,
    required this.storeName,
    required this.isArabic,
    required this.isDark,
    required this.onSelect,
  });

  final String currentRoute;
  final String storeName;
  final bool isArabic;
  final bool isDark;
  final ValueChanged<String> onSelect;

  @override
  State<_SidebarContent> createState() => _SidebarContentState();
}

class _SidebarContentState extends State<_SidebarContent> {
  final ScrollController _scrollController = ScrollController();
  bool _logoError = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isDark
              ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
              : const [AppColors.blue700, AppColors.blue900],
        ),
        border: widget.isDark
            ? const Border(
                left: BorderSide(color: Color(0xFF334155), width: 1),
                right: BorderSide(color: Color(0xFF334155), width: 1),
              )
            : null,
      ),
      child: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Padding 16, bottom border blue600 / borderDark)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: widget.isDark ? const Color(0xFF334155) : AppColors.blue600,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_logoError)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: AppDimens.borderLg,
                            boxShadow: AppShadows.sm,
                          ),
                          child: ClipRRect(
                            borderRadius: AppDimens.borderMd,
                            child: Image.asset(
                              'assets/images/icon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) setState(() => _logoError = true);
                                });
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      Text(
                        widget.storeName,
                        style: AppTextStyles.lgBold(AppColors.white),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.isArabic ? 'نظام إدارة الأقساط' : 'Installment Management',
                        style: AppTextStyles.xs(AppColors.blue200),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Support box (Section 6.2)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF1E293B)
                        : AppColors.blue800.withValues(alpha: 0.4),
                    borderRadius: AppDimens.borderXl,
                    border: Border.all(
                      color: widget.isDark
                          ? const Color(0xFF334155)
                          : AppColors.blue600.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isArabic ? 'الدعم الفني والخدمة' : 'Technical Support',
                        style: AppTextStyles.xsMedium(AppColors.blue200),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // Call button
                      Material(
                        color: AppColors.blue600,
                        borderRadius: AppDimens.borderLg,
                        child: InkWell(
                          onTap: () => WhatsAppLauncher.makeCall(AppConfig.supportPhone),
                          borderRadius: AppDimens.borderLg,
                          highlightColor: AppColors.blue500,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📞', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    AppConfig.supportPhone,
                                    style: AppTextStyles.xs(AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // WhatsApp button
                      Material(
                        color: AppColors.emerald600,
                        borderRadius: AppDimens.borderLg,
                        child: InkWell(
                          onTap: () => WhatsAppLauncher.launchWhatsApp(
                            phone: AppConfig.whatsappPhone,
                            message: 'السلام عليكم',
                          ),
                          borderRadius: AppDimens.borderLg,
                          highlightColor: AppColors.emerald500,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('💬', style: TextStyle(fontSize: 13)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isArabic ? 'مراسلة واتساب' : 'WhatsApp Chat',
                                  style: AppTextStyles.xsMedium(AppColors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Links (8 items in sequence)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    children: AdaptiveShell.navItems.map((item) {
                      final isActive = widget.currentRoute == item.route;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Material(
                          color: isActive ? AppColors.blue600 : Colors.transparent,
                          borderRadius: AppDimens.borderLg,
                          child: InkWell(
                            onTap: () => widget.onSelect(item.route),
                            borderRadius: AppDimens.borderLg,
                            hoverColor: AppColors.blue600.withValues(alpha: 0.8),
                            splashColor: AppColors.blue600,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.isArabic ? item.label : item.labelEn,
                                    style: AppTextStyles.smMedium(AppColors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Footer: v1.0.0
                Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text(
                    AppConfig.version,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.blue300,
                      fontFamily: AppTextStyles.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner({
    required this.remainingDays,
    required this.isMobile,
  });

  final int remainingDays;
  final bool isMobile;

  String _buildMessage() {
    if (remainingDays == 0) {
      return 'تنبيه: سينتهي اشتراكك اليوم! يرجى التواصل معنا لتجديد الاشتراك.';
    }
    if (remainingDays == 1) {
      return 'تنبيه: سينتهي اشتراكك غداً! يرجى التواصل معنا لتجديد الاشتراك.';
    }
    return 'تنبيه: سينتهي اشتراكك خلال $remainingDays يومين! يرجى التواصل معنا لتجديد الاشتراك.';
  }

  @override
  Widget build(BuildContext context) {
    final buttons = Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: [
        // Call button
        Material(
          color: AppColors.red600,
          borderRadius: AppDimens.borderLg,
          child: InkWell(
            onTap: () => WhatsAppLauncher.makeCall(AppConfig.supportPhone),
            borderRadius: AppDimens.borderLg,
            highlightColor: AppColors.red700,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📞', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      AppConfig.supportPhone,
                      style: AppTextStyles.smMedium(AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // WhatsApp button
        Material(
          color: AppColors.emerald600,
          borderRadius: AppDimens.borderLg,
          child: InkWell(
            onTap: () => WhatsAppLauncher.launchWhatsApp(
              phone: AppConfig.whatsappPhone,
              message: 'السلام عليكم، أرغب بتجديد اشتراكي',
            ),
            borderRadius: AppDimens.borderLg,
            highlightColor: AppColors.emerald500,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💬', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    'واتساب',
                    style: AppTextStyles.smMedium(AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppDimens.p4),
      decoration: BoxDecoration(
        color: AppColors.red50,
        borderRadius: AppDimens.borderXl,
        border: Border.all(color: AppColors.red400, width: 2),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _buildMessage(),
                        style: AppTextStyles.smBold(AppColors.red800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                buttons,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _buildMessage(),
                      style: AppTextStyles.smBold(AppColors.red800),
                    ),
                  ],
                ),
                buttons,
              ],
            ),
    );
  }
}
