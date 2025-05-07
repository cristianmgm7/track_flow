import 'package:flutter/material.dart';
import 'package:trackflow/core/models/models.dart';
import 'package:trackflow/core/data/data.dart';
import 'package:trackflow/features/settings/presentation/pages/seetings_acount.dart';
import 'package:trackflow/core/constants/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Overview", style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatsCard(
                  context,
                  "Projects",
                  projects.length.toString(),
                  Icons.music_note,
                ),
                _buildStatsCard(
                  context,
                  "Team Members",
                  users.length.toString(),
                  Icons.group,
                ),
              ],
            ),
            SizedBox(height: 16),
            // Active Projects
            Text(
              "Active Projects on TrackFlow",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Column(
              children:
                  projects
                      .map((project) => _buildProjectCard(context, project))
                      .toList(),
            ),
            SizedBox(height: 16),
            // Recent Activity
            Text(
              "Recent Activity",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Column(
              children:
                  activities
                      .map((activity) => _buildActivityCard(context, activity))
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      child: ListTile(
        title: Text(project.title),
        subtitle: Text(
          "Genre: ${project.genre} | Progress: ${project.progress}%",
        ),
        trailing: Text("Due: ${project.dueDate ?? "N/A"}"),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            activity.user.avatar ?? "assets/placeholder.png",
          ),
        ),
        title: Text(
          "${activity.user.name} ${activity.action} ${activity.target}",
        ),
        subtitle: Text(activity.time),
      ),
    );
  }
}
