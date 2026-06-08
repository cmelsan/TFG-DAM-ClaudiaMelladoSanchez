// @ts-nocheck — Deno Edge Function; el TS LS de VS Code no entiende los imports de Deno ni el global Deno
// supabase/functions/send-encargo-confirmation/index.ts
// Llamada por admin_repository.dart (fire-and-forget) cuando admin confirma un encargo.
// Envía email al cliente con resumen del encargo + código QR de recogida.
//
// Cuerpo esperado: { orderId: string }

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
    const { orderId } = await req.json();
    if (!orderId) {
      return new Response(
        JSON.stringify({ error: "orderId is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ── 1. Obtener el pedido con sus ítems ────────────────────────────────────
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select("*, order_items(quantity, unit_price, subtotal, dish_id, dishes(name))")
      .eq("id", orderId)
      .single();

    if (orderError || !order) {
      return new Response(
        JSON.stringify({ error: "Order not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 2. Obtener perfil del usuario ─────────────────────────────────────────
    let userEmail = "";
    let userName = "Cliente";

    if (order.user_id) {
      const { data: profile } = await supabase
        .from("profiles")
        .select("email, full_name")
        .eq("id", order.user_id)
        .single();

      if (profile) {
        userEmail = profile.email ?? "";
        userName = profile.full_name ?? "Cliente";
      }
    }

    if (!userEmail) {
      // Sin email no podemos enviar — respuesta 200 para no hacer fallar fire-and-forget
      return new Response(
        JSON.stringify({ ok: false, reason: "No user email found" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── 3. Construir el email ─────────────────────────────────────────────────
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(orderId)}`;

    const scheduledDate = order.scheduled_at
      ? new Date(order.scheduled_at).toLocaleString("es-ES", {
          timeZone: "Europe/Madrid",
          weekday: "long",
          year: "numeric",
          month: "long",
          day: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        })
      : "Por confirmar";

    const orderRef = orderId.substring(0, 6).toUpperCase();

    const itemsHtml = (order.order_items as any[])
      .map(
        (item: any) =>
          `<tr>
            <td style="padding: 6px 12px; border-bottom: 1px solid #E5E5E3;">${item.quantity}×</td>
            <td style="padding: 6px 12px; border-bottom: 1px solid #E5E5E3;">${item.dishes?.name ?? item.dish_id}</td>
            <td style="padding: 6px 12px; border-bottom: 1px solid #E5E5E3; text-align: right;">${Number(item.subtotal ?? item.unit_price * item.quantity).toFixed(2)} €</td>
          </tr>`,
      )
      .join("");

    const totalFormatted = Number(order.total).toFixed(2);

    const htmlContent = `
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin:0; padding:0; background-color:#F9FAFB; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color:#F9FAFB; padding: 32px 16px;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF; border-radius:12px; overflow:hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06);">

          <!-- Header -->
          <tr>
            <td style="background-color:#1D9E75; padding: 28px 32px; text-align:center;">
              <h1 style="margin:0; color:#FFFFFF; font-size:22px; font-weight:700;">
                ✅ Encargo Confirmado
              </h1>
              <p style="margin:8px 0 0; color:#E1F5EE; font-size:14px;">
                Referencia: #${orderRef}
              </p>
            </td>
          </tr>

          <!-- Saludo -->
          <tr>
            <td style="padding: 28px 32px 0;">
              <p style="margin:0; font-size:16px; color:#111111;">
                Hola <strong>${userName}</strong>,
              </p>
              <p style="margin:12px 0 0; font-size:15px; color:#374151; line-height:1.6;">
                Tu encargo en <strong>Sabor de Casa</strong> ha sido <strong>confirmado</strong>
                por el restaurante. Recuerda presentar el código QR al llegar al local.
              </p>
            </td>
          </tr>

          <!-- Fecha de recogida -->
          <tr>
            <td style="padding: 20px 32px 0;">
              <table width="100%" cellpadding="0" cellspacing="0"
                style="background-color:#E1F5EE; border-radius:8px; padding:16px;">
                <tr>
                  <td>
                    <p style="margin:0; font-size:12px; color:#0F6E56; text-transform:uppercase; letter-spacing:0.5px; font-weight:600;">
                      📅 Fecha de recogida
                    </p>
                    <p style="margin:6px 0 0; font-size:16px; color:#0F6E56; font-weight:700;">
                      ${scheduledDate}
                    </p>
                  </td>
                </tr>
              </table>
            </td>
          </tr>

          <!-- Detalle del pedido -->
          <tr>
            <td style="padding: 24px 32px 0;">
              <h3 style="margin:0 0 12px; font-size:14px; color:#6B7280; text-transform:uppercase; letter-spacing:0.5px;">
                Detalle del pedido
              </h3>
              <table width="100%" cellpadding="0" cellspacing="0"
                style="border: 1px solid #E5E5E3; border-radius:8px; overflow:hidden;">
                <thead>
                  <tr style="background-color:#F9FAFB;">
                    <th style="padding: 10px 12px; text-align:left; font-size:12px; color:#6B7280; font-weight:600;">Cant.</th>
                    <th style="padding: 10px 12px; text-align:left; font-size:12px; color:#6B7280; font-weight:600;">Plato</th>
                    <th style="padding: 10px 12px; text-align:right; font-size:12px; color:#6B7280; font-weight:600;">Precio</th>
                  </tr>
                </thead>
                <tbody>${itemsHtml}</tbody>
                <tfoot>
                  <tr style="background-color:#F9FAFB;">
                    <td colspan="2" style="padding: 12px; font-weight:700; font-size:15px;">TOTAL</td>
                    <td style="padding: 12px; font-weight:800; font-size:18px; color:#1D9E75; text-align:right;">${totalFormatted} €</td>
                  </tr>
                </tfoot>
              </table>
            </td>
          </tr>

          <!-- QR -->
          <tr>
            <td style="padding: 28px 32px; text-align:center;">
              <h3 style="margin:0 0 16px; font-size:14px; color:#374151;">
                Tu código QR de recogida
              </h3>
              <p style="margin:0 0 16px; font-size:13px; color:#6B7280;">
                Muestra este código en el mostrador del restaurante:
              </p>
              <img src="${qrUrl}" alt="QR de recogida" width="200" height="200"
                style="border: 3px solid #1D9E75; border-radius:8px;" />
              <p style="margin:12px 0 0; font-size:11px; color:#9CA3AF;">
                Referencia del encargo: #${orderRef}
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color:#F9FAFB; padding:20px 32px; text-align:center; border-top:1px solid #E5E5E3;">
              <p style="margin:0; font-size:12px; color:#9CA3AF;">
                Sabor de Casa · Si tienes alguna duda, contacta con nosotros.
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

    // ── 4. Enviar vía Brevo ───────────────────────────────────────────────────
    const brevoRes = await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": BREVO_API_KEY,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        sender: { email: BREVO_SENDER_EMAIL, name: "Sabor de Casa" },
        to: [{ email: userEmail, name: userName }],
        subject: `✅ Encargo confirmado – #${orderRef} | Sabor de Casa`,
        htmlContent,
      }),
    });

    if (!brevoRes.ok) {
      const errText = await brevoRes.text();
      console.error("Brevo error:", errText);
      return new Response(
        JSON.stringify({ error: "Failed to send email", detail: errText }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ ok: true, sentTo: userEmail }),
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
