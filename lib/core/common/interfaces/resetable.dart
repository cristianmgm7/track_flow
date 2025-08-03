/// Interface for components that can be reset to their initial state
/// 
/// This interface provides a common contract for BLoCs and other stateful
/// components that need to be reset during session cleanup to prevent
/// data persistence between different user sessions.
/// 
/// Example usage:
/// ```dart
/// class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> 
///     implements Resetable {
///   @override
///   void reset() {
///     emit(UserProfileInitial());
///   }
/// }
/// ```
abstract class Resetable {
  /// Reset the component to its initial state
  /// 
  /// This method should clear any cached data, reset internal state,
  /// and emit the initial state if applicable.
  void reset();
}