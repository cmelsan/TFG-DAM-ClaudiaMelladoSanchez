# Supabase — Base de Datos, RLS y Edge Functions

Documentación técnica completa del backend del proyecto **Sabor de Casa**.

- **URL del proyecto**: `https://vrxliepwzvdrcxpdgpnd.supabase.co`
- **Región**: eu-central-1 (Europa)

---

## Índice

1. [Tipos ENUM](#1-tipos-enum)
2. [Esquema de tablas](#2-esquema-de-tablas)
3. [Índices](#3-índices)
4. [Funciones y Triggers](#4-funciones-y-triggers)
5. [Row Level Security (RLS)](#5-row-level-security-rls)
6. [Buckets de Storage](#6-buckets-de-storage)
7. [Edge Functions](#7-edge-functions)
8. [Migraciones SQL](#8-migraciones-sql)
9. [Notas de mantenimiento](#9-notas-de-mantenimiento)

---

## 1. Tipos ENUM

```sql
CREATE TYPE user_role           AS ENUM ('client', 'employee', 'admin');
CREATE TYPE order_type          AS ENUM ('mostrador', 'encargo', 'domicilio', 'recogida');
CREATE TYPE order_status        AS ENUM ('pending', 'confirmed', 'preparing', 'ready',
                                         'delivering', 'delivered', 'cancelled');
CREATE TYPE payment_status      AS ENUM ('pending', 'paid', 'refunded');
CREATE TYPE payment_method      AS ENUM ('card', 'cash', 'online', 'tpv');
CREATE TYPE event_request_status AS ENUM ('pending', 'quoted', 'accepted', 'rejected', 'completed');
```

---

## 2. Esquema de tablas

### `profiles`
Extiende `auth.users`. Se crea automáticamente via trigger al registrarse.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | Referencia a `auth.users(id)` ON DELETE CASCADE |
| `email` | TEXT NOT NULL | Email del usuario |
| `role` | user_role | DEFAULT `'client'` |
| `full_name` | TEXT | Nombre completo |
| `phone` | TEXT | Teléfono |
| `avatar_url` | TEXT | URL del avatar en Storage |
| `is_active` | BOOLEAN | DEFAULT TRUE |
| `created_at` | TIMESTAMPTZ | Auto |
| `updated_at` | TIMESTAMPTZ | Auto (trigger) |

---

### `addresses`
Direcciones de entrega por usuario.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | |
| `label` | TEXT | DEFAULT `'Casa'` |
| `street` | TEXT | Calle y número |
| `city` | TEXT | DEFAULT `'Huelva'` |
| `postal_code` | TEXT | |
| `notes` | TEXT | Instrucciones adicionales |
| `is_default` | BOOLEAN | DEFAULT FALSE |
| `created_at` | TIMESTAMPTZ | |

---

### `categories`
Categorías del menú (entrantes, principales, postres, etc.).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `name` | TEXT UNIQUE | |
| `description` | TEXT | |
| `image_url` | TEXT | URL en Storage |
| `sort_order` | INT | Para ordenar en la carta |
| `is_active` | BOOLEAN | DEFAULT TRUE |
| `created_at` | TIMESTAMPTZ | |

---

### `dishes`
Platos del menú.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `category_id` | UUID FK → categories | ON DELETE RESTRICT |
| `name` | TEXT | |
| `description` | TEXT | DEFAULT `''` |
| `price` | NUMERIC(8,2) | CHECK >= 0 |
| `image_url` | TEXT | URL en Storage |
| `allergens` | TEXT[] | Array de alérgenos |
| `prep_time_min` | INT | Tiempo de preparación en minutos |
| `is_available` | BOOLEAN | Disponible hoy |
| `is_active` | BOOLEAN | Visible en carta |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | Auto (trigger) |

---

### `daily_special`
Menú del día con descuento opcional. Un único plato por fecha (`UNIQUE(date)`).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `dish_id` | UUID FK → dishes | |
| `date` | DATE UNIQUE | |
| `discount_percent` | INT | CHECK 0–100 |
| `note` | TEXT | Mensaje especial del día |
| `primero_text` | TEXT | Texto libre para menú de mediodía (primer plato) |
| `segundo_text` | TEXT | Texto libre para menú de mediodía (segundo plato) |
| `postre_text` | TEXT | Texto libre para menú de mediodía (postre) |
| `bebida_text` | TEXT | Texto libre para bebida incluida |
| `menu_price` | NUMERIC(8,2) | Precio menú del día |
| `image_url` | TEXT | Imagen específica del menú del día |
| `created_at` | TIMESTAMPTZ | |

---

### `schedule`
Horarios del local por día de la semana. `day_of_week`: 0=Domingo … 6=Sábado.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `day_of_week` | INT UNIQUE | CHECK 0–6 |
| `open_time` | TIME | |
| `close_time` | TIME | |
| `is_open` | BOOLEAN | DEFAULT TRUE |

---

### `orders`
Pedidos de clientes.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | NULL para pedidos mostrador |
| `order_type` | order_type | `mostrador | encargo | domicilio | recogida` |
| `status` | order_status | DEFAULT `'pending'` |
| `payment_status` | payment_status | DEFAULT `'pending'` |
| `payment_method` | payment_method | `card | cash | online | tpv` |
| `subtotal` | NUMERIC(10,2) | Sin gastos de envío |
| `delivery_fee` | NUMERIC(6,2) | Gastos de envío |
| `total` | NUMERIC(10,2) | Total final |
| `address_id` | UUID FK → addresses | Solo para `domicilio` |
| `scheduled_at` | TIMESTAMPTZ | Para `encargo` y `recogida` futura |
| `notes` | TEXT | Notas del cliente |
| `assigned_driver_id` | UUID FK → profiles | Repartidor asignado |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | Auto (trigger) |

---

### `order_items`
Líneas de cada pedido.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `order_id` | UUID FK → orders | ON DELETE CASCADE |
| `dish_id` | UUID FK → dishes | ON DELETE RESTRICT |
| `quantity` | INT | CHECK > 0 |
| `unit_price` | NUMERIC(8,2) | Precio en el momento del pedido |
| `subtotal` | NUMERIC(10,2) | `quantity * unit_price` |
| `notes` | TEXT | Modificaciones del plato |

---

### `order_ratings`
Valoraciones de pedidos entregados (1 por pedido, `UNIQUE(order_id)`).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `order_id` | UUID FK → orders | UNIQUE |
| `user_id` | UUID FK → profiles | |
| `rating` | INT | CHECK 1–5 |
| `comment` | TEXT | |
| `created_at` | TIMESTAMPTZ | |

---

### `favorites`
Platos favoritos por usuario (`UNIQUE(user_id, dish_id)`).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | |
| `dish_id` | UUID FK → dishes | |
| `created_at` | TIMESTAMPTZ | |

---

### `event_menus`
Menús disponibles para catering.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `name` | TEXT | |
| `description` | TEXT | |
| `price_per_person` | NUMERIC(8,2) | |
| `min_guests` | INT | DEFAULT 10 |
| `max_guests` | INT | DEFAULT 200 |
| `image_url` | TEXT | |
| `event_kind` | TEXT | Tipo funcional: `small`, `family`, `communion`, `wedding`, `business`, `custom` |
| `lead_time_months` | INT | Antelación mínima: 1, 6 u 8 meses |
| `tasting_available` | BOOLEAN | Indica si se puede concertar prueba de menú |
| `highlight_label` | TEXT | Etiqueta destacada para cliente/admin |
| `is_active` | BOOLEAN | DEFAULT TRUE |
| `created_at` | TIMESTAMPTZ | |

---

### `event_menu_courses`
Platos dentro de un menú de catering.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `event_menu_id` | UUID FK → event_menus | ON DELETE CASCADE |
| `course_type` | TEXT | `entrante | principal | postre | bebida` |
| `name` | TEXT | |
| `description` | TEXT | |
| `sort_order` | INT | DEFAULT 0 |

---

### `event_extras`
Servicios extras para catering (DJ, decoración, etc.).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `name` | TEXT | |
| `description` | TEXT | |
| `price` | NUMERIC(8,2) | |
| `is_active` | BOOLEAN | DEFAULT TRUE |

---

### `event_requests`
Solicitudes de catering enviadas por clientes.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | |
| `event_menu_id` | UUID FK → event_menus | |
| `event_date` | DATE | |
| `guest_count` | INT | CHECK > 0 |
| `location` | TEXT | Lugar del evento |
| `notes` | TEXT | |
| `status` | event_request_status | DEFAULT `'pending'` |
| `quoted_total` | NUMERIC(10,2) | Precio final cotizado por admin |
| `admin_notes` | TEXT | Respuesta del admin |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | Auto (trigger) |

---

### `event_request_selections`
Platos seleccionados por el cliente en su solicitud de catering.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `event_request_id` | UUID FK → event_requests | ON DELETE CASCADE |
| `event_menu_course_id` | UUID FK → event_menu_courses | |
| — | UNIQUE | `(event_request_id, event_menu_course_id)` |

---

### `event_request_extras`
Extras seleccionados en una solicitud de catering.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `event_request_id` | UUID FK → event_requests | ON DELETE CASCADE |
| `event_extra_id` | UUID FK → event_extras | |
| `quantity` | INT | DEFAULT 1, CHECK > 0 |
| — | UNIQUE | `(event_request_id, event_extra_id)` |

---

### `event_calendar`
Fechas bloqueadas por eventos de catering confirmados.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `event_request_id` | UUID FK → event_requests | UNIQUE |
| `date` | DATE | |
| `title` | TEXT | |
| `notes` | TEXT | |

---

### `contact_messages`
Mensajes recibidos desde el formulario de contacto.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `name` | TEXT | |
| `email` | TEXT | |
| `phone` | TEXT | |
| `subject` | TEXT | |
| `message` | TEXT | |
| `is_read` | BOOLEAN | DEFAULT FALSE |
| `created_at` | TIMESTAMPTZ | |

---

### `support_threads`
Conversaciones internas entre clientes registrados y administracion.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | Cliente propietario |
| `subject` | TEXT | Asunto visible en la bandeja |
| `category` | TEXT | `general`, `order`, `catering`, `incident` |
| `status` | TEXT | `open`, `waiting_admin`, `waiting_customer`, `closed` |
| `last_message` | TEXT | Resumen del ultimo mensaje |
| `last_message_at` | TIMESTAMPTZ | Ordenacion de bandeja |
| `unread_for_admin` | INTEGER | Contador de no leidos admin |
| `unread_for_customer` | INTEGER | Contador de no leidos cliente |
| `created_at` | TIMESTAMPTZ | |
| `updated_at` | TIMESTAMPTZ | |

---

### `support_messages`
Mensajes pertenecientes a cada hilo de soporte interno.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `thread_id` | UUID FK → support_threads | ON DELETE CASCADE |
| `sender_id` | UUID FK → profiles | Usuario que envia |
| `sender_role` | TEXT | `client` o `admin` |
| `body` | TEXT | Cuerpo del mensaje |
| `created_at` | TIMESTAMPTZ | |

---

### `testimonials`
Reseñas / testimonios mostrados en la home pública. Gestionables desde el panel admin.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `author_name` | TEXT NOT NULL | Nombre visible del autor |
| `body` | TEXT NOT NULL | Texto de la reseña |
| `rating` | INTEGER | 1..5 (estrellas) |
| `is_featured` | BOOLEAN | DEFAULT FALSE — Si aparece en la home |
| `position` | INTEGER | DEFAULT 0 — Orden de visualización |
| `created_at` | TIMESTAMPTZ | Auto |

Definida en `00019_testimonials.sql`. Ampliada por usos del panel admin (`adminTestimonialsProvider`).

---

### `newsletter_subscribers`
Suscriptores opt-in del formulario público de newsletter (pie de `/contact`).

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | DEFAULT `gen_random_uuid()` |
| `email` | TEXT UNIQUE | Email del suscriptor |
| `full_name` | TEXT | Nombre opcional |
| `status` | TEXT | CHECK `active | unsubscribed | bounced`, DEFAULT `'active'` |
| `source` | TEXT | DEFAULT `'web'` — Origen de la alta (`web`, `contact_page`, `admin`, ...) |
| `locale` | TEXT | DEFAULT `'es'` |
| `user_id` | UUID FK → profiles | ON DELETE SET NULL (si el usuario también es cliente registrado) |
| `created_at` | TIMESTAMPTZ | Auto |
| `unsubscribed_at` | TIMESTAMPTZ | Fecha de baja (NULL si activo) |

Índices:
```sql
idx_newsletter_status     → newsletter_subscribers(status)
idx_newsletter_created_at → newsletter_subscribers(created_at DESC)
```

Definida en `00028_newsletter_subscribers.sql` — **aplicar en Studio SQL Editor**.

---

### `push_tokens`
Tokens FCM de dispositivos Android para notificaciones push.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `user_id` | UUID FK → profiles | ON DELETE CASCADE |
| `token` | TEXT | Token FCM del dispositivo |
| `platform` | TEXT | CHECK `android | web` |
| `created_at` | TIMESTAMPTZ | |
| — | UNIQUE | `(user_id, token)` — requerido para upsert |

> **Nota**: La clave única `(user_id, token)` está definida en `00001_initial_schema.sql` como `UNIQUE(user_id, token)`. Si la tabla fue creada sin esta restricción, ejecutar:
> ```sql
> ALTER TABLE push_tokens ADD CONSTRAINT push_tokens_user_token_unique UNIQUE (user_id, token);
> ```

---

### `business_config`
Configuración del negocio en formato clave-valor.

| Columna | Tipo | Descripción |
|---------|------|-------------|
| `id` | UUID PK | |
| `key` | TEXT UNIQUE | Nombre de la configuración |
| `value` | TEXT | Valor de la configuración |
| `updated_at` | TIMESTAMPTZ | Auto (trigger) |

**Claves conocidas**:
| Key | Valor por defecto | Descripción |
|-----|------------------|-------------|
| `encargo_min_days_advance` | `'2'` | Días mínimos de antelación para pedidos encargados |

---

## 3. Índices

```sql
idx_addresses_user_id          → addresses(user_id)
idx_dishes_category_id         → dishes(category_id)
idx_dishes_is_available        → dishes(is_available) WHERE is_active = TRUE
idx_daily_special_date         → daily_special(date)
idx_orders_user_id             → orders(user_id)
idx_orders_status              → orders(status)
idx_orders_created_at          → orders(created_at DESC)
idx_orders_assigned_driver     → orders(assigned_driver_id) WHERE NOT NULL
idx_order_items_order_id       → order_items(order_id)
idx_favorites_user_id          → favorites(user_id)
idx_event_requests_user_id     → event_requests(user_id)
idx_event_requests_status      → event_requests(status)
idx_contact_messages_is_read   → contact_messages(is_read)
idx_support_threads_user_id    → support_threads(user_id)
idx_support_threads_status     → support_threads(status)
idx_support_threads_last_message_at → support_threads(last_message_at DESC)
idx_support_messages_thread_id_created → support_messages(thread_id, created_at)
idx_push_tokens_user_id        → push_tokens(user_id)
```

---

## 4. Funciones y Triggers

### `update_updated_at()` — Trigger genérico
Actualiza `updated_at = now()` antes de cada UPDATE.

**Aplicado a**: `profiles`, `dishes`, `orders`, `event_requests`, `business_config`

### `handle_new_user()` — Trigger de registro
Al insertar en `auth.users`, crea automáticamente un perfil en `profiles` con `role = 'client'`.

**Trigger**: `on_auth_user_created` → AFTER INSERT ON `auth.users`

### `get_my_role()` — Función helper RLS
```sql
SELECT role FROM profiles WHERE id = auth.uid();
```
Usada en las políticas RLS para verificar el rol del usuario autenticado.

---

## 5. Row Level Security (RLS)

RLS habilitado en **todas** las tablas. Resumen de políticas:

### `profiles`
- `SELECT`: el propio usuario ó empleados/admin
- `UPDATE`: el propio usuario (sin poder cambiar su `role`) ó admin

### `addresses`
- `SELECT/INSERT/UPDATE/DELETE`: solo el propio usuario (`user_id = auth.uid()`)

### `categories` / `dishes`
- `SELECT`: todos ven los activos; admin ve todos
- `ALL` (write): solo admin

### `daily_special` / `schedule`
- `SELECT`: público (cualquiera)
- `ALL` (write): solo admin

### `orders`
- `SELECT`: cliente ve los suyos; empleado/admin ve todos
- `INSERT`: cualquier usuario autenticado
- `UPDATE`: solo empleado/admin
- `DELETE`: solo admin

### `order_items`
- `SELECT`: items del propio pedido ó empleado/admin
- `INSERT`: cualquier usuario autenticado
- `ALL` (write): empleado/admin

### `order_ratings`
- `SELECT`: propio usuario ó admin
- `INSERT`: solo para pedidos propios con status `delivered`

### `favorites`
- `SELECT/INSERT/DELETE`: solo el propio usuario

### `event_menus` / `event_menu_courses` / `event_extras`
- `SELECT`: público (activos)
- `ALL` (write): solo admin

### `event_requests`
- `SELECT`: el solicitante ó admin
- `INSERT`: usuario autenticado
- `UPDATE`: solo admin

### `event_request_selections` / `event_request_extras`
- `SELECT/INSERT/DELETE`: el dueño de la solicitud ó admin

### `event_calendar`
- `SELECT`: público (todos pueden ver fechas bloqueadas)
- `ALL` (write): solo admin

### `contact_messages`
- `INSERT`: anónimo permitido (no requiere auth)
- `SELECT/UPDATE`: solo admin

### `support_threads`
- `SELECT`: propietario del hilo o admin
- `INSERT`: cliente autenticado creando su propio hilo
- `UPDATE`: propietario del hilo o admin

### `support_messages`
- `SELECT`: propietario del hilo o admin
- `INSERT`: cliente propietario del hilo o admin

### `testimonials`
- `SELECT`: público (cualquiera puede leer los testimonios para mostrarlos en la home)
- `ALL` (write): solo admin

### `newsletter_subscribers`
- `INSERT`: público (cualquiera puede suscribirse, incluso anónimo)
- `SELECT/UPDATE/DELETE`: solo admin (usando `get_my_role() = 'admin'`)

### `push_tokens`
- `SELECT/INSERT/UPDATE/DELETE`: el propio usuario

### `business_config`
- `SELECT`: público (lectura libre)
- `ALL` (write): solo admin

---

## 6. Buckets de Storage

| Bucket | Acceso público | Uso |
|--------|---------------|-----|
| `dish-images` | Sí | Fotos de platos del menú |
| `category-images` | Sí | Fotos de categorías |
| `profile-avatars` | No | Avatares de usuario (acceso autenticado) |
| `event-images` | Sí | Imágenes de menús de catering |

---

## 7. Edge Functions

### `create-payment-intent`
**Ruta**: `POST /functions/v1/create-payment-intent`

**Propósito**: Crea un `PaymentIntent` en Stripe para el flujo de Payment Sheet en Android.

**Payload**:
```json
{
  "amount": 1250,
  "currency": "eur",
  "metadata": {
    "order_type": "domicilio",
    "user_id": "uuid"
  }
}
```

**Respuesta**:
```json
{
  "client_secret": "pi_xxx_secret_xxx",
  "publishable_key": "pk_..."
}
```

**Secrets requeridos**:
- `STRIPE_SECRET_KEY` — clave secreta de Stripe (`sk_live_...` o `sk_test_...`)

---

### `send-order-notification`
**Ruta**: `POST /functions/v1/send-order-notification`

**Propósito**: Notifica al cliente cuando el estado de su pedido cambia a un estado relevante. Envía email (Brevo) y/o push (FCM) en paralelo.

**Estados que disparan notificación**:
- `accepted` → "¡Tu pedido ha sido aceptado!"
- `en_preparacion` → "Tu pedido está en preparación"
- `ready` → "¡Listo para recoger!" o "Saliendo para entrega"
- `delivering` → "Tu pedido está en camino"
- `delivered` → "¡Pedido entregado!"

**Payload (llamada directa desde Flutter)**:
```json
{
  "orderId": "uuid",
  "newStatus": "ready",
  "orderType": "recogida",
  "userId": "uuid"
}
```

**Payload alternativo (Supabase Database Webhook)**:
```json
{
  "type": "UPDATE",
  "record": {
    "id": "uuid",
    "status": "ready",
    "order_type": "recogida",
    "user_id": "uuid"
  }
}
```

**Flujo interno**:
1. Normaliza payload (soporta ambos formatos)
2. Si `newStatus` no está en `NOTIFY_STATUSES` → devuelve 200 sin hacer nada
3. Consulta `profiles` para obtener `full_name`
4. Consulta `push_tokens` para obtener tokens FCM del usuario
5. Obtiene email desde `supabase.auth.admin.getUserById(userId)`
6. Envía push a todos los tokens FCM en paralelo (best-effort)
7. Envía email Brevo con template HTML responsive (best-effort)
8. Devuelve resumen `{ emailSent, pushSent, pushTokenCount }`

**Secrets requeridos**:
- `BREVO_API_KEY` — API Key de Brevo
- `BREVO_SENDER_EMAIL` — Email del remitente (ej. `noreply@sabordecasa.com`)
- `FCM_SERVER_KEY` — Server Key de Firebase Cloud Messaging

**Llamada desde Flutter** (`employee_orders_repository.dart`):
```dart
_client.functions.invoke(
  'send-order-notification',
  body: {
    'orderId': orderId,
    'newStatus': newStatus,
    'userId': userId,
    'orderType': orderType,
  },
).catchError((_) {});  // best-effort, no bloquea el flujo
```

---

### `send-encargo-confirmation`
**Ruta**: `POST /functions/v1/send-encargo-confirmation`

**Propósito**: Envía email Brevo al cliente confirmando la creación de un encargo con fecha y franja horaria. Se dispara desde Flutter inmediatamente tras crear el pedido tipo `encargo`.

**Payload**: `{ orderId, userId, pickupDate, pickupSlot }`

---

### `send-encargo-reminders`
**Ruta**: `POST /functions/v1/send-encargo-reminders`

**Propósito**: Trabajo programable (cron) que recorre los encargos pendientes con recogida en las próximas 24 h y envía recordatorios por email y push. Pensado para invocar vía Scheduled Function.

---

### `send-catering-notification`
**Ruta**: `POST /functions/v1/send-catering-notification`

**Propósito**: Notifica al cliente cambios de estado de su solicitud de catering (`quoted`, `accepted`, `rejected`, `completed`). Envía email Brevo con el presupuesto adjunto cuando el admin marca como `quoted`.

**Payload**: `{ requestId, newStatus, userId }`

---

### `send-newsletter`
**Ruta**: `POST /functions/v1/send-newsletter`

**Propósito**: Envía una campaña de newsletter en lote a todos los suscriptores con `status = 'active'`. Acepta el HTML / asunto / segmentación opcional desde el panel admin. Usa Brevo para el envío masivo.

**Payload**: `{ subject, html, segment? }`

**Secrets requeridos**: `BREVO_API_KEY`, `BREVO_SENDER_EMAIL`.

---

### `send-welcome-email`
**Ruta**: `POST /functions/v1/send-welcome-email`

**Propósito**: Email de bienvenida tras el registro de un nuevo cliente. Se invoca desde el `auth.signUp` de Flutter (o desde un trigger de BD) con `{ userId, email, fullName }`.

---

### `chat-bot`
**Ruta**: `POST /functions/v1/chat-bot`

**Propósito**: Backend del asistente conversacional de la app (sugerencias de menú, dudas de pedidos, recomendaciones por alérgenos). Recibe el historial reciente y devuelve la respuesta del modelo.

**Payload**: `{ messages: [{ role, content }], userId? }`

**Respuesta**: `{ reply, suggestedDishes?: [uuid] }`

---

## 8. Migraciones SQL

Ejecutar en orden en el SQL Editor de Supabase (**Dashboard → SQL Editor**). El CLI `supabase db push` puede estar bloqueado por desfase de historial; en ese caso aplicar manualmente cada SQL en el editor.

| Orden | Archivo | Contenido |
|-------|---------|-----------|
| 1 | `00001_initial_schema.sql` | ENUMs, todas las tablas iniciales, índices, triggers, funciones, RLS completo |
| 2 | `00002_sample_data.sql` | Categorías, platos, horarios y menús de catering de demostración |
| 3 | `00003_test_users.sql` | Asigna roles a usuarios de prueba creados en el dashboard |
| 4 | `00004_encargo_config.sql` | Inserta `encargo_min_days_advance = '2'` en `business_config` |
| 5 | `00005_dishes_offer_seasonal.sql` | Añade columnas `is_offer`, `is_seasonal`, `offer_price` a `dishes` |
| 6 | `00006_sample_offers.sql` | Datos de ejemplo para ofertas |
| 7 | `00007_offers_section_config.sql` | Configuración de la sección Ofertas en home |
| 8 | `00008_seasonal_section_config.sql` | Configuración de la sección Temporada en home |
| 9 | `00009_extend_daily_special.sql` | Amplía el modelo `daily_special` (descripción, multi-plato) |
| 10 | `00010_create_subscriptions.sql` | Tabla `subscriptions` para alertas/avisos |
| 11 | `00011_daily_special_image_url.sql` | Campo `image_url` en `daily_special` |
| 12 | `00012_storage_update_policy.sql` | Políticas adicionales sobre buckets de Storage |
| 13 | `00013_first_order_discount.sql` | Lógica de descuento para el primer pedido |
| 14 | `00014_orders_discount_column.sql` | Columna `discount` en `orders` |
| 15 | `00015_email_webhooks.sql` | Triggers para webhooks de email transaccional |
| 16 | `00016_accepting_orders.sql` | Flag global `accepting_orders` para abrir/cerrar pedidos |
| 17 | `00017_fix_order_email_trigger.sql` | Hotfix del trigger de email de pedidos |
| 18 | `00018_add_tpv_payment_method.sql` | Añade método de pago `tpv` |
| 19 | `00019_testimonials.sql` | Tabla `testimonials` (reseñas en home) |
| 20 | `00020_notifications.sql` | Configuración / preferencias de notificaciones |
| 21 | `00021_orders_date_indexes.sql` | Índices adicionales por fecha en `orders` |
| 22 | `00022_order_display_ids.sql` | Campo `display_id` (identificador corto humano) en `orders` |
| 23 | `00023_catering_menus_and_requests.sql` | Refuerzo de menús de catering y solicitudes |
| 24 | `00024_detailed_catering_menus.sql` | Menús de catering detallados por curso |
| 25 | `00025_rename_categories_caseras.sql` | Renombrado de categorías "caseras" |
| 26 | `00026_catering_event_rules_and_menus.sql` | Reglas de eventos y menús asociados |
| 27 | `00027_support_threads_messages.sql` | Tablas `support_threads` y `support_messages` |
| 28 | `00028_newsletter_subscribers.sql` | Tabla `newsletter_subscribers` (opt-in público) |
| 29 | `00029_contact_messages_email_webhook.sql` | Flujo de notificación por email para mensajes de contacto |
| 30 | `00030_profiles_allergens.sql` | Campos de alérgenos/perfil en `profiles` |
| 31 | `00031_rls_counters.sql` | Ajustes de contadores y endurecimiento de políticas RLS |
| 32 | `00032_secure_counter_triggers.sql` | Triggers seguros para actualización de contadores |

**Usuarios de prueba** (crear primero en Dashboard → Authentication → Add User con "Auto Confirm"):

| Email | Contraseña | Rol |
|-------|-----------|-----|
| admin@sabordecasa.com | Admin1234! | admin |
| cocina@sabordecasa.com | Cocina1234! | employee |
| repartidor@sabordecasa.com | Repartidor1234! | employee |
| cliente@sabordecasa.com | Cliente1234! | client |

---

## 9. Notas de mantenimiento

### Desplegar Edge Functions
```bash
supabase functions deploy create-payment-intent
supabase functions deploy newsletter-unsubscribe
supabase functions deploy send-contact-notification
supabase functions deploy send-order-notification
supabase functions deploy send-encargo-confirmation
supabase functions deploy send-encargo-reminders
supabase functions deploy send-catering-notification
supabase functions deploy send-newsletter
supabase functions deploy send-newsletter-campaign
supabase functions deploy send-newsletter-welcome
supabase functions deploy send-welcome-email
supabase functions deploy chat-bot
```

### Configurar secrets
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set BREVO_API_KEY=xkeysib-...
supabase secrets set BREVO_SENDER_EMAIL=noreply@sabordecasa.com
supabase secrets set FCM_SERVER_KEY=AAAA...
```

### Constraint para `push_tokens` (si no existe)
```sql
-- Verificar si existe la restricción
SELECT conname FROM pg_constraint
WHERE conrelid = 'push_tokens'::regclass AND contype = 'u';

-- Si no existe, crearla
ALTER TABLE push_tokens
  ADD CONSTRAINT push_tokens_user_token_unique UNIQUE (user_id, token);
```

### Regenerar tipos Dart tras cambios en el esquema
Después de modificar el esquema de BD, regenerar los modelos Freezed y providers:
```bash
dart run build_runner build --delete-conflicting-outputs
```
