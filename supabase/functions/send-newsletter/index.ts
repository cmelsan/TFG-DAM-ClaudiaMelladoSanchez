// @ts-nocheck
// supabase/functions/send-newsletter/index.ts
//
// Edge Function para enviar comunicados desde el panel de administración.
// Llamada SOLO por administradores autenticados (verifica role='admin' en JWT).
//
// Body esperado:
//   {
//     subject : string,          — asunto / título del comunicado
//     body    : string,          — cuerpo en texto plano
//     channels: ('email' | 'inapp')[]  — qué canales usar
//   }
//
// Lo que hace:
//   - canal 'email'  → consulta tabla subscriptions (type='email', active=true)
//                      y envía email HTML a cada suscriptor via Resend
//   - canal 'inapp'  → inserta una fila en notifications para cada usuario
//                      en tabla profiles (usando service_role → bypasea RLS)
//
// Secrets necesarios (Supabase → Settings → Edge Function Secrets):
//   RESEND_API_KEY   — para envíos de email
//   SUPABASE_URL     — ya inyectado automáticamente
//   SUPABASE_SERVICE_ROLE_KEY — ya inyectado automáticamente

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ── Resend ────────────────────────────────────────────────────────────────────

async function sendEmailViaResend(
  to: string,
  subject: string,
  html: string
): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  if (!apiKey) {
    console.warn("[newsletter] RESEND_API_KEY no configurado — email omitido");
    return false;
  }

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: "Sabor de Casa <noreply@sabordecasa.es>",
      to,
      subject,
      html,
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error(`[newsletter] Resend error ${res.status}: ${err}`);
    return false;
  }
  return true;
}

// ── Plantilla HTML ────────────────────────────────────────────────────────────

function buildEmailHtml(subject: string, body: string): string {
  const bodyHtml = body
    .split("\n")
    .map((line) => `<p style="margin:0 0 12px 0;color:#374151;">${line}</p>`)
    .join("");

  return `<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>${subject}</title></head>
<body style="margin:0;padding:0;background:#f3f4f6;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f3f4f6;padding:40px 0;">
    <tr><td align="center">
      <table width="600" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">
        <!-- Header -->
        <tr>
          <td style="background:linear-gradient(135deg,#1D9E75,#0F6E56);padding:32px 40px;text-align:center;">
            <h1 style="margin:0;color:#ffffff;font-size:22px;font-weight:800;">🍽️ Sabor de Casa</h1>
            <p style="margin:8px 0 0 0;color:rgba(255,255,255,0.8);font-size:14px;">Comunicado para suscriptores</p>
          </td>
        </tr>
        <!-- Body -->
        <tr>
          <td style="padding:40px;">
            <h2 style="margin:0 0 20px 0;color:#111111;font-size:20px;">${subject}</h2>
            ${bodyHtml}
          </td>
        </tr>
        <!-- Footer -->
        <tr>
          <td style="background:#f9fafb;padding:24px 40px;border-top:1px solid #e5e7eb;text-align:center;">
            <p style="margin:0;color:#9ca3af;font-size:12px;">
              Has recibido este email porque estás suscrito a las novedades de Sabor de Casa.<br>
              Si no quieres recibirlos más, ignora este mensaje.
            </p>
          </td>
        </tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

// ── Handler principal ─────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── 1. Verificar que el llamante es admin ─────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "No autorizado" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Cliente con el JWT del usuario (para verificar role)
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Token inválido" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verificar role=admin en profiles
    const { data: profile, error: profileError } = await userClient
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profileError || profile?.role !== "admin") {
      return new Response(
        JSON.stringify({ error: "Solo los administradores pueden enviar comunicados" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ── 2. Leer payload ───────────────────────────────────────────────────
    const { subject, body, channels } = await req.json() as {
      subject: string;
      body: string;
      channels: string[];
    };

    if (!subject?.trim() || !body?.trim()) {
      return new Response(
        JSON.stringify({ error: "subject y body son obligatorios" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!channels?.length) {
      return new Response(
        JSON.stringify({ error: "Selecciona al menos un canal (email o inapp)" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Cliente con service_role → bypasea RLS para INSERT masivo
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const results = { emailsSent: 0, emailsFailed: 0, inappInserted: 0 };

    // ── 3. Canal email ────────────────────────────────────────────────────
    if (channels.includes("email")) {
      const { data: subs, error: subsError } = await adminClient
        .from("subscriptions")
        .select("email")
        .eq("type", "email");

      if (subsError) {
        console.error("[newsletter] Error leyendo subscriptions:", subsError.message);
      } else if (subs?.length) {
        const html = buildEmailHtml(subject, body);
        for (const sub of subs) {
          if (!sub.email) continue;
          const ok = await sendEmailViaResend(sub.email, subject, html);
          if (ok) results.emailsSent++;
          else results.emailsFailed++;
        }
      }
    }

    // ── 4. Canal in-app ───────────────────────────────────────────────────
    if (channels.includes("inapp")) {
      // Obtener todos los user IDs activos
      const { data: profiles, error: profilesError } = await adminClient
        .from("profiles")
        .select("id");

      if (profilesError) {
        console.error("[newsletter] Error leyendo profiles:", profilesError.message);
      } else if (profiles?.length) {
        const rows = profiles.map((p: { id: string }) => ({
          user_id: p.id,
          title: subject,
          body,
          type: "promo",
        }));

        // Insertar en lotes de 100
        for (let i = 0; i < rows.length; i += 100) {
          const batch = rows.slice(i, i + 100);
          const { error: insertError } = await adminClient
            .from("notifications")
            .insert(batch);

          if (insertError) {
            console.error("[newsletter] Error insertando notificaciones:", insertError.message);
          } else {
            results.inappInserted += batch.length;
          }
        }
      }
    }

    // ── 5. Registrar el envío en newsletter_sends ─────────────────────────
    await adminClient.from("newsletter_sends").insert({
      admin_id: user.id,
      subject,
      body,
      channels,
      emails_sent: results.emailsSent,
      inapp_inserted: results.inappInserted,
    }).throwOnError().catch((e) => {
      // No es crítico si falla el log
      console.warn("[newsletter] No se pudo registrar el envío:", e.message);
    });

    return new Response(
      JSON.stringify({ success: true, ...results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (error) {
    console.error("[newsletter] Error inesperado:", error);
    return new Response(
      JSON.stringify({ error: "Error interno del servidor" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
