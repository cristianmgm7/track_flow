import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/features/audio_recording/presentation/bloc/recording_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/core/sync/presentation/bloc/sync_bloc.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/cubit/version_selector_cubit.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/voice_memos/presentation/bloc/voice_memo_bloc.dart';
import 'package:trackflow/features/voice_memos/presentation/bloc/voice_memo_event.dart';

/// Centralized BLoC provider management for the entire app
///
/// This class provides a single source of truth for all BLoC providers,
/// organized by scope and usage. Instead of scattered provider definitions
/// across screens and routes, everything is defined here.
///
/// Usage:
/// - `getAllProviders()` - Main app providers (use in MyApp)
/// - Scoped providers - Use in specific routes/screens as needed
class AppBlocProviders {
  // ============================================================================
  // MAIN APP PROVIDERS - Used by MyApp root
  // ============================================================================

  /// Get ALL providers for the main app root
  /// This is the ONLY method you need to call in MyApp
  static List<BlocProvider> getMainAppProviders() {
    return [
      // Core infrastructure (always needed)
      BlocProvider<AppFlowBloc>(create: (_) => sl<AppFlowBloc>()),
      BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      BlocProvider<NavigationCubit>(create: (_) => sl<NavigationCubit>()),
      BlocProvider<SyncBloc>(create: (_) => sl<SyncBloc>()),

      // Auth flow
      BlocProvider<OnboardingBloc>(create: (_) => sl<OnboardingBloc>()),
      BlocProvider<UserProfileBloc>(create: (_) => sl<UserProfileBloc>()),
      BlocProvider<MagicLinkBloc>(create: (_) => sl<MagicLinkBloc>()),

      // Audio system (global)
      BlocProvider<AudioTrackBloc>(create: (_) => sl<AudioTrackBloc>()),
      BlocProvider<AudioPlayerBloc>(
        create:
            (_) =>
                sl<AudioPlayerBloc>()
                  ..add(const AudioPlayerInitializeRequested()),
      ),
      BlocProvider<WaveformBloc>(create: (_) => sl<WaveformBloc>()),
      BlocProvider<AudioContextBloc>(create: (_) => sl<AudioContextBloc>()),
      BlocProvider<RecordingBloc>(create: (_) => sl<RecordingBloc>()),

      // Voice memos (global)
      BlocProvider<VoiceMemoBloc>(
        create:
            (_) =>
                sl<VoiceMemoBloc>()
                  ..add(const WatchVoiceMemosRequested()),
      ),
    ];
  }

  // ============================================================================
  // SCOPED PROVIDERS - Used in specific routes/screens
  // ============================================================================

  /// Providers for main app shell (dashboard, projects list)
  static List<BlocProvider> getMainShellProviders() {
    return [
      BlocProvider<ProjectsBloc>(create: (_) => sl<ProjectsBloc>()),
      BlocProvider<NotificationWatcherBloc>(
        create: (_) => sl<NotificationWatcherBloc>(),
      ),
      BlocProvider<ProjectInvitationWatcherBloc>(
        create: (_) => sl<ProjectInvitationWatcherBloc>(),
      ),
    ];
  }

  /// Providers for track detail screen
  static List<BlocProvider> getTrackDetailProviders() {
    return [
      BlocProvider<TrackCacheBloc>(create: (_) => sl<TrackCacheBloc>()),
      BlocProvider<AudioCommentBloc>(create: (_) => sl<AudioCommentBloc>()),
      BlocProvider<TrackVersionsBloc>(create: (_) => sl<TrackVersionsBloc>()),
      BlocProvider<VersionSelectorCubit>(create: (_) => sl<VersionSelectorCubit>()),
    ];
  }

  /// Providers for project detail screen
  static List<BlocProvider> getProjectDetailsProviders(Project project) {
    return [
      BlocProvider<ProjectDetailBloc>(create: (_) => sl<ProjectDetailBloc>()),
      BlocProvider<ManageCollaboratorsBloc>(
        create:
            (_) =>
                sl<ManageCollaboratorsBloc>()
                  ..add(WatchCollaborators(projectId: project.id)),
      ),
      BlocProvider<PlaylistBloc>(create: (_) => sl<PlaylistBloc>()),
    ];
  }

  /// Providers for manage collaborators screen
  static List<BlocProvider> getManageCollaboratorsProviders(Project project) {
    return [
      BlocProvider<ManageCollaboratorsBloc>(
        create:
            (_) =>
                sl<ManageCollaboratorsBloc>()
                  ..add(WatchCollaborators(projectId: project.id)),
      ),
    ];
  }

  /// Providers for artist/user profile screen
  static List<BlocProvider> getArtistProfileProviders() {
    return [
      BlocProvider<UserProfileBloc>(create: (_) => sl<UserProfileBloc>()),
    ];
  }

}
