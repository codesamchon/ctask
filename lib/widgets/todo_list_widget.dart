import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
import '../theme/app_theme.dart';
import 'todo_item_widget.dart';

class TodoListWidget extends StatelessWidget {
  final TodoState state;
  final Function(TodoItem, TodoState) onStateChanged;

  const TodoListWidget({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.getTodosByState(state);
        
        if (todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStateIcon(state),
                  size: 64,
                  color: AppTheme.getTodoStateColor(
                    state, 
                    Theme.of(context).brightness == Brightness.dark,
                  ).withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${state.name} items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyMessage(state),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TodoItemWidget(
                todo: todo,
                onStateChanged: onStateChanged,
                onDelete: () => provider.deleteTodo(todo.id),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStateIcon(TodoState state) {
    switch (state) {
      case TodoState.todo:
        return Icons.list_alt;
      case TodoState.doing:
        return Icons.work_outline;
      case TodoState.pending:
        return Icons.pause_circle_outline;
      case TodoState.done:
        return Icons.check_circle_outline;
    }
  }

  String _getEmptyMessage(TodoState state) {
    switch (state) {
      case TodoState.todo:
        return 'Add new tasks to get started';
      case TodoState.doing:
        return 'Move tasks here when you start working on them';
      case TodoState.pending:
        return 'Tasks that are temporarily on hold will appear here';
      case TodoState.done:
        return 'Completed tasks will appear here';
    }
  }
}