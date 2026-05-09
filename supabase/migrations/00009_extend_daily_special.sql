-- Extiende daily_special con los campos de texto del menú del día
-- y el precio especial del menú completo.

ALTER TABLE daily_special
  ADD COLUMN IF NOT EXISTS primero_text  TEXT,
  ADD COLUMN IF NOT EXISTS segundo_text  TEXT,
  ADD COLUMN IF NOT EXISTS postre_text   TEXT,
  ADD COLUMN IF NOT EXISTS bebida_text   TEXT,
  ADD COLUMN IF NOT EXISTS menu_price    NUMERIC(8, 2);
