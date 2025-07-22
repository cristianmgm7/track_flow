import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth State Debug Test', () {
    testWidgets('Debug auth state stream behavior', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to initialize
      await Future.delayed(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Check if we're still in splash or moved to auth
      final splashText = find.text('Welcome to TrackFlow');
      final authText = find.text('TrackFlow');

      if (splashText.evaluate().isNotEmpty) {
        // Still in splash
      } else if (authText.evaluate().isNotEmpty) {
        // Successfully moved to auth screen
      }
    });
  });
}
