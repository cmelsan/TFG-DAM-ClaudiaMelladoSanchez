---
name: flutter-proyecto-final
description: >
  Skill maestro del proyecto final DAM. Define la arquitectura, stack tecnologico,
  patrones obligatorios (Riverpod, Freezed, GoRouter), reglas de seguridad,
  estructura de carpetas, naming conventions y directrices de calidad para una app
  Flutter multiplataforma (Android + Web) con backend Supabase.
  ESTA SKILL TIENE PRIORIDAD ABSOLUTA sobre cualquier otra skill de Flutter cuando
  exista conflicto en patrones, paquetes o arquitectura.
---

# Proyecto Final DAM -- Directrices de Desarrollo

## Indice

- [1. Contexto del proyecto](#1-contexto-del-proyecto)
- [2. Stack tecnologico](#2-stack-tecnologico)
- [3. Conflictos con otras skills](#3-conflictos-con-otras-skills)
- [4. Arquitectura](#4-arquitectura)
- [5. Estructura de carpetas](#5-estructura-de-carpetas)
- [6. Patrones obligatorios Riverpod](#6-patrones-obligatorios-riverpod)
- [7. Patrones obligatorios Freezed](#7-patrones-obligatorios-freezed)
- [8. Navegacion con GoRouter](#8-navegacion-con-gorouter)
- [9. Patron Repository con Supabase](#9-patron-repository-con-supabase)
- [10. Seguridad](#10-seguridad)
- [11. Gestion de entornos](#11-gestion-de-entornos)
- [12. Modelo de datos](#12-modelo-de-datos)
- [13. Edge Functions](#13-edge-functions)
- [14. Naming conventions](#14-naming-conventions)
- [15. Linting y formato](#15-linting-y-formato)
- [16. Testing](#16-testing)
- [17. Git workflow](#17-git-workflow)
- [18. Theming](#18-theming)
- [19. Formularios](#19-formularios)
- [20. Imagenes y Storage](#20-imagenes-y-storage)
- [21. Realtime](#21-realtime)
- [22. Notificaciones](#22-notificaciones)
- [23. Accesibilidad](#23-accesibilidad)
- [24. Rendimiento](#24-rendimiento)
- [25. Practicas prohibidas](#25-practicas-prohibidas)
- [26. Dependencias aprobadas](#26-dependencias-aprobadas)

---

## 1. Contexto del proyecto

- **Tipo**: Proyecto final de Grado Superior DAM (Desarrollo de Aplicaciones Multiplataforma).
- **Negocio**: Local de comida preparada para llevar con servicio de catering para eventos.
- **Plataformas**: Android (APK) + Web (Vercel). Sin iOS (no hay Mac).
- **Roles**: Client, Employee (cook/driver/both), Admin.
- **Tipos de pedido**: mostrador (anonimo), encargo (fecha futura), domicilio (hoy), recogida (hoy/futura).
- **Pantallas**: 36 totales (16 cliente, 6 empleado, 14 admin).
- **Features novedosas**: 13 (incluye chatbot IA con Gemini, recomendador personalizado, pedido grupal Realtime, pedido por voz, QR recogida, ticket PDF, animaciones Lottie, modo oscuro/claro, alertas alergenos, plato del dia con countdown).

### Rubrica academica

| Criterio | Peso | Implicacion tecnica |
|----------|------|---------------------|
| Analisis contexto y diseno | 20% | Documentacion ya entregada |
| Planificacion y documentacion tecnica | 20% | Gantt, memoria tecnica |
| Desarrollo tecnico | 30% (obligatorio aprobar) | Codigo limpio, patrones, arquitectura |
| Calidad y funcionalidad | 15% | Testing, UX, accesibilidad |
| Presentacion y defensa | 15% | Demo funcional |

---

## 2. Stack tecnologico

### Versiones del entorno

| Herramienta | Version |
|-------------|---------|
| Flutter | 3.38.6 (stable) |
| Dart | 3.10.7 |
| Android minSDK | 26 (Android 8.0) |
| Android targetSDK | 35 |
| Web target | Chromium, Firefox, Safari modernos |

### Stack principal

| Capa | Tecnologia | Uso |
|------|-----------|-----|
| Framework | Flutter 3.38.x | UI multiplataforma |
| Lenguaje | Dart 3.10.x | Records, patterns, sealed classes |
| State management | Riverpod + riverpod_generator | OBLIGATORIO por directriz del profesor |
| Modelos inmutables | Freezed + freezed_annotation | OBLIGATORIO por directriz del profesor |
| Navegacion | GoRouter | OBLIGATORIO, deep links, guards |
| Backend | Supabase | Auth, PostgreSQL, Realtime, Storage, Edge Functions |
| Pagos | Stripe | Payment Intents via Edge Function |
| Push notifications | Firebase Cloud Messaging (FCM) | Via Edge Function |
| Emails transaccionales | Brevo (ex-Sendinblue) | Via Edge Function |
| IA | Gemini API | Chatbot + recomendador via Edge Function |
| Hosting web | Vercel | Flutter web build |
| Control de versiones | Git + GitHub | Ramas, commits convencionales |

---

## 3. Conflictos con otras skills

Las skills de Flutter instaladas en el workspace contienen directrices genericas que **entran en conflicto** con los requisitos de este proyecto. Cuando haya conflicto, **esta skill tiene prioridad absoluta**.

### flutter-managing-state -- ANULADA PARCIALMENTE

Esa skill recomienda `Provider` + `ChangeNotifier` + `setState()`. **Ignorar** esas recomendaciones. En este proyecto:

- El state management es **Riverpod con code generation** (`@riverpod`), nunca `Provider` ni `ChangeNotifier`.
- `setState()` solo se permite para estado efimero de UI puro (animaciones, `GlobalKey<FormState>`). Nunca para logica de negocio.

### flutter-handling-http-and-json -- ANULADA PARCIALMENTE

Esa skill recomienda el paquete `http` y `json_serializable`. En este proyecto:

- Las queries a la BD se hacen con el **Supabase client** (`supabase.from('table').select()`), no con `http.get()`.
- La serializacion JSON la gestiona **Freezed** (`fromJson`/`toJson`), no `json_serializable`.
- Solo usar `http` o `dio` si se necesita una llamada a una API externa que no sea Supabase (improbable).

### flutter-working-with-databases -- ANULADA PARCIALMENTE

Esa skill recomienda `sqflite` como BD local. En este proyecto:

- La BD principal es **Supabase PostgreSQL remoto**.
- Para cache local ligero usar `shared_preferences` (tokens, preferencias) o `Hive CE` si se necesita cache estructurado del menu.
- No usar `sqflite` salvo necesidad justificada.

### flutter-building-forms -- COMPATIBLE CON MATIZ

Esa skill dice "Always host your Form inside a StatefulWidget". Esto es **aceptable** porque `GlobalKey<FormState>` es estado efimero de UI. Pero:

- La **logica de envio** del formulario (la accion de submit) se gestiona via un provider de Riverpod, no con setState.
- Los formularios complejos usan `reactive_forms` si es necesario.

### Skills compatibles sin conflicto

Las siguientes skills se pueden seguir tal cual: `flutter-architecting-apps`, `flutter-implementing-navigation-and-routing`, `flutter-theming-apps`, `flutter-testing-apps`, `flutter-building-layouts`, `flutter-animating-apps`, `flutter-caching-data`, `flutter-improving-accessibility`, `flutter-handling-concurrency`, `flutter-reducing-app-size`.

---

## 4. Arquitectura

### Capas (alineado con flutter-architecting-apps)

```
UI Layer (Views + Widgets)
    |
    v
Logic Layer (Riverpod Providers / AsyncNotifiers)
    |
    v
Data Layer (Repositories)
    |
    v
Services Layer (Supabase Client, Stripe, FCM, Brevo, Gemini)
```

### Principios

1. **Separation of Concerns**: UI no contiene logica de negocio ni acceso a datos.
2. **Single Source of Truth (SSOT)**: Cada dato tiene un unico repository como fuente de verdad.
3. **Unidirectional Data Flow (UDF)**: Estado fluye hacia abajo (provider -> widget). Eventos fluyen hacia arriba (widget -> provider -> repository).
4. **UI = f(state)**: Toda la UI se construye reactivamente a partir del estado del provider.
5. **Feature-first**: Cada modulo de negocio es autonomo con sus propias capas.

---

## 5. Estructura de carpetas

```
lib/
  app.dart                          # MaterialApp.router + ProviderScope
  main.dart                         # Bootstrap, inicializacion
  bootstrap.dart                    # Inicializacion de servicios (Supabase, FCM, etc.)
  
  core/
    constants/
      app_constants.dart            # Valores constantes de la app
      supabase_constants.dart       # Nombres de tablas, buckets
    extensions/                     # Extension methods (BuildContext, String, etc.)
    errors/
      failures.dart                 # Clases Failure tipadas
      exceptions.dart               # Excepciones custom
    utils/
      validators.dart               # Validadores de formularios reutilizables
      formatters.dart               # Formateadores (precio, fecha, etc.)
    router/
      app_router.dart               # GoRouter config
      route_names.dart              # Constantes de nombres de rutas
      guards/
        auth_guard.dart             # Redirect si no autenticado
        role_guard.dart             # Redirect segun rol
    theme/
      app_theme.dart                # ThemeData light + dark
      app_colors.dart               # Seed colors, paleta custom
      app_text_styles.dart          # Estilos de texto reutilizables
    widgets/                        # Widgets compartidos entre features
      app_scaffold.dart
      loading_indicator.dart
      error_view.dart
      cached_image.dart
  
  features/
    auth/
      data/
        repositories/
          auth_repository.dart
        datasources/
          auth_remote_datasource.dart
      domain/
        models/
          user_profile.dart         # @freezed
          user_profile.freezed.dart
          user_profile.g.dart
      presentation/
        providers/
          auth_provider.dart        # @riverpod
          auth_provider.g.dart
        screens/
          login_screen.dart
          register_screen.dart
        widgets/
          login_form.dart
    
    menu/
      data/
        repositories/
          menu_repository.dart
        datasources/
          menu_remote_datasource.dart
      domain/
        models/
          category.dart
          dish.dart
      presentation/
        providers/
          menu_provider.dart
          categories_provider.dart
        screens/
          menu_screen.dart
          dish_detail_screen.dart
        widgets/
          dish_card.dart
          category_chip.dart
          allergen_badge.dart
    
    cart/                           # Carrito local (no requiere auth)
    orders/                         # Pedidos online
    pos/                            # TPV mostrador (empleado)
    kitchen/                        # Panel cocina KDS (empleado)
    delivery/                       # Panel repartidor (empleado)
    catering/                       # Eventos y catering
    chat/                           # Chatbot IA
    contact/                        # Formulario consultas
    admin/                          # Pantallas de administracion
    notifications/                  # Push + in-app
    profile/                        # Perfil usuario

  services/
    supabase_service.dart           # Singleton del client Supabase
    stripe_service.dart             # Interaccion con Edge Function de pagos
    fcm_service.dart                # Firebase Cloud Messaging setup
    storage_service.dart            # Upload/download de Supabase Storage

supabase/
  functions/
    create-payment-intent/
      index.ts                      # Edge Function Stripe
    send-notification/
      index.ts                      # Edge Function FCM
    send-email/
      index.ts                      # Edge Function Brevo
    chatbot/
      index.ts                      # Edge Function Gemini chatbot
    recommender/
      index.ts                      # Edge Function Gemini recomendador
  migrations/                       # SQL migrations

test/
  features/
    auth/
      data/
        repositories/
          auth_repository_test.dart
      presentation/
        providers/
          auth_provider_test.dart
    menu/
      ...
  helpers/
    test_helpers.dart
    fakes/                          # Fake implementations de repositories

integration_test/
  app_test.dart
```

### Reglas de carpetas

- Cada feature sigue la estructura `data/` + `domain/` + `presentation/`.
- `data/` contiene `repositories/` y `datasources/`.
- `domain/` contiene `models/` (Freezed classes).
- `presentation/` contiene `providers/`, `screens/`, `widgets/`.
- Un feature NUNCA importa directamente el datasource de otro feature. Solo accede via el repository expuesto como provider.
- Los ficheros generados (`.freezed.dart`, `.g.dart`) van junto al archivo fuente.

---

## 6. Patrones obligatorios Riverpod

### Code generation obligatorio

Usar siempre `@riverpod` y `@Riverpod(keepAlive: true)` con code generation. Nunca declarar providers manualmente con `StateProvider`, `StateNotifierProvider`, etc.

```dart
// CORRECTO
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserProfile?> build() async {
    return await ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }
}
```

```dart
// INCORRECTO - NUNCA hacer esto
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
```

### Tipos de providers

| Necesidad | Patron |
|-----------|--------|
| Dato asincrono que depende de otros providers | `@riverpod` funcion (autoDispose por defecto) |
| Estado mutable con logica | `@riverpod class MiNotifier extends _$MiNotifier` |
| Servicio singleton (Supabase client, etc.) | `@Riverpod(keepAlive: true)` |
| Estado que debe sobrevivir a navegacion | `@Riverpod(keepAlive: true)` |
| Dato con parametros (familia) | `@riverpod` funcion con argumentos |

### Consumo en UI

```dart
// Dentro de un ConsumerWidget o ConsumerStatefulWidget (nunca StatelessWidget)
class MenuScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);
    
    return menuAsync.when(
      data: (dishes) => DishGrid(dishes: dishes),
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(menuProvider),
      ),
    );
  }
}
```

### Reglas Riverpod

1. Usar `ref.watch()` en `build()` para reactividad. Usar `ref.read()` en callbacks (onPressed, etc.).
2. Nunca usar `ref.watch()` dentro de un callback o funcion asincrona.
3. Para efectos secundarios (navegacion tras login, mostrar snackbar), usar `ref.listen()` en `build()`.
4. Los providers son la unica fuente de dependencias. No usar service locators (`GetIt`, `get_it`) ni singletons manuales.
5. Ejecutar `dart run build_runner build --delete-conflicting-outputs` tras cada cambio en archivos con `@riverpod` o `@freezed`.

---

## 7. Patrones obligatorios Freezed

### Modelos de dominio

Todos los modelos de datos son `@freezed` con serializacion JSON integrada.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dish.freezed.dart';
part 'dish.g.dart';

@freezed
class Dish with _$Dish {
  const factory Dish({
    required String id,
    required String categoryId,
    required String name,
    required String description,
    required double price,
    String? imageUrl,
    @Default([]) List<String> allergens,
    @Default(15) int prepTimeMin,
    @Default(true) bool isAvailable,
  }) = _Dish;

  factory Dish.fromJson(Map<String, dynamic> json) => _$DishFromJson(json);
}
```

### Estados de UI con union types

Usar union types de Freezed para estados complejos que no encajan en `AsyncValue`.

```dart
@freezed
class CartState with _$CartState {
  const factory CartState.empty() = CartEmpty;
  const factory CartState.active({
    required List<CartItem> items,
    required double total,
  }) = CartActive;
  const factory CartState.checkout({
    required List<CartItem> items,
    required double total,
    required String orderType,
  }) = CartCheckout;
}
```

### Reglas Freezed

1. Todos los modelos que vienen de Supabase son `@freezed` con `fromJson`/`toJson`.
2. Los nombres de campos en Dart son `camelCase`. Usar `@JsonKey(name: 'snake_case')` cuando el campo de Supabase difiera.
3. Preferencia: usar `@JsonSerializable(fieldRename: FieldRename.snake)` en el factory para conversion automatica snake_case <-> camelCase.
4. Nunca crear modelos mutables con campos no-final.
5. Para listas vacias por defecto usar `@Default([])`, no `List<String>?`.

---

## 8. Navegacion con GoRouter

### Configuracion base

```dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: /* listenable del auth state */,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final requiresAuth = _requiresAuth(state.matchedLocation);
      
      if (requiresAuth && !isLoggedIn) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      // Rutas publicas (no requieren auth)
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/menu', builder: (_, __) => const MenuScreen()),
      GoRoute(path: '/menu/:dishId', builder: (_, state) => DishDetailScreen(
        dishId: state.pathParameters['dishId']!,
      )),
      GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
      GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
      
      // Auth
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      
      // Rutas protegidas (requieren auth)
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      // ... mas rutas
      
      // Shell routes para empleado y admin con navegacion propia
      ShellRoute(/* employee shell */),
      ShellRoute(/* admin shell */),
    ],
  );
}
```

### Reglas de navegacion

1. Nunca usar `Navigator.push()` ni `Navigator.pop()` directamente. Siempre `context.go()`, `context.push()`, `context.pop()`.
2. Rutas publicas (sin auth): `/`, `/menu`, `/menu/:id`, `/cart`, `/contact`, `/chat`, `/catering`.
3. Rutas protegidas (requieren auth): `/checkout`, `/orders`, `/profile`, `/favorites`, `/catering/request`.
4. Rutas de empleado: `/employee/kitchen`, `/employee/delivery`, `/employee/pos`, `/employee/scanner`.
5. Rutas de admin: `/admin/dashboard`, `/admin/dishes`, `/admin/orders`, etc.
6. La verificacion de rol (employee vs admin) se hace en el redirect de GoRouter consultando `profiles.role`.

---

## 9. Patron Repository con Supabase

### Estructura de un repository

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'menu_repository.g.dart';

@Riverpod(keepAlive: true)
MenuRepository menuRepository(Ref ref) {
  return MenuRepository(ref.watch(supabaseClientProvider));
}

class MenuRepository {
  final SupabaseClient _client;
  
  MenuRepository(this._client);

  Future<List<Dish>> getDishes({String? categoryId}) async {
    var query = _client.from('dishes').select().eq('is_active', true);
    
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    
    final response = await query.order('name');
    return response.map((json) => Dish.fromJson(json)).toList();
  }

  Future<Dish> getDishById(String id) async {
    final response = await _client
        .from('dishes')
        .select()
        .eq('id', id)
        .single();
    return Dish.fromJson(response);
  }

  Stream<List<Dish>> watchDishes() {
    return _client
        .from('dishes')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .map((data) => data.map((json) => Dish.fromJson(json)).toList());
  }
}
```

### Reglas del repository

1. Los repositories reciben `SupabaseClient` por constructor (inyeccion de dependencias via Riverpod).
2. Todo acceso a Supabase pasa por un repository. Ningun widget ni provider accede a `supabase.from()` directamente.
3. Los repositories devuelven modelos Freezed, nunca `Map<String, dynamic>`.
4. Para operaciones en tiempo real, los repositories exponen `Stream<T>` usando `.stream()`.
5. Los errores de Supabase se capturan en el repository y se transforman en `Failure` tipados (no se propagan `PostgrestException` a la UI).

### Manejo de errores

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  Future<List<Dish>> getDishes() async {
    try {
      final response = await _client.from('dishes').select().eq('is_active', true);
      return response.map((json) => Dish.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
```

---

## 10. Seguridad

### Principios fundamentales

1. **Nunca exponer API keys secretas en el cliente**. Las Supabase `anon key` y `url` son publicas por diseno (la seguridad la da RLS). Pero las keys de Stripe secret, Brevo API, Gemini API, y la Supabase `service_role_key` van SOLO en Edge Functions (servidor).
2. **Row Level Security (RLS) obligatorio** en TODAS las tablas de Supabase desde el dia 1.
3. **Validar entrada en cliente Y servidor**. La validacion del cliente es para UX; la del servidor (RLS + constraints de BD + Edge Functions) es para seguridad real.
4. **Nunca confiar en datos del cliente** para calculos de precio. El total del pedido se recalcula en la Edge Function de Stripe.

### RLS por tabla (directrices)

| Tabla | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| profiles | own row | via trigger on auth.users | own row | never |
| dishes | all (public) | admin only | admin only | admin only |
| categories | all (public) | admin only | admin only | admin only |
| orders | own orders / employee all / admin all | authenticated | employee+admin status | admin only |
| order_items | via order ownership | via order creation | never | never |
| favorites | own rows | authenticated | never | own rows |
| contact_messages | admin only | all (public, rate limited) | admin only | admin only |
| event_requests | own requests / admin all | authenticated | admin (status) + own (limited) | admin only |
| push_tokens | own rows | authenticated | own rows | own rows |

### Gestion de entornos

Usar `--dart-define-from-file` para builds. Ficheros `.env` solo para referencia local en desarrollo.

```
# .env.development (NO se sube a git -- esta en .gitignore)
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

```
# Comando de build
flutter run --dart-define-from-file=.env.development
flutter build apk --dart-define-from-file=.env.production
flutter build web --dart-define-from-file=.env.production
```

```dart
// Acceso en Dart (compilado, no aparece en bundle como texto plano)
class EnvConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

### Sanitizacion de entrada

- Todo input de texto del usuario se sanitiza antes de enviarlo a Supabase: trim, limitar longitud maxima.
- Para el formulario de contacto (publico, sin auth), implementar rate limiting en el lado de Supabase (RLS + trigger o Edge Function).
- Nunca interpolar strings del usuario en queries. El Supabase Dart client ya parametriza queries, pero verificar que no se construyen filtros con concatenacion de strings.

### Auth

- Supabase Auth con email+password y Google OAuth.
- JWT se gestiona automaticamente por `supabase_flutter` (persistencia en secure storage).
- Al hacer logout, limpiar estado de Riverpod con `ref.invalidate()` de todos los providers de usuario.
- El token FCM se registra tras login exitoso y se elimina de la BD tras logout.

---

## 11. Gestion de entornos

### Ficheros de entorno

```
.env.development      # Supabase proyecto de desarrollo
.env.production       # Supabase proyecto de produccion
```

Ambos ficheros van en `.gitignore`. Nunca se suben al repositorio.

### Bootstrap

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: App()));
}

// bootstrap.dart
Future<void> bootstrap() async {
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  // Inicializar FCM, etc.
}
```

---

## 12. Modelo de datos

### Tablas en Supabase (18 tablas)

profiles, addresses, categories, dishes, daily_special, schedule, orders, order_items, order_ratings, favorites, event_menus, event_menu_courses, event_extras, event_requests, event_request_selections, event_request_extras, event_calendar, contact_messages, push_tokens, business_config.

### Convenciones BD

- Nombres de tabla en **snake_case plural** (ej: `order_items`, `event_menus`).
- PKs son `UUID` generados con `gen_random_uuid()`.
- Timestamps son `TIMESTAMPTZ` (con timezone), nunca `TIMESTAMP`.
- Booleans con prefijo semantico: `is_active`, `is_read`, `is_default`.
- ENUMs definidos como PostgreSQL ENUM types o CHECK constraints.
- Soft delete: las tablas principales usan `is_active` en vez de DELETE fisico.

### Mapeo tabla -> modelo Freezed

Cada tabla tiene un modelo Freezed correspondiente en `features/<feature>/domain/models/`. El nombre del modelo es el singular de la tabla en PascalCase:

| Tabla | Modelo Freezed | Feature |
|-------|---------------|---------|
| profiles | UserProfile | auth |
| addresses | Address | profile |
| categories | Category | menu |
| dishes | Dish | menu |
| daily_special | DailySpecial | menu |
| schedule | TimeSlot | orders |
| orders | Order | orders |
| order_items | OrderItem | orders |
| order_ratings | OrderRating | orders |
| favorites | Favorite | menu |
| event_menus | EventMenu | catering |
| event_menu_courses | EventMenuCourse | catering |
| event_extras | EventExtra | catering |
| event_requests | EventRequest | catering |
| event_calendar | EventCalendarEntry | catering |
| contact_messages | ContactMessage | contact |
| push_tokens | PushToken | notifications |
| business_config | BusinessConfig | admin |

---

## 13. Edge Functions

Las Edge Functions se escriben en **TypeScript (Deno)** y viven en `supabase/functions/`.

### Funciones planificadas

| Funcion | Trigger | Descripcion |
|---------|---------|-------------|
| create-payment-intent | HTTP POST desde app | Recibe items + tipo pedido, valida precios contra BD, crea Stripe PaymentIntent, devuelve client_secret |
| handle-stripe-webhook | Stripe webhook POST | Recibe evento payment_intent.succeeded, actualiza order.payment_status en BD |
| send-push | DB trigger (order status change) | Consulta push_tokens del usuario, envia via FCM |
| send-email | DB trigger o HTTP POST | Envia email transaccional via Brevo (confirmacion pedido, presupuesto catering, bienvenida) |
| chatbot | HTTP POST desde app | Recibe mensaje del usuario + contexto (menu, horarios), llama a Gemini API, devuelve respuesta |
| recommend-dishes | HTTP POST desde app | Recibe user_id, consulta historial, llama a Gemini API para recomendacion, devuelve lista de dish_ids |

### Seguridad en Edge Functions

1. Verificar el JWT del usuario en cada request (`req.headers.get('Authorization')`).
2. Usar `createClient()` con `service_role_key` solo para operaciones que necesitan bypasear RLS (contar stock, recalcular precios).
3. Las keys secretas (STRIPE_SECRET_KEY, BREVO_API_KEY, GEMINI_API_KEY) se almacenan como **Supabase Secrets** (`supabase secrets set KEY=value`), nunca hardcodeadas.
4. Validar y sanitizar todo input recibido en la Edge Function.
5. Limitar el tamano del payload (maxBodySize).

---

## 14. Naming conventions

### Ficheros

| Tipo | Convencion | Ejemplo |
|------|-----------|---------|
| Screens | `<nombre>_screen.dart` | `login_screen.dart` |
| Widgets | `<nombre>_widget.dart` o descriptivo | `dish_card.dart` |
| Providers | `<nombre>_provider.dart` | `auth_provider.dart` |
| Repositories | `<nombre>_repository.dart` | `menu_repository.dart` |
| Datasources | `<nombre>_remote_datasource.dart` | `auth_remote_datasource.dart` |
| Models | `<nombre>.dart` (singular) | `dish.dart`, `order.dart` |
| Generated | `<nombre>.freezed.dart`, `<nombre>.g.dart` | `dish.freezed.dart` |
| Tests | `<nombre>_test.dart` | `auth_repository_test.dart` |
| Edge Functions | `index.ts` dentro de carpeta con nombre | `functions/chatbot/index.ts` |

### Clases y tipos

| Tipo | Convencion | Ejemplo |
|------|-----------|---------|
| Modelos Freezed | PascalCase, singular | `Dish`, `OrderItem`, `UserProfile` |
| Providers | camelCase + Provider suffix (generado) | `menuProvider`, `authNotifierProvider` |
| Notifiers Riverpod | PascalCase + Notifier | `AuthNotifier`, `CartNotifier` |
| Repositories | PascalCase + Repository | `MenuRepository`, `OrderRepository` |
| Screens | PascalCase + Screen | `LoginScreen`, `MenuScreen` |
| Widgets | PascalCase descriptivo | `DishCard`, `AllergenBadge` |
| Enums | PascalCase, valores camelCase | `OrderType { mostrador, encargo, domicilio, recogida }` |
| Failures | PascalCase + Failure | `DatabaseFailure`, `AuthFailure` |

### Variables y funciones

- Variables y funciones en **camelCase**: `dishList`, `fetchDishes()`, `isLoading`.
- Constantes en **camelCase** (Dart convention): `const maxRetries = 3;`.
- Privados con underscore: `_client`, `_fetchData()`.
- Booleans con prefijo semantico: `isLoading`, `hasError`, `canSubmit`.

---

## 15. Linting y formato

### Paquete de linting

Usar `very_good_analysis` para reglas estrictas de nivel produccion.

```yaml
# analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore  # Para Freezed

linter:
  rules:
    public_member_api_docs: false  # No requerimos docs en todos los miembros publicos
```

### Reglas de formato

- Maximo 80 caracteres por linea (configurable a 100 si 80 es muy restrictivo).
- `dart format` antes de cada commit.
- Trailing commas obligatorias en argumentos de widgets para formateo legible.
- Imports ordenados: dart > package > relative. Usar `dart fix --apply` periodicamente.

---

## 16. Testing

### Estrategia

Nivel de testing: **Unit tests para repositories y providers** + **Widget tests para pantallas criticas**.

| Capa | Tipo de test | Cobertura objetivo |
|------|--------------|--------------------|
| Repositories | Unit test | Todos los repositories |
| Providers / Notifiers | Unit test | Toda la logica de negocio |
| Screens criticas | Widget test | Login, checkout, carrito, TPV |
| Flujos criticos | Integration test | Pedido completo (si tiempo) |

### Patrones de test

- **Fakes sobre Mocks**: Crear implementaciones Fake de repositories (alineado con skill `flutter-testing-apps`).
- Provider testing con `ProviderContainer` de Riverpod.
- No testear ficheros generados (`.freezed.dart`, `.g.dart`).

```dart
// Ejemplo: Fake repository
class FakeMenuRepository implements MenuRepository {
  @override
  Future<List<Dish>> getDishes({String? categoryId}) async {
    return [
      const Dish(id: '1', categoryId: 'cat1', name: 'Croquetas', 
                 description: 'Caseras', price: 6.50),
    ];
  }
  // ... resto de metodos
}

// Ejemplo: Test de provider
void main() {
  test('menuProvider devuelve lista de platos', () async {
    final container = ProviderContainer(
      overrides: [
        menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
      ],
    );
    
    final result = await container.read(menuProvider.future);
    expect(result, isNotEmpty);
    expect(result.first.name, 'Croquetas');
  });
}
```

---

## 17. Git workflow

### Estrategia de ramas

Trunk-based simplificado:

```
main ─────────────────────────────────────── (produccion, protegida)
  \                    /
   feature/auth ──────
  \                        /
   feature/menu ──────────
  \                            /
   feature/orders ────────────
```

- `main`: rama de produccion. Solo se mergea codigo funcional y testeado.
- `feature/<nombre>`: rama por funcionalidad. Se crea desde main, se mergea a main cuando esta completa.
- Nunca hacer commit directo a main.

### Conventional Commits

Formato obligatorio para mensajes de commit:

```
<tipo>(<scope>): <descripcion corta>

[cuerpo opcional]
```

Tipos permitidos:

| Tipo | Uso |
|------|-----|
| feat | Nueva funcionalidad |
| fix | Correccion de bug |
| refactor | Refactorizacion sin cambio de comportamiento |
| style | Cambios de formato (no afectan logica) |
| test | Anadir o modificar tests |
| docs | Cambios en documentacion |
| chore | Tareas de mantenimiento (deps, config) |
| build | Cambios en build system o dependencias |

Ejemplos:
```
feat(auth): implementar login con email y password
feat(menu): anadir filtro por alergenos  
fix(cart): corregir calculo de subtotal con descuento
refactor(orders): extraer logica de estado a OrderStatusHelper
test(auth): anadir unit tests para AuthRepository
chore(deps): actualizar riverpod a 2.6.1
```

### .gitignore

Incluir obligatoriamente:
```
.env.development
.env.production
.env.*
*.jks
*.keystore
google-services.json
firebase_options.dart
```

---

## 18. Theming

### Material 3 (alineado con skill flutter-theming-apps)

```dart
// app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: /* color principal del negocio */,
      brightness: Brightness.light,
    ),
    // Component themes con *ThemeData suffix
    appBarTheme: const AppBarThemeData(centerTitle: true),
    cardTheme: const CardThemeData(elevation: 1),
    inputDecorationTheme: const InputDecorationThemeData(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: /* mismo color */,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarThemeData(centerTitle: true),
    cardTheme: const CardThemeData(elevation: 1),
    inputDecorationTheme: const InputDecorationThemeData(
      border: OutlineInputBorder(),
      filled: true,
    ),
  );
}
```

### Reglas de theming

1. Colores solo desde `Theme.of(context).colorScheme`. Nunca hardcodear `Colors.red` en produccion.
2. Texto desde `Theme.of(context).textTheme`. Nunca hardcodear `TextStyle(fontSize: 16)`.
3. Modo oscuro/claro: el usuario elige en perfil (sistema / light / dark). Se persiste en `shared_preferences` y se gestiona con un Riverpod provider.
4. Usar `NavigationBar` (M3), no `BottomNavigationBar` (legacy).
5. Botones: `FilledButton`, `OutlinedButton`, `TextButton`. Nunca `FlatButton` ni `RaisedButton`.

---

## 19. Formularios

### Patron estandar (alineado con skill flutter-building-forms)

1. El formulario vive en un `ConsumerStatefulWidget` (necesita `GlobalKey<FormState>` + acceso a ref).
2. `GlobalKey<FormState>` instanciado como `final` en el State.
3. Validacion con `TextFormField.validator`.
4. Submit: `_formKey.currentState!.validate()` -> si ok, llama al provider via `ref.read(miProvider.notifier).submit(data)`.
5. Nunca usar `setState()` para controlar el estado de envio (loading, error). Eso lo hace el provider.

### Validadores centralizados

```dart
// core/utils/validators.dart
class Validators {
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo obligatorio' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email obligatorio';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value.trim()) ? null : 'Email no valido';
  }

  static String? minLength(String? value, int min) =>
      (value != null && value.length >= min) ? null : 'Minimo $min caracteres';

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // opcional
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    return regex.hasMatch(value.trim()) ? null : 'Telefono no valido';
  }
}
```

---

## 20. Imagenes y Storage

### Supabase Storage

- Bucket `dish-images` para fotos de platos (publico, lectura sin auth).
- Bucket `avatars` para fotos de perfil (privado, lectura solo del propietario).
- Bucket `attachments` para adjuntos del formulario de contacto (privado).
- Bucket `quotes` para PDFs de presupuestos de catering (privado, lectura usuario + admin).

### Subida de imagenes

```dart
// storage_service.dart
Future<String> uploadDishImage(String dishId, Uint8List bytes) async {
  final path = 'dishes/$dishId.webp';
  await _client.storage.from('dish-images').uploadBinary(
    path,
    bytes,
    fileOptions: const FileOptions(upsert: true, contentType: 'image/webp'),
  );
  return _client.storage.from('dish-images').getPublicUrl(path);
}
```

### Reglas de imagenes

1. Comprimir SIEMPRE antes de subir con `flutter_image_compress`. Objetivo: max 500KB para platos, max 200KB para avatares.
2. Formato preferido: WebP (mejor compresion, soporte universal).
3. En UI usar `CachedNetworkImage` para cache automatico de imagenes descargadas.
4. Lazy loading: las imagenes en listas/grids usan `fadeInDuration` y placeholder.

---

## 21. Realtime

### Usos de Supabase Realtime

| Feature | Canal | Tipo |
|---------|-------|------|
| Panel cocina (KDS) | `orders` table changes | postgres_changes (INSERT, UPDATE) |
| Panel repartidor | `orders` filtered by driver | postgres_changes (UPDATE) |
| Estado pedido (cliente) | `orders` filtered by user | postgres_changes (UPDATE) |
| Plato del dia | `daily_special` | postgres_changes (INSERT, UPDATE) |
| Pedido grupal | custom channel por group_id | broadcast |

### Patron Realtime con Riverpod

```dart
@riverpod
Stream<List<Order>> kitchenOrders(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return client
      .from('orders')
      .stream(primaryKey: ['id'])
      .inFilter('status', ['pending', 'confirmed', 'preparing'])
      .order('created_at')
      .map((data) => data.map((json) => Order.fromJson(json)).toList());
}
```

---

## 22. Notificaciones

### FCM setup

1. `firebase_messaging` para recibir push en Android.
2. En web, FCM funciona via service worker.
3. Tras login exitoso, registrar token en tabla `push_tokens`.
4. Tras logout, eliminar token de la BD.
5. Las notificaciones se envian desde Edge Function `send-push`, nunca desde el cliente.

### Cuando notificar

| Evento | Destinatario | Canal |
|--------|-------------|-------|
| Pedido nuevo | Empleados cocina | Push + Realtime |
| Pedido listo | Cliente | Push + Email |
| Pedido en camino | Cliente | Push |
| Pedido entregado | Cliente | Push |
| Presupuesto catering listo | Cliente | Push + Email |
| Nuevo mensaje contacto | Admin | Push |

---

## 23. Accesibilidad

Alineado con la skill `flutter-improving-accessibility`:

1. Tap targets minimo 48x48 pixels.
2. Contraste de color minimo 4.5:1 (verificar con `ColorScheme.fromSeed` que lo cumple).
3. `Semantics` en widgets custom interactivos.
4. `ExcludeSemantics` en elementos decorativos (iconos junto a texto que ya lo describe).
5. Textos que escalan: no hardcodear alturas fijas en contenedores de texto.
6. Web: habilitar semantics tree para lectores de pantalla.

---

## 24. Rendimiento

1. `const` constructors siempre que sea posible para evitar rebuilds innecesarios.
2. `ListView.builder` y `GridView.builder` para listas largas (nunca `Column` con `children: list.map(...)`).
3. Imagenes comprimidas y cacheadas (ver seccion 20).
4. Provider `autoDispose` por defecto (el code generation lo hace automaticamente) para liberar recursos cuando la pantalla se desmonta.
5. No hacer queries pesadas en `build()`. Toda carga de datos va en el provider.
6. Para JSON grande (1000+ items), parsear en un isolate con `compute()`.
7. Tree shake de iconos: solo importar los Material Icons usados si el tamano del bundle es un problema.

---

## 25. Practicas prohibidas

| Practica | Motivo | Alternativa |
|----------|--------|-------------|
| `setState()` para logica de negocio | Directriz del profesor, no escalable | Riverpod provider |
| `Provider` package | Obsoleto para este proyecto | Riverpod |
| `ChangeNotifier` | Incompatible con Riverpod code gen | `@riverpod class Notifier` |
| `GetIt` / service locator | Riverpod ya es DI container | `ref.watch(provider)` |
| `BLoC` / `Cubit` | No autorizado, stack diferente | Riverpod |
| `Navigator.push/pop` | Incompatible con GoRouter | `context.go()` / `context.push()` |
| API keys secretas en cliente | Vulnerabilidad critica | Edge Functions + Supabase Secrets |
| SQL string interpolation | Inyeccion SQL | Supabase client parametrizado |
| `http.get()` para queries a BD | Bypasea RLS y tipado | Supabase Dart client |
| Modelos mutables (campos no-final) | Bugs de estado impredecibles | Freezed `@freezed` |
| Colores hardcodeados | Rompe theming/modo oscuro | `Theme.of(context).colorScheme` |
| `print()` en produccion | Leak de info sensible | Logger condicional o paquete `logger` |
| Commit a main directo | Workflow descontrolado | Feature branches |
| `.env` en git | Filtracion de keys | `.gitignore` |
| `FlatButton` / `RaisedButton` | Obsoletos en M3 | `TextButton` / `FilledButton` |
| `BottomNavigationBar` | Legacy M2 | `NavigationBar` (M3) |

---

## 26. Dependencias aprobadas

### pubspec.yaml (core)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (OBLIGATORIO)
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Routing (OBLIGATORIO)
  go_router: ^14.8.1
  
  # Models (OBLIGATORIO)
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  
  # Backend
  supabase_flutter: ^2.8.4
  
  # Payments
  flutter_stripe: ^11.4.0       # Android
  # Web: Stripe.js via html (dart:js_interop)
  
  # Push Notifications
  firebase_core: ^3.12.1
  firebase_messaging: ^15.2.4
  
  # Images
  cached_network_image: ^3.4.1
  flutter_image_compress: ^2.3.0
  
  # UI
  lottie: ^3.3.1
  
  # QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^6.0.5
  
  # PDF
  pdf: ^3.11.2
  printing: ^5.13.5
  
  # Speech
  speech_to_text: ^7.0.0
  
  # Storage local
  shared_preferences: ^2.3.5
  
  # Utils
  intl: ^0.19.0
  url_launcher: ^6.3.1
  connectivity_plus: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation (OBLIGATORIO)
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.3
  freezed: ^2.5.8
  json_serializable: ^6.8.0  # Requerido por Freezed para toJson/fromJson
  
  # Linting
  very_good_analysis: ^6.0.0
  
  # Testing
  mocktail: ^1.0.4
```

### Reglas de dependencias

1. Nunca anadir un paquete sin verificar: (a) que esta mantenido activamente, (b) que es compatible con Flutter 3.38, (c) que soporta web si lo necesitamos.
2. Fijar versiones con caret `^` (permite patches, no major bumps).
3. Ejecutar `flutter pub outdated` periodicamente.
4. Las versiones listadas arriba son orientativas. Al iniciar el proyecto, usar las ultimas estables disponibles en pub.dev.
5. `json_serializable` se incluye en dev_dependencies porque Freezed lo necesita internamente para la generacion de `fromJson`/`toJson`. No usarlo directamente para crear modelos.
