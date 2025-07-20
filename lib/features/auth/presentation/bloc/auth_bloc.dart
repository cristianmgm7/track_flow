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
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 AuthBloc - AuthCheckRequested started');
    emit(AuthLoading());

    try {
      // Add timeout to prevent infinite waiting
      await emit.forEach(
        getAuthState().timeout(
          const Duration(seconds: 15),
          onTimeout: (sink) {
            print('⏰ AuthBloc - Auth state check timed out');
            sink.add(null);
            sink.close();
          },
        ),
        onData: (user) {
          print('🔍 AuthBloc - Auth state data received: ${user?.email}');
          if (user != null) {
            print('✅ AuthBloc - User authenticated: ${user.email}');
            return AuthAuthenticated(user);
          } else {
            print('❌ AuthBloc - No user found, unauthenticated');
            return AuthUnauthenticated();
          }
        },
        onError: (error, stackTrace) {
          print('❌ AuthBloc - Auth state error: $error');
          return AuthError('Failed to check auth state');
        },
      );
    } catch (e) {
      print('❌ AuthBloc - Auth check exception: $e');
      // If timeout or other error, default to unauthenticated
      emit(AuthUnauthenticated());
    }
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
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      emit(AuthAuthenticated(user));
    });
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
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      emit(AuthAuthenticated(user));
      // For new users, ensure onboarding is marked as incomplete
      // This will be handled by the router logic
    });
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError('Failed to sign out: ${failure.message}')),
      (_) {
        print('🔄 AuthBloc - User signed out successfully');
        emit(AuthUnauthenticated());
        // Note: AppFlowBloc will be notified via the router's redirect logic
        // when it detects the auth state change
      },
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
}
