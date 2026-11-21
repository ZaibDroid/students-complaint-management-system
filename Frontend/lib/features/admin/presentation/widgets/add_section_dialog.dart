import 'package:flutter/material.dart';

/// Modal dialog prompting for a new section letter for a batch.
class AddSectionDialog extends StatefulWidget {
  final String batchName;

  const AddSectionDialog({super.key, required this.batchName});

  static Future<String?> show(BuildContext context, String batchName) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AddSectionDialog(batchName: batchName),
    );
  }

  @override
  State<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<AddSectionDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Section to Batch ${widget.batchName}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          labelText: 'Section Letter',
          hintText: 'e.g. C',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim().toUpperCase()),
          child: const Text('Add Section'),
        ),
      ],
    );
  }
}

