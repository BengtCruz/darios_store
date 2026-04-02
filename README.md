# Dario's Store 🇮🇹

An Italian e-commerce application built with Flutter.

## About

Dario's Store is a cross-platform e-commerce app showcasing authentic Italian products. Built with Flutter for seamless experiences on iOS, Android, Web, and Desktop.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- Dart SDK (included with Flutter)
- An IDE with Flutter support (VS Code recommended)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd darios_store
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Available Commands

| Command | Description |
|---------|-------------|
| `flutter run` | Run the app in debug mode |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build for iOS |
| `flutter build web` | Build for web |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code for issues |

## Project Structure

```
lib/
├── main.dart          # App entry point
```

## Tech Stack

- **Framework:** Flutter 3.x (Material 3)
- **Language:** Dart
- **State Management:** InheritedNotifier (CartProviderScope, AuthProviderScope, AppLocaleProvider)
- **Backend:** Dart Frog with PostgreSQL
- **Authentication:** bcrypt password hashing + JWT tokens
- **Localization:** Custom EN/SV system

## License

This project is private and proprietary.
