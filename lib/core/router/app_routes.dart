class AppRoutes {
  // Base routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';

  static const String magicLink = '/magiclink';

  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String trackList = '/tracks';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static const String newProject = '/dashboard/projects/new';

  // Project routes
  static const String projectDetails = '/projects/:id';

  static const String manageCollaborators = '/managecollaborators';

  // User profile routes
  static const String userProfile = '/userprofile';
  static const String profileCreation = '/profile/create';

  // Audio comment routes
  static const String trackDetail = '/track-detail';

  // Profile routes
  static const String artistProfile = '/artistprofile/:id';

  static const String cacheManagement = '/settings/cache-management';

  // Voice memo routes
  static const String voiceMemos = '/voice-memos';
  static const String voiceMemoRecording = '/voice-memos/recording';
}
