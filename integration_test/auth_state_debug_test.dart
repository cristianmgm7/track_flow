import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth State Debug Test', () {
    testWidgets('Debug auth state stream behavior', (
      WidgetTester tester,
    ) async {
      print('=== DEBUGGING AUTH STATE STREAM ===');

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to initialize
      await Future.delayed(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Check what's currently displayed
      final allTexts = find.byType(Text).evaluate();
      print('Text widgets found: ${allTexts.length}');
      for (final widget in allTexts) {
        final text = widget.widget as Text;
        print('  - "${text.data}"');
      }

      // Check if we're still in splash or moved to auth
      final splashText = find.text('Welcome to TrackFlow');
      final authText = find.text('TrackFlow');

      if (splashText.evaluate().isNotEmpty) {
        print('❌ Still stuck in splash screen');
      } else if (authText.evaluate().isNotEmpty) {
        print('✅ Successfully moved to auth screen');
      } else {
        print('❓ Unknown state - neither splash nor auth text found');
      }
    });
  });
}
