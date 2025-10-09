import '../models/todo_item.dart';

/// Minimal repository interface for todos and settings persistence.
abstract class TodoRepositoryBase {
  Future<void> init();

  Future<List<TodoItem>> loadTodos();
  Future<bool> saveTodos(List<TodoItem> todos);
  Future<bool> clearTodos();

  Future<String?> exportTodos();
  Future<bool> importTodos(String jsonString);

  Future<bool> saveDensity(double density);
  Future<double> loadDensity();

  Future<bool> saveCurrentUser(String userId);
  Future<String> loadCurrentUser();

  Future<Map<String, dynamic>> getStorageInfo();
}
