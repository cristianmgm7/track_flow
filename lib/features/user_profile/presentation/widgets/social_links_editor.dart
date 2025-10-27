import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class SocialLinksEditor extends StatefulWidget {
  final List<SocialLink> initialLinks;
  final ValueChanged<List<SocialLink>> onChanged;

  const SocialLinksEditor({
    super.key,
    required this.initialLinks,
    required this.onChanged,
  });

  @override
  State<SocialLinksEditor> createState() => _SocialLinksEditorState();
}

class _SocialLinksEditorState extends State<SocialLinksEditor> {
  late List<_SocialLinkEntry> _entries;

  final List<String> _platforms = [
    'Instagram',
    'Twitter',
    'Spotify',
    'SoundCloud',
    'YouTube',
    'TikTok',
    'Apple Music',
    'Bandcamp',
    'Facebook',
  ];

  @override
  void initState() {
    super.initState();
    _entries = widget.initialLinks
        .map((link) => _SocialLinkEntry(
              platform: link.platform,
              url: link.url,
              controller: TextEditingController(text: link.url),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  void _addLink() {
    setState(() {
      _entries.add(_SocialLinkEntry(
        platform: _platforms.first,
        url: '',
        controller: TextEditingController(),
      ));
    });
  }

  void _removeLink(int index) {
    setState(() {
      _entries[index].controller.dispose();
      _entries.removeAt(index);
      _notifyChange();
    });
  }

  void _updatePlatform(int index, String platform) {
    setState(() {
      _entries[index].platform = platform;
      _notifyChange();
    });
  }

  void _updateUrl(int index, String url) {
    _entries[index].url = url;
    _notifyChange();
  }

  void _notifyChange() {
    final links = _entries
        .where((e) => e.url.trim().isNotEmpty)
        .map((e) => SocialLink(
              platform: e.platform,
              url: e.url.trim(),
            ))
        .toList();
    widget.onChanged(links);
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
      return 'Invalid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Social Media',
          style: AppTextStyle.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: Dimensions.space8),

        if (_entries.isEmpty)
          Text(
            'No social links added yet',
            style: AppTextStyle.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          ..._entries.asMap().entries.map((entry) {
            final index = entry.key;
            final linkEntry = entry.value;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Platform Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: linkEntry.platform,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _platforms.map((platform) {
                      return DropdownMenuItem(
                        value: platform,
                        child: Text(
                          platform,
                          style: AppTextStyle.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updatePlatform(index, value);
                      }
                    },
                  ),
                ),
            
                SizedBox(width: Dimensions.space8),
            
                // URL Field
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: linkEntry.controller,
                    decoration: InputDecoration(
                      hintText: 'URL',
                      hintStyle: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: AppTextStyle.bodySmall,
                    keyboardType: TextInputType.url,
                    validator: _validateUrl,
                    onChanged: (value) => _updateUrl(index, value),
                  ),
                ),
            
                SizedBox(width: Dimensions.space8),
            
                // Remove Button
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                  onPressed: () => _removeLink(index),
                  iconSize: 20,
                ),
              ],
            );
          }),

        SizedBox(height: Dimensions.space8),

        // Add Link Button
        TextButton.icon(
          onPressed: _addLink,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: Text(
            'Add Social Link',
            style: AppTextStyle.labelMedium,
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _SocialLinkEntry {
  String platform;
  String url;
  final TextEditingController controller;

  _SocialLinkEntry({
    required this.platform,
    required this.url,
    required this.controller,
  });
}
