-- Notificación por email para formularios públicos de contacto.
-- Se gestiona desde Flutter tras el insert (igual que pedidos),
-- para evitar dependencia de extensiones de trigger no disponibles.

DROP TRIGGER IF EXISTS on_new_contact_message_email ON public.contact_messages;

-- Política RLS: permite inserts anónimos (formulario público no requiere cuenta).
DROP POLICY IF EXISTS "Cualquiera puede enviar un mensaje" ON public.contact_messages;

CREATE POLICY "Cualquiera puede enviar un mensaje"
  ON public.contact_messages FOR INSERT
  WITH CHECK (TRUE);
