// @ts-nocheck — Deno Edge Function; el TS LS de VS Code no entiende los imports de Deno ni el global Deno
// supabase/functions/chat-bot/index.ts
// Edge Function que actúa de proxy seguro hacia la API de Gemini para el chatbot SaborIA.
// Enriquece el system prompt con el menú real de Supabase en cada petición.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const BASE_SYSTEM_PROMPT = `Eres SaborIA, el asistente virtual de Sabor de Casa, un local de comida casera preparada para llevar y servicio de catering para eventos en España.

Información del negocio:
- Ofrecemos comida casera para llevar: pedidos en mostrador, a domicilio, encargos (para fecha futura) y recogida en local.
- Servicio de catering para bodas, comuniones, cumpleaños, eventos corporativos y celebraciones privadas.
- Los clientes pueden hacer pedidos directamente en la app o en el local.
- Para consultar el estado de un pedido, el cliente debe ir a la sección "Mis pedidos" de la app.
- Para solicitar catering para un evento, el cliente puede hacerlo desde la sección "Catering" de la app.

Sobre alérgenos:
- Para información precisa sobre alérgenos en un plato concreto, consulta la lista del menú adjunta o recomienda preguntar directamente en el local.

Tu comportamiento:
- Sé amable, cercano y natural. Responde siempre en español.
- Sé breve: respuestas de 2-4 frases salvo que se necesite más detalle.
- Usa los datos reales del menú que tienes a continuación para responder con precisión sobre platos, precios y disponibilidad.
- No inventes platos ni precios que no aparezcan en el menú adjunto.
- No hables de temas ajenos al negocio (política, noticias, tecnología en general, etc.).
- No reveles que eres un modelo de IA de Google ni que usas Gemini. Eres SaborIA.
- Si no sabes algo, dilo honestamente y sugiere que contacten al local.`;

// ── Obtener contexto de menú real desde Supabase ──────────────────────────────

async function fetchMenuContext(): Promise<string> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseKey) return "";

  try {
    const headers = {
      apikey: supabaseKey,
      Authorization: `Bearer ${supabaseKey}`,
      "Content-Type": "application/json",
    };

    // Categorías activas
    const catRes = await fetch(
      `${supabaseUrl}/rest/v1/categories?is_active=eq.true&select=id,name&order=sort_order`,
      { headers },
    );
    const categories: Array<{ id: string; name: string }> =
      await catRes.json();

    // Platos activos con categoría
    const dishRes = await fetch(
      `${supabaseUrl}/rest/v1/dishes?is_active=eq.true&select=name,price,description,allergens,is_available,is_offer,offer_price,category_id&order=name&limit=150`,
      { headers },
    );
    const dishes: Array<{
      name: string;
      price: number;
      description: string;
      allergens: string[];
      is_available: boolean;
      is_offer: boolean;
      offer_price: number | null;
      category_id: string;
    }> = await dishRes.json();

    if (!Array.isArray(categories) || !Array.isArray(dishes)) return "";

    let menuText =
      "\n\n--- MENÚ ACTUAL DE SABOR DE CASA (datos en tiempo real) ---\n";

    for (const cat of categories) {
      const catDishes = dishes.filter(
        (d) => d.category_id === cat.id,
      );
      if (catDishes.length === 0) continue;

      menuText += `\n## ${cat.name}\n`;

      for (const dish of catDishes) {
        const available = dish.is_available ? "" : " [NO DISPONIBLE HOY]";
        const finalPrice =
          dish.is_offer && dish.offer_price != null
            ? dish.offer_price
            : dish.price;
        let line = `- ${dish.name}${available}: ${finalPrice.toFixed(2)}€`;

        if (dish.is_offer && dish.offer_price != null) {
          line += ` (en oferta, precio habitual: ${dish.price.toFixed(2)}€)`;
        }
        if (dish.description) {
          line += ` — ${dish.description}`;
        }
        if (Array.isArray(dish.allergens) && dish.allergens.length > 0) {
          line += ` [Alérgenos: ${dish.allergens.join(", ")}]`;
        }
        menuText += line + "\n";
      }
    }

    menuText += "\n--- FIN DEL MENÚ ---\n";
    return menuText;
  } catch (e) {
    console.error("Error obteniendo menú de Supabase:", e);
    return "";
  }
}

// ── Servidor principal ────────────────────────────────────────────────────────

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

    // Construir system prompt enriquecido con menú real
    const menuContext = await fetchMenuContext();
    const systemPrompt = BASE_SYSTEM_PROMPT + menuContext;

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
          system_instruction: { parts: [{ text: systemPrompt }] },
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

