import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ctask/providers/todo_provider.dart';
import 'package:ctask/models/todo_item.dart';

void main() {
  group('TodoProvider Tests', () {
    late TodoProvider provider;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      provider = TodoProvider();
      await provider.init();
    });

    test('TodoProvider should start with empty list', () {
      expect(provider.todos, isEmpty);
      expect(provider.todoCount, 0);
      expect(provider.doingCount, 0);
      expect(provider.pendingCount, 0);
      expect(provider.doneCount, 0);
    });

    test('TodoProvider should add todos correctly', () async {
      expect(provider.todos, isEmpty);

      await provider.addTodo('Test Task', description: 'Test Description');

      expect(provider.todos, hasLength(1));
      expect(provider.todos.first.title, 'Test Task');
      expect(provider.todos.first.description, 'Test Description');
      expect(provider.todos.first.state, TodoState.todo);
      expect(provider.todoCount, 1);
    });

    test('TodoProvider should get todos by state correctly', () async {
      // Add todos with different states
      await provider.addTodo('Todo Task');
      await provider.addTodo('Doing Task');
      await provider.addTodo('Done Task');

      // Change states
      final todos = provider.todos;
      await provider.changeState(todos[1].id, TodoState.doing);
      await provider.changeState(todos[2].id, TodoState.done);

      expect(provider.getTodosByState(TodoState.todo), hasLength(1));
      expect(provider.getTodosByState(TodoState.doing), hasLength(1));
      expect(provider.getTodosByState(TodoState.done), hasLength(1));
      expect(provider.getTodosByState(TodoState.pending), isEmpty);

      expect(provider.todoCount, 1);
      expect(provider.doingCount, 1);
      expect(provider.doneCount, 1);
      expect(provider.pendingCount, 0);
    });

    test('TodoProvider should change todo state correctly', () async {
      await provider.addTodo('Test Task');
      final todoId = provider.todos.first.id;

      await provider.changeState(todoId, TodoState.doing);
      expect(provider.todos.first.state, TodoState.doing);
      expect(provider.doingCount, 1);
      expect(provider.todoCount, 0);

      await provider.changeState(todoId, TodoState.done);
      expect(provider.todos.first.state, TodoState.done);
      expect(provider.doneCount, 1);
      expect(provider.doingCount, 0);
    });

    test('TodoProvider should handle pending state with reason', () async {
      await provider.addTodo('Test Task');
      final todoId = provider.todos.first.id;

      await provider.changeState(todoId, TodoState.pending, pendingReason: 'Waiting for approval');
      
      expect(provider.todos.first.state, TodoState.pending);
      expect(provider.todos.first.pendingReason, 'Waiting for approval');
      expect(provider.pendingCount, 1);
    });

    test('TodoProvider should update todo correctly', () async {
      await provider.addTodo('Original Title');
      final todoId = provider.todos.first.id;

      await provider.updateTodo(
        todoId,
        title: 'Updated Title',
        description: 'Updated Description',
      );

      expect(provider.todos.first.title, 'Updated Title');
      expect(provider.todos.first.description, 'Updated Description');
    });

    test('TodoProvider should delete todo correctly', () async {
      await provider.addTodo('Task 1');
      await provider.addTodo('Task 2');
      expect(provider.todos, hasLength(2));

      final todoId = provider.todos.first.id;
      await provider.deleteTodo(todoId);

      expect(provider.todos, hasLength(1));
      expect(provider.todos.first.title, 'Task 2');
    });

    test('TodoProvider should clear all todos', () async {
      await provider.addTodo('Task 1');
      await provider.addTodo('Task 2');
      await provider.addTodo('Task 3');
      expect(provider.todos, hasLength(3));

      await provider.clearAllTodos();
      expect(provider.todos, isEmpty);
      expect(provider.getTodoCount(), 0);
    });

    test('TodoProvider should handle count methods correctly', () async {
      // Add todos with different states
      await provider.addTodo('Todo 1');
      await provider.addTodo('Todo 2');
      await provider.addTodo('Todo 3');
      await provider.addTodo('Todo 4');

      final todos = provider.todos;
      await provider.changeState(todos[1].id, TodoState.doing);
      await provider.changeState(todos[2].id, TodoState.pending, pendingReason: 'Test');
      await provider.changeState(todos[3].id, TodoState.done);

      expect(provider.getTodoCount(), 4);
      expect(provider.todoCount, 1);
      expect(provider.doingCount, 1);
      expect(provider.pendingCount, 1);
      expect(provider.doneCount, 1);

      expect(provider.getTodoCountByState(TodoState.todo), 1);
      expect(provider.getTodoCountByState(TodoState.doing), 1);
      expect(provider.getTodoCountByState(TodoState.pending), 1);
      expect(provider.getTodoCountByState(TodoState.done), 1);
    });

    test('TodoProvider should handle non-existent todo operations gracefully', () async {
      // Try to update non-existent todo
      await provider.updateTodo('non-existent-id', title: 'Updated');
      expect(provider.todos, isEmpty);

      // Try to delete non-existent todo
      await provider.deleteTodo('non-existent-id');
      expect(provider.todos, isEmpty);

      // Try to change state of non-existent todo
      await provider.changeState('non-existent-id', TodoState.done);
      expect(provider.todos, isEmpty);
    });

    test('TodoProvider should maintain data integrity', () async {
      await provider.addTodo('Task 1');
      await provider.addTodo('Task 2');
      
      final originalCount = provider.getTodoCount();
      final originalTodos = List<TodoItem>.from(provider.todos);

      // Verify todos are unmodifiable
      expect(() => provider.todos.add(TodoItem(id: 'test', title: 'test')), throwsUnsupportedError);

      // Verify count didn't change
      expect(provider.getTodoCount(), originalCount);
      
      // Verify original todos are still there
      for (int i = 0; i < originalTodos.length; i++) {
        expect(provider.todos[i].id, originalTodos[i].id);
        expect(provider.todos[i].title, originalTodos[i].title);
      }
    });
  });
}