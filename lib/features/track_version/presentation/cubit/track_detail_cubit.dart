import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// State for managing track detail screen UI
class TrackDetailState extends Equatable {
  final TrackVersionId? activeVersionId;

  const TrackDetailState({this.activeVersionId});

  TrackDetailState copyWith({TrackVersionId? activeVersionId}) {
    return TrackDetailState(
      activeVersionId: activeVersionId ?? this.activeVersionId,
    );
  }

  @override
  List<Object?> get props => [activeVersionId];
}

/// Events for track detail screen
abstract class TrackDetailEvent extends Equatable {
  const TrackDetailEvent();

  @override
  List<Object?> get props => [];
}

class SetActiveVersionRequested extends TrackDetailEvent {
  final TrackVersionId versionId;

  const SetActiveVersionRequested(this.versionId);

  @override
  List<Object?> get props => [versionId];
}

class StartRenamingRequested extends TrackDetailEvent {
  const StartRenamingRequested();
}

class FinishRenamingRequested extends TrackDetailEvent {
  final String? newLabel;

  const FinishRenamingRequested(this.newLabel);

  @override
  List<Object?> get props => [newLabel];
}

/// Cubit to manage track detail screen state
class TrackDetailCubit extends Cubit<TrackDetailState> {
  TrackDetailCubit(TrackVersionId initialVersionId)
    : super(TrackDetailState(activeVersionId: initialVersionId));

  void setActiveVersion(TrackVersionId versionId) {
    emit(state.copyWith(activeVersionId: versionId));
  }

  void startRenaming() {
    emit(state.copyWith());
  }

  void finishRenaming(String? newLabel) {
    emit(state.copyWith());
    // Here we could dispatch rename if needed
  }
}
