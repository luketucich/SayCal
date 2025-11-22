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
- Supabase account
- OpenAI API key

### iOS App Configuration

1. **Create configuration file**:
   ```bash
   cd ios
   cp Secrets.example.xcconfig Secrets.xcconfig
   ```

2. **Add your credentials to `ios/Secrets.xcconfig`**:
   ```
   SUPABASE_URL = https://your-project.supabase.co
   SUPABASE_ANON_KEY = your-supabase-anon-key
   ```

3. **Link the config file in Xcode**:
   - Open `SayCal.xcodeproj` in Xcode
   - Select the project in the navigator
   - Go to Info tab
   - Under Configurations, set `Secrets` for both Debug and Release

### Supabase Edge Functions

1. **Set environment variables**:
   ```bash
   cd supabase
   supabase secrets set OPENAI_API_KEY=your-openai-api-key
   supabase secrets set SUPABASE_ANON_KEY=your-supabase-anon-key
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

- **Never hardcode** API keys or secrets
- Use environment variables via `.xcconfig` files
- Rotate exposed credentials immediately
- `.gitignore` includes `Secrets.xcconfig`

## Contributing

This is a solo project. Issues and suggestions welcome!

## License

Private project - All rights reserved
