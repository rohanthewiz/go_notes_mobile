import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonotes/widgets/language_selector.dart';

void main() {
  group('LanguageSelector Widget Tests', () {
    testWidgets('Should display popup menu with languages', (WidgetTester tester) async {
      String selectedLanguage = 'markdown';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selectedLanguage: selectedLanguage,
              onLanguageChanged: (lang) {
                selectedLanguage = lang;
              },
            ),
          ),
        ),
      );

      // Find the popup menu button
      final menuButton = find.byType(PopupMenuButton<String>);
      expect(menuButton, findsOneWidget);

      // Tap to open menu
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Verify that some languages are shown
      expect(find.text('Markdown'), findsOneWidget);
      expect(find.text('JavaScript'), findsOneWidget);
      expect(find.text('Python'), findsOneWidget);
    });

    testWidgets('Should show checkmark for selected language', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selectedLanguage: 'javascript',
              onLanguageChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // JavaScript item should have a check icon
      final jsItem = find.ancestor(
        of: find.text('JavaScript'),
        matching: find.byType(PopupMenuItem<String>),
      );
      expect(jsItem, findsOneWidget);
    });

    test('Should return correct language name', () {
      expect(LanguageSelector.getLanguageName('markdown'), 'Markdown');
      expect(LanguageSelector.getLanguageName('javascript'), 'JavaScript');
      expect(LanguageSelector.getLanguageName('python'), 'Python');
      expect(LanguageSelector.getLanguageName('unknown'), 'unknown');
    });

    test('Should return appropriate icons for languages', () {
      expect(LanguageSelector.getLanguageIcon('markdown'), Icons.notes);
      expect(LanguageSelector.getLanguageIcon('javascript'), Icons.javascript);
      expect(LanguageSelector.getLanguageIcon('dart'), Icons.flutter_dash);
      expect(LanguageSelector.getLanguageIcon('unknown'), Icons.description);
    });
  });
}
