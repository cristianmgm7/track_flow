import 'package:flutter/material.dart';
import 'package:trackflow/core/error/failures.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Function()? onRetry;
  final String? fallbackMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onRetry,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error) {
          return Material(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    fallbackMessage ?? 'An unexpected error occurred',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

/// Extension to handle common error scenarios
extension ErrorHandlingExtension on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(this).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: this,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  /// Shows appropriate error UI based on failure type
  void handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
      case ServerFailure:
        showErrorSnackBar(failure.message);
        break;
      case ValidationFailure:
        showErrorDialog('Validation Error', failure.message);
        break;
      case AuthenticationFailure:
        showErrorDialog('Authentication Error', failure.message);
        break;
      default:
        showErrorSnackBar(failure.message);
    }
  }
}
