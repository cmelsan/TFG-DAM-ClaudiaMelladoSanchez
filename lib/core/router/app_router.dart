import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/widgets/scaffold_with_nav_bar.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_categories_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_catering_screen.dart';

import 'package:sabor_de_casa/features/admin/presentation/screens/admin_config_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_dishes_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_encargos_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_schedule_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_stats_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/auth/presentation/screens/login_screen.dart';
import 'package:sabor_de_casa/features/auth/presentation/screens/register_screen.dart';
import 'package:sabor_de_casa/features/cart/presentation/screens/cart_screen.dart';
import 'package:sabor_de_casa/features/cart/presentation/screens/checkout_screen.dart';
import 'package:sabor_de_casa/features/cart/presentation/screens/payment_success_screen.dart';
import 'package:sabor_de_casa/features/catering/presentation/screens/catering_request_screen.dart';
import 'package:sabor_de_casa/features/catering/presentation/screens/catering_screen.dart';
import 'package:sabor_de_casa/features/catering/presentation/screens/my_catering_requests_screen.dart';
import 'package:sabor_de_casa/features/chat/presentation/screens/chat_screen.dart';
import 'package:sabor_de_casa/features/contact/presentation/screens/contact_screen.dart';
import 'package:sabor_de_casa/features/delivery/presentation/screens/delivery_screen.dart';
import 'package:sabor_de_casa/features/delivery/presentation/screens/scanner_screen.dart';
import 'package:sabor_de_casa/features/group_order/presentation/screens/group_order_screen.dart';
import 'package:sabor_de_casa/features/home/presentation/screens/home_screen.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/screens/kitchen_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/dish_detail_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/favorites_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/menu_screen.dart';
import 'package:sabor_de_casa/features/orders/presentation/screens/order_confirmation_screen.dart';
import 'package:sabor_de_casa/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:sabor_de_casa/features/orders/presentation/screens/orders_screen.dart';
import 'package:sabor_de_casa/features/pos/presentation/screens/pos_screen.dart';
import 'package:sabor_de_casa/features/profile/presentation/screens/profile_screen.dart';
import 'package:sabor_de_casa/features/splash/presentation/screens/onboarding_screen.dart';
import 'package:sabor_de_casa/features/splash/presentation/screens/splash_screen.dart';

part 'app_router.g.dart';

/// Rutas que requieren autenticación.
const _protectedPaths = [
  '/checkout',
  '/orders',
  '/order-confirmation',
  '/profile',
  '/favorites',
  '/employee',
  '/admin',
];

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
GoRouter appRouter(AppRouterRef ref) {
  // Notifier que avisa a GoRouter de re-evaluar redirects sin recrear el router.
  // IMPORTANTE: ref.listen (no ref.watch) para que el provider no se destruya
  // al cambiar el estado de auth.
  final authNotifier = ValueNotifier<int>(0);
  ref
    ..listen(authNotifierProvider, (_, __) => authNotifier.value++)
    ..onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Mientras carga el estado de auth no redirigir (evita parpadeo).
      if (authState.isLoading) return null;

      final profile = authState.valueOrNull;
      final isLoggedIn = profile != null;
      final path = state.matchedLocation;

      final isAuthRoute = path.startsWith('/auth');
      final isEmployeeRoute = path.startsWith('/employee');
      final isAdminRoute = path.startsWith('/admin');

      // Si intenta acceder a ruta protegida sin autenticar → login
      if (!isLoggedIn && _protectedPaths.any(path.startsWith)) {
        return '/auth/login';
      }

      // Rutas empleado: employee o admin
      if (isEmployeeRoute && isLoggedIn) {
        final role = profile.role.name;
        if (role != 'employee' && role != 'admin') {
          return '/';
        }
      }

      // Rutas admin: solo admin
      if (isAdminRoute && isLoggedIn) {
        if (profile.role.name != 'admin') {
          return '/';
        }
      }

      // Si ya está autenticado y va a auth → home
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // ─────────────────────────────────────────────────────────────
      // Shell principal: Inicio / Menú / Carrito / Perfil
      // Muestra el BottomNavigationBar persistente en estas 4 tabs.
      // ─────────────────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          // Tab 0 — Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: RouteNames.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1 — Menú (incluye detalle de plato)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/menu',
                name: RouteNames.menu,
                builder: (_, __) => const MenuScreen(),
                routes: [
                  GoRoute(
                    path: ':dishId',
                    name: RouteNames.dishDetail,
                    builder: (_, state) => DishDetailScreen(
                      dishId: state.pathParameters['dishId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2 — Carrito
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: RouteNames.cart,
                builder: (_, __) => const CartScreen(),
              ),
            ],
          ),
          // Tab 3 — Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────
      // Rutas fuera del shell (sin BottomNavBar)
      // ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/contact',
        name: RouteNames.contact,
        builder: (_, __) => const ContactScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: RouteNames.chat,
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/catering',
        name: RouteNames.catering,
        builder: (_, __) => const CateringScreen(),
      ),
      GoRoute(
        path: '/favorites',
        name: RouteNames.favorites,
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/catering/request',
        name: RouteNames.cateringRequest,
        builder: (_, __) => const CateringRequestScreen(),
      ),

      // --- Auth ---
      GoRoute(
        path: '/auth/login',
        name: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        name: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // --- Protegidas (fuera del shell) ---
      GoRoute(
        path: '/checkout',
        name: RouteNames.checkout,
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: RouteNames.orders,
        builder: (_, __) => const OrdersScreen(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: RouteNames.orderDetail,
            builder: (_, state) =>
                OrderDetailScreen(orderId: state.pathParameters['orderId']!),
          ),
        ],
      ),

      // --- Empleado ---
      GoRoute(
        path: '/employee/kitchen',
        name: RouteNames.kitchen,
        builder: (_, __) => const KitchenScreen(),
      ),
      GoRoute(
        path: '/employee/delivery',
        name: RouteNames.delivery,
        builder: (_, __) => const DeliveryScreen(),
      ),
      GoRoute(
        path: '/employee/pos',
        name: RouteNames.pos,
        builder: (_, __) => const PosScreen(),
      ),
      GoRoute(
        path: '/employee/scanner',
        name: RouteNames.scanner,
        builder: (_, __) => const ScannerScreen(),
      ),

      // --- Admin ---
      GoRoute(
        path: '/admin/dashboard',
        name: RouteNames.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/dishes',
        name: RouteNames.adminDishes,
        builder: (_, __) => const AdminDishesScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        name: RouteNames.adminOrders,
        builder: (_, __) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/catering',
        name: RouteNames.adminCatering,
        builder: (_, __) => const AdminCateringScreen(),
      ),
      GoRoute(
        path: '/admin/encargos',
        name: RouteNames.adminEncargos,
        builder: (_, __) => const AdminEncargosScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: RouteNames.adminUsers,
        builder: (_, __) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/config',
        name: RouteNames.adminConfig,
        builder: (_, __) => const AdminConfigScreen(),
      ),
      GoRoute(
        path: '/admin/schedule',
        name: RouteNames.adminSchedule,
        builder: (_, __) => const AdminScheduleScreen(),
      ),
      GoRoute(
        path: '/admin/stats',
        name: RouteNames.adminStats,
        builder: (_, __) => const AdminStatsScreen(),
      ),
      GoRoute(
        path: '/admin/categories',
        name: RouteNames.adminCategories,
        builder: (_, __) => const AdminCategoriesScreen(),
      ),

      // --- Pago web (retorno desde Stripe Checkout) ---
      GoRoute(
        path: '/payment/success',
        name: RouteNames.paymentSuccess,
        builder: (_, state) => PaymentSuccessScreen(
          sessionId: state.uri.queryParameters['session_id'],
        ),
      ),

      // --- Confirmación de pedido ---
      GoRoute(
        path: '/order-confirmation/:orderId',
        name: RouteNames.orderConfirmation,
        builder: (_, state) =>
            OrderConfirmationScreen(orderId: state.pathParameters['orderId']!),
      ),

      // --- Splash & Onboarding ---
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // --- Group Order ---
      GoRoute(
        path: '/group-order',
        name: RouteNames.groupOrder,
        builder: (_, __) => const GroupOrderScreen(),
      ),

      // --- My Catering Requests ---
      GoRoute(
        path: '/catering/my-requests',
        name: RouteNames.myCateringRequests,
        builder: (_, __) => const MyCateringRequestsScreen(),
      ),
    ],
  );
}
