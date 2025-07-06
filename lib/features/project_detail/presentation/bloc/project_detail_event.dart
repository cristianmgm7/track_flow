import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();
  @override
  List<Object?> get props => [];
}

class WatchProjectDetail extends ProjectDetailEvent {
  final Project project;
  const WatchProjectDetail({required this.project});
  @override
  List<Object?> get props => [project];
}
// Add more events as needed for the detail view 