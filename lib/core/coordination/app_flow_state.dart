// States
abstract class AppFlowState {}

class AppFlowInitial extends AppFlowState {}

class AppFlowLoading extends AppFlowState {}

class AppFlowSyncing extends AppFlowState {
  final double progress;
  
  AppFlowSyncing(this.progress);
  
  @override
  String toString() => 'AppFlowSyncing(progress: $progress)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFlowSyncing && other.progress == progress;
  }
  
  @override
  int get hashCode => progress.hashCode;
}

class AppFlowUnauthenticated extends AppFlowState {}

class AppFlowNeedsOnboarding extends AppFlowState {}

class AppFlowNeedsProfileSetup extends AppFlowState {}

class AppFlowReady extends AppFlowState {}

class AppFlowError extends AppFlowState {
  final String message;
  AppFlowError(this.message);
}
