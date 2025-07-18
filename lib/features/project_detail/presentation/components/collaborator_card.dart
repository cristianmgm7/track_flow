import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'dart:ui';
import 'dart:io';

class CollaboratorCard extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final ProjectRole role;
  final CreativeRole? creativeRole;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CollaboratorCard({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
    this.creativeRole,
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
          boxShadow: AppShadows.medium,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background avatar image
              _buildBackgroundImage(),
              
              // Dark overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              
              // Glass filter overlay at bottom with collaborator info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildGlassOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (avatarUrl.isNotEmpty) {
      ImageProvider imageProvider;
      if (avatarUrl.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl);
      } else {
        imageProvider = FileImage(File(avatarUrl));
      }
      
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback to default avatar if image fails to load
            },
          ),
        ),
      );
    } else {
      // Default avatar background
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppTextStyle.displayLarge.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildGlassOverlay() {
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
                AppColors.textPrimary.withValues(alpha: 0.1),
                AppColors.textPrimary.withValues(alpha: 0.2),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: AppTextStyle.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: Dimensions.space4),
              
              // Email
              Text(
                email,
                style: AppTextStyle.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: Dimensions.space8),
              
              // Roles row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Creative role (if available)
                  if (creativeRole != null)
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.space8,
                          vertical: Dimensions.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          creativeRole!.toString().split('.').last,
                          style: AppTextStyle.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  
                  // Project role
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.space8,
                      vertical: Dimensions.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      role.toShortString(),
                      style: AppTextStyle.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal scrollable collaborator cards list
class CollaboratorCardsHorizontalList extends StatelessWidget {
  final List<CollaboratorCardData> collaborators;
  final double? cardHeight;
  final EdgeInsets? padding;
  final Function(CollaboratorCardData)? onCardTap;

  const CollaboratorCardsHorizontalList({
    super.key,
    required this.collaborators,
    this.cardHeight,
    this.padding,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight ?? 240.0,
      padding: padding ?? EdgeInsets.symmetric(horizontal: Dimensions.space16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: collaborators.length,
        itemBuilder: (context, index) {
          final collaborator = collaborators[index];
          return CollaboratorCard(
            name: collaborator.name,
            email: collaborator.email,
            avatarUrl: collaborator.avatarUrl,
            role: collaborator.role,
            creativeRole: collaborator.creativeRole,
            height: cardHeight,
            onTap: () => onCardTap?.call(collaborator),
          );
        },
      ),
    );
  }
}

/// Data class for collaborator card
class CollaboratorCardData {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final ProjectRole role;
  final CreativeRole? creativeRole;

  const CollaboratorCardData({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
    this.creativeRole,
  });
}