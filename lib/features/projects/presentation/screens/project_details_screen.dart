import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_events.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_states.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:share_plus/share_plus.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

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
    return BlocListener<MagicLinkBloc, MagicLinkState>(
      listener: (context, state) {
        if (state is MagicLinkGeneratedSuccess) {
          final link = state.linkId; // linkId es el url generado
          Share.share('Únete a mi proyecto: $link');
        } else if (state is MagicLinkGenerationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al generar el enlace: \\${state.error.message}',
              ),
            ),
          );
        }
      },
      child: BlocBuilder<MagicLinkBloc, MagicLinkState>(
        builder: (context, state) {
          final isLoading = state is MagicLinkLoading;
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    widget.project.name.value.fold(
                      (l) => 'Project Details',
                      (r) => r,
                    ),
                    style: const TextStyle(color: Colors.white),
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
                      // Botón para compartir el link de invitación
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir invitación'),
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  context.read<MagicLinkBloc>().add(
                                    MagicLinkRequested(
                                      projectId: widget.project.id.value,
                                    ),
                                  );
                                },
                      ),
                      const SizedBox(height: 16),
                      // Mostrar el ID del proyecto
                      const SizedBox(height: 16),
                      // Toggle buttons
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
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
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
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
