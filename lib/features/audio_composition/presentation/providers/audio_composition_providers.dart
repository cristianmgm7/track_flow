import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../audio_context/presentation/bloc/audio_context_cubit.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';

/// Audio composition providers for integrating pure audio with business context
/// Provides both BLoCs needed for the collaborative audio screen
class AudioCompositionProviders extends StatelessWidget {
  const AudioCompositionProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Pure audio player BLoC - handles only audio operations
        BlocProvider<AudioPlayerBloc>(
          create: (context) => GetIt.instance<AudioPlayerBloc>(),
        ),

        // Audio context cubit - handles business context information
        BlocProvider<AudioContextCubit>(
          create:
              (context) =>
                  AudioContextCubit(audioContextService: GetIt.instance()),
        ),
      ],
      child: child,
    );
  }
}

/// Usage example:
/// ```dart
/// AudioCompositionProviders(
///   child: CollaborativeAudioScreen(),
/// )
/// ```
/// 
/// This composition pattern demonstrates:
/// 1. Clean separation between pure audio and business context
/// 2. Independent BLoCs that can work together through UI composition
/// 3. SOLID principles in action - each BLoC has single responsibility
/// 4. Easy testing - each BLoC can be tested independently