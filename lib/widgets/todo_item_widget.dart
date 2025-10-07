import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../theme/app_theme.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final Function(TodoItem, TodoState) onStateChanged;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onStateChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = AppTheme.getTodoStateColor(todo.state, isDark);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: stateColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (todo.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStateChip(context, stateColor),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (todo.state == TodoState.pending && todo.pendingReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: stateColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Reason: ${todo.pendingReason}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(BuildContext context, Color stateColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        todo.stateDisplayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: stateColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final availableStates = _getAvailableStates();
    
    if (availableStates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      children: availableStates.map((state) {
        return ElevatedButton.icon(
          onPressed: () => onStateChanged(todo, state),
          icon: Icon(_getStateIcon(state), size: 16),
          label: Text(_getActionText(state)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            textStyle: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }

  List<TodoState> _getAvailableStates() {
    switch (todo.state) {
      case TodoState.todo:
        return [TodoState.doing, TodoState.pending];
      case TodoState.doing:
        return [TodoState.todo, TodoState.pending, TodoState.done];
      case TodoState.pending:
        return [TodoState.todo, TodoState.doing, TodoState.done];
      case TodoState.done:
        return [TodoState.todo];
    }
  }

  IconData _getStateIcon(TodoState state) {
    switch (state) {
      case TodoState.todo:
        return Icons.list_alt;
      case TodoState.doing:
        return Icons.play_arrow;
      case TodoState.pending:
        return Icons.pause;
      case TodoState.done:
        return Icons.check;
    }
  }

  String _getActionText(TodoState state) {
    switch (state) {
      case TodoState.todo:
        return 'To Do';
      case TodoState.doing:
        return 'Start';
      case TodoState.pending:
        return 'Pause';
      case TodoState.done:
        return 'Complete';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}