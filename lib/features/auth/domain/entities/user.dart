import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class User extends Entity<UserId> {
  final String email;
  final String? displayName;
  final String? photoUrl;

  User({
    required UserId id,
    required this.email,
    this.displayName,
    this.photoUrl,
  }) : super(id);

  @override
  String toString() {
    return 'User(id: ${id.value}, email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }
}
