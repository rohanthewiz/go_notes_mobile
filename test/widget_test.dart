import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gonotes/main.dart';

void main() {
  testWidgets('App should launch with GoNotes title', (WidgetTester tester) async {
    await tester.pumpWidget(const GoNotesApp());
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('GoNotes'), findsOneWidget);
  });

  testWidgets('App should show FAB for creating new note', (WidgetTester tester) async {
    await tester.pumpWidget(const GoNotesApp());
    await tester.pumpAndSettle();

    // Find the floating action button
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('App should have search icon in app bar', (WidgetTester tester) async {
    await tester.pumpWidget(const GoNotesApp());
    await tester.pumpAndSettle();

    // Find the search icon
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
