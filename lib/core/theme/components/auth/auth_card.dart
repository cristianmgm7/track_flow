import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_borders.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_shadows.dart';
import 'package:trackflow/core/theme/components/cards/base_card.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AuthCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      backgroundColor: AppColors.surface,
      padding: padding ?? EdgeInsets.all(Dimensions.space24),
      margin: margin ?? EdgeInsets.all(Dimensions.space16),
      borderRadius: AppBorders.large,
      boxShadow: AppShadows.card,
      child: child,
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? logo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (logo != null) ...[
          logo!,
          SizedBox(height: Dimensions.space16),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AuthForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isLogin;
  final Function(String email, String password) onSubmit;
  final VoidCallback? onToggleMode;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.onSubmit,
    this.onToggleMode,
    this.isLoading = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String _email = '';
  String _password = '';

  void _submit() {
    final isValid = widget.formKey.currentState!.validate();
    if (!isValid) return;
    
    widget.formKey.currentState!.save();
    widget.onSubmit(_email, _password);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildEmailField(),
          SizedBox(height: Dimensions.space16),
          _buildPasswordField(),
          SizedBox(height: Dimensions.space24),
          _buildSubmitButton(),
          if (widget.onToggleMode != null) ...[
            SizedBox(height: Dimensions.space16),
            _buildToggleButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: AppBorders.medium,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty || !value.contains("@")) {
          return "Invalid email";
        }
        return null;
      },
      onSaved: (value) => _email = value!,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: AppBorders.medium,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorders.medium,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Password is required";
        }
        if (value.length < 8) {
          return "Password must be at least 8 characters long";
        }
        return null;
      },
      onSaved: (value) => _password = value!,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: Dimensions.buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.medium,
          ),
        ),
        onPressed: widget.isLoading ? null : _submit,
        child: widget.isLoading
            ? SizedBox(
                width: Dimensions.iconMedium,
                height: Dimensions.iconMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : Text(
                widget.isLogin ? "Sign in" : "Sign up",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: widget.onToggleMode,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: Dimensions.space12),
      ),
      child: Text(
        widget.isLogin ? "Create an account" : "I already have an account",
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final bool isLoading;

  const AuthSocialButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: Dimensions.buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: AppBorders.medium,
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: Dimensions.iconMedium,
                  height: Dimensions.iconMedium,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : Image.asset(
                  assetPath,
                  height: Dimensions.iconLarge,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

class AuthContainer extends StatelessWidget {
  final Widget child;

  const AuthContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: Dimensions.space16,
              right: Dimensions.space16,
              top: Dimensions.space16,
              bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.space16,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}