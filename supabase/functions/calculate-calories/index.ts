// Response types matching Swift models
interface Micronutrient {
  name: string;
  value: number;
  unit: string;
}

interface NutritionItem {
  item: string;
  portion: string;
  calories: number;
  protein: number;
  carbs: number;
  fats: number;
  micros: Micronutrient[];
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

type UserTier = "free" | "premium";

const FREE_SYSTEM_PROMPT =
  `You are a nutrition calculator. Analyze meals and return accurate nutrition data as JSON.

RULES:
1. ALWAYS return valid JSON matching the schema - never refuse or say you can't analyze.
2. Use standard USDA values for whole foods (eggs, chicken, rice, vegetables, etc.).
3. For branded/restaurant items, use your knowledge of official nutrition data from company websites and nutrition databases.
4. Scale all values based on the actual portion size eaten.
5. Round calories to nearest 5, macros to 1 decimal place.
6. Breakdown totals MUST sum exactly to match the overall totals. Verify your math.

BRAND & NAME CORRECTION (CRITICAL):
7. Your first job is to correctly identify what the user MEANT, even if they typed it wrong.
   • ALWAYS fix spelling mistakes, missing words, and capitalization for foods, products, and brand names.
   • Use your knowledge to map misspellings to REAL products.
   • NEVER log the misspelled version anywhere in the JSON. Only the corrected, canonical name may appear.

Correction examples:
  - "five big max" → 5 "Big Mac" burgers from McDonald's
  - "one apple crisp ollipop" → "Crisp Apple OLIPOP" (the soda brand)
  - "star bucks frappachino" → "Frappuccino, Starbucks"
  - "All Dee's sourdough" or "All These sourdough" → "Sourdough bread, Aldi"
  - "chiken", "chikcen" → "chicken"
  - "macdonnalds" → "McDonald's", "chipoltle" → "Chipotle"
  - "ollipop" → "OLIPOP", "coce" → "Coke"

When in doubt, prefer a well-known real product over a literal misspelling.

BRANDED FOOD ACCURACY (CRITICAL):
8. For branded items, use OFFICIAL nutrition data. Common sources to recall:
   • Fast food: McDonald's, Chick-fil-A, Chipotle, Subway, etc. publish exact nutrition facts.
   • Packaged foods: Use label data (serving size matters!).
   • Beverages: Starbucks, Dunkin', bottled drinks have exact published values.
9. ALWAYS include the brand name in the item field for branded products.
10. If unsure about exact branded nutrition, state your best estimate but use realistic values based on similar known products.

DEFAULT SIZES (when size not specified):
- Starbucks: Grande (16 oz)
- Dunkin': Medium (24 oz for iced, 14 oz for hot)
- Fast food drinks: Medium
- Fast food fries: Medium
- Coffee shop pastries: Standard/regular size
- Packaged snacks: 1 package/serving unless multi-pack specified
- Canned drinks: 1 can (12 oz) unless otherwise noted
- Bottled drinks: 1 bottle (standard size, usually 16-20 oz)

DEFAULT PORTIONS (when quantity/size not specified):
- Chicken breast: 6 oz (170g) cooked
- Steak: 6 oz (170g) cooked
- Fish fillet: 4 oz (113g) cooked
- Rice: 1 cup cooked (158g)
- Pasta: 1 cup cooked (140g)
- Salad: 2 cups mixed greens
- Bread: 1 slice
- Eggs: assume large
- Cheese: 1 oz (28g) or 1 slice
- Nuts: 1 oz (28g), about a small handful
- Fruit: 1 medium piece or 1 cup
- Vegetables: 1 cup
- Cooking oil/butter: 1 tbsp
- Dressing: 2 tbsp
- "A bowl of" soup/cereal: 1.5 cups
- "Some" or "a little": use minimum reasonable amount
- "A lot of" or "extra": use 1.5x standard portion

FIELD FORMATS:
- meal_type: "Breakfast", "Lunch", "Dinner", "Snack", or "Drink"
- description: Simple, literal list of food items (no portions, no creative names, no adjectives). Just list what was eaten. Examples: "Eggs, toast, and butter" or "Big Mac and fries, McDonald's" or "Pineapple" or "Chicken breast and rice"
- item: "[Food], [Brand/type]" without quantity. Use corrected, canonical names.
- portion: ALWAYS include a measurable unit. Examples: "2 eggs", "1 Grande (16 oz)", "6 oz breast", "1 cup cooked"
- micros: Array of micronutrient objects with structure: {"name": string, "value": number, "unit": string}
  FIBER & FATS:
  • Fiber in g (grams)
  • Sugar in g (grams)
  • Saturated Fat in g (grams)
  • Cholesterol in mg (milligrams)

  MINERALS:
  • Sodium in mg (milligrams)
  • Calcium in mg (milligrams)
  • Iron in mg (milligrams)
  • Potassium in mg (milligrams)
  • Magnesium in mg (milligrams)
  • Phosphorus in mg (milligrams)
  • Zinc in mg (milligrams)
  • Selenium in mcg (micrograms)

  VITAMINS:
  • Vitamin A in mcg (micrograms)
  • Vitamin C in mg (milligrams)
  • Vitamin D in mcg (micrograms)
  • Vitamin E in mg (milligrams)
  • Vitamin K in mcg (micrograms)
  • Vitamin B6 in mg (milligrams)
  • Vitamin B12 in mcg (micrograms)
  • Folate in mcg (micrograms)
  • Thiamin in mg (milligrams)
  • Riboflavin in mg (milligrams)
  • Niacin in mg (milligrams)

  Format: [{"name": "Sodium", "value": 200, "unit": "mg"}, {"name": "Fiber", "value": 3, "unit": "g"}]
  NEVER use percentages (%). Always use actual amounts.
  Include as many of these as relevant for the food items. Empty array [] if none apply.

EXAMPLE:
Input: "2 eggs and toast with butter"
Output:
{
  "meal_type": "Breakfast",
  "description": "Eggs, toast, and butter",
  "total_calories": 325,
  "total_protein": 15.0,
  "total_carbs": 15.5,
  "total_fats": 22.0,
  "breakdown": [
    {"item": "Eggs, large", "portion": "2 eggs", "calories": 145, "protein": 12.5, "carbs": 1.0, "fats": 9.5, "micros": [{"name": "Cholesterol", "value": 372, "unit": "mg"}, {"name": "Vitamin D", "value": 2, "unit": "mcg"}, {"name": "Sodium", "value": 140, "unit": "mg"}]},
    {"item": "Bread, white toast", "portion": "1 slice", "calories": 80, "protein": 2.5, "carbs": 14.5, "fats": 1.0, "micros": [{"name": "Sodium", "value": 130, "unit": "mg"}, {"name": "Fiber", "value": 1, "unit": "g"}]},
    {"item": "Butter, salted", "portion": "1 tbsp (14g)", "calories": 100, "protein": 0.0, "carbs": 0.0, "fats": 11.5, "micros": [{"name": "Saturated Fat", "value": 7, "unit": "g"}, {"name": "Vitamin A", "value": 97, "unit": "mcg"}, {"name": "Sodium", "value": 90, "unit": "mg"}]}
  ]
}

IMPORTANT:
- VERIFY that breakdown calories/macros sum to totals before responding.
- Any food description can be analyzed - never refuse.
- For branded items, accuracy matters more than speed. Use real nutrition data.
- Always return valid JSON.`;

const PREMIUM_SYSTEM_PROMPT =
  `You are a nutrition calculator. Analyze meals and return accurate nutrition data as JSON.

RULES:
1. ALWAYS return valid JSON matching the schema - never refuse or say you can't analyze.
2. Search the web for branded products, restaurant items, and packaged foods to get EXACT official nutrition data.
3. Use standard USDA values for whole foods (eggs, chicken, rice, vegetables, etc.).
4. Scale all values based on the actual portion size eaten.
5. Round calories to nearest 5, macros to 1 decimal place.
6. Breakdown totals MUST sum exactly to match the overall totals. Verify your math.

BRAND & NAME CORRECTION (CRITICAL):
7. Your first job is to correctly identify what the user MEANT, even if they typed it wrong.
   • ALWAYS fix spelling mistakes, missing words, and capitalization for foods, products, and brand names.
   • Use web search to confirm correct product names and get accurate data.
   • NEVER log the misspelled version anywhere in the JSON. Only the corrected, canonical name may appear.

Correction examples:
  - "five big max" → 5 "Big Mac" burgers from McDonald's
  - "one apple crisp ollipop" → "Crisp Apple OLIPOP" (the soda brand)
  - "star bucks frappachino" → "Frappuccino, Starbucks"
  - "All Dee's sourdough" or "All These sourdough" → "Sourdough bread, Aldi"
  - "chiken", "chikcen" → "chicken"
  - "macdonnalds" → "McDonald's", "chipoltle" → "Chipotle"
  - "ollipop" → "OLIPOP", "coce" → "Coke"

When in doubt, search to confirm the correct product and use official nutrition data.

BRANDED FOOD ACCURACY (CRITICAL - USE WEB SEARCH):
8. For branded items, ALWAYS search for official nutrition data from:
   • Company websites (mcdonalds.com, starbucks.com, etc.)
   • Official nutrition PDFs and menu nutrition pages
   • FDA/USDA databases for packaged foods
9. ALWAYS include the brand name in the item field for branded products.
10. Cross-reference multiple sources when possible to ensure accuracy.
11. For restaurant items, use the EXACT values from their published nutrition information.

DEFAULT SIZES (when size not specified):
- Starbucks: Grande (16 oz)
- Dunkin': Medium (24 oz for iced, 14 oz for hot)
- Fast food drinks: Medium
- Fast food fries: Medium
- Coffee shop pastries: Standard/regular size
- Packaged snacks: 1 package/serving unless multi-pack specified
- Canned drinks: 1 can (12 oz) unless otherwise noted
- Bottled drinks: 1 bottle (standard size, usually 16-20 oz)

DEFAULT PORTIONS (when quantity/size not specified):
- Chicken breast: 6 oz (170g) cooked
- Steak: 6 oz (170g) cooked
- Fish fillet: 4 oz (113g) cooked
- Rice: 1 cup cooked (158g)
- Pasta: 1 cup cooked (140g)
- Salad: 2 cups mixed greens
- Bread: 1 slice
- Eggs: assume large
- Cheese: 1 oz (28g) or 1 slice
- Nuts: 1 oz (28g), about a small handful
- Fruit: 1 medium piece or 1 cup
- Vegetables: 1 cup
- Cooking oil/butter: 1 tbsp
- Dressing: 2 tbsp
- "A bowl of" soup/cereal: 1.5 cups
- "Some" or "a little": use minimum reasonable amount
- "A lot of" or "extra": use 1.5x standard portion

FIELD FORMATS:
- meal_type: "Breakfast", "Lunch", "Dinner", "Snack", or "Drink"
- description: Simple, literal list of food items (no portions, no creative names, no adjectives). Just list what was eaten. Examples: "Eggs, toast, and butter" or "Big Mac and fries, McDonald's" or "Pineapple" or "Chicken breast and rice"
- item: "[Food], [Brand/type]" without quantity. Use corrected, canonical names.
- portion: ALWAYS include a measurable unit. Examples: "2 eggs", "1 Grande (16 oz)", "6 oz breast", "1 cup cooked"
- micros: Array of micronutrient objects with structure: {"name": string, "value": number, "unit": string}
  FIBER & FATS:
  • Fiber in g (grams)
  • Sugar in g (grams)
  • Saturated Fat in g (grams)
  • Cholesterol in mg (milligrams)

  MINERALS:
  • Sodium in mg (milligrams)
  • Calcium in mg (milligrams)
  • Iron in mg (milligrams)
  • Potassium in mg (milligrams)
  • Magnesium in mg (milligrams)
  • Phosphorus in mg (milligrams)
  • Zinc in mg (milligrams)
  • Selenium in mcg (micrograms)

  VITAMINS:
  • Vitamin A in mcg (micrograms)
  • Vitamin C in mg (milligrams)
  • Vitamin D in mcg (micrograms)
  • Vitamin E in mg (milligrams)
  • Vitamin K in mcg (micrograms)
  • Vitamin B6 in mg (milligrams)
  • Vitamin B12 in mcg (micrograms)
  • Folate in mcg (micrograms)
  • Thiamin in mg (milligrams)
  • Riboflavin in mg (milligrams)
  • Niacin in mg (milligrams)

  Format: [{"name": "Sodium", "value": 200, "unit": "mg"}, {"name": "Fiber", "value": 3, "unit": "g"}]
  NEVER use percentages (%). Always use actual amounts.
  Include as many of these as relevant for the food items. Empty array [] if none apply.

EXAMPLE:
Input: "2 eggs and toast with butter"
Output:
{
  "meal_type": "Breakfast",
  "description": "Eggs, toast, and butter",
  "total_calories": 325,
  "total_protein": 15.0,
  "total_carbs": 15.5,
  "total_fats": 22.0,
  "breakdown": [
    {"item": "Eggs, large", "portion": "2 eggs", "calories": 145, "protein": 12.5, "carbs": 1.0, "fats": 9.5, "micros": [{"name": "Cholesterol", "value": 372, "unit": "mg"}, {"name": "Vitamin D", "value": 2, "unit": "mcg"}, {"name": "Sodium", "value": 140, "unit": "mg"}]},
    {"item": "Bread, white toast", "portion": "1 slice", "calories": 80, "protein": 2.5, "carbs": 14.5, "fats": 1.0, "micros": [{"name": "Sodium", "value": 130, "unit": "mg"}, {"name": "Fiber", "value": 1, "unit": "g"}]},
    {"item": "Butter, salted", "portion": "1 tbsp (14g)", "calories": 100, "protein": 0.0, "carbs": 0.0, "fats": 11.5, "micros": [{"name": "Saturated Fat", "value": 7, "unit": "g"}, {"name": "Vitamin A", "value": 97, "unit": "mcg"}, {"name": "Sodium", "value": 90, "unit": "mg"}]}
  ]
}

IMPORTANT:
- VERIFY that breakdown calories/macros sum to totals before responding.
- Any food description can be analyzed - never refuse.
- For branded items, USE WEB SEARCH to get exact official nutrition data.
- Accuracy is critical - users are tracking their nutrition.
- Always return valid JSON.`;

async function analyzeMealFree(meal: string): Promise<NutritionResponse> {
  const apiKey = Deno.env.get("OPEN_AI_CALCULATE_API_KEY");
  if (!apiKey) {
    return {
      success: false,
      data: null,
      error: "Missing OpenAI API key",
      unparseable_meal: meal,
    };
  }

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-5-nano",
        messages: [
          { role: "system", content: FREE_SYSTEM_PROMPT },
          { role: "user", content: `Analyze this meal: "${meal}"` },
        ],
        response_format: { type: "json_object" },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`❌ OpenAI API error ${response.status}:`, errorText);
      return {
        success: false,
        data: null,
        error: "API request failed",
        unparseable_meal: meal,
      };
    }

    const result = await response.json();

    const usage = result.usage;
    if (usage) {
      console.log(`📊 [FREE] Token Usage:`, {
        model: "gpt-5-nano",
        prompt_tokens: usage.prompt_tokens,
        completion_tokens: usage.completion_tokens,
        total_tokens: usage.total_tokens,
      });
    }

    const content = result.choices?.[0]?.message?.content;

    if (!content) {
      console.error("❌ Empty response from OpenAI API");
      return {
        success: false,
        data: null,
        error: "Empty API response",
        unparseable_meal: meal,
      };
    }

    const data: NutritionAnalysis = JSON.parse(content);

    if (!data.meal_type || !data.breakdown || !Array.isArray(data.breakdown)) {
      throw new Error("Invalid response structure");
    }

    // Recalculate totals from breakdown to ensure accuracy
    data.total_calories = data.breakdown.reduce(
      (sum, item) => sum + item.calories,
      0,
    );
    data.total_protein = data.breakdown.reduce(
      (sum, item) => sum + item.protein,
      0,
    );
    data.total_carbs = data.breakdown.reduce(
      (sum, item) => sum + item.carbs,
      0,
    );
    data.total_fats = data.breakdown.reduce((sum, item) => sum + item.fats, 0);

    console.log(
      `✅ [FREE] Analyzed: ${data.description} | ${data.total_calories} cal`,
    );
    return { success: true, data, error: null, unparseable_meal: null };
  } catch (err) {
    console.error("❌ OpenAI Error:", err);
    return {
      success: false,
      data: null,
      error: err instanceof Error ? err.message : "Unknown error",
      unparseable_meal: meal,
    };
  }
}

async function analyzeMealPremium(meal: string): Promise<NutritionResponse> {
  const apiKey = Deno.env.get("PERPLEXITY_API_KEY");
  if (!apiKey) {
    return {
      success: false,
      data: null,
      error: "Missing Perplexity API key",
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
          { role: "system", content: PREMIUM_SYSTEM_PROMPT },
          { role: "user", content: `Analyze this meal: "${meal}"` },
        ],
        max_tokens: 1000,
        temperature: 0.1,
        web_search_options: { search_context_size: "medium" },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error(`❌ Perplexity API error ${response.status}:`, errorText);
      return {
        success: false,
        data: null,
        error: "API request failed",
        unparseable_meal: meal,
      };
    }

    const result = await response.json();

    const usage = result.usage;
    if (usage) {
      console.log(`📊 [PREMIUM] Token Usage:`, {
        model: "sonar",
        prompt_tokens: usage.prompt_tokens,
        completion_tokens: usage.completion_tokens,
        total_tokens: usage.total_tokens,
      });
    }

    const content = result.choices?.[0]?.message?.content;

    if (!content) {
      console.error("❌ Empty response from Perplexity API");
      return {
        success: false,
        data: null,
        error: "Empty API response",
        unparseable_meal: meal,
      };
    }

    // Extract JSON from response - handle markdown blocks, extra text, whitespace
    let cleanedContent = content.trim();

    // Remove markdown code blocks
    cleanedContent = cleanedContent.replace(/```json\s*/gi, "").replace(
      /```\s*/g,
      "",
    );

    // Find the JSON object by locating first { and last }
    const firstBrace = cleanedContent.indexOf("{");
    const lastBrace = cleanedContent.lastIndexOf("}");

    if (firstBrace === -1 || lastBrace === -1 || lastBrace <= firstBrace) {
      console.error("❌ No valid JSON object found in response:", content);
      return {
        success: false,
        data: null,
        error: "Invalid JSON response",
        unparseable_meal: meal,
      };
    }

    cleanedContent = cleanedContent.slice(firstBrace, lastBrace + 1);

    const data: NutritionAnalysis = JSON.parse(cleanedContent);

    if (!data.meal_type || !data.breakdown || !Array.isArray(data.breakdown)) {
      throw new Error("Invalid response structure");
    }

    // Recalculate totals from breakdown to ensure accuracy
    data.total_calories = data.breakdown.reduce(
      (sum, item) => sum + item.calories,
      0,
    );
    data.total_protein = data.breakdown.reduce(
      (sum, item) => sum + item.protein,
      0,
    );
    data.total_carbs = data.breakdown.reduce(
      (sum, item) => sum + item.carbs,
      0,
    );
    data.total_fats = data.breakdown.reduce((sum, item) => sum + item.fats, 0);

    console.log(
      `✅ [PREMIUM] Analyzed: ${data.description} | ${data.total_calories} cal`,
    );
    return { success: true, data, error: null, unparseable_meal: null };
  } catch (err) {
    console.error("❌ Perplexity Error:", err);
    return {
      success: false,
      data: null,
      error: err instanceof Error ? err.message : "Unknown error",
      unparseable_meal: meal,
    };
  }
}

async function getUserTier(userId: string): Promise<UserTier> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseKey) {
    console.warn("⚠️ Supabase credentials missing, defaulting to free tier");
    return "free";
  }

  try {
    const response = await fetch(
      `${supabaseUrl}/rest/v1/user_profiles?user_id=eq.${userId}&select=tier`,
      {
        headers: {
          apikey: supabaseKey,
          Authorization: `Bearer ${supabaseKey}`,
        },
      },
    );

    if (!response.ok) {
      console.warn("⚠️ Failed to fetch user tier, defaulting to free");
      return "free";
    }

    const data = await response.json();
    const tier = data?.[0]?.tier;
    return tier === "premium" ? "premium" : "free";
  } catch (err) {
    console.warn("⚠️ Error fetching user tier:", err);
    return "free";
  }
}

// Server
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { transcribed_meal, user_id } = await req.json();

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

    if (!user_id || typeof user_id !== "string") {
      return new Response(
        JSON.stringify({
          success: false,
          data: null,
          error: "Missing user_id",
          unparseable_meal: null,
        }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    console.log("🍽 Input:", transcribed_meal);
    console.log("👤 User ID:", user_id);

    const tier = await getUserTier(user_id);
    console.log(`🎟️ User tier: ${tier}`);

    const result = tier === "premium"
      ? await analyzeMealPremium(transcribed_meal)
      : await analyzeMealFree(transcribed_meal);

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
