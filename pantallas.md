# Mapa de Pantallas — Proyecto Final DAM

## Resumen

| Rol | Pantallas | Plataforma |
|-----|-----------|-----------|
| Cliente | 16 | Android + Web |
| Empleado | 6 | Android + Web |
| Admin | 14 | Web + Android |
| **TOTAL** | **36** | |

---

## 5 Líneas de Servicio

| # | Servicio | Quién lo inicia | Ejemplo |
|---|----------|-----------------|---------|
| 1 | **Venta diaria (mostrador)** | Cliente va al local | "Dame 2 croquetas y una lasaña para hoy" |
| 2 | **Encargo programado** | Cliente (app/web) | "Quiero paella para 10 personas el viernes a las 14h" |
| 3 | **Domicilio** | Cliente (app/web) | "Quiero que me traigáis la cena hoy a las 21h" |
| 4 | **Catering de eventos** | Cliente (app/web) | "Necesito menú de comunión para 80 personas el 15 de junio" |
| 5 | **Consultas / Contacto** | Cualquiera (app/web) | "¿Hacéis menús para empresas?", "¿Necesitáis repartidor?" |

---

## 4 Tipos de Pedido en BD

```
orders.type = 'mostrador' | 'encargo' | 'domicilio' | 'recogida'
```

| Campo | mostrador | encargo | domicilio | recogida |
|-------|-----------|---------|-----------|----------|
| Cliente registrado | No (anónimo) | Sí | Sí | Sí |
| Fecha/hora futura | No (ahora) | Sí | Sí (hoy) | Sí |
| Dirección | No | No | Sí | No |
| Pago online | No (efectivo/tarjeta física) | Sí (Stripe) | Sí (Stripe) | Sí (Stripe o en local) |
| QR recogida | No | Sí | No | Sí |
| Quien lo crea | Empleado | Cliente | Cliente | Cliente |

---

## Navegación sin registro

| Acción | ¿Requiere registro? |
|--------|---------------------|
| Ver menú completo (platos, fotos, precios, alérgenos) | **No** |
| Ver plato del día con countdown | **No** |
| Ver menús de catering/eventos | **No** |
| Buscar platos (texto y voz) | **No** |
| Ver horarios, dirección, info del negocio | **No** |
| Enviar consulta/contacto | **No** (solo pide email en formulario) |
| Usar el chatbot IA | **No** |
| Añadir al carrito | **No** (carrito local) |
| **Hacer checkout / pagar** | **Sí** → salta login/registro |
| Marcar favoritos | **Sí** |
| Ver historial de pedidos | **Sí** |
| Repetir pedido | **Sí** |
| Solicitar catering | **Sí** |
| Pedido grupal | **Sí** |
| Configurar alérgenos en perfil | **Sí** |
| Valorar pedido | **Sí** |

---

## ROL 1: CLIENTE (16 pantallas — Android + Web)

| # | Pantalla | Descripción |
|---|----------|-------------|
| 1.1 | **Splash / Onboarding** | Logo + 3 slides explicativos (solo primera vez) |
| 1.2 | **Login / Registro** | Email+contraseña o Google. Supabase Auth |
| 1.3 | **Home** | Plato del día con countdown, categorías, sección "Para ti" (recomendador IA), acceso rápido a repetir último pedido, banner de novedades |
| 1.4 | **Catálogo / Menú** | Lista de categorías → platos con foto, precio, alérgenos, descripción. Filtros (sin gluten, vegetariano, etc.). Búsqueda por texto y por voz |
| 1.5 | **Detalle de plato** | Foto grande, descripción, alérgenos destacados, precio, botón añadir al carrito con cantidad. Alerta si coincide con alérgenos del perfil |
| 1.6 | **Carrito** | Lista de platos, cantidades, subtotales, total. Elegir tipo: Recogida (fecha/hora) o Domicilio (dirección + fecha/hora). Notas especiales |
| 1.7 | **Checkout / Pago** | Resumen + pasarela Stripe (tarjeta) o "Pago en local" (solo recogida). Confirmación |
| 1.8 | **Mis pedidos** | Historial con estado (pendiente → confirmado → preparando → listo → entregado). Filtro por estado |
| 1.9 | **Detalle de pedido** | Estado con animación Lottie, productos, total, QR de recogida, descarga ticket PDF, valorar (estrellas + comentario) |
| 1.10 | **Pedido grupal** | Crear sala compartida → genera enlace → invitados añaden platos → anfitrión confirma y paga |
| 1.11 | **Catering / Eventos** | Menús de evento disponibles. Seleccionar → personalizar platos por curso → extras → nº comensales, fecha, lugar → enviar solicitud |
| 1.12 | **Mis solicitudes de catering** | Lista con estado (pendiente → presupuesto enviado → aceptado → rechazado). Ver presupuesto PDF, aceptar/rechazar |
| 1.13 | **Chatbot IA** | Botón flotante → chat con IA. Preguntas sobre menú, alérgenos, horarios, estado pedido, recomendaciones |
| 1.14 | **Contacto / Consultas** | Formulario: nombre, email, teléfono, tipo (consulta / propuesta evento / oferta trabajo / colaboración / otro), mensaje, adjuntar foto opcional |
| 1.15 | **Favoritos** | Lista de platos favoritos, acceso rápido para pedir |
| 1.16 | **Mi perfil** | Datos personales, dirección(es) de entrega, alérgenos personales, preferencias notificación, modo oscuro/claro, cerrar sesión |

---

## ROL 2: EMPLEADO (6 pantallas — Android + Web)

| # | Pantalla | Descripción |
|---|----------|-------------|
| 2.1 | **Login empleado** | Mismo login, redirige al panel empleado según rol asignado |
| 2.2 | **Panel Cocina (KDS)** | Pedidos entrantes en tiempo real (Realtime). Cards: tipo de pedido (icono), productos, hora de entrega, notas. Botones: **Nuevo → Preparando → Listo**. Orden por urgencia. Incluye pedidos online Y mostrador |
| 2.3 | **Panel Repartidor** | Entregas asignadas: dirección, nombre, teléfono, productos, hora. Botón: **En camino → Entregado**. Botón llamar al cliente |
| 2.4 | **TPV Mostrador** | Grid de categorías → platos (TPV táctil). Tocar platos para añadir, ajustar cantidades. Ticket lateral con total. Botón "Cobrar" → método (efectivo / tarjeta). Crea pedido `type: 'mostrador'`, `status: 'entregado'`. NO requiere datos del cliente (venta anónima) |
| 2.5 | **Escáner QR recogida** | Cámara → escanea QR del cliente → muestra pedido → confirma entrega |
| 2.6 | **Mi perfil empleado** | Datos, cambiar contraseña, ver turno asignado |

---

## ROL 3: ADMIN (14 pantallas — Web + Android)

| # | Pantalla | Descripción |
|---|----------|-------------|
| 3.1 | **Dashboard** | Resumen del día: pedidos hoy, ventas totales (online + mostrador), platos más vendidos, pedidos pendientes. Gráficas: ventas por día/semana/mes, por tipo de pedido |
| 3.2 | **Gestión de Categorías** | CRUD: nombre, orden, icono/imagen, activo/inactivo |
| 3.3 | **Gestión de Platos** | CRUD: nombre, descripción, precio, categoría, foto (Storage), alérgenos, disponible sí/no, tiempo estimado. IA opcional: foto → genera nombre y descripción |
| 3.4 | **Plato del Día** | Seleccionar plato destacado, hora inicio y fin del countdown |
| 3.5 | **Gestión de Pedidos** | TODOS los pedidos (online + mostrador + domicilio). Filtros: estado, tipo, fecha. Detalle, cambiar estado, cancelar |
| 3.6 | **Franjas horarias** | Slots para encargos/domicilio (ej: 13:00-13:30). Máx pedidos por franja. Días activos/inactivos |
| 3.7 | **Gestión de Menús de Evento** | CRUD: nombre ("Menú Comunión Premium"), cursos (entrante, primero, segundo, postre), platos por curso, extras, precio base por comensal |
| 3.8 | **Solicitudes de Catering** | Lista solicitudes. Detalle, generar presupuesto (calculado o manual), enviar al cliente, marcar aceptado/rechazado |
| 3.9 | **Calendario de Eventos** | Vista calendario de eventos confirmados. Detalle: fecha, lugar, menú, nº comensales |
| 3.10 | **Buzón de Consultas** | Mensajes del formulario Contacto. Clasificados por tipo. Marcar leído, responder por email (Brevo), archivar |
| 3.11 | **Gestión de Empleados** | CRUD: nombre, email, rol (cocinero/repartidor/ambos), activo/inactivo |
| 3.12 | **Gestión de Usuarios** | Lista clientes registrados, historial pedidos, desactivar cuenta |
| 3.13 | **Configuración** | Datos negocio (nombre, dirección, teléfono, horarios), zonas de reparto, precio mínimo domicilio, tiempo máx antelación encargos |
| 3.14 | **Mi perfil admin** | Datos personales, cambiar contraseña |

---

## 13 Features Novedosas

| # | Feature | Tecnología |
|---|---------|-----------|
| 1 | Modo oscuro/claro automático | ThemeMode + sistema |
| 2 | Pedido por voz | speech_to_text → búsqueda platos |
| 3 | Estimación tiempo preparación | Algoritmo según carga cocina |
| 4 | Pedido grupal compartido | Supabase Realtime |
| 5 | Plato del día con countdown | Supabase Realtime |
| 6 | Repetir último pedido 1 tap | Consulta historial |
| 7 | Alertas alérgenos personalizadas | Match perfil ↔ plato |
| 8 | QR de recogida | qr_flutter + mobile_scanner |
| 9 | Favoritos | Tabla favorites |
| 10 | Ticket PDF descargable | pdf (dart) |
| 11 | Animaciones Lottie estados pedido | lottie package |
| 12 | Chatbot asistente IA | Gemini API via Edge Function |
| 13 | Recomendador personalizado | Historial + IA via Edge Function |
