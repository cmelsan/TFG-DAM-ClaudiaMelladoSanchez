-- ============================================================
-- Migración 00005: Añadir campos de oferta y temporada a dishes
-- ============================================================

ALTER TABLE dishes
  ADD COLUMN IF NOT EXISTS is_offer    BOOLEAN       NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_seasonal BOOLEAN       NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS offer_price NUMERIC(8,2)  CHECK (offer_price IS NULL OR offer_price >= 0);

-- Restricción: offer_price solo tiene sentido si is_offer = TRUE
ALTER TABLE dishes
  ADD CONSTRAINT chk_offer_price
    CHECK (offer_price IS NULL OR is_offer = TRUE);

-- Añadir campo cancellation_reason a orders (para cancelaciones con motivo)
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

COMMENT ON COLUMN dishes.is_offer        IS 'TRUE si el plato está actualmente en oferta';
COMMENT ON COLUMN dishes.is_seasonal     IS 'TRUE si es un plato de temporada';
COMMENT ON COLUMN dishes.offer_price     IS 'Precio de oferta (precio especial, < price). NULL si no está en oferta.';
COMMENT ON COLUMN orders.cancellation_reason IS 'Motivo de cancelación del pedido (solo relevante cuando status = cancelled)';
