import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_catering_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_config_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_dishes_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_schedule_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_stats_screen.dart';
import 'package:sabor_de_casa/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/auth/presentation/screens/login_screen.dart';
import 'package:sabor_de_casa/features/auth/presentation/screens/register_screen.dart';
import 'package:sabor_de_casa/features/cart/presentation/screens/cart_screen.dart';
import 'package:sabor_de_casa/features/cart/presentation/screens/checkout_screen.dart';
import 'package:sabor_de_casa/features/catering/presentation/screens/catering_request_screen.dart';
import 'package:sabor_de_casa/features/catering/presentation/screens/catering_screen.dart';
import 'package:sabor_de_casa/features/chat/presentation/screens/chat_screen.dart';
import 'package:sabor_de_casa/features/contact/presentation/screens/contact_screen.dart';
import 'package:sabor_de_casa/features/delivery/presentation/screens/delivery_screen.dart';
import 'package:sabor_de_casa/features/delivery/presentation/screens/scanner_screen.dart';
import 'package:sabor_de_casa/features/home/presentation/screens/home_screen.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/screens/kitchen_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/dish_detail_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/favorites_screen.dart';
import 'package:sabor_de_casa/features/menu/presentation/screens/menu_screen.dart';
import 'package:sabor_de_casa/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:sabor_de_casa/features/orders/presentation/screens/orders_screen.dart';
import 'package:sabor_de_casa/features/pos/presentation/screens/pos_screen.dart';
import 'package:sabor_de_casa/features/profile/presentation/screens/profile_screen.dart';

part 'app_router.g.dart';

/// Rutas que requieren autenticación.
const _protectedPaths = [
  '/checkout',
  '/orders',
  '/profile',
  '/favorites',
  '/employee',
  '/admin',
];

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);
  final profile = authState.valueOrNull;
  final isLoggedIn = profile != null;

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isEmployeeRoute = state.matchedLocation.startsWith('/employee');
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      // Si intenta acceder a ruta protegida sin autenticar → login
      if (!isLoggedIn &&
          _protectedPaths.any(state.matchedLocation.startsWith)) {
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
        final role = profile.role.name;
        if (role != 'admin') {
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
      // --- Rutas públicas ---
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, __) => const HomeScreen(),
      ),
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
      GoRoute(
        path: '/cart',
        name: RouteNames.cart,
        builder: (_, __) => const CartScreen(),
      ),
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

      // --- Protegidas ---
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
            builder: (_, state) => OrderDetailScreen(
              orderId: state.pathParameters['orderId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (_, __) => const ProfileScreen(),
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
    ],
  );
}
