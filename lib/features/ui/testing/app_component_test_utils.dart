import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_style.dart';

/// Testing utilities for TrackFlow UI components
///
/// Provides comprehensive testing tools for all UI components
/// to ensure quality and consistency.
class AppComponentTestUtils {
  // Test widget wrapper with theme
  static Widget createTestApp(Widget child) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          onSurface: AppColors.textPrimary,
        ),
      ),
      home: Scaffold(backgroundColor: AppColors.background, body: child),
    );
  }

  // Test widget wrapper with BLoC
  static Widget createTestAppWithBloc<T extends StateStreamableSource<S>, S>(
    Widget child,
    T bloc,
  ) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          onSurface: AppColors.textPrimary,
        ),
      ),
      home: BlocProvider<T>(
        create: (context) => bloc,
        child: Scaffold(backgroundColor: AppColors.background, body: child),
      ),
    );
  }

  // Common test helpers
  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget widget, {
    bool withTheme = true,
  }) async {
    if (withTheme) {
      await tester.pumpWidget(createTestApp(widget));
    } else {
      await tester.pumpWidget(widget);
    }
    await tester.pumpAndSettle();
  }

  static Future<void> pumpWidgetWithBloc<T extends StateStreamableSource<S>, S>(
    WidgetTester tester,
    Widget widget,
    T bloc,
  ) async {
    await tester.pumpWidget(createTestAppWithBloc(widget, bloc));
    await tester.pumpAndSettle();
  }

  // Common assertions
  static void expectTextPresent(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void expectTextNotPresent(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }

  static void expectWidgetPresent(WidgetTester tester, Type widgetType) {
    expect(find.byType(widgetType), findsOneWidget);
  }

  static void expectWidgetNotPresent(WidgetTester tester, Type widgetType) {
    expect(find.byType(widgetType), findsNothing);
  }

  static void expectIconPresent(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  static void expectIconNotPresent(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsNothing);
  }

  // Interaction helpers
  static Future<void> tapButton(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  static Future<void> tapIcon(WidgetTester tester, IconData icon) async {
    await tester.tap(find.byIcon(icon));
    await tester.pumpAndSettle();
  }

  static Future<void> enterText(
    WidgetTester tester,
    String text,
    String hint,
  ) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pumpAndSettle();
  }

  static Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      500.0,
      scrollable: find.byType(SingleChildScrollView),
    );
    await tester.pumpAndSettle();
  }

  // Visual testing helpers
  static Future<void> expectGoldenMatch(
    WidgetTester tester,
    String goldenName,
  ) async {
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(goldenName));
  }

  // Accessibility testing
  static void expectSemanticsPresent(WidgetTester tester, String label) {
    expect(find.bySemanticsLabel(label), findsOneWidget);
  }

  static void expectSemanticsNotPresent(WidgetTester tester, String label) {
    expect(find.bySemanticsLabel(label), findsNothing);
  }

  // Performance testing
  static Future<void> measurePerformance(
    WidgetTester tester,
    Future<void> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();

    // Log performance metrics
    debugPrint(
      'Performance test completed in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  // Memory testing
  static void expectNoMemoryLeaks(WidgetTester tester) {
    // Check for disposed controllers, animations, etc.
    // This is a placeholder for actual memory leak detection
  }
}

/// Test data generators
class AppTestData {
  // Sample project data
  static Map<String, dynamic> sampleProject = {
    'id': 'test-project-id',
    'name': 'Test Project',
    'description': 'A test project for UI testing',
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  // Sample user data
  static Map<String, dynamic> sampleUser = {
    'id': 'test-user-id',
    'name': 'Test User',
    'email': 'test@example.com',
    'avatar': null,
  };

  // Sample audio track data
  static Map<String, dynamic> sampleAudioTrack = {
    'id': 'test-track-id',
    'name': 'Test Track',
    'duration': 180.0,
    'url': 'https://example.com/test.mp3',
  };

  // Sample form data
  static Map<String, dynamic> sampleFormData = {
    'name': 'Test Form',
    'email': 'test@example.com',
    'phone': '+1234567890',
    'message': 'This is a test message',
  };
}

/// Mock widgets for testing
class MockWidgets {
  static Widget mockLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  static Widget mockErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  static Widget mockEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 48),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}

/// Test scenarios
class AppTestScenarios {
  // Button testing scenarios
  static Future<void> testButtonInteraction(
    WidgetTester tester,
    Widget button,
    VoidCallback? onPressed,
  ) async {
    await AppComponentTestUtils.pumpWidget(tester, button);

    if (onPressed != null) {
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }
  }

  // Form testing scenarios
  static Future<void> testFormSubmission(
    WidgetTester tester,
    Widget form,
    Map<String, String> formData,
  ) async {
    await AppComponentTestUtils.pumpWidget(tester, form);

    // Fill form fields
    for (final entry in formData.entries) {
      await AppComponentTestUtils.enterText(tester, entry.value, entry.key);
    }

    // Submit form
    await AppComponentTestUtils.tapButton(tester, 'Submit');
  }

  // List testing scenarios
  static Future<void> testListScrolling(
    WidgetTester tester,
    Widget list,
    int itemCount,
  ) async {
    await AppComponentTestUtils.pumpWidget(tester, list);

    // Scroll through list
    for (int i = 0; i < itemCount; i++) {
      await tester.scrollUntilVisible(
        find.text('Item $i'),
        500.0,
        scrollable: find.byType(SingleChildScrollView),
      );
    }
  }

  // Modal testing scenarios
  static Future<void> testModalInteraction(
    WidgetTester tester,
    Widget modal,
    String actionText,
  ) async {
    await AppComponentTestUtils.pumpWidget(tester, modal);

    // Perform action
    await AppComponentTestUtils.tapButton(tester, actionText);
    await tester.pumpAndSettle();
  }
}

/// Test matchers
class AppTestMatchers {
  // Custom matchers for common UI patterns
  static Finder hasText(String text) {
    return find.text(text);
  }

  static Finder hasIcon(IconData icon) {
    return find.byIcon(icon);
  }

  static Finder hasWidget(Type widgetType) {
    return find.byType(widgetType);
  }

  static Finder hasSemanticsLabel(String label) {
    return find.bySemanticsLabel(label);
  }

  static Finder isEnabled() {
    return find.byWidgetPredicate((widget) {
      if (widget is ElevatedButton) {
        return widget.onPressed != null;
      }
      return false;
    });
  }

  static Finder isDisabled() {
    return find.byWidgetPredicate((widget) {
      if (widget is ElevatedButton) {
        return widget.onPressed == null;
      }
      return false;
    });
  }
}
