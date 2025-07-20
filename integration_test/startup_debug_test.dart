import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Startup Debug Test', () {
    testWidgets('Debug app startup process', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait and check multiple times to see the progression
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Check for specific screens
        final hasTrackFlow = find.text('TrackFlow').evaluate().isNotEmpty;
        final hasContinueWithEmail =
            find.text('Continue with Email').evaluate().isNotEmpty;
        final hasProjects =
            find.textContaining('Projects').evaluate().isNotEmpty;

        // If we find the auth screen, we're good
        if (hasTrackFlow && hasContinueWithEmail) {
          break;
        }

        // If we find the dashboard, that's also good
        if (hasProjects) {
          break;
        }
      }
    });
  });
}
