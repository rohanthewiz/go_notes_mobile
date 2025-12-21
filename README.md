# GoNotes - Mobile Programmer's Editor

A powerful Flutter-based note-taking application with native code editor, designed specifically for mobile developers. Features syntax highlighting for 100+ programming languages, optimized mobile typing experience, and smooth performance.

## Features

### ✨ Native Flutter Code Editor
- **Mobile-Optimized**: Built with re_editor for perfect mobile performance
- **Syntax Highlighting**: Support for 100+ programming languages via re_highlight
- **Smart Features**:
  - Line numbers and code folding
  - Bidirectional scrolling
  - Word wrap
  - Native touch handling (no WebView lag)
  - Instant character rendering
  - Perfect keyboard support (onscreen and external)

### 💼 Developer-Friendly
- **Multiple Themes**: Atom One Dark, Atom One Light
- **Keyboard Shortcuts**: Full support for standard editor shortcuts
  - `Ctrl+S` - Save note (works with external keyboards)
  - `Ctrl+F` - Find
  - `Ctrl+H` - Find & Replace
  - `Ctrl+Z` - Undo
  - `Ctrl+Y` - Redo
  - `Ctrl+/` - Toggle comment
- **Smart Auto-Save**: 10-second delay after typing stops
- **Visual Indicators**: Clean save status (no intrusive toasts)

### 📝 Note Management
- **Local Storage**: SQLite database for fast, offline access
- **Search**: Full-text search across all notes
- **Pin Notes**: Keep important notes at the top
- **File Import**: Import existing code files
- **Share**: Share notes to other apps

### 🎯 Supported Languages

**100+ languages** including:
- **Web**: JavaScript, TypeScript, HTML, CSS, JSON, XML
- **Mobile**: Dart, Swift, Kotlin, Java
- **Backend**: Python, Go, Java, Ruby, PHP, Rust, Scala
- **Systems**: C, C++, Rust
- **Data**: SQL, YAML, JSON
- **Scripting**: Bash, Shell, Perl, R
- **Markup**: Markdown, HTML, XML
- **And many more...**

## Requirements

- Flutter SDK 3.2.0 or higher
- Dart 3.0.0 or higher
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

## Getting Started

### 1. Install Flutter

If you haven't already, install Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install).

Verify your installation:
```bash
flutter doctor
```

### 2. Clone and Setup

```bash
cd GoNotesFlutter
flutter pub get
```

### 3. Run the App

#### On Android/iOS Device or Emulator
```bash
# List available devices
flutter devices

# Run on connected device
flutter run

# Run in release mode for better performance
flutter run --release
```

#### On Web
```bash
flutter run -d chrome
```

#### On Desktop (Linux/macOS/Windows)
```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## Building for Production

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS
```bash
flutter build ios --release
# Then open in Xcode: ios/Runner.xcworkspace
```

### Web
```bash
flutter build web --release
# Output: build/web/
```

## Project Structure

```
gonotes/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── note.dart            # Note data model
│   ├── services/
│   │   ├── database_service.dart # SQLite database operations
│   │   └── note_provider.dart    # State management
│   ├── screens/
│   │   ├── note_list_screen.dart # Note list view
│   │   └── note_editor_screen.dart # Monaco editor screen
│   └── widgets/
│       ├── monaco_editor_widget.dart # Monaco wrapper
│       └── language_selector.dart    # Language picker
├── test/                        # Unit & widget tests
├── android/                     # Android-specific code
├── ios/                        # iOS-specific code
└── pubspec.yaml               # Dependencies
```

## Usage Guide

### Creating a New Note
1. Tap the **+** button (floating action button)
2. Enter a title
3. Start typing in the Monaco editor
4. Auto-save will save your changes automatically

### Changing Language/Syntax
1. Open a note
2. Tap the **code icon** in the app bar
3. Select your desired language
4. Syntax highlighting updates immediately

### Changing Theme
1. Open a note
2. Tap the **palette icon** in the app bar
3. Choose from available themes:
   - Dark (VS Code) - Default
   - Light (VS Code)
   - High Contrast Dark
   - High Contrast Light

### Importing Files
1. From the note list, tap the **menu** (three dots)
2. Select **Import File**
3. Choose a file from your device
4. The file will be imported with appropriate syntax highlighting

### Searching Notes
1. Tap the **search icon** in the app bar
2. Type your search query
3. Results update in real-time
4. Search works across both titles and content

### Pinning Notes
1. In the note list, tap the **pin icon** on any note
2. Pinned notes appear at the top with an amber pin icon
3. Tap again to unpin

### Sharing Notes
1. Open a note
2. Tap the **menu** (three dots)
3. Select **Share**
4. Choose your sharing method

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/models/note_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Categories
- **Unit Tests**: Model and service logic (`test/models/`, `test/services/`)
- **Widget Tests**: UI components (`test/widgets/`)
- **Integration Tests**: Full app flows (`test/widget_test.dart`)

## Development Tips

### Hot Reload
While running the app, press `r` in the terminal to hot reload changes, or `R` for a full restart.

### Debugging
Use VS Code or Android Studio with Flutter extensions for:
- Breakpoints
- Variable inspection
- Widget inspector
- Performance profiling

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Run linter
flutter analyze --fatal-infos
```

## Performance Optimization

### Monaco Editor
- Monaco loads from CDN on first use
- Subsequent loads use cached resources
- Disable minimap for better mobile performance (already configured)

### Database
- Uses indexes for fast search
- Batch operations for multiple updates
- Connection pooling via singleton pattern

## Troubleshooting

### Monaco Editor Not Loading
- Ensure internet connection on first launch
- Check that WebView is enabled
- Clear app cache and restart

### Build Errors
```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

### Platform-Specific Issues

**Android:**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**iOS:**
```bash
cd ios
pod install
cd ..
flutter run
```

## Architecture

### State Management
- **Provider**: Simple and efficient state management
- **NoteProvider**: Manages note operations and UI state
- **ChangeNotifier**: Reactive updates to UI

### Database
- **SQLite (sqflite)**: Local persistent storage
- **Repository Pattern**: Clean separation of data access
- **Singleton**: Single database instance

### UI/UX
- **Material Design 3**: Modern, consistent UI
- **Dark/Light Themes**: System-aware theming
- **Responsive**: Adapts to different screen sizes
- **Accessibility**: Screen reader support, semantic labels

## Contributing

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use provided `analysis_options.yaml`
- Format code before committing: `flutter format .`

### Adding a New Language
1. Add to `LanguageSelector.languages` in `lib/widgets/language_selector.dart`
2. Add icon mapping in `getLanguageIcon()`
3. Add file extension mapping in `note_provider.dart` `importNote()`

## Known Limitations

1. **Monaco Package**: The `flutter_monaco_editor` package is relatively new and may have some platform-specific issues
2. **WebView Dependency**: Monaco requires WebView support
3. **Large Files**: Very large files (>1MB) may impact performance
4. **Offline**: Monaco CDN requires internet on first load

## Future Enhancements

- [ ] Multi-file projects/workspaces
- [ ] Git integration
- [ ] Cloud sync
- [ ] Collaborative editing
- [ ] Custom themes
- [ ] Plugin system
- [ ] Export to PDF/HTML
- [ ] Terminal integration

## License

MIT License - Feel free to use and modify as needed.

## Tech Stack

- **Framework**: Flutter 3.2+
- **Language**: Dart 3.0+
- **Editor**: Monaco Editor (flutter_monaco_editor)
- **Database**: SQLite (sqflite)
- **State Management**: Provider
- **UI**: Material Design 3
- **Testing**: flutter_test, mockito

## Support

For issues and feature requests, please use the GitHub issue tracker.

## Acknowledgments

- Monaco Editor by Microsoft
- Flutter team at Google
- All open-source contributors
