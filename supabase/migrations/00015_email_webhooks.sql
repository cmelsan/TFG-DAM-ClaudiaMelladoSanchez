-- ============================================================
-- SABOR DE CASA — Webhooks de email via Brevo
-- Crea triggers que llaman a las Edge Functions automáticamente:
--   1. Pedido nuevo     → send-order-notification (INSERT orders)
--   2. Cambio estado    → send-order-notification (UPDATE orders)
--   3. Registro usuario → send-welcome-email       (INSERT profiles)
-- ============================================================

-- Eliminar triggers anteriores si existen
DROP TRIGGER IF EXISTS on_new_order_email    ON public.orders;
DROP TRIGGER IF EXISTS on_order_status_email ON public.orders;
DROP TRIGGER IF EXISTS on_new_profile_welcome ON public.profiles;

-- ── 1. Confirmación de nuevo pedido ──────────────────────────────────────────
CREATE TRIGGER on_new_order_email
  AFTER INSERT ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION supabase_functions.http_request(
    'https://vrxliepwzvdrcxpdgpnd.supabase.co/functions/v1/send-order-notification',
    'POST',
    '{"Content-Type":"application/json"}',
    '{}',
    '5000'
  );

-- ── 2. Cambio de estado del pedido ───────────────────────────────────────────
CREATE TRIGGER on_order_status_email
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION supabase_functions.http_request(
    'https://vrxliepwzvdrcxpdgpnd.supabase.co/functions/v1/send-order-notification',
    'POST',
    '{"Content-Type":"application/json"}',
    '{}',
    '5000'
  );

-- ── 3. Bienvenida al registrarse ─────────────────────────────────────────────
CREATE TRIGGER on_new_profile_welcome
  AFTER INSERT ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION supabase_functions.http_request(
    'https://vrxliepwzvdrcxpdgpnd.supabase.co/functions/v1/send-welcome-email',
    'POST',
    '{"Content-Type":"application/json"}',
    '{}',
    '5000'
  );
