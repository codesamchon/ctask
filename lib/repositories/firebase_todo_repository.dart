import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/todo_item.dart';
import 'todo_repository_base.dart';

/// Firestore-backed implementation of the Todo repository.
/// Collections:
/// - todos (documents keyed by id)
/// - settings (single doc 'app' for density and currentUser)
class FirebaseTodoRepository implements TodoRepositoryBase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _todosCollection = 'todos';
  final String _settingsDocPath = 'settings/app';

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    // Ensure Firebase initialized by caller (in main)
    _initialized = true;
    log('FirebaseTodoRepository initialized');
  }

  @override
  Future<List<TodoItem>> loadTodos() async {
    try {
      final snapshot = await _db.collection(_todosCollection).get();
      final todos = snapshot.docs.map((d) => TodoItem.fromJson(d.data())).toList();
      log('Loaded ${todos.length} todos from Firestore');
      return todos;
    } catch (e) {
      log('Failed to load todos from Firestore: $e');
      return [];
    }
  }

  @override
  Future<bool> saveTodos(List<TodoItem> todos) async {
    try {
      final batch = _db.batch();
      final col = _db.collection(_todosCollection);
      for (final t in todos) {
        final docRef = col.doc(t.id);
        batch.set(docRef, t.toJson());
      }
      await batch.commit();
      log('Saved ${todos.length} todos to Firestore');
      return true;
    } catch (e, stack) {
      if (e is FirebaseException) {
        log('Failed to save todos to Firestore: code=${e.code}, message=${e.message}, plugin=${e.plugin}');
      } else {
        log('Failed to save todos to Firestore: $e');
      }
      // include stack trace for deeper debugging
      log('Stack: $stack');
      return false;
    }
  }

  @override
  Future<bool> clearTodos() async {
    try {
      final col = _db.collection(_todosCollection);
      final snapshot = await col.get();
      final batch = _db.batch();
      for (final d in snapshot.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      log('Cleared todos in Firestore');
      return true;
    } catch (e) {
      log('Failed to clear todos in Firestore: $e');
      return false;
    }
  }

  @override
  Future<String?> exportTodos() async {
    try {
      final todos = await loadTodos();
      final json = jsonEncode(TodoItem.listToJson(todos));
      return json;
    } catch (e) {
      log('Failed to export todos from Firestore: $e');
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
      log('Failed to import todos to Firestore: $e');
      return false;
    }
  }

  @override
  Future<bool> saveDensity(double density) async {
    try {
      final docRef = _db.doc(_settingsDocPath);
      await docRef.set({'density': density}, SetOptions(merge: true));
      return true;
    } catch (e) {
      log('Failed to save density to Firestore: $e');
      return false;
    }
  }

  @override
  Future<double> loadDensity() async {
    try {
      final doc = await _db.doc(_settingsDocPath).get();
      if (!doc.exists) return 1.0;
      final data = doc.data();
      if (data == null) return 1.0;
      final v = data['density'];
      if (v is num) return v.toDouble();
      return 1.0;
    } catch (e) {
      log('Failed to load density from Firestore: $e');
      return 1.0;
    }
  }

  @override
  Future<bool> saveCurrentUser(String userId) async {
    try {
      final docRef = _db.doc(_settingsDocPath);
      await docRef.set({'currentUser': userId}, SetOptions(merge: true));
      return true;
    } catch (e) {
      log('Failed to save current user to Firestore: $e');
      return false;
    }
  }

  @override
  Future<String> loadCurrentUser() async {
    try {
      final doc = await _db.doc(_settingsDocPath).get();
      if (!doc.exists) return 'KH';
      final data = doc.data();
      if (data == null) return 'KH';
      final v = data['currentUser'];
      if (v is String && v.isNotEmpty) return v;
      return 'KH';
    } catch (e) {
      log('Failed to load current user from Firestore: $e');
      return 'KH';
    }
  }

  @override
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final snapshot = await _db.collection(_todosCollection).get();
      return {
        'todoCount': snapshot.docs.length,
      };
    } catch (e) {
      log('Failed to get storage info from Firestore: $e');
      return {};
    }
  }
}
