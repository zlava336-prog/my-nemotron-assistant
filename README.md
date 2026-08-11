# My Nemotron Assistant

A lightweight personal AI assistant app for Android powered by NVIDIA Nemotron 3 Ultra API.

## Features

- **Clean, Simple UI** - Material 3 design with light/dark theme support
- **Chat Interface** - Real-time messaging with streaming responses
- **Nemotron 3 Ultra Integration** - Connects directly to NVIDIA's API
- **Bilingual Support** - English and Hindi languages
- **Lightweight** - Optimized for Android phones
- **Offline Chat History** - Messages saved locally
- **Secure API Key Storage** - Stored locally on device

## Prerequisites

1. **Flutter SDK** (3.16 or later)
2. **Android Studio** with Android SDK (API 21+)
3. **NVIDIA Nemotron API Key** - Get from [NVIDIA API Catalog](https://build.nvidia.com/nvidia/nemotron-3-ultra)
4. **Java 17** or later

## Getting Your Nemotron API Key

1. Go to [NVIDIA API Catalog](https://build.nvidia.com/nvidia/nemotron-3-ultra)
2. Sign in or create an account
3. Generate an API key
4. Copy the key for use in the app

## Project Structure

```
my_nemotron_assistant/
├── android/                 # Android native code
├── lib/
│   ├── l10n/               # Localization (English, Hindi)
│   ├── models/             # Data models
│   ├── providers/          # State management (Provider)
│   ├── screens/            # UI screens
│   ├── services/           # API services
│   ├── main.dart           # App entry point
│   └── utils/              # Utilities
├── pubspec.yaml            # Dependencies
└── README.md
```

## Installation & Setup

### 1. Clone/Extract Project
```bash
cd my_nemotron_assistant
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Configure Android SDK Path
Edit `android/local.properties`:
```properties
flutter.sdk=/path/to/your/flutter/sdk
```
Or run:
```bash
flutter config --android-sdk /path/to/android/sdk
```

### 4. Verify Setup
```bash
flutter doctor
flutter devices
```

## Building the APK

### Debug APK (for testing)
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (optimized, signed)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Release App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

## Installing on Your Phone

### Option 1: ADB (Recommended for development)
```bash
# Enable USB debugging on your phone
# Connect phone via USB
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Option 2: Direct Transfer
1. Copy the APK to your phone
2. Enable "Install unknown apps" for your file manager
3. Tap the APK to install

### Option 3: Flutter Install (device connected)
```bash
flutter install --release
```

## Using the App

1. **First Launch**: App opens to chat screen
2. **Set API Key**: Tap Settings (gear icon) → Enter your Nemotron API key → Save
3. **Start Chatting**: Type messages in English or Hindi
4. **Switch Language**: Settings → Language → Select English/Hindi
5. **Clear Chat**: Settings → Clear Chat

## Configuration

### API Endpoint
The app uses NVIDIA's official endpoint: `https://integrate.api.nvidia.com/v1/chat/completions`

### Model
Default: `nvidia/nemotron-3-ultra`

### Customization
Edit `lib/services/nemotron_service.dart` to modify:
- Temperature (creativity): `0.7`
- Max tokens: `1024`
- System prompt

## Troubleshooting

### Build Errors
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### API Key Issues
- Ensure key is valid and has Nemotron 3 Ultra access
- Check internet connection
- Verify key format (no extra spaces)

### Hindi Not Displaying
- Ensure device has Hindi font support
- Restart app after language change

### App Crashes on Launch
- Check `flutter doctor` for issues
- Verify minSdkVersion 21 (Android 5.0+)
- Check logcat: `adb logcat`

## Performance Tips

- App uses streaming for real-time responses
- Chat history limited to local storage
- Release build uses R8 optimization
- Minimal dependencies for small APK size (~15-20 MB)

## Security Notes

- API key stored in Android SharedPreferences (app-private)
- No data sent to third parties except NVIDIA API
- All network traffic over HTTPS
- No analytics or tracking

## License

Personal use only. NVIDIA Nemotron API subject to NVIDIA terms.

## Support

For issues:
1. Check Flutter and Android SDK versions
2. Verify API key validity
3. Check device logs with `adb logcat`