enum ProjectRoleType { owner, admin, editor, viewer }

class ProjectRole {
  final ProjectRoleType value;

  const ProjectRole._(this.value);

  static const ProjectRole owner = ProjectRole._(ProjectRoleType.owner);
  static const ProjectRole admin = ProjectRole._(ProjectRoleType.admin);
  static const ProjectRole editor = ProjectRole._(ProjectRoleType.editor);
  static const ProjectRole viewer = ProjectRole._(ProjectRoleType.viewer);

  static ProjectRole fromString(String input) {
    switch (input) {
      case 'owner':
        return owner;
      case 'admin':
        return admin;
      case 'editor':
        return editor;
      case 'viewer':
        return viewer;
      default:
        throw ArgumentError('Invalid role: $input');
    }
  }

  String toShortString() {
    return value.name;
  }

  @override
  String toString() => toShortString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectRole &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
