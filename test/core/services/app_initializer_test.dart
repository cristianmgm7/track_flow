import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/services/app_initializer.dart';
import 'package:trackflow/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:trackflow/features/onboarding/data/repositories/shared_prefs_onboarding_repository.dart';

// Generate mocks
@GenerateMocks([FirebaseAuthRepository, SharedPrefsOnboardingRepository])
import 'app_initializer_test.mocks.dart';

void main() {
  late MockFirebaseAuthRepository mockAuthRepo;
  late MockSharedPrefsOnboardingRepository mockOnboardingRepo;
  late AppInitializer initializer;

  setUpAll(() {
    // Set up mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    mockAuthRepo = MockFirebaseAuthRepository();
    mockOnboardingRepo = MockSharedPrefsOnboardingRepository();

    // Get the actual SharedPreferences instance (it will be a mock)
    final prefs = await SharedPreferences.getInstance();

    initializer = TestAppInitializer(
      prefs: prefs,
      authRepository: mockAuthRepo,
      onboardingRepository: mockOnboardingRepo,
    );
  });

  group('AppInitializer', () {
    test('initializes all dependencies successfully', () async {
      // Act
      await initializer.initialize();

      // Assert
      expect(initializer.authRepository, equals(mockAuthRepo));
      expect(initializer.onboardingRepository, equals(mockOnboardingRepo));
    });

    test('handles initialization errors gracefully', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({
        'invalid_key': Object(), // This will cause an error when reading
      });

      final prefs = await SharedPreferences.getInstance();
      final errorInitializer = ErrorThrowingAppInitializer(
        prefs: prefs,
        authRepository: mockAuthRepo,
        onboardingRepository: mockOnboardingRepo,
      );

      // Act & Assert
      expect(() => errorInitializer.initialize(), throwsA(isA<Exception>()));
    });
  });
}

/// Test version of AppInitializer that allows dependency injection
class TestAppInitializer extends AppInitializer {
  @override
  final SharedPreferences prefs;
  @override
  final FirebaseAuthRepository authRepository;
  @override
  final SharedPrefsOnboardingRepository onboardingRepository;

  TestAppInitializer({
    required this.prefs,
    required this.authRepository,
    required this.onboardingRepository,
  });

  @override
  Future<void> initialize() async {
    // Skip actual Firebase initialization for tests
    // WidgetsFlutterBinding.ensureInitialized();
    // await Firebase.initializeApp(...);

    // Use the injected dependencies
    super.prefs = prefs;
    super.authRepository = authRepository;
    super.onboardingRepository = onboardingRepository;
  }
}

/// Test version of AppInitializer that throws an error during initialization
class ErrorThrowingAppInitializer extends AppInitializer {
  @override
  final SharedPreferences prefs;
  @override
  final FirebaseAuthRepository authRepository;
  @override
  final SharedPrefsOnboardingRepository onboardingRepository;

  ErrorThrowingAppInitializer({
    required this.prefs,
    required this.authRepository,
    required this.onboardingRepository,
  });

  @override
  Future<void> initialize() async {
    throw Exception('Test initialization error');
  }
}
