import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_projects_section.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_tracks_section.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_comments_section.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const WatchDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(
        title: 'Dashboard',
        centerTitle: true,
        showShadow: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: Dimensions.space16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Dimensions.space24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(const WatchDashboard());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const WatchDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: Dimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Projects Section
                    DashboardProjectsSection(
                      projects: state.projectPreview,
                    ),
                    SizedBox(height: Dimensions.space24),

                    // Tracks Section
                    DashboardTracksSection(
                      tracks: state.trackPreview,
                    ),
                    SizedBox(height: Dimensions.space24),

                    // Comments Section
                    DashboardCommentsSection(
                      comments: state.recentComments,
                    ),
                  ],
                ),
              ),
            );
          }

          // Fallback for unknown states
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

