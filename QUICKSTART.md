# Quick Start Guide

Get GoNotes Flutter up and running in 5 minutes!

## Prerequisites

- Flutter SDK 3.2.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- A device or emulator (Android/iOS) or web browser

## 1. Verify Flutter Installation

```bash
flutter doctor
```

Make sure you see checkmarks (✓) for the platforms you want to target.

## 2. Setup the Project

```bash
cd GoNotesFlutter
./scripts/setup.sh
```

This will:
- Install all dependencies
- Run Flutter doctor
- Format code
- Check for issues

## 3. Run the App

### Option A: Automatic (Recommended)

```bash
flutter run
```

Flutter will automatically detect and use an available device.

### Option B: Choose a Specific Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Examples:
flutter run -d chrome          # Web
flutter run -d android         # Android emulator/device
flutter run -d ios             # iOS simulator/device
```

## 4. Start Developing

The app will launch with hot-reload enabled. Make changes to the code and:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

## Common Commands

```bash
# Run tests
./scripts/test.sh

# Build for production
./scripts/build-release.sh android    # Android APK/AAB
./scripts/build-release.sh web        # Web build
./scripts/build-release.sh all        # All platforms

# Format code
flutter format .

# Analyze code
flutter analyze

# Clean build
flutter clean
```

## First Time Using the App?

1. **Create a Note**: Tap the **+** button
2. **Write Code**: Start typing in the Monaco editor
3. **Change Language**: Tap the **code icon** and select a language
4. **Change Theme**: Tap the **palette icon** and pick a theme
5. **Save**: It auto-saves! Look for the "Saved" indicator

## Keyboard Shortcuts

Once you're editing a note:
- `Ctrl+S` - Save
- `Ctrl+F` - Find
- `Ctrl+H` - Replace
- `Ctrl+Z` - Undo
- `Ctrl+Y` - Redo
- `Ctrl+/` - Toggle comment

## Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Tests failing?
```bash
flutter pub get
flutter test
```

### Monaco editor not loading?
- Ensure you have internet connection (first load only)
- Check that WebView is enabled on your device

## What's Next?

- Read the full [README.md](README.md) for detailed features
- Check [DEVELOPMENT.md](DEVELOPMENT.md) for development tips
- Browse the code in `lib/` to understand the structure
- Write your first note with syntax highlighting!

## Need Help?

- Check the [README.md](README.md) for full documentation
- Read [DEVELOPMENT.md](DEVELOPMENT.md) for development guides
- Review tests in `test/` for code examples

Happy coding! 🚀
