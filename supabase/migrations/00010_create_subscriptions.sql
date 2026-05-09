-- Tabla para suscripciones de newsletter / WhatsApp desde la web pública.

CREATE TABLE IF NOT EXISTS subscriptions (
  id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  email      TEXT,
  phone      TEXT,
  type       TEXT          NOT NULL CHECK (type IN ('email', 'whatsapp')),
  created_at TIMESTAMPTZ   NOT NULL DEFAULT now(),
  CONSTRAINT subscriptions_contact_check CHECK (
    (type = 'email'    AND email IS NOT NULL) OR
    (type = 'whatsapp' AND phone IS NOT NULL)
  )
);

-- RLS: cualquiera puede insertar; solo admin puede leer/borrar.
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "subscriptions_insert_public"
  ON subscriptions FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "subscriptions_select_admin"
  ON subscriptions FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
  );

CREATE POLICY "subscriptions_delete_admin"
  ON subscriptions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
  );
