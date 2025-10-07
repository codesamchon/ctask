import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
import '../theme/app_theme.dart';

class StateGridWidget extends StatelessWidget {
  final TodoState state;
  final Function(TodoItem, TodoState) onStateChanged;

  const StateGridWidget({
    super.key,
    required this.state,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = AppTheme.getTodoStateColor(state, isDark);
    
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.getTodosByState(state);
        final count = todos.length;
        
        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStateIcon(state),
                      color: stateColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getStateTitle(state),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: stateColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: stateColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: todos.isEmpty
                    ? _buildEmptyState(context, stateColor)
                    : _buildTodoList(context, todos, provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, Color stateColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStateIcon(state),
            size: 32,
            color: stateColor.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No ${state.name} items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, List<TodoItem> todos, TodoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildCompactTodoItem(context, todo, provider),
        );
      },
    );
  }

  Widget _buildCompactTodoItem(BuildContext context, TodoItem todo, TodoProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stateColor = AppTheme.getTodoStateColor(todo.state, isDark);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: stateColor,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, todo, provider);
                  } else if (value.startsWith('move_')) {
                    final newState = _parseStateFromValue(value);
                    if (newState != null) {
                      _handleStateChange(context, todo, newState);
                    }
                  }
                },
                itemBuilder: (context) => [
                  ..._buildMoveMenuItems(todo),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (todo.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              todo.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (todo.state == TodoState.pending && todo.pendingReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: stateColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: stateColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      todo.pendingReason!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stateColor,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMoveMenuItems(TodoItem todo) {
    final availableStates = _getAvailableStates(todo.state);
    return availableStates.map((state) {
      return PopupMenuItem(
        value: 'move_${state.name}',
        child: Row(
          children: [
            Icon(_getStateIcon(state), size: 16),
            const SizedBox(width: 8),
            Text(_getActionText(state)),
          ],
        ),
      );
    }).toList();
  }

  List<TodoState> _getAvailableStates(TodoState currentState) {
    switch (currentState) {
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

  TodoState? _parseStateFromValue(String value) {
    final stateName = value.replaceFirst('move_', '');
    switch (stateName) {
      case 'todo':
        return TodoState.todo;
      case 'doing':
        return TodoState.doing;
      case 'pending':
        return TodoState.pending;
      case 'done':
        return TodoState.done;
      default:
        return null;
    }
  }

  void _handleStateChange(BuildContext context, TodoItem todo, TodoState newState) {
    onStateChanged(todo, newState);
  }

  void _showDeleteConfirmation(BuildContext context, TodoItem todo, TodoProvider provider) {
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
              provider.deleteTodo(todo.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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

  String _getStateTitle(TodoState state) {
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

  String _getActionText(TodoState state) {
    switch (state) {
      case TodoState.todo:
        return 'Move to Todo';
      case TodoState.doing:
        return 'Start Working';
      case TodoState.pending:
        return 'Pause';
      case TodoState.done:
        return 'Complete';
    }
  }
}