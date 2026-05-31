// @ts-nocheck — Deno Edge Function; el TS LS de VS Code no entiende los imports de Deno ni el global Deno
// supabase/functions/send-encargo-reminders/index.ts
// Cron diario (9:00 Europe/Madrid) que envía recordatorio por email a todos los
// clientes con encargos programados para HOY que aún no están entregados ni cancelados.
//
// Para activar el cron, ejecutar en el SQL Editor de Supabase:
//
//   select cron.schedule(
//     'encargo-reminders-daily',
//     '0 8 * * *',   -- 8 UTC = 9-10 h Madrid (ajustar en verano/invierno)
//     $$
//     select net.http_post(
//       url    := 'https://vrxliepwzvdrcxpdgpnd.supabase.co/functions/v1/send-encargo-reminders',
//       headers := jsonb_build_object(
//         'Content-Type',  'application/json',
//         'Authorization', 'Bearer ' || current_setting('app.service_role_key')
//       ),
//       body   := '{}'::jsonb
//     );
//     $$
//   );
//
// Alternativamente se puede llamar manualmente con POST {} desde el panel de Supabase.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const BREVO_API_KEY = Deno.env.get("BREVO_API_KEY")!;
const BREVO_SENDER_EMAIL =
  Deno.env.get("BREVO_SENDER_EMAIL") ?? "noreply@sabordecasa.com";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ── 1. Calcular rango de hoy en UTC ───────────────────────────────────────
    const now = new Date();
    const todayStart = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 0, 0, 0),
    );
    const todayEnd = new Date(
      Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 23, 59, 59),
    );

    // ── 2. Obtener encargos de hoy con estado relevante ───────────────────────
    const { data: orders, error } = await supabase
      .from("orders")
      .select("*, order_items(*)")
      .eq("order_type", "encargo")
      .not("status", "in", '("cancelled","delivered")')
      .gte("scheduled_at", todayStart.toISOString())
      .lte("scheduled_at", todayEnd.toISOString());

    if (error) {
      console.error("Error fetching orders:", error);
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    if (!orders || orders.length === 0) {
      return new Response(
        JSON.stringify({ ok: true, sent: 0, message: "No encargos today" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 3. Enviar recordatorio por cada encargo ───────────────────────────────
    let sent = 0;
    let skipped = 0;
    const errors: string[] = [];

    for (const order of orders) {
      try {
        if (!order.user_id) { skipped++; continue; }

        const { data: profile } = await supabase
          .from("profiles")
          .select("email, full_name")
          .eq("id", order.user_id)
          .single();

        if (!profile?.email) { skipped++; continue; }

        const userEmail = profile.email;
        const userName = profile.full_name ?? "Cliente";
        const orderRef = order.id.substring(0, 6).toUpperCase();
        const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=${encodeURIComponent(order.id)}`;

        const scheduledDate = order.scheduled_at
          ? new Date(order.scheduled_at).toLocaleString("es-ES", {
              timeZone: "Europe/Madrid",
              weekday: "long",
              hour: "2-digit",
              minute: "2-digit",
            })
          : "Hoy";

        const STATUS_LABEL: Record<string, string> = {
          pending:   "Pendiente de confirmación",
          confirmed: "Confirmado ✅",
          preparing: "En preparación 👨‍🍳",
          ready:     "Listo para recoger 🎉",
        };

        const statusLabel = STATUS_LABEL[order.status] ?? order.status;

        const itemsHtml = (order.order_items as any[])
          .map(
            (item: any) =>
              `<tr>
                <td style="padding:5px 10px;border-bottom:1px solid #E5E5E3;">${item.quantity}×</td>
                <td style="padding:5px 10px;border-bottom:1px solid #E5E5E3;">${item.name ?? item.dish_id}</td>
              </tr>`,
          )
          .join("");

        const totalFormatted = Number(order.total).toFixed(2);

        const htmlContent = `
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1.0"/></head>
<body style="margin:0;padding:0;background-color:#F9FAFB;font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#F9FAFB;padding:32px 16px;">
    <tr>
      <td align="center">
        <table width="580" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF;border-radius:12px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.06);">

          <!-- Header -->
          <tr>
            <td style="background-color:#1D9E75;padding:24px 28px;text-align:center;">
              <h1 style="margin:0;color:#FFFFFF;font-size:20px;font-weight:700;">
                🔔 Recordatorio de tu encargo
              </h1>
              <p style="margin:6px 0 0;color:#E1F5EE;font-size:13px;">Referencia: #${orderRef}</p>
            </td>
          </tr>

          <!-- Cuerpo -->
          <tr>
            <td style="padding:24px 28px;">
              <p style="margin:0;font-size:15px;color:#111111;">
                Hola <strong>${userName}</strong>,
              </p>
              <p style="margin:10px 0 0;font-size:14px;color:#374151;line-height:1.6;">
                Te recordamos que tienes un encargo en <strong>Sabor de Casa</strong>
                programado para <strong>hoy ${scheduledDate}</strong>.
              </p>
            </td>
          </tr>

          <!-- Estado -->
          <tr>
            <td style="padding:0 28px;">
              <table width="100%" cellpadding="0" cellspacing="0"
                style="background-color:#E1F5EE;border-radius:8px;padding:14px;">
                <tr>
                  <td>
                    <p style="margin:0;font-size:12px;color:#0F6E56;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;">Estado actual</p>
                    <p style="margin:4px 0 0;font-size:15px;color:#0F6E56;font-weight:700;">${statusLabel}</p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Artículos -->
          <tr>
            <td style="padding:20px 28px 0;">
              <p style="margin:0 0 8px;font-size:12px;color:#6B7280;text-transform:uppercase;letter-spacing:0.5px;font-weight:600;">Tu pedido</p>
              <table width="100%" cellpadding="0" cellspacing="0"
                style="border:1px solid #E5E5E3;border-radius:8px;overflow:hidden;">
                <tbody>${itemsHtml}</tbody>
                <tfoot>
                  <tr style="background-color:#F9FAFB;">
                    <td style="padding:10px;font-weight:700;">Total</td>
                    <td style="padding:10px;font-weight:800;color:#1D9E75;text-align:right;">${totalFormatted} €</td>
                  </tr>
                </tfoot>
              </table>
            </td>
          </tr>

          <!-- QR -->
          <tr>
            <td style="padding:24px 28px;text-align:center;">
              <p style="margin:0 0 12px;font-size:13px;color:#6B7280;">
                Presenta este QR al recoger tu pedido:
              </p>
              <img src="${qrUrl}" alt="QR de recogida" width="180" height="180"
                style="border:3px solid #1D9E75;border-radius:8px;"/>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#F9FAFB;padding:16px 28px;text-align:center;border-top:1px solid #E5E5E3;">
              <p style="margin:0;font-size:11px;color:#9CA3AF;">
                Sabor de Casa · Este es un recordatorio automático.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
        `;

        const brevoRes = await fetch("https://api.brevo.com/v3/smtp/email", {
          method: "POST",
          headers: {
            "api-key": BREVO_API_KEY,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            sender: { email: BREVO_SENDER_EMAIL, name: "Sabor de Casa" },
            to: [{ email: userEmail, name: userName }],
            subject: `🔔 Recordatorio: tu encargo de hoy #${orderRef} | Sabor de Casa`,
            htmlContent,
          }),
        });

        if (brevoRes.ok) {
          sent++;
        } else {
          const errText = await brevoRes.text();
          errors.push(`Order ${orderRef}: ${errText}`);
        }
      } catch (itemErr) {
        errors.push(`Order ${order.id}: ${String(itemErr)}`);
      }
    }

    return new Response(
      JSON.stringify({ ok: true, total: orders.length, sent, skipped, errors }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
