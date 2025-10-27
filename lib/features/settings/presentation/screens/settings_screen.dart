import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_state.dart';
import 'package:trackflow/features/settings/presentation/widgets/user_profile_section.dart';
import 'package:trackflow/features/settings/presentation/widgets/sign_out.dart';
import 'package:trackflow/features/ui/navigation/app_scaffold.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_bloc.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_event.dart';
import 'package:trackflow/features/user_profile/presentation/bloc/current_user/current_user_state.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/sync/domain/usecases/trigger_upstream_sync_usecase.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize user profile if not already loaded
    final currentUserBloc = context.read<CurrentUserBloc>();
    final currentState = currentUserBloc.state;

    // Only trigger profile loading if we're in initial state or error state
    if (currentState is CurrentUserInitial ||
        currentState is CurrentUserError) {
      AppLogger.info(
        'SettingsScreen: Initializing user profile loading',
        tag: 'SETTINGS_SCREEN',
      );
      currentUserBloc.add(WatchCurrentUserProfile());
    } else {
      AppLogger.info(
        'SettingsScreen: User profile already loaded or loading',
        tag: 'SETTINGS_SCREEN',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppFlowBloc, AppFlowState>(
      listener: (context, state) {
        if (state is AppFlowUnauthenticated) {
          context.go(AppRoutes.auth);
        }
      },
      child: AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: "Settings",
          centerTitle: true,
          showShadow: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(Dimensions.space16),
          children: [
            // User Profile Section
            const UserProfileSection(),
            SizedBox(height: Dimensions.space16),
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: EdgeInsets.all(Dimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Tools',
                      style: AppTextStyle.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Dimensions.space12),
                    // Manual Sync Button
                    ListTile(
                      leading: Icon(Icons.sync, color: AppColors.textPrimary),
                      title: Text(
                        'Sync Data',
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Force sync all data',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: Dimensions.iconSmall,
                      ),
                      onTap: () async {
                        try {
                          final triggerSync =
                              context.read<TriggerUpstreamSyncUseCase>();
                          await triggerSync.call();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sync triggered')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sync failed: $e')),
                          );
                        }
                      },
                    ),
                    SizedBox(height: Dimensions.space8),
                    // Audio Cache Demo removed
                    ListTile(
                      leading: Icon(
                        Icons.storage,
                        color: AppColors.textPrimary,
                      ),
                      title: Text(
                        'Storage Management',
                        style: AppTextStyle.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Manage cached audio and storage usage',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: Dimensions.iconSmall,
                      ),
                      onTap: () => context.push(AppRoutes.cacheManagement),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Dimensions.space16),

            // Sign Out Card
            const SignOut(),
          ],
        ),
      ),
    );
  }
}
