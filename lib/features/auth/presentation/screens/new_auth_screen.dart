import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_events.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/auth/glassmorphism_card.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';
import 'package:trackflow/core/app_flow/presentation/bloc/app_flow_bloc.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/ui/inputs/app_text_field.dart';

enum AuthStep { welcome, form }

class NewAuthScreen extends StatefulWidget {
  const NewAuthScreen({super.key});

  @override
  State<NewAuthScreen> createState() => _NewAuthScreenState();
}

class _NewAuthScreenState extends State<NewAuthScreen> {
  AuthStep _currentStep = AuthStep.welcome;
  bool _isLogin = false; // Default to signup mode for better UX
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _goToFormStep() {
    setState(() {
      _currentStep = AuthStep.form;
    });
  }

  void _goBack() {
    setState(() {
      switch (_currentStep) {
        case AuthStep.form:
          _currentStep = AuthStep.welcome;
          break;
        case AuthStep.welcome:
          break;
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(email: email, password: password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(email: email, password: password),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _signInWithApple() {
    context.read<AuthBloc>().add(AuthAppleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.info(
          'Auth screen received state: ${state.runtimeType}',
          tag: 'AUTH_SCREEN',
        );

        if (state is AuthError) {
          AppLogger.warning(
            'Auth error received: ${state.message}',
            tag: 'AUTH_SCREEN',
          );

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }

        // Handle successful authentication
        if (state is AuthAuthenticated) {
          AppLogger.info(
            'Auth successful! User: ${state.user.email} (ID: ${state.user.id})',
            tag: 'AUTH_SCREEN',
          );

          // Clear any existing error messages
          ScaffoldMessenger.of(context).clearSnackBars();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isLogin
                    ? 'Successfully signed in!'
                    : 'Account created successfully!',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );

          // Clear form fields after successful auth
          _emailController.clear();
          _passwordController.clear();

          // Trigger AppFlowBloc for proper state coordination
          AppLogger.info(
            'Triggering AppFlowBloc.checkAppFlow() after successful auth',
            tag: 'AUTH_SCREEN',
          );

          context.read<AppFlowBloc>().add(CheckAppFlow());
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grey900.withValues(alpha: 0.3),
                  AppColors.grey900.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (_currentStep != AuthStep.welcome)
                    Padding(
                      padding: EdgeInsets.all(Dimensions.space16),
                      child: Row(
                        children: [
                          GlassmorphismButton(
                            text: 'Back',
                            onPressed: _goBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            width: 100,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Dimensions.space24),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;

                            switch (_currentStep) {
                              case AuthStep.welcome:
                                return _buildWelcomeStep(isLoading);
                              case AuthStep.form:
                                return _buildFormStep(isLoading);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo y título
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            width: Dimensions.space32,
            height: Dimensions.space32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Container( 
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/logo/trackflow_staging.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: Dimensions.space24),

        Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Text(
            'Enjoy your\nown music',
            style: AppTextStyle.displayLarge,
          ),
        ),
        SizedBox(height: Dimensions.space12),

        Padding(
          padding: const EdgeInsets.only(left:16.0),
          child: Text(
            'All your team in the same place',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: Dimensions.space64),

        // Botones de acción
        GlassmorphismCard(
          child: Column(
            children: [
              GlassmorphismButton(
                text: 'Continue with Email',
                onPressed: _goToFormStep,
                icon: const Icon(Icons.email, color: AppColors.textPrimary),
              ),
              SizedBox(height: Dimensions.space16),
              GlassmorphismButton(
                text: 'Continue with Google',
                onPressed: isLoading ? null : _signInWithGoogle,
                isLoading: isLoading,
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: Dimensions.space16),
              if (Theme.of(context).platform == TargetPlatform.iOS)
                GlassmorphismButton(
                  text: 'Continue with Apple',
                  onPressed: isLoading ? null : _signInWithApple,
                  isLoading: isLoading,
                  icon: const Icon(Icons.apple, color: AppColors.textPrimary),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep(bool isLoading) {
    return Column(
      children: [
        Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: AppColors.grey900.withValues(alpha: 0.5),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),

        Text(
          _isLogin ? 'Sign in to your account' : 'Create your new account',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),

        SizedBox(height: Dimensions.space48),

        GlassmorphismCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Dimensions.space16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: Dimensions.space24),
                GlassmorphismButton(
                  text: _isLogin ? 'Sign In' : 'Create Account',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                  // Disable button during loading to prevent multiple submissions
                ),
                SizedBox(height: Dimensions.space16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign up'
                        : 'Already have an account? Sign in',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
