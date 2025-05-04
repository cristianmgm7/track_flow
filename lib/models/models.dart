class User {
  final String id;
  final String name;
  final String? avatar;

  User({required this.id, required this.name, this.avatar});
}

class Activity {
  final String id;
  final User user;
  final String action;
  final String target;
  final String time;

  Activity({
    required this.id,
    required this.user,
    required this.action,
    required this.target,
    required this.time,
  });
}

class Project {
  final String id;
  final String title;
  final String genre;
  final int progress;
  final String? dueDate;
  final List<User> team;

  Project({
    required this.id,
    required this.title,
    required this.genre,
    required this.progress,
    this.dueDate,
    required this.team,
  });
}
