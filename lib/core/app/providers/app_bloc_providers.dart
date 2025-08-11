import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/user_profile_bloc.dart';
import 'package:trackflow/features/navegation/presentation/cubit/navigation_cubit.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/audio_track/presentation/bloc/audio_track_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/bloc/audio_comment_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart';
import 'package:trackflow/core/sync/presentation/cubit/sync_status_cubit.dart';

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
      BlocProvider<AudioCommentBloc>(
        create: (context) => sl<AudioCommentBloc>(),
      ),
      BlocProvider<AudioPlayerBloc>(create: (context) => sl<AudioPlayerBloc>()),
      BlocProvider<AudioWaveformBloc>(
        create: (context) => sl<AudioWaveformBloc>(),
      ),
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
}
