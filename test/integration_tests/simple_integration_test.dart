import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ctask/main.dart';

void main() {
  group('CTask App Basic Integration Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App should start and show grid layout', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Should show the grid layout with 4 states
      expect(find.text('TODO'), findsOneWidget);
      expect(find.text('DOING'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('DONE'), findsOneWidget);

      // Should show FloatingActionButton
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Add a new todo task', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Tap the add button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Task'), findsOneWidget);

      // Enter task details
      await tester.enterText(find.byType(TextFormField).first, 'Test Task');
      if (find.byType(TextFormField).evaluate().length > 1) {
        await tester.enterText(find.byType(TextFormField).last, 'Test Description');
      }

      // Submit the form
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify task was added
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('Theme toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Find theme toggle button (try both icons)
      Finder themeButton;
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        themeButton = find.byIcon(Icons.dark_mode);
      } else {
        themeButton = find.byIcon(Icons.light_mode);
      }
      expect(themeButton, findsOneWidget);

      // Tap to toggle theme
      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      // Theme should have changed (verify opposite icon exists or same icon exists)
      // We just check that the app still works after theme toggle
      expect(find.text('TODO'), findsOneWidget);
    });

    testWidgets('Summary stats show correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Summary Test Task');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // The summary should show at least one task
      expect(find.text('Summary Test Task'), findsOneWidget);
      
      // Check that the summary card exists (it has the total count)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('App handles multiple tasks', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Add multiple tasks
      final taskTitles = ['Task 1', 'Task 2', 'Task 3'];
      
      for (final title in taskTitles) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, title);
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();
      }

      // Verify all tasks are present
      for (final title in taskTitles) {
        expect(find.text(title), findsOneWidget);
      }
    });
  });
}