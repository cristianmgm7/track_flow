import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Service to get current user information
@injectable
class CurrentUserService {
  final SessionStorage _sessionStorage;

  CurrentUserService(this._sessionStorage);

  /// Get current user ID from session storage
  Future<UserId?> getCurrentUserId() async {
    final userIdString = await _sessionStorage.getUserId();
    if (userIdString == null || userIdString.isEmpty) {
      return null;
    }
    return UserId.fromUniqueString(userIdString);
  }

  /// Get current user ID or throw if not authenticated
  Future<UserId> getCurrentUserIdOrThrow() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final userId = await getCurrentUserId();
    return userId != null;
  }
}
