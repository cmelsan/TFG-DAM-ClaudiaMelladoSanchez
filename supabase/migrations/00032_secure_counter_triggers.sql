-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00032 · Triggers seguros para contadores internos
-- Los triggers de display_id deben poder escribir en order_type_counters y
-- catering_counters aunque el usuario final tenga RLS activado.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION generate_order_display_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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

  INSERT INTO order_type_counters (order_type, last_seq)
  VALUES (NEW.order_type, 1)
  ON CONFLICT (order_type) DO UPDATE
    SET last_seq = order_type_counters.last_seq + 1
  RETURNING last_seq INTO v_seq;

  NEW.display_id := v_prefix || '-' || LPAD(v_seq::TEXT, 4, '0');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION generate_catering_display_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
