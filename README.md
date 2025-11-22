# SayCal

AI-powered calorie tracking app with voice input. Record your meals with your voice, get instant nutrition analysis powered by OpenAI.

## Features

- **Voice Recording**: Record meals using your voice
- **AI Transcription**: OpenAI Whisper converts audio to text
- **Nutrition Analysis**: GPT-4 analyzes meals and provides detailed nutrition info
- **Real-time Streaming**: See nutrition information as it's calculated
- **Profile Management**: Track your goals, dietary preferences, and allergies

## Tech Stack

- **iOS**: SwiftUI
- **Backend**: Supabase (Auth, Database, Edge Functions, Realtime)
- **AI**: OpenAI (Whisper for transcription, GPT-4 for nutrition analysis)

## Setup

### Prerequisites

- Xcode 15+
- Supabase project
- OpenAI API key

### iOS App

The Supabase URL and anon key are already configured in the code (these are meant to be public and are protected by Row Level Security policies).

Just open and run:
```bash
open ios/SayCal.xcodeproj
```

### Supabase Edge Functions

1. **Set OpenAI API key**:
   ```bash
   cd supabase
   supabase secrets set OPEN_AI_TRANSCRIBE_API_KEY=your-openai-api-key
   ```

2. **Deploy functions**:
   ```bash
   supabase functions deploy transcribe
   supabase functions deploy calculate-calories
   ```

### Database Schema

The app uses a `user_profiles` table in Supabase. Schema is managed through Supabase migrations.

## Project Structure

```
SayCal/
├── ios/
│   └── SayCal/
│       ├── Managers/         # Business logic
│       ├── Models/           # Data models
│       ├── Views/            # UI views
│       ├── Components/       # Reusable UI components
│       └── Config.swift      # Configuration management
├── supabase/
│   └── functions/
│       ├── transcribe/       # Audio → Text (Whisper)
│       └── calculate-calories/  # Text → Nutrition (GPT-4)
└── README.md
```

## Development

### Running Locally

1. Open `ios/SayCal.xcodeproj` in Xcode
2. Select your target device/simulator
3. Build and run (⌘R)

### Environment Variables

- **Never commit** `Secrets.xcconfig` to version control
- Use `Secrets.example.xcconfig` as a template
- Rotate keys immediately if accidentally committed

## Architecture

- **Managers**: Singleton classes handling business logic (UserManager, AudioRecorderManager)
- **MVVM Pattern**: Views observe published properties from managers
- **Supabase Realtime**: Streams nutrition data in real-time from edge functions
- **Caching**: User profiles cached locally with UserDefaults

## Best Practices

### Supabase
- All user data stored in metric units
- Auth state managed through Supabase Auth
- Row Level Security (RLS) policies applied
- Realtime channels created per-request with unique IDs

### OpenAI
- Whisper-1 model for transcription
- GPT-4.1-mini for nutrition analysis
- Streaming enabled for better UX
- Web search tool for accurate nutrition data

## Security

- Supabase anon keys are designed to be public (protected by RLS policies)
- OpenAI API keys are kept server-side in edge functions
- Database access controlled by Row Level Security (RLS)

## Contributing

This is a solo project. Issues and suggestions welcome!

## License

Private project - All rights reserved
