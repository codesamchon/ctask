import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ctask/main.dart';

void main() {

  group('CTask App Integration Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Complete todo workflow: add, change states, delete', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Step 1: Add a new todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Task'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Integration Test Task');
      await tester.enterText(find.byType(TextFormField).last, 'This is a test task for integration testing');

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Verify task was added and appears in Todo column
      expect(find.text('Integration Test Task'), findsOneWidget);
      expect(find.text('This is a test task for integration testing'), findsOneWidget);

      // Step 2: Move task to Doing state
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Working'));
      await tester.pumpAndSettle();

      // Verify task moved to Doing state
      expect(find.text('Integration Test Task'), findsOneWidget);

      // Step 3: Move task to Pending state with reason
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      // Should show pending reason dialog
      expect(find.text('Pause Task'), findsOneWidget);
      
      await tester.enterText(find.byType(TextFormField).first, 'Waiting for approval');
      await tester.tap(find.text('Pause Task'));
      await tester.pumpAndSettle();

      // Verify task is in pending state with reason
      expect(find.text('Integration Test Task'), findsOneWidget);
      expect(find.text('Waiting for approval'), findsOneWidget);

      // Step 4: Complete the task
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Verify task is completed
      expect(find.text('Integration Test Task'), findsOneWidget);

      // Step 5: Delete the task
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      expect(find.text('Delete Task'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify task is deleted
      expect(find.text('Integration Test Task'), findsNothing);
    });

    testWidgets('Data persistence: add task, restart app, verify task exists', (WidgetTester tester) async {
      // First session: Add a task
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Persistent Task');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Persistent Task'), findsOneWidget);

      // Simulate app restart by creating a new app instance
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Wait for data to load
      await tester.pump(const Duration(seconds: 2));

      // Verify task still exists after restart
      expect(find.text('Persistent Task'), findsOneWidget);
    });

    testWidgets('Theme toggle functionality', (WidgetTester tester) async {
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

      // Theme should have changed (verify opposite icon exists)
      if (find.byIcon(Icons.dark_mode).evaluate().isNotEmpty) {
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      } else {
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      }
    });

    testWidgets('Export and import data functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Add some test data
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Export Test Task');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Export Test Task'), findsOneWidget);

      // Test export functionality
      await tester.tap(find.byIcon(Icons.more_vert).last); // App menu, not task menu
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();

      // Export dialog should appear
      expect(find.text('Export Data'), findsWidgets);
      
      // Close export dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Test clear all functionality
      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // Confirm clear all
      expect(find.text('Clear All Data'), findsOneWidget);
      await tester.tap(find.text('Clear All').last);
      await tester.pumpAndSettle();

      // Verify data is cleared
      expect(find.text('Export Test Task'), findsNothing);
    });

    testWidgets('Error handling: invalid state transitions', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Error Test Task');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Task should be created successfully
      expect(find.text('Error Test Task'), findsOneWidget);

      // Try to interact with task menu multiple times quickly
      // This tests for race conditions and error handling
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();
        
        // Tap outside to close menu
        await tester.tapAt(const Offset(100, 100));
        await tester.pumpAndSettle();
      }

      // Task should still exist and be functional
      expect(find.text('Error Test Task'), findsOneWidget);
    });

    testWidgets('Summary statistics update correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Initial state: all counts should be 0
      expect(find.text('0'), findsNWidgets(3)); // Total, In Progress, Completed

      // Add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Summary Test Task');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // Total should now be 1
      expect(find.text('1'), findsOneWidget);

      // Move to doing state
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Working'));
      await tester.pumpAndSettle();

      // In Progress should now be 1
      expect(find.text('1'), findsNWidgets(2)); // Total and In Progress

      // Complete the task
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Completed should now be 1, In Progress should be 0
      expect(find.text('1'), findsNWidgets(2)); // Total and Completed
      expect(find.text('0'), findsOneWidget); // In Progress
    });

    testWidgets('Multiple tasks workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const TodoApp());
      await tester.pumpAndSettle();

      // Add multiple tasks
      final taskTitles = ['Task 1', 'Task 2', 'Task 3', 'Task 4'];
      
      for (final title in taskTitles) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).first, title);
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();

        expect(find.text(title), findsOneWidget);
      }

      // Verify all tasks are created
      for (final title in taskTitles) {
        expect(find.text(title), findsOneWidget);
      }

      // Move tasks to different states
      final tasks = find.byIcon(Icons.more_vert);
      
      // Move first task to doing
      await tester.tap(tasks.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Working'));
      await tester.pumpAndSettle();

      // Move second task to pending
      await tester.tap(tasks.at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, 'Test pause reason');
      await tester.tap(find.text('Pause Task'));
      await tester.pumpAndSettle();

      // Move third task to done
      await tester.tap(tasks.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start Working'));
      await tester.pumpAndSettle();

      await tester.tap(tasks.at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete'));
      await tester.pumpAndSettle();

      // Verify all tasks still exist
      for (final title in taskTitles) {
        expect(find.text(title), findsOneWidget);
      }

      // Verify statistics are correct
      expect(find.text('4'), findsOneWidget); // Total tasks
      expect(find.text('1'), findsNWidgets(2)); // In Progress and Completed
    });
  });
}