import 'sign_in_usecase.dart';
import 'sign_up_usecase.dart';
import 'sign_out_usecase.dart';
import 'google_sign_in_usecase.dart';
import 'get_auth_state_usecase.dart';

class AuthUseCases {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GoogleSignInUseCase googleSignIn;
  final GetAuthStateUseCase getAuthState;

  AuthUseCases({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.googleSignIn,
    required this.getAuthState,
  });
}
