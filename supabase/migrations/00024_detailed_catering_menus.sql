-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00024 · Detalle de platos incluidos en menús de catering
-- ─────────────────────────────────────────────────────────────────────────────

UPDATE event_menus
SET description = $$Incluye:
- Mesa de bienvenida con aceitunas aliñadas, picos artesanos y frutos secos.
- Aperitivos fríos: ensaladilla casera en vasito, tosta de salmorejo con jamón y mini brochetas caprese.
- Aperitivos calientes: croquetas de puchero, mini tortillas, lagrimitas de pollo y empanadillas caseras.
- Bocaditos dulces: mini brownies, vasitos de arroz con leche y fruta cortada.
- Servicio tipo cóctel con montaje básico y reposición durante el evento.$$,
    price_per_person = 18.50,
    min_guests = 10,
    max_guests = 80
WHERE name = 'Menú Cóctel Casero';

UPDATE event_menus
SET description = $$Incluye:
- Entrantes para compartir: ensaladilla, croquetas, tortilla de patatas, chacinas y queso curado.
- Principal a elegir: carrillada al oloroso, pollo al horno con patatas o albóndigas en salsa casera.
- Guarniciones: patatas panaderas, arroz salteado y verduras de temporada.
- Pan, picos y aliños incluidos.
- Postre casero: tarta de queso, flan de huevo o arroz con leche.
- Ideal para comidas familiares, cumpleaños y celebraciones en casa.$$,
    price_per_person = 24.00,
    min_guests = 12,
    max_guests = 120
WHERE name = 'Menú Familiar Tradicional';

UPDATE event_menus
SET description = $$Incluye:
- Bandejas saladas fáciles de servir: mini wraps, sandwiches gourmet, tortillas, empanadas y surtido de canapés.
- Opciones vegetarianas: hummus con crudités, focaccia vegetal y ensalada de pasta.
- Platos calientes opcionales en formato bandeja: arroz campero, pasta gratinada o pollo al curry suave.
- Postres individuales: vasitos de mousse, fruta y bizcocho casero.
- Bebidas básicas: agua, refrescos y café.
- Montaje práctico para reuniones, formaciones y comidas de empresa.$$,
    price_per_person = 21.75,
    min_guests = 15,
    max_guests = 150
WHERE name = 'Menú Empresa';

UPDATE event_menus
SET description = $$Incluye:
- Recepción premium: tabla de quesos, ibéricos, tostas de salmón, tartaletas y brochetas frías.
- Entrantes calientes: croquetas variadas, dados de pescado frito, mini quiches y hojaldres salados.
- Principal a elegir: solomillo en salsa, merluza al horno o arroz marinero.
- Guarniciones de temporada y panes artesanos.
- Mesa dulce: tartas caseras, macarons, vasitos dulces y fruta preparada.
- Bebidas, montaje cuidado y asesoramiento personalizado para cerrar tiempos y cantidades.$$,
    price_per_person = 34.50,
    min_guests = 20,
    max_guests = 220
WHERE name = 'Menú Celebración Premium';