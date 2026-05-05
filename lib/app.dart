import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sabor_de_casa/core/router/app_router.dart';
import 'package:sabor_de_casa/core/theme/app_theme.dart';
import 'package:sabor_de_casa/core/theme/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'Sabor de Casa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
