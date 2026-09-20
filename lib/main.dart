import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/state/locale_controller.dart';
import 'core/state/view_state.dart';
import 'core/state/theme_controller.dart';
import 'core/storage/prefs_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/views/auth_page.dart';
import 'features/customers/data/datasources/customers_remote_datasource.dart';
import 'features/customers/data/repositories/customers_repository_impl.dart';
import 'features/customers/domain/repositories/customers_repository.dart';
import 'features/customers/presentation/controllers/customers_controller.dart';
import 'features/customers/presentation/views/customers_page.dart';
import 'features/installments/data/datasources/installments_remote_datasource.dart';
import 'features/installments/data/repositories/installments_repository_impl.dart';
import 'features/installments/domain/repositories/installments_repository.dart';
import 'features/installments/presentation/controllers/installments_controller.dart';
import 'features/installments/presentation/views/installments_page.dart';
import 'features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/repositories/inventory_repository.dart';
import 'features/inventory/presentation/controllers/inventory_controller.dart';
import 'features/inventory/presentation/views/inventory_page.dart';
import 'features/reports/data/datasources/reports_remote_datasource.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/presentation/controllers/reports_controller.dart';
import 'features/reports/presentation/views/reports_page.dart';
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/settings/presentation/views/settings_page.dart';
import 'features/sales/data/datasources/sales_remote_datasource.dart';
import 'features/sales/data/repositories/sales_repository_impl.dart';
import 'features/sales/domain/repositories/sales_repository.dart';
import 'features/sales/presentation/controllers/sales_controller.dart';
import 'features/sales/presentation/views/sales_page.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'features/products/data/datasources/products_remote_datasource.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/repositories/products_repository.dart';
import 'features/products/presentation/controllers/products_controller.dart';
import 'features/products/presentation/views/products_page.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(AksatApp(prefs: PrefsService(preferences)));
}

class AksatApp extends StatelessWidget {
  const AksatApp({super.key, required this.prefs});

  final PrefsService prefs;

  @override
  Widget build(BuildContext context) {
    final authInterceptor = AuthInterceptor(
      const FlutterSecureStorage(),
      preferences: prefs.preferences,
    );
    final apiClient = ApiClient(authInterceptor)..init();
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(apiClient),
      authInterceptor,
    );
    final dashboardRepository = DashboardRepositoryImpl(
      DashboardRemoteDataSource(apiClient),
    );
    final productsRepository = ProductsRepositoryImpl(
      ProductsRemoteDataSource(apiClient),
    );
    final customersRepository = CustomersRepositoryImpl(
      CustomersRemoteDataSource(apiClient),
    );
    final installmentsRepository = InstallmentsRepositoryImpl(
      InstallmentsRemoteDataSource(apiClient),
    );
    final salesRepository = SalesRepositoryImpl(
      SalesRemoteDataSource(apiClient),
    );
    final inventoryRepository = InventoryRepositoryImpl(
      InventoryRemoteDataSource(apiClient),
    );
    final reportsRepository = ReportsRepositoryImpl(
      ReportsRemoteDataSource(apiClient),
    );
    final settingsRepository = SettingsRepositoryImpl(
      SettingsRemoteDataSource(apiClient),
    );

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthController(repository)..restoreSession(),
          ),
          ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
          ChangeNotifierProvider(create: (_) => ThemeController(prefs)),
          Provider<DashboardRepository>.value(value: dashboardRepository),
          Provider<ProductsRepository>.value(value: productsRepository),
          Provider<CustomersRepository>.value(value: customersRepository),
          Provider<InstallmentsRepository>.value(value: installmentsRepository),
          Provider<SalesRepository>.value(value: salesRepository),
          Provider<InventoryRepository>.value(value: inventoryRepository),
          Provider<ReportsRepository>.value(value: reportsRepository),
          Provider<SettingsRepository>.value(value: settingsRepository),
        ],
        child: Consumer2<LocaleController, ThemeController>(
          builder: (context, locale, theme, _) => MaterialApp(
            title: 'أقساط',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            locale: locale.locale,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            home: child,
          ),
        ),
      ),
      child: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (context.watch<AuthController>().status) {
      AuthStatus.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                DashboardController(context.read<DashboardRepository>())
                  ..load(),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ProductsController(context.read<ProductsRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                CustomersController(context.read<CustomersRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                InstallmentsController(context.read<InstallmentsRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                SalesController(context.read<SalesRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                InventoryController(context.read<InventoryRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                ReportsController(context.read<ReportsRepository>()),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                SettingsController(context.read<SettingsRepository>()),
          ),
        ],
        child: const DashboardShell(),
      ),
      AuthStatus.submitting ||
      AuthStatus.error ||
      AuthStatus.unauthenticated => const AuthPage(),
    };
  }
}

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    final textTheme = Theme.of(context).textTheme;
    final dashboard = context.watch<DashboardController>();
    final summary = dashboard.summary;
    final english =
        context.watch<LocaleController>().locale.languageCode == 'en';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _AppDrawer(
          onDashboard: () => Navigator.pop(context),
          onProducts: () => _openProducts(context),
          onCustomers: () => _openCustomers(context),
          onInstallments: () => _openInstallments(context),
          onSales: () => _openSales(context),
          onInventory: () => _openInventory(context),
          onReports: () => _openReports(context),
          onSettings: () => _openSettings(context),
        ),
        appBar: AppBar(
          title: Text(english ? 'Aksat' : 'أقساط'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
              tooltip: 'الإشعارات',
            ),
            IconButton(
              onPressed: () => context.read<AuthController>().logout(),
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  english ? 'Today summary' : 'ملخص اليوم',
                  style: textTheme.headlineSmall,
                ),
                SizedBox(height: 4.h),
                Text(
                  dashboard.state.isError
                      ? dashboard.errorMessage ??
                            (english
                                ? 'Unable to load data.'
                                : 'تعذر تحميل البيانات.')
                      : english
                      ? 'Your store and installments in one place.'
                      : 'بيانات متجرك ومتابعة الأقساط في مكان واحد.',
                  style: textTheme.bodyMedium,
                ),
                if (dashboard.state.isError) ...[
                  SizedBox(height: 12.h),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: dashboard.load,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(english ? 'Retry' : 'إعادة المحاولة'),
                    ),
                  ),
                ],
                SizedBox(height: 20.h),
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width >= 600
                      ? 4
                      : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.0,
                  children: [
                    _SummaryCard(
                      label: english ? 'Collected' : 'المحصّل',
                      value: _money(summary?.collected),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    _SummaryCard(
                      label: english ? 'Remaining' : 'المتبقي',
                      value: _money(summary?.remaining),
                      icon: Icons.pending_actions_rounded,
                    ),
                    _SummaryCard(
                      label: english ? 'Late installments' : 'الأقساط المتأخرة',
                      value: summary == null
                          ? '--'
                          : '${summary.lateInstallments}',
                      icon: Icons.warning_amber_rounded,
                    ),
                    _SummaryCard(
                      label: english ? 'Active sales' : 'المبيعات النشطة',
                      value: summary == null ? '--' : '${summary.activeSales}',
                      icon: Icons.receipt_long_outlined,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          color: colors?.textSecondary,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            summary == null
                                ? (english
                                      ? 'Loading your store data...'
                                      : 'جارٍ تحميل بيانات متجرك...')
                                : english
                                ? 'This week: ${summary.upcomingWeekCount} | This month: ${summary.upcomingMonthCount}'
                                : 'أقساط هذا الأسبوع: ${summary.upcomingWeekCount} | هذا الشهر: ${summary.upcomingMonthCount}',
                            style: textTheme.bodyMedium,
                          ),
                        ),
                        Icon(Icons.arrow_back_ios_new_rounded, size: 16.r),
                      ],
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

  void _openProducts(BuildContext context) {
    final controller = context.read<ProductsController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const ProductsPage(),
        ),
      ),
    );
  }

  void _openCustomers(BuildContext context) {
    final controller = context.read<CustomersController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const CustomersPage(),
        ),
      ),
    );
  }

  void _openInstallments(BuildContext context) {
    final controller = context.read<InstallmentsController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const InstallmentsPage(),
        ),
      ),
    );
  }

  void _openSales(BuildContext context) {
    final controller = context.read<SalesController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const SalesPage(),
        ),
      ),
    );
  }

  void _openInventory(BuildContext context) {
    final controller = context.read<InventoryController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const InventoryPage(),
        ),
      ),
    );
  }

  void _openReports(BuildContext context) {
    final controller = context.read<ReportsController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const ReportsPage(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final controller = context.read<SettingsController>();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const SettingsPage(),
        ),
      ),
    );
  }

  static String _money(Map<String, double>? values) {
    if (values == null) return '--';
    final usd = values['USD'] ?? 0;
    final local = values['LOCAL'] ?? 0;
    return 'USD ${usd.toStringAsFixed(2)}\nLOCAL ${local.toStringAsFixed(2)}';
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.onDashboard,
    required this.onProducts,
    required this.onCustomers,
    required this.onInstallments,
    required this.onSales,
    required this.onInventory,
    required this.onReports,
    required this.onSettings,
  });

  final VoidCallback onDashboard;
  final VoidCallback onProducts;
  final VoidCallback onCustomers;
  final VoidCallback onInstallments;
  final VoidCallback onSales;
  final VoidCallback onInventory;
  final VoidCallback onReports;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final english =
        context.watch<LocaleController>().locale.languageCode == 'en';
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                  english ? 'Aksat' : 'أقساط',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(english ? 'Dashboard' : 'الرئيسية'),
              onTap: onDashboard,
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(english ? 'Products' : 'المواد'),
              onTap: onProducts,
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded),
              title: Text(english ? 'Customers' : 'المشترون'),
              onTap: onCustomers,
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(english ? 'Installments' : 'الأقساط'),
              onTap: onInstallments,
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: Text(english ? 'Sales' : 'المبيعات'),
              onTap: onSales,
            ),
            ListTile(
              leading: const Icon(Icons.warehouse_outlined),
              title: Text(english ? 'Inventory' : 'المخزن'),
              onTap: onInventory,
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(english ? 'Reports' : 'التقارير'),
              onTap: onReports,
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(english ? 'Settings' : 'الإعدادات'),
              onTap: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>();
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors?.primary, size: 24.r),
            SizedBox(height: 4.h),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: 2.h),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
