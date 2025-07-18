import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/auth/domain/usecases/onboarding_usacase.dart';
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
  final OnboardingUseCase onboarding;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.googleSignIn,
    required this.getAuthState,
    required this.onboarding,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);

    // Onboarding
    on<OnboardingMarkCompleted>(_onboardingMarkCompleted);
    on<WelcomeScreenMarkCompleted>(_welcomeScreenMarkCompleted);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await emit.forEach(
      getAuthState(),
      onData:
          (user) =>
              user != null ? AuthAuthenticated(user) : AuthUnauthenticated(),
      onError: (_, __) => AuthError('Failed to check auth state'),
    );
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signIn(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUp(
      EmailAddress(event.email),
      PasswordValue(event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError('Failed to sign out: ${failure.message}')),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await googleSignIn();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Onboarding
  Future<void> _onboardingMarkCompleted(
    OnboardingMarkCompleted event,
    Emitter<AuthState> emit,
  ) async {
    final result = await onboarding.onboardingCompleted();
    result.fold(
      (failure) => emit(AuthError('Failed to complete onboarding: ${failure.message}')),
      (_) {}, // Success - no state change needed
    );
  }

  Future<void> _welcomeScreenMarkCompleted(
    WelcomeScreenMarkCompleted event,
    Emitter<AuthState> emit,
  ) async {
    final result = await onboarding.welcomeScreenSeenCompleted();
    result.fold(
      (failure) => emit(AuthError('Failed to mark welcome screen as seen: ${failure.message}')),
      (_) {}, // Success - no state change needed
    );
  }
}
