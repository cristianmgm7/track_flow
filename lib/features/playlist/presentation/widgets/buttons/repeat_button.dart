import 'package:flutter/material.dart';
import 'package:trackflow/features/audio_player/domain/entities/repeat_mode.dart';

class RepeatButton extends StatelessWidget {
  final RepeatMode mode;
  final VoidCallback onPressed;

  const RepeatButton({
    super.key,
    required this.mode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: _buildModeIndicator(
        icon: _getRepeatIcon(mode),
        isActive: mode != RepeatMode.none,
        label: _getRepeatLabel(mode),
      ),
    );
  }

  Widget _buildModeIndicator({
    required IconData icon,
    required bool isActive,
    required String label,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return Icons.repeat;
      case RepeatMode.single:
        return Icons.repeat_one;
      case RepeatMode.queue:
        return Icons.repeat;
    }
  }

  String _getRepeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return 'No Repeat';
      case RepeatMode.single:
        return 'Repeat One';
      case RepeatMode.queue:
        return 'Repeat All';
    }
  }
}