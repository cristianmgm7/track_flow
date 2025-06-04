import 'package:trackflow/core/entities/project_actions.dart';

import '../value_objects/user_role.dart';
import '../value_objects/project_action.dart';

class PermissionPolicy {
  static bool can(UserRole role, ProjectAction action) {
    switch (role) {
      case UserRole.owner:
        return true;

      case UserRole.admin:
        return switch (action) {
          ProjectAction.viewProject => true,
          ProjectAction.editDetails => true,
          ProjectAction.manageParticipants => true,
          ProjectAction.changeRoles => true,
          ProjectAction.deleteProject => false,
          ProjectAction.viewChat => true,
          ProjectAction.comment => true,
          ProjectAction.viewFiles => true,
          ProjectAction.uploadFiles => true,
        };

      case UserRole.member:
        return switch (action) {
          ProjectAction.viewProject => true,
          ProjectAction.editDetails => false,
          ProjectAction.manageParticipants => false,
          ProjectAction.changeRoles => false,
          ProjectAction.deleteProject => false,
          ProjectAction.viewChat => true,
          ProjectAction.comment => true,
          ProjectAction.viewFiles => true,
          ProjectAction.uploadFiles => true,
        };

      case UserRole.viewer:
        return switch (action) {
          ProjectAction.viewProject => true,
          ProjectAction.editDetails => false,
          ProjectAction.manageParticipants => false,
          ProjectAction.changeRoles => false,
          ProjectAction.deleteProject => false,
          ProjectAction.viewChat => true,
          ProjectAction.comment => false,
          ProjectAction.viewFiles => true,
          ProjectAction.uploadFiles => false,
        };
    }
  }
}
