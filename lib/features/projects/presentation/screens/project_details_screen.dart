import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // 0 = Tasks, 1 = Comments
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Project Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Audio player placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Audio Player (placeholder)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Toggle buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabButton(
                    label: 'Tasks',
                    selected: _selectedTab == 0,
                    color: const Color(0xFFF25BB4),
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 16),
                  _TabButton(
                    label: 'Comments',
                    selected: _selectedTab == 1,
                    color: const Color(0xFF6DD3FF),
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Content area
            Expanded(
              child:
                  _selectedTab == 0
                      ? _TasksListPlaceholder()
                      : _CommentsListPlaceholder(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _TasksListPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder:
          (context, index) => Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Task ${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
    );
  }
}

class _CommentsListPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder:
          (context, index) => Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(32),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Comment ${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
    );
  }
}
