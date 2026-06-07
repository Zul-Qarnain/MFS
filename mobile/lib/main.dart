import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MfsUnifiedApp(),
    ),
  );
}

class MfsUnifiedApp extends ConsumerWidget {
  const MfsUnifiedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'MFS Unified',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
