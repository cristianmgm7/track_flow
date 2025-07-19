// Events
abstract class AppFlowEvent {}

class CheckAppFlow extends AppFlowEvent {}

class UserAuthenticated extends AppFlowEvent {}

class UserSignedOut extends AppFlowEvent {}
