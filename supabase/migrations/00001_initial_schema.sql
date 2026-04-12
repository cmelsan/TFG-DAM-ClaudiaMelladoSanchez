-- ============================================================
-- SABOR DE CASA — Migración inicial completa
-- Ejecutar en Supabase SQL Editor (en orden)
-- ============================================================

-- ============================
-- 1. TIPOS ENUM
-- ============================

CREATE TYPE user_role AS ENUM ('client', 'employee', 'admin');
CREATE TYPE order_type AS ENUM ('mostrador', 'encargo', 'domicilio', 'recogida');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'refunded');
CREATE TYPE payment_method AS ENUM ('card', 'cash', 'online');
CREATE TYPE event_request_status AS ENUM ('pending', 'quoted', 'accepted', 'rejected', 'completed');

-- ============================
-- 2. TABLAS
-- ============================

-- ---- PROFILES ----
CREATE TABLE profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT NOT NULL,
  role        user_role NOT NULL DEFAULT 'client',
  full_name   TEXT,
  phone       TEXT,
  avatar_url  TEXT,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- ADDRESSES ----
CREATE TABLE addresses (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  label       TEXT NOT NULL DEFAULT 'Casa',
  street      TEXT NOT NULL,
  city        TEXT NOT NULL DEFAULT 'Huelva',
  postal_code TEXT NOT NULL,
  notes       TEXT,
  is_default  BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- CATEGORIES ----
CREATE TABLE categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  description TEXT,
  image_url   TEXT,
  sort_order  INT NOT NULL DEFAULT 0,
  is_active   BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- DISHES ----
CREATE TABLE dishes (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id   UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  name          TEXT NOT NULL,
  description   TEXT NOT NULL DEFAULT '',
  price         NUMERIC(8,2) NOT NULL CHECK (price >= 0),
  image_url     TEXT,
  allergens     TEXT[] NOT NULL DEFAULT '{}',
  prep_time_min INT NOT NULL DEFAULT 15 CHECK (prep_time_min > 0),
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- DAILY SPECIAL (plato del día) ----
CREATE TABLE daily_special (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dish_id          UUID NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
  date             DATE NOT NULL,
  discount_percent INT CHECK (discount_percent BETWEEN 0 AND 100),
  note             TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(date)
);

-- ---- SCHEDULE (horarios del local) ----
CREATE TABLE schedule (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day_of_week  INT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  open_time    TIME NOT NULL,
  close_time   TIME NOT NULL,
  is_open      BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE(day_of_week)
);

-- ---- ORDERS ----
CREATE TABLE orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES profiles(id) ON DELETE SET NULL,
  order_type        order_type NOT NULL,
  status            order_status NOT NULL DEFAULT 'pending',
  payment_status    payment_status NOT NULL DEFAULT 'pending',
  payment_method    payment_method,
  subtotal          NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  delivery_fee      NUMERIC(6,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
  total             NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
  address_id        UUID REFERENCES addresses(id) ON DELETE SET NULL,
  scheduled_at      TIMESTAMPTZ,
  notes             TEXT,
  assigned_driver_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- ORDER ITEMS ----
CREATE TABLE order_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  dish_id     UUID NOT NULL REFERENCES dishes(id) ON DELETE RESTRICT,
  quantity    INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price  NUMERIC(8,2) NOT NULL CHECK (unit_price >= 0),
  subtotal    NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
  notes       TEXT
);

-- ---- ORDER RATINGS ----
CREATE TABLE order_ratings (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id    UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE UNIQUE,
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating      INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- FAVORITES ----
CREATE TABLE favorites (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  dish_id     UUID NOT NULL REFERENCES dishes(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, dish_id)
);

-- ---- EVENT MENUS (menús de catering) ----
CREATE TABLE event_menus (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name              TEXT NOT NULL,
  description       TEXT,
  price_per_person  NUMERIC(8,2) NOT NULL CHECK (price_per_person >= 0),
  min_guests        INT NOT NULL DEFAULT 10,
  max_guests        INT NOT NULL DEFAULT 200,
  image_url         TEXT,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- EVENT MENU COURSES (platos dentro de un menú) ----
CREATE TABLE event_menu_courses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_menu_id   UUID NOT NULL REFERENCES event_menus(id) ON DELETE CASCADE,
  course_type     TEXT NOT NULL CHECK (course_type IN ('entrante', 'principal', 'postre', 'bebida')),
  name            TEXT NOT NULL,
  description     TEXT,
  sort_order      INT NOT NULL DEFAULT 0
);

-- ---- EVENT EXTRAS (servicios extra: DJ, decoración, etc.) ----
CREATE TABLE event_extras (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  description TEXT,
  price       NUMERIC(8,2) NOT NULL CHECK (price >= 0),
  is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---- EVENT REQUESTS (solicitudes de catering) ----
CREATE TABLE event_requests (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  event_menu_id   UUID NOT NULL REFERENCES event_menus(id) ON DELETE RESTRICT,
  event_date      DATE NOT NULL,
  guest_count     INT NOT NULL CHECK (guest_count > 0),
  location        TEXT NOT NULL,
  notes           TEXT,
  status          event_request_status NOT NULL DEFAULT 'pending',
  quoted_total    NUMERIC(10,2),
  admin_notes     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- EVENT REQUEST SELECTIONS (cursos elegidos) ----
CREATE TABLE event_request_selections (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_request_id       UUID NOT NULL REFERENCES event_requests(id) ON DELETE CASCADE,
  event_menu_course_id   UUID NOT NULL REFERENCES event_menu_courses(id) ON DELETE CASCADE,
  UNIQUE(event_request_id, event_menu_course_id)
);

-- ---- EVENT REQUEST EXTRAS (extras elegidos) ----
CREATE TABLE event_request_extras (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_request_id  UUID NOT NULL REFERENCES event_requests(id) ON DELETE CASCADE,
  event_extra_id    UUID NOT NULL REFERENCES event_extras(id) ON DELETE CASCADE,
  quantity          INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
  UNIQUE(event_request_id, event_extra_id)
);

-- ---- EVENT CALENDAR (calendario de eventos confirmados) ----
CREATE TABLE event_calendar (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_request_id  UUID NOT NULL REFERENCES event_requests(id) ON DELETE CASCADE UNIQUE,
  date              DATE NOT NULL,
  title             TEXT NOT NULL,
  notes             TEXT
);

-- ---- CONTACT MESSAGES ----
CREATE TABLE contact_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  email       TEXT NOT NULL,
  phone       TEXT,
  subject     TEXT NOT NULL,
  message     TEXT NOT NULL,
  is_read     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---- PUSH TOKENS ----
CREATE TABLE push_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  token       TEXT NOT NULL,
  platform    TEXT NOT NULL CHECK (platform IN ('android', 'web')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, token)
);

-- ---- BUSINESS CONFIG (configuración del negocio) ----
CREATE TABLE business_config (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         TEXT NOT NULL UNIQUE,
  value       TEXT NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================
-- 3. ÍNDICES
-- ============================

CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_dishes_category_id ON dishes(category_id);
CREATE INDEX idx_dishes_is_available ON dishes(is_available) WHERE is_active = TRUE;
CREATE INDEX idx_daily_special_date ON daily_special(date);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_assigned_driver ON orders(assigned_driver_id) WHERE assigned_driver_id IS NOT NULL;
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_event_requests_user_id ON event_requests(user_id);
CREATE INDEX idx_event_requests_status ON event_requests(status);
CREATE INDEX idx_contact_messages_is_read ON contact_messages(is_read);
CREATE INDEX idx_push_tokens_user_id ON push_tokens(user_id);

-- ============================
-- 4. FUNCIONES Y TRIGGERS
-- ============================

-- Función genérica para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de updated_at
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_dishes_updated_at
  BEFORE UPDATE ON dishes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_event_requests_updated_at
  BEFORE UPDATE ON event_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_business_config_updated_at
  BEFORE UPDATE ON business_config
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Función: crear perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, role)
  VALUES (
    NEW.id,
    NEW.email,
    'client'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: al crear usuario en auth.users → crear perfil
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================
-- 5. ROW LEVEL SECURITY (RLS)
-- ============================

-- Habilitar RLS en TODAS las tablas
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_special ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_menus ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_menu_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_extras ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_request_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_request_extras ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_calendar ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_config ENABLE ROW LEVEL SECURITY;

-- Función helper: obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_my_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ---- PROFILES ----
CREATE POLICY "Usuarios ven su propio perfil"
  ON profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Empleados ven todos los perfiles"
  ON profiles FOR SELECT
  USING (get_my_role() IN ('employee', 'admin'));

CREATE POLICY "Usuarios actualizan su propio perfil"
  ON profiles FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid() AND role = (SELECT role FROM profiles WHERE id = auth.uid()));
  -- No pueden cambiar su propio rol

CREATE POLICY "Admin actualiza cualquier perfil"
  ON profiles FOR UPDATE
  USING (get_my_role() = 'admin');

-- ---- ADDRESSES ----
CREATE POLICY "Usuarios ven sus direcciones"
  ON addresses FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Usuarios crean sus direcciones"
  ON addresses FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Usuarios actualizan sus direcciones"
  ON addresses FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Usuarios eliminan sus direcciones"
  ON addresses FOR DELETE
  USING (user_id = auth.uid());

-- ---- CATEGORIES (público lectura, admin escritura) ----
CREATE POLICY "Todos ven categorías activas"
  ON categories FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Admin ve todas las categorías"
  ON categories FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin gestiona categorías"
  ON categories FOR ALL
  USING (get_my_role() = 'admin');

-- ---- DISHES (público lectura, admin escritura) ----
CREATE POLICY "Todos ven platos activos y disponibles"
  ON dishes FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Admin ve todos los platos"
  ON dishes FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin gestiona platos"
  ON dishes FOR ALL
  USING (get_my_role() = 'admin');

-- ---- DAILY SPECIAL ----
CREATE POLICY "Todos ven el plato del día"
  ON daily_special FOR SELECT
  USING (TRUE);

CREATE POLICY "Admin gestiona plato del día"
  ON daily_special FOR ALL
  USING (get_my_role() = 'admin');

-- ---- SCHEDULE ----
CREATE POLICY "Todos ven los horarios"
  ON schedule FOR SELECT
  USING (TRUE);

CREATE POLICY "Admin gestiona horarios"
  ON schedule FOR ALL
  USING (get_my_role() = 'admin');

-- ---- ORDERS ----
CREATE POLICY "Clientes ven sus propios pedidos"
  ON orders FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Empleados y admin ven todos los pedidos"
  ON orders FOR SELECT
  USING (get_my_role() IN ('employee', 'admin'));

CREATE POLICY "Usuarios autenticados crean pedidos"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Empleados y admin actualizan pedidos"
  ON orders FOR UPDATE
  USING (get_my_role() IN ('employee', 'admin'));

CREATE POLICY "Admin elimina pedidos"
  ON orders FOR DELETE
  USING (get_my_role() = 'admin');

-- ---- ORDER ITEMS ----
CREATE POLICY "Ver items de mis pedidos"
  ON order_items FOR SELECT
  USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    OR get_my_role() IN ('employee', 'admin')
  );

CREATE POLICY "Crear items en mis pedidos"
  ON order_items FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Empleados y admin gestionan items"
  ON order_items FOR ALL
  USING (get_my_role() IN ('employee', 'admin'));

-- ---- ORDER RATINGS ----
CREATE POLICY "Ver mis valoraciones"
  ON order_ratings FOR SELECT
  USING (user_id = auth.uid() OR get_my_role() = 'admin');

CREATE POLICY "Crear valoración de mi pedido"
  ON order_ratings FOR INSERT
  WITH CHECK (
    user_id = auth.uid()
    AND order_id IN (SELECT id FROM orders WHERE user_id = auth.uid() AND status = 'delivered')
  );

-- ---- FAVORITES ----
CREATE POLICY "Ver mis favoritos"
  ON favorites FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Añadir a favoritos"
  ON favorites FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Eliminar de favoritos"
  ON favorites FOR DELETE
  USING (user_id = auth.uid());

-- ---- EVENT MENUS (público lectura) ----
CREATE POLICY "Todos ven menús de eventos activos"
  ON event_menus FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Admin gestiona menús de eventos"
  ON event_menus FOR ALL
  USING (get_my_role() = 'admin');

-- ---- EVENT MENU COURSES ----
CREATE POLICY "Todos ven los cursos de menús"
  ON event_menu_courses FOR SELECT
  USING (TRUE);

CREATE POLICY "Admin gestiona cursos"
  ON event_menu_courses FOR ALL
  USING (get_my_role() = 'admin');

-- ---- EVENT EXTRAS ----
CREATE POLICY "Todos ven extras activos"
  ON event_extras FOR SELECT
  USING (is_active = TRUE);

CREATE POLICY "Admin gestiona extras"
  ON event_extras FOR ALL
  USING (get_my_role() = 'admin');

-- ---- EVENT REQUESTS ----
CREATE POLICY "Clientes ven sus solicitudes"
  ON event_requests FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Admin ve todas las solicitudes"
  ON event_requests FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Clientes crean solicitudes"
  ON event_requests FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admin actualiza solicitudes"
  ON event_requests FOR UPDATE
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin elimina solicitudes"
  ON event_requests FOR DELETE
  USING (get_my_role() = 'admin');

-- ---- EVENT REQUEST SELECTIONS ----
CREATE POLICY "Ver selecciones de mis solicitudes"
  ON event_request_selections FOR SELECT
  USING (
    event_request_id IN (SELECT id FROM event_requests WHERE user_id = auth.uid())
    OR get_my_role() = 'admin'
  );

CREATE POLICY "Crear selecciones en mis solicitudes"
  ON event_request_selections FOR INSERT
  WITH CHECK (
    event_request_id IN (SELECT id FROM event_requests WHERE user_id = auth.uid())
  );

CREATE POLICY "Admin gestiona selecciones"
  ON event_request_selections FOR ALL
  USING (get_my_role() = 'admin');

-- ---- EVENT REQUEST EXTRAS ----
CREATE POLICY "Ver extras de mis solicitudes"
  ON event_request_extras FOR SELECT
  USING (
    event_request_id IN (SELECT id FROM event_requests WHERE user_id = auth.uid())
    OR get_my_role() = 'admin'
  );

CREATE POLICY "Crear extras en mis solicitudes"
  ON event_request_extras FOR INSERT
  WITH CHECK (
    event_request_id IN (SELECT id FROM event_requests WHERE user_id = auth.uid())
  );

CREATE POLICY "Admin gestiona extras de solicitudes"
  ON event_request_extras FOR ALL
  USING (get_my_role() = 'admin');

-- ---- EVENT CALENDAR ----
CREATE POLICY "Admin ve calendario"
  ON event_calendar FOR SELECT
  USING (get_my_role() IN ('employee', 'admin'));

CREATE POLICY "Admin gestiona calendario"
  ON event_calendar FOR ALL
  USING (get_my_role() = 'admin');

-- ---- CONTACT MESSAGES ----
CREATE POLICY "Cualquiera puede enviar un mensaje"
  ON contact_messages FOR INSERT
  WITH CHECK (TRUE);

CREATE POLICY "Admin ve mensajes"
  ON contact_messages FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admin gestiona mensajes"
  ON contact_messages FOR UPDATE
  USING (get_my_role() = 'admin');

-- ---- PUSH TOKENS ----
CREATE POLICY "Ver mis tokens"
  ON push_tokens FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Registrar mi token"
  ON push_tokens FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Actualizar mi token"
  ON push_tokens FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Eliminar mi token"
  ON push_tokens FOR DELETE
  USING (user_id = auth.uid());

-- ---- BUSINESS CONFIG ----
CREATE POLICY "Todos leen configuración"
  ON business_config FOR SELECT
  USING (TRUE);

CREATE POLICY "Admin gestiona configuración"
  ON business_config FOR ALL
  USING (get_my_role() = 'admin');

-- ============================
-- 6. STORAGE BUCKETS
-- ============================

INSERT INTO storage.buckets (id, name, public) VALUES ('dish-images', 'dish-images', TRUE);
INSERT INTO storage.buckets (id, name, public) VALUES ('category-images', 'category-images', TRUE);
INSERT INTO storage.buckets (id, name, public) VALUES ('profile-avatars', 'profile-avatars', TRUE);
INSERT INTO storage.buckets (id, name, public) VALUES ('event-images', 'event-images', TRUE);

-- Políticas de Storage

-- dish-images: público lectura, admin escritura
CREATE POLICY "Público lee imágenes de platos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'dish-images');

CREATE POLICY "Admin sube imágenes de platos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'dish-images' AND (SELECT get_my_role()) = 'admin');

CREATE POLICY "Admin elimina imágenes de platos"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'dish-images' AND (SELECT get_my_role()) = 'admin');

-- category-images: público lectura, admin escritura
CREATE POLICY "Público lee imágenes de categorías"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'category-images');

CREATE POLICY "Admin sube imágenes de categorías"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'category-images' AND (SELECT get_my_role()) = 'admin');

-- profile-avatars: usuario sube su propio avatar
CREATE POLICY "Público lee avatares"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-avatars');

CREATE POLICY "Usuarios suben su avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );

CREATE POLICY "Usuarios eliminan su avatar"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-avatars'
    AND (storage.foldername(name))[1] = auth.uid()::TEXT
  );

-- event-images: público lectura, admin escritura
CREATE POLICY "Público lee imágenes de eventos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'event-images');

CREATE POLICY "Admin sube imágenes de eventos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'event-images' AND (SELECT get_my_role()) = 'admin');

-- ============================
-- 7. DATOS INICIALES
-- ============================

-- Horarios por defecto (Lun-Sáb abierto, Dom cerrado)
INSERT INTO schedule (day_of_week, open_time, close_time, is_open) VALUES
  (1, '09:00', '15:00', TRUE),   -- Lunes
  (2, '09:00', '15:00', TRUE),   -- Martes
  (3, '09:00', '15:00', TRUE),   -- Miércoles
  (4, '09:00', '15:00', TRUE),   -- Jueves
  (5, '09:00', '15:00', TRUE),   -- Viernes
  (6, '09:00', '14:00', TRUE),   -- Sábado
  (0, '00:00', '00:00', FALSE);  -- Domingo

-- Configuración inicial del negocio
INSERT INTO business_config (key, value) VALUES
  ('business_name', 'Sabor de Casa'),
  ('phone', '+34 000 000 000'),
  ('email', 'info@sabordecasa.es'),
  ('address', 'Huelva, España'),
  ('delivery_fee', '2.50'),
  ('min_order_delivery', '12.00'),
  ('max_delivery_km', '10'),
  ('currency', 'EUR');
