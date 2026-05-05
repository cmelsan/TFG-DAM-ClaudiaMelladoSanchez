# Sabor de Casa — Proyecto Final DAM

Aplicación multiplataforma (Android + Web) para un local de comida preparada para llevar con servicio de catering para eventos. Desarrollada como Proyecto Final de Grado Superior DAM.

---

## Índice

1. [Descripción del negocio](#1-descripción-del-negocio)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Arquitectura](#3-arquitectura)
4. [Estructura de carpetas](#4-estructura-de-carpetas)
5. [Features implementadas](#5-features-implementadas)
6. [Rutas y navegación](#6-rutas-y-navegación)
7. [Modelo de datos (Supabase)](#7-modelo-de-datos-supabase)
8. [Edge Functions](#8-edge-functions)
9. [Notificaciones](#9-notificaciones)
10. [Pagos (Stripe)](#10-pagos-stripe)
11. [Variables de entorno](#11-variables-de-entorno)
12. [Cómo ejecutar el proyecto](#12-cómo-ejecutar-el-proyecto)
13. [Migraciones SQL](#13-migraciones-sql)
14. [Roles de usuario](#14-roles-de-usuario)
15. [Tipos de pedido](#15-tipos-de-pedido)
16. [Changelog de implementación](#16-changelog-de-implementación)

---

## 1. Descripción del negocio

**Sabor de Casa** es una aplicación para un local de comida preparada que ofrece:

- Venta directa en mostrador (anónima, sin cuenta)
- Pedidos para recoger en el local (con o sin reserva anticipada)
- Pedidos a domicilio (solo en Huelva)
- Pedidos encargados (fecha y hora futura)
- Servicio de catering para eventos privados (bodas, comuniones, empresas…)

**Roles de usuario:**
| Rol | Acceso |
|-----|--------|
| `client` | Menú, carrito, pedidos propios, perfil, catering, chat IA |
| `employee` | Panel cocina (gestión de estados), pantalla de reparto, TPV mostrador, escáner QR |
| `admin` | Dashboard completo + todas las pantallas de empleado |

---

## 2. Stack tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Framework | Flutter | 3.38.6 |
| Lenguaje | Dart | 3.10.7 |
| Estado | flutter_riverpod + riverpod_annotation | ^2.6.1 |
| Modelos | freezed + freezed_annotation | ^2.5.8 / ^2.4.4 |
| Navegación | go_router | ^14.8.1 |
| Backend/Auth/DB | Supabase (supabase_flutter) | ^2.9.0 |
| Pagos móvil | flutter_stripe | ^11.5.0 |
| Pagos web | stripe_js | ^6.4.0 |
| Notificaciones push | firebase_messaging | ^15.2.4 |
| Emails transaccionales | Brevo (API REST) | — |
| Fuentes | google_fonts | ^6.2.1 |
| Imágenes en red | cached_network_image | ^3.4.1 |
| QR | qr_flutter | ^4.1.0 |
| Escáner QR | mobile_scanner | ^7.0.0 |
| Lottie animations | lottie | ^3.3.1 |
| PDF/Ticket | pdf + printing | ^3.11.2 / ^5.14.2 |
| Voz (pedido por voz) | speech_to_text | ^7.0.0 |
| Conectividad | connectivity_plus | ^6.1.4 |
| Preferencias locales | shared_preferences | ^2.5.3 |
| Compresión imágenes | flutter_image_compress | ^2.3.0 |
| Selector de imágenes | image_picker | ^1.1.2 |
| Internacionalización | intl | ^0.20.2 |
| Deep links | app_links | — |
| Apertura de URLs | url_launcher | ^6.3.1 |

---

## 3. Arquitectura

Se sigue una **arquitectura por capas** dentro de cada feature:

```
feature/
├── data/
│   └── repositories/      ← Acceso a datos (Supabase, HTTP)
├── domain/
│   └── models/            ← Modelos Freezed con fromJson/toJson
└── presentation/
    ├── screens/           ← Widgets de página (ConsumerWidget / ConsumerStatefulWidget)
    ├── providers/         ← Lógica de estado con Riverpod (@riverpod / @Riverpod)
    └── widgets/           ← Widgets reutilizables de la feature
```

**Patrones obligatorios:**
- `@riverpod` → providers auto-dispose (por defecto)
- `@Riverpod(keepAlive: true)` → singletons (ej. `authNotifierProvider`, `checkoutRepositoryProvider`)
- `@freezed` → todos los modelos de dominio
- `GoRouter` con named routes (via `RouteNames`)
- Patrón Repository: UI → Provider → Repository → Supabase
- `AsyncValue` (`AsyncLoading`, `AsyncData`, `AsyncError`) para estados async

---

## 4. Estructura de carpetas

```
lib/
├── main.dart                        ← Entry point
├── bootstrap.dart                   ← Inicialización async (Supabase, Stripe, Firebase)
├── app.dart                         ← MaterialApp.router + theme
├── core/
│   ├── config/                      ← Configuración de entorno (URLs, claves)
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── supabase_constants.dart  ← Nombres de tablas y buckets
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/
│   ├── router/
│   │   ├── app_router.dart          ← Definición de todas las rutas GoRouter
│   │   └── route_names.dart         ← Constantes de nombres de rutas
│   ├── theme/
│   │   ├── app_theme.dart           ← ThemeData claro y oscuro
│   │   └── theme_provider.dart      ← Riverpod provider para cambio de tema
│   ├── utils/
│   │   ├── formatters.dart
│   │   ├── validators.dart
│   │   ├── web_storage.dart         ← Abstracción conditional import
│   │   ├── web_storage_stub.dart    ← Stub para plataformas no-web
│   │   └── web_storage_web.dart     ← Implementación web (localStorage)
│   └── widgets/
│       ├── error_view.dart          ← Widget de error reutilizable
│       ├── loading_indicator.dart   ← Spinner de carga
│       └── scaffold_with_nav_bar.dart ← Shell de navegación con tabs
├── features/
│   ├── splash/                      ← Pantalla de carga + onboarding
│   ├── auth/                        ← Login, registro, estado global de auth
│   ├── home/                        ← Pantalla principal (adaptativa web/móvil)
│   ├── menu/                        ← Carta, detalle de plato, favoritos, plato del día
│   ├── cart/                        ← Carrito, checkout, pantalla de pago web
│   ├── orders/                      ← Historial de pedidos, detalle, confirmación
│   ├── profile/                     ← Perfil de usuario, direcciones, preferencias
│   ├── catering/                    ← Catálogo de menús, solicitud de evento
│   ├── chat/                        ← Chat con IA (Gemini)
│   ├── contact/                     ← Formulario de contacto
│   ├── delivery/                    ← Pantalla del repartidor, escáner QR
│   ├── group_order/                 ← Pedido grupal en tiempo real
│   ├── kitchen/                     ← Panel de cocina para empleados
│   ├── notifications/               ← Gestión de notificaciones push
│   ├── pos/                         ← TPV para venta en mostrador
│   └── admin/                       ← Panel de administración completo
└── services/
    └── supabase_service.dart        ← Cliente Supabase singleton

supabase/
├── migrations/                      ← Scripts SQL ordenados
│   ├── 00001_initial_schema.sql     ← Esquema completo
│   ├── 00002_sample_data.sql        ← Datos de demostración
│   ├── 00003_test_users.sql         ← Usuarios de prueba (3 roles)
│   └── 00004_encargo_config.sql     ← Config para pedidos encargados
└── functions/
    ├── create-payment-intent/       ← Crea PaymentIntent de Stripe (móvil)
    └── send-order-notification/     ← Envía email (Brevo) + push (FCM) al cliente

assets/
├── animations/                      ← Archivos Lottie .json
└── images/                          ← Imágenes estáticas

android/
web/
```

---

## 5. Features implementadas

### Área Cliente

| Feature | Pantallas | Estado |
|---------|-----------|--------|
| Splash & Onboarding | `SplashScreen`, `OnboardingScreen` | ✅ |
| Autenticación | `LoginScreen`, `RegisterScreen` | ✅ |
| Home | `HomeScreen` (adaptativa: web + móvil) | ✅ |
| Menú / Carta | `MenuScreen`, `DishDetailScreen` | ✅ |
| Favoritos | `FavoritesScreen` | ✅ |
| Plato del día | `DailySpecialBanner` con countdown | ✅ |
| Alertas de alérgenos | `AllergenBadge` en detalle de plato | ✅ |
| Carrito | `CartScreen`, `CheckoutScreen` | ✅ |
| Pago móvil | Stripe Payment Sheet (flutter_stripe) | ✅ |
| Pago web | Stripe Checkout (redirección) | ✅ |
| Confirmación de pedido | `OrderConfirmationScreen` (QR, Lottie, notif.) | ✅ |
| Historial de pedidos | `OrdersScreen`, `OrderDetailScreen` | ✅ |
| QR de recogida/encargo | `QrImageView` en confirmación y detalle | ✅ |
| Perfil de usuario | `ProfileScreen` | ✅ |
| Catering / Eventos | `CateringScreen`, `CateringRequestScreen`, `MyCateringRequestsScreen` | ✅ |
| Chat IA (Gemini) | `ChatScreen` | ✅ |
| Contacto | `ContactScreen` | ✅ |
| Pedido grupal | `GroupOrderScreen` (Realtime) | ✅ |
| Pedido por voz | Integrado en `CheckoutScreen` (speech_to_text) | ✅ |

### Área Empleado / Admin

| Feature | Pantallas | Estado |
|---------|-----------|--------|
| Panel de cocina | `KitchenScreen` (estados en tiempo real) | ✅ |
| Reparto | `DeliveryScreen` | ✅ |
| Escáner QR | `ScannerScreen` (mobile_scanner) | ✅ |
| TPV mostrador | `PosScreen` | ✅ |
| Dashboard admin | `AdminDashboardScreen` | ✅ |
| Gestión de platos | `AdminDishesScreen` | ✅ |
| Gestión de pedidos | `AdminOrdersScreen` | ✅ |
| Gestión de catering | `AdminCateringScreen` | ✅ |
| Gestión de encargos | `AdminEncargosScreen` | ✅ |
| Gestión de usuarios | `AdminUsersScreen` | ✅ |
| Configuración del negocio | `AdminConfigScreen` | ✅ |
| Horarios | `AdminScheduleScreen` | ✅ |
| Estadísticas | `AdminStatsScreen` | ✅ |

---

## 6. Rutas y navegación

Implementado con **GoRouter 14** + hash routing en web (`/#/ruta`).

| Ruta | Nombre | Protección |
|------|--------|-----------|
| `/splash` | `splash` | Pública |
| `/onboarding` | `onboarding` | Pública |
| `/` | `home` | Pública |
| `/menu` | `menu` | Pública |
| `/menu/:dishId` | `dish-detail` | Pública |
| `/cart` | `cart` | Pública |
| `/contact` | `contact` | Pública |
| `/chat` | `chat` | Pública |
| `/catering` | `catering` | Pública |
| `/auth/login` | `login` | Pública |
| `/auth/register` | `register` | Pública |
| `/checkout` | `checkout` | Auth requerida |
| `/payment-success` | `payment-success` | Auth requerida |
| `/order-confirmation/:orderId` | `order-confirmation` | Auth requerida |
| `/orders` | `orders` | Auth requerida |
| `/order-detail/:orderId` | `order-detail` | Auth requerida |
| `/profile` | `profile` | Auth requerida |
| `/favorites` | `favorites` | Auth requerida |
| `/catering-request` | `catering-request` | Auth requerida |
| `/my-catering-requests` | `my-catering-requests` | Auth requerida |
| `/group-order` | `group-order` | Auth requerida |
| `/employee/kitchen` | `kitchen` | Role: employee/admin |
| `/employee/delivery` | `delivery` | Role: employee/admin |
| `/employee/delivery/scanner` | `scanner` | Role: employee/admin |
| `/employee/pos` | `pos` | Role: employee/admin |
| `/admin` | `admin-dashboard` | Role: admin |
| `/admin/dishes` | `admin-dishes` | Role: admin |
| `/admin/orders` | `admin-orders` | Role: admin |
| `/admin/catering` | `admin-catering` | Role: admin |
| `/admin/encargos` | `admin-encargos` | Role: admin |
| `/admin/users` | `admin-users` | Role: admin |
| `/admin/config` | `admin-config` | Role: admin |
| `/admin/schedule` | `admin-schedule` | Role: admin |
| `/admin/stats` | `admin-stats` | Role: admin |

---

## 7. Modelo de datos (Supabase)

**URL del proyecto**: `vrxliepwzvdrcxpdgpnd.supabase.co`

### Tablas principales

| Tabla | Descripción |
|-------|-------------|
| `profiles` | Usuarios (extiende `auth.users`). Campos: `role`, `full_name`, `phone`, `avatar_url` |
| `addresses` | Direcciones de entrega por usuario |
| `categories` | Categorías del menú |
| `dishes` | Platos con precio, alérgenos, tiempo de preparación |
| `daily_special` | Plato del día con descuento opcional |
| `schedule` | Horarios del local por día de la semana |
| `orders` | Pedidos. Campos: `order_type`, `status`, `payment_method`, `payment_status`, `scheduled_at` |
| `order_items` | Líneas de cada pedido (referencia a `dishes`) |
| `order_ratings` | Valoraciones de pedidos entregados |
| `favorites` | Platos favoritos por usuario |
| `event_menus` | Menús disponibles para catering |
| `event_menu_courses` | Platos de cada menú de catering |
| `event_extras` | Extras opcionales para catering |
| `event_requests` | Solicitudes de evento de catering |
| `event_request_selections` | Menús seleccionados en cada solicitud |
| `event_request_extras` | Extras seleccionados en cada solicitud |
| `event_calendar` | Fechas bloqueadas para catering |
| `contact_messages` | Mensajes del formulario de contacto |
| `push_tokens` | Tokens FCM para notificaciones push (por dispositivo) |
| `business_config` | Configuración del negocio (clave-valor) |

### Tipos ENUM

```sql
user_role:           client | employee | admin
order_type:          mostrador | encargo | domicilio | recogida
order_status:        pending | confirmed | preparing | ready | delivering | delivered | cancelled
payment_status:      pending | paid | refunded
payment_method:      card | cash | online
event_request_status: pending | quoted | accepted | rejected | completed
```

### Buckets de Storage

| Bucket | Uso |
|--------|-----|
| `dish-images` | Fotos de platos |
| `category-images` | Fotos de categorías |
| `profile-avatars` | Avatares de usuario |
| `event-images` | Imágenes de menús de catering |

---

## 8. Edge Functions

### `create-payment-intent`
- **Trigger**: Llamada desde `CheckoutRepository` en móvil (antes de mostrar Payment Sheet)
- **Acción**: Crea un `PaymentIntent` en Stripe y devuelve el `client_secret`
- **Secrets requeridos**: `STRIPE_SECRET_KEY`

### `send-order-notification`
- **Trigger**: Llamada desde `EmployeeOrdersRepository.updateOrderStatus()` al cambiar el estado de un pedido
- **Acción**: Envía en paralelo:
  - **Email** vía Brevo con plantilla HTML responsive (codificada por estado)
  - **Push notification** vía FCM a todos los tokens del usuario en `push_tokens`
- **Estados que disparan notificación**: `accepted`, `en_preparacion`, `ready`, `delivering`, `delivered`
- **Secrets requeridos**: `BREVO_API_KEY`, `BREVO_SENDER_EMAIL`, `FCM_SERVER_KEY`
- **Acepta dos formatos**: webhook de BD Supabase o llamada directa con `{orderId, newStatus, userId, orderType}`

---

## 9. Notificaciones

### Push (Android — FCM)
1. `bootstrap.dart` inicializa `Firebase` y llama a `_setupFcm()` en plataformas no-web
2. Se solicitan permisos con `FirebaseMessaging.instance.requestPermission()`
3. El token FCM se guarda en `push_tokens` con upsert sobre `(user_id, token)`
4. `auth_provider.dart` escucha `AuthChangeEvent.signedIn` y vuelve a guardar el token (para usuarios que inician sesión después del arranque de la app)
5. También se escucha `onTokenRefresh` para actualizar tokens rotados

### Email (Web y Android — Brevo)
- Enviado desde la Edge Function `send-order-notification`
- Template HTML con colores distintos por estado del pedido
- Se usa el email del usuario almacenado en `auth.users`

### Plataforma adaptativa en `OrderConfirmationScreen`
- Web → muestra banner azul: "Te enviaremos un correo electrónico..."
- Android → muestra banner naranja: "Te notificaremos..."

---

## 10. Pagos (Stripe)

### Móvil (Android)
- Flujo: `CheckoutScreen` → `checkoutSubmitProvider` → `CheckoutRepository.createOrder()` → Edge Function `create-payment-intent` → `Stripe.instance.presentPaymentSheet()` → `OrderConfirmationScreen`
- Inicializado en `bootstrap.dart` con `if (!kIsWeb)` para excluir web

### Web
- Flujo: `CheckoutScreen` → Stripe Checkout Session (redirección a `stripe.com`) → retorno a `/payment-success` → `PaymentSuccessScreen` crea el pedido → `OrderConfirmationScreen`
- `PaymentSuccessScreen` usa `checkoutRepositoryProvider` directamente (keepAlive) para evitar el error "Bad state: Future already completed"

---

## 11. Variables de entorno

Definidas en `lib/core/config/` y en los secrets de Supabase.

### Flutter (dart-define o config)
```
SUPABASE_URL=https://vrxliepwzvdrcxpdgpnd.supabase.co
SUPABASE_ANON_KEY=<tu-anon-key>
STRIPE_PUBLISHABLE_KEY=<pk_live/test_...>
```

### Supabase Edge Function Secrets
```
STRIPE_SECRET_KEY=sk_live/test_...
BREVO_API_KEY=xkeysib-...
BREVO_SENDER_EMAIL=noreply@sabordecasa.com
FCM_SERVER_KEY=<Firebase Server Key>
```

### Desplegar edge functions
```bash
supabase functions deploy create-payment-intent
supabase functions deploy send-order-notification

supabase secrets set STRIPE_SECRET_KEY=<valor>
supabase secrets set BREVO_API_KEY=<valor>
supabase secrets set BREVO_SENDER_EMAIL=noreply@sabordecasa.com
supabase secrets set FCM_SERVER_KEY=<valor>
```

---

## 12. Cómo ejecutar el proyecto

### Requisitos previos
- Flutter 3.38.6 (`flutter --version`)
- Android Studio + emulador Android (API 24+) o dispositivo físico
- Chrome instalado (para desarrollo web)
- `google-services.json` en `android/app/` (Firebase)

### Generar código automático (Riverpod, Freezed, GoRouter)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Ejecutar en web (Chrome)
```bash
flutter run -d chrome
```

### Ejecutar en Android
```bash
flutter run -d emulator-5554
# o
flutter run -d <id-dispositivo>
```

### Build de producción
```bash
# APK Android
flutter build apk --release

# Web (para Vercel)
flutter build web --release
```

---

## 13. Migraciones SQL

Ejecutar en orden en el SQL Editor de Supabase:

| Archivo | Contenido |
|---------|-----------|
| `00001_initial_schema.sql` | Enums, todas las tablas, RLS, triggers, funciones |
| `00002_sample_data.sql` | Categorías, platos, horarios y menús de catering de ejemplo |
| `00003_test_users.sql` | 3 usuarios de prueba (client, employee, admin) con contraseña conocida |
| `00004_encargo_config.sql` | Configuración de negocio para pedidos encargados (días de antelación, franjas horarias) |
| `00005_dishes_offer_seasonal.sql` | Campos `is_offer`, `is_seasonal`, `offer_price` en dishes; campo `cancellation_reason` en orders |

---

## 14. Changelog

### Admin CRUD Completo + UI moderna (sesiones 3-4)

**Nuevas dependencias:**
- `flutter_animate: ^4.5.2` — animaciones en listas y cards del panel admin

**Base de datos (migración 00005):**
- Tabla `dishes`: nuevos campos `is_offer BOOLEAN`, `is_seasonal BOOLEAN`, `offer_price NUMERIC(8,2) nullable`
- Tabla `orders`: nuevo campo `cancellation_reason TEXT`

**Modelos actualizados:**
- `Dish`: añadidos `isOffer`, `isSeasonal`, `offerPrice`

**Repositorio admin (`AdminRepository`):**
- `createDish` / `updateDish` / `deleteDish` (soft-delete)
- `getAllCategories` / `createCategory` / `updateCategory` / `deleteCategory` (soft-delete)
- `updateUserRole`
- `updateScheduleHours`
- `cancelOrderWithReason`

**Providers admin (`AdminProvider`):**
- Nuevo `adminCategoriesProvider`
- Métodos en `AdminAction`: createDish, updateDish, deleteDish, createCategory, updateCategory, deleteCategory, updateUserRole, updateScheduleHours, cancelOrderWithReason

**Rutas nuevas:**
- `/admin/categories` → `AdminCategoriesScreen`

**Nuevas pantallas / pantallas rediseñadas:**
- `AdminDishesScreen` — CRUD completo con GridView, form sheet con ImagePicker, badges oferta/temporada, alérgenos EU, animaciones staggered
- `AdminCategoriesScreen` — CRUD completo con ListView animado, form sheet, soft-delete
- `AdminScheduleScreen` — TimePicker para horas de apertura/cierre por día, toggle isOpen, diseño moderno
- `AdminUsersScreen` — Dropdown de rol (client/employee/admin), toggle isActive, avatares con colores por rol
- `AdminOrdersScreen` — FilterChips por estado y tipo, cards expandibles con detalle, diálogo cancelación con motivo
- `AdminDashboardScreen` — Añadido item "Categorías" en navegación, animaciones scale en stat cards

**Nuevo widget compartido:**
- `AllergenChips` (`lib/core/widgets/allergen_chips.dart`) — 14 alérgenos EU como FilterChips o badges read-only

> **Nota**: La tabla `push_tokens` requiere un índice único compuesto `(user_id, token)` para que el upsert funcione:
> ```sql
> ALTER TABLE push_tokens
>   ADD CONSTRAINT push_tokens_user_token_unique UNIQUE (user_id, token);
> ```

### Lint y calidad de código (sesión 5)

**`dart analyze lib` → 0 issues** (corregidos 31 problemas):
- `List<dynamic>` → `List<Category>` en `_DishFormSheet` (type safety)
- `activeColor` → `activeThumbColor` en todos los `Switch` y `SwitchListTile` (deprecado desde Flutter v3.31.0)
- `DropdownButtonFormField.value` → `initialValue` (deprecado desde Flutter v3.33.0)
- `AllergenChips`: parámetros required reordenados antes de opcionales; `onToggle` ahora no-nullable con firma `Function(String id, {required bool isSelected})`
- `prefer_const_constructors`: `_Badge`, `_SectionLabel`, `ColoredBox` marcados como `const`
- `dead_null_aware_expression`: eliminado `?? bytes` innecesario en `AdminRepository.compressWithList`
- Finales de línea (`eol_at_end_of_file`): 5 ficheros convertidos a LF puro con trailing newline

---

## 14. Roles de usuario

| Rol | Login de prueba | Contraseña |
|-----|----------------|------------|
| `client` | client@sabordecasa.com | Test1234! |
| `employee` | employee@sabordecasa.com | Test1234! |
| `admin` | admin@sabordecasa.com | Test1234! |

*(Creados por `00003_test_users.sql`)*

---

## 15. Tipos de pedido

| Tipo | Descripción | QR | Notificación |
|------|-------------|-----|--------------|
| `mostrador` | Venta en caja, pago efectivo/tarjeta | No | No (anónimo) |
| `encargo` | Pedido para fecha futura | Sí | Email + Push |
| `domicilio` | Entrega a domicilio hoy | No | Email + Push |
| `recogida` | Recogida en local hoy/futura | Sí | Email + Push |

El QR se muestra en `OrderConfirmationScreen` y `OrderDetailScreen` para que el empleado lo escanee con `ScannerScreen` al entregar el pedido.

---

## 16. Changelog de implementación

### v0.1 — Scaffolding inicial
- Estructura de carpetas por feature (data/domain/presentation)
- Configuración de Riverpod, Freezed, GoRouter
- Tema claro/oscuro con `ThemeProvider`
- `ScaffoldWithNavBar` como shell de navegación

### v0.2 — Auth + Onboarding
- `SplashScreen` con redirección inteligente (onboarding / home)
- `OnboardingScreen` (saltado en web)
- `LoginScreen`, `RegisterScreen` con validación
- `AuthNotifier` (keepAlive) con `watchAuthState()`
- Protección de rutas en `app_router.dart`

### v0.3 — Menú y carrito
- Listado de platos con filtrado por categoría
- `DishDetailScreen` con alérgenos
- `DailySpecialBanner` con countdown
- Carrito persistente con `CartNotifier`
- `CartScreen` y `CheckoutScreen` con selector de tipo de pedido

### v0.4 — Pagos Stripe
- Edge Function `create-payment-intent` (Deno)
- Payment Sheet en Android
- Stripe Checkout redirect en Web
- `PaymentSuccessScreen` con polling de sesión y creación de pedido

### v0.5 — Confirmación y pedidos
- `OrderConfirmationScreen` con Lottie, QR, información de notificación
- `OrdersScreen` e `OrderDetailScreen` con historial completo
- Generación de ticket PDF con `pdf` + `printing`

### v0.6 — Kitchen + Notificaciones
- `KitchenScreen` con listado en tiempo real (Supabase Realtime)
- `EmployeeOrdersRepository.updateOrderStatus()` llama a Edge Function
- Edge Function `send-order-notification` (Brevo email + FCM push)
- `bootstrap.dart`: inicialización Firebase + registro token FCM
- `auth_provider.dart`: registro de token FCM en `signedIn` event

### v0.7 — Admin
- Dashboard con estadísticas
- CRUD de platos, categorías, horarios
- Gestión de solicitudes de catering
- Gestión de usuarios y roles

### v0.8 — Features avanzadas
- Chat IA con Gemini (`ChatScreen`)
- Pedido por voz (`speech_to_text`)
- Pedido grupal en tiempo real (`GroupOrderScreen`)
- Escáner QR en pantalla de reparto (`ScannerScreen`)
- TPV para mostrador (`PosScreen`)

### v0.9 — Imágenes de platos (admin)
- Añadido `image_picker: ^1.1.2` para seleccionar imágenes desde galería (Android + Web)
- Añadidos permisos Android: `READ_MEDIA_IMAGES` (≥ API 33) + `READ_EXTERNAL_STORAGE` (≤ API 32)
- `AdminRepository.uploadDishImage()`: comprime a WebP con `flutter_image_compress` (solo móvil), sube al bucket `dish-images` de Supabase Storage con `upsert: true`
- `AdminRepository.updateDishImageUrl()`: actualiza la columna `image_url` de la tabla `dishes`
- `AdminAction.uploadDishImage()`: orquesta subida + actualización, invalida `adminDishesProvider`
- `AdminDishesScreen` rediseñado: cada plato muestra miniatura 60×60 (con `CachedNetworkImage`) + botón `camera_alt` para subir nueva imagen + switch de disponibilidad
- Las tarjetas de home (`_TopDishCard`, `DishCard`) ya mostraban `imageUrl` vía `CachedNetworkImage` — ahora se visualizan correctamente al tener URL real en BD
