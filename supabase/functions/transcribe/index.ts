Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const { audio, format = "webm", timestamp } = await req.json();

    const audioBytes = Uint8Array.from(atob(audio), (c) => c.charCodeAt(0));

    const formData = new FormData();
    const audioBlob = new Blob([audioBytes], { type: `audio/${format}` });
    formData.append("file", audioBlob, `audio.${format}`);
    formData.append("model", "whisper-1");

    const response = await fetch(
      "https://api.openai.com/v1/audio/transcriptions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY")}`,
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

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: errorMessage }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
