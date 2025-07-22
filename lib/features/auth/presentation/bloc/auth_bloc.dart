import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GoogleSignInUseCase googleSignIn;
  final GetAuthStateUseCase getAuthState;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.googleSignIn,
    required this.getAuthState,
  }) : super(AuthInitial()) {
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
  }


  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] _onAuthSignInRequested() started');
    emit(AuthLoading());
    final result = await signIn(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );
    result.fold(
      (failure) {
        print('❌ [AuthBloc] Sign in failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        print('🔄 [AuthBloc] Sign in successful: ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] _onAuthSignUpRequested() started');
    emit(AuthLoading());
    final result = await signUp(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );
    result.fold(
      (failure) {
        print('❌ [AuthBloc] Sign up failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        print('🔄 [AuthBloc] Sign up successful: ${user.email}');
        emit(AuthAuthenticated(user));
        // For new users, ensure onboarding is marked as incomplete
        // This will be handled by the router logic
      },
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] _onAuthSignOutRequested() started');
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) {
        print('❌ [AuthBloc] Sign out failed: ${failure.message}');
        emit(AuthError('Failed to sign out: ${failure.message}'));
      },
      (_) {
        print('🔄 [AuthBloc] Sign out successful');
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 [AuthBloc] _onAuthGoogleSignInRequested() started');
    emit(AuthLoading());
    final result = await googleSignIn();
    result.fold(
      (failure) {
        print('❌ [AuthBloc] Google sign in failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        print('🔄 [AuthBloc] Google sign in successful: ${user.email}');
        emit(AuthAuthenticated(user));
      },
    );
  }

}
