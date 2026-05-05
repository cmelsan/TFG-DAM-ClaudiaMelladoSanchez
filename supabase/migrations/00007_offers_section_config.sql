-- ============================================================
-- SABOR DE CASA — Toggle global de la sección "En oferta"
-- ============================================================
-- Añade la clave show_offers_section a business_config.
-- Valor 'true' → la sección es visible en la home web.
-- Valor 'false' → la sección se oculta aunque haya platos en oferta.
-- El admin puede cambiar este valor desde el panel de configuración.
-- ============================================================

INSERT INTO business_config (key, value)
VALUES ('show_offers_section', 'true')
ON CONFLICT (key) DO NOTHING;
