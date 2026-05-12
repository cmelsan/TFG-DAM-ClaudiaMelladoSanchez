-- ============================================================
-- SABOR DE CASA — Descuento primer pedido (30%)
-- ============================================================
-- Añade la clave first_order_discount_enabled a business_config.
-- Valor 'true'  → el descuento se aplica automáticamente al
--                 primer pedido de cada usuario.
-- Valor 'false' → el descuento está desactivado.
-- El admin puede cambiar este valor desde Configuración.
-- ============================================================

INSERT INTO business_config (key, value)
VALUES ('first_order_discount_enabled', 'true')
ON CONFLICT (key) DO NOTHING;
