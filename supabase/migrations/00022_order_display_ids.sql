-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00022 · IDs de pedido diferenciados por categoría
-- Genera IDs legibles tipo DOM-0001 / LOC-0002 / ENC-0003 / MOS-0004
-- y CAT-0001 para solicitudes de catering.
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Tabla contadores por tipo de pedido ───────────────────────────────────
CREATE TABLE IF NOT EXISTS order_type_counters (
  order_type TEXT PRIMARY KEY,
  last_seq   INT  NOT NULL DEFAULT 0
);

INSERT INTO order_type_counters (order_type, last_seq) VALUES
  ('domicilio', 0),
  ('recogida',  0),
  ('encargo',   0),
  ('mostrador', 0)
ON CONFLICT DO NOTHING;

-- ── 2. Tabla contador catering ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS catering_counters (
  key      TEXT PRIMARY KEY DEFAULT 'catering',
  last_seq INT  NOT NULL DEFAULT 0
);

INSERT INTO catering_counters (key, last_seq) VALUES ('catering', 0)
ON CONFLICT DO NOTHING;

-- ── 3. Columna display_id en orders ─────────────────────────────────────────
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS display_id TEXT;

-- Índice único (permite NULL, solo uno por valor no nulo)
CREATE UNIQUE INDEX IF NOT EXISTS orders_display_id_unique
  ON orders (display_id)
  WHERE display_id IS NOT NULL;

-- ── 4. Columna display_id en event_requests ──────────────────────────────────
ALTER TABLE event_requests
  ADD COLUMN IF NOT EXISTS display_id TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS event_requests_display_id_unique
  ON event_requests (display_id)
  WHERE display_id IS NOT NULL;

-- ── 5. Función trigger para orders ───────────────────────────────────────────
CREATE OR REPLACE FUNCTION generate_order_display_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_prefix TEXT;
  v_seq    INT;
BEGIN
  v_prefix := CASE NEW.order_type
    WHEN 'domicilio' THEN 'DOM'
    WHEN 'recogida'  THEN 'LOC'
    WHEN 'encargo'   THEN 'ENC'
    WHEN 'mostrador' THEN 'MOS'
    ELSE 'PED'
  END;

  -- Incremento atómico del contador del tipo correspondiente
  INSERT INTO order_type_counters (order_type, last_seq)
  VALUES (NEW.order_type, 1)
  ON CONFLICT (order_type) DO UPDATE
    SET last_seq = order_type_counters.last_seq + 1
  RETURNING last_seq INTO v_seq;

  NEW.display_id := v_prefix || '-' || LPAD(v_seq::TEXT, 4, '0');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_order_display_id ON orders;
CREATE TRIGGER trg_order_display_id
  BEFORE INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION generate_order_display_id();

-- ── 6. Función trigger para event_requests (catering) ────────────────────────
CREATE OR REPLACE FUNCTION generate_catering_display_id()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_seq INT;
BEGIN
  INSERT INTO catering_counters (key, last_seq)
  VALUES ('catering', 1)
  ON CONFLICT (key) DO UPDATE
    SET last_seq = catering_counters.last_seq + 1
  RETURNING last_seq INTO v_seq;

  NEW.display_id := 'CAT-' || LPAD(v_seq::TEXT, 4, '0');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_catering_display_id ON event_requests;
CREATE TRIGGER trg_catering_display_id
  BEFORE INSERT ON event_requests
  FOR EACH ROW
  EXECUTE FUNCTION generate_catering_display_id();

-- ── 7. Backfill pedidos existentes (en orden de creación) ────────────────────
DO $$
DECLARE
  r        RECORD;
  v_prefix TEXT;
  v_seq    INT;
BEGIN
  FOR r IN
    SELECT id, order_type FROM orders
    WHERE display_id IS NULL
    ORDER BY created_at ASC
  LOOP
    v_prefix := CASE r.order_type
      WHEN 'domicilio' THEN 'DOM'
      WHEN 'recogida'  THEN 'LOC'
      WHEN 'encargo'   THEN 'ENC'
      WHEN 'mostrador' THEN 'MOS'
      ELSE 'PED'
    END;

    INSERT INTO order_type_counters (order_type, last_seq)
    VALUES (r.order_type, 1)
    ON CONFLICT (order_type) DO UPDATE
      SET last_seq = order_type_counters.last_seq + 1
    RETURNING last_seq INTO v_seq;

    UPDATE orders
    SET display_id = v_prefix || '-' || LPAD(v_seq::TEXT, 4, '0')
    WHERE id = r.id;
  END LOOP;
END $$;

-- ── 8. Backfill solicitudes catering existentes ───────────────────────────────
DO $$
DECLARE
  r     RECORD;
  v_seq INT;
BEGIN
  FOR r IN
    SELECT id FROM event_requests
    WHERE display_id IS NULL
    ORDER BY created_at ASC
  LOOP
    INSERT INTO catering_counters (key, last_seq)
    VALUES ('catering', 1)
    ON CONFLICT (key) DO UPDATE
      SET last_seq = catering_counters.last_seq + 1
    RETURNING last_seq INTO v_seq;

    UPDATE event_requests
    SET display_id = 'CAT-' || LPAD(v_seq::TEXT, 4, '0')
    WHERE id = r.id;
  END LOOP;
END $$;
