// @ts-nocheck - Deno Edge Function
// Notifica por email al buzón del negocio cuando llega un formulario público.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

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
    const record = body.record ?? body;

    const name = String(record.name ?? "Cliente").trim();
    const email = String(record.email ?? "").trim();
    const phone = String(record.phone ?? "").trim();
    const subject = String(record.subject ?? "Consulta web").trim();
    const message = String(record.message ?? "").trim();
    const createdAt = String(record.created_at ?? "").trim();

    if (!email || !message) {
      return new Response(
        JSON.stringify({ error: "Missing email or message" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const brevoKey = Deno.env.get("BREVO_API_KEY");
    if (!brevoKey) {
      return new Response(
        JSON.stringify({ skipped: "BREVO_API_KEY not configured" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const toEmail =
      Deno.env.get("BUSINESS_CONTACT_EMAIL") ?? "sabordecasasanlucar@gmail.com";
    const senderEmail =
      Deno.env.get("BREVO_SENDER_EMAIL") ?? "noreply@sabordecasa.com";

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
          email: senderEmail,
        },
        to: [{ email: toEmail, name: "Sabor de Casa" }],
        replyTo: { email, name },
        subject: `Nuevo mensaje web: ${subject}`,
        htmlContent: buildHtml({
          name,
          email,
          phone,
          subject,
          message,
          createdAt,
        }),
      }),
    });

    return new Response(
      JSON.stringify({
        sent: emailRes.ok,
        status: emailRes.status,
        to: toEmail,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: String(error) }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

function buildHtml({
  name,
  email,
  phone,
  subject,
  message,
  createdAt,
}: {
  name: string;
  email: string;
  phone: string;
  subject: string;
  message: string;
  createdAt: string;
}) {
  const dateLabel = createdAt
    ? new Date(createdAt).toLocaleString("es-ES", {
        dateStyle: "medium",
        timeStyle: "short",
      })
    : "Ahora";

  const year = new Date().getFullYear();
  const businessContactEmail =
    Deno.env.get("BUSINESS_CONTACT_EMAIL") ?? "info@sabordecasa.es";

  return `
    <div style="font-family:Arial,Helvetica,sans-serif;max-width:700px;margin:0 auto;color:#1f2937;background:#fff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;">
      <div style="background:#1a7a7a;color:white;padding:20px 24px;">
        <h1 style="margin:0;font-size:22px;">Sabor de Casa</h1>
        <p style="margin:8px 0 0;font-size:14px;color:#d2f2ee;">Nuevo mensaje de contacto (formulario web)</p>
      </div>
      <div style="padding:20px 24px;">
        <p style="margin:0 0 14px;"><strong>Asunto:</strong> ${escapeHtml(subject)}</p>
        <p style="margin:0 0 8px;"><strong>Nombre:</strong> ${escapeHtml(name)}</p>
        <p style="margin:0 0 8px;"><strong>Email:</strong> ${escapeHtml(email)}</p>
        <p style="margin:0 0 8px;"><strong>Teléfono:</strong> ${escapeHtml(phone || "No indicado")}</p>
        <p style="margin:0 0 16px;"><strong>Fecha:</strong> ${escapeHtml(dateLabel)}</p>
        <div style="background:#f8fafc;border:1px solid #e5e7eb;border-radius:10px;padding:14px;white-space:pre-wrap;line-height:1.6;">
          ${escapeHtml(message)}
        </div>
        <p style="margin:16px 0 0;color:#6b7280;font-size:12px;">
          Responde directamente a este email para contestar al cliente.
        </p>
      </div>
      <div style="padding:14px 24px;background:#f9fafb;border-top:1px solid #e5e7eb;">
        <p style="margin:0;font-size:12px;color:#6b7280;">Contacto negocio: <a href="mailto:${businessContactEmail}" style="color:#1a7a7a;font-weight:600;">${businessContactEmail}</a></p>
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
