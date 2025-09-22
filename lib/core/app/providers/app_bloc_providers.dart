import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart';
import 'package:trackflow/features/waveform/presentation/bloc/waveform_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/audio_context/presentation/bloc/audio_context_bloc.dart';
import 'package:trackflow/core/notifications/presentation/blocs/watcher/notification_watcher_bloc.dart';
import 'package:trackflow/features/invitations/presentation/blocs/watcher/project_invitation_watcher_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/track_cache_bloc.dart';
import 'package:trackflow/features/track_version/presentation/blocs/track_versions/track_versions_bloc.dart';
import 'package:trackflow/features/track_version/presentation/cubit/track_detail_cubit.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaborators_event.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

/// Factory for creating BLoC providers following SOLID principles
///
/// This class organizes BLoC providers into logical groups and provides
/// a clean interface for managing dependencies at different app levels.
class AppBlocProviders {
  /// Get all BLoC providers for the main app
  static List<BlocProvider> getAllProviders() {
    return [
      ...getCoreProviders(),
      ...getAuthProviders(),
      ...getMainAppProviders(),
      ...getAudioProviders(),
    ];
  }

  /// Get core app providers (always needed for app initialization)
  static List<BlocProvider> getCoreProviders() {
    return [
      BlocProvider<AppFlowBloc>(create: (context) => sl<AppFlowBloc>()),
      BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
      BlocProvider<NavigationCubit>(create: (context) => sl<NavigationCubit>()),
      BlocProvider<SyncStatusCubit>(create: (context) => sl<SyncStatusCubit>()),
    ];
  }

  /// Get authentication flow providers
  static List<BlocProvider> getAuthProviders() {
    return [
      BlocProvider<OnboardingBloc>(create: (context) => sl<OnboardingBloc>()),
      BlocProvider<UserProfileBloc>(create: (context) => sl<UserProfileBloc>()),
      BlocProvider<MagicLinkBloc>(create: (context) => sl<MagicLinkBloc>()),
    ];
  }

  /// Get main app providers (dashboard and project management features)
  static List<BlocProvider> getMainAppProviders() {
    return [];
  }

  /// Get audio-related providers
  static List<BlocProvider> getAudioProviders() {
    return [
      BlocProvider<AudioTrackBloc>(create: (context) => sl<AudioTrackBloc>()),
      BlocProvider<AudioPlayerBloc>(
        create:
            (context) =>
                sl<AudioPlayerBloc>()
                  ..add(const AudioPlayerInitializeRequested()),
      ),
      BlocProvider<WaveformBloc>(create: (context) => sl<WaveformBloc>()),
    ];
  }

  /// Get providers for specific app states
  static List<BlocProvider> getAuthFlowProviders() {
    return [...getCoreProviders(), ...getAuthProviders()];
  }

  static List<BlocProvider> getMainAppFlowProviders() {
    return [
      ...getCoreProviders(),
      ...getMainAppProviders(),
      ...getAudioProviders(),
    ];
  }

  /// Get providers for a specific feature
  static List<BlocProvider> getFeatureProviders(String feature) {
    switch (feature.toLowerCase()) {
      case 'auth':
        return getAuthProviders();
      case 'audio':
        return getAudioProviders();
      case 'main':
        return getMainAppProviders();
      case 'core':
        return getCoreProviders();
      default:
        return [];
    }
  }

  /// Get providers for the main app shell (dashboard, projects, etc.)
  static List<BlocProvider> getMainShellProviders() {
    return [
      BlocProvider<ProjectsBloc>(create: (_) => sl<ProjectsBloc>()),
      BlocProvider<AudioContextBloc>(create: (_) => sl<AudioContextBloc>()),
      BlocProvider<NotificationWatcherBloc>(
        create: (_) => sl<NotificationWatcherBloc>(),
      ),
      BlocProvider<ProjectInvitationWatcherBloc>(
        create: (_) => sl<ProjectInvitationWatcherBloc>(),
      ),
    ];
  }

  /// Get providers for track detail screen
  static List<BlocProvider> getTrackDetailProviders() {
    return [
      BlocProvider<TrackCacheBloc>(create: (context) => sl<TrackCacheBloc>()),
      BlocProvider<AudioCommentBloc>(
        create: (context) => sl<AudioCommentBloc>(),
      ),
      BlocProvider<TrackVersionsBloc>(
        create: (context) => sl<TrackVersionsBloc>(),
      ),
      BlocProvider<TrackDetailCubit>(
        create: (context) => sl<TrackDetailCubit>(),
      ),
    ];
  }

  /// Get providers for artist profile screen
  static List<BlocProvider> getArtistProfileProviders() {
    return [
      BlocProvider<UserProfileBloc>(create: (_) => sl<UserProfileBloc>()),
    ];
  }

  /// Get providers for project details screen
  static List<BlocProvider> getProjectDetailsProviders(Project project) {
    return [
      BlocProvider<ProjectDetailBloc>(create: (_) => sl<ProjectDetailBloc>()),
      BlocProvider<ManageCollaboratorsBloc>(
        create:
            (_) =>
                sl<ManageCollaboratorsBloc>()
                  ..add(WatchCollaborators(projectId: project.id)),
      ),
    ];
  }

  /// Get providers for manage collaborators screen
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
}
