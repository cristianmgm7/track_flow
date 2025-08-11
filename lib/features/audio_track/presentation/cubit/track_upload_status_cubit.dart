import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/usecases/watch_track_upload_status_usecase.dart';

part 'track_upload_status_state.dart';

@injectable
class TrackUploadStatusCubit extends Cubit<TrackUploadStatusState> {
  final WatchTrackUploadStatusUseCase _watchUseCase;
  StreamSubscription<TrackUploadStatus>? _subscription;

  TrackUploadStatusCubit(this._watchUseCase)
    : super(const TrackUploadStatusState.initial());

  void watch(AudioTrackId trackId) {
    _subscription?.cancel();
    emit(const TrackUploadStatusState.initial());
    _subscription = _watchUseCase(trackId).listen((status) {
      emit(TrackUploadStatusState(status));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
