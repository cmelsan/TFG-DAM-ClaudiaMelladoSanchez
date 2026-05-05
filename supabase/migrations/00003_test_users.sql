-- ============================================================
-- SABOR DE CASA — Usuarios de prueba
-- ============================================================
-- PASO 1: Crear usuarios en Supabase Dashboard o a través de la app.
--
-- Opción A (recomendada para desarrollo):
--   Supabase Dashboard → Authentication → Users → "Add user"
--   Crear estos usuarios (marcar "Auto Confirm User"):
--     admin@sabordecasa.com      contraseña: Admin1234!
--     cocina@sabordecasa.com     contraseña: Cocina1234!
--     repartidor@sabordecasa.com contraseña: Repartidor1234!
--     cliente@sabordecasa.com    contraseña: Cliente1234!
--
-- Opción B: Registrarlos desde la pantalla de registro de la app.
--
-- PASO 2: Ejecutar este script para asignar roles.
-- ============================================================

-- Asignar rol admin
UPDATE profiles
SET role = 'admin',
    full_name = 'Administrador'
WHERE email = 'admin@sabordecasa.com';

-- Asignar rol employee — Cocinero
UPDATE profiles
SET role = 'employee',
    full_name = 'Chef Cocina'
WHERE email = 'cocina@sabordecasa.com';

-- Asignar rol employee — Repartidor
UPDATE profiles
SET role = 'employee',
    full_name = 'Repartidor'
WHERE email = 'repartidor@sabordecasa.com';

-- El cliente mantiene role = 'client' (asignado por el trigger)
UPDATE profiles
SET full_name = 'Cliente Prueba'
WHERE email = 'cliente@sabordecasa.com';

-- ============================================================
-- VERIFICACIÓN: comprobar que los roles se asignaron bien
-- ============================================================
SELECT email, role, full_name, is_active
FROM profiles
WHERE email IN (
    'admin@sabordecasa.com',
    'cocina@sabordecasa.com',
    'repartidor@sabordecasa.com',
    'cliente@sabordecasa.com'
)
ORDER BY role;
