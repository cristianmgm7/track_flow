import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';

class InviteCollaboratorButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const InviteCollaboratorButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = width ?? (screenWidth / 2) - (Dimensions.space16 * 1.5);
    final cardHeight = height ?? 240.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(right: Dimensions.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color: AppColors.primary.withAlpha(128),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background with subtle gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withAlpha(64),
                      AppColors.primary.withAlpha(32),
                    ],
                  ),
                ),
              ),

              // Glass filter overlay at bottom with invite info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildGlassOverlay(context),
              ),

              // Center icon
              Center(
                child: Icon(
                  Icons.person_add,
                  size: Dimensions.iconXLarge,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassOverlay(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(Dimensions.radiusLarge),
        bottomRight: Radius.circular(Dimensions.radiusLarge),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(Dimensions.space16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface.withAlpha(128),
                AppColors.surface.withAlpha(192),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.primary.withAlpha(64),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'Invite Collaborator',
                style: AppTextStyle.titleMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: Dimensions.space4),

              // Subtitle
              Text(
                'Add someone to work on this project',
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
