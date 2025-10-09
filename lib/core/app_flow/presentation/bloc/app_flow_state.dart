// Simplified States - Reduced from 8 to 5 states
abstract class AppFlowState {}

/// Loading state (combines initial, loading, syncing)
class AppFlowLoading extends AppFlowState {
  final double progress;
  
  AppFlowLoading({this.progress = 0.0});
  
  @override
  String toString() => 'AppFlowLoading(progress: $progress)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowLoading && other.progress == progress;
  }
  
  @override
  int get hashCode => progress.hashCode;
}

/// User not logged in
class AppFlowUnauthenticated extends AppFlowState {}

/// User logged in but may need onboarding/profile setup
class AppFlowAuthenticated extends AppFlowState {
  final bool needsOnboarding;
  final bool needsProfileSetup;
  
  AppFlowAuthenticated({
    this.needsOnboarding = false,
    this.needsProfileSetup = false,
  });
  
  @override
  String toString() => 'AppFlowAuthenticated(needsOnboarding: $needsOnboarding, needsProfileSetup: $needsProfileSetup)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowAuthenticated && 
           other.needsOnboarding == needsOnboarding &&
           other.needsProfileSetup == needsProfileSetup;
  }
  
  @override
  int get hashCode => Object.hash(needsOnboarding, needsProfileSetup);
}

/// Fully authenticated and ready
class AppFlowReady extends AppFlowState {
  final bool isSyncing;
  final bool syncCompleted;

  AppFlowReady({
    this.isSyncing = false,
    this.syncCompleted = false,
  });

  @override
  String toString() => 'AppFlowReady(isSyncing: $isSyncing, syncCompleted: $syncCompleted)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowReady &&
           other.isSyncing == isSyncing &&
           other.syncCompleted == syncCompleted;
  }

  @override
  int get hashCode => Object.hash(isSyncing, syncCompleted);
}

/// Error state
class AppFlowError extends AppFlowState {
  final String message;
  AppFlowError(this.message);
  
  @override
  String toString() => 'AppFlowError(message: $message)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowError && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
}