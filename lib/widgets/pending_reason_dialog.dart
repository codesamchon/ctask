import 'package:flutter/material.dart';

class PendingReasonDialog extends StatefulWidget {
  final String todoTitle;

  const PendingReasonDialog({
    super.key,
    required this.todoTitle,
  });

  @override
  State<PendingReasonDialog> createState() => _PendingReasonDialogState();
}

class _PendingReasonDialogState extends State<PendingReasonDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitReason() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pause Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to pause:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '"${widget.todoTitle}"',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please provide a reason for pausing this task:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for pausing',
                hintText: 'e.g., Waiting for approval, blocked by dependency...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a reason';
                }
                return null;
              },
              autofocus: true,
              maxLines: 2,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitReason,
          child: const Text('Pause Task'),
        ),
      ],
    );
  }
}