// supabase/functions/send-welcome-email/index.ts
// Edge Function que envía email de bienvenida cuando un usuario se registra.
//
// Webhook necesario en Supabase → Database → Webhooks:
//   Tabla: profiles   Evento: INSERT   → esta función

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

    // Payload del Database Webhook (INSERT en profiles)
    const record = body.record ?? body;
    const userId: string    = record.id;
    const userEmail: string = record.email;
    const userName: string  = record.full_name ?? "Cliente";

    if (!userId || !userEmail) {
      return new Response(
        JSON.stringify({ error: "Missing user data" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const brevoKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoKey) {
      return new Response(
        JSON.stringify({ skipped: "BREVO_API_KEY not configured" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const emailRes = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": brevoKey,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({
        sender: {
          name: "Sabor de Casa",
          email: Deno.env.get("BREVO_SENDER_EMAIL") ?? "noreply@sabordecasa.com",
        },
        to: [{ email: userEmail, name: userName }],
        subject: "¡Bienvenido/a a Sabor de Casa! 🍽️",
        htmlContent: buildWelcomeHtml(userName),
      }),
    });

    return new Response(
      JSON.stringify({ ok: true, status: emailRes.status, to: userEmail }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("send-welcome-email error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// ── Template HTML de bienvenida ───────────────────────────────────────────────

function buildWelcomeHtml(userName: string): string {
  const year = new Date().getFullYear();

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>¡Bienvenido/a a Sabor de Casa!</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f0;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f0;padding:32px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:16px;overflow:hidden;max-width:600px;">

        <!-- Header -->
        <tr>
          <td style="background:#1a7a7a;padding:40px 32px;text-align:center;">
            <p style="margin:0;font-size:48px;line-height:1;">🍽️</p>
            <h1 style="margin:12px 0 4px;color:#fff;font-size:26px;font-weight:bold;">Sabor de Casa</h1>
            <p style="margin:0;color:#b2dfdb;font-size:14px;">Comida preparada con cariño · Sanlúcar de Barrameda</p>
          </td>
        </tr>

        <!-- Bienvenida -->
        <tr>
          <td style="padding:40px 32px 20px;">
            <h2 style="margin:0 0 16px;font-size:22px;color:#111827;">¡Hola, ${userName}! 👋</h2>
            <p style="margin:0 0 14px;font-size:15px;color:#374151;line-height:1.7;">
              Nos alegra mucho que te hayas unido a <strong>Sabor de Casa</strong>. 
              Ahora puedes disfrutar de nuestra comida preparada para llevar y nuestros 
              servicios de catering para eventos especiales.
            </p>
            <p style="margin:0;font-size:15px;color:#374151;line-height:1.7;">
              Con tu cuenta podrás:
            </p>
          </td>
        </tr>

        <!-- Features -->
        <tr>
          <td style="padding:0 32px 28px;">
            <table width="100%" cellpadding="0" cellspacing="0">
              ${[
                ["🛒", "Pedir online", "Realiza pedidos para llevar, a domicilio o recogida en tienda."],
                ["📅", "Encargos anticipados", "Programa tus pedidos con días de antelación."],
                ["🎉", "Catering para eventos", "Solicita presupuesto para celebraciones y eventos."],
                ["🔔", "Notificaciones en tiempo real", "Recibe actualizaciones del estado de tu pedido."],
                ["⭐", "Guarda tus favoritos", "Marca los platos que más te gustan para pedirlos rápido."],
              ].map(([icon, title, desc]) => `
              <tr>
                <td style="padding:10px 0;vertical-align:top;width:40px;">
                  <span style="font-size:22px;">${icon}</span>
                </td>
                <td style="padding:10px 0 10px 10px;vertical-align:top;">
                  <p style="margin:0 0 2px;font-size:14px;font-weight:bold;color:#111827;">${title}</p>
                  <p style="margin:0;font-size:13px;color:#6b7280;">${desc}</p>
                </td>
              </tr>`).join("")}
            </table>
          </td>
        </tr>

        <!-- CTA -->
        <tr>
          <td style="padding:0 32px 36px;text-align:center;">
            <p style="margin:0 0 6px;font-size:14px;color:#6b7280;">¿Tienes alguna pregunta?</p>
            <p style="margin:0;font-size:14px;color:#374151;">
              Escríbenos a <a href="mailto:sabordecasasanlucar@gmail.com" style="color:#1a7a7a;font-weight:bold;">sabordecasasanlucar@gmail.com</a>
            </p>
          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="background:#f9fafb;padding:20px 32px;text-align:center;border-top:1px solid #e5e7eb;">
            <p style="margin:0;font-size:12px;color:#9ca3af;">
              © ${year} Sabor de Casa · Todos los derechos reservados
            </p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>`;
}
