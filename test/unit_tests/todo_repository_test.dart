import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ctask/repositories/todo_repository.dart';
import 'package:ctask/models/todo_item.dart';

void main() {
  group('TodoRepository Tests', () {
    late TodoRepository repository;

    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      repository = TodoRepository();
      await repository.init();
    });

    test('TodoRepository should initialize correctly', () async {
      final newRepository = TodoRepository();
      await newRepository.init();
      
      // Should not throw any errors
      expect(newRepository, isNotNull);
    });

    test('TodoRepository should save and load todos correctly', () async {
      final todos = [
        TodoItem(id: '1', title: 'Task 1', state: TodoState.todo),
        TodoItem(id: '2', title: 'Task 2', state: TodoState.doing),
        TodoItem(id: '3', title: 'Task 3', state: TodoState.done),
      ];

      // Save todos
      final saveResult = await repository.saveTodos(todos);
      expect(saveResult, isTrue);

      // Load todos
      final loadedTodos = await repository.loadTodos();
      expect(loadedTodos, hasLength(3));
      expect(loadedTodos[0].title, 'Task 1');
      expect(loadedTodos[1].title, 'Task 2');
      expect(loadedTodos[2].title, 'Task 3');
      expect(loadedTodos[0].state, TodoState.todo);
      expect(loadedTodos[1].state, TodoState.doing);
      expect(loadedTodos[2].state, TodoState.done);
    });

    test('TodoRepository should handle empty todos list', () async {
      final emptyTodos = <TodoItem>[];
      
      final saveResult = await repository.saveTodos(emptyTodos);
      expect(saveResult, isTrue);

      final loadedTodos = await repository.loadTodos();
      expect(loadedTodos, isEmpty);
    });

    test('TodoRepository should return empty list when no data exists', () async {
      final loadedTodos = await repository.loadTodos();
      expect(loadedTodos, isEmpty);
    });

    test('TodoRepository should save and load theme mode', () async {
      // Save theme mode
      final saveResult = await repository.saveThemeMode('dark');
      expect(saveResult, isTrue);

      // Load theme mode
      final themeMode = await repository.loadThemeMode();
      expect(themeMode, 'dark');
    });

    test('TodoRepository should return default theme mode when none exists', () async {
      final themeMode = await repository.loadThemeMode();
      expect(themeMode, 'system');
    });

    test('TodoRepository should clear todos correctly', () async {
      final todos = [
        TodoItem(id: '1', title: 'Task 1'),
        TodoItem(id: '2', title: 'Task 2'),
      ];

      await repository.saveTodos(todos);
      
      // Verify todos exist
      final loadedTodos = await repository.loadTodos();
      expect(loadedTodos, hasLength(2));

      // Clear todos
      final clearResult = await repository.clearTodos();
      expect(clearResult, isTrue);

      // Verify todos are cleared
      final clearedTodos = await repository.loadTodos();
      expect(clearedTodos, isEmpty);
    });

    test('TodoRepository should export todos as JSON string', () async {
      final todos = [
        TodoItem(id: '1', title: 'Task 1', state: TodoState.todo),
        TodoItem(id: '2', title: 'Task 2', state: TodoState.pending, pendingReason: 'Test reason'),
      ];

      await repository.saveTodos(todos);

      final exportedJson = await repository.exportTodos();
      expect(exportedJson, isNotNull);
      expect(exportedJson, contains('Task 1'));
      expect(exportedJson, contains('Task 2'));
      expect(exportedJson, contains('Test reason'));
    });

    test('TodoRepository should import todos from JSON string', () async {
      final todos = [
        TodoItem(id: '1', title: 'Imported Task 1', state: TodoState.doing),
        TodoItem(id: '2', title: 'Imported Task 2', state: TodoState.done),
      ];

      await repository.saveTodos(todos);
      final exportedJson = await repository.exportTodos();

      // Clear existing todos
      await repository.clearTodos();

      // Import from JSON
      final importResult = await repository.importTodos(exportedJson!);
      expect(importResult, isTrue);

      // Verify imported todos
      final importedTodos = await repository.loadTodos();
      expect(importedTodos, hasLength(2));
      expect(importedTodos[0].title, 'Imported Task 1');
      expect(importedTodos[1].title, 'Imported Task 2');
    });

    test('TodoRepository should handle todos with pending reasons', () async {
      final todo = TodoItem(
        id: '1',
        title: 'Pending Task',
        state: TodoState.pending,
        pendingReason: 'Waiting for approval',
      );

      await repository.saveTodos([todo]);
      final loadedTodos = await repository.loadTodos();

      expect(loadedTodos, hasLength(1));
      expect(loadedTodos.first.title, 'Pending Task');
      expect(loadedTodos.first.state, TodoState.pending);
      expect(loadedTodos.first.pendingReason, 'Waiting for approval');
    });

    test('TodoRepository should provide storage info', () async {
      final todos = [
        TodoItem(id: '1', title: 'Task 1'),
        TodoItem(id: '2', title: 'Task 2'),
      ];

      await repository.saveTodos(todos);
      await repository.saveThemeMode('dark');

      final storageInfo = await repository.getStorageInfo();
      expect(storageInfo['hasTodos'], isTrue);
      expect(storageInfo['todosSize'], greaterThan(0));
      expect(storageInfo['themeMode'], 'dark');
      expect(storageInfo['lastModified'], isNotNull);
    });

    test('TodoRepository should handle malformed JSON gracefully', () async {
      // This test verifies error handling for invalid JSON
      final importResult = await repository.importTodos('invalid json string');
      expect(importResult, isFalse);
    });

    test('TodoRepository should preserve todo dates correctly', () async {
      final now = DateTime.now();
      final todo = TodoItem(
        id: '1',
        title: 'Test Task',
        createdAt: now,
        updatedAt: now,
      );

      await repository.saveTodos([todo]);
      final loadedTodos = await repository.loadTodos();

      expect(loadedTodos, hasLength(1));
      // Note: Date comparison might have slight differences due to serialization
      expect(loadedTodos.first.createdAt.millisecondsSinceEpoch, 
             closeTo(now.millisecondsSinceEpoch, 1000));
    });
  });
}