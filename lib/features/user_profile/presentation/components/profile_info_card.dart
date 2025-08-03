import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.space16),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary, size: 24),
            SizedBox(height: Dimensions.space8),
            Text(
              'This information helps us personalize your experience and connect you with the right collaborators.',
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
