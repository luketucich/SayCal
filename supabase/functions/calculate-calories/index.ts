Deno.serve(async (req) => {
  try {
    console.log("📥 Incoming request:", req.method);

    if (req.method !== "POST") {
      console.log("❌ Wrong method:", req.method);
      return new Response("Method not allowed", { status: 405 });
    }

    const { transcribed_meal } = await req.json();
    console.log("🍽 Transcribed meal:", transcribed_meal);

    // -------- OpenAI payload (Responses API, gpt-4.1-mini + web_search) --------
    const payload = {
      model: "gpt-4.1-mini",
      temperature: 0.1, // more deterministic, better math
      max_output_tokens: 800,
      tools: [
        { type: "web_search" },
      ],
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
Analyze this meal: "${transcribed_meal}"

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
"Could not parse meal: ${transcribed_meal}"
`,
        },
      ],
    };

    console.log(
      "📤 Sending payload to OpenAI:",
      JSON.stringify(payload, null, 2),
    );

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    console.log("📡 OpenAI HTTP status:", response.status);

    if (!response.ok) {
      const err = await response.text();
      console.log("❌ OpenAI error:", err);
      return new Response(JSON.stringify({ error: err }), {
        status: response.status,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await response.json();

    console.log(
      "📦 OpenAI response shape:",
      JSON.stringify(
        {
          id: result.id,
          status: result.status,
          model: result.model,
          outputTypes: Array.isArray(result.output)
            ? result.output.map((o: any) => o.type)
            : null,
        },
        null,
        2,
      ),
    );

    // -------- Extract the final assistant text --------
    let outputText = "";

    // 1) Best case: convenience field
    if (typeof result.output_text === "string" && result.output_text.trim()) {
      console.log("✅ Using result.output_text");
      outputText = result.output_text.trim();
    }

    // 2) Normal Responses API pattern: find message item
    if (!outputText && Array.isArray(result.output)) {
      console.log("ℹ️ Searching result.output[] for message item...");

      const messageItem = result.output.find((item: any) =>
        item.type === "message"
      ) ?? null;

      if (messageItem && Array.isArray(messageItem.content)) {
        const first = messageItem.content[0];

        if (first && typeof first.text === "string") {
          outputText = first.text.trim();
          console.log("✅ Extracted from message.content[0].text");
        } else {
          console.log(
            "❌ message.content[0].text missing or not a string:",
            JSON.stringify(first, null, 2),
          );
        }
      } else {
        console.log("❌ No message item with content found in result.output");
      }
    }

    if (!outputText) {
      console.log("⚠️ outputText is empty – falling back to debug dump.");
      outputText = "Model returned no usable content.\n\nRaw result.output:\n" +
        JSON.stringify(result.output, null, 2);
    }

    console.log(
      "📝 Final extracted output (truncated):",
      outputText.slice(0, 400),
    );

    return new Response(JSON.stringify({ nutritionInfo: outputText }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.log("🔥 Server error:", err);
    const errorMessage = err instanceof Error ? err.message : String(err);
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
