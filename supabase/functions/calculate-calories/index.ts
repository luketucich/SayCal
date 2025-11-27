// Types matching Swift models
interface NutritionItem {
  item: string;
  portion: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  micros: string[];
}

interface NutritionAnalysis {
  meal_type: string;
  description: string;
  total_calories: number;
  total_protein: number;
  total_carbs: number;
  total_fats: number;
  breakdown: NutritionItem[];
}

// In strict mode, all properties must be required
// So we use a flat structure where success determines which fields are meaningful
type NutritionResponse =
  | {
    success: true;
    data: NutritionAnalysis;
    error: null;
    unparseable_meal: null;
  }
  | {
    success: false;
    data: null;
    error: string;
    unparseable_meal: string | null;
  };

// JSON Schema for OpenAI structured outputs (strict mode requires ALL props in required)
const nutritionSchema = {
  type: "object",
  properties: {
    success: { type: "boolean" },
    data: {
      type: ["object", "null"],
      properties: {
        meal_type: { type: "string" },
        description: { type: "string" },
        total_calories: { type: "number" },
        total_protein: { type: "number" },
        total_carbs: { type: "number" },
        total_fats: { type: "number" },
        breakdown: {
          type: "array",
          items: {
            type: "object",
            properties: {
              item: { type: "string" },
              portion: { type: "string" },
              calories: { type: "number" },
              protein: { type: "number" },
              carbs: { type: "number" },
              fats: { type: "number" },
              micros: { type: "array", items: { type: "string" } },
            },
            required: [
              "item",
              "portion",
              "calories",
              "protein",
              "carbs",
              "fats",
              "micros",
            ],
            additionalProperties: false,
          },
        },
      },
      required: [
        "meal_type",
        "description",
        "total_calories",
        "total_protein",
        "total_carbs",
        "total_fats",
        "breakdown",
      ],
      additionalProperties: false,
    },
    error: { type: ["string", "null"] },
    unparseable_meal: { type: ["string", "null"] },
  },
  required: ["success", "data", "error", "unparseable_meal"],
  additionalProperties: false,
};

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { transcribed_meal } = await req.json();
    console.log("🍽 Analyzing meal:", transcribed_meal);

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4.1-mini",
        temperature: 0.1,
        max_output_tokens: 800,
        tools: [{ type: "web_search" }],
        tool_choice: "auto",
        text: {
          format: {
            type: "json_schema",
            name: "nutrition_analysis",
            schema: nutritionSchema,
            strict: true,
          },
        },
        input: [
          {
            role: "system",
            content:
              "You are a nutrition analysis engine. Return structured JSON only. " +
              "Use web search to find accurate nutrition label data for branded products. " +
              "Always respect serving sizes and scale calories/macros based on the amount eaten. " +
              "Always include the micros array (use empty array [] if no micronutrient data). " +
              "When successful: set success=true, populate data, set error=null and unparseable_meal=null. " +
              "When the meal cannot be parsed: set success=false, data=null, error='Could not parse meal', unparseable_meal=the original input.",
          },
          {
            role: "user",
            content: buildNutritionPrompt(transcribed_meal),
          },
        ],
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("❌ OpenAI error:", errorText);
      const errorResponse: NutritionResponse = {
        success: false,
        data: null,
        error: "Failed to analyze meal",
        unparseable_meal: transcribed_meal,
      };
      return new Response(JSON.stringify(errorResponse), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const result = await response.json();
    const outputText = result.output?.find((o: { type: string }) =>
      o.type === "message"
    )
      ?.content?.[0]?.text;

    if (!outputText) {
      const errorResponse: NutritionResponse = {
        success: false,
        data: null,
        error: "No response from AI",
        unparseable_meal: transcribed_meal,
      };
      return new Response(JSON.stringify(errorResponse), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const nutritionData: NutritionResponse = JSON.parse(outputText);
    console.log(
      "✅ Analysis complete:",
      nutritionData.success ? "success" : "failed",
    );

    return new Response(JSON.stringify(nutritionData), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("🔥 Server error:", err);
    const errorResponse: NutritionResponse = {
      success: false,
      data: null,
      error: err instanceof Error ? err.message : "Unknown error",
      unparseable_meal: null,
    };
    return new Response(JSON.stringify(errorResponse), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  }
});

function buildNutritionPrompt(meal: string): string {
  return `
Analyze this meal: "${meal}"

Return JSON with this exact structure:
- If successful: { "success": true, "data": { meal analysis }, "error": null, "unparseable_meal": null }
- If unparseable: { "success": false, "data": null, "error": "Could not parse meal", "unparseable_meal": "${meal}" }

RULES:
1. Web search branded products for accurate nutrition labels
2. Scale all values based on quantity eaten vs label serving size
3. Round calories to nearest 5, macros to 0.1g
4. Fix typos in brand names (e.g., "Chock-ternal" → "Chocturnal")  
5. Keep description brief: "Ice Cream for Bears Chocturnal (1/2 pint)"
6. Always include micros array (empty [] if no data available)
7. Only return success: false if text clearly isn't food

SERVING MATH:
- Label says "2/3 cup, 3 servings per container" and user says "whole pint" → multiply by 3
- Label says "1 slice" and user says "2 slices" → multiply by 2
- Apply: actual_value = per_serving × servings_eaten
`;
}
