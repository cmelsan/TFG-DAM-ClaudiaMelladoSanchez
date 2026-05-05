# Arquitectura — Sabor de Casa

Guía técnica de la arquitectura interna de la aplicación Flutter.

---

## Índice

1. [Visión general](#1-visión-general)
2. [Capas de la arquitectura](#2-capas-de-la-arquitectura)
3. [Patrón de feature](#3-patrón-de-feature)
4. [Gestión de estado (Riverpod)](#4-gestión-de-estado-riverpod)
5. [Modelos de dominio (Freezed)](#5-modelos-de-dominio-freezed)
6. [Navegación (GoRouter)](#6-navegación-gorouter)
7. [Inicialización de la app](#7-inicialización-de-la-app)
8. [Tema y apariencia](#8-tema-y-apariencia)
9. [Plataformas (web vs. Android)](#9-plataformas-web-vs-android)
10. [Manejo de errores](#10-manejo-de-errores)
11. [Generación de código](#11-generación-de-código)

---

## 1. Visión general

```
┌────────────────────────────────────────────────┐
│               Flutter App (UI)                 │
│   ConsumerWidget / ConsumerStatefulWidget      │
│   ← observa AsyncValue de providers           │
└─────────────────┬──────────────────────────────┘
                  │ ref.watch / ref.read
┌─────────────────▼──────────────────────────────┐
│            Riverpod Providers                   │
│   @riverpod (auto-dispose por defecto)          │
│   @Riverpod(keepAlive) para singletons          │
└─────────────────┬──────────────────────────────┘
                  │ repository.method()
┌─────────────────▼──────────────────────────────┐
│             Repositories                        │
│   Acceso directo a Supabase client              │
│   Devuelven modelos Freezed o List<Model>       │
└─────────────────┬──────────────────────────────┘
                  │ supabase_flutter
┌─────────────────▼──────────────────────────────┐
│         Supabase (PostgreSQL + Auth)            │
│   RLS activo en todas las tablas                │
│   Edge Functions para lógica de servidor        │
└────────────────────────────────────────────────┘
```

---

## 2. Capas de la arquitectura

| Capa | Responsabilidad | Artefactos |
|------|----------------|------------|
| **UI** | Renderizar y capturar interacciones | `*_screen.dart`, `*_widget.dart` |
| **State/Logic** | Estado reactivo, lógica de presentación | `*_provider.dart` (Riverpod) |
| **Data** | Acceso a datos externos | `*_repository.dart` |
| **Domain** | Modelos puros de la app | `*_model.dart` (Freezed) |

Regla estricta: **la UI nunca habla directamente con Supabase**. Toda comunicación pasa por providers → repositories.

---

## 3. Patrón de feature

Cada feature sigue la misma estructura de directorios:

```
feature_name/
├── data/
│   └── repositories/
│       ├── feature_repository.dart       ← Implementación con Supabase
│       └── feature_repository.g.dart     ← Generado (Riverpod)
├── domain/
│   └── models/
│       ├── feature_model.dart            ← @freezed class
│       ├── feature_model.freezed.dart    ← Generado (Freezed)
│       └── feature_model.g.dart          ← Generado (json_serializable)
└── presentation/
    ├── screens/
    │   └── feature_screen.dart           ← ConsumerWidget / ConsumerStatefulWidget
    ├── providers/
    │   ├── feature_provider.dart         ← @riverpod / @Riverpod
    │   └── feature_provider.g.dart       ← Generado (Riverpod)
    └── widgets/
        └── feature_specific_widget.dart  ← Widgets reutilizables de la feature
```

---

## 4. Gestión de estado (Riverpod)

### Tipos de providers usados

**`@riverpod` (auto-dispose)**
```dart
// Future: carga datos, se invalida con ref.invalidate()
@riverpod
Future<List<Dish>> dishes(DishesRef ref) => 
    ref.watch(menuRepositoryProvider).getDishes();

// Notifier: estado mutable
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() => const CartState.empty();
  void addItem(CartItem item) { /* ... */ }
}
```

**`@Riverpod(keepAlive: true)` (singleton)**
```dart
// Usado para: AuthNotifier, CheckoutRepository, SupabaseService
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<UserProfile?> build() async { /* ... */ }
}
```

### Convenciones de naming

| Tipo | Sufijo del provider | Ejemplo |
|------|--------------------|----|
| Future (datos) | `Provider` | `dishesProvider`, `ordersProvider` |
| Notifier mutable | `NotifierProvider` | `cartNotifierProvider` |
| Stream (realtime) | `StreamProvider` | `kitchenOrdersStreamProvider` |
| Repositorio | `RepositoryProvider` | `menuRepositoryProvider` |

### Invalidación de cache
```dart
// Forzar recarga tras mutación
ref.invalidate(ordersProvider);
ref.invalidate(menuProvider);
```

### Consumir en UI
```dart
// ConsumerWidget — más ligero, preferido para pantallas simples
class MenuScreen extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final dishesAsync = ref.watch(dishesProvider);
    return dishesAsync.when(
      data: (dishes) => ListView(...),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(message: e.toString()),
    );
  }
}

// ConsumerStatefulWidget — cuando se necesita AnimationController, etc.
class OrderConfirmationScreen extends ConsumerStatefulWidget { /* ... */ }
```

---

## 5. Modelos de dominio (Freezed)

Todo modelo de dominio usa `@freezed`:

```dart
@freezed
class Order with _$Order {
  const factory Order({
    required String id,
    required String orderType,
    required String status,
    required double total,
    String? notes,
    DateTime? scheduledAt,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}
```

**Reglas**:
- Siempre incluir `fromJson` para deserializar respuestas de Supabase
- Campos opcionales con `?` y valor por defecto si es necesario
- No lógica de negocio en modelos Freezed
- Los archivos `.freezed.dart` y `.g.dart` son **generados** → no editar

---

## 6. Navegación (GoRouter)

### Configuración
- Hash routing en web: `/#/ruta` (via `GoRouter(initialLocation: '/splash')`)
- Named routes vía `RouteNames` (constantes de strings)
- Shell route para la navegación con tabs (`ScaffoldWithNavBar`)

### Provider del router (keepAlive)
```dart
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) => _redirect(authState, state),
    routes: [ /* ... */ ],
  );
}
```

### Protección de rutas
El `redirect` en `app_router.dart` evalúa:
1. Si la ruta está en `_protectedPaths` → requiere auth
2. Si la ruta empieza por `/employee/` o `/admin/` → requiere rol específico
3. Si el usuario ya está autenticado y va a `/auth/*` → redirige a `/`

### Navegación desde UI
```dart
// Navegar por nombre (preferido)
context.goNamed(RouteNames.orderConfirmation,
    pathParameters: {'orderId': id});

// Navegar con path completo
context.go('/menu');

// Volver atrás
context.pop();
```

---

## 7. Inicialización de la app

**Flujo de arranque** (`main.dart` → `bootstrap.dart` → `App`):

```
main()
  └── WidgetsFlutterBinding.ensureInitialized()
  └── bootstrap()
      ├── Supabase.initialize(url, anonKey)
      ├── if (!kIsWeb):
      │   ├── Stripe.publishableKey = ...
      │   ├── Firebase.initializeApp()
      │   └── _setupFcm()         ← solicita permisos + guarda token FCM
      └── runApp(ProviderScope(child: App()))
```

**`App` widget** (`app.dart`):
```dart
MaterialApp.router(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ref.watch(themeNotifierProvider).valueOrNull,
  routerConfig: ref.watch(appRouterProvider),
)
```

---

## 8. Tema y apariencia

- Definido en `lib/core/theme/app_theme.dart`
- `AppTheme.light()` y `AppTheme.dark()` devuelven `ThemeData`
- `ThemeNotifier` (Riverpod, keepAlive) persiste la preferencia en `SharedPreferences`
- Fuentes: Google Fonts (via `google_fonts`)

---

## 9. Plataformas (web vs. Android)

La app corre en **Android** y **Web (Chrome)**. Diferencias por plataforma:

| Aspecto | Android | Web |
|---------|---------|-----|
| Pagos | Stripe Payment Sheet (`flutter_stripe`) | Stripe Checkout redirect (`stripe_js`) |
| Stripe init | `bootstrap.dart` con `if (!kIsWeb)` | No se inicializa |
| Notificaciones | FCM push (`firebase_messaging`) | Email (Brevo) |
| Firebase | Inicializado en `bootstrap.dart` | No inicializado |
| Onboarding | Se muestra al primer uso | Saltado (`kIsWeb`) |
| Storage local | `SharedPreferences` nativo | `localStorage` via `web_storage_web.dart` |
| QR escáner | `mobile_scanner` | No disponible |
| Voz | `speech_to_text` | Experimental |

### Conditional imports para Storage
```dart
// web_storage.dart — exports el correcto según plataforma
export 'web_storage_stub.dart'   // Para Android/non-web
    if (dart.library.html) 'web_storage_web.dart'; // Para web
```

---

## 10. Manejo de errores

### En providers
```dart
// AsyncValue.guard captura excepciones y las convierte en AsyncError
state = await AsyncValue.guard(() => repository.fetchData());
```

### En UI
```dart
// .when() maneja los tres estados
asyncValue.when(
  data: (data) => /* Widget */,
  loading: () => const LoadingIndicator(),
  error: (error, _) => ErrorView(message: error.toString()),
);
```

### Widgets de error reutilizables
- `ErrorView` (`lib/core/widgets/error_view.dart`): muestra mensaje + botón de reintento
- `LoadingIndicator` (`lib/core/widgets/loading_indicator.dart`): spinner centrado

### Excepciones y fallos
- `lib/core/errors/exceptions.dart` — clases de excepciones de dominio
- `lib/core/errors/failures.dart` — clases de failures (resultado fallido tipado)

---

## 11. Generación de código

Los siguientes archivos son **generados automáticamente** y **no deben editarse**:

| Patrón | Genera | Herramienta |
|--------|--------|-------------|
| `*.freezed.dart` | Constructores, copyWith, operadores | `build_runner` + `freezed` |
| `*.g.dart` (modelos) | `fromJson`, `toJson` | `build_runner` + `json_serializable` |
| `*.g.dart` (providers) | Clase `_$Provider` + `xxxProvider` | `build_runner` + `riverpod_generator` |
| `app_router.g.dart` | — (GoRouter no usa gen en este proyecto) | — |

**Comando para regenerar**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Comando para watch (desarrollo continuo)**:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

> Ejecutar siempre tras añadir o modificar un modelo `@freezed` o un provider `@riverpod`.
