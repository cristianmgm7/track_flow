import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/services/audio_player/audio_player_state.dart';
import 'package:trackflow/core/services/audio_player/audioplayer_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/components/pro_audio_player.dart';

class AudioPlayerScreen extends StatelessWidget {
  final ScrollController? scrollController;

  const AudioPlayerScreen({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state is! AudioPlayerActiveState) return const SizedBox.shrink();
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // PRO AUDIO PLAYER
                ProAudioPlayer(scrollController: scrollController),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: 10, // Placeholder
                    itemBuilder:
                        (context, index) => ListTile(
                          title: Text(
                            'Acción o elemento #$index',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
