-- ============================================================
-- SABOR DE CASA — Toggle global de la sección "Platos de temporada"
--                + datos de ejemplo
-- ============================================================
-- 1) Añade la clave show_seasonal_section a business_config.
--    Valor 'true'  → sección visible en la home web.
--    Valor 'false' → sección oculta aunque haya platos de temporada.
-- 2) Marca algunos platos existentes como is_seasonal = TRUE.
--    Ajusta los nombres según los platos reales de tu BD.
-- ============================================================

-- Configuración del toggle
INSERT INTO business_config (key, value)
VALUES ('show_seasonal_section', 'true')
ON CONFLICT (key) DO NOTHING;

-- Marcar platos de temporada (ejemplos: veranos / gazpacho, salmorejo, etc.)
-- Sustituye los nombres por los platos reales de tu catálogo.
UPDATE dishes
SET is_seasonal = TRUE
WHERE name ILIKE ANY (ARRAY[
  '%gazpacho%',
  '%salmorejo%',
  '%ajoblanco%',
  '%ensaladilla%',
  '%porra%'
]);
