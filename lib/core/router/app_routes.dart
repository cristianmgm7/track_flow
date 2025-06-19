class AppRoutes {
  // Base routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  static const String magicLink = '/magiclink';

  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static const String newProject = '/dashboard/projects/new';

  // Project routes
  static const String projectDetails = '/projectdetails';

  static const String manageCollaborators = '/managecollaborators';

  // Helper method to generate project details route with ID
  static String projectDetailsWithId(String id) => '/projectdetails/$id';

  // User profile routes
  static const String userProfile = '/userprofile';

  // Audio comment routes
  static const String audioComments = '/audio-comments';
}
