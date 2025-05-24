class AppRoutes {
  // Base routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String notifications = '/notifications';
  static const String settingsAccount = '/settings';

  static const String newProject = '/dashboard/projects/new';

  // Project routes
  static const String projectDetails = '/projectdetails';

  // Helper method to generate project details route with ID
  static String projectDetailsWithId(String id) => '/projectdetails/$id';
}
