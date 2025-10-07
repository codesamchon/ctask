import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ctask/main.dart';
import 'package:ctask/providers/todo_provider.dart';

void main() {
  group('Main App Widget Tests', () {
    late TodoProvider todoProvider;

    setUp(() {
      todoProvider = TodoProvider();
    });

    testWidgets('App should start and display main screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: todoProvider,
          child: const TodoApp(),
        ),
      );

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // Verify that the main app elements are present
      expect(find.text('CTask'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      
      // Verify grid layout is present
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Theme toggle button should be present', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: todoProvider,
          child: const TodoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Look for theme toggle button (light/dark mode icons)
      Finder themeButton;
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        themeButton = find.byIcon(Icons.dark_mode);
      } else {
        themeButton = find.byIcon(Icons.light_mode);
      }
      expect(themeButton, findsOneWidget);
    });

    testWidgets('Floating action button should open add todo dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: todoProvider,
          child: const TodoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify that the add todo dialog appears
      expect(find.text('Add New Task'), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);
    });

    testWidgets('App should have menu with data management options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: todoProvider,
          child: const TodoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Verify menu options are present
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Import Data'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('Summary statistics should be displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: todoProvider,
          child: const TodoApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for summary section elements
      expect(find.text('Total Tasks'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}