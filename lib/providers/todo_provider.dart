import 'package:flutter/foundation.dart';
import 'dart:developer';
import '../models/todo_item.dart';
import '../repositories/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _todos = [];
  final TodoRepository _repository = TodoRepository();
  
  bool _isLoading = false;
  String? _error;

  List<TodoItem> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the provider and load existing todos
  Future<void> init() async {
    _setLoading(true);
    try {
      await _repository.init();
      final loadedTodos = await _repository.loadTodos();
      _todos.clear();
      _todos.addAll(loadedTodos);
      _clearError();
      log('TodoProvider initialized with ${_todos.length} todos');
    } catch (e) {
      _setError('Failed to load todos: $e');
      log('Failed to initialize TodoProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    try {
      await _repository.saveTodos(_todos);
      _clearError();
    } catch (e) {
      _setError('Failed to save todos: $e');
      log('Failed to save todos: $e');
    }
  }

  List<TodoItem> getTodosByState(TodoState state) {
    return _todos.where((todo) => todo.state == state).toList();
  }

  Future<void> addTodo(String title, {String description = ''}) async {
    try {
      final todo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
      );
      _todos.add(todo);
      await _saveTodos();
      notifyListeners();
      log('Added todo: ${todo.title}');
    } catch (e) {
      _setError('Failed to add todo: $e');
    }
  }

  Future<void> updateTodo(String id, {
    String? title,
    String? description,
    TodoState? state,
    String? pendingReason,
  }) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final updatedTodo = _todos[index].copyWith(
          title: title,
          description: description,
          state: state,
          pendingReason: pendingReason,
          updatedAt: DateTime.now(),
        );
        _todos[index] = updatedTodo;
        await _saveTodos();
        notifyListeners();
        log('Updated todo: ${updatedTodo.title}');
      }
    } catch (e) {
      _setError('Failed to update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final todoTitle = _todos.firstWhere((todo) => todo.id == id).title;
      _todos.removeWhere((todo) => todo.id == id);
      await _saveTodos();
      notifyListeners();
      log('Deleted todo: $todoTitle');
    } catch (e) {
      _setError('Failed to delete todo: $e');
    }
  }

  Future<void> changeState(String id, TodoState newState, {String? pendingReason}) async {
    try {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final updatedTodo = _todos[index].copyWith(
          state: newState,
          pendingReason: newState == TodoState.pending ? pendingReason : null,
          updatedAt: DateTime.now(),
        );
        _todos[index] = updatedTodo;
        await _saveTodos();
        notifyListeners();
        log('Changed todo state: ${updatedTodo.title} -> ${newState.name}');
      }
    } catch (e) {
      _setError('Failed to change todo state: $e');
    }
  }

  int getTodoCount() => _todos.length;
  int getTodoCountByState(TodoState state) => getTodosByState(state).length;

  // Helper methods for getting counts
  int get todoCount => getTodoCountByState(TodoState.todo);
  int get doingCount => getTodoCountByState(TodoState.doing);
  int get pendingCount => getTodoCountByState(TodoState.pending);
  int get doneCount => getTodoCountByState(TodoState.done);

  // Data management methods
  Future<void> clearAllTodos() async {
    try {
      _todos.clear();
      await _repository.clearTodos();
      notifyListeners();
      log('Cleared all todos');
    } catch (e) {
      _setError('Failed to clear todos: $e');
    }
  }

  Future<String?> exportTodos() async {
    try {
      final exportData = await _repository.exportTodos();
      log('Exported todos');
      return exportData;
    } catch (e) {
      _setError('Failed to export todos: $e');
      return null;
    }
  }

  Future<bool> importTodos(String jsonData) async {
    try {
      _setLoading(true);
      final success = await _repository.importTodos(jsonData);
      if (success) {
        // Reload todos after import
        final loadedTodos = await _repository.loadTodos();
        _todos.clear();
        _todos.addAll(loadedTodos);
        _clearError();
        notifyListeners();
        log('Imported todos successfully');
      }
      return success;
    } catch (e) {
      _setError('Failed to import todos: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshTodos() async {
    await init();
  }

  // Get storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    return await _repository.getStorageInfo();
  }
}