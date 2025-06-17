import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_event.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _avatarUrl;
  CreativeRole? _creativeRole;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _name = widget.profile.name;
    _email = widget.profile.email;
    _avatarUrl = widget.profile.avatarUrl;
    _creativeRole = widget.profile.creativeRole;
    if (_avatarUrl.isNotEmpty && Uri.tryParse(_avatarUrl)?.isAbsolute == true) {
      // No cargar File si es URL remota
      _avatarFile = null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
        _avatarUrl = pickedFile.path;
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final updatedProfile = UserProfile(
        id: widget.profile.id,
        name: _name,
        email: _email,
        avatarUrl: _avatarUrl,
        creativeRole: _creativeRole,
        createdAt: DateTime.now(),
      );
      context.read<UserProfileBloc>().add(SaveUserProfile(updatedProfile));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : (_avatarUrl.isNotEmpty &&
                              Uri.tryParse(_avatarUrl)?.isAbsolute == true)
                          ? NetworkImage(_avatarUrl) as ImageProvider
                          : null,
                  child:
                      (_avatarFile == null &&
                              (_avatarUrl.isEmpty ||
                                  Uri.tryParse(_avatarUrl)?.isAbsolute != true))
                          ? Icon(Icons.person, size: 40)
                          : null,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value ?? '',
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              DropdownButtonFormField<CreativeRole>(
                value: _creativeRole,
                decoration: InputDecoration(labelText: 'Creative Role'),
                items:
                    CreativeRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.toString().split('.').last),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _creativeRole = value),
                onSaved: (value) => _creativeRole = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(onPressed: _updateProfile, child: Text('Save Changes')),
      ],
    );
  }
}
