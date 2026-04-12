/// Nombres de tablas y buckets de Supabase.
class SupabaseConstants {
  const SupabaseConstants._();

  // Tablas
  static const profiles = 'profiles';
  static const addresses = 'addresses';
  static const categories = 'categories';
  static const dishes = 'dishes';
  static const dailySpecial = 'daily_special';
  static const schedule = 'schedule';
  static const orders = 'orders';
  static const orderItems = 'order_items';
  static const orderRatings = 'order_ratings';
  static const favorites = 'favorites';
  static const eventMenus = 'event_menus';
  static const eventMenuCourses = 'event_menu_courses';
  static const eventExtras = 'event_extras';
  static const eventRequests = 'event_requests';
  static const eventRequestSelections = 'event_request_selections';
  static const eventRequestExtras = 'event_request_extras';
  static const eventCalendar = 'event_calendar';
  static const contactMessages = 'contact_messages';
  static const pushTokens = 'push_tokens';
  static const businessConfig = 'business_config';

  // Buckets de Storage
  static const dishImagesBucket = 'dish-images';
  static const categoryImagesBucket = 'category-images';
  static const profileAvatarsBucket = 'profile-avatars';
  static const eventImagesBucket = 'event-images';
}
