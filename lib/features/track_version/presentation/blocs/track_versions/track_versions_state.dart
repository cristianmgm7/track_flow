import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

abstract class TrackVersionsState extends Equatable {
  const TrackVersionsState();

  @override
  List<Object?> get props => [];
}

class TrackVersionsInitial extends TrackVersionsState {
  const TrackVersionsInitial();
}

class TrackVersionsLoading extends TrackVersionsState {
  const TrackVersionsLoading();
}

class TrackVersionsLoaded extends TrackVersionsState {
  final List<TrackVersion> versions;
  final TrackVersionId? activeVersionId;
  const TrackVersionsLoaded({required this.versions, this.activeVersionId});

  @override
  List<Object?> get props => [versions, activeVersionId];
}

class TrackVersionsError extends TrackVersionsState {
  final String message;
  const TrackVersionsError(this.message);

  @override
  List<Object?> get props => [message];
}
