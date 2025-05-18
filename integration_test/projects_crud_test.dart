import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:trackflow/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Projects CRUD flow', (WidgetTester tester) async {
    app.main(testMode: true);
    await tester.pumpAndSettle();

    // Debug: Check if add button is present
    final addButton = find.byIcon(Icons.add);
    print('Add button found: \\${addButton.evaluate().length}');
    if (addButton.evaluate().isEmpty) {
      debugDumpApp();
    }

    // CREATE
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Integration Project',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Integration Description',
    );
    await tester.tap(find.textContaining('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Integration Project'), findsOneWidget);

    // UPDATE
    await tester.tap(find.text('Integration Project'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Updated Project');
    await tester.tap(find.textContaining('Update'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Project'), findsOneWidget);

    // DELETE
    await tester.tap(find.text('Updated Project'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Updated Project'), findsNothing);
  });
}
