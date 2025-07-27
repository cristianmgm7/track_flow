import 'package:trackflow/core/app_flow/domain/entities/user_session.dart';
import 'package:trackflow/core/app_flow/domain/value_objects/app_initial_state.dart';

/// Result of app bootstrap containing both state and session info
class AppBootstrapResult {
  final AppInitialState state;
  final UserSession? userSession;

  const AppBootstrapResult({required this.state, this.userSession});
}
