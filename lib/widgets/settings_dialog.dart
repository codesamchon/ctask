import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _density = 1.0;

  @override
  void initState() {
    super.initState();
    // Defer provider read to after first frame to avoid using BuildContext across sync gaps during init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      setState(() {
        _density = provider.density;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);

    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Density'),
              Text(_density.toStringAsFixed(2)),
            ],
          ),
          Slider(
            min: 0.6,
            max: 1.4,
            divisions: 16,
            value: _density,
            onChanged: (v) => setState(() { _density = v; }),
          ),
          const SizedBox(height: 8),
          const Text('Lower values make items more compact.'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          final nav = Navigator.of(context);
          final value = _density;
          await provider.setDensity(value);
          if (mounted) nav.pop();
        }, child: const Text('Save')),
      ],
    );
  }
}
