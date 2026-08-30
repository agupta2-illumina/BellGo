# BellGo

**Know when to go.**

BellGo is a smart school-day assistant for parents that automatically determines when school ends and tells you when to leave to pick up your child on time.

## The Problem

Parents often forget when their child's school day ends, especially on:
- Minimum days
- Early-release days  
- Fridays
- Holidays
- Teacher workdays
- Schedule changes

## The Solution

BellGo answers the most important question: **"Do I need to leave now?"**

Instead of showing "School ends at 3:05 PM", BellGo calculates:
- Your current location
- Drive time to school
- Pickup buffer time

And tells you: **"Leave by 2:42 PM"**

## Architecture

This is a production-quality Flutter application with:

- **Clean Architecture** - Domain, Data, and Presentation layers
- **Riverpod** - Type-safe state management
- **GoRouter** - Declarative navigation
- **Mock Data** - Fully functional without backend
- **iOS-first Design** - Premium native feel

## Project Structure

```
lib/
├── app/              # App initialization, routing, theme
├── core/             # Constants, errors, utilities
├── domain/           # Business logic and interfaces
├── data/             # Data implementations and mocks
├── features/         # Feature modules
│   ├── onboarding/
│   ├── today/
│   ├── calendar/
│   ├── children/
│   ├── schools/
│   ├── locations/
│   ├── notifications/
│   └── settings/
└── shared/           # Reusable widgets
```

## Getting Started

```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## MVP Features

- ✅ Today dashboard with smart leave time
- ✅ Visual timeline and status indicators
- ✅ Tomorrow preview
- ✅ Calendar view with schedule types
- ✅ Children management
- ✅ Location management
- ✅ Settings and preferences
- ✅ Mock notifications

## Future Enhancements

- User authentication
- Cloud sync
- Real school calendar integration
- Live traffic data
- Push notifications
- Multiple parents
- Family sharing

## License

Proprietary
