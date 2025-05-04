import '../models/models.dart';

final List<User> users = [
  User(id: "1", name: "Emma Wilson", avatar: "assets/placeholder.png"),
  User(id: "2", name: "Alex Johnson", avatar: "assets/placeholder.png"),
  User(id: "3", name: "Taylor Smith", avatar: "assets/placeholder.png"),
  User(id: "4", name: "Jordan Lee"),
];

final List<Project> projects = [
  Project(
    id: "1",
    title: "Summer Vibes EP",
    genre: "Pop",
    progress: 65,
    dueDate: "Aug 15",
    team: [users[0], users[1], users[2], users[3]],
  ),
  Project(
    id: "2",
    title: "Midnight Sessions",
    genre: "R&B",
    progress: 30,
    dueDate: "Sep 22",
    team: [users[0], users[1]],
  ),
  Project(
    id: "3",
    title: "Acoustic Covers",
    genre: "Acoustic",
    progress: 80,
    team: [users[2], users[3]],
  ),
];

final List<Activity> activities = [
  Activity(
    id: "1",
    user: users[0],
    action: "uploaded a new track to",
    target: "Summer Vibes EP",
    time: "10 minutes ago",
  ),
  Activity(
    id: "2",
    user: users[1],
    action: "completed a task in",
    target: "Midnight Sessions",
    time: "2 hours ago",
  ),
  Activity(
    id: "3",
    user: users[2],
    action: "added a note to",
    target: "Acoustic Covers",
    time: "Yesterday at 7:30 PM",
  ),
];
