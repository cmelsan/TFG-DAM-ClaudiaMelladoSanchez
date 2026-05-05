-- ============================================================
-- SABOR DE CASA — Configuración de encargos
-- ============================================================
-- Añade la clave encargo_min_days_advance a business_config.
-- Valor por defecto: 2 días de antelación mínima.
-- El admin puede cambiar este valor desde el panel de configuración.
-- ============================================================

INSERT INTO business_config (key, value)
VALUES ('encargo_min_days_advance', '2')
ON CONFLICT (key) DO NOTHING;
