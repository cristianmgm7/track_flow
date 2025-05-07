import 'package:trackflow/core/models/models.dart';

// Mock data for development
final List<User> users = [
  User(id: '1', name: 'John Doe', avatar: 'assets/images/avatars/john.png'),
  User(id: '2', name: 'Jane Smith', avatar: 'assets/images/avatars/jane.png'),
  User(id: '3', name: 'Mike Johnson', avatar: 'assets/images/avatars/mike.png'),
];

final List<Project> projects = [
  Project(
    id: '1',
    title: 'Summer Hit 2024',
    genre: 'Pop',
    progress: 75,
    dueDate: '2024-06-15',
    team: [users[0], users[1]],
  ),
  Project(
    id: '2',
    title: 'Rock Album',
    genre: 'Rock',
    progress: 45,
    dueDate: '2024-08-01',
    team: [users[1], users[2]],
  ),
  Project(
    id: '3',
    title: 'Hip Hop Mix',
    genre: 'Hip Hop',
    progress: 90,
    dueDate: '2024-05-30',
    team: [users[0], users[2]],
  ),
];

final List<Activity> activities = [
  Activity(
    id: '1',
    user: users[0],
    action: 'updated',
    target: 'Summer Hit 2024',
    time: '2 hours ago',
  ),
  Activity(
    id: '2',
    user: users[1],
    action: 'commented on',
    target: 'Rock Album',
    time: '5 hours ago',
  ),
  Activity(
    id: '3',
    user: users[2],
    action: 'uploaded files to',
    target: 'Hip Hop Mix',
    time: '1 day ago',
  ),
];
