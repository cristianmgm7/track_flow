sealed class AudioCacheState {}

class AudioCacheInitial extends AudioCacheState {}

class AudioCacheLoading extends AudioCacheState {}

class AudioCacheProgress extends AudioCacheState {
  final double progress; // 0.0 a 1.0
  AudioCacheProgress(this.progress);
}

class AudioCacheDownloaded extends AudioCacheState {
  final String localPath;
  AudioCacheDownloaded(this.localPath);
}

class AudioCacheFailure extends AudioCacheState {
  final String error;
  AudioCacheFailure(this.error);
}
