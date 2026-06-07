import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/authentication_screen.dart';
import '../screens/home_screen.dart';
import '../screens/payment_details_screen.dart';
import '../screens/processing_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/success_screen.dart';

/// Canonical route paths.
class Routes {
  static const String root = '/';
  static const String scan = '/scan';
  static const String pay = '/pay';
  static const String processing = '/processing';
  static const String success = '/success';
  static const String auth = '/auth';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.root,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.root,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.scan,
        builder: (_, __) => const QrScannerScreen(),
      ),
      GoRoute(
        path: Routes.pay,
        builder: (_, state) => PaymentDetailsScreen(
          qrPayload: state.extra as String?,
        ),
      ),
      GoRoute(
        path: Routes.processing,
        builder: (_, __) => const ProcessingScreen(),
      ),
      GoRoute(
        path: Routes.success,
        builder: (_, state) => SuccessScreen(
          providerTxnId: state.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.auth,
        builder: (_, __) => const AuthenticationScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
});
