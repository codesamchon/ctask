import 'dart:convert';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';

import '../models/todo_item.dart';
import 'todo_repository_base.dart';

/// Realtime Database implementation.
/// Writes todos under `/todos/{id}` and settings under `/settings/app`.
class RealtimeTodoRepository implements TodoRepositoryBase {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  final String _todosPath = 'todos';
  final String _settingsPath = 'settings/app';

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    log('RealtimeTodoRepository initialized');
  }

  @override
  Future<bool> saveTodos(List<TodoItem> todos) async {
    try {
      final ref = _db.ref(_todosPath);

      // Read existing keys so we can remove any that no longer exist locally
      final existingSnap = await ref.get();
      final existingKeys = <String>{};
      if (existingSnap.exists && existingSnap.value != null) {
        final raw = existingSnap.value as Map<dynamic, dynamic>;
        existingKeys.addAll(raw.keys.map((k) => k.toString()));
      }

      // Create / update individual children
      for (final t in todos) {
        final childRef = ref.child(t.id);
        await childRef.set(t.toJson());
        existingKeys.remove(t.id);
      }

      // Remove any keys that existed remotely but are no longer present locally
      for (final stale in existingKeys) {
        await ref.child(stale).remove();
      }

      log('Saved ${todos.length} todos to Realtime DB (per-item)');
      return true;
    } catch (e, stack) {
      log('Failed to save todos to Realtime DB: $e');
      log('Stack: $stack');
      return false;
    }
  }

  @override
  Future<List<TodoItem>> loadTodos() async {
    try {
      final snapshot = await _db.ref(_todosPath).get();
      if (!snapshot.exists || snapshot.value == null) return [];
      final raw = snapshot.value as Map<dynamic, dynamic>;
      final todos = raw.values.map((v) => TodoItem.fromJson(Map<String, dynamic>.from(v))).toList();
      log('Loaded ${todos.length} todos from Realtime DB');
      return todos;
    } catch (e) {
      log('Failed to load todos from Realtime DB: $e');
      return [];
    }
  }

  @override
  Future<bool> clearTodos() async {
    try {
      await _db.ref(_todosPath).remove();
      log('Cleared todos in Realtime DB');
      return true;
    } catch (e) {
      log('Failed to clear todos in Realtime DB: $e');
      return false;
    }
  }

  @override
  Future<String?> exportTodos() async {
    try {
      final todos = await loadTodos();
      return jsonEncode(TodoItem.listToJson(todos));
    } catch (e) {
      log('Failed to export todos from Realtime DB: $e');
      return null;
    }
  }

  @override
  Future<bool> importTodos(String jsonString) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final todos = TodoItem.listFromJson(jsonList);
      return await saveTodos(todos);
    } catch (e) {
      log('Failed to import todos to Realtime DB: $e');
      return false;
    }
  }

  @override
  Future<bool> saveDensity(double density) async {
    try {
      await _db.ref(_settingsPath).update({'density': density});
      return true;
    } catch (e) {
      log('Failed to save density to Realtime DB: $e');
      return false;
    }
  }

  @override
  Future<double> loadDensity() async {
    try {
      final snapshot = await _db.ref(_settingsPath).child('density').get();
      if (!snapshot.exists || snapshot.value == null) return 1.0;
      final v = snapshot.value;
      if (v is num) return v.toDouble();
      return 1.0;
    } catch (e) {
      log('Failed to load density from Realtime DB: $e');
      return 1.0;
    }
  }

  @override
  Future<bool> saveCurrentUser(String userId) async {
    try {
      await _db.ref(_settingsPath).update({'currentUser': userId});
      return true;
    } catch (e) {
      log('Failed to save current user to Realtime DB: $e');
      return false;
    }
  }

  @override
  Future<String> loadCurrentUser() async {
    try {
      final snapshot = await _db.ref(_settingsPath).child('currentUser').get();
      if (!snapshot.exists || snapshot.value == null) return 'KH';
      final v = snapshot.value;
      if (v is String && v.isNotEmpty) return v;
      return 'KH';
    } catch (e) {
      log('Failed to load current user from Realtime DB: $e');
      return 'KH';
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final snapshot = await _db.ref(_todosPath).get();
      if (!snapshot.exists || snapshot.value == null) return {'todoCount': 0};
      final raw = snapshot.value as Map<dynamic, dynamic>;
      return {'todoCount': raw.length};
    } catch (e) {
      log('Failed to get storage info from Realtime DB: $e');
      return {};
    }
  }
}
