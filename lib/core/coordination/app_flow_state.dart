// States
abstract class AppFlowState {}

class AppFlowInitial extends AppFlowState {}

class AppFlowLoading extends AppFlowState {}

class AppFlowUnauthenticated extends AppFlowState {}

class AppFlowNeedsOnboarding extends AppFlowState {}

class AppFlowNeedsProfileSetup extends AppFlowState {}

class AppFlowReady extends AppFlowState {}

class AppFlowError extends AppFlowState {
  final String message;
  AppFlowError(this.message);
}
