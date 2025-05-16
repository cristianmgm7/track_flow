import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';

class ProjectPresenter {
  static String getDisplayStatus(Project project) {
    return project.statusValue.replaceAll('_', ' ').toUpperCase();
  }

  static String getFormattedDuration(Project project) {
    final duration = DateTime.now().difference(project.createdAt);
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inMinutes} minutes';
    }
  }

  static double getCompletionPercentage(Project project) {
    switch (project.statusValue) {
      case ProjectStatus.draft:
        return 0.0;
      case ProjectStatus.inProgress:
        return 50.0;
      case ProjectStatus.finished:
        return 100.0;
      default:
        return 0.0;
    }
  }
}
