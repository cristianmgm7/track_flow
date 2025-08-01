// Test configuration for excluding integration tests from unit test runs
// Integration tests should be run separately with: flutter test integration_test/

const List<String> excludeFromUnitTests = [
  'test/integration_test/**',
];