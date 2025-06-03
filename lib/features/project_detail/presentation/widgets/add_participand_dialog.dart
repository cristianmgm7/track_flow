import 'package:flutter/material.dart';

class AddParticipantDialog extends StatefulWidget {
  final Function(String) onAddParticipant;

  const AddParticipantDialog({super.key, required this.onAddParticipant});

  @override
  _AddParticipantDialogState createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<AddParticipantDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _participantIdController;

  @override
  void initState() {
    super.initState();
    _participantIdController = TextEditingController();
  }

  @override
  void dispose() {
    _participantIdController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    if (!_formKey.currentState!.validate()) return;
    final participantId = _participantIdController.text;
    widget.onAddParticipant(participantId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Participant'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _participantIdController,
          decoration: const InputDecoration(
            labelText: 'Participant ID',
            hintText: 'Paste the ID of your collaborator',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a participant ID';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _addParticipant, child: const Text('Add')),
      ],
    );
  }
}
