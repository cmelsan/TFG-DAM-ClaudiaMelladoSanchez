-- ============================================================
-- Datos de ejemplo: categorías y platos
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ============================================================

-- ── Categorías ──────────────────────────────────────────────
INSERT INTO categories (id, name, description, sort_order, is_active)
VALUES
  ('a1000000-0000-0000-0000-000000000001', 'Menú del día',       'Menú completo diario a precio especial', 1, true),
  ('a1000000-0000-0000-0000-000000000002', 'Entrantes',          'Tapas y entrantes para compartir',        2, true),
  ('a1000000-0000-0000-0000-000000000003', 'Platos principales', 'Carnes, pescados y arroces',              3, true),
  ('a1000000-0000-0000-0000-000000000004', 'Pasta y arroces',    'Pasta artesanal y arroces cremosos',      4, true),
  ('a1000000-0000-0000-0000-000000000005', 'Postres',            'Dulces caseros y helados',                5, true),
  ('a1000000-0000-0000-0000-000000000006', 'Bebidas',            'Refrescos, zumos y agua',                 6, true)
ON CONFLICT (id) DO NOTHING;

-- ── Platos ──────────────────────────────────────────────────
INSERT INTO dishes (id, category_id, name, description, price, prep_time_min, allergens, is_available, is_active)
VALUES
  -- Menú del día
  ('b1000000-0000-0000-0000-000000000001',
   'a1000000-0000-0000-0000-000000000001',
   'Menú Casero Completo',
   'Sopa de fideos + segundo a elegir + postre + pan y bebida',
   10.50, 20, ARRAY['gluten'], true, true),

  ('b1000000-0000-0000-0000-000000000002',
   'a1000000-0000-0000-0000-000000000001',
   'Menú Vegetariano',
   'Crema de verduras + pasta con pesto + fruta del tiempo',
   9.50, 15, ARRAY['gluten','frutos_secos'], true, true),

  -- Entrantes
  ('b1000000-0000-0000-0000-000000000003',
   'a1000000-0000-0000-0000-000000000002',
   'Croquetas Caseras (8 uds)',
   'Croquetas de jamón serrano con bechamel casera',
   6.50, 10, ARRAY['gluten','lacteos','huevos'], true, true),

  ('b1000000-0000-0000-0000-000000000004',
   'a1000000-0000-0000-0000-000000000002',
   'Ensalada César',
   'Lechuga romana, pollo a la plancha, parmesano y anchoas',
   7.00, 10, ARRAY['lacteos','pescado','huevos'], true, true),

  ('b1000000-0000-0000-0000-000000000005',
   'a1000000-0000-0000-0000-000000000002',
   'Tabla de Ibéricos',
   'Selección de embutidos ibéricos con pan de cristal',
   9.00, 5, ARRAY['gluten'], true, true),

  -- Platos principales
  ('b1000000-0000-0000-0000-000000000006',
   'a1000000-0000-0000-0000-000000000003',
   'Pollo al Horno con Patatas',
   'Muslos de pollo asados con patatas panaderas y romero',
   10.00, 30, ARRAY[]::text[], true, true),

  ('b1000000-0000-0000-0000-000000000007',
   'a1000000-0000-0000-0000-000000000003',
   'Merluza en Salsa Verde',
   'Merluza fresca con almejas en salsa verde de perejil y ajo',
   12.50, 20, ARRAY['pescado','marisco'], true, true),

  ('b1000000-0000-0000-0000-000000000008',
   'a1000000-0000-0000-0000-000000000003',
   'Secreto Ibérico a la Plancha',
   'Secreto ibérico con guarnición de verduras asadas',
   14.00, 20, ARRAY[]::text[], true, true),

  ('b1000000-0000-0000-0000-000000000009',
   'a1000000-0000-0000-0000-000000000003',
   'Hamburguesa Artesanal',
   'Carne de ternera 200 g, queso, bacon y patatas fritas',
   11.00, 15, ARRAY['gluten','lacteos','huevos'], true, true),

  -- Pasta y arroces
  ('b1000000-0000-0000-0000-000000000010',
   'a1000000-0000-0000-0000-000000000004',
   'Pasta Carbonara',
   'Espaguetis con panceta, huevo y parmesano',
   9.00, 15, ARRAY['gluten','lacteos','huevos'], true, true),

  ('b1000000-0000-0000-0000-000000000011',
   'a1000000-0000-0000-0000-000000000004',
   'Arroz Cremoso de Setas',
   'Risotto de boletus y trufa con parmesano',
   10.50, 25, ARRAY['lacteos'], true, true),

  ('b1000000-0000-0000-0000-000000000012',
   'a1000000-0000-0000-0000-000000000004',
   'Pasta al Pesto de Albahaca',
   'Fusilli con pesto genovés, piñones y tomates cherry',
   8.50, 12, ARRAY['gluten','frutos_secos','lacteos'], true, true),

  -- Postres
  ('b1000000-0000-0000-0000-000000000013',
   'a1000000-0000-0000-0000-000000000005',
   'Tarta de Queso Casera',
   'Tarta de queso cremosa con coulis de frutos rojos',
   4.50, 1, ARRAY['lacteos','huevos','gluten'], true, true),

  ('b1000000-0000-0000-0000-000000000014',
   'a1000000-0000-0000-0000-000000000005',
   'Brownie con Helado',
   'Brownie de chocolate caliente con bola de vainilla',
   5.00, 5, ARRAY['gluten','lacteos','huevos','frutos_secos'], true, true),

  ('b1000000-0000-0000-0000-000000000015',
   'a1000000-0000-0000-0000-000000000005',
   'Flan de Huevo Casero',
   'Flan de huevo con caramelo, receta tradicional',
   3.50, 1, ARRAY['lacteos','huevos'], true, true),

  -- Bebidas
  ('b1000000-0000-0000-0000-000000000016',
   'a1000000-0000-0000-0000-000000000006',
   'Agua Mineral (50 cl)',
   'Agua mineral natural o con gas',
   1.50, 1, ARRAY[]::text[], true, true),

  ('b1000000-0000-0000-0000-000000000017',
   'a1000000-0000-0000-0000-000000000006',
   'Refresco (33 cl)',
   'Cola, naranja, limón o tónica',
   2.00, 1, ARRAY[]::text[], true, true),

  ('b1000000-0000-0000-0000-000000000018',
   'a1000000-0000-0000-0000-000000000006',
   'Zumo Natural de Naranja',
   'Naranja exprimida al momento',
   3.00, 5, ARRAY[]::text[], true, true)

ON CONFLICT (id) DO NOTHING;
