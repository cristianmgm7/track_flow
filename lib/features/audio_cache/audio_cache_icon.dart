import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/audio_cache_cubit.dart';
import 'package:trackflow/features/audio_cache/audio_cache_state.dart';

class AudioCacheIcon extends StatelessWidget {
  final String remoteUrl;

  const AudioCacheIcon({super.key, required this.remoteUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCacheCubit, AudioCacheState>(
      builder: (context, state) {
        if (state is AudioCacheLoading) {
          return const CircularProgressIndicator();
        } else if (state is AudioCacheProgress) {
          return CircularProgressIndicator(value: state.progress);
        } else if (state is AudioCacheDownloaded) {
          return const Icon(Icons.check_circle, color: Colors.green);
        } else if (state is AudioCacheFailure) {
          return const Icon(Icons.error, color: Colors.red);
        } else {
          return IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              context.read<AudioCacheCubit>().load(remoteUrl);
            },
          );
        }
      },
    );
  }
}
