import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/responsive/adaptive_shell.dart';
import 'core/state/locale_controller.dart';
import 'core/state/theme_controller.dart';
import 'core/storage/prefs_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/views/auth_page.dart';
import 'features/customers/data/datasources/customers_remote_datasource.dart';
import 'features/customers/data/repositories/customers_repository_impl.dart';
import 'features/customers/domain/repositories/customers_repository.dart';
import 'features/customers/presentation/controllers/customer_details_controller.dart';
import 'features/customers/presentation/controllers/customers_controller.dart';
import 'features/customers/presentation/views/customer_details_page.dart';
import 'features/customers/presentation/views/customers_page.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'features/dashboard/presentation/views/dashboard_page.dart';
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
import 'features/products/data/datasources/products_remote_datasource.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/repositories/products_repository.dart';
import 'features/products/presentation/controllers/products_controller.dart';
import 'features/products/presentation/views/products_page.dart';
import 'features/reports/data/datasources/reports_remote_datasource.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/repositories/reports_repository.dart';
import 'features/reports/presentation/controllers/reports_controller.dart';
import 'features/reports/presentation/views/reports_page.dart';
import 'features/sales/data/datasources/sales_remote_datasource.dart';
import 'features/sales/data/repositories/sales_repository_impl.dart';
import 'features/sales/domain/repositories/sales_repository.dart';
import 'features/sales/presentation/views/new_sale_page.dart';
import 'features/settings/data/datasources/settings_remote_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/settings/presentation/views/settings_page.dart';

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

    final authRepository = AuthRepositoryImpl(
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
    final inventoryDataSource = InventoryRemoteDataSource(apiClient);
    final inventoryRepository = InventoryRepositoryImpl(
      inventoryDataSource,
    );
    final reportsRepository = ReportsRepositoryImpl(
      ReportsRemoteDataSource(apiClient),
    );
    final settingsRepository = SettingsRepositoryImpl(
      SettingsRemoteDataSource(apiClient),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider(create: (_) => LocaleController(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeController(prefs)),
        Provider<ApiClient>.value(value: apiClient),
        Provider<DashboardRepository>.value(value: dashboardRepository),
        Provider<ProductsRepository>.value(value: productsRepository),
        Provider<CustomersRepository>.value(value: customersRepository),
        Provider<InstallmentsRepository>.value(value: installmentsRepository),
        Provider<SalesRepository>.value(value: salesRepository),
        Provider<InventoryRemoteDataSource>.value(value: inventoryDataSource),
        Provider<InventoryRepository>.value(value: inventoryRepository),
        Provider<ReportsRepository>.value(value: reportsRepository),
        Provider<SettingsRepository>.value(value: settingsRepository),
      ],
      child: Consumer2<LocaleController, ThemeController>(
        builder: (context, locale, theme, _) => MaterialApp(
          title: 'نظام إدارة الأقساط',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.mode,
          locale: locale.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return switch (auth.status) {
      AuthStatus.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) =>
                DashboardController(
                  context.read<DashboardRepository>(),
                  context.read<ReportsRepository>(),
                )..load(),
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
                CustomerDetailsController(
                  customersRepository: context.read<CustomersRepository>(),
                  installmentsRepository: context.read<InstallmentsRepository>(),
                ),
          ),
          ChangeNotifierProvider(
            create: (context) =>
                InstallmentsController(context.read<InstallmentsRepository>()),
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
                SettingsController(context.read<SettingsRepository>())..load(),
          ),
        ],
        child: const AppShell(),
      ),
      AuthStatus.submitting ||
      AuthStatus.error ||
      AuthStatus.unauthenticated => const AuthPage(),
    };
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentRoute = '/';
  String? _selectedCustomerId;

  void _navigateTo(String route) {
    setState(() {
      _currentRoute = route;
      if (!route.startsWith('/customers/')) {
        _selectedCustomerId = null;
      }
    });
  }

  void _navigateToCustomer(String id) {
    setState(() {
      _selectedCustomerId = id;
      _currentRoute = '/customers/$id';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (_currentRoute == '/') {
      page = DashboardPage(
        onNavigate: _navigateTo,
        onLogout: () => context.read<AuthController>().logout(),
      );
    } else if (_currentRoute == '/products') {
      page = ProductsPage(
        onNavigateToInventory: () => _navigateTo('/inventory'),
      );
    } else if (_currentRoute == '/inventory') {
      page = const InventoryPage();
    } else if (_currentRoute == '/new-sale') {
      page = NewSalePage(
        onNavigateToCustomer: _navigateToCustomer,
        onNavigateToProducts: () => _navigateTo('/products'),
      );
    } else if (_currentRoute == '/customers') {
      page = CustomersPage(
        onSelectCustomer: _navigateToCustomer,
      );
    } else if (_currentRoute.startsWith('/customers/') && _selectedCustomerId != null) {
      page = CustomerDetailsPage(
        customerId: _selectedCustomerId!,
        onBack: () => _navigateTo('/customers'),
      );
    } else if (_currentRoute == '/upcoming') {
      page = InstallmentsPage(
        onNavigateToCustomer: _navigateToCustomer,
      );
    } else if (_currentRoute == '/reports') {
      page = const ReportsPage();
    } else if (_currentRoute == '/settings') {
      page = const SettingsPage();
    } else {
      page = DashboardPage(
        onNavigate: _navigateTo,
        onLogout: () => context.read<AuthController>().logout(),
      );
    }

    final sidebarRoute = _currentRoute.startsWith('/customers/') ? '/customers' : _currentRoute;

    return AdaptiveShell(
      currentRoute: sidebarRoute,
      onNavigate: _navigateTo,
      child: page,
    );
  }
}
