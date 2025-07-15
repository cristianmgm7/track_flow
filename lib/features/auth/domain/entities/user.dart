import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class User extends Entity<UserId> {
  final String email;
  final String? displayName;

  User({required UserId id, required this.email, this.displayName}) : super(id);
}
