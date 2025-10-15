import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// State for managing version selection in the track detail screen
class VersionSelectorState extends Equatable {
  final TrackVersionId? selectedVersionId;

  const VersionSelectorState({this.selectedVersionId});

  VersionSelectorState copyWith({TrackVersionId? selectedVersionId}) {
    return VersionSelectorState(
      selectedVersionId: selectedVersionId ?? this.selectedVersionId,
    );
  }

  @override
  List<Object?> get props => [selectedVersionId];
}

/// Cubit to manage version selection in the track detail screen
/// This is UI-only state and does not persist to the database
@injectable
class VersionSelectorCubit extends Cubit<VersionSelectorState> {
  VersionSelectorCubit() : super(const VersionSelectorState());

  /// Set the selected version (UI-only, does not persist)
  void selectVersion(TrackVersionId versionId) {
    emit(state.copyWith(selectedVersionId: versionId));
  }

  /// Initialize with a specific version
  void initialize(TrackVersionId versionId) {
    emit(VersionSelectorState(selectedVersionId: versionId));
  }
}
