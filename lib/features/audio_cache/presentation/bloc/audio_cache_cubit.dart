import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_cache/presentation/bloc/audio_cache_state.dart';
import 'package:trackflow/features/audio_cache/domain/usecases/get_cached_audio_path.dart';

@injectable
class AudioCacheCubit extends Cubit<AudioCacheState> {
  final GetCachedAudioPath getCachedAudioPath;

  AudioCacheCubit(this.getCachedAudioPath) : super(AudioCacheInitial());

  Future<void> load(String remoteUrl) async {
    emit(AudioCacheLoading());
    try {
      final localPath = await getCachedAudioPath(
        remoteUrl,
        onProgress: (progress) {
          emit(AudioCacheProgress(progress));
        },
      );
      emit(AudioCacheDownloaded(localPath));
    } catch (e) {
      emit(AudioCacheFailure(e.toString()));
    }
  }

  void checkStatus(String remoteUrl) async {
    emit(AudioCacheLoading());
    try {
      final localPath = await getCachedAudioPath(remoteUrl);
      if (localPath.isNotEmpty) {
        emit(AudioCacheDownloaded(localPath));
      } else {
        emit(AudioCacheInitial()); // O un estado específico de no descargado
      }
    } catch (_) {
      emit(AudioCacheInitial());
    }
  }
}
