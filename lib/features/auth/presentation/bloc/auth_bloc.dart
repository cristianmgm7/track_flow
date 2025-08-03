import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final GoogleSignInUseCase googleSignIn;
  final SignOutUseCase signOut;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.googleSignIn,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info(
      'Starting sign in process for email: ${event.email}',
      tag: 'AUTH_BLOC',
    );

    emit(AuthLoading());

    final result = await signIn(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Sign in failed: ${failure.message}',
          tag: 'AUTH_BLOC',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info(
          'Sign in successful for user: ${user.email} (ID: ${user.id})',
          tag: 'AUTH_BLOC',
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info(
      'Starting sign up process for email: ${event.email}',
      tag: 'AUTH_BLOC',
    );

    emit(AuthLoading());

    final result = await signUp(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          'Sign up failed: ${failure.message}',
          tag: 'AUTH_BLOC',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info(
          'Sign up successful for new user: ${user.email} (ID: ${user.id})',
          tag: 'AUTH_BLOC',
        );
        emit(AuthAuthenticated(user));
        // For new users, ensure onboarding is marked as incomplete
        // This will be handled by the router logic
      },
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Starting Google sign in process', tag: 'AUTH_BLOC');

    emit(AuthLoading());

    final result = await googleSignIn();

    result.fold(
      (failure) {
        AppLogger.error(
          'Google sign in failed: ${failure.message}',
          tag: 'AUTH_BLOC',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (user) {
        AppLogger.info(
          'Google sign in successful for user: ${user.email} (ID: ${user.id})',
          tag: 'AUTH_BLOC',
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('Starting sign out process', tag: 'AUTH_BLOC');

    emit(AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) {
        AppLogger.error(
          'Sign out failed: ${failure.message}',
          tag: 'AUTH_BLOC',
          error: failure,
        );
        emit(AuthError(failure.message));
      },
      (_) {
        AppLogger.info('Sign out completed successfully', tag: 'AUTH_BLOC');

        // ✅ CRÍTICO: Limpiar estado completo antes de emitir AuthInitial
        _clearAllUserData();

        emit(AuthInitial());
      },
    );
  }

  /// Clear all user-related data when signing out
  void _clearAllUserData() {
    AppLogger.info(
      'AuthBloc: Clearing all user data during sign out',
      tag: 'AUTH_BLOC',
    );

    // This will be handled by the AppFlowBloc listener
    // The AppFlowBloc will detect the auth state change and trigger a complete reset
  }
}
