import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoRepository {
  static const String _todosKey = 'todos';
  static const String _themeKey = 'theme_mode';
  
  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      log('TodoRepository initialized successfully');
    } catch (e) {
      log('Failed to initialize TodoRepository: $e');
      rethrow;
    }
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Save todos to local storage
  Future<bool> saveTodos(List<TodoItem> todos) async {
    try {
      final prefsInstance = await prefs;
      final todosJson = TodoItem.listToJson(todos);
      final jsonString = jsonEncode(todosJson);
      
      final result = await prefsInstance.setString(_todosKey, jsonString);
      log('Saved ${todos.length} todos to local storage');
      return result;
    } catch (e) {
      log('Failed to save todos: $e');
      return false;
    }
  }

  // Load todos from local storage
  Future<List<TodoItem>> loadTodos() async {
    try {
      final prefsInstance = await prefs;
      final jsonString = prefsInstance.getString(_todosKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        log('No todos found in local storage');
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = TodoItem.listFromJson(jsonList);
      log('Loaded ${todos.length} todos from local storage');
      return todos;
    } catch (e) {
      log('Failed to load todos: $e');
      return [];
    }
  }

  // Clear all todos
  Future<bool> clearTodos() async {
    try {
      final prefsInstance = await prefs;
      final result = await prefsInstance.remove(_todosKey);
      log('Cleared all todos from local storage');
      return result;
    } catch (e) {
      log('Failed to clear todos: $e');
      return false;
    }
  }

  // Save theme preference
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      final prefsInstance = await prefs;
      final result = await prefsInstance.setString(_themeKey, themeMode);
      log('Saved theme mode: $themeMode');
      return result;
    } catch (e) {
      log('Failed to save theme mode: $e');
      return false;
    }
  }

  // Load theme preference
  Future<String> loadThemeMode() async {
    try {
      final prefsInstance = await prefs;
      final themeMode = prefsInstance.getString(_themeKey) ?? 'system';
      log('Loaded theme mode: $themeMode');
      return themeMode;
    } catch (e) {
      log('Failed to load theme mode: $e');
      return 'system';
    }
  }

  // Export todos as JSON string (for backup/sharing)
  Future<String?> exportTodos() async {
    try {
      final todos = await loadTodos();
      final todosJson = TodoItem.listToJson(todos);
      final jsonString = jsonEncode(todosJson);
      log('Exported ${todos.length} todos as JSON');
      return jsonString;
    } catch (e) {
      log('Failed to export todos: $e');
      return null;
    }
  }

  // Import todos from JSON string (for backup/sharing)
  Future<bool> importTodos(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = TodoItem.listFromJson(jsonList);
      final result = await saveTodos(todos);
      log('Imported ${todos.length} todos from JSON');
      return result;
    } catch (e) {
      log('Failed to import todos: $e');
      return false;
    }
  }

  // Get storage info (for debugging/monitoring)
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefsInstance = await prefs;
      final jsonString = prefsInstance.getString(_todosKey);
      final themeMode = prefsInstance.getString(_themeKey);
      
      return {
        'hasTodos': jsonString != null && jsonString.isNotEmpty,
        'todosSize': jsonString?.length ?? 0,
        'themeMode': themeMode ?? 'system',
        'lastModified': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      log('Failed to get storage info: $e');
      return {};
    }
  }

  // Web-specific method to check if running on web
  bool get isWeb {
    try {
      // This will throw on web platforms
      return identical(0, 0.0);
    } catch (e) {
      return true;
    }
  }

  // Future: Add cloud sync capabilities
  Future<bool> syncToCloud() async {
    // Placeholder for future cloud sync implementation
    // Could integrate with Firebase, Supabase, or custom backend
    log('Cloud sync not implemented yet');
    return false;
  }

  Future<bool> syncFromCloud() async {
    // Placeholder for future cloud sync implementation
    log('Cloud sync not implemented yet');
    return false;
  }
}