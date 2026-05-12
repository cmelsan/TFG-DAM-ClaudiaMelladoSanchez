-- ============================================================
-- SABOR DE CASA — Columna discount_amount en orders
-- ============================================================
-- Añade el campo discount_amount para registrar el importe
-- descontado en cada pedido (p. ej. 30% primer pedido).
-- ============================================================

ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0
    CHECK (discount_amount >= 0);
