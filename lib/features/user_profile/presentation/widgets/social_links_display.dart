import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class SocialLinksDisplay extends StatelessWidget {
  final List<SocialLink> socialLinks;

  const SocialLinksDisplay({
    super.key,
    required this.socialLinks,
  });

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.photo_camera;
      case 'twitter':
      case 'x':
        return Icons.alternate_email;
      case 'spotify':
        return Icons.music_note;
      case 'soundcloud':
        return Icons.cloud;
      case 'youtube':
        return Icons.play_circle_outline;
      case 'tiktok':
        return Icons.video_library;
      case 'apple music':
        return Icons.music_note;
      case 'bandcamp':
        return Icons.album;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.link;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
      case 'x':
        return const Color(0xFF1DA1F2);
      case 'spotify':
        return const Color(0xFF1DB954);
      case 'soundcloud':
        return const Color(0xFFFF5500);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'tiktok':
        return const Color(0xFF000000);
      case 'apple music':
        return const Color(0xFFFA243C);
      case 'bandcamp':
        return const Color(0xFF629AA9);
      case 'facebook':
        return const Color(0xFF1877F2);
      default:
        return AppColors.primary;
    }
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.space12,
      runSpacing: Dimensions.space12,
      children: socialLinks.map((link) {
        final color = _getPlatformColor(link.platform);
        final icon = _getPlatformIcon(link.platform);

        return InkWell(
          onTap: () => _openLink(context, link.url),
          borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
          child: Container(
            padding: EdgeInsets.all(Dimensions.space12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: Dimensions.iconSmall,
                  color: color,
                ),
                SizedBox(width: Dimensions.space8),
                Text(
                  link.platform,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
