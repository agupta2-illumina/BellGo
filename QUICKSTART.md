# BellGo - Quick Start Guide

## Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- iOS Simulator or Android Emulator

## Installation

### 1. Install Flutter

If you don't have Flutter installed:

```bash
# macOS
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install
```

Verify installation:
```bash
flutter doctor
```

### 2. Get Dependencies

Navigate to the project directory:

```bash
cd bellgo
flutter pub get
```

### 3. Generate Code (Optional)

This step is optional for the MVP as no code generation is actively used yet:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running the App

### iOS Simulator (macOS only)

```bash
# List available simulators
flutter devices

# Run on iOS
flutter run
```

### Android Emulator

```bash
# Run on Android
flutter run
```

### Chrome (Web)

```bash
flutter run -d chrome
```

## Testing

Run all tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/domain/services/leave_time_calculator_test.dart
```

## Code Quality

### Analyze Code

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib test
```

## Project Commands

### Clean Build

```bash
flutter clean
flutter pub get
```

### Update Dependencies

```bash
flutter pub upgrade
```

### Check Outdated Packages

```bash
flutter pub outdated
```

## Development Workflow

1. **Start Development**
   ```bash
   flutter run
   ```

2. **Hot Reload**
   - Press `r` in terminal while app is running
   - Changes appear instantly

3. **Hot Restart**
   - Press `R` in terminal
   - Full restart with state reset

4. **Run Tests**
   ```bash
   flutter test --watch
   ```

## Common Issues

### Issue: "flutter command not found"
**Solution**: Add Flutter to your PATH
```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "Dart SDK version doesn't match"
**Solution**: Update Flutter
```bash
flutter upgrade
```

### Issue: "Waiting for another flutter command to release the startup lock"
**Solution**: Delete the lock file
```bash
rm -rf <flutter-sdk-path>/bin/cache/lockfile
```

### Issue: Pod install fails (iOS)
**Solution**: Update CocoaPods
```bash
cd ios
pod install
cd ..
```

## IDE Setup

### VS Code

Recommended extensions:
- Flutter
- Dart
- Error Lens

`.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "bellgo",
      "request": "launch",
      "type": "dart"
    }
  ]
}
```

### Android Studio / IntelliJ

1. Install Flutter plugin
2. Install Dart plugin
3. Open project
4. Run > Run 'main.dart'

## App Structure at a Glance

```
lib/
├── app/           # App setup (theme, routes, providers)
├── core/          # Constants and utilities
├── domain/        # Business logic (models, services)
├── data/          # Data layer (repositories, mocks)
├── features/      # UI screens
│   ├── today/     # Main dashboard
│   ├── calendar/  # Calendar view
│   ├── children/  # Manage children
│   ├── locations/ # Pickup locations
│   └── settings/  # App settings
└── main.dart      # Entry point
```

## Sample Data

The app starts with pre-loaded sample data:

**Child**: Viaan Gupta, Grade 5  
**School**: Mission San Jose Elementary  
**Location**: Work (San Jose, CA)  
**Schedule**: 3:05 PM dismissal, 18 min drive  

## Next Steps

1. ✅ Run the app
2. ✅ Navigate through all screens
3. ✅ Add a new child
4. ✅ Change locations
5. ✅ View calendar
6. ✅ Check settings

## Need Help?

- Flutter docs: https://flutter.dev/docs
- Riverpod docs: https://riverpod.dev
- GoRouter docs: https://pub.dev/packages/go_router

## Production Deployment

### iOS

1. Create `ios/` folder with `flutter create .`
2. Configure signing in Xcode
3. Build: `flutter build ios --release`

### Android

1. Create `android/` folder with `flutter create .`
2. Configure signing
3. Build: `flutter build apk --release`

For detailed deployment instructions, see Flutter's deployment documentation.

---

**BellGo** - Know when to go. 🚗🔔
