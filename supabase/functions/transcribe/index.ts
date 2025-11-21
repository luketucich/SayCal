// Constants
const OPENAI_API_URL = "https://api.openai.com/v1/audio/transcriptions";
const WHISPER_MODEL = "whisper-1";
const DEFAULT_AUDIO_FORMAT = "webm";

// Transcribe audio using OpenAI Whisper API
Deno.serve(async (req) => {
  try {
    // Validate request method
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        { status: 405, headers: { "Content-Type": "application/json" } }
      );
    }

    // Parse and validate request body
    const { audio, format, timestamp } = await req.json();

    if (!audio) {
      return new Response(
        JSON.stringify({ error: "Missing audio data" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Decode base64 audio
    const audioBytes = Uint8Array.from(atob(audio), (c) => c.charCodeAt(0));
    const audioFormat = format || DEFAULT_AUDIO_FORMAT;

    // Prepare FormData for OpenAI API
    const formData = new FormData();
    const audioBlob = new Blob([audioBytes], { type: `audio/${audioFormat}` });
    formData.append("file", audioBlob, `audio.${audioFormat}`);
    formData.append("model", WHISPER_MODEL);

    // Call OpenAI Whisper API
    const apiKey = Deno.env.get("OPEN_AI_TRANSCRIBE_API_KEY");
    if (!apiKey) {
      throw new Error("Missing OpenAI API key");
    }

    const response = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: { "Authorization": `Bearer ${apiKey}` },
      body: formData,
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("OpenAI API error:", errorText);
      return new Response(
        JSON.stringify({ error: errorText }),
        {
          status: response.status,
          headers: { "Content-Type": "application/json" }
        }
      );
    }

    const result = await response.json();

    return new Response(
      JSON.stringify(result),
      {
        status: 200,
        headers: { "Content-Type": "application/json" }
      }
    );
  } catch (error) {
    console.error("Transcription error:", error);
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
