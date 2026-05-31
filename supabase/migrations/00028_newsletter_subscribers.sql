-- Newsletter: suscriptores opt-in desde la web pública.

CREATE TABLE newsletter_subscribers (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT NOT NULL UNIQUE,
  full_name       TEXT,
  status          TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'unsubscribed', 'bounced')),
  source          TEXT NOT NULL DEFAULT 'web',
  locale          TEXT NOT NULL DEFAULT 'es',
  user_id         UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  unsubscribed_at TIMESTAMPTZ
);

CREATE INDEX idx_newsletter_status ON newsletter_subscribers(status);
CREATE INDEX idx_newsletter_created_at ON newsletter_subscribers(created_at DESC);

ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

-- Cualquiera (incluso anónimo) puede dar su email de alta.
CREATE POLICY "Cualquiera se suscribe"
  ON newsletter_subscribers FOR INSERT
  WITH CHECK (true);

-- Solo admins pueden listar/borrar.
CREATE POLICY "Admins ven suscriptores"
  ON newsletter_subscribers FOR SELECT
  USING (get_my_role() = 'admin');

CREATE POLICY "Admins editan suscriptores"
  ON newsletter_subscribers FOR UPDATE
  USING (get_my_role() = 'admin')
  WITH CHECK (get_my_role() = 'admin');

CREATE POLICY "Admins borran suscriptores"
  ON newsletter_subscribers FOR DELETE
  USING (get_my_role() = 'admin');
