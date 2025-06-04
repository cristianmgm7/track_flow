enum UserCreativeRoleType {
  producer,
  songwriter,
  mixingEngineer,
  masteringEngineer,
  musician,
  other,
}

class UserCreativeRole {
  final UserCreativeRoleType value;

  const UserCreativeRole._(this.value);

  static const UserCreativeRole producer = UserCreativeRole._(
    UserCreativeRoleType.producer,
  );
  static const UserCreativeRole songwriter = UserCreativeRole._(
    UserCreativeRoleType.songwriter,
  );
  static const UserCreativeRole mixingEngineer = UserCreativeRole._(
    UserCreativeRoleType.mixingEngineer,
  );
  static const UserCreativeRole masteringEngineer = UserCreativeRole._(
    UserCreativeRoleType.masteringEngineer,
  );
  static const UserCreativeRole musician = UserCreativeRole._(
    UserCreativeRoleType.musician,
  );
  static const UserCreativeRole other = UserCreativeRole._(
    UserCreativeRoleType.other,
  );

  static UserCreativeRole fromString(String input) {
    switch (input) {
      case 'producer':
        return producer;
      case 'songwriter':
        return songwriter;
      case 'mixingEngineer':
        return mixingEngineer;
      case 'masteringEngineer':
        return masteringEngineer;
      case 'musician':
        return musician;
      case 'other':
        return other;
      default:
        throw ArgumentError('Invalid creative role: $input');
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
      other is UserCreativeRole &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
