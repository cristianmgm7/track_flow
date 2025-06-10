import 'package:flutter/material.dart';

class TracksTab extends StatelessWidget {
  final String projectId;
  const TracksTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Tracks for project: $projectId'));
  }
}
