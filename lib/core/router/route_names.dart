/// Constantes de nombres de rutas.
class RouteNames {
  const RouteNames._();

  // Públicas
  static const home = 'home';
  static const menu = 'menu';
  static const dishDetail = 'dish-detail';
  static const cart = 'cart';
  static const contact = 'contact';
  static const chat = 'chat';
  static const catering = 'catering';

  // Auth
  static const login = 'login';
  static const register = 'register';

  // Protegidas (requieren auth)
  static const checkout = 'checkout';
  static const orders = 'orders';
  static const orderDetail = 'order-detail';
  static const profile = 'profile';
  static const favorites = 'favorites';
  static const cateringRequest = 'catering-request';

  // Empleado
  static const kitchen = 'kitchen';
  static const delivery = 'delivery';
  static const pos = 'pos';
  static const scanner = 'scanner';

  // Admin
  static const adminDashboard = 'admin-dashboard';
  static const adminDishes = 'admin-dishes';
  static const adminOrders = 'admin-orders';
  static const adminCatering = 'admin-catering';
  static const adminUsers = 'admin-users';
  static const adminConfig = 'admin-config';
  static const adminSchedule = 'admin-schedule';
  static const adminStats = 'admin-stats';
}
