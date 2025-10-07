enum TodoState {
  todo,
  doing,
  pending,
  done,
}

class TodoItem {
  final String id;
  String title;
  String description;
  TodoState state;
  String? pendingReason; // Only used when state is pending
  DateTime createdAt;
  DateTime updatedAt;

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.state = TodoState.todo,
    this.pendingReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    TodoState? state,
    String? pendingReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      state: state ?? this.state,
      pendingReason: pendingReason ?? this.pendingReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get stateDisplayName {
    switch (state) {
      case TodoState.todo:
        return 'To Do';
      case TodoState.doing:
        return 'Doing';
      case TodoState.pending:
        return 'Pending';
      case TodoState.done:
        return 'Done';
    }
  }

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, state: $state, pendingReason: $pendingReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'state': state.name,
      'pendingReason': pendingReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      state: TodoState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => TodoState.todo,
      ),
      pendingReason: json['pendingReason'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper method to convert list to JSON
  static List<Map<String, dynamic>> listToJson(List<TodoItem> todos) {
    return todos.map((todo) => todo.toJson()).toList();
  }

  // Helper method to convert JSON to list
  static List<TodoItem> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TodoItem.fromJson(json)).toList();
  }
}