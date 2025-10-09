import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable avatar widget that handles both network URLs and local file paths
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Widget? fallback;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildFallback();
    }

    // Network image (Firebase Storage URL)
    if (imageUrl.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: size,
            height: size,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallback(),
        ),
      );
    }

    // Local file path
    return ClipOval(
      child: Image.file(
        File(imageUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return fallback ??
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.grey[600],
            size: size * 0.6,
          ),
        );
  }
}
