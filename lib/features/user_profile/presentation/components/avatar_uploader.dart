import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/utils/image_utils.dart';

class AvatarUploader extends StatefulWidget {
  final String initialUrl;
  final ValueChanged<String> onAvatarChanged;
  final bool isGoogleUser; // ✅ NUEVO: Flag para usuarios de Google

  const AvatarUploader({
    super.key,
    required this.initialUrl,
    required this.onAvatarChanged,
    this.isGoogleUser = false, // ✅ NUEVO: Default false
  });

  @override
  State<AvatarUploader> createState() => _AvatarUploaderState();
}

class _AvatarUploaderState extends State<AvatarUploader> {
  String _avatarUrl = '';
  final bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.initialUrl;
  }

  void _handleAvatarTap() async {
    // Feedback táctil
    HapticFeedback.lightImpact();

    // Feedback auditivo
    SystemSound.play(SystemSoundType.click);

    // TODO: Implement image picker functionality
    // For now, this is a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar upload coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: 'Selector de imagen de perfil',
          button: true,
          child: Stack(
            alignment: Alignment.center,
            children: [_buildAvatar(), _buildEditButton()],
          ),
        ),
        SizedBox(height: Dimensions.space16),
        Text(
          widget.isGoogleUser
              ? 'Google Account Connected'
              : 'Tap to change profile picture',
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              _isValidating
                  ? Colors.orange
                  : (widget.isGoogleUser
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : AppColors.border.withValues(alpha: 0.3)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: GestureDetector(
          onTap: _handleAvatarTap,
          child: ImageUtils.createRobustImageWidget(
            imagePath: _avatarUrl,
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            fallbackWidget: Semantics(
              label: 'Imagen de perfil no disponible',
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Semantics(
        label: 'Cambiar imagen de perfil',
        button: true,
        child: GestureDetector(
          onTap: _handleAvatarTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey900.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 16,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
