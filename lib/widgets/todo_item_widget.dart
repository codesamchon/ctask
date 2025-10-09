import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

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
  final density = Provider.of<TodoProvider>(context).density;
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  const double fsScale = 0.90; // slightly smaller fonts for grid items

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8 * density),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20 * density,
                  decoration: BoxDecoration(
                    color: stateColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 10 * density),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: (textTheme.titleSmall?.fontSize ?? 14) * fsScale,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (todo.description.isNotEmpty) ...[
                        SizedBox(height: 2 * density),
                        Text(
                          todo.description,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: (textTheme.bodySmall?.fontSize ?? 12) * fsScale,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Creator label
                      SizedBox(height: 4 * density),
                      Text(
                        'Created by ${todo.createdBy}',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: (textTheme.labelSmall?.fontSize ?? 11) * fsScale,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStateChip(context, stateColor),
                SizedBox(width: 6 * density),
                if (todo.assignedTo != null && (todo.assignedTo ?? '').trim().isNotEmpty) ...[
                  Tooltip(
                    message: 'Assigned to ${todo.assignedTo}',
                    child: Chip(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      label: Text(
                        todo.assignedTo ?? '?',
                        style: textTheme.bodySmall?.copyWith(fontSize: (textTheme.bodySmall?.fontSize ?? 12) * fsScale),
                      ),
                      avatar: CircleAvatar(
                        radius: 10 * density,
                        child: Text((todo.assignedTo != null && todo.assignedTo!.isNotEmpty) ? todo.assignedTo![0] : '?'),
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * density),
                ],
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
              SizedBox(height: 6 * density),
              Container(
                padding: EdgeInsets.all(6 * density),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: stateColor.withValues(alpha: 0.22),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14 * density,
                      color: stateColor,
                    ),
                    SizedBox(width: 6 * density),
                    Expanded(
                      child: Text(
                        'Reason: ${todo.pendingReason}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 8 * density),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStateChip(BuildContext context, Color stateColor) {
    final density = Provider.of<TodoProvider>(context).density;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * density, vertical: 2 * density),
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

    final density = Provider.of<TodoProvider>(context).density;
    return Wrap(
      spacing: 8 * density,
      children: availableStates.map((state) {
        return ElevatedButton.icon(
          onPressed: () => onStateChanged(todo, state),
          icon: Icon(_getStateIcon(state), size: 14 * density),
          label: Text(_getActionText(state)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 10 * density, vertical: 6 * density),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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