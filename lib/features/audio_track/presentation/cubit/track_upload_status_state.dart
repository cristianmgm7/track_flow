part of 'track_upload_status_cubit.dart';

class TrackUploadStatusState extends Equatable {
  final TrackUploadStatus status;

  const TrackUploadStatusState(this.status);

  const TrackUploadStatusState.initial() : status = TrackUploadStatus.none;

  @override
  List<Object?> get props => [status];
}
