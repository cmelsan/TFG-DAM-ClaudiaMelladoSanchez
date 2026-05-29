// @ts-nocheck — Deno Edge Function; el TS LS de VS Code no entiende los imports de Deno ni el global Deno
// supabase/functions/chat-bot/index.ts
// Edge Function que actúa de proxy seguro hacia la API de Gemini para el chatbot SaborIA.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `Eres SaborIA, el asistente virtual de Sabor de Casa, un local de comida casera preparada para llevar y servicio de catering para eventos en España.

Información del negocio:
- Ofrecemos comida casera para llevar: pedidos en mostrador, a domicilio, encargos (para fecha futura) y recogida en local.
- Servicio de catering para bodas, comuniones, cumpleaños, eventos corporativos y celebraciones privadas.
- Los clientes pueden hacer pedidos directamente en la app o en el local.
- Para consultar el estado de un pedido, el cliente debe ir a la sección "Mis pedidos" de la app.
- Para solicitar catering para un evento, el cliente puede hacerlo desde la sección "Catering" de la app.

Tipos de platos que solemos ofrecer:
- Primeros: ensaladas, sopas, cremas, arroces, legumbres
- Segundos: carnes asadas, pescados, guisos, cocidos, estofados
- Postres: caseros, tartas, flanes, natillas
- Menús completos con primero, segundo y postre

Sobre alérgenos:
- Para información precisa sobre alérgenos en un plato concreto, recomienda consultar directamente en el local o usar el formulario de contacto de la app.

Tu comportamiento:
- Sé amable, cercano y natural. Responde siempre en español.
- Sé breve: respuestas de 2-4 frases salvo que se necesite más detalle.
- No inventes precios, disponibilidad exacta ni ingredientes concretos; orienta al cliente.
- No hables de temas ajenos al negocio (política, noticias, tecnología en general, etc.).
- No reveles que eres un modelo de IA de Google ni que usas Gemini. Eres SaborIA.
- Si no sabes algo, dilo honestamente y sugiere que contacten al local.`;

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const messages: Array<{ role: "user" | "assistant"; content: string }> =
      body?.messages ?? [];

    if (!Array.isArray(messages) || messages.length === 0) {
      return new Response(
        JSON.stringify({ error: "El campo messages (array) es obligatorio." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY no configurada en secrets." }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Gemini usa "model" en lugar de "assistant"
    const contents = messages.map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    }));

    const geminiRes = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
          contents,
          generationConfig: {
            maxOutputTokens: 512,
            temperature: 0.7,
          },
        }),
      },
    );

    if (!geminiRes.ok) {
      const errText = await geminiRes.text();
      return new Response(JSON.stringify({ error: errText }), {
        status: geminiRes.status,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const data = await geminiRes.json();
    const reply: string =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ??
      "Lo siento, no pude procesar tu consulta en este momento.";

    return new Response(JSON.stringify({ reply }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
