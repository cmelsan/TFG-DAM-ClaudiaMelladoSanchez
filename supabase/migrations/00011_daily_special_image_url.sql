-- Añade una imagen personalizada al menú del día.
-- El admin puede subir una URL de imagen que sustituye a la foto del plato.
ALTER TABLE daily_special
  ADD COLUMN IF NOT EXISTS image_url TEXT;
