// @ts-nocheck — Deno Edge Function; el TS LS de VS Code no entiende los imports de Deno ni el global Deno
// supabase/functions/chat-bot/index.ts
// Edge Function que actúa de proxy seguro hacia la API de Gemini para el chatbot SaborIA.
// Enriquece el system prompt con el menú real de Supabase en cada petición.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
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

const EXTRA_SYSTEM_PROMPT = `

Reglas anti-invento:
- Usa exclusivamente los datos reales adjuntos para menu del dia, carta, precios, horarios, contacto y disponibilidad.
- No inventes platos, precios, horarios, promociones, direccion ni telefono.
- Si los datos reales no contienen la respuesta, dilo claramente y sugiere contactar al local o revisar la app.`;

// Datos públicos mostrados actualmente en la web (footer/contacto).
const WEB_CONTACT_CONTEXT = `
\n## Contacto público web
- Ciudad: Sanlúcar de Barrameda, Cádiz
- Teléfono: 956 36 30 09
- Email: info@sabordecasa.es
- Horario visible en web: Lun – Sáb: 12:00 – 16:00
`;

const DAY_NAMES = [
  "Domingo",
  "Lunes",
  "Martes",
  "Miercoles",
  "Jueves",
  "Viernes",
  "Sabado",
];

function madridDate(): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Europe/Madrid",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
}

function madridDayOfWeek(): number {
  // JS: 0=Sunday ... 6=Saturday (mismo convenio usado en la tabla schedule)
  const weekday = new Intl.DateTimeFormat("en-US", {
    timeZone: "Europe/Madrid",
    weekday: "short",
  }).format(new Date());

  const dayMap: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };

  return dayMap[weekday] ?? 0;
}

function euro(value: number | string | null | undefined): string {
  const amount = Number(value);
  if (!Number.isFinite(amount)) return "precio no disponible";
  return `${amount.toFixed(2)} EUR`;
}

function unavailableContext(reason: string): string {
  return `\n\n--- DATOS REALES NO DISPONIBLES ---\n${reason}\nNo inventes informacion de menu, horarios ni precios.\n--- FIN DATOS REALES ---\n`;
}

async function fetchJson<T>(
  url: string,
  headers: Record<string, string>,
  fallback: T,
): Promise<T> {
  const res = await fetch(url, { headers });
  if (!res.ok) {
    console.error(`Supabase REST ${res.status} en ${url}:`, await res.text());
    return fallback;
  }
  return await res.json();
}

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

    const categories = await fetchJson<Array<{ id: string; name: string }>>(
      `${supabaseUrl}/rest/v1/categories?is_active=eq.true&select=id,name&order=sort_order`,
      headers,
      [],
    );

    const dishes = await fetchJson<Array<{
      name: string;
      price: number;
      description: string;
      allergens: string[];
      is_available: boolean;
      is_offer: boolean;
      offer_price: number | null;
      category_id: string;
      id?: string;
    }>>(
      `${supabaseUrl}/rest/v1/dishes?is_active=eq.true&select=id,name,price,description,allergens,is_available,is_offer,offer_price,category_id&order=name&limit=150`,
      headers,
      [],
    );

    const specialRows = await fetchJson<Array<{
      dish_id: string;
      date: string;
      primero_text: string | null;
      segundo_text: string | null;
      postre_text: string | null;
      bebida_text: string | null;
      menu_price: number | null;
      note: string | null;
      discount_percent: number | null;
    }>>(
      `${supabaseUrl}/rest/v1/daily_special?select=dish_id,date,primero_text,segundo_text,postre_text,bebida_text,menu_price,note,discount_percent&order=date.desc&limit=1`,
      headers,
      [],
    );

    const schedules = await fetchJson<Array<{
      day_of_week: number;
      open_time: string;
      close_time: string;
      is_open: boolean;
    }>>(
      `${supabaseUrl}/rest/v1/schedule?select=day_of_week,open_time,close_time,is_open&order=day_of_week.asc`,
      headers,
      [],
    );

    if (!Array.isArray(categories) || !Array.isArray(dishes)) {
      return unavailableContext("No se pudieron leer categories/dishes desde Supabase.");
    }

    if (categories.length === 0 && dishes.length === 0) {
      return unavailableContext("No hay datos de menu activos en la base de datos.");
    }

    let menuText =
      "\n\n--- DATOS REALES DE SABOR DE CASA (tiempo real) ---\n";

    // Menú del día real (tabla daily_special). Prioridad alta sobre textos genéricos.
    const special = specialRows[0];
    if (special) {
      const specialDish = dishes.find((d) => d.id && d.id === special.dish_id);
      menuText += "\n## Menú del día (real)\n";
      if (special.menu_price != null) {
        menuText += `- Precio menú del día: ${euro(special.menu_price)}\n`;
      }
      if (specialDish) {
        const basePrice =
          specialDish.is_offer && specialDish.offer_price != null
            ? specialDish.offer_price
            : specialDish.price;
        menuText += `- Plato base asociado: ${specialDish.name} (${basePrice.toFixed(2)}€)\n`;
      }
      if (special.primero_text) menuText += `- Primero: ${special.primero_text}\n`;
      if (special.segundo_text) menuText += `- Segundo: ${special.segundo_text}\n`;
      if (special.postre_text) menuText += `- Postre: ${special.postre_text}\n`;
      if (special.bebida_text) menuText += `- Bebida: ${special.bebida_text}\n`;
      if (special.note) menuText += `- Nota: ${special.note}\n`;
      if (special.discount_percent != null) {
        menuText += `- Descuento: ${special.discount_percent}%\n`;
      }
      menuText += `- Fecha de vigencia: ${special.date}\n`;
    } else {
      menuText += "\n## Menú del día (real)\n- No hay menú del día publicado en la tabla daily_special.\n";
    }

    // Horario real desde schedule.
    if (Array.isArray(schedules) && schedules.length > 0) {
      const today = madridDayOfWeek();
      menuText += "\n## Horarios (tabla schedule)\n";
      for (const row of schedules) {
        const day = DAY_NAMES[row.day_of_week] ?? `Día ${row.day_of_week}`;
        const marker = row.day_of_week === today ? " [HOY]" : "";
        const timeRange = row.is_open
          ? `${(row.open_time ?? "").slice(0, 5)}-${(row.close_time ?? "").slice(0, 5)}`
          : "CERRADO";
        menuText += `- ${day}${marker}: ${timeRange}\n`;
      }
    }

    menuText += "\n## Carta (categorías y platos activos)\n";

    for (const cat of categories) {
      // Evitar duplicar menú del día legacy de la carta cuando existe daily_special real.
      if (cat.name.toLowerCase() === "menú del día" || cat.name.toLowerCase() === "menu del dia") {
        continue;
      }

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

    menuText += "\n--- FIN DATOS REALES ---\n";
    return menuText + WEB_CONTACT_CONTEXT;
  } catch (e) {
    console.error("Error obteniendo menú de Supabase:", e);
    return unavailableContext(`Error obteniendo datos reales: ${String(e)}`) + WEB_CONTACT_CONTEXT;
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
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const apiKey = Deno.env.get("GROQ_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "GROQ_API_KEY no configurada en secrets." }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Construir system prompt enriquecido con menú real
    const menuContext = await fetchMenuContext();
    const systemPrompt = BASE_SYSTEM_PROMPT + EXTRA_SYSTEM_PROMPT + menuContext;

    // Groq usa la misma interfaz que OpenAI Chat Completions
    const groqRes = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: "llama-3.1-8b-instant",
          messages: [
            { role: "system", content: systemPrompt },
            ...messages.map((m) => ({
              role: m.role, // "user" | "assistant" — compatible con OpenAI
              content: m.content,
            })),
          ],
          max_tokens: 512,
          temperature: 0.7,
        }),
      },
    );

    if (!groqRes.ok) {
      let errMsg: string;
      try {
        const errJson = await groqRes.json();
        errMsg = errJson?.error?.message ?? JSON.stringify(errJson);
      } catch {
        errMsg = await groqRes.text();
      }
      return new Response(
        JSON.stringify({ error: `Groq ${groqRes.status}: ${errMsg}` }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const data = await groqRes.json();
    const reply: string =
      data?.choices?.[0]?.message?.content ??
      "Lo siento, no pude procesar tu consulta en este momento.";

    return new Response(JSON.stringify({ reply }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: `Error interno: ${String(e)}` }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});

