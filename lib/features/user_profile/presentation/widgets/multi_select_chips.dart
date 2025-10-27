import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_borders.dart';

class MultiSelectChips extends StatefulWidget {
  final List<String> predefinedOptions;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool allowCustom;
  final String? customPlaceholder;

  const MultiSelectChips({
    super.key,
    required this.predefinedOptions,
    required this.selectedValues,
    required this.onChanged,
    this.allowCustom = false,
    this.customPlaceholder,
  });

  @override
  State<MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<MultiSelectChips> {
  final TextEditingController _customController = TextEditingController();
  final FocusNode _customFocusNode = FocusNode();
  bool _showCustomInput = false;

  @override
  void dispose() {
    _customController.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  void _toggleSelection(String value) {
    final newSelection = List<String>.from(widget.selectedValues);

    if (newSelection.contains(value)) {
      newSelection.remove(value);
    } else {
      newSelection.add(value);
    }

    widget.onChanged(newSelection);
  }

  void _addCustomValue() {
    final customValue = _customController.text.trim();
    if (customValue.isEmpty) return;

    final newSelection = List<String>.from(widget.selectedValues);
    if (!newSelection.contains(customValue)) {
      newSelection.add(customValue);
      widget.onChanged(newSelection);
    }

    _customController.clear();
    setState(() => _showCustomInput = false);
  }

  void _removeCustomValue(String value) {
    // Only allow removing custom values (not in predefined list)
    if (!widget.predefinedOptions.contains(value)) {
      _toggleSelection(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Dimensions.space8,
          runSpacing: Dimensions.space8,
          children: [
            // Predefined options
            ...widget.predefinedOptions.map((option) {
              final isSelected = widget.selectedValues.contains(option);
              return _SelectableChip(
                label: option,
                isSelected: isSelected,
                onTap: () => _toggleSelection(option),
              );
            }),

            // Selected custom values (not in predefined list)
            ...widget.selectedValues
                .where((value) => !widget.predefinedOptions.contains(value))
                .map((customValue) {
              return _CustomChip(
                label: customValue,
                onRemove: () => _removeCustomValue(customValue),
              );
            }),

            // Add custom button
            if (widget.allowCustom && !_showCustomInput)
              _AddCustomButton(
                onTap: () {
                  setState(() => _showCustomInput = true);
                  // Focus the text field after the next frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _customFocusNode.requestFocus();
                  });
                },
              ),
          ],
        ),

        // Custom input field
        if (_showCustomInput) ...[
          SizedBox(height: Dimensions.space12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customController,
                  focusNode: _customFocusNode,
                  decoration: InputDecoration(
                    hintText: widget.customPlaceholder ?? 'Add custom value',
                    hintStyle: AppTextStyle.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppBorders.medium,
                    ),
                  ),
                  style: AppTextStyle.bodySmall,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addCustomValue(),
                ),
              ),
              SizedBox(width: Dimensions.space8),
              IconButton(
                icon: const Icon(Icons.check_circle, color: AppColors.success),
                onPressed: _addCustomValue,
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: AppColors.error),
                onPressed: () {
                  _customController.clear();
                  setState(() => _showCustomInput = false);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.medium,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
            borderRadius: AppBorders.medium,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.space12,
              vertical: Dimensions.space8,
            ),
            child: Text(
              label,
              style: AppTextStyle.bodySmall.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _CustomChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.accent,
          width: 1.5,
        ),
        borderRadius: AppBorders.medium,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space8,
          vertical: Dimensions.space6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: Dimensions.space4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: Icon(
                Icons.close,
                size: Dimensions.iconSmall,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCustomButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.medium,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
              style: BorderStyle.solid,
            ),
            borderRadius: AppBorders.medium,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.space12,
              vertical: Dimensions.space8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: Dimensions.iconSmall,
                  color: AppColors.primary,
                ),
                SizedBox(width: Dimensions.space6),
                Text(
                  'Add Custom',
                  style: AppTextStyle.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
