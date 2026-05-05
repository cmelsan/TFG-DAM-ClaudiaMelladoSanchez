// supabase/functions/send-order-notification/index.ts
// Edge Function que envía notificación (email via Brevo o push via FCM)
// cuando el estado de un pedido cambia a un estado relevante.
//
// Llamada desde:
//   - Supabase Database Webhook (tabla orders, evento UPDATE) — para notificaciones automáticas.
//   - Manualmente desde el cliente con el anon key al actualizar estado.
//
// Payload esperado:
// {
//   "orderId": "uuid",
//   "newStatus": "accepted" | "en_preparacion" | "ready" | "delivering" | "delivered",
//   "orderType": "domicilio" | "recogida" | "encargo" | "mostrador",
//   "userId": "uuid"            // dueño del pedido
// }

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── Constantes de estado ──────────────────────────────────────────────────────

/** Estados que disparan una notificación al cliente */
const NOTIFY_STATUSES = new Set([
  "accepted",
  "en_preparacion",
  "ready",
  "delivering",
  "delivered",
]);

function getStatusLabel(status: string, orderType: string): string {
  const labels: Record<string, string> = {
    accepted: "¡Tu pedido ha sido aceptado!",
    en_preparacion: "Tu pedido está en preparación",
    ready:
      orderType === "domicilio"
        ? "Tu pedido está listo y saliendo para entrega"
        : "¡Tu pedido está listo para recoger!",
    delivering: "Tu pedido está en camino",
    delivered: "¡Pedido entregado! Esperamos que lo disfrutes 🍽️",
  };
  return labels[status] ?? "Actualización de tu pedido";
}

function getStatusBody(status: string, orderType: string): string {
  const bodies: Record<string, string> = {
    accepted:
      "Hemos recibido y confirmado tu pedido. Ya estamos preparándolo.",
    en_preparacion:
      "Nuestro equipo está cocinando tu pedido con todo el cariño.",
    ready:
      orderType === "domicilio"
        ? "Tu repartidor saldrá en breve."
        : "Muestra tu QR en caja para recogerlo.",
    delivering: "Tu repartidor está de camino. ¡Prepárate para recibirlo!",
    delivered:
      "Pedido entregado con éxito. ¡Gracias por elegir Sabor de Casa!",
  };
  return (
    bodies[status] ??
    "El estado de tu pedido ha cambiado. Consulta la aplicación para más detalles."
  );
}

// ── Handler principal ─────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

    // Soporte para payload de Database Webhook (type: INSERT/UPDATE)
    // o llamada directa con el payload simplificado.
    let orderId: string;
    let newStatus: string;
    let orderType: string;
    let userId: string;

    if (body.type === "UPDATE" && body.record) {
      // Webhook de Supabase
      const record = body.record;
      orderId = record.id;
      newStatus = record.status;
      orderType = record.order_type;
      userId = record.user_id;
    } else {
      orderId = body.orderId;
      newStatus = body.newStatus;
      orderType = body.orderType;
      userId = body.userId;
    }

    if (!orderId || !newStatus || !userId) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Solo notificar en estados relevantes
    if (!NOTIFY_STATUSES.has(newStatus)) {
      return new Response(
        JSON.stringify({ skipped: true, reason: "Status not in notify list" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Obtener datos del usuario (email + push tokens)
    const [profileResult, tokensResult] = await Promise.all([
      supabase
        .from("profiles")
        .select("full_name, platform")
        .eq("id", userId)
        .single(),
      supabase.from("push_tokens").select("token").eq("user_id", userId),
    ]);

    // Obtener email del usuario (está en auth.users, no en profiles)
    const { data: authUser } = await supabase.auth.admin.getUserById(userId);
    const userEmail = authUser?.user?.email;
    const userName = profileResult.data?.full_name ?? "Cliente";

    const title = getStatusLabel(newStatus, orderType);
    const messageBody = getStatusBody(newStatus, orderType);

    const results: Record<string, unknown> = {};

    // ── Push FCM (si hay tokens registrados) ──────────────────────────────────
    const fcmTokens: string[] =
      (tokensResult.data ?? []).map((r: { token: string }) => r.token);

    if (fcmTokens.length > 0) {
      const fcmKey = Deno.env.get("FCM_SERVER_KEY");
      if (fcmKey) {
        try {
          const fcmRes = await fetch("https://fcm.googleapis.com/fcm/send", {
            method: "POST",
            headers: {
              Authorization: `key=${fcmKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              registration_ids: fcmTokens,
              notification: {
                title,
                body: messageBody,
                sound: "default",
              },
              data: {
                orderId,
                status: newStatus,
                orderType,
                click_action: "FLUTTER_NOTIFICATION_CLICK",
              },
              priority: "high",
            }),
          });
          results.fcm = { sent: fcmTokens.length, status: fcmRes.status };
        } catch (e) {
          results.fcm = { error: String(e) };
        }
      } else {
        results.fcm = { skipped: "FCM_SERVER_KEY not configured" };
      }
    }

    // ── Email Brevo (si hay email disponible) ─────────────────────────────────
    if (userEmail) {
      const brevoKey = Deno.env.get("BREVO_API_KEY");
      if (brevoKey) {
        try {
          const orderShortId = orderId.substring(0, 8).toUpperCase();
          const emailRes = await fetch(
            "https://api.brevo.com/v3/smtp/email",
            {
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
                subject: `${title} · Pedido #${orderShortId}`,
                htmlContent: buildEmailHtml({
                  userName,
                  title,
                  body: messageBody,
                  orderId,
                  orderShortId,
                  newStatus,
                  orderType,
                }),
              }),
            }
          );
          results.email = {
            sent: true,
            to: userEmail,
            status: emailRes.status,
          };
        } catch (e) {
          results.email = { error: String(e) };
        }
      } else {
        results.email = { skipped: "BREVO_API_KEY not configured" };
      }
    }

    return new Response(JSON.stringify({ ok: true, results }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("send-order-notification error:", err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

// ── Template de email HTML ────────────────────────────────────────────────────

function buildEmailHtml(params: {
  userName: string;
  title: string;
  body: string;
  orderId: string;
  orderShortId: string;
  newStatus: string;
  orderType: string;
}): string {
  const { userName, title, body, orderShortId, newStatus } = params;

  const statusColor: Record<string, string> = {
    accepted: "#22c55e",
    en_preparacion: "#f97316",
    ready: "#3b82f6",
    delivering: "#8b5cf6",
    delivered: "#22c55e",
  };
  const color = statusColor[newStatus] ?? "#22c55e";

  return `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f0;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f0;padding:32px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;max-width:600px;">
          <!-- Header -->
          <tr>
            <td style="background:${color};padding:32px;text-align:center;">
              <h1 style="margin:0;color:#ffffff;font-size:24px;font-weight:bold;">🍽️ Sabor de Casa</h1>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:40px 32px;">
              <p style="margin:0 0 8px;font-size:16px;color:#374151;">Hola, <strong>${userName}</strong></p>
              <h2 style="margin:8px 0 20px;font-size:22px;color:#111827;">${title}</h2>
              <p style="font-size:15px;color:#6b7280;line-height:1.6;">${body}</p>
              <hr style="border:none;border-top:1px solid #e5e7eb;margin:28px 0;" />
              <p style="margin:0;font-size:13px;color:#9ca3af;">Número de pedido: <strong>#${orderShortId}</strong></p>
            </td>
          </tr>
          <!-- Footer -->
          <tr>
            <td style="background:#f9fafb;padding:20px 32px;text-align:center;">
              <p style="margin:0;font-size:12px;color:#9ca3af;">
                © ${new Date().getFullYear()} Sabor de Casa · Todos los derechos reservados
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}
