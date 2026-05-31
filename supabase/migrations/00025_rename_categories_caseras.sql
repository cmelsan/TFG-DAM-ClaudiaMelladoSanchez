-- ============================================================
-- Renombra las categorías del menú con nombres más caseros
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- ============================================================

UPDATE categories
SET name        = 'Para picar',
    description = 'Tapas y cositas para compartir'
WHERE name = 'Entrantes';

UPDATE categories
SET name        = 'De la cazuela',
    description = 'Guisos, carnes y pescados del día'
WHERE name = 'Platos principales';

UPDATE categories
SET name        = 'Arroces y pasta',
    description = 'Arroces cremosos y pasta artesanal'
WHERE name = 'Pasta y arroces';

UPDATE categories
SET name        = 'Dulces caseros',
    description = 'Postres y dulces de elaboración propia'
WHERE name = 'Postres';
