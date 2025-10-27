import 'package:flutter/material.dart';

/// Centralized Icon System for TrackFlow
///
/// Provides consistent iconography across the application
/// and eliminates hardcoded icon references.
class AppIcons {
  // Navigation icons
  static const IconData home = Icons.home_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData profile = Icons.person_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData back = Icons.arrow_back_ios_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData more = Icons.more_horiz_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData preview = Icons.visibility_rounded;

  // Audio icons
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData stop = Icons.stop_rounded;
  static const IconData skipNext = Icons.skip_next_rounded;
  static const IconData skipPrevious = Icons.skip_previous_rounded;
  static const IconData volume = Icons.volume_up_rounded;
  static const IconData volumeOff = Icons.volume_off_rounded;
  static const IconData musicNote = Icons.music_note_rounded;
  static const IconData waveform = Icons.graphic_eq_rounded;
  static const IconData microphone = Icons.mic_rounded;
  static const IconData headphones = Icons.headphones_rounded;

  // Project icons
  static const IconData project = Icons.folder_rounded;
  static const IconData newProject = Icons.create_new_folder_rounded;
  static const IconData collaborators = Icons.people_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;
  static const IconData cloud = Icons.cloud_rounded;
  static const IconData local = Icons.storage_rounded;

  // User icons
  static const IconData user = Icons.person_rounded;
  static const IconData userAdd = Icons.person_add_rounded;
  static const IconData userRemove = Icons.person_remove_rounded;
  static const IconData avatar = Icons.account_circle_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData gallery = Icons.photo_library_rounded;

  // Action icons
  static const IconData save = Icons.save_rounded;
  static const IconData cancel = Icons.cancel_rounded;
  static const IconData confirm = Icons.check_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData sync = Icons.sync_rounded;
  static const IconData favorite = Icons.favorite_rounded;
  static const IconData favoriteBorder = Icons.favorite_border_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData starBorder = Icons.star_border_rounded;

  // Status icons
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData loading = Icons.hourglass_empty_rounded;
  static const IconData done = Icons.done_rounded;
  static const IconData pending = Icons.schedule_rounded;

  // Communication icons
  static const IconData comment = Icons.comment_rounded;
  static const IconData message = Icons.message_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData email = Icons.email_rounded;
  static const IconData phone = Icons.phone_rounded;
  static const IconData link = Icons.link_rounded;
  static const IconData copy = Icons.copy_rounded;

  // Media icons
  static const IconData image = Icons.image_rounded;
  static const IconData video = Icons.video_library_rounded;
  static const IconData audio = Icons.audiotrack_rounded;
  static const IconData file = Icons.insert_drive_file_rounded;
  static const IconData folder = Icons.folder_rounded;
  static const IconData playlist = Icons.playlist_play_rounded;

  // UI icons
  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;
  static const IconData expand = Icons.expand_more_rounded;
  static const IconData collapse = Icons.expand_less_rounded;
  static const IconData drag = Icons.drag_handle_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData searchClear = Icons.clear_rounded;

  // Social icons
  static const IconData google = Icons.g_mobiledata_rounded;
  static const IconData facebook = Icons.facebook_rounded;
  static const IconData twitter = Icons.flutter_dash; // Placeholder for twitter
  static const IconData instagram = Icons.camera_alt_rounded;
  static const IconData linkedin = Icons.work_rounded;

  // Utility icons
  static const IconData help = Icons.help_rounded;
  static const IconData about = Icons.info_rounded;
  static const IconData privacy = Icons.privacy_tip_rounded;
  static const IconData terms = Icons.description_rounded;
  static const IconData support = Icons.support_agent_rounded;
  static const IconData feedback = Icons.feedback_rounded;
  static const IconData bug = Icons.bug_report_rounded;

  // Icon size constants
  static const double sizeSmall = 16.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 32.0;
  static const double sizeXLarge = 48.0;

  // Get icon by name (for dynamic icon loading)
  static IconData? getIconByName(String name) {
    switch (name.toLowerCase()) {
      case 'home':
        return home;
      case 'search':
        return search;
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'back':
        return back;
      case 'close':
        return close;
      case 'add':
        return add;
      case 'edit':
        return edit;
      case 'delete':
        return delete;
      case 'play':
        return play;
      case 'pause':
        return pause;
      case 'stop':
        return stop;
      case 'music':
        return musicNote;
      case 'user':
        return user;
      case 'save':
        return save;
      case 'cancel':
        return cancel;
      case 'confirm':
        return confirm;
      case 'success':
        return success;
      case 'error':
        return error;
      case 'warning':
        return warning;
      case 'info':
        return info;
      case 'loading':
        return loading;
      case 'comment':
        return comment;
      case 'notification':
        return notification;
      case 'image':
        return image;
      case 'video':
        return video;
      case 'audio':
        return audio;
      case 'file':
        return file;
      case 'folder':
        return folder;
      case 'visibility':
        return visibility;
      case 'visibility_off':
        return visibilityOff;
      case 'expand':
        return expand;
      case 'collapse':
        return collapse;
      case 'sort':
        return sort;
      case 'filter':
        return filter;
      case 'help':
        return help;
      case 'about':
        return about;
      default:
        return null;
    }
  }

  // Get icon size by type
  static double getIconSize(IconSize size) {
    switch (size) {
      case IconSize.small:
        return sizeSmall;
      case IconSize.medium:
        return sizeMedium;
      case IconSize.large:
        return sizeLarge;
      case IconSize.xlarge:
        return sizeXLarge;
    }
  }
}

enum IconSize { small, medium, large, xlarge }

/// Icon Usage Tracker
class IconUsageTracker {
  static final Map<String, int> _usageCount = {};

  static void trackUsage(String iconName) {
    _usageCount[iconName] = (_usageCount[iconName] ?? 0) + 1;
  }

  static int getUsageCount(String iconName) {
    return _usageCount[iconName] ?? 0;
  }

  static Map<String, int> getMostUsedIcons() {
    final sorted =
        _usageCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}
