-- Añade la clave de configuración para pausar/reanudar la aceptación de pedidos.
-- Por defecto el negocio acepta pedidos (value = 'true').
INSERT INTO business_config (key, value)
VALUES ('accepting_orders', 'true')
ON CONFLICT (key) DO NOTHING;
