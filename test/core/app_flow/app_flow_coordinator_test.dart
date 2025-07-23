import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/app_flow/data/services/app_flow_coordinator.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/core/sync/data/services/sync_service.dart';
import 'package:trackflow/core/session/domain/entities/user_session.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/app_flow/domain/entities/app_flow_state.dart';
import 'package:trackflow/features/auth/domain/entities/user.dart';
import 'package:trackflow/core/entities/unique_id.dart';

import 'app_flow_coordinator_test.mocks.dart';

@GenerateMocks([SessionService, SyncService])
void main() {
  group('AppFlowCoordinator', () {
    late AppFlowCoordinator coordinator;
    late MockSessionService mockSessionService;
    late MockSyncService mockSyncService;

    setUp(() {
      mockSessionService = MockSessionService();
      mockSyncService = MockSyncService();
      coordinator = AppFlowCoordinator(
        sessionService: mockSessionService,
        syncService: mockSyncService,
      );
    });

    test('should return unauthenticated when user is not logged in', () async {
      // Arrange
      when(
        mockSessionService.getCurrentSession(),
      ).thenAnswer((_) async => Right(const UserSession.unauthenticated()));
      when(mockSyncService.getCurrentSyncState()).thenAnswer(
        (_) async => Right(const SyncState(status: SyncStatus.complete)),
      );

      // Act
      final result = await coordinator.determineAppFlow();

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (flowState) {
        expect(flowState.status, AppFlowStatus.unauthenticated);
      });
    });

    test(
      'should return ready when user is authenticated and sync is complete',
      () async {
        // Arrange
        final user = User(
          id: UserId.fromUniqueString('test-user'),
          email: 'test@example.com',
        );
        when(
          mockSessionService.getCurrentSession(),
        ).thenAnswer((_) async => Right(UserSession.ready(user: user)));
        when(mockSyncService.getCurrentSyncState()).thenAnswer(
          (_) async => Right(const SyncState(status: SyncStatus.complete)),
        );

        // Act
        final result = await coordinator.determineAppFlow();

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          flowState,
        ) {
          expect(flowState.status, AppFlowStatus.ready);
          expect(flowState.session.currentUser, user);
        });
      },
    );

    test('should return authenticated when user needs onboarding', () async {
      // Arrange
      final user = User(
        id: UserId.fromUniqueString('test-user'),
        email: 'test@example.com',
      );
      when(mockSessionService.getCurrentSession()).thenAnswer(
        (_) async => Right(
          UserSession.authenticated(
            user: user,
            onboardingComplete: false,
            profileComplete: false,
          ),
        ),
      );
      when(mockSyncService.getCurrentSyncState()).thenAnswer(
        (_) async => Right(const SyncState(status: SyncStatus.complete)),
      );

      // Act
      final result = await coordinator.determineAppFlow();

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (flowState) {
        expect(flowState.status, AppFlowStatus.authenticated);
        expect(flowState.session.currentUser, user);
        expect(flowState.session.isOnboardingCompleted, false);
      });
    });
  });
}
