import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/storage/app_preferences.dart';
import '../features/auth/presentation/pages/forgot_password_otp_page.dart';
import '../features/auth/presentation/pages/forgot_password_start_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/menu/presentation/pages/bottle_balance_page.dart';
import '../features/menu/presentation/pages/bottle_balance_models.dart';
import '../features/menu/presentation/pages/bottle_balance_result_page.dart';
import '../features/menu/presentation/pages/cash_report_page.dart';
import '../features/menu/presentation/pages/cash_report_models.dart';
import '../features/menu/presentation/pages/cash_report_result_page.dart';
import '../features/menu/presentation/pages/courier_service_page.dart';
import '../features/menu/presentation/pages/delivered_orders_models.dart';
import '../features/menu/presentation/pages/delivered_orders_report_page.dart';
import '../features/menu/presentation/pages/delivered_today_page.dart';
import '../features/menu/presentation/pages/orders_map_page.dart';
import '../features/menu/presentation/pages/orders_page.dart';
import '../features/menu/presentation/pages/pending_orders_page.dart';
import '../features/menu/presentation/pages/security_page.dart';
import '../features/onboarding/presentation/pages/language_selection_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create({required AppPreferences preferences}) {
    final hasSession = preferences.hasSession;
    final initialLocation = preferences.hasLocale
        ? (hasSession ? '/home' : '/login')
        : '/language';

    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) {
        final hasLocale = preferences.hasLocale;
        final hasSessionNow = preferences.hasSession;
        final location = state.matchedLocation;
        final isLanguageRoute = location == '/language';
        if (!hasLocale && !isLanguageRoute) {
          return '/language';
        }
        if (hasLocale && hasSessionNow && location == '/login') {
          return '/home';
        }
        if (hasLocale && !hasSessionNow && location == '/home') {
          return '/login';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/language',
          name: 'language',
          builder: (context, state) => const LanguageSelectionPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordStartPage(),
        ),
        GoRoute(
          path: '/forgot-password/otp/:courierId',
          name: 'forgot-password-otp',
          builder: (context, state) {
            final courierId =
                int.tryParse(state.pathParameters['courierId'] ?? '');
            if (courierId == null) {
              return const ForgotPasswordStartPage();
            }
            return ForgotPasswordOtpPage(courierId: courierId);
          },
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: '/orders/pending',
          name: 'orders-pending',
          builder: (context, state) => const PendingOrdersPage(),
        ),
        GoRoute(
          path: '/orders/delivered-today',
          name: 'orders-delivered-today',
          builder: (context, state) => const DeliveredTodayPage(),
        ),
        GoRoute(
          path: '/orders/delivered-range',
          name: 'orders-delivered-range',
          builder: (context, state) => DeliveredOrdersReportPage(
            request: state.extra as DeliveredOrdersRequest?,
          ),
        ),
        GoRoute(
          path: '/orders/map',
          name: 'orders-map',
          builder: (context, state) => const OrdersMapPage(),
        ),
        GoRoute(
          path: '/cash-report',
          name: 'cash-report',
          builder: (context, state) => const CashReportPage(),
        ),
        GoRoute(
          path: '/cash-report/periodic',
          name: 'cash-report-periodic',
          builder: (context, state) => CashReportResultPage(
            request: state.extra as CashReportRequest?,
          ),
        ),
        GoRoute(
          path: '/cash-report/online',
          name: 'cash-report-online',
          builder: (context, state) => CashReportResultPage(
            request: state.extra as CashReportRequest?,
          ),
        ),
        GoRoute(
          path: '/bottle-balance',
          name: 'bottle-balance',
          builder: (context, state) => const BottleBalancePage(),
        ),
        GoRoute(
          path: '/bottle-balance/empty',
          name: 'bottle-balance-empty',
          builder: (context, state) => BottleBalanceResultPage(
            request: state.extra as BottleBalanceRequest?,
          ),
        ),
        GoRoute(
          path: '/bottle-balance/full-water',
          name: 'bottle-balance-full-water',
          builder: (context, state) => BottleBalanceResultPage(
            request: state.extra as BottleBalanceRequest?,
          ),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/security',
          name: 'security',
          builder: (context, state) => const SecurityPage(),
        ),
        GoRoute(
          path: '/courier-service',
          name: 'courier-service',
          builder: (context, state) => const CourierServicePage(),
        ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          body: Center(
            child: Text(state.error?.toString() ?? 'Unknown routing error'),
          ),
        );
      },
    );
  }
}
