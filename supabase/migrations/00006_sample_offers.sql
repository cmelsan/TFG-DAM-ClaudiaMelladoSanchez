-- ============================================================
-- Migración 00006: Marcar platos de ejemplo como ofertas
-- ============================================================

UPDATE dishes
SET
  is_offer   = TRUE,
  offer_price = ROUND(price * 0.80, 2)   -- 20 % de descuento
WHERE id IN (
  'b1000000-0000-0000-0000-000000000003',  -- Croquetas Caseras  6.50 → 5.20
  'b1000000-0000-0000-0000-000000000006',  -- Pollo al Horno    10.00 → 8.00
  'b1000000-0000-0000-0000-000000000010',  -- Pasta Carbonara    8.50 → 6.80
  'b1000000-0000-0000-0000-000000000007'   -- Merluza en Salsa  12.50 → 10.00
);
