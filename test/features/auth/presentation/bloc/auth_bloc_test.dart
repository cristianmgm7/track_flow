import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart';

class FakeEmail extends Fake implements EmailAddress {}

class FakePassword extends Fake implements PasswordValue {}

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockGetAuthStateUseCase extends Mock implements GetAuthStateUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEmail());
    registerFallbackValue(FakePassword());
  });

  late AuthBloc bloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockGoogleSignInUseCase mockGoogleSignInUseCase;
  late MockGetAuthStateUseCase mockGetAuthStateUseCase;
  final testUser = domain.User(id: '123', email: 'test@example.com');

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockGoogleSignInUseCase = MockGoogleSignInUseCase();
    mockGetAuthStateUseCase = MockGetAuthStateUseCase();

    bloc = AuthBloc(
      signIn: mockSignInUseCase,
      signUp: mockSignUpUseCase,
      signOut: mockSignOutUseCase,
      googleSignIn: mockGoogleSignInUseCase,
      getAuthState: mockGetAuthStateUseCase,
    );
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
    build: () {
      when(
        () => mockSignInUseCase.call(any<EmailAddress>(), any<PasswordValue>()),
      ).thenAnswer((_) async => right(testUser));
      return bloc;
    },
    act:
        (bloc) => bloc.add(
          AuthSignInRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
    expect: () => [AuthLoading(), AuthAuthenticated(testUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when sign in fails',
    build: () {
      when(
        () => mockSignInUseCase.call(any<EmailAddress>(), any<PasswordValue>()),
      ).thenAnswer((_) async => left(AuthenticationFailure('fail')));
      return bloc;
    },
    act:
        (bloc) => bloc.add(
          AuthSignInRequested(email: 'test@example.com', password: 'wrong'),
        ),
    expect: () => [AuthLoading(), AuthError('fail')],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
    build: () {
      when(
        () => mockSignUpUseCase.call(any<EmailAddress>(), any<PasswordValue>()),
      ).thenAnswer((_) async => right(testUser));
      return bloc;
    },
    act:
        (bloc) => bloc.add(
          AuthSignUpRequested(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
    expect: () => [AuthLoading(), AuthAuthenticated(testUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
    build: () {
      when(() => mockSignOutUseCase.call()).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(AuthSignOutRequested()),
    expect: () => [AuthLoading(), AuthUnauthenticated()],
  );
}
