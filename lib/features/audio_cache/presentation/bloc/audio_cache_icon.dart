import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_cubit.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_state.dart';

class AudioCacheIcon extends StatefulWidget {
  final String remoteUrl;
  final bool autoLoad;
  final VoidCallback? onDownloaded;

  const AudioCacheIcon({
    super.key,
    required this.remoteUrl,
    this.autoLoad = false,
    this.onDownloaded,
  });

  @override
  State<AudioCacheIcon> createState() => _AudioCacheIconState();
}

class _AudioCacheIconState extends State<AudioCacheIcon> {
  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      context.read<AudioCacheCubit>().load(widget.remoteUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioCacheCubit, AudioCacheState>(
      listener: (context, state) {
        if (state is AudioCacheDownloaded && widget.onDownloaded != null) {
          widget.onDownloaded!();
        }
      },
      builder: (context, state) {
        if (state is AudioCacheLoading) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (state is AudioCacheProgress) {
          return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 2,
            ),
          );
        } else if (state is AudioCacheDownloaded) {
          return const Icon(Icons.check_circle, color: Colors.green);
        } else if (state is AudioCacheFailure) {
          return const Icon(Icons.error, color: Colors.red);
        } else {
          return IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              context.read<AudioCacheCubit>().load(widget.remoteUrl);
            },
          );
        }
      },
    );
  }
}
