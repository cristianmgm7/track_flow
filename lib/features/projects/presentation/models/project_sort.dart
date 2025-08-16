import 'package:flutter/material.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

enum ProjectSort { lastActivityDesc, createdDesc, nameAsc, nameDesc }

extension ProjectSortX on ProjectSort {
  String get label => switch (this) {
    ProjectSort.lastActivityDesc => 'Last activity',
    ProjectSort.createdDesc => 'Created (newest)',
    ProjectSort.nameAsc => 'Name A–Z',
    ProjectSort.nameDesc => 'Name Z–A',
  };

  IconData get icon => switch (this) {
    ProjectSort.lastActivityDesc => Icons.update_rounded,
    ProjectSort.createdDesc => Icons.schedule_rounded,
    ProjectSort.nameAsc => Icons.sort_by_alpha_rounded,
    ProjectSort.nameDesc => Icons.sort_rounded,
  };
}

int compareProjectsBySort(Project a, Project b, ProjectSort sort) {
  final DateTime aActivity = a.updatedAt ?? a.createdAt;
  final DateTime bActivity = b.updatedAt ?? b.createdAt;
  String name(Project p) => p.name.value.fold((l) => '', (r) => r);
  switch (sort) {
    case ProjectSort.lastActivityDesc:
      return bActivity.compareTo(aActivity);
    case ProjectSort.createdDesc:
      return b.createdAt.compareTo(a.createdAt);
    case ProjectSort.nameAsc:
      return name(a).toLowerCase().compareTo(name(b).toLowerCase());
    case ProjectSort.nameDesc:
      return name(b).toLowerCase().compareTo(name(a).toLowerCase());
  }
}
