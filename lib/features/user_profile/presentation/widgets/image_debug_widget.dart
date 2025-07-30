import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackflow/core/utils/image_utils.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

/// Debug widget to test and monitor image handling system
/// This widget helps developers understand the state of image storage
class ImageDebugWidget extends StatefulWidget {
  final String imagePath;

  const ImageDebugWidget({super.key, required this.imagePath});

  @override
  State<ImageDebugWidget> createState() => _ImageDebugWidgetState();
}

class _ImageDebugWidgetState extends State<ImageDebugWidget> {
  String? _validatedPath;
  bool _isValidating = false;
  String _debugInfo = '';
  bool _isMigrating = false;
  bool _isCheckingStorage = false;

  @override
  void initState() {
    super.initState();
    _validateImagePath();
  }

  Future<void> _validateImagePath() async {
    setState(() {
      _isValidating = true;
      _debugInfo = 'Validating image path...';
    });

    try {
      final validatedPath = await ImageUtils.validateAndRepairImagePath(
        widget.imagePath,
      );

      setState(() {
        _validatedPath = validatedPath;
        _isValidating = false;
        _debugInfo = _buildDebugInfo(validatedPath);
      });

      // Feedback auditivo de éxito
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      setState(() {
        _isValidating = false;
        _debugInfo = 'Error validating image: $e';
      });

      // Feedback auditivo de error
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _migrateImages() async {
    setState(() {
      _isMigrating = true;
      _debugInfo += '\nMigrating images...';
    });

    try {
      await ImageUtils.migrateImagesToPermanentStorage();
      await _validateImagePath();

      // Feedback táctil y auditivo
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      setState(() {
        _debugInfo += '\nMigration failed: $e';
      });

      // Feedback de error
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.alert);
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  Future<void> _checkStorage() async {
    setState(() {
      _isCheckingStorage = true;
      _debugInfo += '\nChecking storage...';
    });

    try {
      final size = await ImageUtils.getProfileImagesSize();
      final sizeInMB = (size / (1024 * 1024)).toStringAsFixed(2);
      setState(() {
        _debugInfo += '\nTotal Storage: ${sizeInMB}MB';
      });

      // Feedback de éxito
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      setState(() {
        _debugInfo += '\nStorage check failed: $e';
      });

      // Feedback de error
      SystemSound.play(SystemSoundType.alert);
    } finally {
      setState(() {
        _isCheckingStorage = false;
      });
    }
  }

  String _buildDebugInfo(String? validatedPath) {
    final originalExists = _fileExists(widget.imagePath);
    final validatedExists =
        validatedPath != null ? _fileExists(validatedPath) : false;

    return '''
Original Path: ${widget.imagePath}
Original Exists: $originalExists
Validated Path: ${validatedPath ?? 'null'}
Validated Exists: $validatedExists
Path Repaired: ${widget.imagePath != validatedPath}
''';
  }

  bool _fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Información de debug de imagen',
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Título de debug de imagen',
                child: Text(
                  'Image Debug Info',
                  style: AppTextStyle.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_isValidating || _isMigrating || _isCheckingStorage)
                Semantics(
                  label: 'Procesando operación',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isValidating
                            ? 'Validating...'
                            : _isMigrating
                            ? 'Migrating...'
                            : 'Checking storage...',
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Estado de validación: $_debugInfo',
                child: Text(
                  _debugInfo,
                  style: AppTextStyle.bodySmall.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Botón para revalidar imagen',
                      button: true,
                      child: ElevatedButton(
                        onPressed: _isValidating ? null : _validateImagePath,
                        child: Text(
                          _isValidating ? 'Validating...' : 'Revalidate',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Semantics(
                      label: 'Botón para migrar imágenes',
                      button: true,
                      child: ElevatedButton(
                        onPressed: _isMigrating ? null : _migrateImages,
                        child: Text(_isMigrating ? 'Migrating...' : 'Migrate'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  label: 'Botón para verificar almacenamiento',
                  button: true,
                  child: ElevatedButton(
                    onPressed: _isCheckingStorage ? null : _checkStorage,
                    child: Text(
                      _isCheckingStorage ? 'Checking...' : 'Check Storage',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
