import 'package:flutter/material.dart';

class RemoveParticipantDialog extends StatefulWidget {
  final Function(String) onRemoveParticipant;

  const RemoveParticipantDialog({super.key, required this.onRemoveParticipant});

  @override
  _RemoveParticipantDialogState createState() =>
      _RemoveParticipantDialogState();
}

class _RemoveParticipantDialogState extends State<RemoveParticipantDialog> {
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

  void _removeParticipant() {
    if (!_formKey.currentState!.validate()) return;
    final participantId = _participantIdController.text;
    widget.onRemoveParticipant(participantId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove Participant'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _participantIdController,
          decoration: const InputDecoration(
            labelText: 'Participant ID',
            hintText: 'Enter the ID of the participant to remove',
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
        ElevatedButton(
          onPressed: _removeParticipant,
          child: const Text('Remove'),
        ),
      ],
    );
  }
}
