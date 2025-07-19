import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'package:go_router/go_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Debug Flow Test', () {
    testWidgets('Debug app flow and find actual UI elements', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait a bit for initialization
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Debug: Print all text widgets found
      print('=== DEBUGGING APP FLOW ===');
      print('All text widgets found:');
      for (final widget in find.byType(Text).evaluate()) {
        final text = widget.widget as Text;
        print('Text: "${text.data}"');
      }

      // Debug: Print all form fields found
      print('\nAll TextFormField widgets found:');
      final formFields = find.byType(TextFormField).evaluate();
      print('Found ${formFields.length} TextFormField widgets');

      // Debug: Print all buttons found
      print('\nAll buttons found:');
      for (final widget in find.byType(ElevatedButton).evaluate()) {
        final button = widget.widget as ElevatedButton;
        if (button.child is Text) {
          final text = button.child as Text;
          print('Button: "${text.data}"');
        }
      }

      // Debug: Print current route
      print('\nCurrent route information:');
      final context = tester.element(find.byType(MaterialApp));
      if (context.mounted) {
        print('Context mounted: true');
        // Try to get route information
        try {
          final router = GoRouter.of(context);
          print(
            'Current location: ${router.routerDelegate.currentConfiguration.uri}',
          );
        } catch (e) {
          print('Could not get router info: $e');
        }
      }

      // Take a screenshot for visual debugging
      await tester.pumpAndSettle();
      print('\nTest completed. Check the screenshot for visual debugging.');
    });
  });
}
