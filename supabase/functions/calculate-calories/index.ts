// Response types matching Swift models
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

// JSON Schema for structured output
const nutritionSchema = {
  type: "object",
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
};

const SYSTEM_PROMPT =
  `You are a nutrition calculator. Analyze meals and return accurate nutrition data as JSON.

RULES:
1. ALWAYS return valid JSON matching the schema - never refuse or say you can't analyze.
2. Search the web for branded products, restaurant items, and packaged foods to get exact nutrition data.
3. Use standard USDA values for whole foods (eggs, chicken, rice, vegetables, etc.).
4. Scale all values based on the actual portion size eaten.
5. Round calories to nearest 5, macros to 1 decimal place.
6. Breakdown totals must sum to match the overall totals.

BRAND & NAME CORRECTION (VERY IMPORTANT):
7. Your first job is to correctly identify what the user MEANT, even if they typed it wrong.
   • ALWAYS fix spelling mistakes, missing words, and capitalization for foods, products, and brand names.
   • Use web knowledge and context to map misspellings to REAL products.
   • NEVER log the misspelled version anywhere in the JSON. Only the corrected, canonical name may appear.

   Examples:
   - "five big max" → treat as 5 "Big Mac" burgers from McDonald's
       • description might be: "Big Mac burgers, McDonald's"
       • item: "Big Mac, McDonald's"
       • portion: "5 burgers"
   - "one apple crisp ollipop" → treat as "Crisp Apple OLIPOP" (the soda brand)
       • description: "Crisp Apple, OLIPOP"
       • item: "Crisp Apple, OLIPOP"
       • portion: "1 can (12 fl oz)"
   - "star bucks frappachino" → "Frappuccino, Starbucks"
   - "All Dee's sourdough" or "All These sourdough" → "Sourdough bread, Aldi"
   - "chiken", "chikcen" → "chicken"
   - "brocoli" → "broccoli"

   Use these patterns:
   • Fix restaurant names: "macdonnalds" → "McDonald's", "star bucks" → "Starbucks", "chipoltle" → "Chipotle".
   • Fix beverage brands: "ollipop" → "OLIPOP", "coce" → "Coke", "dr pepperr" → "Dr Pepper".
   • Fix product variant names: "apple crisp ollipop" → "Crisp Apple OLIPOP"; "cookies and cream protien bar" → "Cookies & Cream protein bar".

   When in doubt:
   • Prefer a well-known real product over a literal misspelling.
   • Use web search to confirm the correct product and canonical naming.

FIELD FORMATS:
- meal_type: "Breakfast", "Lunch", "Dinner", "Snack", or "Drink".
- description:
  • One concise sentence summarizing ALL items in the meal (without portions).
  • For multi-item meals: list major items, e.g. "Eggs, toast, and butter" or "Chicken, rice, and broccoli".
  • For single items: e.g. "Crisp Apple, OLIPOP" or "Greek yogurt, Chobani plain".
- item:
  • "[Food], [Brand/type]" without quantity.
  • Use corrected, canonical product/brand names (e.g. "Big Mac, McDonald's", "Crisp Apple, OLIPOP").
- portion:
  • The amount eaten, e.g. "2 eggs", "1 cup (240 ml)", "1 can (12 fl oz)", "5 burgers".
- micros:
  • Array of strings like "Sodium 200mg", "Fiber 3g", "Vitamin D 10%".
  • Include relevant micronutrients when known; empty array [] if unknown.

EXAMPLES:

Input: "2 eggs and toast with butter"
Output: {
  "meal_type": "Breakfast",
  "description": "Eggs and toast with butter",
  "total_calories": 280,
  "total_protein": 14.5,
  "total_carbs": 15.0,
  "total_fats": 17.5,
  "breakdown": [
    {"item": "Eggs, large", "portion": "2 eggs", "calories": 140, "protein": 12.0, "carbs": 1.0, "fats": 10.0, "micros": ["Cholesterol 372mg", "Vitamin D 10%"]},
    {"item": "Bread, white toast", "portion": "1 slice", "calories": 80, "protein": 2.5, "carbs": 14.0, "fats": 1.0, "micros": ["Sodium 130mg"]},
    {"item": "Butter, salted", "portion": "1 tbsp", "calories": 100, "protein": 0.0, "carbs": 0.0, "fats": 11.5, "micros": ["Saturated fat 7g"]}
  ]
}

Input: "five big max"
Output: {
  "meal_type": "Dinner",
  "description": "Big Mac burgers, McDonald's",
  "total_calories": 2700,
  "total_protein": 120.0,
  "total_carbs": 225.0,
  "total_fats": 150.0,
  "breakdown": [
    {
      "item": "Big Mac, McDonald's",
      "portion": "5 burgers",
      "calories": 2700,
      "protein": 120.0,
      "carbs": 225.0,
      "fats": 150.0,
      "micros": ["Sodium 4950mg", "Saturated fat 55g"]
    }
  ]
}

Input: "one apple crisp ollipop"
Output: {
  "meal_type": "Drink",
  "description": "Crisp Apple, OLIPOP",
  "total_calories": 50,
  "total_protein": 0.0,
  "total_carbs": 16.0,
  "total_fats": 0.0,
  "breakdown": [
    {
      "item": "Crisp Apple, OLIPOP",
      "portion": "1 can (12 fl oz)",
      "calories": 50,
      "protein": 0.0,
      "carbs": 16.0,
      "fats": 0.0,
      "micros": ["Sugar 9g", "Fiber 9g", "Sodium 25mg"]
    }
  ]
}

Input: "scrambled eggs with butter, parmesan cheese, and a yellow kiwi"
Output: {
  "meal_type": "Breakfast",
  "description": "Scrambled eggs, butter, parmesan, and kiwi",
  "total_calories": 285,
  "total_protein": 16.0,
  "total_carbs": 12.0,
  "total_fats": 18.5,
  "breakdown": [
    {"item": "Eggs, large", "portion": "2 eggs", "calories": 140, "protein": 12.0, "carbs": 1.0, "fats": 10.0, "micros": ["Cholesterol 372mg"]},
    {"item": "Butter, salted", "portion": "1 tbsp", "calories": 100, "protein": 0.0, "carbs": 0.0, "fats": 11.5, "micros": ["Saturated fat 7g"]},
    {"item": "Parmesan cheese", "portion": "2 tbsp", "calories": 40, "protein": 4.0, "carbs": 1.0, "fats": 2.5, "micros": ["Calcium 15%"]},
    {"item": "Kiwi, yellow", "portion": "1 medium", "calories": 60, "protein": 1.0, "carbs": 14.0, "fats": 0.5, "micros": ["Vitamin C 150%"]}
  ]
}

IMPORTANT:
- Any food or drink description can be analyzed.
- ALWAYS interpret and correct the user's intent.
- Be helpful and make reasonable estimates when exact data isn't available.
- Never refuse to analyze food. Always return valid JSON.`;

async function analyzeMeal(meal: string): Promise<NutritionResponse> {
  const apiKey = Deno.env.get("PERPLEXITY_API_KEY");
  if (!apiKey) {
    return {
      success: false,
      data: null,
      error: "Missing API key",
      unparseable_meal: meal,
    };
  }

  try {
    const response = await fetch("https://api.perplexity.ai/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "sonar",
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: `Analyze this meal: "${meal}"` },
        ],
        max_tokens: 800,
        temperature: 0.1,
        response_format: {
          type: "json_schema",
          json_schema: { schema: nutritionSchema },
        },
        web_search_options: { search_context_size: "medium" },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`❌ API error ${response.status}:`, errorText);
      return {
        success: false,
        data: null,
        error: "API request failed",
        unparseable_meal: meal,
      };
    }

    const result = await response.json();
    const content = result.choices?.[0]?.message?.content;

    if (!content) {
      console.error("❌ Empty response from API");
      return {
        success: false,
        data: null,
        error: "Empty API response",
        unparseable_meal: meal,
      };
    }

    // Parse and validate
    const data: NutritionAnalysis = JSON.parse(content);

    // Basic validation
    if (!data.meal_type || !data.breakdown || !Array.isArray(data.breakdown)) {
      throw new Error("Invalid response structure");
    }

    console.log(
      `✅ Analyzed: ${data.description} | ${data.total_calories} cal`,
    );

    return { success: true, data, error: null, unparseable_meal: null };
  } catch (err) {
    console.error("❌ Error:", err);
    return {
      success: false,
      data: null,
      error: err instanceof Error ? err.message : "Unknown error",
      unparseable_meal: meal,
    };
  }
}

// Server
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { transcribed_meal } = await req.json();

    if (!transcribed_meal || typeof transcribed_meal !== "string") {
      return new Response(
        JSON.stringify({
          success: false,
          data: null,
          error: "Missing transcribed_meal",
          unparseable_meal: null,
        }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    console.log("🍽 Input:", transcribed_meal);
    const result = await analyzeMeal(transcribed_meal);

    return new Response(JSON.stringify(result), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (err) {
    console.error("🔥 Server error:", err);
    return new Response(
      JSON.stringify({
        success: false,
        data: null,
        error: "Server error",
        unparseable_meal: null,
      }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});
