Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const { audio, format, timestamp } = await req.json();
  const originalAudio = Uint8Array.from(atob(audio), (c) => c.charCodeAt(0));

  // Create FormData with the audio file
  const formData = new FormData();
  const audioBlob = new Blob([originalAudio], {
    type: `audio/${format || "webm"}`,
  });
  formData.append("file", audioBlob, `audio.${format || "webm"}`);
  formData.append("model", "whisper-1");

  // Optional: add timestamp granularities if needed
  // formData.append('timestamp_granularities[]', 'word');

  // Call OpenAI API
  const response = await fetch(
    "https://api.openai.com/v1/audio/transcriptions",
    {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY")}`,
      },
      body: formData,
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

  return new Response(
    JSON.stringify(result),
    {
      status: 200,
      headers: { "Content-Type": "application/json" },
    },
  );
});
