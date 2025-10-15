import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

/// Dedicated widget for the delete background shown during swipe-to-dismiss
class VoiceMemoDeleteBackground extends StatelessWidget {
  const VoiceMemoDeleteBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: Dimensions.space20),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
