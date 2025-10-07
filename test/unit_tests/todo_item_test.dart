import 'package:flutter_test/flutter_test.dart';
import 'package:ctask/models/todo_item.dart';

void main() {
  group('TodoItem Model Tests', () {
    test('TodoItem should be created with correct properties', () {
      final todo = TodoItem(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        state: TodoState.todo,
      );

      expect(todo.id, '1');
      expect(todo.title, 'Test Task');
      expect(todo.description, 'Test Description');
      expect(todo.state, TodoState.todo);
      expect(todo.pendingReason, isNull);
    });

    test('TodoItem should handle all states correctly', () {
      final todoStates = [
        TodoState.todo,
        TodoState.doing,
        TodoState.pending,
        TodoState.done,
      ];

      for (final state in todoStates) {
        final todo = TodoItem(
          id: '1',
          title: 'Test Task',
          state: state,
        );
        expect(todo.state, state);
      }
    });

    test('TodoItem should have correct state display names', () {
      expect(TodoItem(id: '1', title: 'Test', state: TodoState.todo).stateDisplayName, 'To Do');
      expect(TodoItem(id: '1', title: 'Test', state: TodoState.doing).stateDisplayName, 'Doing');
      expect(TodoItem(id: '1', title: 'Test', state: TodoState.pending).stateDisplayName, 'Pending');
      expect(TodoItem(id: '1', title: 'Test', state: TodoState.done).stateDisplayName, 'Done');
    });

    test('TodoItem copyWith should work correctly', () {
      final originalTodo = TodoItem(
        id: '1',
        title: 'Original Title',
        description: 'Original Description',
        state: TodoState.todo,
      );

      final updatedTodo = originalTodo.copyWith(
        title: 'Updated Title',
        state: TodoState.doing,
      );

      expect(updatedTodo.id, '1'); // Should remain the same
      expect(updatedTodo.title, 'Updated Title'); // Should be updated
      expect(updatedTodo.description, 'Original Description'); // Should remain the same
      expect(updatedTodo.state, TodoState.doing); // Should be updated
    });

    test('TodoItem JSON serialization should work correctly', () {
      final todo = TodoItem(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        state: TodoState.pending,
        pendingReason: 'Waiting for approval',
      );

      // Test toJson
      final json = todo.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['state'], 'pending');
      expect(json['pendingReason'], 'Waiting for approval');
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());

      // Test fromJson
      final todoFromJson = TodoItem.fromJson(json);
      expect(todoFromJson.id, todo.id);
      expect(todoFromJson.title, todo.title);
      expect(todoFromJson.description, todo.description);
      expect(todoFromJson.state, todo.state);
      expect(todoFromJson.pendingReason, todo.pendingReason);
    });

    test('TodoItem list serialization should work correctly', () {
      final todos = [
        TodoItem(id: '1', title: 'Task 1', state: TodoState.todo),
        TodoItem(id: '2', title: 'Task 2', state: TodoState.doing),
        TodoItem(id: '3', title: 'Task 3', state: TodoState.done),
      ];

      // Test listToJson
      final jsonList = TodoItem.listToJson(todos);
      expect(jsonList, hasLength(3));
      expect(jsonList[0]['title'], 'Task 1');
      expect(jsonList[1]['title'], 'Task 2');
      expect(jsonList[2]['title'], 'Task 3');

      // Test listFromJson
      final todosFromJson = TodoItem.listFromJson(jsonList);
      expect(todosFromJson, hasLength(3));
      expect(todosFromJson[0].title, 'Task 1');
      expect(todosFromJson[1].title, 'Task 2');
      expect(todosFromJson[2].title, 'Task 3');
    });

    test('TodoItem equality should work correctly', () {
      final todo1 = TodoItem(id: '1', title: 'Task 1');
      final todo2 = TodoItem(id: '1', title: 'Task 1 Updated');
      final todo3 = TodoItem(id: '2', title: 'Task 1');

      // Same ID should be equal
      expect(todo1, equals(todo2));
      
      // Different ID should not be equal
      expect(todo1, isNot(equals(todo3)));
    });

    test('TodoItem should handle pending reason correctly', () {
      final todo = TodoItem(
        id: '1',
        title: 'Test Task',
        state: TodoState.pending,
        pendingReason: 'Waiting for review',
      );

      expect(todo.pendingReason, 'Waiting for review');

      // When not pending, reason should be null or ignored
      final doneTodo = todo.copyWith(state: TodoState.done);
      expect(doneTodo.state, TodoState.done);
    });
  });
}