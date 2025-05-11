import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/repositories/firestore_project_repository.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

@GenerateMocks([Connectivity])
import 'sync_project_repository_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late Box<Map<String, dynamic>> projectsBox;
  late MockConnectivity mockConnectivity;
  late FirestoreProjectRepository remoteRepository;
  late HiveProjectLocalDataSource localDataSource;
  late SyncProjectRepository repository;

  final testProject = Project(
    id: 'test-id',
    userId: 'user-123',
    title: 'Test Project',
    description: 'Test Description',
    createdAt: DateTime(2024, 1, 1),
    status: Project.statusDraft,
  );

  setUp(() async {
    // Initialize Hive for testing
    Hive.init('test/hive');
    projectsBox = await Hive.openBox<Map<String, dynamic>>('projects');

    // Setup mocks and repositories
    fakeFirestore = FakeFirebaseFirestore();
    mockConnectivity = MockConnectivity();
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => Stream.value(ConnectivityResult.wifi));
    remoteRepository = FirestoreProjectRepository(firestore: fakeFirestore);
    localDataSource = HiveProjectLocalDataSource(box: projectsBox);

    repository = SyncProjectRepository(
      localDataSource: localDataSource,
      remoteRepository: remoteRepository,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() async {
    await projectsBox.clear();
    await projectsBox.close();
    await Hive.close();
  });

  group('SyncProjectRepository - Local Operations', () {
    test('creates project locally immediately', () async {
      // Act
      final createdProject = await repository.createProject(testProject);

      // Assert
      expect(createdProject.id, equals(testProject.id));
      expect(createdProject.title, equals(testProject.title));

      // Verify local storage
      final localProject = await localDataSource.getCachedProject(
        testProject.id,
      );
      expect(localProject, isNotNull);
      expect(localProject!.title, equals(testProject.title));
    });

    test('updates project locally immediately', () async {
      // Arrange
      await repository.createProject(testProject);
      final updatedProject = testProject.copyWith(
        title: 'Updated Title',
        status: Project.statusInProgress,
      );

      // Act
      await repository.updateProject(updatedProject);

      // Assert
      final localProject = await localDataSource.getCachedProject(
        testProject.id,
      );
      expect(localProject!.title, equals('Updated Title'));
      expect(localProject.status, equals(Project.statusInProgress));
    });

    test('deletes project locally immediately', () async {
      // Arrange
      await repository.createProject(testProject);

      // Act
      await repository.deleteProject(testProject.id);

      // Assert
      final localProject = await localDataSource.getCachedProject(
        testProject.id,
      );
      expect(localProject, isNull);
    });
  });

  group('SyncProjectRepository - Sync Operations', () {
    test('syncs project to remote when online', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);

      // Act
      await repository.createProject(testProject);
      // Wait for sync
      await Future.delayed(const Duration(milliseconds: 1000));

      // Assert
      final remoteDoc =
          await fakeFirestore.collection('projects').doc(testProject.id).get();
      expect(remoteDoc.exists, isTrue);
      expect(remoteDoc.data()?['title'], equals(testProject.title));
    });

    test('queues operations when offline', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.none);

      // Act
      await repository.createProject(testProject);
      // Wait for potential sync
      await Future.delayed(const Duration(milliseconds: 1000));

      // Assert
      final remoteDoc =
          await fakeFirestore.collection('projects').doc(testProject.id).get();
      expect(remoteDoc.exists, isFalse); // Should not be synced yet

      // Simulate coming online
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);
      when(
        mockConnectivity.onConnectivityChanged,
      ).thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

      // Wait for sync
      await Future.delayed(const Duration(milliseconds: 1000));

      // Verify sync happened
      final remoteDocAfterSync =
          await fakeFirestore.collection('projects').doc(testProject.id).get();
      expect(remoteDocAfterSync.exists, isTrue);
      expect(remoteDocAfterSync.data()?['title'], equals(testProject.title));
    });

    test('emits sync status changes', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);

      // Act & Assert
      expectLater(
        repository.syncStatus,
        emitsInOrder([
          isA<SyncStatus>().having(
            (s) => s.type,
            'type',
            SyncStatusType.syncing,
          ),
          isA<SyncStatus>().having(
            (s) => s.type,
            'type',
            SyncStatusType.synced,
          ),
        ]),
      );

      await repository.createProject(testProject);
    });
  });

  group('SyncProjectRepository - Error Handling', () {
    test('handles remote errors gracefully', () async {
      // Arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => ConnectivityResult.wifi);

      // Simulate remote error
      fakeFirestore.collection('projects').doc(testProject.id).set({
        'id': 'existing-id', // This will cause a conflict
      });

      // Act
      await repository.createProject(testProject);
      // Wait for sync attempt
      await Future.delayed(const Duration(milliseconds: 1000));

      // Assert
      final localProject = await localDataSource.getCachedProject(
        testProject.id,
      );
      expect(localProject, isNotNull); // Local storage should still work

      // Verify error status was emitted
      expect(
        repository.syncStatus,
        emitsInOrder([
          isA<SyncStatus>().having(
            (s) => s.type,
            'type',
            SyncStatusType.syncing,
          ),
          isA<SyncStatus>().having((s) => s.type, 'type', SyncStatusType.error),
        ]),
      );
    });
  });
}
