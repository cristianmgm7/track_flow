import 'package:flutter/material.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ChangeRoleDialog extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onRoleChanged;

  const ChangeRoleDialog({
    super.key,
    required this.userProfile,
    required this.onRoleChanged,
  });

  @override
  _ChangeRoleDialogState createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  CreativeRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.userProfile.creativeRole;
  }

  void _changeRole() {
    if (_selectedRole != null) {
      final updatedProfile = widget.userProfile.copyWith(
        creativeRole: _selectedRole,
      );
      widget.onRoleChanged(updatedProfile);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Role'),
      content: DropdownButtonFormField<CreativeRole>(
        value: _selectedRole,
        items:
            CreativeRole.values.map((role) {
              return DropdownMenuItem(value: role, child: Text(role.name));
            }).toList(),
        onChanged: (role) {
          setState(() {
            _selectedRole = role;
          });
        },
        decoration: const InputDecoration(labelText: 'Select a new role'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _changeRole, child: const Text('Change')),
      ],
    );
  }
}
