// @ts-nocheck - Deno Edge Function
// Baja de newsletter mediante enlace en email.

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
    const url = new URL(req.url);
    const token = String(url.searchParams.get("token") ?? "").trim();

    if (!token) {
      return htmlResponse("Enlace inválido", 400);
    }

    const decoded = atob(token);
    const [id, email] = decoded.split(":");
    if (!id || !email) {
      return htmlResponse("Enlace inválido", 400);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      return htmlResponse("Configuración incompleta", 500);
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const result = await adminClient
      .from("newsletter_subscribers")
      .update({
        status: "unsubscribed",
        unsubscribed_at: new Date().toISOString(),
      })
      .eq("id", id)
      .eq("email", email.toLowerCase())
      .eq("status", "active");

    if (result.error) {
      return htmlResponse("No se pudo procesar la baja", 500);
    }

    return htmlResponse("Te has dado de baja correctamente", 200);
  } catch {
    return htmlResponse("Enlace inválido", 400);
  }
});

function htmlResponse(message: string, status: number): Response {
  const body = `
  <!doctype html>
  <html lang="es">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Newsletter | Sabor de Casa</title>
      <style>
        body { font-family: Arial, sans-serif; margin:0; background:#f7f7f5; color:#111827; }
        .box { max-width:560px; margin:64px auto; background:#fff; border-radius:14px; padding:24px; box-shadow:0 8px 30px rgba(0,0,0,.08); }
        h1 { margin:0 0 8px 0; font-size:22px; color:#0d3b2e; }
        p { margin:0; line-height:1.6; }
      </style>
    </head>
    <body>
      <main class="box">
        <h1>Sabor de Casa</h1>
        <p>${escapeHtml(message)}</p>
      </main>
    </body>
  </html>`;

  return new Response(body, {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/html; charset=utf-8",
    },
  });
}

function escapeHtml(text: string): string {
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&#39;");
}
