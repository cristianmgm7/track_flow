import 'package:flutter/material.dart';

class CommentsTab extends StatelessWidget {
  final String projectId;
  const CommentsTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Comments for project: $projectId'));
  }
}
