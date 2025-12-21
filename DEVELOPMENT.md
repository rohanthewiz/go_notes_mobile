# Development Guide - GoNotes Flutter

This guide provides detailed information for developers working on GoNotes Flutter.

## Quick Start

```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Testing Strategy

### Test Coverage Goals
- **Models**: 100% coverage
- **Services**: 90%+ coverage
- **Widgets**: 80%+ coverage
- **Screens**: 70%+ coverage

### Running Tests

#### All Tests
```bash
flutter test
```

#### Specific Test Suite
```bash
# Model tests
flutter test test/models/

# Service tests
flutter test test/services/

# Widget tests
flutter test test/widgets/
```

#### With Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
# or
start coverage/html/index.html  # Windows
```

#### Watch Mode (automatically re-run on changes)
```bash
# Using find and entr (install entr first)
find lib test -name "*.dart" | entr -c flutter test
```

### Writing Tests

#### Unit Tests
Test individual functions and classes in isolation:

```dart
test('Note should be created with all required fields', () {
  final note = Note(
    id: '123',
    title: 'Test',
    content: 'Content',
    language: 'dart',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  expect(note.id, '123');
  expect(note.title, 'Test');
});
```

#### Widget Tests
Test UI components:

```dart
testWidgets('Should display language selector', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LanguageSelector(
        selectedLanguage: 'dart',
        onLanguageChanged: (_) {},
      ),
    ),
  );

  expect(find.byType(PopupMenuButton), findsOneWidget);
});
```

#### Integration Tests
Test complete user flows (create `integration_test/` directory):

```dart
testWidgets('Create and save note flow', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Tap FAB to create note
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();

  // Enter content
  await tester.enterText(find.byType(TextField), 'My Note');
  await tester.pumpAndSettle();

  // Verify saved
  expect(find.text('Saved'), findsOneWidget);
});
```

## Code Quality

### Linting
```bash
# Run analyzer
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Check for unused code
flutter analyze --fatal-infos
```

### Formatting
```bash
# Format all files
flutter format .

# Format specific file
flutter format lib/main.dart

# Check formatting without modifying
flutter format --set-exit-if-changed .
```

### Pre-commit Checks
Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
set -e

echo "Running pre-commit checks..."

# Format code
echo "Formatting code..."
flutter format .

# Analyze
echo "Running analyzer..."
flutter analyze --fatal-infos

# Run tests
echo "Running tests..."
flutter test

echo "All checks passed!"
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Performance Profiling

### CPU/GPU Performance
```bash
# Run in profile mode
flutter run --profile

# Then use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Memory Analysis
```bash
# Run with memory profiling
flutter run --profile --trace-skia

# Use DevTools Memory tab to analyze
```

### Build Size Analysis
```bash
# Build and analyze size
flutter build apk --analyze-size
flutter build appbundle --analyze-size
```

## Debugging

### Debug Mode Features
- Hot Reload: `r`
- Hot Restart: `R`
- Quit: `q`
- Widget Inspector: Use DevTools

### VS Code Launch Configuration
Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter (Profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    }
  ]
}
```

### Common Debug Commands
```dart
// Print debug info
debugPrint('Message: $value');

// Assert in debug mode
assert(condition, 'Error message');

// Check if in debug mode
if (kDebugMode) {
  print('Debug only');
}
```

## Database Migrations

When modifying the database schema:

1. Update `database_service.dart` `_onCreate()`
2. Increment `version` number
3. Add `_onUpgrade()` method:

```dart
Future<Database> _initDatabase() async {
  return await openDatabase(
    path,
    version: 2,  // Increment this
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE notes ADD COLUMN newField TEXT');
  }
}
```

## Adding New Features

### Checklist
- [ ] Create feature branch
- [ ] Implement feature
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Update documentation
- [ ] Run all tests
- [ ] Check code coverage
- [ ] Format code
- [ ] Create pull request

### Example: Adding a New Screen

1. **Create Screen File**
```dart
// lib/screens/my_new_screen.dart
class MyNewScreen extends StatefulWidget {
  const MyNewScreen({Key? key}) : super(key: key);

  @override
  State<MyNewScreen> createState() => _MyNewScreenState();
}
```

2. **Add Navigation**
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => MyNewScreen()),
);
```

3. **Write Tests**
```dart
// test/screens/my_new_screen_test.dart
testWidgets('MyNewScreen should display title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: MyNewScreen()),
  );

  expect(find.text('Expected Title'), findsOneWidget);
});
```

## Dependency Management

### Adding Dependencies
```bash
# Add runtime dependency
flutter pub add package_name

# Add dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade

# Get specific version
flutter pub add package_name:1.0.0
```

### Checking for Updates
```bash
# Check outdated packages
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade --major-versions
```

## Monaco Editor Integration

### Understanding the Integration

The Monaco editor is integrated via WebView:

1. **MonacoEditorWidget** wraps the `flutter_monaco_editor` package
2. Configuration is in `lib/widgets/monaco_editor_widget.dart`
3. Themes and languages are configured in options

### Customizing Monaco

To add custom Monaco features:

```dart
MonacoEditor(
  options: MonacoEditorOptions(
    // Add custom options here
    fontSize: 16,
    wordWrap: 'on',
    minimap: MinimapOptions(enabled: false),
  ),
)
```

### Monaco API Reference
- [Monaco Editor API](https://microsoft.github.io/monaco-editor/api/index.html)
- [flutter_monaco_editor Package](https://pub.dev/packages/flutter_monaco_editor)

## CI/CD Setup

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Platform-Specific Development

### Android

#### Build Variants
```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# Profile
flutter build apk --profile
```

#### Signing for Release
1. Create keystore: `keytool -genkey -v -keystore my-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias`
2. Update `android/key.properties`
3. Update `android/app/build.gradle`

### iOS

#### Provisioning
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing in target settings
3. Set bundle identifier

#### Build for Device
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

#### "Plugin not found"
```bash
flutter clean
flutter pub get
flutter run
```

#### "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter run
```

#### "CocoaPods issues" (iOS)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

### Performance Issues

1. **Slow startup**: Use `--profile` mode and check DevTools timeline
2. **Laggy scrolling**: Check for unnecessary rebuilds with Flutter DevTools
3. **Large bundle size**: Analyze with `flutter build --analyze-size`

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Monaco Editor Docs](https://microsoft.github.io/monaco-editor/)

## Best Practices

### State Management
- Use Provider for app-wide state
- Use StatefulWidget for local UI state
- Avoid unnecessary rebuilds with `const` constructors

### Error Handling
```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  debugPrint('Error: $e');
  debugPrintStack(stackTrace: stackTrace);
  // Show user-friendly error
}
```

### Null Safety
- Always handle nullable values
- Use `?`, `!`, `??` operators appropriately
- Prefer `??` over `!` when possible

### Performance
- Use `const` constructors wherever possible
- Avoid expensive operations in `build()` methods
- Use `ListView.builder` for long lists
- Cache expensive computations

### Accessibility
- Add semantic labels to important widgets
- Test with screen readers
- Ensure sufficient color contrast
- Support text scaling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Ensure all tests pass
6. Format code
7. Submit pull request

## License

MIT License - See LICENSE file for details
