Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const { transcribed_meal } = await req.json();

  // Call OpenAI o3-mini reasoning model
  const response = await fetch(
    "https://api.openai.com/v1/chat/completions",
    {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "o3-mini",
        messages: [
          {
            role: "user",
            content:
              `Analyze the following transcribed meal description. Closely calculate the total calories, macronutrients (proteins, carbs, fats in grams), and relevant micronutrients (such as vitamins and minerals where data is available, in appropriate units). Provide a detailed breakdown by food item with estimated portion sizes, calories, macros, and micros per item.

If a specific brand name is mentioned, perform research to find the exact nutrition information for that product. Otherwise, closely estimate using research and your trained knowledge.

Food description: ${transcribed_meal}

If it does not make sense, respond with "Could not parse meal: ${transcribed_meal}"

Your final output should be something like this:

[What kind of meal it is, e.g., breakfast, lunch, dinner, snack]: [A brief description of the meal]

Total Calories: [x] kcal
Total Protein: [x] g
Total Carbs: [x] g
Total Fats: [x] g

Breakdown:
[Food Item 1]: [Portion Size] - Calories: [x] kcal, Protein: [x] g, Carbs: [x] g, Fats: [x] g, Micros: [list of relevant vitamins and minerals with amounts],
[Food Item 2]: [Portion Size] - Calories: [x] kcal, Protein: [x] g, Carbs: [x] g, Fats: [x] g, Micros: [list of relevant vitamins and minerals with amounts],
...`,
          },
        ],
        reasoning_effort: "high",
      }),
    },
  );

  if (!response.ok) {
    const error = await response.text();
    return new Response(JSON.stringify({ error }), {
      status: response.status,
      headers: { "Content-Type": "application/json" },
    });
  }

  const result = await response.json();
  const content = result.choices[0].message.content;

  return new Response(JSON.stringify({ nutritionInfo: content }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
});
