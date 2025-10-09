import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/open_link.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';
import '../widgets/state_grid_widget.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/pending_reason_dialog.dart';
import '../widgets/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }

  void _onTodoStateChanged(TodoItem todo, TodoState newState) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    if (newState == TodoState.pending) {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => PendingReasonDialog(todoTitle: todo.title),
      );
      
      if (reason != null && reason.isNotEmpty) {
        provider.changeState(todo.id, newState, pendingReason: reason);
      }
    } else {
      provider.changeState(todo.id, newState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Co-op Task'),
        actions: [
          // Error indicator
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return IconButton(
                  icon: const Icon(Icons.error_outline, color: Colors.red),
                  onPressed: () => _showErrorDialog(context, provider.error!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Loading indicator
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
          // Current user selector
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 72,
                  child: DropdownButton<String>(
                    value: provider.currentUser,
                    isDense: true,
                    isExpanded: false,
                    underline: const SizedBox.shrink(),
                    items: provider.users.map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u, textAlign: TextAlign.center),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.setCurrentUser(value);
                      }
                    },
                  ),
                ),
              );
            },
          ),
          // Menu with data management options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 8),
                    Text('Import Data'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              // Hidden debug menu items removed
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Left-aligned external links below the AppBar — responsive
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Tooltip(
                    message: 'Open check lists in a new tab',
                    child: TextButton.icon(
                      onPressed: () async {
                        const url = 'https://checklists-dcbee.web.app/';
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await openLink(url);
                        if (!ok && mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Could not open link')),
                          );
                        }
                      },
                      icon: const Icon(Icons.list_alt_outlined, size: 18),
                      label: const Text('Move to check lists'),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
                    ),
                  ),
                  Tooltip(
                    message: 'Open shared storage (SharePoint)',
                    child: TextButton.icon(
                      onPressed: () async {
                        const url = 'https://103z26-my.sharepoint.com/:f:/g/personal/asyourwish_103z26_onmicrosoft_com/Ej12V2oYVVZMpNNYwEYRpO8BQZzmCfCopnJpzkbKWYqPCQ?e=QCs1gj';
                        final messenger = ScaffoldMessenger.of(context);
                        final ok = await openLink(url);
                        if (!ok && mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Could not open link')),
                          );
                        }
                      },
                      icon: const Icon(Icons.folder_shared_outlined, size: 18),
                      label: const Text('Move to Shared Storage'),
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8.0)),
                    ),
                  ),
                ],
              ),
            ),
            // Summary Row
            Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final totalTasks = provider.getTodoCount();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        'Total Tasks',
                        totalTasks.toString(),
                        Icons.task_alt,
                        Theme.of(context).colorScheme.primary,
                      ),
                      _buildSummaryItem(
                        context,
                        'In Progress',
                        provider.doingCount.toString(),
                        Icons.work_outline,
                        Colors.blue,
                      ),
                      _buildSummaryItem(
                        context,
                        'Completed',
                        provider.doneCount.toString(),
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Grid Layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive grid based on screen width
                  final provider = Provider.of<TodoProvider>(context);
                  final density = provider.density;
                  int crossAxisCount = 1;
                  double baseAspect = 1.1;

                  // Use single-column layout for narrow/mobile screens
                  if (constraints.maxWidth > 800) {
                    crossAxisCount = 4; // 4 columns on wide screens
                    baseAspect = 0.7;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2; // 2 columns on medium screens
                    baseAspect = 0.9;
                  }

                  // Adjust tile height by density: lower density -> more compact -> increase aspect ratio
                  var childAspectRatio = baseAspect / density;
                  // clamp aspect ratio to avoid extreme values which can cause RenderFlex overflow
                  childAspectRatio = (childAspectRatio.clamp(0.4, 2.0)).toDouble();
                  
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      StateGridWidget(
                        state: TodoState.todo,
                        onStateChanged: _onTodoStateChanged,
                      ),
                      StateGridWidget(
                        state: TodoState.doing,
                        onStateChanged: _onTodoStateChanged,
                      ),
                      StateGridWidget(
                        state: TodoState.pending,
                        onStateChanged: _onTodoStateChanged,
                      ),
                      StateGridWidget(
                        state: TodoState.done,
                        onStateChanged: _onTodoStateChanged,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final provider = Provider.of<TodoProvider>(context, listen: false);
              provider.refreshTodos();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuSelection(String value) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    
    switch (value) {
      case 'refresh':
        await provider.refreshTodos();
        break;
      case 'export':
        await _exportData();
        break;
      case 'settings':
        showDialog(context: context, builder: (_) => const SettingsDialog());
        break;
      case 'import':
        await _importData();
        break;
      case 'clear':
        await _clearAllData();
        break;
      case 'debug':
        // Dump provider state to the console
        try {
          // Using print/log for quick debugging
          final stateInfo = {
            'currentUser': provider.currentUser,
            'users': provider.users,
            'density': provider.density,
            'totalTodos': provider.getTodoCount(),
            'todoByState': {
              'todo': provider.getTodoCountByState(TodoState.todo),
              'doing': provider.getTodoCountByState(TodoState.doing),
              'pending': provider.getTodoCountByState(TodoState.pending),
              'done': provider.getTodoCountByState(TodoState.done),
            }
          };
          // ignore: avoid_print
          print('CTask Debug Info: $stateInfo');
        } catch (e) {
          // ignore: avoid_print
          print('Failed to dump debug info: $e');
        }
        break;
      case 'check_db':
        {
          final result = await provider.checkBackend();
          if (!mounted) return;
          // Ensure dialog is shown synchronously on the next frame to avoid using context across async gaps
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Backend Info'),
                content: SingleChildScrollView(
                  child: Text(result.toString()),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                ],
              ),
            );
          });
        }
        break;
      case 'seed_db':
        {
          final success = await provider.seedSampleTodos();
          if (!mounted) return;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Seeded sample todos' : 'Failed to seed todos'),
              ),
            );
          });
        }
        break;
    }
  }

  Future<void> _exportData() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final exportData = await provider.exportTodos();
    
    if (exportData != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your todo data has been exported. Copy the JSON below:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    exportData,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importData() async {
    final controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste your exported JSON data below:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste JSON data here...',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && mounted) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      final success = await provider.importTodos(result);

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Data imported successfully!' : 'Failed to import data'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        });
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all todos? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      await provider.clearAllTodos();

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared'),
              backgroundColor: Colors.orange,
            ),
          );
        });
      }
    }
  }
}