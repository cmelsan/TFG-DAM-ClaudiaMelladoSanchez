-- ── 00021_newsletter_sends.sql ───────────────────────────────────────────────
-- Tabla de log de comunicados enviados desde el panel de admin.
-- Permite al admin ver el historial de newsletters enviados.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS newsletter_sends (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id        UUID        NOT NULL REFERENCES profiles(id) ON DELETE SET NULL,
  subject         TEXT        NOT NULL,
  body            TEXT        NOT NULL,
  channels        TEXT[]      NOT NULL DEFAULT '{}',
  emails_sent     INT         NOT NULL DEFAULT 0,
  inapp_inserted  INT         NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE newsletter_sends ENABLE ROW LEVEL SECURITY;

-- Solo admin puede ver el historial
CREATE POLICY "Admin ve historial de envios"
  ON newsletter_sends FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role = 'admin'
    )
  );

-- Solo service_role puede insertar (lo hace la Edge Function)
-- No se necesita policy de INSERT porque service_role bypasea RLS.
