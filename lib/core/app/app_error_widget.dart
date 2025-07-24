import 'package:flutter/material.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Error recovery widget shown when app initialization fails
/// 
/// This widget provides a user-friendly error interface with:
/// - Clear error explanation
/// - Retry functionality  
/// - Option to report the issue
/// - Graceful degradation when core systems fail
class AppErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'TrackFlow Failed to Start',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error description
              Text(
                'An error occurred during app initialization. This may be due to network connectivity issues, corrupted data, or system problems.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Error details (collapsible)
              ExpansionTile(
                title: const Text(
                  'Technical Details',
                  style: TextStyle(color: Colors.white70),
                ),
                iconColor: Colors.white70,
                collapsedIconColor: Colors.white70,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action buttons
              Column(
                children: [
                  // Retry button
                  if (onRetry != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          AppLogger.info('User triggered app restart', tag: 'ERROR_RECOVERY');
                          onRetry!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Retry Initialization',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Safe mode button (basic functionality)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        AppLogger.info('User entered safe mode', tag: 'ERROR_RECOVERY');
                        _showSafeModeDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Safe Mode Options',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Help text
              Text(
                'If this problem persists, please check your internet connection or contact support.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSafeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Safe Mode Options',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safe mode recovery options:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            _buildSafeModeOption(
              '🔄 Clear App Cache',
              'Reset local data and try again',
              () {
                Navigator.of(context).pop();
                _clearCacheAndRetry();
              },
            ),
            _buildSafeModeOption(
              '📱 Restart Device',
              'Restart your device and try again',
              () {
                Navigator.of(context).pop();
                _showRestartInstructions(context);
              },
            ),
            _buildSafeModeOption(
              '🆘 Contact Support',
              'Get help from our support team',
              () {
                Navigator.of(context).pop();
                _showSupportInfo(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeModeOption(String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  void _clearCacheAndRetry() {
    AppLogger.info('Attempting cache clear and retry', tag: 'ERROR_RECOVERY');
    // In a real implementation, this would clear app cache
    // For now, just retry
    if (onRetry != null) {
      onRetry!();
    }
  }

  void _showRestartInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Restart Instructions',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Please restart your device and try opening TrackFlow again. This can resolve many initialization issues.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSupportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please include this error information when contacting support:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Error: ${error.toString()}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}