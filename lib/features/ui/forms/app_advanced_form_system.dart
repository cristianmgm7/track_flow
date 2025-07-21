import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_style.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_borders.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';
import '../inputs/app_text_field.dart';

/// Advanced Form System for TrackFlow
///
/// Provides complex form handling with multi-step validation,
/// dynamic fields, and enhanced user experience.
class AppAdvancedFormSystem {
  // Multi-step form
  static Widget buildMultiStepForm({
    required List<FormStep> steps,
    required Function(Map<String, dynamic>) onSubmit,
    String? title,
    bool showProgress = true,
  }) {
    return MultiStepForm(
      steps: steps,
      onSubmit: onSubmit,
      title: title,
      showProgress: showProgress,
    );
  }

  // Dynamic form
  static Widget buildDynamicForm({
    required List<DynamicField> fields,
    required Function(Map<String, dynamic>) onSubmit,
    String? title,
  }) {
    return DynamicForm(fields: fields, onSubmit: onSubmit, title: title);
  }

  // Form validation
  static String? validateField({
    required String value,
    required FieldValidation validation,
  }) {
    return validation.validate(value);
  }
}

/// Form step for multi-step forms
class FormStep {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<FieldValidation> validations;

  const FormStep({
    required this.title,
    this.subtitle,
    required this.child,
    this.validations = const [],
  });
}

/// Dynamic field for dynamic forms
class DynamicField {
  final String key;
  final String label;
  final String? hint;
  final FieldType type;
  final List<FieldValidation> validations;
  final Map<String, dynamic>? options;

  const DynamicField({
    required this.key,
    required this.label,
    this.hint,
    required this.type,
    this.validations = const [],
    this.options,
  });
}

/// Field types for dynamic forms
enum FieldType {
  text,
  email,
  password,
  number,
  phone,
  date,
  time,
  select,
  multiSelect,
  checkbox,
  radio,
  textarea,
  file,
}

/// Field validation
class FieldValidation {
  final String? Function(String) validate;
  final String errorMessage;

  const FieldValidation({required this.validate, required this.errorMessage});

  // Predefined validations
  static const FieldValidation required = FieldValidation(
    validate: _validateRequired,
    errorMessage: 'This field is required',
  );

  static const FieldValidation email = FieldValidation(
    validate: _validateEmail,
    errorMessage: 'Please enter a valid email',
  );

  static const FieldValidation password = FieldValidation(
    validate: _validatePassword,
    errorMessage: 'Password must be at least 8 characters',
  );

  static const FieldValidation phone = FieldValidation(
    validate: _validatePhone,
    errorMessage: 'Please enter a valid phone number',
  );

  static String? _validateRequired(String value) {
    return value.trim().isEmpty ? 'This field is required' : null;
  }

  static String? _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return !emailRegex.hasMatch(value) ? 'Please enter a valid email' : null;
  }

  static String? _validatePassword(String value) {
    return value.length < 8 ? 'Password must be at least 8 characters' : null;
  }

  static String? _validatePhone(String value) {
    final phoneRegex = RegExp(r'^\+?[\d\s-\(\)]+$');
    return !phoneRegex.hasMatch(value)
        ? 'Please enter a valid phone number'
        : null;
  }
}

/// Multi-step form component
class MultiStepForm extends StatefulWidget {
  final List<FormStep> steps;
  final Function(Map<String, dynamic>) onSubmit;
  final String? title;
  final bool showProgress;

  const MultiStepForm({
    super.key,
    required this.steps,
    required this.onSubmit,
    this.title,
    this.showProgress = true,
  });

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _animationController.forward().then((_) {
        setState(() {
          _currentStep++;
        });
        _animationController.reverse();
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _animationController.forward().then((_) {
        setState(() {
          _currentStep--;
        });
        _animationController.reverse();
      });
    }
  }

  void _submitForm() {
    widget.onSubmit(_formData);
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStep];
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == widget.steps.length - 1;

    return Column(
      children: [
        if (widget.showProgress) ...[
          _buildProgressIndicator(),
          SizedBox(height: Dimensions.space24),
        ],
        if (widget.title != null) ...[
          Text(widget.title!, style: AppTextStyle.headlineMedium),
          SizedBox(height: Dimensions.space16),
        ],
        Text(currentStep.title, style: AppTextStyle.titleLarge),
        if (currentStep.subtitle != null) ...[
          SizedBox(height: Dimensions.space8),
          Text(currentStep.subtitle!, style: AppTextStyle.bodyMedium),
        ],
        SizedBox(height: Dimensions.space24),
        Expanded(
          child: AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slideAnimation.value * 50, 0),
                child: Opacity(
                  opacity: 1 - _slideAnimation.value,
                  child: currentStep.child,
                ),
              );
            },
          ),
        ),
        SizedBox(height: Dimensions.space24),
        _buildNavigationButtons(isFirstStep, isLastStep),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(widget.steps.length, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < widget.steps.length - 1 ? Dimensions.space8 : 0,
            ),
            child: Column(
              children: [
                Container(
                  width: Dimensions.space24,
                  height: Dimensions.space24,
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? AppColors.success
                            : (isActive
                                ? AppColors.primary
                                : AppColors.disabled),
                    shape: BoxShape.circle,
                  ),
                  child:
                      isCompleted
                          ? Icon(
                            AppIcons.success,
                            color: Colors.white,
                            size: AppIcons.sizeSmall,
                          )
                          : Text(
                            '${index + 1}',
                            style: AppTextStyle.labelMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                ),
                if (index < widget.steps.length - 1)
                  Container(
                    height: 2,
                    color: isCompleted ? AppColors.success : AppColors.disabled,
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNavigationButtons(bool isFirstStep, bool isLastStep) {
    return Row(
      children: [
        if (!isFirstStep)
          Expanded(
            child: SecondaryButton(
              text: 'Previous',
              onPressed: _previousStep,
              icon: AppIcons.back,
            ),
          ),
        if (!isFirstStep) SizedBox(width: Dimensions.space12),
        Expanded(
          child: PrimaryButton(
            text: isLastStep ? 'Submit' : 'Next',
            onPressed: isLastStep ? _submitForm : _nextStep,
            icon: isLastStep ? AppIcons.confirm : AppIcons.forward,
            iconRight: true,
          ),
        ),
      ],
    );
  }
}

/// Dynamic form component
class DynamicForm extends StatefulWidget {
  final List<DynamicField> fields;
  final Function(Map<String, dynamic>) onSubmit;
  final String? title;

  const DynamicForm({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.title,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateField(String key, String value) {
    final field = widget.fields.firstWhere((f) => f.key == key);
    String? error;

    for (final validation in field.validations) {
      final validationError = validation.validate(value);
      if (validationError != null) {
        error = validationError;
        break;
      }
    }

    setState(() {
      _errors[key] = error;
    });
  }

  void _submitForm() {
    // Validate all fields
    bool isValid = true;
    for (final field in widget.fields) {
      final value = _controllers[field.key]?.text ?? '';
      _validateField(field.key, value);
      if (_errors[field.key] != null) {
        isValid = false;
      }
    }

    if (isValid) {
      // Collect form data
      for (final field in widget.fields) {
        _formData[field.key] = _controllers[field.key]?.text ?? '';
      }
      widget.onSubmit(_formData);
    }
  }

  Widget _buildField(DynamicField field) {
    final controller = _controllers[field.key];
    final error = _errors[field.key];

    switch (field.type) {
      case FieldType.text:
      case FieldType.email:
      case FieldType.password:
      case FieldType.number:
      case FieldType.phone:
        return AppTextField(
          labelText: field.label,
          hintText: field.hint,
          controller: controller,
          errorText: error,
          keyboardType: _getKeyboardType(field.type),
          obscureText: field.type == FieldType.password,
          onChanged: (value) => _validateField(field.key, value),
        );

      case FieldType.select:
        return _buildSelectField(field);

      case FieldType.checkbox:
        return _buildCheckboxField(field);

      case FieldType.radio:
        return _buildRadioField(field);

      case FieldType.textarea:
        return _buildTextareaField(field);

      default:
        return AppTextField(
          labelText: field.label,
          hintText: field.hint,
          controller: controller,
          errorText: error,
          onChanged: (value) => _validateField(field.key, value),
        );
    }
  }

  TextInputType _getKeyboardType(FieldType type) {
    switch (type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  Widget _buildSelectField(DynamicField field) {
    final options = field.options?['options'] as List<String>? ?? [];
    final selectedValue = _formData[field.key] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: AppTextStyle.labelMedium),
        SizedBox(height: Dimensions.space8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: AppBorders.medium),
            errorText: _errors[field.key],
          ),
          items:
              options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _formData[field.key] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxField(DynamicField field) {
    final isChecked = _formData[field.key] as bool? ?? false;

    return CheckboxListTile(
      title: Text(field.label),
      value: isChecked,
      onChanged: (value) {
        setState(() {
          _formData[field.key] = value ?? false;
        });
      },
    );
  }

  Widget _buildRadioField(DynamicField field) {
    final options = field.options?['options'] as List<String>? ?? [];
    final selectedValue = _formData[field.key] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: AppTextStyle.labelMedium),
        SizedBox(height: Dimensions.space8),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedValue,
            onChanged: (value) {
              setState(() {
                _formData[field.key] = value;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildTextareaField(DynamicField field) {
    final controller = _controllers[field.key];
    final error = _errors[field.key];

    return AppTextField(
      labelText: field.label,
      hintText: field.hint,
      controller: controller,
      errorText: error,
      maxLines: 4,
      onChanged: (value) => _validateField(field.key, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: AppTextStyle.headlineMedium),
          SizedBox(height: Dimensions.space24),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: widget.fields.length,
            itemBuilder: (context, index) {
              final field = widget.fields[index];
              return Padding(
                padding: EdgeInsets.only(bottom: Dimensions.space16),
                child: _buildField(field),
              );
            },
          ),
        ),
        SizedBox(height: Dimensions.space24),
        PrimaryButton(
          text: 'Submit',
          onPressed: _submitForm,
          icon: AppIcons.confirm,
          width: double.infinity,
        ),
      ],
    );
  }
}
