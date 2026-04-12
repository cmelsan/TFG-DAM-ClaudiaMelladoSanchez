import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';

part 'app_router.g.dart';

/// Pantalla temporal mientras se implementan las features.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Pantalla: $name')),
    );
  }
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      // Redirect con auth state: se implementará con auth feature
      return null;
    },
    routes: [
      // --- Rutas públicas ---
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, __) => const _PlaceholderScreen(name: 'Home'),
      ),
      GoRoute(
        path: '/menu',
        name: RouteNames.menu,
        builder: (_, __) => const _PlaceholderScreen(name: 'Menú'),
        routes: [
          GoRoute(
            path: ':dishId',
            name: RouteNames.dishDetail,
            builder: (_, state) =>
                const _PlaceholderScreen(name: 'Detalle plato'),
          ),
        ],
      ),
      GoRoute(
        path: '/cart',
        name: RouteNames.cart,
        builder: (_, __) => const _PlaceholderScreen(name: 'Carrito'),
      ),
      GoRoute(
        path: '/contact',
        name: RouteNames.contact,
        builder: (_, __) => const _PlaceholderScreen(name: 'Contacto'),
      ),
      GoRoute(
        path: '/chat',
        name: RouteNames.chat,
        builder: (_, __) => const _PlaceholderScreen(name: 'Chat IA'),
      ),
      GoRoute(
        path: '/catering',
        name: RouteNames.catering,
        builder: (_, __) => const _PlaceholderScreen(name: 'Catering'),
      ),

      // --- Auth ---
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (_, __) => const _PlaceholderScreen(name: 'Login'),
      ),
      GoRoute(
        path: '/auth/register',
        name: RouteNames.register,
        builder: (_, __) => const _PlaceholderScreen(name: 'Registro'),
      ),

      // --- Protegidas ---
      GoRoute(
        path: '/checkout',
        name: RouteNames.checkout,
        builder: (_, __) => const _PlaceholderScreen(name: 'Checkout'),
      ),
      GoRoute(
        path: '/orders',
        name: RouteNames.orders,
        builder: (_, __) => const _PlaceholderScreen(name: 'Mis pedidos'),
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (_, __) => const _PlaceholderScreen(name: 'Perfil'),
      ),
      GoRoute(
        path: '/favorites',
        name: RouteNames.favorites,
        builder: (_, __) =>
            const _PlaceholderScreen(name: 'Favoritos'),
      ),
    ],
  );
}
