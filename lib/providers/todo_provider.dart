import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import '../models/todo_item.dart';
import '../repositories/todo_repository_base.dart';
import '../repositories/todo_repository.dart' as local_repo;

class TodoProvider extends ChangeNotifier {
  final List<TodoItem> _todos = [];
  final TodoRepositoryBase _repository;
  StreamSubscription<DatabaseEvent>? _todosSubscription;

  // Allow injecting a repository (local or cloud-backed)
  TodoProvider({TodoRepositoryBase? repository}) : _repository = repository ?? local_repo.TodoRepository();
  
  bool _isLoading = false;
  String? _error;
  double _density = 1.0;
  String _currentUser = 'KH';
  final List<String> _users = ['KH', 'JM', 'RK'];

  List<TodoItem> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get density => _density;
  String get currentUser => _currentUser;
  List<String> get users => List.unmodifiable(_users);

  // Initialize the provider and load existing todos
  Future<void> init() async {
    _setLoading(true);
    try {
      await _repository.init();
      // If using the realtime repository, listen for remote changes
      if (_repository.runtimeType.toString() == 'RealtimeTodoRepository') {
        final ref = FirebaseDatabase.instance.ref('todos');
        _todosSubscription = ref.onValue.listen((event) {
          try {
            final val = event.snapshot.value;
            if (val == null) {
              _todos.clear();
              notifyListeners();
              return;
            }
            if (val is Map<dynamic, dynamic>) {
              final list = val.values.map((v) => TodoItem.fromJson(Map<String, dynamic>.from(v))).toList();
              _todos.clear();
              _todos.addAll(list);
              notifyListeners();
            }
          } catch (e) {
            log('Failed to process realtime update: $e');
          }
        }, onError: (e) {
          log('Realtime subscription error: $e');
        });
      }
      // load density
      _density = await _repository.loadDensity();
      // load current user
      _currentUser = await _repository.loadCurrentUser();
      // Normalize loaded user: if it's not in known users, default to first and persist
      if (!_users.contains(_currentUser)) {
        _currentUser = _users.first;
        try {
          await _repository.saveCurrentUser(_currentUser);
        } catch (_) {}
      }
      notifyListeners();
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

  @override
  void dispose() {
    _todosSubscription?.cancel();
    super.dispose();
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

  Future<void> addTodo(String title, {String description = '', String? assignedTo, String? createdBy}) async {
    try {
      final todo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        assignedTo: assignedTo,
        createdBy: createdBy ?? _currentUser,
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

  // Set density and persist
  Future<void> setDensity(double value) async {
    // clamp density to sensible range used by the UI (match SettingsDialog slider)
    final clamped = value.clamp(0.6, 1.4);
    _density = clamped;
    notifyListeners();
    try {
      await _repository.saveDensity(value);
    } catch (e) {
      log('Failed to persist density: $e');
    }
  }

  // Set current user and persist
  Future<void> setCurrentUser(String userId) async {
    if (!_users.contains(userId)) return;
    _currentUser = userId;
    notifyListeners();
    try {
      await _repository.saveCurrentUser(userId);
    } catch (e) {
      log('Failed to persist current user: $e');
    }
  }

  // Get storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    return await _repository.getStorageInfo();
  }

  /// Returns a short identifier for the repository in use (for debugging)
  String get backendType => _repository.runtimeType.toString();

  /// Check backend connectivity/storage info via repository
  Future<Map<String, dynamic>> checkBackend() async {
    try {
      return await _repository.getStorageInfo();
    } catch (e) {
      log('checkBackend failed: $e');
      return {'error': e.toString()};
    }
  }

  /// Seed a couple of sample todos into the configured repository.
  /// Returns true if successful.
  Future<bool> seedSampleTodos() async {
    try {
      final samples = [
        TodoItem(id: 'seed-1', title: 'Seed Task 1', state: TodoState.todo, createdBy: _currentUser),
        TodoItem(id: 'seed-2', title: 'Seed Task 2', state: TodoState.doing, createdBy: _currentUser),
      ];
      final success = await _repository.saveTodos(samples);
      if (success) {
        // reload todos from repository
        final loaded = await _repository.loadTodos();
        _todos.clear();
        _todos.addAll(loaded);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to seed samples: $e');
      return false;
    }
  }
}