import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
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

/// Cubit to manage track detail screen state
@injectable
class TrackDetailCubit extends Cubit<TrackDetailState> {
  TrackDetailCubit() : super(const TrackDetailState());

  void setActiveVersion(TrackVersionId versionId) {
    emit(state.copyWith(activeVersionId: versionId));
  }
}
