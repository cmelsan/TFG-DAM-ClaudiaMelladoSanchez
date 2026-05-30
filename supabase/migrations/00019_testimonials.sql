-- ── 00019_testimonials.sql ────────────────────────────────────────────────────
-- Tabla de testimonios curados para mostrar en la Home (acceso público).
-- Se usa en lugar de una query directa sobre order_ratings para evitar exponer
-- datos personales y permitir lectura anónima de forma segura.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS testimonials (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_name TEXT        NOT NULL,
  body        TEXT        NOT NULL,
  rating      INT         NOT NULL DEFAULT 5 CHECK (rating BETWEEN 1 AND 5),
  is_featured BOOLEAN     NOT NULL DEFAULT true,
  position    INT         NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario (incluido anónimo) puede leer los testimonios destacados.
CREATE POLICY "Testimonios públicos"
  ON testimonials FOR SELECT
  USING (is_featured = true);

-- Solo admins pueden insertar / actualizar / borrar.
CREATE POLICY "Admin gestiona testimonios"
  ON testimonials FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
  );

-- ── Seed data ────────────────────────────────────────────────────────────────
INSERT INTO testimonials (author_name, body, rating, is_featured, position)
VALUES
  (
    'María G.',
    'La mejor comida casera de Sanlúcar. El pollo asado es espectacular, igual que el de mi abuela. Llevo meses pidiendo cada semana.',
    5, true, 1
  ),
  (
    'Carlos R.',
    'Pedimos catering para la comunión de mi hija y fue todo un éxito. La organización perfecta y la comida deliciosa.',
    5, true, 2
  ),
  (
    'Ana L.',
    'Los encargos son comodísimos. Dejo el pedido el día anterior y lo recojo recién hecho. Sin colas, sin esperas.',
    5, true, 3
  ),
  (
    'José M.',
    'Nunca había probado un rabo de toro tan bien guisado. Se nota que cocinan con cariño y buenos ingredientes.',
    5, true, 4
  ),
  (
    'Lucía P.',
    'Ideal para llevar la comida a la oficina. Porciones generosas, precio justo y siempre llega calentito.',
    5, true, 5
  ),
  (
    'Antonio S.',
    'El menú del día es una pasada. Primer plato, segundo, postre y bebida por un precio increíble. Recomendadísimo.',
    5, true, 6
  );
