// @ts-nocheck - Deno Edge Function
// Notifica al cliente cuando el admin actualiza una solicitud de catering.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const STATUS_LABEL: Record<string, string> = {
  pending: "Pendiente",
  appointment: "Cita propuesta",
  quoted: "Presupuesto enviado",
  accepted: "Aceptado",
  rejected: "Rechazado",
  cancelled: "Cancelado",
  completed: "Completado",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const requestId = body.requestId as string | undefined;
    const status = body.status as string | undefined;

    if (!requestId || !status) {
      return new Response(
        JSON.stringify({ error: "Missing requestId or status" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const requestResult = await supabase
      .from("event_requests")
      .select(`
        id,
        user_id,
        display_id,
        event_date,
        guest_count,
        location,
        status,
        quoted_total,
        admin_notes,
        appointment_at,
        appointment_notes,
        event_type,
        menu_type,
        custom_menu_description,
        event_menus(name, price_per_person)
      `)
      .eq("id", requestId)
      .single();

    if (requestResult.error || !requestResult.data) {
      return new Response(
        JSON.stringify({ error: requestResult.error?.message ?? "Request not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const cateringRequest = requestResult.data;
    const [profileResult, authUserResult] = await Promise.all([
      supabase
        .from("profiles")
        .select("full_name")
        .eq("id", cateringRequest.user_id)
        .single(),
      supabase.auth.admin.getUserById(cateringRequest.user_id),
    ]);

    const userEmail = authUserResult.data?.user?.email;
    if (!userEmail) {
      return new Response(
        JSON.stringify({ skipped: "User email not found" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const brevoKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoKey) {
      return new Response(
        JSON.stringify({ skipped: "BREVO_API_KEY not configured" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const userName = profileResult.data?.full_name ?? "Cliente";
    const shortId = cateringRequest.display_id ?? requestId.substring(0, 8).toUpperCase();
    const statusLabel = STATUS_LABEL[status] ?? status;
    const menuName = cateringRequest.menu_type === "custom"
      ? "Menú personalizado"
      : cateringRequest.event_menus?.name ?? "Menú de catering";

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
        subject: `Catering #${shortId}: ${statusLabel} · Sabor de Casa`,
        htmlContent: buildHtml({ userName, shortId, statusLabel, menuName, cateringRequest }),
      }),
    });

    return new Response(
      JSON.stringify({ sent: emailRes.ok, status: emailRes.status, to: userEmail }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

function buildHtml({
  userName,
  shortId,
  statusLabel,
  menuName,
  cateringRequest,
}: {
  userName: string;
  shortId: string;
  statusLabel: string;
  menuName: string;
  cateringRequest: Record<string, unknown>;
}) {
  const quotedTotal = cateringRequest.quoted_total
    ? `${Number(cateringRequest.quoted_total).toFixed(2)} €`
    : null;
  const appointmentAt = cateringRequest.appointment_at
    ? new Date(String(cateringRequest.appointment_at)).toLocaleString("es-ES", {
        dateStyle: "medium",
        timeStyle: "short",
      })
    : null;

  const year = new Date().getFullYear();
  const businessContactEmail =
    Deno.env.get("BUSINESS_CONTACT_EMAIL") ?? "info@sabordecasa.es";

  return `
    <div style="font-family:Arial,Helvetica,sans-serif;max-width:640px;margin:0 auto;color:#1f2933;background:#fff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;">
      <div style="background:#1a7a7a;color:white;padding:22px;">
        <h1 style="margin:0;font-size:24px;">Solicitud de catering #${shortId}</h1>
        <p style="margin:8px 0 0;font-size:16px;color:#d2f2ee;">Estado: <strong>${statusLabel}</strong></p>
      </div>
      <div style="padding:24px;">
        <p>Hola ${escapeHtml(userName)},</p>
        <p>Hemos actualizado tu solicitud de catering. Estos son los detalles actuales:</p>
        <ul style="line-height:1.8;padding-left:18px;">
          <li><strong>Menú:</strong> ${escapeHtml(menuName)}</li>
          <li><strong>Evento:</strong> ${escapeHtml(String(cateringRequest.event_type ?? "Evento"))}</li>
          <li><strong>Fecha:</strong> ${escapeHtml(String(cateringRequest.event_date ?? "Pendiente"))}</li>
          <li><strong>Personas:</strong> ${escapeHtml(String(cateringRequest.guest_count ?? ""))}</li>
          <li><strong>Lugar:</strong> ${escapeHtml(String(cateringRequest.location ?? ""))}</li>
          ${quotedTotal ? `<li><strong>Presupuesto:</strong> ${quotedTotal}</li>` : ""}
          ${appointmentAt ? `<li><strong>Cita propuesta:</strong> ${appointmentAt}</li>` : ""}
        </ul>
        ${cateringRequest.appointment_notes ? `<p><strong>Mensaje sobre la cita:</strong><br>${escapeHtml(String(cateringRequest.appointment_notes))}</p>` : ""}
        ${cateringRequest.admin_notes ? `<p><strong>Notas del equipo:</strong><br>${escapeHtml(String(cateringRequest.admin_notes))}</p>` : ""}
        <p style="margin-top:24px;">Gracias por confiar en Sabor de Casa.</p>
      </div>
      <div style="padding:14px 24px;background:#f9fafb;border-top:1px solid #e5e7eb;">
        <p style="margin:0;font-size:12px;color:#6b7280;">Contacto: <a href="mailto:${businessContactEmail}" style="color:#1a7a7a;font-weight:600;">${businessContactEmail}</a></p>
        <p style="margin:8px 0 0;font-size:12px;color:#9ca3af;">© ${year} Sabor de Casa</p>
      </div>
    </div>
  `;
}

function escapeHtml(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}
