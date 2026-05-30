-- ── 00020_notifications.sql ──────────────────────────────────────────────────
-- Tabla de notificaciones in-app por usuario.
-- Se inserta desde Edge Functions (p.ej. al actualizar estado de un pedido)
-- o desde el handler FCM cuando se recibe un mensaje en background.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title       TEXT        NOT NULL,
  body        TEXT        NOT NULL,
  type        TEXT        NOT NULL DEFAULT 'general',
  -- tipos: 'order_update' | 'promo' | 'catering' | 'general'
  is_read     BOOLEAN     NOT NULL DEFAULT false,
  data        JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_user_created_idx
  ON notifications (user_id, created_at DESC);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Cada usuario solo ve sus propias notificaciones
CREATE POLICY "Usuario ve sus notificaciones"
  ON notifications FOR SELECT
  USING (user_id = auth.uid());

-- El propio usuario puede marcar como leído (UPDATE is_read)
CREATE POLICY "Usuario actualiza sus notificaciones"
  ON notifications FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Los admins (y service_role) pueden insertar notificaciones para cualquier usuario
CREATE POLICY "Admin inserta notificaciones"
  ON notifications FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
        AND profiles.role IN ('admin', 'employee')
    )
  );
