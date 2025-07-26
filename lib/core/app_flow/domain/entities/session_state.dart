/// Represents the possible states of a user session
enum SessionState {
  /// User is not authenticated
  unauthenticated,

  /// User is authenticated but may need setup completion
  authenticated,

  /// User is fully authenticated and ready to use the app
  ready,

  /// Session has encountered an error
  error,
}
