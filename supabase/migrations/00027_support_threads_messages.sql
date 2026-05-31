-- Internal support conversations between clients and admins.

CREATE TABLE support_threads (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  subject            TEXT NOT NULL,
  category           TEXT NOT NULL DEFAULT 'general'
    CHECK (category IN ('general', 'order', 'catering', 'incident')),
  status             TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open', 'waiting_admin', 'waiting_customer', 'closed')),
  last_message       TEXT,
  last_message_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  unread_for_admin   INTEGER NOT NULL DEFAULT 0,
  unread_for_customer INTEGER NOT NULL DEFAULT 0,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE support_messages (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id   UUID NOT NULL REFERENCES support_threads(id) ON DELETE CASCADE,
  sender_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sender_role TEXT NOT NULL CHECK (sender_role IN ('client', 'admin')),
  body        TEXT NOT NULL CHECK (length(trim(body)) > 0),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_support_threads_user_id ON support_threads(user_id);
CREATE INDEX idx_support_threads_status ON support_threads(status);
CREATE INDEX idx_support_threads_last_message_at ON support_threads(last_message_at DESC);
CREATE INDEX idx_support_messages_thread_id_created ON support_messages(thread_id, created_at);

ALTER TABLE support_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clientes ven sus conversaciones"
  ON support_threads FOR SELECT
  USING (user_id = auth.uid() OR get_my_role() = 'admin');

CREATE POLICY "Clientes crean sus conversaciones"
  ON support_threads FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Participantes actualizan conversaciones"
  ON support_threads FOR UPDATE
  USING (user_id = auth.uid() OR get_my_role() = 'admin')
  WITH CHECK (user_id = auth.uid() OR get_my_role() = 'admin');

CREATE POLICY "Participantes ven mensajes"
  ON support_messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM support_threads st
      WHERE st.id = support_messages.thread_id
        AND (st.user_id = auth.uid() OR get_my_role() = 'admin')
    )
  );

CREATE POLICY "Participantes envian mensajes"
  ON support_messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid()
    AND (
      (sender_role = 'client' AND EXISTS (
        SELECT 1
        FROM support_threads st
        WHERE st.id = support_messages.thread_id
          AND st.user_id = auth.uid()
      ))
      OR (sender_role = 'admin' AND get_my_role() = 'admin')
    )
  );
