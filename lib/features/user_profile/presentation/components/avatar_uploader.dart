import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _avatarUrl = widget.initialUrl;
  }

  void _handleAvatarTap() {
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
        Center(child: Stack(children: [_buildAvatar(), _buildEditButton()])),
        SizedBox(height: Dimensions.space12),
        Text(
          widget.isGoogleUser ? 'Google Profile Picture' : 'Profile Picture',
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.space4),
        if (widget.isGoogleUser)
          Text(
            'Using your Google profile picture',
            style: AppTextStyle.bodySmall.copyWith(color: AppColors.success),
            textAlign: TextAlign.center,
          )
        else
          Text(
            'Add a photo to help others recognize you',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    final avatarProvider = ImageUtils.createSafeImageProvider(_avatarUrl);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              widget.isGoogleUser
                  ? AppColors.primary.withValues(
                    alpha: 0.3,
                  ) // ✅ NUEVO: Color especial para Google
                  : AppColors.border.withValues(alpha: 0.3),
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
      child: CircleAvatar(
        radius: 58,
        backgroundColor: AppColors.surface,
        backgroundImage: avatarProvider,
        child:
            avatarProvider == null
                ? Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                )
                : null,
      ),
    );
  }

  Widget _buildEditButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleAvatarTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  widget.isGoogleUser
                      ? AppColors
                          .success // ✅ NUEVO: Color verde para Google
                      : AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey900.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              widget.isGoogleUser
                  ? Icons.check
                  : Icons.camera_alt, // ✅ NUEVO: Icono diferente para Google
              size: Dimensions.iconSmall,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
