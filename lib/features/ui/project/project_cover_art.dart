import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_gradients.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'dart:io';
import 'dart:math' as math;

class ProjectCoverArt extends StatelessWidget {
  final String projectName;
  final String? projectDescription;
  final double size;
  final String? imageUrl;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const ProjectCoverArt({
    super.key,
    required this.projectName,
    this.projectDescription,
    this.size = Dimensions.avatarMedium,
    this.imageUrl,
    this.showShadow = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Check local path first (offline support)
    if (imageUrl != null && imageUrl!.isNotEmpty && !imageUrl!.startsWith('http')) {
      return _buildLocalImageCover();
    }

    // Then check remote URL
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildImageCover();
    }

    // Otherwise, show generated placeholder
    return _buildGeneratedCover();
  }

  Widget _buildImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingCover(),
          errorWidget: (context, url, error) => _buildGeneratedCover(),
        ),
      ),
    );
  }

  Widget _buildLocalImageCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppBorders.medium,
        child: Image.file(
          File(imageUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildGeneratedCover(),
        ),
      ),
    );
  }

  Widget _buildGeneratedCover() {
    final gradient = _generateGradientFromName(projectName);
    final initials = _generateInitials(projectName);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: size * 0.3,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCover() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.shimmer,
        borderRadius: borderRadius ?? AppBorders.medium,
        boxShadow: showShadow ? AppShadows.card : null,
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: size * 0.3,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }


  LinearGradient _generateGradientFromName(String name) {
    // Generate a consistent gradient based on project name
    final hash = name.hashCode;
    final random = math.Random(hash);
    
    // Create Spotify-style gradients with predefined color combinations
    final gradientSets = [
      [const Color(0xFF1DB954), const Color(0xFF1ED760)], // Spotify green
      [const Color(0xFF9146FF), const Color(0xFFB19CD9)], // Purple
      [const Color(0xFFE22134), const Color(0xFFFF4458)], // Red
      [const Color(0xFF0D73EC), const Color(0xFF3B82F6)], // Blue
      [const Color(0xFFF59E0B), const Color(0xFFEAB308)], // Yellow
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
      [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Rose
      [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // Violet
      [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan
      [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pink
    ];

    final selectedGradient = gradientSets[random.nextInt(gradientSets.length)];
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: selectedGradient,
      stops: const [0.0, 1.0],
    );
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return 'P';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, math.min(2, words[0].length)).toUpperCase();
    }
    
    // Take first letter of first two words
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }
}


// Factory methods for different sizes
class ProjectCoverArtSizes {
  static ProjectCoverArt small({
    required String projectName,
    String? projectDescription,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return ProjectCoverArt(
      projectName: projectName,
      projectDescription: projectDescription,
      imageUrl: imageUrl,
      size: Dimensions.avatarSmall, // 32
      showShadow: showShadow,
      borderRadius: AppBorders.tiny,
    );
  }

  static ProjectCoverArt medium({
    required String projectName,
    String? projectDescription,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return ProjectCoverArt(
      projectName: projectName,
      projectDescription: projectDescription,
      imageUrl: imageUrl,
      size: Dimensions.avatarMedium, // 48
      showShadow: showShadow,
      borderRadius: AppBorders.tiny,
    );
  }

  static ProjectCoverArt large({
    required String projectName,
    String? projectDescription,
    String? imageUrl,
    bool showShadow = false,
  }) {
    return ProjectCoverArt(
      projectName: projectName,
      projectDescription: projectDescription,
      imageUrl: imageUrl,
      size: Dimensions.avatarLarge, // 64
      showShadow: showShadow,
      borderRadius: AppBorders.tiny,
    );
  }
}