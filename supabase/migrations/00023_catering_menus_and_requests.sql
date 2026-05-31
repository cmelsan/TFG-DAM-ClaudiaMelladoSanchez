-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00023 · Catering funcional con menús cerrados y menú personalizado
-- ─────────────────────────────────────────────────────────────────────────────

-- Estados adicionales para el flujo de catering.
ALTER TYPE event_request_status ADD VALUE IF NOT EXISTS 'appointment';
ALTER TYPE event_request_status ADD VALUE IF NOT EXISTS 'cancelled';

-- Una solicitud puede no tener menú cerrado cuando el cliente quiere diseñarlo.
ALTER TABLE event_requests
  ALTER COLUMN event_menu_id DROP NOT NULL;

ALTER TABLE event_requests
  ADD COLUMN IF NOT EXISTS event_type TEXT,
  ADD COLUMN IF NOT EXISTS contact_phone TEXT,
  ADD COLUMN IF NOT EXISTS menu_type TEXT NOT NULL DEFAULT 'closed',
  ADD COLUMN IF NOT EXISTS custom_menu_description TEXT,
  ADD COLUMN IF NOT EXISTS appointment_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS appointment_notes TEXT;

ALTER TABLE event_requests
  DROP CONSTRAINT IF EXISTS event_requests_menu_type_check;

ALTER TABLE event_requests
  ADD CONSTRAINT event_requests_menu_type_check
  CHECK (menu_type IN ('closed', 'custom'));

ALTER TABLE event_requests
  DROP CONSTRAINT IF EXISTS event_requests_menu_consistency_check;

ALTER TABLE event_requests
  ADD CONSTRAINT event_requests_menu_consistency_check
  CHECK (
    (menu_type = 'closed' AND event_menu_id IS NOT NULL)
    OR
    (menu_type = 'custom' AND event_menu_id IS NULL)
  );

CREATE INDEX IF NOT EXISTS idx_event_requests_appointment_at
  ON event_requests (appointment_at)
  WHERE appointment_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_event_requests_menu_type
  ON event_requests (menu_type);

-- Menús iniciales visibles en cliente y administrables desde el panel admin.
INSERT INTO event_menus (
  name,
  description,
  price_per_person,
  min_guests,
  max_guests,
  image_url,
  is_active
) VALUES
  (
    'Menú Cóctel Casero',
    'Aperitivos fríos y calientes, mini tortillas, croquetas artesanas, tostas variadas y selección dulce para celebraciones informales.',
    18.50,
    10,
    80,
    'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=1200&q=80',
    TRUE
  ),
  (
    'Menú Familiar Tradicional',
    'Entrantes para compartir, plato principal a elegir, guarniciones caseras, postre y pan. Ideal para cumpleaños y reuniones familiares.',
    24.00,
    12,
    120,
    'https://images.unsplash.com/photo-1543353071-10c8ba85a904?auto=format&fit=crop&w=1200&q=80',
    TRUE
  ),
  (
    'Menú Empresa',
    'Formato práctico para reuniones: bandejas saladas, opciones vegetarianas, bebidas, postres individuales y montaje sencillo.',
    21.75,
    15,
    150,
    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1200&q=80',
    TRUE
  ),
  (
    'Menú Celebración Premium',
    'Propuesta completa con entrantes especiales, principales de temporada, mesa dulce, bebidas y asesoramiento personalizado.',
    34.50,
    20,
    220,
    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1200&q=80',
    TRUE
  )
ON CONFLICT DO NOTHING;
