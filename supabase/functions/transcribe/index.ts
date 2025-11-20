Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  // Parse the incoming request body
  const { audio, format, timestamp } = await req.json();

  // Decode the base64 audio data
  const originalAudio = Uint8Array.from(atob(audio), (c) => c.charCodeAt(0));

  // TODO: Send originalAudio to OpenAI Whisper

  const result = { text: "Testing testing, originalAudio" };

  return new Response(
    JSON.stringify(result),
    {
      status: 200,
      headers: { "Content-Type": "application/json" },
    },
  );
});
