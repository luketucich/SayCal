// Constants
const OPENAI_API_URL = "https://api.openai.com/v1/responses";
const OPENAI_MODEL = "gpt-4.1-mini";
const MAX_OUTPUT_TOKENS = 800;
const TEMPERATURE = 0.1;

// Helper function to broadcast to Realtime channel
async function broadcastToChannel(
  channelId: string,
  event: string,
  payload: any
): Promise<void> {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || "sb_publishable_3jmhHH_JX4KQcT-2i8MpzQ_XtTS9mWC";

    const response = await fetch(`${supabaseUrl}/realtime/v1/api/broadcast`, {
      method: "POST",
      headers: {
        "apikey": supabaseKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        messages: [{
          topic: channelId,
          event: event,
          payload: payload,
        }],
      }),
    });

    if (!response.ok) {
      console.error("Broadcast failed:", await response.text());
    }
  } catch (error) {
    console.error("Broadcast error:", error);
  }
}

// Build OpenAI request payload
function buildNutritionPrompt(meal: string) {
  return {
    model: OPENAI_MODEL,
    temperature: TEMPERATURE,
    max_output_tokens: MAX_OUTPUT_TOKENS,
    stream: true,
    tools: [{ type: "web_search" }],
    tool_choice: "auto",
    input: [
      {
        role: "system",
        content:
          "You are a nutrition analysis engine for a calorie tracking app. " +
          "You MUST respond ONLY with the final nutrition analysis as plain text " +
          "in the exact format requested. Do not output JSON. Do not explain your reasoning. " +
          "Use up-to-date nutrition label data when possible. " +
          "ALWAYS respect serving sizes and user-described quantities by scaling calories and macros " +
          "up or down based on the amount eaten.",
      },
      {
        role: "user",
        content: `
Analyze this meal: "${meal}"

Your goal is to ALWAYS return a best-effort nutrition estimate.

====================
SERVING SIZE & QUANTITY (CRITICAL, FOLLOW EXACTLY)

1. Find label-based data:
   - When the meal mentions a brand or product name (Aldi, Ben & Jerry's, Ice Cream for Bears, Costco, Trader Joe's, etc.),
     perform at least one web search to find that product's nutrition label or the closest precise match.
   - Prefer sources in this order:
     a) Official brand or retailer sites (e.g. aldi.us, benjerry.com, costco.com, traderjoes.com, etc.)
     b) Major nutrition databases (e.g. MyFitnessPal, Nutritionix)
     c) Large retailer sites with clear nutrition panels.

2. From the label, extract:
   - serving_size_description (e.g. "2 slices (64 g)", "2/3 cup (91 g)", "1 bar (60 g)")
   - calories_per_serving
   - protein_per_serving
   - carbs_per_serving
   - fats_per_serving
   - servings_per_container (if available)

3. Determine how many servings the user ate:
   - If the label serving is 2 slices and the user says "1 slice" → number_of_servings_eaten = 0.5
   - If the label serving is 1 slice and the user says "2 slices" → number_of_servings_eaten = 2
   - If the label serving is 1/2 cup and the user says "1 cup" → number_of_servings_eaten = 2
   - If the label shows something like "2/3 cup, 3 servings per container" and the user says:
       • "one pint"
       • "the whole pint"
       • "the whole container"
       • "the whole tub"
     then number_of_servings_eaten = servings_per_container
   - If the user says "half a pint", "half the container", "half the tub", etc.:
       number_of_servings_eaten = servings_per_container / 2
   - If the user says "a quarter of the pint/container":
       number_of_servings_eaten = servings_per_container / 4

4. SCALE calories and macros using math (do not skip this):
   - actual_calories = calories_per_serving × number_of_servings_eaten
   - actual_protein  = protein_per_serving × number_of_servings_eaten
   - actual_carbs    = carbs_per_serving × number_of_servings_eaten
   - actual_fats     = fats_per_serving × number_of_servings_eaten
   - Round calories to the nearest 5 kcal and macros to 0.1 g when needed.
   - NEVER just copy per-serving label values if the user ate more or less than exactly one serving.
   - Sanity check:
     • If the user eats half the container, the total calories MUST be approximately half of the full-container calories
       (within about ±15–20%, not double).
     • If the user eats the whole container, the total calories MUST be approximately:
         full_container_calories = calories_per_serving × servings_per_container

   Example logic for ice cream:
   - Label: 2/3 cup, 3 servings per container, 270 calories per serving.
     • Full pint calories ≈ 270 × 3 = 810 kcal.
     • If user says "half a pint": use number_of_servings_eaten = 1.5 → ≈ 405 kcal.
     • Your answer MUST be close to half of 810, not close to 810.

5. If the quantity is unclear:
   - Assume one reasonable standard serving (e.g. 1 slice of bread, 1 cup cooked pasta, 1 medium apple).
   - Treat results as approximate but still scale if the wording implies more or less than one serving.

====================
BRAND / NAME CORRECTION

- If the transcription slightly mis-spells a brand or product name
  (e.g. "Ice Cream for Bears Chock-ternal"), use web search and context to infer the correct official name
  (e.g. "Ice Cream for Bears Chocturnal").
- In your FINAL output, always use the corrected / official product name in the Description and Breakdown.

====================
ACCURACY VS GENERIC ESTIMATES

- If you CAN find a clear branded nutrition label, use those values as the basis for your calculations and scale.
- If search results are conflicting or unclear, prefer a close generic equivalent with clean, consistent label data
  instead of guessing from noisy or uncertain branded information.
- If you truly cannot find a good branded match after a reasonable search:
  - Use a close generic equivalent (e.g. "generic vanilla ice cream", "generic sourdough bread").
  - Clearly treat the values as approximate but still apply the serving math.

====================
DESCRIPTION LINE

- Keep the "Description" brief and label-like, not a full sentence, e.g.:
  - "Ice Cream for Bears Chocturnal (1/2 pint)"
  - "Aldi sourdough round, 1 slice"
  - "Grilled chicken breast with rice"
- Do NOT add extra explanation or notes to the Description.

====================
PARSING RULES

- If part of the meal is understandable, analyze that part instead of failing.
- Only when the text clearly does NOT describe any food at all
  (e.g., random letters, just "test", or something like "hello there")
  should you consider the meal unparseable.

====================
OUTPUT FORMAT (EXACT)

Return exactly in this format (plain text, no extra commentary):

Meal Type:
Description:

Total Calories:
Total Protein:
Total Carbs:
Total Fats:

Breakdown:
- Item:
  Portion:
  Calories:
  Protein:
  Carbs:
  Fats:
  Micros:

Only in the rare case where the text clearly does NOT describe any food and you cannot infer any meal at all, output exactly:
"Could not parse meal: ${meal}"
`,
      },
    ],
  };
}

Deno.serve(async (req) => {
  try {
    // Validate request method
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: { "Content-Type": "application/json" } }
      );
    }

    // Parse request body
    const { transcribed_meal, channel_id } = await req.json();

    if (!transcribed_meal || !channel_id) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Build and send OpenAI request
    const payload = buildNutritionPrompt(transcribed_meal);

    const apiKey = Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY");
    if (!apiKey) {
      throw new Error("Missing OpenAI API key");
    }

    const openaiResponse = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    if (!openaiResponse.ok) {
      const errorText = await openaiResponse.text();
      console.error("OpenAI API error:", errorText);
      return new Response(
        JSON.stringify({ error: errorText }),
        {
          status: openaiResponse.status,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    // Stream OpenAI response and broadcast chunks to client
    const reader = openaiResponse.body!.getReader();
    const decoder = new TextDecoder();
    let fullText = "";

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value, { stream: true });
        const lines = chunk.split("\n");

        for (const line of lines) {
          if (!line.startsWith("data: ")) continue;

          const data = line.slice(6).trim();
          if (data === "[DONE]") break;

          try {
            const json = JSON.parse(data);

            // Extract and broadcast text deltas
            if (json.type === "response.output_text.delta" && json.delta) {
              fullText += json.delta;
              await broadcastToChannel(channel_id, "nutrition_delta", {
                delta: json.delta,
                fullText: fullText,
              });
            }
          } catch {
            // Skip invalid JSON lines
          }
        }
      }
    } finally {
      reader.releaseLock();
    }

    // Send completion event
    await broadcastToChannel(channel_id, "nutrition_complete", {
      fullText: fullText,
    });

    return new Response(
      JSON.stringify({
        success: true,
        message: "Nutrition analysis completed",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" }
      }
    );
  } catch (error) {
    console.error("Server error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: errorMessage }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" }
      }
    );
  }
});
