// supabase/functions/send-order-notification/index.ts
// Edge Function que envía email (Brevo) y push (FCM) para:
//   - Confirmación de nuevo pedido con ticket completo  (INSERT en orders)
//   - Cambio de estado del pedido                       (UPDATE en orders)
//
// Webhooks necesarios en Supabase → Database → Webhooks:
//   1. Tabla: orders  Evento: INSERT  → esta función
//   2. Tabla: orders  Evento: UPDATE  → esta función

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── Helpers de labels ─────────────────────────────────────────────────────────

const ORDER_TYPE_LABEL: Record<string, string> = {
  mostrador: "En mostrador",
  encargo: "Encargo",
  domicilio: "A domicilio",
  recogida: "Para recoger",
};

const PAYMENT_METHOD_LABEL: Record<string, string> = {
  card: "Tarjeta",
  cash: "Efectivo",
  online: "Pago online",
};

const STATUS_LABEL: Record<string, string> = {
  pending: "Pendiente",
  confirmed: "Confirmado",
  preparing: "En preparación",
  ready: "Listo",
  delivering: "En camino",
  delivered: "Entregado",
  cancelled: "Cancelado",
  // Legacy keys
  accepted: "Aceptado",
  en_preparacion: "En preparación",
};

/** Estados de cambio que disparan notificación al cliente */
const NOTIFY_STATUSES = new Set([
  "accepted", "confirmed", "preparing", "en_preparacion",
  "ready", "delivering", "delivered", "cancelled",
]);

function getStatusTitle(status: string, orderType: string): string {
  const map: Record<string, string> = {
    accepted:       "¡Tu pedido ha sido aceptado!",
    confirmed:      "¡Tu pedido ha sido confirmado!",
    preparing:      "Tu pedido está en preparación",
    en_preparacion: "Tu pedido está en preparación",
    ready: orderType === "domicilio"
      ? "Tu pedido sale para entrega"
      : "¡Tu pedido está listo para recoger!",
    delivering: "Tu pedido está en camino 🛵",
    delivered:  "¡Pedido entregado! Buen provecho 🍽️",
    cancelled:  "Tu pedido ha sido cancelado",
  };
  return map[status] ?? "Actualización de tu pedido";
}

function getStatusBody(status: string, orderType: string): string {
  const map: Record<string, string> = {
    accepted:       "Hemos recibido y confirmado tu pedido. Ya estamos preparándolo.",
    confirmed:      "Tu pedido ha sido confirmado y está en cola de preparación.",
    preparing:      "Nuestro equipo está cocinando tu pedido con todo el cariño.",
    en_preparacion: "Nuestro equipo está cocinando tu pedido con todo el cariño.",
    ready: orderType === "domicilio"
      ? "Tu repartidor saldrá en breve con tu pedido."
      : "Muestra tu código QR en caja para recogerlo.",
    delivering: "Tu repartidor está de camino. ¡Prepárate para recibirlo!",
    delivered:  "Pedido entregado con éxito. ¡Gracias por elegirnos!",
    cancelled:  "Lamentamos los inconvenientes. Si tienes dudas, contáctanos.",
  };
  return map[status] ?? "El estado de tu pedido ha cambiado. Consulta la app para más detalles.";
}

// ── Tipos internos ────────────────────────────────────────────────────────────

interface OrderItem {
  quantity: number;
  unit_price: number;
  subtotal: number;
  notes: string | null;
  dishes: { name: string } | null;
}

interface OrderData {
  id: string;
  order_type: string;
  status: string;
  payment_method: string | null;
  payment_status: string;
  subtotal: number;
  delivery_fee: number;
  total: number;
  discount: number | null;
  scheduled_at: string | null;
  notes: string | null;
  created_at: string;
  addresses: {
    street: string;
    city: string;
    postal_code: string;
    notes: string | null;
  } | null;
}

// ── Handler principal ─────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();

    // Detectar tipo de evento desde Database Webhook
    const eventType: string = body.type ?? "UPDATE"; // INSERT o UPDATE
    const record = body.record ?? body;

    const orderId: string   = record.id        ?? body.orderId;
    const newStatus: string = record.status    ?? body.newStatus;
    const orderType: string = record.order_type ?? body.orderType;
    const userId: string    = record.user_id   ?? body.userId;

    if (!orderId || !userId) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Para UPDATE: solo notificar en estados relevantes
    if (eventType === "UPDATE" && !NOTIFY_STATUSES.has(newStatus)) {
      return new Response(
        JSON.stringify({ skipped: true, reason: "Status not in notify list" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Datos del usuario
    const [profileResult, tokensResult, authUserResult] = await Promise.all([
      supabase.from("profiles").select("full_name").eq("id", userId).single(),
      supabase.from("push_tokens").select("token").eq("user_id", userId),
      supabase.auth.admin.getUserById(userId),
    ]);

    const userEmail = authUserResult.data?.user?.email;
    const userName  = profileResult.data?.full_name ?? "Cliente";

    // Datos completos del pedido + items (para ticket)
    const [orderResult, itemsResult] = await Promise.all([
      supabase
        .from("orders")
        .select(`id, order_type, status, payment_method, payment_status,
                 subtotal, delivery_fee, total, discount, scheduled_at,
                 notes, created_at,
                 addresses(street, city, postal_code, notes)`)
        .eq("id", orderId)
        .single(),
      supabase
        .from("order_items")
        .select("quantity, unit_price, subtotal, notes, dishes(name)")
        .eq("order_id", orderId),
    ]);

    const orderData = orderResult.data as OrderData | null;
    const items     = (itemsResult.data ?? []) as OrderItem[];

    const results: Record<string, unknown> = {};

    // ── Push FCM ──────────────────────────────────────────────────────────────
    const fcmTokens: string[] = (tokensResult.data ?? []).map((r: { token: string }) => r.token);
    if (fcmTokens.length > 0) {
      const fcmKey = Deno.env.get("FCM_SERVER_KEY");
      if (fcmKey) {
        try {
          const pushTitle = eventType === "INSERT"
            ? "¡Pedido recibido! 🍽️"
            : getStatusTitle(newStatus, orderType);
          const pushBody = eventType === "INSERT"
            ? `Tu pedido #${orderId.substring(0, 8).toUpperCase()} ha sido recibido y está siendo procesado.`
            : getStatusBody(newStatus, orderType);

          const fcmRes = await fetch("https://fcm.googleapis.com/fcm/send", {
            method: "POST",
            headers: {
              Authorization: `key=${fcmKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              registration_ids: fcmTokens,
              notification: { title: pushTitle, body: pushBody, sound: "default" },
              data: { orderId, status: newStatus, orderType, click_action: "FLUTTER_NOTIFICATION_CLICK" },
              priority: "high",
            }),
          });
          results.fcm = { sent: fcmTokens.length, status: fcmRes.status };
        } catch (e) {
          results.fcm = { error: String(e) };
        }
      }
    }

    // ── Email Brevo ───────────────────────────────────────────────────────────
    if (userEmail) {
      const brevoKey = Deno.env.get("BREVO_API_KEY");
      if (brevoKey) {
        try {
          const orderShortId = orderId.substring(0, 8).toUpperCase();

          const emailSubject = eventType === "INSERT"
            ? `✅ Pedido confirmado #${orderShortId} · Sabor de Casa`
            : `${getStatusTitle(newStatus, orderType)} · Pedido #${orderShortId}`;

          const htmlContent = eventType === "INSERT"
            ? buildOrderTicketHtml({ userName, orderShortId, orderData, items })
            : buildStatusUpdateHtml({ userName, orderShortId, newStatus, orderType });

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
              subject: emailSubject,
              htmlContent,
            }),
          });
          results.email = { sent: true, to: userEmail, status: emailRes.status };
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
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// ── Template: ticket de nuevo pedido ─────────────────────────────────────────

function buildOrderTicketHtml(params: {
  userName: string;
  orderShortId: string;
  orderData: OrderData | null;
  items: OrderItem[];
}): string {
  const { userName, orderShortId, orderData, items } = params;

  const orderTypeLabel = ORDER_TYPE_LABEL[orderData?.order_type ?? ""] ?? orderData?.order_type ?? "";
  const paymentLabel   = PAYMENT_METHOD_LABEL[orderData?.payment_method ?? ""] ?? "—";
  const createdAt      = orderData?.created_at
    ? new Date(orderData.created_at).toLocaleString("es-ES", { timeZone: "Europe/Madrid" })
    : "—";
  const scheduledAt    = orderData?.scheduled_at
    ? new Date(orderData.scheduled_at).toLocaleString("es-ES", { timeZone: "Europe/Madrid" })
    : null;

  const address = orderData?.addresses
    ? `${orderData.addresses.street}, ${orderData.addresses.postal_code} ${orderData.addresses.city}`
    : null;

  const itemsHtml = items.map((item) => `
    <tr>
      <td style="padding:8px 0;font-size:14px;color:#374151;border-bottom:1px solid #f3f4f6;">
        ${item.dishes?.name ?? "Producto"}
      </td>
      <td style="padding:8px 0;text-align:center;font-size:14px;color:#6b7280;border-bottom:1px solid #f3f4f6;">
        ${item.quantity}
      </td>
      <td style="padding:8px 0;text-align:right;font-size:14px;color:#374151;border-bottom:1px solid #f3f4f6;">
        ${Number(item.unit_price).toFixed(2)} €
      </td>
      <td style="padding:8px 0;text-align:right;font-size:14px;font-weight:bold;color:#111827;border-bottom:1px solid #f3f4f6;">
        ${Number(item.subtotal).toFixed(2)} €
      </td>
    </tr>
    ${item.notes ? `<tr><td colspan="4" style="padding:0 0 8px;font-size:12px;color:#9ca3af;font-style:italic;">↳ ${item.notes}</td></tr>` : ""}
  `).join("");

  const discount = orderData?.discount ? Number(orderData.discount) : 0;

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Pedido confirmado #${orderShortId}</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f0;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f0;padding:32px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:16px;overflow:hidden;max-width:600px;">

        <!-- Header verde -->
        <tr>
          <td style="background:#1a7a7a;padding:28px 32px;text-align:center;">
            <h1 style="margin:0;color:#fff;font-size:22px;font-weight:bold;">🍽️ Sabor de Casa</h1>
            <p style="margin:6px 0 0;color:#b2dfdb;font-size:13px;">Comida preparada con cariño</p>
          </td>
        </tr>

        <!-- Confirmación -->
        <tr>
          <td style="background:#e8f5e9;padding:20px 32px;text-align:center;border-bottom:2px dashed #1a7a7a;">
            <p style="margin:0;font-size:28px;">✅</p>
            <h2 style="margin:8px 0 4px;font-size:20px;color:#1a7a7a;">¡Pedido recibido!</h2>
            <p style="margin:0;font-size:13px;color:#6b7280;">Nº de pedido: <strong style="color:#111827;">#${orderShortId}</strong></p>
          </td>
        </tr>

        <!-- Saludo -->
        <tr>
          <td style="padding:28px 32px 0;">
            <p style="margin:0;font-size:15px;color:#374151;">Hola, <strong>${userName}</strong>. Hemos recibido tu pedido correctamente. Aquí tienes el resumen:</p>
          </td>
        </tr>

        <!-- Info del pedido -->
        <tr>
          <td style="padding:20px 32px;">
            <table width="100%" cellpadding="0" cellspacing="0" style="background:#f9fafb;border-radius:8px;padding:16px;">
              <tr>
                <td style="font-size:13px;color:#6b7280;padding:4px 0;">Fecha del pedido</td>
                <td style="font-size:13px;color:#111827;text-align:right;padding:4px 0;">${createdAt}</td>
              </tr>
              <tr>
                <td style="font-size:13px;color:#6b7280;padding:4px 0;">Tipo</td>
                <td style="font-size:13px;color:#111827;text-align:right;padding:4px 0;">${orderTypeLabel}</td>
              </tr>
              ${scheduledAt ? `<tr>
                <td style="font-size:13px;color:#6b7280;padding:4px 0;">Fecha de entrega</td>
                <td style="font-size:13px;color:#111827;text-align:right;padding:4px 0;">${scheduledAt}</td>
              </tr>` : ""}
              ${address ? `<tr>
                <td style="font-size:13px;color:#6b7280;padding:4px 0;">Dirección</td>
                <td style="font-size:13px;color:#111827;text-align:right;padding:4px 0;">${address}</td>
              </tr>` : ""}
              <tr>
                <td style="font-size:13px;color:#6b7280;padding:4px 0;">Pago</td>
                <td style="font-size:13px;color:#111827;text-align:right;padding:4px 0;">${paymentLabel}</td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- Tabla de productos -->
        ${items.length > 0 ? `
        <tr>
          <td style="padding:0 32px 8px;">
            <h3 style="margin:0 0 12px;font-size:15px;color:#374151;border-bottom:2px solid #1a7a7a;padding-bottom:8px;">Productos</h3>
            <table width="100%" cellpadding="0" cellspacing="0">
              <tr style="background:#f3f4f6;">
                <th style="padding:8px 4px;font-size:12px;color:#6b7280;text-align:left;font-weight:600;">Producto</th>
                <th style="padding:8px 4px;font-size:12px;color:#6b7280;text-align:center;font-weight:600;">Ud.</th>
                <th style="padding:8px 4px;font-size:12px;color:#6b7280;text-align:right;font-weight:600;">Precio</th>
                <th style="padding:8px 4px;font-size:12px;color:#6b7280;text-align:right;font-weight:600;">Total</th>
              </tr>
              ${itemsHtml}
            </table>
          </td>
        </tr>` : ""}

        <!-- Totales -->
        <tr>
          <td style="padding:12px 32px 28px;">
            <table width="100%" cellpadding="0" cellspacing="0">
              <tr>
                <td style="font-size:13px;color:#6b7280;padding:3px 0;">Subtotal</td>
                <td style="font-size:13px;color:#374151;text-align:right;padding:3px 0;">${Number(orderData?.subtotal ?? 0).toFixed(2)} €</td>
              </tr>
              ${orderData?.delivery_fee ? `<tr>
                <td style="font-size:13px;color:#6b7280;padding:3px 0;">Gastos de envío</td>
                <td style="font-size:13px;color:#374151;text-align:right;padding:3px 0;">${Number(orderData.delivery_fee).toFixed(2)} €</td>
              </tr>` : ""}
              ${discount > 0 ? `<tr>
                <td style="font-size:13px;color:#22c55e;padding:3px 0;">Descuento</td>
                <td style="font-size:13px;color:#22c55e;text-align:right;padding:3px 0;">-${discount.toFixed(2)} €</td>
              </tr>` : ""}
              <tr style="border-top:2px solid #e5e7eb;">
                <td style="font-size:16px;font-weight:bold;color:#111827;padding:8px 0 0;">TOTAL</td>
                <td style="font-size:16px;font-weight:bold;color:#1a7a7a;text-align:right;padding:8px 0 0;">${Number(orderData?.total ?? 0).toFixed(2)} €</td>
              </tr>
            </table>
          </td>
        </tr>

        <!-- Nota pedido -->
        ${orderData?.notes ? `<tr>
          <td style="padding:0 32px 20px;">
            <p style="margin:0;font-size:13px;color:#6b7280;background:#fffbeb;border-left:3px solid #f59e0b;padding:10px 14px;border-radius:4px;">
              📝 <strong>Nota:</strong> ${orderData.notes}
            </p>
          </td>
        </tr>` : ""}

        <!-- Footer -->
        <tr>
          <td style="background:#f9fafb;padding:20px 32px;text-align:center;border-top:1px solid #e5e7eb;">
            <p style="margin:0 0 6px;font-size:13px;color:#374151;">¿Tienes alguna duda? Escríbenos a <a href="mailto:sabordecasasanlucar@gmail.com" style="color:#1a7a7a;">sabordecasasanlucar@gmail.com</a></p>
            <p style="margin:0;font-size:12px;color:#9ca3af;">© ${new Date().getFullYear()} Sabor de Casa · Todos los derechos reservados</p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

// ── Template: cambio de estado ────────────────────────────────────────────────

function buildStatusUpdateHtml(params: {
  userName: string;
  orderShortId: string;
  newStatus: string;
  orderType: string;
}): string {
  const { userName, orderShortId, newStatus, orderType } = params;

  const statusColor: Record<string, string> = {
    accepted:       "#22c55e",
    confirmed:      "#22c55e",
    preparing:      "#f97316",
    en_preparacion: "#f97316",
    ready:          "#3b82f6",
    delivering:     "#8b5cf6",
    delivered:      "#22c55e",
    cancelled:      "#ef4444",
  };
  const color = statusColor[newStatus] ?? "#1a7a7a";
  const title = getStatusTitle(newStatus, orderType);
  const body  = getStatusBody(newStatus, orderType);

  const statusEmoji: Record<string, string> = {
    accepted: "✅", confirmed: "✅", preparing: "👨‍🍳", en_preparacion: "👨‍🍳",
    ready: "🎉", delivering: "🛵", delivered: "🍽️", cancelled: "❌",
  };
  const emoji = statusEmoji[newStatus] ?? "📦";

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>${title}</title>
</head>
<body style="margin:0;padding:0;background:#f5f5f0;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f5f5f0;padding:32px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#fff;border-radius:16px;overflow:hidden;max-width:600px;">

        <tr>
          <td style="background:${color};padding:32px;text-align:center;">
            <p style="margin:0;font-size:40px;line-height:1;">${emoji}</p>
            <h1 style="margin:12px 0 0;color:#fff;font-size:22px;font-weight:bold;">Sabor de Casa</h1>
          </td>
        </tr>

        <tr>
          <td style="padding:40px 32px;">
            <p style="margin:0 0 8px;font-size:15px;color:#374151;">Hola, <strong>${userName}</strong></p>
            <h2 style="margin:8px 0 16px;font-size:21px;color:#111827;">${title}</h2>
            <p style="font-size:15px;color:#6b7280;line-height:1.7;">${body}</p>
            <hr style="border:none;border-top:1px solid #e5e7eb;margin:28px 0;"/>
            <p style="margin:0;font-size:13px;color:#9ca3af;">Número de pedido: <strong style="color:#374151;">#${orderShortId}</strong></p>
          </td>
        </tr>

        <tr>
          <td style="background:#f9fafb;padding:20px 32px;text-align:center;border-top:1px solid #e5e7eb;">
            <p style="margin:0 0 6px;font-size:13px;color:#374151;">¿Tienes alguna duda? <a href="mailto:sabordecasasanlucar@gmail.com" style="color:#1a7a7a;">sabordecasasanlucar@gmail.com</a></p>
            <p style="margin:0;font-size:12px;color:#9ca3af;">© ${new Date().getFullYear()} Sabor de Casa · Todos los derechos reservados</p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>`;
}


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
