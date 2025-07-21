/// Centralized UI Component Registry
///
/// This registry provides a single source of truth for all UI components
/// and eliminates redundancies across the application.
class UIComponentRegistry {
  // Singleton pattern
  static final UIComponentRegistry _instance = UIComponentRegistry._internal();
  factory UIComponentRegistry() => _instance;
  UIComponentRegistry._internal();

  // Component categories
  static const Map<String, List<String>> componentCategories = {
    'buttons': [
      'PrimaryButton',
      'SecondaryButton',
      'AppLoadingButton',
      'IconButton',
      'FloatingActionButton',
    ],
    'cards': ['BaseCard', 'ProjectCard', 'TrackCard', 'GlassmorphismCard'],
    'inputs': [
      'AppTextField',
      'AppFormField',
      'AppPasswordField',
      'AppSearchField',
    ],
    'navigation': [
      'AppBar',
      'BottomNavigation',
      'AppScaffold',
      'SideNavigation',
    ],
    'modals': [
      'AppDialog',
      'AppBottomSheet',
      'TrackFlowActionSheet',
      'TrackFlowFormSheet',
    ],
    'loading': [
      'AppLoading',
      'AppSplashScreen',
      'AppShimmer',
      'AppLoadingOverlay',
    ],
    'feedback': ['AppToast', 'AppSnackBar', 'AppTooltip', 'AppBanner'],
    'audio': [
      'AudioPlayPauseButton',
      'SoundbarAnimation',
      'AudioControls',
      'MiniPlayer',
    ],
  };

  // Usage guidelines
  static const Map<String, String> usageGuidelines = {
    'buttons':
        'Use PrimaryButton for main actions, SecondaryButton for secondary actions',
    'cards':
        'Use BaseCard as foundation, specialized cards for specific content types',
    'inputs':
        'Use AppTextField for basic input, AppFormField for forms with validation',
    'navigation': 'Use AppScaffold as main container, AppBar for headers',
    'modals':
        'Use TrackFlowActionSheet for action lists, TrackFlowFormSheet for forms',
    'loading':
        'Use AppLoading for full-screen, AppShimmer for content placeholders',
    'feedback':
        'Use AppToast for success/error messages, AppSnackBar for actions',
    'audio':
        'Use AudioPlayPauseButton for play controls, SoundbarAnimation for visual feedback',
  };

  // Migration status
  static const Map<String, bool> migrationStatus = {
    'buttons': true,
    'cards': true,
    'inputs': true,
    'navigation': true,
    'modals': true,
    'loading': true,
    'feedback': false, // TODO: Implement
    'audio': true,
  };

  // Get components by category
  static List<String> getComponentsByCategory(String category) {
    return componentCategories[category] ?? [];
  }

  // Check if component is migrated
  static bool isComponentMigrated(String componentName) {
    for (final category in componentCategories.keys) {
      if (componentCategories[category]!.contains(componentName)) {
        return migrationStatus[category] ?? false;
      }
    }
    return false;
  }

  // Get usage guideline
  static String getUsageGuideline(String category) {
    return usageGuidelines[category] ?? 'No guideline available';
  }
}

/// Component Usage Tracker
class ComponentUsageTracker {
  static final Map<String, int> _usageCount = {};

  static void trackUsage(String componentName) {
    _usageCount[componentName] = (_usageCount[componentName] ?? 0) + 1;
  }

  static int getUsageCount(String componentName) {
    return _usageCount[componentName] ?? 0;
  }

  static Map<String, int> getMostUsedComponents() {
    final sorted =
        _usageCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}
