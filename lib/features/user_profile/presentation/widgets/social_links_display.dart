import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        return FontAwesomeIcons.instagram;
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'x':
        return FontAwesomeIcons.xTwitter;
      case 'spotify':
        return FontAwesomeIcons.spotify;
      case 'soundcloud':
        return FontAwesomeIcons.soundcloud;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      case 'apple music':
        return FontAwesomeIcons.itunes;
      case 'bandcamp':
        return FontAwesomeIcons.bandcamp;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'github':
        return FontAwesomeIcons.github;
      case 'discord':
        return FontAwesomeIcons.discord;
      case 'twitch':
        return FontAwesomeIcons.twitch;
      default:
        return FontAwesomeIcons.link;
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
