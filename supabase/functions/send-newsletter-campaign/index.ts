// @ts-nocheck - Deno Edge Function
// Envía campaña de newsletter a suscriptores activos.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { delay } from "https://deno.land/std@0.168.0/async/delay.ts";
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
    const subject = String(body?.subject ?? "").trim();
    const messageBody = String(body?.body ?? "").trim();

    if (!subject || !messageBody) {
      return new Response(
        JSON.stringify({ error: "Missing subject or body" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const brevoKey = Deno.env.get("BREVO_API_KEY");
    const senderEmail =
      Deno.env.get("BREVO_SENDER_EMAIL") ?? "noreply@sabordecasa.com";

    if (!supabaseUrl || !serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: "Missing Supabase env" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!brevoKey) {
      return new Response(
        JSON.stringify({ error: "BREVO_API_KEY not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.startsWith("Bearer ")
      ? authHeader.substring(7)
      : "";

    if (!jwt) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization token" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const userResult = await adminClient.auth.getUser(jwt);
    const authUser = userResult.data.user;
    if (!authUser) {
      return new Response(
        JSON.stringify({ error: "Invalid user" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const profileResult = await adminClient
      .from("profiles")
      .select("role")
      .eq("id", authUser.id)
      .maybeSingle();

    if (profileResult.error || profileResult.data?.role !== "admin") {
      return new Response(
        JSON.stringify({ error: "Forbidden" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const subsResult = await adminClient
      .from("newsletter_subscribers")
      .select("id,email")
      .eq("status", "active");

    if (subsResult.error) {
      return new Response(
        JSON.stringify({ error: subsResult.error.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const subscribers = (subsResult.data ?? [])
      .map((row: { email?: string; id?: string }) => ({
        id: String(row.id ?? "").trim(),
        email: String(row.email ?? "").trim(),
      }))
      .filter((row: { id: string; email: string }) => row.id && row.email);

    const throttleMs = 250;

    let sentCount = 0;
    let failedCount = 0;

    for (const subscriber of subscribers) {
      const token = encodeToken(subscriber.id, subscriber.email);
      const unsubscribeUrl = `${supabaseUrl}/functions/v1/newsletter-unsubscribe?token=${encodeURIComponent(token)}`;
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
          to: [{ email: subscriber.email }],
          subject,
          htmlContent: buildHtml(messageBody, unsubscribeUrl),
        }),
      });

      if (emailRes.ok) {
        sentCount += 1;
      } else {
        failedCount += 1;
      }

      await delay(throttleMs);
    }

    return new Response(
      JSON.stringify({
        sentCount,
        failedCount,
        total: subscribers.length,
        throttleMs,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: String(error),
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});

function buildHtml(messageBody: string, unsubscribeUrl: string): string {
  const escaped = escapeHtml(messageBody).replace(/\n/g, "<br>");
  const year = new Date().getFullYear();
  const businessContactEmail =
    Deno.env.get("BUSINESS_CONTACT_EMAIL") ?? "info@sabordecasa.es";

  return `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:640px;margin:0 auto;line-height:1.6;color:#111827;background:#ffffff;border:1px solid #e5e7eb;border-radius:14px;overflow:hidden;">
    <div style="background:#1a7a7a;padding:18px 22px;">
      <h2 style="margin:0;color:#ffffff;font-size:21px;">Sabor de Casa</h2>
      <p style="margin:4px 0 0;color:#d2f2ee;font-size:12px;">Novedades de la newsletter</p>
    </div>
    <div style="padding:20px 22px;">
      <p style="margin:0 0 10px 0;">${escaped}</p>
      <p style="margin:0;">Contacto: <a href="mailto:${businessContactEmail}" style="color:#1a7a7a;font-weight:600;">${businessContactEmail}</a></p>
    </div>
    <div style="padding:14px 22px;background:#f9fafb;border-top:1px solid #e5e7eb;">
      <p style="font-size:12px;color:#6b7280;margin:0 0 8px 0;">
        Recibes este correo porque estás suscrito a nuestra newsletter.
      </p>
      <p style="font-size:12px;color:#6b7280;margin:0;line-height:1.6;">
        Si no quieres recibir más correos, puedes darte de baja aquí:
        <a href="${unsubscribeUrl}" style="color:#1a7a7a;font-weight:600;">Cancelar suscripción</a>
      </p>
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
