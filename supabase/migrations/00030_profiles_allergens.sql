-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 00030 · Alérgenos del usuario en tabla profiles
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS allergens TEXT[] NOT NULL DEFAULT '{}';

COMMENT ON COLUMN profiles.allergens IS
  'Alérgenos declarados por el usuario (14 alérgenos UE Reglamento 1169/2011). '
  'Valores posibles: gluten, lactosa, huevo, pescado, marisco, frutos_secos, '
  'soja, apio, mostaza, sesamo, sulfitos, moluscos, altramuces, cacahuete.';
