import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/features/auth/domain/usecases/auth_usecases.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart' as domain;
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/entities/email.dart';
import 'package:trackflow/features/auth/domain/entities/password.dart';

class MockAuthUseCases extends Mock implements AuthUseCases {}

class FakeEmail extends Fake implements Email {}

class FakePassword extends Fake implements Password {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEmail());
    registerFallbackValue(FakePassword());
  });

  late AuthBloc bloc;
  late MockAuthUseCases mockUseCases;
  final testUser = domain.User(id: '123', email: 'test@example.com');

  setUp(() {
    mockUseCases = MockAuthUseCases();
    bloc = AuthBloc(mockUseCases);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
    build: () {
      when(
        () => mockUseCases.signIn(
          any(that: isA<Email>()),
          any(that: isA<Password>()),
        ),
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
        () => mockUseCases.signIn(
          any(that: isA<Email>()),
          any(that: isA<Password>()),
        ),
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
        () => mockUseCases.signUp(
          any(that: isA<Email>()),
          any(that: isA<Password>()),
        ),
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
      when(() => mockUseCases.signOut()).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(AuthSignOutRequested()),
    expect: () => [AuthLoading(), AuthUnauthenticated()],
  );
}
