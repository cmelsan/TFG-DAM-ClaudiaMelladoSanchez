// @ts-nocheck - Deno Edge Function
// Envia correo de bienvenida al suscribirse a newsletter.

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
    const email = String(body?.email ?? "").trim().toLowerCase();
    const fullName = String(body?.full_name ?? "Cliente").trim() || "Cliente";

    if (!email) {
      return new Response(
        JSON.stringify({ error: "Missing email" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const brevoKey = Deno.env.get("BREVO_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const senderEmail =
      Deno.env.get("BREVO_SENDER_EMAIL") ?? "noreply@sabordecasa.com";
    const businessContactEmail =
      Deno.env.get("BUSINESS_CONTACT_EMAIL") ?? "info@sabordecasa.es";

    if (!brevoKey) {
      return new Response(
        JSON.stringify({ skipped: "BREVO_API_KEY not configured" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    let unsubscribeUrl: string | null = null;
    if (supabaseUrl && serviceRoleKey) {
      const adminClient = createClient(supabaseUrl, serviceRoleKey);
      const subResult = await adminClient
        .from("newsletter_subscribers")
        .select("id,email")
        .eq("email", email)
        .eq("status", "active")
        .maybeSingle();

      const sub = subResult.data;
      if (sub?.id && sub?.email) {
        const token = encodeToken(String(sub.id), String(sub.email));
        unsubscribeUrl = `${supabaseUrl}/functions/v1/newsletter-unsubscribe?token=${encodeURIComponent(token)}`;
      }
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
          email: senderEmail,
        },
        to: [{ email, name: fullName }],
        subject: "Bienvenido a la newsletter de Sabor de Casa",
        htmlContent: buildHtml(fullName, unsubscribeUrl, businessContactEmail),
      }),
    });

    return new Response(
      JSON.stringify({ sent: emailRes.ok, status: emailRes.status, to: email }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
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

function buildHtml(
  name: string,
  unsubscribeUrl: string | null,
  businessContactEmail: string,
): string {
  const safeName = escapeHtml(name);
  const unsubscribeBlock = unsubscribeUrl
    ? `
    <p style="font-size:12px;color:#6b7280;margin:0;line-height:1.6;">
      Si no quieres recibir más correos, puedes darte de baja aquí:
      <a href="${unsubscribeUrl}" style="color:#1a7a7a;font-weight:600;">Cancelar suscripción</a>
    </p>`
    : "";

  const year = new Date().getFullYear();

  return `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:640px;margin:0 auto;line-height:1.6;color:#111827;background:#ffffff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;">
    <div style="background:#1a7a7a;padding:18px 22px;">
      <h2 style="margin:0;color:#ffffff;font-size:21px;">Sabor de Casa</h2>
      <p style="margin:4px 0 0 0;color:#d2f2ee;font-size:12px;">Newsletter oficial</p>
    </div>

    <div style="padding:20px 22px;">
      <h3 style="margin:0 0 10px 0;color:#1a7a7a;font-size:20px;">Bienvenido, ${safeName}</h3>
      <p style="margin:0 0 10px 0;">Gracias por suscribirte. Ya formas parte de nuestra newsletter.</p>
      <p style="margin:0 0 12px 0;">A partir de ahora recibirás:</p>
      <ul style="margin:0 0 14px 18px;padding:0;">
        <li>Menú del día</li>
        <li>Ofertas especiales</li>
        <li>Novedades de temporada</li>
      </ul>
      <p style="margin:0;">No hacemos spam. Solo contenido útil sobre Sabor de Casa.</p>
      <p style="margin:10px 0 0;">Contacto: <a href="mailto:${businessContactEmail}" style="color:#1a7a7a;font-weight:600;">${businessContactEmail}</a></p>
    </div>

    <div style="padding:14px 22px;background:#f9fafb;border-top:1px solid #e5e7eb;">
      <p style="font-size:12px;color:#6b7280;margin:0 0 8px 0;">
        Recibes este correo porque has confirmado tu suscripción en nuestra web.
      </p>
      ${unsubscribeBlock}
      <p style="font-size:12px;color:#9ca3af;margin:10px 0 0;">© ${year} Sabor de Casa</p>
    </div>
  </div>
  `;
}

function encodeToken(id: string, email: string): string {
  return btoa(`${id}:${email.toLowerCase()}`);
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&#39;");
}
