import 'package:flutter/material.dart';

class ShuffleButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const ShuffleButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: _buildModeIndicator(
        icon: Icons.shuffle,
        isActive: isEnabled,
        label: 'Shuffle',
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
}