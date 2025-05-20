class AppRoutes {
  // Base routes
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  // Dashboard routes
  static const String dashboard = '/dashboard';
  static const String newProject = '/dashboard/projects/new';

  // Project routes
  static const String projectDetails = '/projectdetails/:id';

  // Helper method to generate project details route with ID
  static String projectDetailsWithId(String id) => '/projectdetails/$id';
}
