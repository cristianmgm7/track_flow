import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../ui/feedback/app_feedback_system.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/navigation/app_bar.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_state.dart';
import '../widgets/voice_memo_card.dart';

class VoiceMemosScreenContent extends StatelessWidget {
  const VoiceMemosScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceMemoBloc, VoiceMemoState>(
      listener: (context, state) {
        if (state is VoiceMemoError) {
          AppFeedbackSystem.showBanner(context, title: 'Error', message: state.message);
        } else if (state is VoiceMemoActionSuccess) {
          AppFeedbackSystem.showBanner(context, title: 'Success', message: state.message);
        }
      },
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'Voice Memos',
          leading: AppIconButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => GoRouter.of(context).pop(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.voiceMemoRecording),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.mic, color: AppColors.onPrimary),
        ),
        body: BlocBuilder<VoiceMemoBloc, VoiceMemoState>(
          builder: (context, state) {
            if (state is VoiceMemoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VoiceMemoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    SizedBox(height: Dimensions.space16),
                    Text(
                      'Failed to load voice memos',
                      style: AppTextStyle.bodyLarge,
                    ),
                    SizedBox(height: Dimensions.space8),
                    Text(
                      state.message,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is VoiceMemosLoaded) {
              if (state.memos.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildMemosList(context, state.memos);
            }

            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none,
            size: 80,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: Dimensions.space24),
          Text(
            'No voice memos yet',
            style: AppTextStyle.headlineSmall,
          ),
          SizedBox(height: Dimensions.space8),
          Text(
            'Tap the microphone button to\nrecord your first memo',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemosList(BuildContext context, List<VoiceMemo> memos) {
    return ListView.separated(
      padding: EdgeInsets.all(Dimensions.space16),
      itemCount: memos.length,
      separatorBuilder: (_, __) => SizedBox(height: Dimensions.space12),
      itemBuilder: (context, index) {
        return VoiceMemoCard(memo: memos[index]);
      },
    );
  }
}
