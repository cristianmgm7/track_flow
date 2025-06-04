enum UserRoleType { owner, admin, member, viewer }

class UserRole {
  final UserRoleType value;

  const UserRole._(this.value);

  static const UserRole owner = UserRole._(UserRoleType.owner);
  static const UserRole admin = UserRole._(UserRoleType.admin);
  static const UserRole member = UserRole._(UserRoleType.member);
  static const UserRole viewer = UserRole._(UserRoleType.viewer);

  static UserRole fromString(String input) {
    switch (input) {
      case 'owner':
        return owner;
      case 'admin':
        return admin;
      case 'member':
        return member;
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
      other is UserRole &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
