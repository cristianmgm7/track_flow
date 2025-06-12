import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/audio_player_cubit.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
      builder: (context, state) {
        if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
          return Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    state.url.split('/').last,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    state is AudioPlayerPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (state is AudioPlayerPlaying) {
                      context.read<AudioPlayerCubit>().pause();
                    } else {
                      context.read<AudioPlayerCubit>().resume();
                    }
                  },
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink(); // nothing
      },
    );
  }
}
