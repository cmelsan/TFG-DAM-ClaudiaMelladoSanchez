-- -----------------------------------------------------------------------------
-- Migration 00026 · Catering: reglas por evento, bodas/comuniones y menus caseros
-- -----------------------------------------------------------------------------

ALTER TABLE event_menus
  ADD COLUMN IF NOT EXISTS event_kind TEXT NOT NULL DEFAULT 'small',
  ADD COLUMN IF NOT EXISTS lead_time_months INT NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS tasting_available BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS highlight_label TEXT;

ALTER TABLE event_menus
  DROP CONSTRAINT IF EXISTS event_menus_event_kind_check;

ALTER TABLE event_menus
  ADD CONSTRAINT event_menus_event_kind_check
  CHECK (event_kind IN ('small', 'family', 'communion', 'wedding', 'business', 'custom'));

ALTER TABLE event_menus
  DROP CONSTRAINT IF EXISTS event_menus_lead_time_months_check;

ALTER TABLE event_menus
  ADD CONSTRAINT event_menus_lead_time_months_check
  CHECK (lead_time_months IN (1, 6, 8));

UPDATE event_menus
SET name = 'Mesa Casera para Cumpleanos',
    description = $$Incluye:
- Croquetas de puchero, tortilla de patatas, ensaladilla y empanadas caseras.
- Montaditos variados, mini flamenquines, lagrimitas de pollo y albondigas en salsa.
- Bandejas frias con chacinas, queso curado, picos y panes artesanos.
- Mesa dulce con tarta de queso, flan de huevo, brownies y fruta preparada.
- Montaje sencillo para celebraciones en casa o local privado.$$,
    price_per_person = 19.50,
    min_guests = 10,
    max_guests = 80,
    image_url = 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=1200&q=80',
    event_kind = 'small',
    lead_time_months = 1,
    tasting_available = FALSE,
    highlight_label = 'Para cumpleanos'
WHERE name = 'Menu Coctel Casero'
   OR name = 'Menú Cóctel Casero'
   OR name = 'Mesa Casera para Cumpleanos';

UPDATE event_menus
SET name = 'Menú Familiar Tradicional',
    description = $$Incluye:
- Entrantes al centro: ensaladilla, croquetas, tortilla, chacinas y queso curado.
- Principal a elegir: carrillada al oloroso, pollo al horno con patatas o albondigas caseras.
- Guarniciones de temporada: patatas panaderas, arroz salteado y verduras asadas.
- Pan, picos, alinos y servicio en bandejas listo para compartir.
- Postre casero: tarta de queso, flan de huevo o arroz con leche.$$,
    price_per_person = 24.00,
    min_guests = 12,
    max_guests = 120,
    image_url = 'https://images.unsplash.com/photo-1543353071-10c8ba85a904?auto=format&fit=crop&w=1200&q=80',
    event_kind = 'family',
    lead_time_months = 1,
    tasting_available = FALSE,
    highlight_label = 'Tradicional'
WHERE name = 'Menú Familiar Tradicional'
   OR name = 'Menu Familiar Tradicional';

UPDATE event_menus
SET name = 'Menú Empresa Casero',
    description = $$Incluye:
- Bandejas faciles de servir: mini wraps, empanadas, tortillas, canapes y sandwiches calientes.
- Opciones vegetarianas con hummus, focaccia vegetal, ensalada de pasta y verduras asadas.
- Platos calientes opcionales: arroz campero, pasta gratinada o pollo al curry suave.
- Postres individuales: vasitos dulces, fruta y bizcocho casero.
- Montaje practico para reuniones, formaciones y comidas de equipo.$$,
    price_per_person = 22.00,
    min_guests = 15,
    max_guests = 150,
    image_url = 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1200&q=80',
    event_kind = 'business',
    lead_time_months = 1,
    tasting_available = FALSE,
    highlight_label = 'Empresa'
WHERE name = 'Menú Empresa'
   OR name = 'Menu Empresa'
   OR name = 'Menú Empresa Casero';

UPDATE event_menus
SET name = 'Menú Celebración Premium',
    description = $$Incluye:
- Recepcion con tabla de quesos, ibericos, tostas, tartaletas y brochetas frias.
- Entrantes calientes: croquetas variadas, dados de pescado frito, mini quiches y hojaldres.
- Principal a elegir: solomillo en salsa, merluza al horno o arroz marinero.
- Guarniciones de temporada, panes artesanos y mesa dulce casera.
- Asesoramiento personalizado para cerrar cantidades, tiempos y montaje.$$,
    price_per_person = 34.50,
    min_guests = 20,
    max_guests = 220,
    image_url = 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?auto=format&fit=crop&w=1200&q=80',
    event_kind = 'family',
    lead_time_months = 6,
    tasting_available = FALSE,
    highlight_label = 'Evento grande'
WHERE name = 'Menú Celebración Premium'
   OR name = 'Menu Celebracion Premium';

INSERT INTO event_menus (
  name,
  description,
  price_per_person,
  min_guests,
  max_guests,
  image_url,
  is_active,
  event_kind,
  lead_time_months,
  tasting_available,
  highlight_label
)
SELECT
  'Menú Comunión Casera',
  $$Incluye:
- Recepcion familiar con croquetas, tortillas, mini hamburguesitas, empanadas y canapes suaves.
- Platos pensados para ninos y adultos: pollo al horno, arroz campero, albondigas y pasta gratinada.
- Mesa dulce de comunion con tarta, vasitos de mousse, brownies, fruta y chuches bajo peticion.
- Bebidas, pan, picos, montaje cuidado y coordinacion de horarios con la familia.
- Adaptamos alergias, preferencias infantiles y numero final de invitados.$$,
  29.00,
  25,
  180,
  'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?auto=format&fit=crop&w=1200&q=80',
  TRUE,
  'communion',
  6,
  FALSE,
  'Comuniones'
WHERE NOT EXISTS (SELECT 1 FROM event_menus WHERE name = 'Menú Comunión Casera');

INSERT INTO event_menus (
  name,
  description,
  price_per_person,
  min_guests,
  max_guests,
  image_url,
  is_active,
  event_kind,
  lead_time_months,
  tasting_available,
  highlight_label
)
SELECT
  'Menú Boda Sabor de Casa',
  $$Incluye:
- Prueba de menu para cerrar entrantes, principales, guarniciones y mesa dulce antes del evento.
- Recepcion con ibericos, quesos, croquetas especiales, tostas, tartaletas y aperitivos calientes.
- Principal a elegir con opciones de carne, pescado, arroz o propuesta vegetariana.
- Mesa dulce casera, coordinacion de tiempos, montaje y acompanamiento del equipo.
- Propuesta personalizada segun invitados, estilo de boda, alergias y presupuesto.$$,
  48.00,
  40,
  260,
  'https://images.unsplash.com/photo-1519225421980-715cb0215aed?auto=format&fit=crop&w=1200&q=80',
  TRUE,
  'wedding',
  8,
  TRUE,
  'Prueba de menu'
WHERE NOT EXISTS (SELECT 1 FROM event_menus WHERE name = 'Menú Boda Sabor de Casa');
