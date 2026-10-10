import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/api_client.dart';
import 'core/database.dart';
import 'core/l10n.dart';
import 'data/pos_store.dart';
import 'ui/login_page.dart';
import 'ui/pages.dart';
import 'ui/product_intro_page.dart';
import 'ui/shell.dart';
import 'ui/sign_up_page.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final apiProvider = Provider<ApiClient>((ref) => ApiClient());

final storeProvider = Provider<PosStore>((ref) {
  return PosStore(ref.watch(dbProvider), ref.watch(apiProvider));
});

final sessionProvider = AsyncNotifierProvider<SessionController, Session?>(SessionController.new);

class SessionController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.read(storeProvider).restore();

  Future<String?> register(Map<String, dynamic> body) async {
    state = const AsyncLoading();
    try {
      final session = await ref.read(storeProvider).register(body);
      state = AsyncData(session);
      return null;
    } catch (error) {
      state = const AsyncData(null);
      return apiError(error);
    }
  }

  Future<String?> login({
    required String companyCode,
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final session = await ref.read(storeProvider).login(
            companyCode: companyCode,
            username: username,
            password: password,
          );
      state = AsyncData(session);
      return null;
    } catch (error) {
      state = const AsyncData(null);
      return apiError(error);
    }
  }

  Future<void> logout() async {
    await ref.read(storeProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> setCurrency(String code, String symbol) async {
    final current = state.value;
    if (current == null) return;
    final company = Map<String, dynamic>.from(current.company)
      ..['currency_code'] = code
      ..['currency_symbol'] = symbol;
    final next = Session(token: current.token, user: current.user, company: company);
    await ref.read(storeProvider).replaceSession(next);
    state = AsyncData(next);
  }
}

final localeProvider = NotifierProvider<LocaleController, String>(LocaleController.new);

class LocaleController extends Notifier<String> {
  @override
  String build() {
    Future.microtask(() async {
      final saved = await ref.read(storeProvider).meta('locale');
      if (saved != null && languageByCode(saved) != null) state = saved;
    });
    return 'en';
  }

  Future<void> set(String code) async {
    state = code;
    await ref.read(storeProvider).setMeta('locale', code);
  }
}

final dashboardStyleProvider = NotifierProvider<DashboardStyleController, String>(DashboardStyleController.new);

class DashboardStyleController extends Notifier<String> {
  @override
  String build() {
    Future.microtask(() async {
      final saved = await ref.read(storeProvider).meta('dashboard_style');
      if (saved == 'modules' || saved == 'overview') state = saved!;
    });
    return 'overview';
  }

  Future<void> set(String style) async {
    state = style;
    await ref.read(storeProvider).setMeta('dashboard_style', style);
  }
}

final branchProvider = NotifierProvider<BranchController, String?>(BranchController.new);

class BranchController extends Notifier<String?> {
  @override
  String? build() {
    Future.microtask(() async {
      final saved = await ref.read(storeProvider).meta('branch');
      state = (saved == null || saved.isEmpty) ? null : saved;
    });
    return null;
  }

  Future<void> select(String? uuid) async {
    state = uuid;
    await ref.read(storeProvider).setMeta('branch', uuid ?? '');
  }
}

final onlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _online(await connectivity.checkConnectivity());
  await for (final results in connectivity.onConnectivityChanged) {
    yield _online(results);
  }
});

bool _online(List<ConnectivityResult> results) {
  return results.any((result) => result != ConnectivityResult.none);
}

final l10nProvider = Provider<L10n>((ref) => L10n(ref.watch(localeProvider)));

/// Company sites open on login. The public marketing page stays on the apex.
bool _companySite(String base) {
  if (!kIsWeb) return false;
  final host = Uri.base.host.toLowerCase().split(':').first;
  if (!host.endsWith('.$base')) return false;
  final label = host.substring(0, host.length - base.length - 1);
  if (label.isEmpty || label.contains('.') || label == 'www' || label == 'api') return false;
  return RegExp(r'^[a-z0-9]{1,40}$').hasMatch(label);
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.onDispose(refresh.dispose);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);
  const publicPaths = {'/', '/login', '/sign-up', '/register'};
  final companySite = _companySite('pos360techx.com');
  final home = (!kIsWeb || companySite) ? '/login' : '/';
  return GoRouter(
    initialLocation: home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final loggedIn = session.value != null;
      final location = state.matchedLocation;
      final atPublic = publicPaths.contains(location);
      if (session.isLoading) return null;
      if ((!kIsWeb || companySite) && !loggedIn && location == '/') return '/login';
      if (!loggedIn && !atPublic) return home;
      if (loggedIn && atPublic) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ProductIntroPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/sign-up', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/register', redirect: (context, state) => '/sign-up'),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
          GoRoute(path: '/products', builder: (context, state) => const ProductsPage()),
          GoRoute(path: '/categories', builder: (context, state) => const CategoriesPage()),
          GoRoute(path: '/brands', builder: (context, state) => const BrandsPage()),
          GoRoute(path: '/units', builder: (context, state) => const UnitsPage()),
          GoRoute(path: '/stock', builder: (context, state) => const StockPage()),
          GoRoute(path: '/stock/ledger', builder: (context, state) => const LedgerPage()),
          GoRoute(path: '/stock/adjustment', builder: (context, state) => const StockDocPage(mode: 'adjustment')),
          GoRoute(path: '/stock/transfer', builder: (context, state) => const StockDocPage(mode: 'transfer')),
          GoRoute(path: '/stock/write-off', builder: (context, state) => const StockDocPage(mode: 'writeoff')),
          GoRoute(path: '/stock/move', builder: (context, state) => const StockDocPage(mode: 'move')),
          GoRoute(path: '/branches', builder: (context, state) => const BranchesPage()),
          GoRoute(path: '/users', builder: (context, state) => const UsersPage()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsPage()),
          GoRoute(path: '/reports/party', builder: (context, state) => const PartyReportPage()),
          GoRoute(path: '/reports/:key', builder: (context, state) => ReportDetailPage(reportKey: state.pathParameters['key']!)),
          GoRoute(path: '/cheques', builder: (context, state) => const ChequesPage()),
          GoRoute(path: '/cheques/new', builder: (context, state) => const ChequeFormPage()),
          GoRoute(path: '/investment', builder: (context, state) => const InvestmentPage()),
          GoRoute(path: '/roznamcha', builder: (context, state) => const RoznamchaPage()),
          GoRoute(path: '/roznamcha/new', builder: (context, state) => const JournalFormPage()),
          GoRoute(path: '/roznamcha/daily-book', builder: (context, state) => const DailyBookPage()),
          GoRoute(path: '/roznamcha/day-close', builder: (context, state) => const DayClosePage()),
          GoRoute(path: '/accounts', builder: (context, state) => const AccountsPage()),
          GoRoute(path: '/accounts/new', builder: (context, state) => const AccountFormPage()),
          GoRoute(path: '/accounts/edit/:uuid', builder: (context, state) => AccountFormPage(clientUuid: state.pathParameters['uuid'])),
          GoRoute(path: '/bank-accounts', builder: (context, state) => const BankAccountsPage()),
          GoRoute(path: '/bank-accounts/new', builder: (context, state) => const BankAccountFormPage()),
          GoRoute(path: '/bank-accounts/edit/:uuid', builder: (context, state) => BankAccountFormPage(clientUuid: state.pathParameters['uuid'])),
          GoRoute(path: '/purchases', builder: (context, state) => const PurchasesPage()),
          GoRoute(path: '/purchases/receive', builder: (context, state) => const ReceivePurchasePage()),
          GoRoute(path: '/purchases/orders', builder: (context, state) => const PurchaseOrdersPage()),
          GoRoute(path: '/purchases/orders/new', builder: (context, state) => const PurchaseOrderFormPage()),
          GoRoute(path: '/purchases/returns', builder: (context, state) => const PurchaseReturnsPage()),
          GoRoute(path: '/purchases/returns/new', builder: (context, state) => const PurchaseReturnFormPage()),
          GoRoute(path: '/purchases/quick-pay', builder: (context, state) => const QuickPayPage()),
          GoRoute(path: '/stock/returns', builder: (context, state) => const PurchaseReturnsPage(back: '/stock')),
          GoRoute(path: '/manufacturing', builder: (context, state) => const ManufacturingPage()),
          GoRoute(path: '/manufacturing/new', builder: (context, state) => const ManufacturingFormPage()),
          GoRoute(path: '/parties', builder: (context, state) => const PartiesPage()),
          GoRoute(path: '/parties/new', builder: (context, state) => const PartyFormPage()),
          GoRoute(path: '/parties/edit/:uuid', builder: (context, state) => PartyFormPage(clientUuid: state.pathParameters['uuid'])),
          GoRoute(path: '/parties/recovery', builder: (context, state) => const CreditRecoveryPage()),
          GoRoute(path: '/parties/areas', builder: (context, state) => const AreasPage()),
          GoRoute(path: '/pos', builder: (context, state) => const CheckoutPage()),
          GoRoute(path: '/sales', builder: (context, state) => const SalesPage()),
          GoRoute(path: '/sales/new', builder: (context, state) => const CheckoutPage(back: '/sales')),
          GoRoute(path: '/expenses', builder: (context, state) => const ExpensesPage()),
          GoRoute(path: '/expenses/new', builder: (context, state) => const ExpenseFormPage()),
          GoRoute(path: '/hr/employees', builder: (context, state) => const EmployeesPage()),
          GoRoute(path: '/hr/employees/new', builder: (context, state) => const EmployeeFormPage()),
          GoRoute(path: '/hr/employees/edit/:uuid', builder: (context, state) => EmployeeFormPage(clientUuid: state.pathParameters['uuid'])),
          GoRoute(path: '/hr/attendance', builder: (context, state) => const AttendancePage()),
          GoRoute(path: '/hr/salaries', builder: (context, state) => const SalariesPage()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          GoRoute(path: '/settings/payments', builder: (context, state) => const PaymentMethodsPage()),
          GoRoute(path: '/sales/estimates', builder: (context, state) => const PaperDocsPage(entity: 'estimate', titleKey: 'estimates')),
          GoRoute(path: '/sales/orders', builder: (context, state) => const PaperDocsPage(entity: 'sale_order', titleKey: 'saleOrders')),
          GoRoute(path: '/sales/deliveries', builder: (context, state) => const PaperDocsPage(entity: 'delivery_note', titleKey: 'deliveryNotes')),
          GoRoute(
            path: '/soon/:key',
            builder: (context, state) => PlaceholderPage(moduleKey: state.pathParameters['key']!),
          ),
        ],
      ),
    ],
  );
});

Locale _materialLocale(String code) {
  return switch (code) {
    'ur_latn' => const Locale('en'),
    'bal' => const Locale('ur'),
    _ => Locale(code),
  };
}

class PosApp extends ConsumerWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final rtl = ref.watch(l10nProvider).isRtl;
    final router = ref.watch(routerProvider);
    ref.listen(onlineProvider, (previous, next) {
      if (next.value == true && ref.read(sessionProvider).value != null) {
        unawaited(ref.read(storeProvider).flush());
      }
    });
    return MaterialApp.router(
      title: 'POS360tech',
      debugShowCheckedModeBanner: false,
      locale: _materialLocale(locale),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F5F8),
        useMaterial3: true,
        splashFactory: InkSparkle.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1A1D26)),
          titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D26)),
          bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF1A1D26)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF9FAFB),
          isDense: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFE6E8EE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFE6E8EE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFF0F766E), width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F766E),
            side: const BorderSide(color: Color(0xFFD7DEE3)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            side: BorderSide(color: Color(0xFFE6E8EE)),
          ),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFFE6E8EE)),
      ),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
